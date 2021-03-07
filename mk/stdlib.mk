# This file is generated by the gen-stdlib script, do not edit it by hand

# rt
rtscript=$(STDLIB)/rt/hare.sc
stdlib_rt_srcs= \
	$(STDLIB)/rt/$(PLATFORM)/env.ha \
	$(STDLIB)/rt/$(PLATFORM)/errno.ha \
	$(STDLIB)/rt/$(PLATFORM)/segmalloc.ha \
	$(STDLIB)/rt/$(PLATFORM)/start.ha \
	$(STDLIB)/rt/$(PLATFORM)/stat.ha \
	$(STDLIB)/rt/$(PLATFORM)/$(ARCH).ha \
	$(STDLIB)/rt/$(PLATFORM)/syscallno$(ARCH).ha \
	$(STDLIB)/rt/$(PLATFORM)/syscalls.ha \
	$(STDLIB)/rt/$(PLATFORM)/types.ha \
	$(STDLIB)/rt/$(ARCH)/jmp.ha \
	$(STDLIB)/rt/ensure.ha \
	$(STDLIB)/rt/jmp.ha \
	$(STDLIB)/rt/malloc.ha \
	$(STDLIB)/rt/memcpy.ha \
	$(STDLIB)/rt/memset.ha \
	$(STDLIB)/rt/strcmp.ha \
	$(STDLIB)/rt/$(PLATFORM)/abort.ha \
	$(STDLIB)/rt/start.ha

$(HARECACHE)/rt/rt.ssa: $(stdlib_rt_srcs) $(stdlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/rt
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nrt \
		-t$(HARECACHE)/rt/rt.td $(stdlib_rt_srcs)

$(HARECACHE)/rt/start.o: $(STDLIB)/rt/$(PLATFORM)/start$(ARCH).s
	@printf 'AS \t$@\n'
	@mkdir -p $(HARECACHE)/rt
	@$(AS) -o $@ $<

stdlib_asm=$(HARECACHE)/rt/syscall.o \
	$(HARECACHE)/rt/setjmp.o \
	$(HARECACHE)/rt/longjmp.o

$(HARECACHE)/rt/syscall.o: $(STDLIB)/rt/$(PLATFORM)/syscall$(ARCH).s
	@printf 'AS \t$@\n'
	@mkdir -p $(HARECACHE)/rt
	@$(AS) -o $@ $<

$(HARECACHE)/rt/setjmp.o: $(STDLIB)/rt/$(ARCH)/setjmp.s
	@printf 'AS \t$@\n'
	@mkdir -p $(HARECACHE)/rt
	@$(AS) -o $@ $<

$(HARECACHE)/rt/longjmp.o: $(STDLIB)/rt/$(ARCH)/longjmp.s
	@printf 'AS \t$@\n'
	@mkdir -p $(HARECACHE)/rt
	@$(AS) -o $@ $<

$(HARECACHE)/rt/rt.a: $(HARECACHE)/rt/rt.o $(stdlib_asm)
	@printf 'AR\t$@\n'
	@$(AR) -csr $@ $(HARECACHE)/rt/rt.o $(stdlib_asm)

stdlib_rt=$(HARECACHE)/rt/rt.a
stdlib_start=$(HARECACHE)/rt/start.o
hare_stdlib_deps+=$(stdlib_rt)

stdlib_ascii=$(HARECACHE)/ascii/ascii.o
hare_stdlib_deps+=$(stdlib_ascii)

stdlib_bufio=$(HARECACHE)/bufio/bufio.o
hare_stdlib_deps+=$(stdlib_bufio)

stdlib_bytes=$(HARECACHE)/bytes/bytes.o
hare_stdlib_deps+=$(stdlib_bytes)

stdlib_crypto_math=$(HARECACHE)/crypto/math/crypto.math.o
hare_stdlib_deps+=$(stdlib_crypto_math)

stdlib_crypto_random=$(HARECACHE)/crypto/random/crypto.random.o
hare_stdlib_deps+=$(stdlib_crypto_random)

stdlib_crypto_sha256=$(HARECACHE)/crypto/sha256/crypto.sha256.o
hare_stdlib_deps+=$(stdlib_crypto_sha256)

stdlib_dirs=$(HARECACHE)/dirs/dirs.o
hare_stdlib_deps+=$(stdlib_dirs)

stdlib_encoding_hex=$(HARECACHE)/encoding/hex/encoding.hex.o
hare_stdlib_deps+=$(stdlib_encoding_hex)

stdlib_encoding_utf8=$(HARECACHE)/encoding/utf8/encoding.utf8.o
hare_stdlib_deps+=$(stdlib_encoding_utf8)

stdlib_endian=$(HARECACHE)/endian/endian.o
hare_stdlib_deps+=$(stdlib_endian)

stdlib_fmt=$(HARECACHE)/fmt/fmt.o
hare_stdlib_deps+=$(stdlib_fmt)

stdlib_format_elf=$(HARECACHE)/format/elf/format.elf.o
hare_stdlib_deps+=$(stdlib_format_elf)

stdlib_fs=$(HARECACHE)/fs/fs.o
hare_stdlib_deps+=$(stdlib_fs)

stdlib_hare_ast=$(HARECACHE)/hare/ast/hare.ast.o
hare_stdlib_deps+=$(stdlib_hare_ast)

stdlib_hare_lex=$(HARECACHE)/hare/lex/hare.lex.o
hare_stdlib_deps+=$(stdlib_hare_lex)

stdlib_hare_module=$(HARECACHE)/hare/module/hare.module.o
hare_stdlib_deps+=$(stdlib_hare_module)

stdlib_hare_parse=$(HARECACHE)/hare/parse/hare.parse.o
hare_stdlib_deps+=$(stdlib_hare_parse)

stdlib_hash=$(HARECACHE)/hash/hash.o
hare_stdlib_deps+=$(stdlib_hash)

stdlib_hash_fnv=$(HARECACHE)/hash/fnv/hash.fnv.o
hare_stdlib_deps+=$(stdlib_hash_fnv)

stdlib_io=$(HARECACHE)/io/io.o
hare_stdlib_deps+=$(stdlib_io)

stdlib_os=$(HARECACHE)/os/os.o
hare_stdlib_deps+=$(stdlib_os)

stdlib_os_exec=$(HARECACHE)/os/exec/os.exec.o
hare_stdlib_deps+=$(stdlib_os_exec)

stdlib_path=$(HARECACHE)/path/path.o
hare_stdlib_deps+=$(stdlib_path)

stdlib_slice=$(HARECACHE)/slice/slice.o
hare_stdlib_deps+=$(stdlib_slice)

stdlib_sort=$(HARECACHE)/sort/sort.o
hare_stdlib_deps+=$(stdlib_sort)

stdlib_strconv=$(HARECACHE)/strconv/strconv.o
hare_stdlib_deps+=$(stdlib_strconv)

stdlib_strings=$(HARECACHE)/strings/strings.o
hare_stdlib_deps+=$(stdlib_strings)

stdlib_strio=$(HARECACHE)/strio/strio.o
hare_stdlib_deps+=$(stdlib_strio)

stdlib_types=$(HARECACHE)/types/types.o
hare_stdlib_deps+=$(stdlib_types)

# ascii
stdlib_ascii_srcs= \
	$(STDLIB)/ascii/ctype.ha \
	$(STDLIB)/ascii/strcmp.ha

$(HARECACHE)/ascii/ascii.ssa: $(stdlib_ascii_srcs) $(stdlib_rt) $(stdlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/ascii
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nascii \
		-t$(HARECACHE)/ascii/ascii.td $(stdlib_ascii_srcs)

# bufio
stdlib_bufio_srcs= \
	$(STDLIB)/bufio/buffered.ha \
	$(STDLIB)/bufio/dynamic.ha \
	$(STDLIB)/bufio/fixed.ha

$(HARECACHE)/bufio/bufio.ssa: $(stdlib_bufio_srcs) $(stdlib_rt) $(stdlib_io) $(stdlib_bytes) $(stdlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/bufio
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nbufio \
		-t$(HARECACHE)/bufio/bufio.td $(stdlib_bufio_srcs)

# bytes
stdlib_bytes_srcs= \
	$(STDLIB)/bytes/contains.ha \
	$(STDLIB)/bytes/copy.ha \
	$(STDLIB)/bytes/equal.ha \
	$(STDLIB)/bytes/index.ha \
	$(STDLIB)/bytes/reverse.ha \
	$(STDLIB)/bytes/tokenize.ha

$(HARECACHE)/bytes/bytes.ssa: $(stdlib_bytes_srcs) $(stdlib_rt) $(stdlib_types)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/bytes
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nbytes \
		-t$(HARECACHE)/bytes/bytes.td $(stdlib_bytes_srcs)

# crypto::math
stdlib_crypto_math_srcs= \
	$(STDLIB)/crypto/math/bits.ha

$(HARECACHE)/crypto/math/crypto.math.ssa: $(stdlib_crypto_math_srcs) $(stdlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/crypto/math
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Ncrypto::math \
		-t$(HARECACHE)/crypto/math/crypto.math.td $(stdlib_crypto_math_srcs)

# crypto::random
stdlib_crypto_random_srcs= \
	$(STDLIB)/crypto/random/$(PLATFORM).ha \
	$(STDLIB)/crypto/random/random.ha

$(HARECACHE)/crypto/random/crypto.random.ssa: $(stdlib_crypto_random_srcs) $(stdlib_rt) $(stdlib_rt) $(stdlib_io)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/crypto/random
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Ncrypto::random \
		-t$(HARECACHE)/crypto/random/crypto.random.td $(stdlib_crypto_random_srcs)

# crypto::sha256
stdlib_crypto_sha256_srcs= \
	$(STDLIB)/crypto/sha256/sha256.ha

$(HARECACHE)/crypto/sha256/crypto.sha256.ssa: $(stdlib_crypto_sha256_srcs) $(stdlib_rt) $(stdlib_hash) $(stdlib_io) $(stdlib_endian)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/crypto/sha256
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Ncrypto::sha256 \
		-t$(HARECACHE)/crypto/sha256/crypto.sha256.td $(stdlib_crypto_sha256_srcs)

# dirs
stdlib_dirs_srcs= \
	$(STDLIB)/dirs/xdg.ha

$(HARECACHE)/dirs/dirs.ssa: $(stdlib_dirs_srcs) $(stdlib_rt) $(stdlib_fs) $(stdlib_os) $(stdlib_path)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/dirs
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Ndirs \
		-t$(HARECACHE)/dirs/dirs.td $(stdlib_dirs_srcs)

# encoding::hex
stdlib_encoding_hex_srcs= \
	$(STDLIB)/encoding/hex/hex.ha

$(HARECACHE)/encoding/hex/encoding.hex.ssa: $(stdlib_encoding_hex_srcs) $(stdlib_rt) $(stdlib_io) $(stdlib_strconv) $(stdlib_strio) $(stdlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/encoding/hex
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nencoding::hex \
		-t$(HARECACHE)/encoding/hex/encoding.hex.td $(stdlib_encoding_hex_srcs)

# encoding::utf8
stdlib_encoding_utf8_srcs= \
	$(STDLIB)/encoding/utf8/rune.ha \
	$(STDLIB)/encoding/utf8/decode.ha \
	$(STDLIB)/encoding/utf8/encode.ha

$(HARECACHE)/encoding/utf8/encoding.utf8.ssa: $(stdlib_encoding_utf8_srcs) $(stdlib_rt) $(stdlib_types)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/encoding/utf8
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nencoding::utf8 \
		-t$(HARECACHE)/encoding/utf8/encoding.utf8.td $(stdlib_encoding_utf8_srcs)

# endian
stdlib_endian_srcs= \
	$(STDLIB)/endian/big.ha \
	$(STDLIB)/endian/little.ha \
	$(STDLIB)/endian/endian.ha \
	$(STDLIB)/endian/host$(ARCH).ha

$(HARECACHE)/endian/endian.ssa: $(stdlib_endian_srcs) $(stdlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/endian
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nendian \
		-t$(HARECACHE)/endian/endian.td $(stdlib_endian_srcs)

# fmt
stdlib_fmt_srcs= \
	$(STDLIB)/fmt/fmt.ha

$(HARECACHE)/fmt/fmt.ssa: $(stdlib_fmt_srcs) $(stdlib_rt) $(stdlib_bufio) $(stdlib_io) $(stdlib_os) $(stdlib_strconv) $(stdlib_strings) $(stdlib_types)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/fmt
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nfmt \
		-t$(HARECACHE)/fmt/fmt.td $(stdlib_fmt_srcs)

# format::elf
stdlib_format_elf_srcs= \
	$(STDLIB)/format/elf/types.ha

$(HARECACHE)/format/elf/format.elf.ssa: $(stdlib_format_elf_srcs) $(stdlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/format/elf
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nformat::elf \
		-t$(HARECACHE)/format/elf/format.elf.td $(stdlib_format_elf_srcs)

# fs
stdlib_fs_srcs= \
	$(STDLIB)/fs/types.ha \
	$(STDLIB)/fs/fs.ha \
	$(STDLIB)/fs/util.ha

$(HARECACHE)/fs/fs.ssa: $(stdlib_fs_srcs) $(stdlib_rt) $(stdlib_io) $(stdlib_strings) $(stdlib_path)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/fs
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nfs \
		-t$(HARECACHE)/fs/fs.td $(stdlib_fs_srcs)

# hare::ast
stdlib_hare_ast_srcs= \
	$(STDLIB)/hare/ast/types.ha \
	$(STDLIB)/hare/ast/unparse.ha

$(HARECACHE)/hare/ast/hare.ast.ssa: $(stdlib_hare_ast_srcs) $(stdlib_rt) $(stdlib_io) $(stdlib_fmt) $(stdlib_strio)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/hare/ast
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nhare::ast \
		-t$(HARECACHE)/hare/ast/hare.ast.td $(stdlib_hare_ast_srcs)

# hare::lex
stdlib_hare_lex_srcs= \
	$(STDLIB)/hare/lex/token.ha \
	$(STDLIB)/hare/lex/lex.ha

$(HARECACHE)/hare/lex/hare.lex.ssa: $(stdlib_hare_lex_srcs) $(stdlib_rt) $(stdlib_io) $(stdlib_bufio) $(stdlib_strings) $(stdlib_types) $(stdlib_fmt) $(stdlib_sort)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/hare/lex
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nhare::lex \
		-t$(HARECACHE)/hare/lex/hare.lex.td $(stdlib_hare_lex_srcs)

# hare::module
stdlib_hare_module_srcs= \
	$(STDLIB)/hare/module/types.ha \
	$(STDLIB)/hare/module/context.ha \
	$(STDLIB)/hare/module/scan.ha

$(HARECACHE)/hare/module/hare.module.ssa: $(stdlib_hare_module_srcs) $(stdlib_rt) $(stdlib_hare_ast) $(stdlib_hare_lex) $(stdlib_hare_parse) $(stdlib_strio) $(stdlib_fs) $(stdlib_io) $(stdlib_strings) $(stdlib_hash) $(stdlib_crypto_sha256) $(stdlib_dirs) $(stdlib_bytes) $(stdlib_encoding_utf8)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/hare/module
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nhare::module \
		-t$(HARECACHE)/hare/module/hare.module.td $(stdlib_hare_module_srcs)

# hare::parse
stdlib_hare_parse_srcs= \
	$(STDLIB)/hare/parse/types.ha \
	$(STDLIB)/hare/parse/util.ha \
	$(STDLIB)/hare/parse/parse.ha

$(HARECACHE)/hare/parse/hare.parse.ssa: $(stdlib_hare_parse_srcs) $(stdlib_rt) $(stdlib_hare_ast) $(stdlib_hare_lex) $(stdlib_slice)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/hare/parse
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nhare::parse \
		-t$(HARECACHE)/hare/parse/hare.parse.td $(stdlib_hare_parse_srcs)

# hash
stdlib_hash_srcs= \
	$(STDLIB)/hash/hash.ha

$(HARECACHE)/hash/hash.ssa: $(stdlib_hash_srcs) $(stdlib_rt) $(stdlib_io)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/hash
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nhash \
		-t$(HARECACHE)/hash/hash.td $(stdlib_hash_srcs)

# hash::fnv
stdlib_hash_fnv_srcs= \
	$(STDLIB)/hash/fnv/fnv.ha

$(HARECACHE)/hash/fnv/hash.fnv.ssa: $(stdlib_hash_fnv_srcs) $(stdlib_rt) $(stdlib_hash) $(stdlib_io) $(stdlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/hash/fnv
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nhash::fnv \
		-t$(HARECACHE)/hash/fnv/hash.fnv.td $(stdlib_hash_fnv_srcs)

# io
stdlib_io_srcs= \
	$(STDLIB)/io/arch$(ARCH).ha \
	$(STDLIB)/io/types.ha \
	$(STDLIB)/io/copy.ha \
	$(STDLIB)/io/println.ha \
	$(STDLIB)/io/stream.ha \
	$(STDLIB)/io/limit.ha \
	$(STDLIB)/io/strings.ha \
	$(STDLIB)/io/tee.ha

$(HARECACHE)/io/io.ssa: $(stdlib_io_srcs) $(stdlib_rt) $(stdlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/io
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nio \
		-t$(HARECACHE)/io/io.td $(stdlib_io_srcs)

# os
stdlib_os_srcs= \
	$(STDLIB)/os/$(PLATFORM)/environ.ha \
	$(STDLIB)/os/$(PLATFORM)/errors.ha \
	$(STDLIB)/os/$(PLATFORM)/exit.ha \
	$(STDLIB)/os/$(PLATFORM)/dirfdfs.ha \
	$(STDLIB)/os/$(PLATFORM)/fdstream.ha \
	$(STDLIB)/os/$(PLATFORM)/open.ha \
	$(STDLIB)/os/$(PLATFORM)/stdfd.ha \
	$(STDLIB)/os/$(PLATFORM)/fs.ha \
	$(STDLIB)/os/stdfd.ha \
	$(STDLIB)/os/fs.ha

$(HARECACHE)/os/os.ssa: $(stdlib_os_srcs) $(stdlib_rt) $(stdlib_io) $(stdlib_strings) $(stdlib_types) $(stdlib_fs) $(stdlib_encoding_utf8)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/os
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nos \
		-t$(HARECACHE)/os/os.td $(stdlib_os_srcs)

# os::exec
stdlib_os_exec_srcs= \
	$(STDLIB)/os/exec/$(PLATFORM).ha \
	$(STDLIB)/os/exec/types.ha \
	$(STDLIB)/os/exec/process$(PLATFORM).ha \
	$(STDLIB)/os/exec/cmd$(PLATFORM).ha \
	$(STDLIB)/os/exec/cmd.ha

$(HARECACHE)/os/exec/os.exec.ssa: $(stdlib_os_exec_srcs) $(stdlib_rt) $(stdlib_os) $(stdlib_strings) $(stdlib_fmt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/os/exec
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nos::exec \
		-t$(HARECACHE)/os/exec/os.exec.td $(stdlib_os_exec_srcs)

# path
stdlib_path_srcs= \
	$(STDLIB)/path/$(PLATFORM).ha \
	$(STDLIB)/path/util.ha \
	$(STDLIB)/path/join.ha \
	$(STDLIB)/path/norm.ha \
	$(STDLIB)/path/names.ha

$(HARECACHE)/path/path.ssa: $(stdlib_path_srcs) $(stdlib_rt) $(stdlib_strings) $(stdlib_bufio) $(stdlib_bytes)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/path
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Npath \
		-t$(HARECACHE)/path/path.td $(stdlib_path_srcs)

# slice
stdlib_slice_srcs= \
	$(STDLIB)/slice/reverse.ha

$(HARECACHE)/slice/slice.ssa: $(stdlib_slice_srcs) $(stdlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/slice
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nslice \
		-t$(HARECACHE)/slice/slice.td $(stdlib_slice_srcs)

# sort
stdlib_sort_srcs= \
	$(STDLIB)/sort/search.ha

$(HARECACHE)/sort/sort.ssa: $(stdlib_sort_srcs) $(stdlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/sort
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nsort \
		-t$(HARECACHE)/sort/sort.td $(stdlib_sort_srcs)

# strconv
stdlib_strconv_srcs= \
	$(STDLIB)/strconv/types.ha \
	$(STDLIB)/strconv/itos.ha \
	$(STDLIB)/strconv/utos.ha \
	$(STDLIB)/strconv/stou.ha \
	$(STDLIB)/strconv/stoi.ha \
	$(STDLIB)/strconv/numeric.ha

$(HARECACHE)/strconv/strconv.ssa: $(stdlib_strconv_srcs) $(stdlib_rt) $(stdlib_types) $(stdlib_strings) $(stdlib_ascii)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/strconv
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nstrconv \
		-t$(HARECACHE)/strconv/strconv.td $(stdlib_strconv_srcs)

# strings
stdlib_strings_srcs= \
	$(STDLIB)/strings/concat.ha \
	$(STDLIB)/strings/contains.ha \
	$(STDLIB)/strings/cstrings.ha \
	$(STDLIB)/strings/dup.ha \
	$(STDLIB)/strings/iter.ha \
	$(STDLIB)/strings/sub.ha \
	$(STDLIB)/strings/suffix.ha \
	$(STDLIB)/strings/tokenize.ha \
	$(STDLIB)/strings/utf8.ha

$(HARECACHE)/strings/strings.ssa: $(stdlib_strings_srcs) $(stdlib_rt) $(stdlib_bytes) $(stdlib_encoding_utf8) $(stdlib_types)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/strings
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nstrings \
		-t$(HARECACHE)/strings/strings.td $(stdlib_strings_srcs)

# strio
stdlib_strio_srcs= \
	$(STDLIB)/strio/dynamic.ha \
	$(STDLIB)/strio/fixed.ha \
	$(STDLIB)/strio/ops.ha

$(HARECACHE)/strio/strio.ssa: $(stdlib_strio_srcs) $(stdlib_rt) $(stdlib_io) $(stdlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/strio
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Nstrio \
		-t$(HARECACHE)/strio/strio.td $(stdlib_strio_srcs)

# types
stdlib_types_srcs= \
	$(STDLIB)/types/limits.ha \
	$(STDLIB)/types/classes.ha \
	$(STDLIB)/types/arch$(ARCH).ha

$(HARECACHE)/types/types.ssa: $(stdlib_types_srcs) $(stdlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(HARECACHE)/types
	@HARECACHE=$(HARECACHE) $(HAREC) $(HAREFLAGS) -o $@ -Ntypes \
		-t$(HARECACHE)/types/types.td $(stdlib_types_srcs)

# rt
testlib_rt_srcs= \
	$(STDLIB)/rt/$(PLATFORM)/env.ha \
	$(STDLIB)/rt/$(PLATFORM)/errno.ha \
	$(STDLIB)/rt/$(PLATFORM)/segmalloc.ha \
	$(STDLIB)/rt/$(PLATFORM)/start.ha \
	$(STDLIB)/rt/$(PLATFORM)/stat.ha \
	$(STDLIB)/rt/$(PLATFORM)/$(ARCH).ha \
	$(STDLIB)/rt/$(PLATFORM)/syscallno$(ARCH).ha \
	$(STDLIB)/rt/$(PLATFORM)/syscalls.ha \
	$(STDLIB)/rt/$(PLATFORM)/types.ha \
	$(STDLIB)/rt/$(ARCH)/jmp.ha \
	$(STDLIB)/rt/ensure.ha \
	$(STDLIB)/rt/jmp.ha \
	$(STDLIB)/rt/malloc.ha \
	$(STDLIB)/rt/memcpy.ha \
	$(STDLIB)/rt/memset.ha \
	$(STDLIB)/rt/strcmp.ha \
	$(STDLIB)/rt/+test/$(PLATFORM).ha \
	$(STDLIB)/rt/+test/abort.ha \
	$(STDLIB)/rt/+test/cstring.ha \
	$(STDLIB)/rt/+test/start.ha \
	$(STDLIB)/rt/+test/ztos.ha

$(TESTCACHE)/rt/rt.ssa: $(testlib_rt_srcs) $(testlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/rt
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nrt \
		-t$(TESTCACHE)/rt/rt.td $(testlib_rt_srcs)

$(TESTCACHE)/rt/start.o: $(STDLIB)/rt/$(PLATFORM)/start$(ARCH).s
	@printf 'AS \t$@\n'
	@mkdir -p $(TESTCACHE)/rt
	@$(AS) -o $@ $<

testlib_asm=$(TESTCACHE)/rt/syscall.o \
	$(TESTCACHE)/rt/setjmp.o \
	$(TESTCACHE)/rt/longjmp.o

$(TESTCACHE)/rt/syscall.o: $(STDLIB)/rt/$(PLATFORM)/syscall$(ARCH).s
	@printf 'AS \t$@\n'
	@mkdir -p $(TESTCACHE)/rt
	@$(AS) -o $@ $<

$(TESTCACHE)/rt/setjmp.o: $(STDLIB)/rt/$(ARCH)/setjmp.s
	@printf 'AS \t$@\n'
	@mkdir -p $(TESTCACHE)/rt
	@$(AS) -o $@ $<

$(TESTCACHE)/rt/longjmp.o: $(STDLIB)/rt/$(ARCH)/longjmp.s
	@printf 'AS \t$@\n'
	@mkdir -p $(TESTCACHE)/rt
	@$(AS) -o $@ $<

$(TESTCACHE)/rt/rt.a: $(TESTCACHE)/rt/rt.o $(testlib_asm)
	@printf 'AR\t$@\n'
	@$(AR) -csr $@ $(TESTCACHE)/rt/rt.o $(testlib_asm)

testlib_rt=$(TESTCACHE)/rt/rt.a
testlib_start=$(TESTCACHE)/rt/start.o
hare_testlib_deps+=$(testlib_rt)

testlib_ascii=$(TESTCACHE)/ascii/ascii.o
hare_testlib_deps+=$(testlib_ascii)

testlib_bufio=$(TESTCACHE)/bufio/bufio.o
hare_testlib_deps+=$(testlib_bufio)

testlib_bytes=$(TESTCACHE)/bytes/bytes.o
hare_testlib_deps+=$(testlib_bytes)

testlib_crypto_math=$(TESTCACHE)/crypto/math/crypto.math.o
hare_testlib_deps+=$(testlib_crypto_math)

testlib_crypto_random=$(TESTCACHE)/crypto/random/crypto.random.o
hare_testlib_deps+=$(testlib_crypto_random)

testlib_crypto_sha256=$(TESTCACHE)/crypto/sha256/crypto.sha256.o
hare_testlib_deps+=$(testlib_crypto_sha256)

testlib_dirs=$(TESTCACHE)/dirs/dirs.o
hare_testlib_deps+=$(testlib_dirs)

testlib_encoding_hex=$(TESTCACHE)/encoding/hex/encoding.hex.o
hare_testlib_deps+=$(testlib_encoding_hex)

testlib_encoding_utf8=$(TESTCACHE)/encoding/utf8/encoding.utf8.o
hare_testlib_deps+=$(testlib_encoding_utf8)

testlib_endian=$(TESTCACHE)/endian/endian.o
hare_testlib_deps+=$(testlib_endian)

testlib_fmt=$(TESTCACHE)/fmt/fmt.o
hare_testlib_deps+=$(testlib_fmt)

testlib_format_elf=$(TESTCACHE)/format/elf/format.elf.o
hare_testlib_deps+=$(testlib_format_elf)

testlib_fs=$(TESTCACHE)/fs/fs.o
hare_testlib_deps+=$(testlib_fs)

testlib_hare_ast=$(TESTCACHE)/hare/ast/hare.ast.o
hare_testlib_deps+=$(testlib_hare_ast)

testlib_hare_lex=$(TESTCACHE)/hare/lex/hare.lex.o
hare_testlib_deps+=$(testlib_hare_lex)

testlib_hare_module=$(TESTCACHE)/hare/module/hare.module.o
hare_testlib_deps+=$(testlib_hare_module)

testlib_hare_parse=$(TESTCACHE)/hare/parse/hare.parse.o
hare_testlib_deps+=$(testlib_hare_parse)

testlib_hash=$(TESTCACHE)/hash/hash.o
hare_testlib_deps+=$(testlib_hash)

testlib_hash_fnv=$(TESTCACHE)/hash/fnv/hash.fnv.o
hare_testlib_deps+=$(testlib_hash_fnv)

testlib_io=$(TESTCACHE)/io/io.o
hare_testlib_deps+=$(testlib_io)

testlib_os=$(TESTCACHE)/os/os.o
hare_testlib_deps+=$(testlib_os)

testlib_os_exec=$(TESTCACHE)/os/exec/os.exec.o
hare_testlib_deps+=$(testlib_os_exec)

testlib_path=$(TESTCACHE)/path/path.o
hare_testlib_deps+=$(testlib_path)

testlib_slice=$(TESTCACHE)/slice/slice.o
hare_testlib_deps+=$(testlib_slice)

testlib_sort=$(TESTCACHE)/sort/sort.o
hare_testlib_deps+=$(testlib_sort)

testlib_strconv=$(TESTCACHE)/strconv/strconv.o
hare_testlib_deps+=$(testlib_strconv)

testlib_strings=$(TESTCACHE)/strings/strings.o
hare_testlib_deps+=$(testlib_strings)

testlib_strio=$(TESTCACHE)/strio/strio.o
hare_testlib_deps+=$(testlib_strio)

testlib_types=$(TESTCACHE)/types/types.o
hare_testlib_deps+=$(testlib_types)

# ascii
testlib_ascii_srcs= \
	$(STDLIB)/ascii/ctype.ha \
	$(STDLIB)/ascii/strcmp.ha

$(TESTCACHE)/ascii/ascii.ssa: $(testlib_ascii_srcs) $(testlib_rt) $(testlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/ascii
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nascii \
		-t$(TESTCACHE)/ascii/ascii.td $(testlib_ascii_srcs)

# bufio
testlib_bufio_srcs= \
	$(STDLIB)/bufio/buffered.ha \
	$(STDLIB)/bufio/dynamic.ha \
	$(STDLIB)/bufio/fixed.ha

$(TESTCACHE)/bufio/bufio.ssa: $(testlib_bufio_srcs) $(testlib_rt) $(testlib_io) $(testlib_bytes) $(testlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/bufio
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nbufio \
		-t$(TESTCACHE)/bufio/bufio.td $(testlib_bufio_srcs)

# bytes
testlib_bytes_srcs= \
	$(STDLIB)/bytes/contains.ha \
	$(STDLIB)/bytes/copy.ha \
	$(STDLIB)/bytes/equal.ha \
	$(STDLIB)/bytes/index.ha \
	$(STDLIB)/bytes/reverse.ha \
	$(STDLIB)/bytes/tokenize.ha

$(TESTCACHE)/bytes/bytes.ssa: $(testlib_bytes_srcs) $(testlib_rt) $(testlib_types)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/bytes
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nbytes \
		-t$(TESTCACHE)/bytes/bytes.td $(testlib_bytes_srcs)

# crypto::math
testlib_crypto_math_srcs= \
	$(STDLIB)/crypto/math/bits.ha

$(TESTCACHE)/crypto/math/crypto.math.ssa: $(testlib_crypto_math_srcs) $(testlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/crypto/math
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Ncrypto::math \
		-t$(TESTCACHE)/crypto/math/crypto.math.td $(testlib_crypto_math_srcs)

# crypto::random
testlib_crypto_random_srcs= \
	$(STDLIB)/crypto/random/$(PLATFORM).ha \
	$(STDLIB)/crypto/random/random.ha

$(TESTCACHE)/crypto/random/crypto.random.ssa: $(testlib_crypto_random_srcs) $(testlib_rt) $(testlib_rt) $(testlib_io)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/crypto/random
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Ncrypto::random \
		-t$(TESTCACHE)/crypto/random/crypto.random.td $(testlib_crypto_random_srcs)

# crypto::sha256
testlib_crypto_sha256_srcs= \
	$(STDLIB)/crypto/sha256/sha256.ha \
	$(STDLIB)/crypto/sha256/+test.ha

$(TESTCACHE)/crypto/sha256/crypto.sha256.ssa: $(testlib_crypto_sha256_srcs) $(testlib_rt) $(testlib_hash) $(testlib_io) $(testlib_endian) $(testlib_fmt) $(testlib_strio) $(testlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/crypto/sha256
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Ncrypto::sha256 \
		-t$(TESTCACHE)/crypto/sha256/crypto.sha256.td $(testlib_crypto_sha256_srcs)

# dirs
testlib_dirs_srcs= \
	$(STDLIB)/dirs/xdg.ha

$(TESTCACHE)/dirs/dirs.ssa: $(testlib_dirs_srcs) $(testlib_rt) $(testlib_fs) $(testlib_os) $(testlib_path)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/dirs
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Ndirs \
		-t$(TESTCACHE)/dirs/dirs.td $(testlib_dirs_srcs)

# encoding::hex
testlib_encoding_hex_srcs= \
	$(STDLIB)/encoding/hex/hex.ha

$(TESTCACHE)/encoding/hex/encoding.hex.ssa: $(testlib_encoding_hex_srcs) $(testlib_rt) $(testlib_io) $(testlib_strconv) $(testlib_strio) $(testlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/encoding/hex
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nencoding::hex \
		-t$(TESTCACHE)/encoding/hex/encoding.hex.td $(testlib_encoding_hex_srcs)

# encoding::utf8
testlib_encoding_utf8_srcs= \
	$(STDLIB)/encoding/utf8/rune.ha \
	$(STDLIB)/encoding/utf8/decode.ha \
	$(STDLIB)/encoding/utf8/encode.ha

$(TESTCACHE)/encoding/utf8/encoding.utf8.ssa: $(testlib_encoding_utf8_srcs) $(testlib_rt) $(testlib_types)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/encoding/utf8
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nencoding::utf8 \
		-t$(TESTCACHE)/encoding/utf8/encoding.utf8.td $(testlib_encoding_utf8_srcs)

# endian
testlib_endian_srcs= \
	$(STDLIB)/endian/big.ha \
	$(STDLIB)/endian/little.ha \
	$(STDLIB)/endian/endian.ha \
	$(STDLIB)/endian/host$(ARCH).ha

$(TESTCACHE)/endian/endian.ssa: $(testlib_endian_srcs) $(testlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/endian
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nendian \
		-t$(TESTCACHE)/endian/endian.td $(testlib_endian_srcs)

# fmt
testlib_fmt_srcs= \
	$(STDLIB)/fmt/fmt.ha

$(TESTCACHE)/fmt/fmt.ssa: $(testlib_fmt_srcs) $(testlib_rt) $(testlib_bufio) $(testlib_io) $(testlib_os) $(testlib_strconv) $(testlib_strings) $(testlib_types)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/fmt
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nfmt \
		-t$(TESTCACHE)/fmt/fmt.td $(testlib_fmt_srcs)

# format::elf
testlib_format_elf_srcs= \
	$(STDLIB)/format/elf/types.ha

$(TESTCACHE)/format/elf/format.elf.ssa: $(testlib_format_elf_srcs) $(testlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/format/elf
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nformat::elf \
		-t$(TESTCACHE)/format/elf/format.elf.td $(testlib_format_elf_srcs)

# fs
testlib_fs_srcs= \
	$(STDLIB)/fs/types.ha \
	$(STDLIB)/fs/fs.ha \
	$(STDLIB)/fs/util.ha

$(TESTCACHE)/fs/fs.ssa: $(testlib_fs_srcs) $(testlib_rt) $(testlib_io) $(testlib_strings) $(testlib_path)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/fs
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nfs \
		-t$(TESTCACHE)/fs/fs.td $(testlib_fs_srcs)

# hare::ast
testlib_hare_ast_srcs= \
	$(STDLIB)/hare/ast/types.ha \
	$(STDLIB)/hare/ast/unparse.ha

$(TESTCACHE)/hare/ast/hare.ast.ssa: $(testlib_hare_ast_srcs) $(testlib_rt) $(testlib_io) $(testlib_fmt) $(testlib_strio)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/hare/ast
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nhare::ast \
		-t$(TESTCACHE)/hare/ast/hare.ast.td $(testlib_hare_ast_srcs)

# hare::lex
testlib_hare_lex_srcs= \
	$(STDLIB)/hare/lex/token.ha \
	$(STDLIB)/hare/lex/lex.ha \
	$(STDLIB)/hare/lex/+test.ha

$(TESTCACHE)/hare/lex/hare.lex.ssa: $(testlib_hare_lex_srcs) $(testlib_rt) $(testlib_io) $(testlib_bufio) $(testlib_strings) $(testlib_types) $(testlib_fmt) $(testlib_sort)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/hare/lex
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nhare::lex \
		-t$(TESTCACHE)/hare/lex/hare.lex.td $(testlib_hare_lex_srcs)

# hare::module
testlib_hare_module_srcs= \
	$(STDLIB)/hare/module/types.ha \
	$(STDLIB)/hare/module/context.ha \
	$(STDLIB)/hare/module/scan.ha

$(TESTCACHE)/hare/module/hare.module.ssa: $(testlib_hare_module_srcs) $(testlib_rt) $(testlib_hare_ast) $(testlib_hare_lex) $(testlib_hare_parse) $(testlib_strio) $(testlib_fs) $(testlib_io) $(testlib_strings) $(testlib_hash) $(testlib_crypto_sha256) $(testlib_dirs) $(testlib_bytes) $(testlib_encoding_utf8)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/hare/module
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nhare::module \
		-t$(TESTCACHE)/hare/module/hare.module.td $(testlib_hare_module_srcs)

# hare::parse
testlib_hare_parse_srcs= \
	$(STDLIB)/hare/parse/types.ha \
	$(STDLIB)/hare/parse/util.ha \
	$(STDLIB)/hare/parse/parse.ha \
	$(STDLIB)/hare/parse/+test.ha

$(TESTCACHE)/hare/parse/hare.parse.ssa: $(testlib_hare_parse_srcs) $(testlib_rt) $(testlib_hare_ast) $(testlib_hare_lex) $(testlib_slice)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/hare/parse
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nhare::parse \
		-t$(TESTCACHE)/hare/parse/hare.parse.td $(testlib_hare_parse_srcs)

# hash
testlib_hash_srcs= \
	$(STDLIB)/hash/hash.ha

$(TESTCACHE)/hash/hash.ssa: $(testlib_hash_srcs) $(testlib_rt) $(testlib_io)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/hash
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nhash \
		-t$(TESTCACHE)/hash/hash.td $(testlib_hash_srcs)

# hash::fnv
testlib_hash_fnv_srcs= \
	$(STDLIB)/hash/fnv/fnv.ha

$(TESTCACHE)/hash/fnv/hash.fnv.ssa: $(testlib_hash_fnv_srcs) $(testlib_rt) $(testlib_hash) $(testlib_io) $(testlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/hash/fnv
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nhash::fnv \
		-t$(TESTCACHE)/hash/fnv/hash.fnv.td $(testlib_hash_fnv_srcs)

# io
testlib_io_srcs= \
	$(STDLIB)/io/arch$(ARCH).ha \
	$(STDLIB)/io/types.ha \
	$(STDLIB)/io/copy.ha \
	$(STDLIB)/io/println.ha \
	$(STDLIB)/io/stream.ha \
	$(STDLIB)/io/limit.ha \
	$(STDLIB)/io/strings.ha \
	$(STDLIB)/io/tee.ha \
	$(STDLIB)/io/+test/copy.ha \
	$(STDLIB)/io/+test/limit.ha \
	$(STDLIB)/io/+test/stream.ha \
	$(STDLIB)/io/+test/strings.ha

$(TESTCACHE)/io/io.ssa: $(testlib_io_srcs) $(testlib_rt) $(testlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/io
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nio \
		-t$(TESTCACHE)/io/io.td $(testlib_io_srcs)

# os
testlib_os_srcs= \
	$(STDLIB)/os/$(PLATFORM)/environ.ha \
	$(STDLIB)/os/$(PLATFORM)/errors.ha \
	$(STDLIB)/os/$(PLATFORM)/exit.ha \
	$(STDLIB)/os/$(PLATFORM)/dirfdfs.ha \
	$(STDLIB)/os/$(PLATFORM)/fdstream.ha \
	$(STDLIB)/os/$(PLATFORM)/open.ha \
	$(STDLIB)/os/$(PLATFORM)/stdfd.ha \
	$(STDLIB)/os/$(PLATFORM)/fs.ha \
	$(STDLIB)/os/stdfd.ha \
	$(STDLIB)/os/fs.ha

$(TESTCACHE)/os/os.ssa: $(testlib_os_srcs) $(testlib_rt) $(testlib_io) $(testlib_strings) $(testlib_types) $(testlib_fs) $(testlib_encoding_utf8)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/os
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nos \
		-t$(TESTCACHE)/os/os.td $(testlib_os_srcs)

# os::exec
testlib_os_exec_srcs= \
	$(STDLIB)/os/exec/$(PLATFORM).ha \
	$(STDLIB)/os/exec/types.ha \
	$(STDLIB)/os/exec/process$(PLATFORM).ha \
	$(STDLIB)/os/exec/cmd$(PLATFORM).ha \
	$(STDLIB)/os/exec/cmd.ha

$(TESTCACHE)/os/exec/os.exec.ssa: $(testlib_os_exec_srcs) $(testlib_rt) $(testlib_os) $(testlib_strings) $(testlib_fmt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/os/exec
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nos::exec \
		-t$(TESTCACHE)/os/exec/os.exec.td $(testlib_os_exec_srcs)

# path
testlib_path_srcs= \
	$(STDLIB)/path/$(PLATFORM).ha \
	$(STDLIB)/path/util.ha \
	$(STDLIB)/path/join.ha \
	$(STDLIB)/path/norm.ha \
	$(STDLIB)/path/names.ha

$(TESTCACHE)/path/path.ssa: $(testlib_path_srcs) $(testlib_rt) $(testlib_strings) $(testlib_bufio) $(testlib_bytes)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/path
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Npath \
		-t$(TESTCACHE)/path/path.td $(testlib_path_srcs)

# slice
testlib_slice_srcs= \
	$(STDLIB)/slice/reverse.ha

$(TESTCACHE)/slice/slice.ssa: $(testlib_slice_srcs) $(testlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/slice
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nslice \
		-t$(TESTCACHE)/slice/slice.td $(testlib_slice_srcs)

# sort
testlib_sort_srcs= \
	$(STDLIB)/sort/search.ha \
	$(STDLIB)/sort/+test.ha

$(TESTCACHE)/sort/sort.ssa: $(testlib_sort_srcs) $(testlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/sort
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nsort \
		-t$(TESTCACHE)/sort/sort.td $(testlib_sort_srcs)

# strconv
testlib_strconv_srcs= \
	$(STDLIB)/strconv/types.ha \
	$(STDLIB)/strconv/itos.ha \
	$(STDLIB)/strconv/utos.ha \
	$(STDLIB)/strconv/stou.ha \
	$(STDLIB)/strconv/stoi.ha \
	$(STDLIB)/strconv/numeric.ha \
	$(STDLIB)/strconv/+test/stou.ha \
	$(STDLIB)/strconv/+test/stoi.ha

$(TESTCACHE)/strconv/strconv.ssa: $(testlib_strconv_srcs) $(testlib_rt) $(testlib_types) $(testlib_strings) $(testlib_ascii)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/strconv
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nstrconv \
		-t$(TESTCACHE)/strconv/strconv.td $(testlib_strconv_srcs)

# strings
testlib_strings_srcs= \
	$(STDLIB)/strings/concat.ha \
	$(STDLIB)/strings/contains.ha \
	$(STDLIB)/strings/cstrings.ha \
	$(STDLIB)/strings/dup.ha \
	$(STDLIB)/strings/iter.ha \
	$(STDLIB)/strings/sub.ha \
	$(STDLIB)/strings/suffix.ha \
	$(STDLIB)/strings/tokenize.ha \
	$(STDLIB)/strings/utf8.ha

$(TESTCACHE)/strings/strings.ssa: $(testlib_strings_srcs) $(testlib_rt) $(testlib_bytes) $(testlib_encoding_utf8) $(testlib_types)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/strings
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nstrings \
		-t$(TESTCACHE)/strings/strings.td $(testlib_strings_srcs)

# strio
testlib_strio_srcs= \
	$(STDLIB)/strio/dynamic.ha \
	$(STDLIB)/strio/fixed.ha \
	$(STDLIB)/strio/ops.ha

$(TESTCACHE)/strio/strio.ssa: $(testlib_strio_srcs) $(testlib_rt) $(testlib_io) $(testlib_strings)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/strio
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Nstrio \
		-t$(TESTCACHE)/strio/strio.td $(testlib_strio_srcs)

# types
testlib_types_srcs= \
	$(STDLIB)/types/limits.ha \
	$(STDLIB)/types/classes.ha \
	$(STDLIB)/types/arch$(ARCH).ha

$(TESTCACHE)/types/types.ssa: $(testlib_types_srcs) $(testlib_rt)
	@printf 'HAREC \t$@\n'
	@mkdir -p $(TESTCACHE)/types
	@HARECACHE=$(TESTCACHE) $(HAREC) $(TESTHAREFLAGS) -o $@ -Ntypes \
		-t$(TESTCACHE)/types/types.td $(testlib_types_srcs)

