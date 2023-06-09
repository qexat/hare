// License: MPL-2.0
// (c) 2021-2022 Alexey Yerin <yyp@disroot.org>
// (c) 2021 Drew DeVault <sir@cmpwn.com>
// (c) 2021 Ember Sawady <ecs@d2evs.net>
// (c) 2022 Sebastian <sebastian@sebsite.pw>
use io;
use fmt;
use hare::ast;
use hare::lex;
use strings;
use strio;

// Unparses a [[hare::ast::decl]].
export fn decl(out: io::handle, d: ast::decl) (size | io::error) = {
	let n = 0z;
	if (len(d.docs) > 0) {
		n += comment(out, d.docs, 0)?;
	};
	if (d.exported) {
		n += fmt::fprint(out, "export ")?;
	};
	match (d.decl) {
	case let c: []ast::decl_const =>
		n += fmt::fprint(out, "def ")?;
		for (let i = 0z; i < len(c); i += 1) {
			n += ident(out, c[i].ident)?;
			match (c[i]._type) {
			case null =>
				yield;
			case let ty: *ast::_type =>
				n += fmt::fprint(out, ": ")?;
				n += _type(out, 0, *ty)?;
			};
			n += fmt::fprint(out, " = ")?;
			n += expr(out, 0, *c[i].init)?;
			if (i + 1 < len(c)) {
				n += fmt::fprint(out, ", ")?;
			};
		};
	case let g: []ast::decl_global =>
		n += fmt::fprint(out,
			if (g[0].is_const) "const " else "let ")?;
		for (let i = 0z; i < len(g); i += 1) {
			if (len(g[i].symbol) != 0) {
				n += fmt::fprintf(out,
					"@symbol(\"{}\") ", g[i].symbol)?;
			} else if (g[i].is_threadlocal) {
				n += fmt::fprintf(out, "@threadlocal ")?;
			};
			n += ident(out, g[i].ident)?;
			match (g[i]._type) {
			case null =>
				yield;
			case let ty: *ast::_type =>
				n += fmt::fprint(out, ": ")?;
				n += _type(out, 0, *ty)?;
			};
			match (g[i].init) {
			case null => void;
			case let ex: *ast::expr =>
				n += fmt::fprint(out, " = ")?;
				n += expr(out, 0, *ex)?;
			};
			if (i + 1 < len(g)) {
				n += fmt::fprint(out, ", ")?;
			};
		};
	case let t: []ast::decl_type =>
		n += fmt::fprint(out, "type ")?;
		for (let i = 0z; i < len(t); i += 1) {
			n += ident(out, t[i].ident)?;
			n += fmt::fprint(out, " = ")?;
			n += _type(out, 0, t[i]._type)?;
			if (i + 1 < len(t)) {
				n += fmt::fprint(out, ", ")?;
			};
		};
	case let f: ast::decl_func =>
		n += fmt::fprint(out, switch (f.attrs) {
		case ast::fndecl_attrs::NONE =>
			yield "";
		case ast::fndecl_attrs::FINI =>
			yield "@fini ";
		case ast::fndecl_attrs::INIT =>
			yield "@init ";
		case ast::fndecl_attrs::TEST =>
			yield "@test ";
		})?;
		let p = f.prototype.repr as ast::func_type;
		if (p.attrs & ast::func_attrs::NORETURN != 0) {
			n += fmt::fprint(out, "@noreturn ")?;
		};
		if (len(f.symbol) != 0) {
			n += fmt::fprintf(out, "@symbol(\"{}\") ",
				f.symbol)?;
		};
		n += fmt::fprint(out, "fn ")?;
		n += ident(out, f.ident)?;
		const fntype = f.prototype.repr as ast::func_type;
		n += prototype(out, 0, fntype)?;
		match (f.body) {
		case void => void;
		case let e: ast::expr =>
			n += fmt::fprint(out, " = ")?;
			n += expr(out, 0, e)?;
		};
	};
	n += fmt::fprint(out, ";")?;
	return n;
};

fn comment(out: io::handle, s: str, indent: size) (size | io::error) = {
	let n = 0z;
	const lines = strings::split(s, "\n");
	defer free(lines);
	assert(len(lines) > 0);
	for (let i = 0z; i < len(lines) - 1; i += 1) {
		for (let j = 0z; j < indent; j += 1) {
			n += fmt::fprint(out, "\t")?;
		};
		n += fmt::fprintfln(out, "//{}", lines[i])?;
	};
	return n;
};

fn decl_test(d: ast::decl, expected: str) bool = {
	let buf = strio::dynamic();
	decl(&buf, d) as size;
	let s = strio::string(&buf);
	defer free(s);
	return s == expected;
};

@test fn decl() void = {
	let loc = lex::location {
		path = "<test>",
		line = 0,
		col = 0,
	};
	let type_int = ast::_type {
		start = loc,
		end = loc,
		flags = 0,
		repr = ast::builtin_type::INT,
	};
	let type_fn = ast::_type {
		start = loc,
		end = loc,
		flags = ast::type_flag::CONST,
		repr = ast::func_type {
			result = &type_int,
			attrs = ast::func_attrs::NORETURN,
			variadism = ast::variadism::HARE,
			params = [
				ast::func_param {
					loc = loc,
					name = "foo",
					_type = &type_int,
				},
				ast::func_param {
					loc = loc,
					name = "bar",
					_type = &type_int,
				},
			],
		},
	};
	let expr_void = ast::expr {
		start = lex::location { ... },
		end = lex::location { ... },
		expr = void,
	};

	let d = ast::decl {
		exported = false,
		start = loc,
		end = loc,
		decl = [
			ast::decl_global {
				is_const = false,
				is_threadlocal = false,
				symbol = "",
				ident = ["foo", "bar"],
				_type = &type_int,
				init = alloc(expr_void),
			},
			ast::decl_global {
				is_const = false,
				is_threadlocal = true,
				symbol = "",
				ident = ["boo"],
				_type = &type_int,
				init = alloc(expr_void),
			},
			ast::decl_global {
				is_const = false,
				is_threadlocal = false,
				symbol = "foobar",
				ident = ["baz"],
				_type = &type_int,
				init = alloc(expr_void),
			},
		],
		...
	};
	assert(decl_test(d, "let foo::bar: int = void, @threadlocal boo: int = void, @symbol(\"foobar\") baz: int = void;"));

	d.exported = true;
	d.decl = [
		ast::decl_const {
			ident = ["foo"],
			_type = &type_int,
			init = alloc(expr_void),
		},
	];
	assert(decl_test(d, "export def foo: int = void;"));

	d.exported = false;
	d.decl = [
		ast::decl_type {
			ident = ["foo"],
			_type = type_int,
		},
		ast::decl_type {
			ident = ["bar"],
			_type = type_int,
		},
	];
	assert(decl_test(d, "type foo = int, bar = int;"));

	d.decl = ast::decl_func {
		symbol = "foo",
		ident = ["foo"],
		prototype = type_fn,
		body = void,
		attrs = ast::fndecl_attrs::FINI,
	};
	assert(decl_test(d, "@fini @noreturn @symbol(\"foo\") fn foo(foo: int, bar: int...) int;"));

	type_fn.repr = ast::func_type {
		result = &type_int,
		attrs = 0,
		variadism = ast::variadism::NONE,
		params = [
			ast::func_param {
				loc = loc,
				name = "",
				_type = &type_int,
			},
		],
	};
	d.decl = ast::decl_func {
		symbol = "",
		ident = ["foo"],
		prototype = type_fn,
		body = expr_void,
		attrs = 0,
	};
	assert(decl_test(d, "fn foo(int) int = void;"));
};
