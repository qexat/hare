// License: MPL-2.0
// (c) 2021 Drew DeVault <sir@cmpwn.com>

@symbol(".main") fn main() void;
@symbol("exit") fn c_exit(status: int) void;

const @symbol("__libc_init_array_start") init_start: [*]*fn() void;
const @symbol("__libc_init_array_end") init_end: [*]*fn() void;
const @symbol("__fini_array_start") fini_start: [*]*fn() void;
const @symbol("__fini_array_end") fini_end: [*]*fn() void;

// Run all global initialization functions.
export fn init() void = {
	const ninit = (&init_end: uintptr - &init_start: uintptr): size
		/ size(*fn() void);
	for (let i = 0z; i < ninit; i += 1) {
		init_start[i]();
	};
};

// Run all global finalization functions.
export fn fini() void = {
	const nfini = (&fini_end: uintptr - &fini_start: uintptr): size
		/ size(*fn() void);
	for (let i = 0z; i < nfini; i += 1) {
		fini_start[i]();
	};
};

export @symbol("main") @noreturn fn start_ha(c_argc: int, c_argv: *[*]*u8) void = {
	argc = c_argc: size;
	argv = c_argv;
	envp = c_envp;
	// we deliberately prevent libc from running @init for us, in order to
	// be able to initialize argc/argv/envp beforehand. we can still get
	// away with just using libc for @fini though
	init();
	main();
	c_exit(0);
};

let @symbol("environ") c_envp: *[*]nullable *u8;
