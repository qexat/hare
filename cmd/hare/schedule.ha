// License: GPL-3.0
// (c) 2021-2022 Alexey Yerin <yyp@disroot.org>
// (c) 2021-2022 Drew DeVault <sir@cmpwn.com>
// (c) 2021 Ember Sawady <ecs@d2evs.net>
// (c) 2021 Thomas Bracht Laumann Jespersen <t@laumann.xyz>
// (c) 2022 Jon Eskin <eskinjp@gmail.com>
use encoding::hex;
use fmt;
use fs;
use hare::ast;
use hare::module;
use hare::unparse;
use hash::fnv;
use hash;
use os;
use path;
use shlex;
use strings;
use strio;

fn getenv(var: str) []str = {
	match (os::getenv(var)) {
	case let val: str =>
		match (shlex::split(val)) {
		case let fields: []str =>
			return fields;
		case => void;
		};
	case => void;
	};

	return [];
};

// (executable name, executable variable, flags variable)
type tool = (str, str, str);

let ld_tool: tool = ("", "LD", "LDLINKFLAGS");
let as_tool: tool = ("", "AS", "ASFLAGS");
let ar_tool: tool = ("", "AR", "ARFLAGS");
let qbe_tool: tool = ("qbe", "QBE", "QBEFLAGS");

fn getcmd(tool: *tool, args: str...) []str = {
	let execargs: []str = [];

	let vals = getenv(tool.1);
	defer free(vals);
	if (len(vals) == 0) {
		append(execargs, tool.0);
	} else {
		append(execargs, vals...);
	};

	let vals = getenv(tool.2);
	defer free(vals);
	append(execargs, vals...);

	append(execargs, args...);

	return execargs;
};

fn ident_hash(ident: ast::ident) u32 = {
	let hash = fnv::fnv32();
	for (let i = 0z; i < len(ident); i += 1) {
		hash::write(&hash, strings::toutf8(ident[i]));
		hash::write(&hash, [0]);
	};
	return fnv::sum32(&hash);
};

fn sched_module(plan: *plan, ident: ast::ident, link: *[]*task) *task = {
	let hash = ident_hash(ident);
	let bucket = &plan.modmap[hash % len(plan.modmap)];
	for (let i = 0z; i < len(bucket); i += 1) {
		if (bucket[i].hash == hash
				&& ast::ident_eq(bucket[i].ident, ident)) {
			return bucket[i].task;
		};
	};

	let ver = match (module::lookup(plan.context, ident)) {
	case let err: module::error =>
		let ident = unparse::identstr(ident);
		progress_clear(plan);
		fmt::fatalf("Error resolving {}: {}", ident,
			module::strerror(err));
	case let ver: module::version =>
		yield ver;
	};

	let depends: []*task = [];
	defer free(depends);
	for (let i = 0z; i < len(ver.depends); i += 1) {
		const dep = ver.depends[i];
		let obj = sched_module(plan, dep, link);
		append(depends, obj);
	};

	let obj = sched_hare_object(plan, ver, ident, void, depends...);
	append(bucket, modcache {
		hash = hash,
		task = obj,
		ident = ident,
		version = ver,
	});
	append(link, obj);
	return obj;
};

// Schedules a task which compiles objects into an executable.
fn sched_ld(plan: *plan, output: str, depend: *task...) *task = {
	let task = alloc(task {
		status = status::SCHEDULED,
		output = output,
		depend = alloc(depend...),
		cmd = getcmd(&ld_tool,
			"-T", plan.script,
			"-o", output),
		module = void,
	});

	if (len(plan.libdir) != 0) {
		for (let i = 0z; i < len(plan.libdir); i += 1) {
			append(task.cmd, strings::concat("-L", plan.libdir[i]));
		};
	};

	// Using --gc-sections will not work when using cc as the linker
	if (len(plan.libs) == 0 && task.cmd[0] == plan.target.ld_cmd) {
		append(task.cmd, "--gc-sections");
	};

	let archives: []str = [];
	defer free(archives);

	for (let i = 0z; i < len(depend); i += 1) {
		if (strings::hassuffix(depend[i].output, ".a")) {
			append(archives, depend[i].output);
		} else {
			append(task.cmd, depend[i].output);
		};
	};
	append(task.cmd, archives...);
	for (let i = 0z; i < len(plan.libs); i += 1) {
		append(task.cmd, strings::concat("-l", plan.libs[i]));
	};
	append(plan.scheduled, task);
	return task;
};

// Schedules a task which merges objects into an archive.
fn sched_ar(plan: *plan, output: str, depend: *task...) *task = {
	let task = alloc(task {
		status = status::SCHEDULED,
		output = output,
		depend = alloc(depend...),
		cmd = getcmd(&ar_tool, "-c", output),
		module = void,
	});

	// POSIX specifies `ar -r [-cuv] <archive> <file>`
	// Add -r here so it is always before any ARFLAGS
	insert(task.cmd[1], "-r");

	for (let i = 0z; i < len(depend); i += 1) {
		assert(strings::hassuffix(depend[i].output, ".o"));
		append(task.cmd, depend[i].output);
	};
	append(plan.scheduled, task);
	return task;
};

// Schedules a task which compiles assembly into an object.
fn sched_as(plan: *plan, output: str, input: str, depend: *task...) *task = {
	let task = alloc(task {
		status = status::SCHEDULED,
		output = output,
		depend = alloc(depend...),
		cmd = getcmd(&as_tool, "-g", "-o", output),
		module = void,
	});

	append(task.cmd, input);

	append(plan.scheduled, task);
	return task;
};

// Schedules a task which compiles an SSA file into assembly.
fn sched_qbe(plan: *plan, output: str, depend: *task) *task = {
	let task = alloc(task {
		status = status::SCHEDULED,
		output = output,
		depend = alloc([depend]),
		cmd = getcmd(&qbe_tool,
			"-t", plan.target.qbe_target,
			"-o", output,
			depend.output),
		module = void,
	});
	append(plan.scheduled, task);
	return task;
};

// Schedules tasks which compiles a Hare module into an object or archive.
fn sched_hare_object(
	plan: *plan,
	ver: module::version,
	namespace: ast::ident,
	output: (void | str),
	depend: *task...
) *task = {
	// XXX: Do we care to support assembly-only modules?
	let mixed = false;
	for (let i = 0z; i < len(ver.inputs); i += 1) {
		if (strings::hassuffix(ver.inputs[i].path, ".s")) {
			mixed = true;
			break;
		};
	};

	const ns = unparse::identstr(namespace);
	const displayed_ns = if (len(ns) == 0) "(root)" else ns;
	if (len(ns) > plan.progress.maxwidth)
		plan.progress.maxwidth = len(ns);

	let ssa = mkfile(plan, ns, "ssa");
	let harec = alloc(task {
		status = status::SCHEDULED,
		output = ssa,
		depend = alloc(depend...),
		cmd = alloc([
			os::tryenv("HAREC", "harec"), "-o", ssa,
		]),
		module = strings::dup(ns),
	});

	let libc = false;
	for (let i = 0z; i < len(plan.context.tags); i += 1) {
		if (plan.context.tags[i].mode == module::tag_mode::INCLUSIVE
				&& plan.context.tags[i].name == "test") {
			const opaths = plan.context.paths;
			plan.context.paths = ["."];
			const ver = module::lookup(plan.context, namespace);
			if (ver is module::version) {
				append(harec.cmd, "-T");
			};
			plan.context.paths = opaths;
		} else if (plan.context.tags[i].mode == module::tag_mode::INCLUSIVE
				&& plan.context.tags[i].name == "libc") {
			libc = true;
		};
	};

	if (len(ns) != 0 || libc) {
		append(harec.cmd, ["-N", ns]...);
	};

	let current = false;
	let output = if (output is str) {
		static let buf = path::buffer{...};
		path::set(&buf, output as str)!;
		// TODO: Should we use the cache here?
		const ext = match (path::peek_ext(&buf)) {
		case let s: str => yield s;
		case void => yield "";
		};
		const expected = if (mixed) "a" else "o";
		if (ext != expected) {
			fmt::errorfln("Warning: Expected output file extension {}, found {}",
				expected, output)!;
		};
		yield strings::dup(output as str);
	} else if (len(namespace) != 0) {
		let buf = path::init(plan.context.cache)!;
		path::push(&buf, namespace...)!;
		const path = path::string(&buf);
		match (os::mkdirs(path, 0o755)) {
		case void => void;
		case let err: fs::error =>
			progress_clear(plan);
			fmt::fatalf("Error: mkdirs {}: {}", path,
				fs::strerror(err));
		};

		let version = hex::encodestr(ver.hash);
		let td = fmt::asprintf("{}.td", version);
		defer free(td);
		let name = fmt::asprintf("{}.{}", version,
			if (mixed) "a" else "o");
		defer free(name);
		path::push(&buf, td)!;

		append(plan.environ, (
			fmt::asprintf("HARE_TD_{}", ns),
			strings::dup(path::string(&buf)),
		));

		// TODO: Keep this around and append new versions, rather than
		// overwriting with just the latest
		let manifest = match (module::manifest_load(
				plan.context, namespace)) {
		case let err: module::error =>
			progress_clear(plan);
			fmt::fatalf("Error reading cache entry for {}: {}",
				displayed_ns, module::strerror(err));
		case let m: module::manifest =>
			yield m;
		};
		defer module::manifest_finish(&manifest);
		current = module::current(&manifest, &ver);

		append(harec.cmd, ["-t", strings::dup(path::string(&buf))]...);
		yield strings::dup(path::push(&buf, "..", name)!);
	} else {
		// XXX: This is probably kind of dumb
		// It would be better to apply any defines which affect this
		// namespace instead
		for (let i = 0z; i < len(plan.context.defines); i += 1) {
			append(harec.cmd, ["-D", plan.context.defines[i]]...);
		};

		yield mkfile(plan, ns, "o"); // TODO: Should exes go in the cache?
	};

	let hare_inputs = 0z;
	for (let i = 0z; i < len(ver.inputs); i += 1) {
		let path = ver.inputs[i].path;
		if (strings::hassuffix(path, ".ha")) {
			append(harec.cmd, path);
			hare_inputs += 1;
		};
	};
	if (hare_inputs == 0) {
		progress_clear(plan);
		fmt::fatalf("Error: Module {} has no Hare input files",
			displayed_ns);
	};

	if (current) {
		harec.status = status::COMPLETE;
		harec.output = output;
		append(plan.complete, harec);
		return harec;
	} else {
		append(plan.scheduled, harec);
	};

	let s = mkfile(plan, ns, "s");
	let qbe = sched_qbe(plan, s, harec);
	let hare_obj = sched_as(plan,
		if (mixed) mkfile(plan, ns, "o") else output,
		s, qbe);
	if (!mixed) {
		return hare_obj;
	};

	let objs: []*task = alloc([hare_obj]);
	defer free(objs);
	for (let i = 0z; i < len(ver.inputs); i += 1) {
		// XXX: All of our assembly files don't depend on anything else,
		// but that may not be generally true. We may have to address
		// this at some point.
		let path = ver.inputs[i].path;
		if (!strings::hassuffix(path, ".s")) {
			continue;
		};
		append(objs, sched_as(plan, mkfile(plan, ns, "o"), path));
	};
	return sched_ar(plan, output, objs...);
};

// Schedules tasks which compiles hare sources into an executable.
fn sched_hare_exe(
	plan: *plan,
	ver: module::version,
	output: str,
	depend: *task...
) *task = {
	let obj = sched_hare_object(plan, ver, [], void, depend...);
	// TODO: We should be able to use partial variadic application
	let link: []*task = alloc([], len(depend));
	defer free(link);
	append(link, obj);
	append(link, depend...);
	return sched_ld(plan, strings::dup(output), link...);
};
