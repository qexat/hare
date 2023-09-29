.POSIX:

all:

include config.mk
include makefiles/$(PLATFORM).$(ARCH).mk

all: $(BINOUT)/hare $(BINOUT)/harec2 $(BINOUT)/haredoc docs

HARE_DEFINES = \
	-D PLATFORM:str='"$(PLATFORM)"' \
	-D ARCH:str='"$(ARCH)"' \
	-D VERSION:str='"$(VERSION)"' \
	-D HAREPATH:str='"$(HAREPATH)"' \
	-D AARCH64_AS:str='"$(AARCH64_AS)"' \
	-D AARCH64_CC:str='"$(AARCH64_CC)"' \
	-D AARCH64_LD:str='"$(AARCH64_LD)"' \
	-D RISCV64_AS:str='"$(RISCV64_AS)"' \
	-D RISCV64_CC:str='"$(RISCV64_CC)"' \
	-D RISCV64_LD:str='"$(RISCV64_LD)"' \
	-D X86_64_AS:str='"$(X86_64_AS)"' \
	-D X86_64_CC:str='"$(X86_64_CC)"' \
	-D X86_64_LD:str='"$(X86_64_LD)"'

.SUFFIXES:
.SUFFIXES: .ha .ssa .td .s .o .scd
.ssa.td:
	@cmp -s '$@' '$@.tmp' 2>/dev/null || cp '$@.tmp' '$@'

.ssa.s:
	@printf 'QBE\t%s\n' '$@'
	@$(QBE) $(QBEFLAGS) -o '$@' '$<'

.s.o:
	@printf 'AS\t%s\n' '$@'
	@$(AS) $(ASFLAGS) -o '$@' '$<'

.scd:
	@printf 'SCDOC\t%s\n' '$@'
	@$(SCDOC) < '$<' > '$@'

$(BINOUT)/hare: $(OBJS)
	@mkdir -p -- "$(BINOUT)"
	@printf 'LD\t%s\n' "$@"
	@$(LD) $(LDLINKFLAGS) --gc-sections -z noexecstack -T $(RTSCRIPT) -o $@ $(OBJS)

$(BINOUT)/harec2: $(BINOUT)/hare
	@printf 'HARE\t%s\n' "$@"
	@env HAREPATH=. HAREC=$(HAREC) QBE=$(QBE) AS=$(AS) LD=$(LD) \
		HAREFLAGS=$(HAREFLAGS) HARECFLAGS=$(HARECFLAGS) \
		QBEFLAGS=$(QBEFLAGS) ASFLAGS=$(ASFLAGS) \
		LDLINKFLAGS=$(LDLINKFLAGS) \
		$(BINOUT)/hare build $(HARE_DEFINES) -o $(BINOUT)/harec2 cmd/harec

$(BINOUT)/haredoc: $(BINOUT)/hare
	@mkdir -p $(BINOUT)
	@printf 'HARE\t%s\n' "$@"
	@env HAREPATH=. HAREC=$(HAREC) QBE=$(QBE) $(BINOUT)/hare build \
		$(HARE_DEFINES) -o $(BINOUT)/haredoc ./cmd/haredoc

docs/html: $(BINOUT)/haredoc
	mkdir -p docs/html
	$(BINOUT)/haredoc -Fhtml > docs/html/index.html
	for d in $$(scripts/moddirs); do \
		find $$d -type d | sed -E '/(\+|-)/d'; \
	done \
	| while read path; do \
		mod=$$(echo $$path | sed -E 's@/@::@g'); \
		echo $$mod; \
		mkdir -p docs/html/$$path; \
		$(BINOUT)/haredoc -Fhtml $$mod > docs/html/$$path/index.html; \
	done

docs/hare.1: docs/hare.1.scd
docs/haredoc.1: docs/haredoc.1.scd
docs/hare-doc.5: docs/hare-doc.5.scd

docs: docs/hare.1 docs/haredoc.1 docs/hare-doc.5

bootstrap:
	@BINOUT=$(BINOUT) ./scripts/genbootstrap

clean:
	$(RM) -rf '$(HARECACHE)' '$(BINOUT)' docs/hare.1 docs/haredoc.1 \
		docs/hare-doc.5 docs/html

check: $(BINOUT)/hare
	@env HAREPATH=. HAREC=$(HAREC) QBE=$(QBE) AS=$(AS) LD=$(LD) \
		HAREFLAGS=$(HAREFLAGS) HARECFLAGS=$(HARECFLAGS) \
		QBEFLAGS=$(QBEFLAGS) ASFLAGS=$(ASFLAGS) \
		LDLINKFLAGS=$(LDLINKFLAGS) $(BINOUT)/hare test

install: install-cmd install-mods

install-cmd:
	mkdir -p -- \
		'$(DESTDIR)$(BINDIR)' '$(DESTDIR)$(MANDIR)/man1' \
		'$(DESTDIR)$(BINDIR)' '$(DESTDIR)$(MANDIR)/man5'
	install -m755 '$(BINOUT)/hare' '$(DESTDIR)$(BINDIR)/hare'
	install -m755 '$(BINOUT)/haredoc' '$(DESTDIR)$(BINDIR)/haredoc'
	install -m644 docs/hare.1 '$(DESTDIR)$(MANDIR)/man1/hare.1'
	install -m644 docs/haredoc.1 '$(DESTDIR)$(MANDIR)/man1/haredoc.1'
	install -m644 docs/hare-doc.5 '$(DESTDIR)$(MANDIR)/man5/hare-doc.5'

install-mods:
	$(RM) -rf -- '$(DESTDIR)$(STDLIB)'
	mkdir -p -- '$(DESTDIR)$(STDLIB)'
	cp -R -- $$(scripts/moddirs) '$(DESTDIR)$(STDLIB)'

uninstall:
	$(RM) -- '$(DESTDIR)$(BINDIR)/hare'
	$(RM) -- '$(DESTDIR)$(BINDIR)/haredoc'
	$(RM) -- '$(DESTDIR)$(MANDIR)/man1/hare.1'
	$(RM) -- '$(DESTDIR)$(MANDIR)/man1/haredoc.1'
	$(RM) -- '$(DESTDIR)$(MANDIR)/man5/hare-doc.5'
	$(RM) -r -- '$(DESTDIR)$(STDLIB)'

.PHONY: all $(BINOUT)/harec2 $(BINOUT)/haredoc bootstrap clean check docs \
	docs/html install start uninstall
