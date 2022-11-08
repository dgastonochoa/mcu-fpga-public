APP ?= bootloader_tests

CC=riscv64-unknown-elf-gcc
OBJC=riscv64-unknown-elf-objcopy
OBJD=riscv64-unknown-elf-objdump

CC_FLAGS = -march=rv32g -mabi=ilp32 -static -mcmodel=medany 					\
		   -fvisibility=hidden -nostdlib -nostartfiles -I./include 				\
		   -g -O0

BUILDIR = build

BLD_SRCDIR = ./src
BLDT_SRCDIR = $(BLD_SRCDIR)/test
INCDIR = ./include

bld_src = $(BLD_SRCDIR)/bootloader.s $(BLD_SRCDIR)/startup.s $(BLD_SRCDIR)/drivers.s

bld_test_src = $(BLDT_SRCDIR)/startup.s 				\
			   $(BLD_SRCDIR)/bootloader.s				\
			   $(BLDT_SRCDIR)/bootloader_test_utils.s	\
			   $(BLDT_SRCDIR)/bootloader_test_utils.c	\
			   $(BLDT_SRCDIR)/bootloader_test_stdlib.c	\
			   $(BLDT_SRCDIR)/bootloader_mocks.c		\
			   $(BLDT_SRCDIR)/main.c


$(BUILDIR)/bootloader.txt: $(BUILDIR)/bootloader.bin
	xxd -e -c 4 $< | cut -d ' ' -f 2 > $@

$(BUILDIR)/bootloader.bin: $(BUILDIR)/bootloader.elf
	$(OBJC) -O binary $< $@

$(BUILDIR)/bootloader.elf: $(bld_src) $(BUILDIR)/.ld_timestamp.s | dirs
	$(CC) -o $@ $(CC_FLAGS) -T$(INCDIR)/my_riscv_bootloader.ld $^

$(BUILDIR)/bootloader_tests.elf: $(bld_test_src) $(BUILDIR)/.ld_sifive_timestamp.s | dirs
	$(CC) -o $@ $(CC_FLAGS) -T$(INCDIR)/test/sifive_e_modif.ld $^


$(BUILDIR)/.ld_timestamp.s: $(INCDIR)/my_riscv_bootloader.ld | dirs
	@touch $(BUILDIR)/.ld_timestamp.s

$(BUILDIR)/.ld_sifive_timestamp.s: $(INCDIR)/test/sifive_e_modif.ld | dirs
	@touch $(BUILDIR)/.ld_sifive_timestamp.s


.PHONY:
diss-bootloader.elf: $(BUILDIR)/bootloader.elf
	$(OBJD) -M no-aliases -M numeric -mabi=ilp32 -m riscv -D $< | head -n 20

.PHONY:
diss-bootloader.bin: $(BUILDIR)/bootloader.bin
	$(OBJD) -M no-aliases -M numeric -mabi=ilp32 -b binary -m riscv -D $< | head -n 20

.PHONY:
qemu32: $(BUILDIR)/$(APP).elf
	qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel $<

.PHONY:
qemu32.server: $(BUILDIR)/$(APP).elf
	qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel $< -s -S

.PHONY:
gdb: $(BUILDIR)/$(APP).elf
	riscv64-unknown-elf-gdb $<

.PHONY:
debug: $(BUILDIR)/$(APP).elf
	qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel $< -s -S &
	riscv64-unknown-elf-gdb $< -x ./riscv_debug.gdb

.PHONY:
clean:
	rm -rf $(BUILDIR)

.PHONY:
dirs:
	@if [ ! -d "./build" ]; then mkdir build; fi
