// License: MPL-2.0
// (c) 2021 Bor Grošelj Simić <bor.groseljsimic@telemach.net>
// (c) 2021 Drew DeVault <sir@cmpwn.com>
// (c) 2021 Ember Sawady <ecs@d2evs.net>
// (c) 2021 Sudipto Mallick <smlckz@disroot.org>
// (c) 2021 Sudipto Mallick <smlckz@envs.net>
// (c) 2021 Vlad-Stefan Harbuz <vlad@vladh.net>

// Using Ryū: fast float-to-string conversion algorithm by Ulf Adams.
// https://doi.org/10.1145/3192366.3192369
// This Hare implementation is translated from the original
// C implementation here: https://github.com/ulfjack/ryu

use math;
use types;

type r128 = struct {
	hi: u64,
	lo: u64,
};

// TODO: use 128-bit integers when implemented
fn u128mul(a: u64, b: u64) r128 = {
	const a0 = a: u32: u64, a1 = a >> 32;
	const b0 = b: u32: u64, b1 = b >> 32;
	const p00 = a0 * b0, p01 = a0 * b1, p10 = a1 * b0, p11 = a1 * b1;
	const p00_lo = p00: u32: u64, p00_hi = p00 >> 32;
	const mid1 = p10 + p00_hi;
	const mid1_lo = mid1: u32: u64, mid1_hi = mid1 >> 32;
	const mid2 = p01 + mid1_lo;
	const mid2_lo = mid2: u32: u64, mid2_hi = mid2 >> 32;
	const r_hi = p11 + mid1_hi + mid2_hi;
	const r_lo = (mid2_lo << 32) | p00_lo;
	return r128 { hi = r_hi, lo = r_lo };
};

// TODO: Same as above
fn u128rshift(lo: u64, hi: u64, s: u32) u64 = {
	assert(0 <= s);
	assert(s <= 64);
	return (hi << (64 - s)) | (lo >> s);
};

fn pow5fac(value: u64) u32 = {
	const m_inv_5: u64 = 14757395258967641293; // 5 * m_inv_5 = 1 (mod 2^64)
	const n_div_5: u64 = 3689348814741910323;
	let count: u32 = 0;
	for (true) {
		assert(value != 0);
		value *= m_inv_5;
		if (value > n_div_5) break;
		count += 1;
	};
	return count;
};

fn pow5fac32(value: u32) u32 = {
	let count: u32 = 0;
	for (true) {
		assert(value != 0);
		const q = value / 5, r = value % 5;
		if (r != 0) break;
		value = q;
		count += 1;
	};
	return count;
};

fn ibool(b: bool) u8 = if (b) 1 else 0;

fn pow5multiple(v: u64, p: u32) bool = pow5fac(v) >= p;
fn pow5multiple32(v: u32, p: u32) bool = pow5fac32(v) >= p;

fn pow2multiple(v: u64, p: u32) bool = {
	assert(v > 0);
	assert(p < 64);
	return (v & ((1u64 << p) - 1)) == 0;
};

fn pow2multiple32(v: u32, p: u32) bool = {
	assert(v > 0);
	assert(p < 32);
	return (v & ((1u32 << p) - 1)) == 0;
};

fn mulshift64(m: u64, mul: (u64, u64), j: u32) u64 = {
	// m is maximum 55 bits
	let r0 = u128mul(m, mul.0), r1 = u128mul(m, mul.1);
	const sum = r1.lo + r0.hi;
	r1.hi += ibool(sum < r0.hi);
	return u128rshift(sum, r1.hi, j - 64);
};

fn mulshiftall64(m: u64, mul: (u64, u64), j: i32, mm_shift: u32) (u64, u64, u64) = {
	m <<= 1;
	const r0 = u128mul(m, mul.0), r1 = u128mul(m, mul.1);
	const lo = r0.lo, tmp = r0.hi, mid = tmp + r1.lo;
	const hi = r1.hi + ibool(mid < tmp);
	const lo2 = lo + mul.0;
	const mid2 = mid + mul.1 + ibool(lo2 < lo);
	const hi2 = hi + ibool(mid2 < mid);
	const v_plus = u128rshift(mid2, hi2, (j - 64 - 1): u32);
	const v_minus = if (mm_shift == 1) {
		const lo3 = lo - mul.0;
		const mid3 = mid - mul.1 - ibool(lo3 > lo);
		const hi3 = hi - ibool(mid3 > mid);
		yield u128rshift(mid3, hi3, (j - 64 - 1): u32);
	} else {
		const lo3 = lo + lo;
		const mid3 = mid + mid + ibool(lo3 < lo);
		const hi3 = hi + hi + ibool(mid3 < mid);
		const lo4 = lo3 - mul.0;
		const mid4 = mid3 - mul.1 - ibool(lo4 > lo3);
		const hi4 = hi3 - ibool(mid4 > mid3);
		yield u128rshift(mid4, hi4, (j - 64): u32);
	};
	const v_rounded = u128rshift(mid, hi, (j - 64 - 1): u32);
	return (v_plus, v_rounded, v_minus);
};

fn mulshift32(m: u32, a: u64, s: u32) u32 = {
	assert(s > 32);
	const a_lo = a: u32: u64, a_hi = a >> 32;
	const b0 = m * a_lo, b1 = m * a_hi;
	const sum = (b0 >> 32) + b1, ss = sum >> (s - 32);
	assert(ss <= types::U32_MAX);
	return ss: u32;
};

fn mulpow5inv_divpow2(m: u32, q: u32, j: i32) u32 = {
	const pow5 = f64computeinvpow5(q);
	return mulshift32(m, pow5.1 + 1, j: u32);
};

fn mulpow5_divpow2(m: u32, i: u32, j: i32) u32 = {
	const pow5 = f64computepow5(i);
	return mulshift32(m, pow5.1, j: u32);
};

fn log2pow5(e: u32) u32 = {
	assert(e <= 3528);
	return ((e * 1217359) >> 19);
};

fn ceil_log2pow5(e: u32) u32 = log2pow5(e) + 1;

fn pow5bits(e: u32) u32 = ceil_log2pow5(e);

fn log10pow2(e: u32) u32 = {
	assert(e <= 1650);
	return ((e * 78913) >> 18);
};

fn log10pow5(e: u32) u32 = {
	assert(e <= 2620);
	return ((e * 732923) >> 20);
};

def F64_POW5_INV_BITCOUNT: u8 = 125;
def F64_POW5_BITCOUNT: u8 = 125;

def F32_POW5_INV_BITCOUNT: u8 = F64_POW5_INV_BITCOUNT - 64;
def F32_POW5_BITCOUNT: u8 = F64_POW5_BITCOUNT - 64;

const F64_POW5_INV_SPLIT2: [15][2]u64 = [
	[1, 2305843009213693952],
	[5955668970331000884, 1784059615882449851],
	[8982663654677661702, 1380349269358112757],
	[7286864317269821294, 2135987035920910082],
	[7005857020398200553, 1652639921975621497],
	[17965325103354776697, 1278668206209430417],
	[8928596168509315048, 1978643211784836272],
	[10075671573058298858, 1530901034580419511],
	[597001226353042382, 1184477304306571148],
	[1527430471115325346, 1832889850782397517],
	[12533209867169019542, 1418129833677084982],
	[5577825024675947042, 2194449627517475473],
	[11006974540203867551, 1697873161311732311],
	[10313493231639821582, 1313665730009899186],
	[12701016819766672773, 2032799256770390445],
];

const POW5_INV_OFFSETS: [19]u32 = [
	0x54544554, 0x04055545, 0x10041000, 0x00400414, 0x40010000, 0x41155555,
	0x00000454, 0x00010044, 0x40000000, 0x44000041, 0x50454450, 0x55550054,
	0x51655554, 0x40004000, 0x01000001, 0x00010500, 0x51515411, 0x05555554,
	0x00000000
];

const F64_POW5_SPLIT2: [13][2]u64 = [
	[0, 1152921504606846976],
	[0, 1490116119384765625],
	[1032610780636961552, 1925929944387235853],
	[7910200175544436838, 1244603055572228341],
	[16941905809032713930, 1608611746708759036],
	[13024893955298202172, 2079081953128979843],
	[6607496772837067824, 1343575221513417750],
	[17332926989895652603, 1736530273035216783],
	[13037379183483547984, 2244412773384604712],
	[1605989338741628675, 1450417759929778918],
	[9630225068416591280, 1874621017369538693],
	[665883850346957067, 1211445438634777304],
	[14931890668723713708, 1565756531257009982]
];

const POW5_OFFSETS: [21]u32 = [
	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x40000000, 0x59695995,
	0x55545555, 0x56555515, 0x41150504, 0x40555410, 0x44555145, 0x44504540,
	0x45555550, 0x40004000, 0x96440440, 0x55565565, 0x54454045, 0x40154151,
	0x55559155, 0x51405555, 0x00000105
];

def POW5_TABLE_SIZE: u8 = 26;

const POW5_TABLE: [POW5_TABLE_SIZE]u64 = [
	1u64, 5u64, 25u64, 125u64, 625u64, 3125u64, 15625u64, 78125u64,
	390625u64, 1953125u64, 9765625u64, 48828125u64, 244140625u64,
	1220703125u64, 6103515625u64, 30517578125u64, 152587890625u64,
	762939453125u64, 3814697265625u64, 19073486328125u64, 95367431640625u64,
	476837158203125u64, 2384185791015625u64, 11920928955078125u64,
	59604644775390625u64, 298023223876953125u64 //, 1490116119384765625u64
];

fn f64computeinvpow5(i: u32) (u64, u64) = {
	const base = ((i + POW5_TABLE_SIZE - 1) / POW5_TABLE_SIZE): u32;
	const base2 = base * POW5_TABLE_SIZE;
	const mul = F64_POW5_INV_SPLIT2[base];
	const off = base2 - i;
	if (off == 0) {
		return (mul[0], mul[1]);
	};
	const m = POW5_TABLE[off];
	const r1 = u128mul(m, mul[1]), r0 = u128mul(m, mul[0] - 1);
	let high1 = r1.hi, low1 = r1.lo, high0 = r0.hi, low0 = r0.lo;
	const sum = high0 + low1;
	if (sum < high0) {
		high1 += 1;
	};
	const delta = pow5bits(base2) - pow5bits(i);
	const res0 = u128rshift(low0, sum, delta) + 1 +
		((POW5_INV_OFFSETS[i / 16] >> ((i % 16) << 1)) & 3);
	const res1 = u128rshift(sum, high1, delta);
	return (res0, res1);
};

fn f64computepow5(i: u32) (u64, u64) = {
	const base = i / POW5_TABLE_SIZE, base2 = base * POW5_TABLE_SIZE;
	const mul = F64_POW5_SPLIT2[base];
	const off = i - base2;
	if (off == 0) {
		return (mul[0], mul[1]);
	};
	const m = POW5_TABLE[off];
	const r1 = u128mul(m, mul[1]), r0 = u128mul(m, mul[0]);
	let high1 = r1.hi, low1 = r1.lo, high0 = r0.hi, low0 = r0.lo;
	const sum = high0 + low1;
	if (sum < high0) {
		high1 += 1;
	};
	const delta = pow5bits(i) - pow5bits(base2);
	const res0 = u128rshift(low0, sum, delta) +
		((POW5_OFFSETS[i / 16] >> ((i % 16) << 1)) & 3);
	const res1 = u128rshift(sum, high1, delta);
	return (res0, res1);
};

fn declen(n: u64) u8 = {
	assert(n <= 1e17);
	return if (n >= 1e17) 18
	else if (n >= 1e16) 17
	else if (n >= 1e15) 16
	else if (n >= 1e14) 15
	else if (n >= 1e13) 14
	else if (n >= 1e12) 13
	else if (n >= 1e11) 12
	else if (n >= 1e10) 11
	else if (n >= 1e9) 10
	else if (n >= 1e8) 9
	else if (n >= 1e7) 8
	else if (n >= 1e6) 7
	else if (n >= 1e5) 6
	else if (n >= 1e4) 5
	else if (n >= 1e3) 4
	else if (n >= 100) 3
	else if (n >= 10) 2
	else 1;
};

type decf64 = struct {
	mantissa: u64,
	exponent: i32,
};

fn f64todecf64(mantissa: u64, exponent: u32) decf64 = {
	let e2 = (math::F64_EXPONENT_BIAS + math::F64_MANTISSA_BITS + 2): i32;
	let m2: u64 = 0;
	if (exponent == 0) {
		e2 = 1 - e2;
		m2 = mantissa;
	} else {
		e2 = (exponent: i32) - e2;
		m2 = (1u64 << math::F64_MANTISSA_BITS) | mantissa;
	};
	const accept_bounds = (m2 & 1) == 0;
	const mv = 4 * m2;
	const mm_shift = ibool(mantissa != 0 || exponent <= 1);
	let vp: u64 = 0, vr: u64 = 0, vm: u64 = 0;
	let e10: i32 = 0;
	let vm_trailing_zeros = false, vr_trailing_zeros = false;
	if (e2 >= 0) {
		const q = log10pow2(e2: u32) - ibool(e2 > 3);
		e10 = q: i32;
		const k = F64_POW5_INV_BITCOUNT + pow5bits(q) - 1;
		const i = -e2 + (q + k): i32;
		let pow5 = f64computeinvpow5(q);
		const res = mulshiftall64(m2, pow5, i, mm_shift);
		vp = res.0; vr = res.1; vm = res.2;
		if (q <= 21) {
			if ((mv - 5 * (mv / 5)) == 0) {
				vr_trailing_zeros = pow5multiple(mv, q);
			} else if (accept_bounds) {
				vm_trailing_zeros = pow5multiple(mv - 1 - mm_shift, q);
			} else {
				vp -= ibool(pow5multiple(mv + 2, q));
			};
		};
	} else {
		const q = log10pow5((-e2): u32) - ibool(-e2 > 1);
		e10 = e2 + (q: i32);
		const i = -e2 - (q: i32);
		const k = pow5bits(i: u32): i32 - F64_POW5_BITCOUNT: i32;
		const j = (q: i32) - k;
		let pow5 = f64computepow5(i: u32);
		const res = mulshiftall64(m2, pow5, j, mm_shift);
		vp = res.0; vr = res.1; vm = res.2;
		if (q <= 1) {
			vr_trailing_zeros = true;
			if (accept_bounds) {
				vm_trailing_zeros = mm_shift == 1;
			} else {
				vp -= 1;
			};
		} else if (q < 63) {
			vr_trailing_zeros = pow2multiple(mv, q);
		};
	};
	let removed: i32 = 0, last_removed_digit: u8 = 0;
	let output: u64 = 0;
	if (vm_trailing_zeros || vr_trailing_zeros) {
		for (true) {
			const vpby10 = vp / 10, vmby10 = vm / 10;
			if (vpby10 <= vmby10) break;
			const vmmod10 = (vm: u32) - 10 * (vmby10: u32);
			const vrby10 = vr / 10;
			const vrmod10 = (vr: u32) - 10 * (vrby10: u32);
			vm_trailing_zeros &&= vmmod10 == 0;
			vr_trailing_zeros &&= last_removed_digit == 0;
			last_removed_digit = vrmod10: u8;
			vr = vrby10; vp = vpby10; vm = vmby10;
			removed += 1;
		};
		if (vm_trailing_zeros) {
			for (true) {
				const vmby10 = vm / 10;
				const vmmod10 = (vm: u32) - 10 * (vmby10: u32);
				if (vmmod10 != 0) break;
				const vpby10 = vp / 10, vrby10 = vr / 10;
				const vrmod10 = (vr: u32) - 10 * (vrby10: u32);
				vr_trailing_zeros &&= last_removed_digit == 0;
				last_removed_digit = vrmod10: u8;
				vr = vrby10; vp = vpby10; vm = vmby10;
				removed += 1;
			};
		};
		if (vr_trailing_zeros && last_removed_digit == 5 && (vr & 1 == 0)) {
			// round to even
			last_removed_digit = 4;
		};
		output = vr + ibool((vr == vm &&
			(!accept_bounds || !vm_trailing_zeros)) ||
			last_removed_digit >= 5);
	} else {
		let round_up = false;
		const vpby100 = vp / 100, vmby100 = vm / 100;
		if (vpby100 > vmby100) {
			const vrby100 = vr / 100;
			const vrmod100 = (vr: u32) - 100 * (vrby100: u32);
			round_up = vrmod100 >= 50;
			vr = vrby100; vp = vpby100; vm = vmby100;
			removed += 2;
		};
		for (true) {
			const vmby10 = vm / 10, vpby10 = vp / 10;
			if (vpby10 <= vmby10) break;
			const vrby10 = vr / 10;
			const vrmod10 = (vr: u32) - 10 * (vrby10: u32);
			round_up = vrmod10 >= 5;
			vr = vrby10; vp = vpby10; vm = vmby10;
			removed += 1;
		};
		output = vr + ibool(vr == vm || round_up);
	};
	const exp = e10 + removed;
	return decf64 { exponent = exp, mantissa = output };
};

type decf32 = struct {
	mantissa: u32,
	exponent: i32,
};

fn f32todecf32(mantissa: u32, exponent: u32) decf32 = {
	let e2 = (math::F32_EXPONENT_BIAS + math::F32_MANTISSA_BITS + 2): i32;
	let m2: u32 = 0;
	if (exponent == 0) {
		e2 = 1 - e2;
		m2 = mantissa;
	} else {
		e2 = (exponent: i32) - e2;
		m2 = (1u32 << math::F32_MANTISSA_BITS: u32) | mantissa;
	};
	const accept_bounds = (m2 & 1) == 0;
	const mv = 4 * m2, mp = mv + 2;
	const mm_shift = ibool(mantissa != 0 || exponent <= 1);
	const mm = mv - 1 - mm_shift;
	let vr: u32 = 0, vp: u32 = 0, vm: u32 = 0;
	let e10: i32 = 0;
	let vm_trailing_zeroes = false, vr_trailing_zeroes = false;
	let last_removed_digit: u8 = 0;
	if (e2 >= 0) {
		const q = log10pow2(e2: u32);
		e10 = q: i32;
		const k = F32_POW5_INV_BITCOUNT + pow5bits(q) - 1;
		const i = -e2 + (q + k): i32;
		vr = mulpow5inv_divpow2(mv, q, i);
		vp = mulpow5inv_divpow2(mp, q, i);
		vm = mulpow5inv_divpow2(mm, q, i);
		if (q != 0 && (vp - 1) / 10 <= vm / 10) {
			const l = F32_POW5_INV_BITCOUNT + pow5bits(q - 1) - 1;
			last_removed_digit = (mulpow5inv_divpow2(mv, q - 1,
				-e2 + ((q + l): i32) - 1) % 10): u8;
		};
		if (q <= 9) {
			if (mv % 5 == 0) {
				vr_trailing_zeroes = pow5multiple32(mv, q);
			} else if (accept_bounds) {
				vm_trailing_zeroes = pow5multiple32(mm, q);
			} else {
				vp -= ibool(pow5multiple32(mp, q));
			};
		};
	} else {
		const q = log10pow5((-e2): u32);
		e10 = (q: i32) + e2;
		const i = (-e2 - (q: i32)): u32;
		const k = pow5bits(i) - F32_POW5_BITCOUNT;
		let j = (q: i32) - k: i32;
		vr = mulpow5_divpow2(mv, i, j);
		vp = mulpow5_divpow2(mp, i, j);
		vm = mulpow5_divpow2(mm, i, j);
		if (q != 0 && (vp - 1) / 10 <= vm / 10) {
			j = (q: i32) - 1 - (pow5bits(i + 1): i32 -
				F32_POW5_BITCOUNT: i32);
			last_removed_digit = (mulpow5_divpow2(mv,
				(i + 1), j) % 10): u8;
		};
		if (q <= 1) {
			vr_trailing_zeroes = true;
			if (accept_bounds) {
				vm_trailing_zeroes = mm_shift == 1;
			} else {
				vp -= 1;
			};
		} else if (q < 31) {
			vr_trailing_zeroes = pow2multiple32(mv, q - 1);
		};
	};
	let removed: i32 = 0, output: u32 = 0;
	if (vm_trailing_zeroes || vr_trailing_zeroes) {
		for (vp / 10 > vm / 10) {
			vm_trailing_zeroes &&= (vm - (vm / 10) * 10) == 0;
			vr_trailing_zeroes &&= last_removed_digit == 0;
			last_removed_digit = (vr % 10): u8;
			vr /= 10;
			vp /= 10;
			vm /= 10;
			removed += 1;
		};
		if (vm_trailing_zeroes) {
			for (vm % 10 == 0) {
				vr_trailing_zeroes &&= last_removed_digit == 0;
				last_removed_digit = (vr % 10): u8;
				vr /= 10;
				vp /= 10;
				vm /= 10;
				removed += 1;
			};
		};
		if (vr_trailing_zeroes && last_removed_digit == 5 && vr % 2 == 0) {
			// round to even
			last_removed_digit = 4;
		};
		output = vr + ibool((vr == vm &&
			(!accept_bounds || !vm_trailing_zeroes)) ||
			last_removed_digit >= 5);
	} else {
		for (vp / 10 > vm / 10) {
			last_removed_digit = (vr % 10): u8;
			vr /= 10;
			vp /= 10;
			vm /= 10;
			removed += 1;
		};
		output = vr + ibool(vr == vm || last_removed_digit >= 5);
	};
	const exp = e10 + removed;
	return decf32 { mantissa = output, exponent = exp };
};

def F32_DECIMAL_DIGITS: i32 = 9;
def F64_DECIMAL_DIGITS: i32 = 17;

fn encode_base10(buf: []u8, mantissa: u64, exponent: i32, digits: i32) size = {
	const zch = '0': u8;
	const n = mantissa, e = exponent, olen = declen(n);
	const exp = e + olen: i32 - 1;
	// use scientific notation for numbers whose exponent is beyond the
	// precision available for the underlying type
	if (exp > -4 && exp < digits) {
		if (e >= 0) {
			let k = exp;
			for (let a = e; a > 0; a -= 1) {
				buf[k] = zch;
				k -= 1;
			};
			let m = n;
			for (k >= 0; k -= 1) {
				const mby10 = m / 10;
				const mmod10 = (m: u32) - 10 * (mby10: u32);
				buf[k] = zch + mmod10: u8;
				m = mby10;
			};
			return (e + olen: i32): size;
		} else if (exp < 0) {
			buf[0] = zch;
			buf[1] = '.';
			let k = -e + 1;
			let m = n;
			for (let a = olen: i32; a > 0; a -= 1) {
				const mby10 = m / 10;
				const mmod10 = (m: u32) - 10 * (mby10: u32);
				buf[k] = zch + mmod10: u8;
				k -= 1;
				m = mby10;
			};
			for (k > 1; k -= 1) {
				buf[k] = zch;
			};
			return (-e + 2): size;
		} else {
			let k = olen: i32;
			let m = n;
			for (let a = -e; a > 0; a -= 1) {
				const mby10 = m / 10;
				const mmod10 = (m: u32) - 10 * (mby10: u32);
				buf[k] = zch + mmod10: u8;
				k -= 1;
				m = mby10;
			};
			buf[k] = '.';
			k -= 1;
			for (k >= 0; k -= 1) {
				const mby10 = m / 10;
				const mmod10 = (m: u32) - 10 * (mby10: u32);
				buf[k] = zch + mmod10: u8;
				m = mby10;
			};
			return (olen + 1): size;
		};
	} else {
		let h: i32 = 0;
		let m = n;
		if (olen == 1) {
			buf[0] = zch + m: u8;
			h = 1;
		} else {
			let k = olen: i32;
			for (let a = k; a > 1; a -= 1) {
				const mby10 = m / 10;
				const mmod10 = (m: u32) - 10 * (mby10: u32);
				buf[k] = zch + mmod10: u8;
				k -= 1;
				m = mby10;
			};
			buf[k] = '.';
			buf[0] = zch + m: u8;
			h = olen: i32 + 1;
		};
		buf[h] = 'e';
		h += 1;
		let ex = if (exp < 0) {
			buf[h] = '-';
			h += 1;
			yield -exp;
		} else exp;
		const elen = declen(ex: u64);
		let k = h + elen: i32 - 1;
		for (let a = elen: i32; a > 0; a -= 1) {
			const eby10 = ex / 10;
			const emod10 = (ex: u32) - 10 * (eby10: u32);
			buf[k] = zch + emod10: u8;
			k -= 1;
			ex = eby10;
		};
		h += elen: i32;
		return h: size;
	};
};

// Converts a f64 to a string in base 10. The return value is statically
// allocated and will be overwritten on subsequent calls; see [[strings::dup]]
// to duplicate the result.
export fn f64tos(n: f64) const str = {
	// The biggest string produced by a f64 number in base 10 would have the
	// negative sign, followed by a digit and decimal point, and then
	// sixteen more decimal digits, followed by 'e' and another negative
	// sign and the maximum of three digits for exponent.
	// (1 + 1 + 1 + 16 + 1 + 1 + 3) = 24
	static let buf: [24]u8 = [0...];
	const bits = math::f64bits(n);
	const sign = (bits >> (math::F64_MANTISSA_BITS +
	math::F64_EXPONENT_BITS)): size; // bits >> 63
	const mantissa = bits & ((1u64 << math::F64_MANTISSA_BITS) - 1);
	const exponent = ((bits >> math::F64_MANTISSA_BITS) &
			(1u64 << math::F64_EXPONENT_BITS) - 1): u32;
	if (mantissa == 0 && exponent == 0) {
		return "0";
	} else if (exponent == ((1 << math::F64_EXPONENT_BITS) - 1)) {
		if (mantissa != 0) {
			return "NaN";
		};
		return if (sign == 0) "Infinity" else "-Infinity";
	};
	const d = f64todecf64(mantissa, exponent);
	if (sign != 0) {
		buf[0] = '-';
	};
	let z = encode_base10(buf[sign..], d.mantissa, d.exponent,
			F64_DECIMAL_DIGITS) + sign;
	let s = types::string { data = &buf, length = z, ... };
	return *(&s: *str);
};

// Converts a f32 to a string in base 10. The return value is statically
// allocated and will be overwritten on subsequent calls; see [[strings::dup]]
// to duplicate the result.
export fn f32tos(n: f32) const str = {
	// The biggest string produced by a f32 number in base 10 would have the
	// negative sign, followed by a digit and decimal point, and then seven
	// more decimal digits, followed by 'e' and another negative sign and
	// the maximum of two digits for exponent.
	// (1 + 1 + 1 + 7 + 1 + 1 + 2) = 14
	static let buf: [16]u8 = [0...];
	const bits = math::f32bits(n);
	const sign = (bits >> (math::F32_MANTISSA_BITS +
	math::F32_EXPONENT_BITS)): size; // bits >> 31
	const mantissa = bits & ((1u32 << math::F32_MANTISSA_BITS) - 1): u32;
	const exponent = (bits >> math::F32_MANTISSA_BITS): u32 &
		((1u32 << math::F32_EXPONENT_BITS) - 1): u32;
	if (mantissa == 0 && exponent == 0) {
		return "0";
	} else if (exponent == ((1 << math::F32_EXPONENT_BITS) - 1): u32) {
		if (mantissa != 0) {
			return "NaN";
		};
		return if (sign == 0) "Infinity" else "-Infinity";
	};
	const d = f32todecf32(mantissa, exponent);
	if (sign != 0) {
		buf[0] = '-';
	};
	let z = encode_base10(buf[sign..], d.mantissa, d.exponent,
			F32_DECIMAL_DIGITS) + sign;
	const s = types::string { data = &buf, length = z, ... };
	return *(&s: *str);
};

@test fn f64tos() void = {
	assert(f64tos(0.0) == "0");
	assert(f64tos(1.0 / 0.0) == "Infinity");
	assert(f64tos(-1.0 / 0.0) == "-Infinity");
	assert(f64tos(0.0 / 0.0) == "NaN");
	assert(f64tos(1.0) == "1");
	assert(f64tos(0.3) == "0.3");
	assert(f64tos(0.0031415) == "0.0031415");
	assert(f64tos(0.0000012345678) == "1.2345678e-6");
	assert(f64tos(1.414) == "1.414");
	assert(f64tos(1e234f64) == "1e234");
	assert(f64tos(1.2e-34) == "1.2e-34");
	assert(f64tos(-6345.9721) == "-6345.9721");
	assert(f64tos(1.23456789e67) == "1.23456789e67");
	assert(f64tos(11.2233445566778899e20) == "1.122334455667789e21");
	assert(f64tos(1000000.0e9) == "1000000000000000");
	assert(f64tos(9007199254740991.0) == "9007199254740991");
	assert(f64tos(90071992547409915.0) == "90071992547409920");
	assert(f64tos(90071992547409925.0) == "90071992547409920");
	assert(f64tos(5.0e-324) == "5e-324");
	assert(f64tos(2.2250738585072014e-308) == "2.2250738585072014e-308");
	assert(f64tos(1.7976931348623157e308) == "1.7976931348623157e308");
};

@test fn f32tos() void = {
	assert(f32tos(0.0) == "0");
	assert(f32tos(1.0 / 0.0) == "Infinity");
	assert(f32tos(-1.0 / 0.0) == "-Infinity");
	assert(f32tos(0.0 / 0.0) == "NaN");
	assert(f32tos(1.0) == "1");
	assert(f32tos(-8.0) == "-8");
	assert(f32tos(1.23) == "1.23");
	assert(f32tos(-0.618) == "-0.618");
	assert(f32tos(0.00456) == "0.00456");
	assert(f32tos(0.00000000000434655) == "4.34655e-12");
	assert(f32tos(123456.78) == "123456.78");
	assert(f32tos(-1.234567) == "-1.234567");
	assert(f32tos(12345.6789) == "12345.679");
	assert(f32tos(1.23e30) == "1.23e30");
	assert(f32tos(1.23e-30) == "1.23e-30");
	assert(f32tos(16777215.0) == "16777215");
	assert(f32tos(167772155.0) == "167772160");
	assert(f32tos(167772145.0) == "167772140");
	assert(f32tos(1.0e-45) == "1e-45");
	assert(f32tos(1.1754944e-38) == "1.1754944e-38");
	assert(f32tos(3.4028235e+38) == "3.4028235e38");
};

