// License: MPL-2.0
// (c) 2021-2023 Alexey Yerin <yyp@disroot.org>
// (c) 2021-2023 Drew DeVault <sir@cmpwn.com>
// (c) 2021 Ember Sawady <ecs@d2evs.net>
use bytes;
use encoding::utf8;
use errors;
use io;
use strings;
use types;

def BUFSIZ: size = 4096;

export type scanner = struct {
	src: io::handle,
	buffer: []u8,
	// Number of bytes available in buffer
	pending: size,
	// Number of bytes returned to the user
	readout: size,
	// User-confirmed maximum size of read buffer
	maxread: size,
};

// Creates a new [[scanner]] which will allocate and maintain a read buffer for
// efficient reading of files. The scanner will read ahead only up to maxread
// bytes, which can be [[types::SIZE_MAX]] if no limit is required. The user
// must free resources associated with the scanner using [[finish]] after use.
//
// Reads from the scanner will return [[errors::overflow]] if maxread is
// reached.
export fn newscanner(src: io::handle, maxread: size) scanner = {
	return scanner {
		src = src,
		buffer = alloc([0...], BUFSIZ),
		maxread = maxread,
		pending = 0,
		readout = 0,
	};
};

// Creates a new [[scanner]] using a user-provided buffer. The scanner will
// return [[errors::overflow]] if the buffer length is reached, but will not
// perform any allocations. The user should not call [[finish]] after use unless
// they wish to free the underlying buffer through bufio.
export fn newscanner_static(src: io::handle, buffer: []u8) scanner = {
	return scanner {
		src = src,
		buffer = buffer,
		maxread = len(buffer),
		pending = 0,
		readout = 0,
	};
};

// Frees resources associated associated with a [[scanner]]. Does not close the
// underlying I/O handle.
export fn finish(scan: *scanner) void = {
	free(scan.buffer);
};

// Fills up the scanner buffer with data from the underlying I/O handle. If no
// space remains in the read buffer, it is expanded by BUFSIZ (up to maxread).
// Then, one read from the underlying I/O handle is performed and scan.pending
// is updated accordingly. Returns the number of bytes which had been available
// prior to the call.
fn scan_readahead(scan: *scanner) (size | io::EOF | io::error) = {
	if (scan.pending >= len(scan.buffer)) {
		let readahead = scan.pending + BUFSIZ;
		if (readahead > scan.maxread) {
			readahead = scan.maxread;
		};
		if (scan.pending >= readahead) {
			return errors::overflow;
		};
		append(scan.buffer, [0...], readahead);
	};

	const prev = scan.pending;
	match (io::read(scan.src, scan.buffer[scan.pending..])?) {
	case let z: size =>
		scan.pending += z;
		return prev;
	case io::EOF =>
		return io::EOF;
	};
};

// Shifts the buffer towards the start, discarding bytes which were read out.
fn scan_shift(scan: *scanner) void = {
	const n = scan.readout;
	if (n == 0) {
		return;
	};
	scan.buffer[..len(scan.buffer) - n] = scan.buffer[n..];
	scan.readout = 0;
	scan.pending -= n;
};

// Consumes N bytes from the buffer, updating scan.readout. User must call
// [[scan_shift]] before calling scan_consume again.
fn scan_consume(scan: *scanner, n: size) []u8 = {
	assert(len(scan.buffer) >= n && scan.readout == 0);
	scan.readout = n;
	return scan.buffer[..n];
};

// Reads one byte from a [[scanner]].
export fn scan_byte(scan: *scanner) (u8 | io::EOF | io::error) = {
	if (scan.pending == 0) {
		match (scan_readahead(scan)?) {
		case io::EOF =>
			return io::EOF;
		case size =>
			yield;
		};
	};

	// Consume previous read, if any
	scan_shift(scan);
	// Consume this read right away
	defer scan_shift(scan);

	return scan_consume(scan, 1)[0];
};

// Reads the next token from a [[scanner]], delimited by delim. The return value
// is borrowed from the internal scanner buffer, which is invalidated during
// subsequent operations which use this scanner.
export fn scan_bytes(
	scan: *scanner,
	delim: (u8 | []u8),
) ([]u8 | io::EOF | io::error) = {
	scan_shift(scan);

	let i = 0z, nread = 0z;
	for (true) {
		match (bytes::index(scan.buffer[nread..scan.pending], delim)) {
		case let ix: size =>
			i = ix;
			break;
		case void =>
			yield;
		};

		match (scan_readahead(scan)?) {
		case io::EOF =>
			if (scan.pending == 0) {
				return io::EOF;
			};
			return scan_consume(scan, scan.pending);
		case let z: size =>
			// No need to re-index the earlier part of the buffer
			nread += z;
		};
	};

	const ndelim = match (delim) {
	case u8 =>
		yield 1z;
	case let u: []u8 =>
		yield len(u);
	};
	const nuser = nread + i, nconsume = nuser + ndelim;
	return scan_consume(scan, nconsume)[..nuser];
};

// Reads one rune from a [[scanner]].
export fn scan_rune(
	scan: *scanner,
) (rune | io::EOF | io::error | utf8::invalid) = {
	if (scan.pending == 0) {
		match (scan_readahead(scan)?) {
		case io::EOF =>
			if (scan.pending == 0) {
				return io::EOF;
			};
		case size =>
			yield;
		};
	};
	const sz = match (utf8::utf8sz(scan.buffer[0])) {
	case let z: size =>
		yield z;
	case void =>
		return utf8::invalid;
	};

	for (scan.pending < sz) {
		match (scan_readahead(scan)?) {
		case io::EOF =>
			return utf8::invalid;
		case size =>
			yield;
		};
	};

	// Consume previous read, if any
	scan_shift(scan);
	// Consume this read right away
	defer scan_shift(scan);

	const buf = scan_consume(scan, sz);
	const dec = utf8::decode(buf[..sz]);
	match (utf8::next(&dec)?) {
	case let r: rune =>
		return r;
	case void =>
		return io::EOF;
	case utf8::more =>
		return utf8::invalid;
	};
};

@test fn scan_rune() void = {
	let in = fixed(strings::toutf8("1234"), io::mode::READ);
	let scan = newscanner(&in, 4);
	assert(scan_rune(&scan) == '1', "expected '1'");
	assert(scan_rune(&scan) == '2', "expected '2'");
	assert(scan_rune(&scan) == '3', "expected '3'");
	assert(scan_rune(&scan) == '4', "expected '4'");
	finish(&scan);
};

// Scans a string of text from a [[scanner]] up to some delimiter. The return
// value is borrowed from the internal scanner buffer, which is invalidated
// during subsequent operations which use this scanner.
export fn scan_string(
	scan: *scanner,
	delim: str,
) (const str | io::EOF | io::error | utf8::invalid) = {
	const token = match (scan_bytes(scan, strings::toutf8(delim))?) {
	case let token: []u8 =>
		yield token;
	case io::EOF =>
		return io::EOF;
	};
	return strings::fromutf8(token)?;
};

// Scans the next line of text from a [[scanner]]. The return value is borrowed
// from the internal scanner buffer, which is invalidated during subsequent
// operations which use this scanner.
export fn scan_line(
	scan: *scanner,
) (const str | io::EOF | io::error | utf8::invalid) = {
	return scan_string(scan, "\n");
};

// Returns the internal scanner buffer, which contains all bytes read ahead by
// the scanner up to this point.
export fn scan_buffer(scan: *scanner) []u8 = {
	scan_shift(scan);
	return scan.buffer[..scan.pending];
};

// Reads a single byte from an [[io::handle]].
export fn scanbyte(file: io::handle) (u8 | io::EOF | io::error) = {
	let buf: [1]u8 = [0...];

	match (io::readall(file, buf)?) {
	case size =>
		return buf[0];
	case io::EOF =>
		return io::EOF;
	};
};

// Reads a slice of bytes until the delimiter. Delimiter is not included. The
// return value must be freed by the caller.
export fn scantok(file: io::handle, delim: u8...) ([]u8 | io::EOF | io::error) = {
	let buf: []u8 = [];

	for (true) {
		match (scanbyte(file)?) {
		case let res: u8 =>
			if (bytes::contains(delim, res)) {
				break;
			};
			append(buf, res);
		case io::EOF =>
			if (len(buf) == 0) {
				return io::EOF;
			};
			break;
		};
	};

	return buf;
};

// Reads a slice of bytes until a newline character (\n, 0x0A). Newline itself
// is not included. The return value must be freed by the caller.
export fn scanline(file: io::handle) ([]u8 | io::EOF | io::error) =
	scantok(file, '\n');

// Reads a rune from a UTF-8 stream.
export fn scanrune(
	file: io::handle,
) (rune | utf8::invalid | io::EOF | io::error) = {
	let b: [4]u8 = [0...];
	match (io::readall(file, b[..1])?) {
	case let n: size => void;
	case io::EOF =>
		return io::EOF;
	};

	const sz = match (utf8::utf8sz(b[0])) {
	case let z: size =>
		yield z;
	case void =>
		return utf8::invalid;
	};

	if (sz == 1) {
		return b[0]: u32: rune;
	};

	match (io::readall(file, b[1..sz])) {
	case let n: size => void;
	case io::EOF =>
		return io::EOF;
	case let err: io::error =>
		return if (err is io::underread) utf8::invalid else err;
	};

	let dec = utf8::decode(b[..sz]);
	match (utf8::next(&dec)?) {
	case let r: rune =>
		return r;
	case void =>
		return io::EOF;
	case utf8::more =>
		return utf8::invalid;
	};
};

@test fn scanbyte() void = {
	let buf = fixed([1, 3, 3, 7], io::mode::READ);

	assert(scanbyte(&buf) as u8 == 1);
	assert(scanbyte(&buf) as u8 == 3);
	assert(scanbyte(&buf) as u8 == 3);
	assert(scanbyte(&buf) as u8 == 7);
	assert(scanbyte(&buf) is io::EOF);
};

@test fn scantok() void = {
	let buf = fixed([1, 3, 4, 5, 3, 7], io::mode::READ);

	let tok = scantok(&buf, 4) as []u8;
	defer free(tok);
	assert(bytes::equal(tok, [1, 3]));

	let tok = scantok(&buf, 7) as []u8;
	defer free(tok);
	assert(bytes::equal(tok, [5, 3]));

	assert(scantok(&buf, 1) is io::EOF);
};

@test fn scanline() void = {
	let helloworld = strings::toutf8("hello\nworld");
	let buf = fixed(helloworld, io::mode::READ);

	let line = scanline(&buf) as []u8;
	defer free(line);
	assert(bytes::equal(line, strings::toutf8("hello")));

	let line = scanline(&buf) as []u8;
	defer free(line);
	assert(bytes::equal(line, strings::toutf8("world")));

	assert(scanline(&buf) is io::EOF);
};

@test fn scanrune() void = {
	let in = fixed([
		0xE3, 0x81, 0x93, 0xE3, 0x82, 0x93, 0xE3, 0x81,
		0xAB, 0xE3, 0x81, 0xA1, 0xE3, 0x81, 0xAF, 0x00,
	], io::mode::READ);

	const expected: [_](rune | utf8::invalid | io::EOF | io::error) = [
		'こ', 'ん', 'に', 'ち', 'は', '\0', io::EOF,
	];
	for (let i = 0z; i < len(expected); i += 1) {
		let want = expected[i];

		match (scanrune(&in)) {
		case let r: rune =>
			assert(want is rune && want as rune == r);
		case io::EOF =>
			assert(want is io::EOF);
		case =>
			abort();
		};
	};
};

@test fn scan_rune() void = {
	let in = fixed(strings::toutf8("hello"), io::mode::READ);
	let scanner = newscanner(&in, 32);

	const expected: [_](rune | utf8::invalid | io::EOF | io::error) = [
		'h', 'e', 'l', 'l', 'o', io::EOF,
	];
	for (let i = 0z; i < len(expected); i += 1) {
		let want = expected[i];

		match (scan_rune(&scanner)) {
		case let r: rune =>
			assert(want is rune && want as rune == r);
		case io::EOF =>
			assert(want is io::EOF);
		case =>
			abort();
		};
	};
};

@test fn scan_rune_cutoff() void = {
	let in = fixed([
		'a', 0xE3,
	], io::mode::READ);
	let scanner = newscanner(&in, 32);

	const expected: [_](rune | utf8::invalid | io::EOF | io::error) = [
		'a', utf8::invalid,
	];
	for (let i = 0z; i < len(expected); i += 1) {
		let want = expected[i];

		match (scan_rune(&scanner)) {
		case let r: rune =>
			assert(want is rune && want as rune == r);
		case io::EOF =>
			assert(want is io::EOF);
		case utf8::invalid =>
			assert(want is utf8::invalid);
		case =>
			abort();
		};
	};
};
