// License: MPL-2.0
// (c) 2022 Bor Grošelj Simić <bor.groseljsimic@telemach.net>
// (c) 2021 Drew DeVault <sir@cmpwn.com>
// (c) 2021 Ember Sawady <ecs@d2evs.net>

// Reads an entire buffer, perhaps issuing several [[read]] calls to do so. If
// EOF is immediately encountered, it is returned; if [[EOF]] is encountered
// partway through reading the buffer, [[underread]] is returned.
export fn readall(in: handle, buf: []u8) (size | EOF | error) = {
	let z: size = 0;
	for (z < len(buf)) {
		match (read(in, buf[z..])?) {
		case EOF =>
			if (z == 0) {
				return EOF;
			};
			return z: underread: error;
		case let n: size =>
			z += n;
		};
	};
	return z;
};

// Writes an entire buffer, perhaps issuing several [[write]] calls to do so.
// Aborts on errors after partial writes. Hence it should only be used if it is
// certain that the underlying writes will not fail after an initial write.
export fn writeall(out: handle, buf: []u8) (size | error) = {
	let z: size = 0;
	for (z < len(buf)) {
		z += match (write(out, buf[z..])) {
		case let s: size =>
			yield s;
		case let e: error =>
			if (z == 0) {
				return e;
			};

			abort("error after partial write");
		};
	};
	return z;
};
