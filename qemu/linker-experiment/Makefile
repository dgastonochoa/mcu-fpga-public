APP ?= led_blink_ln_exper_tests

CC=riscv64-unknown-elf-gcc
OBJC=riscv64-unknown-elf-objcopy
OBJD=riscv64-unknown-elf-objdump

CC_FLAGS = -march=rv32g -mabi=ilp32 -static -mcmodel=medany 					\
		   -fvisibility=hidden -nostdlib -nostartfiles -I./include 				\
		   -g -O0

BUILDIR = build

SRCDIR = ./src
INCDIR = ./include

bld_src = $(SRCDIR)/main.c $(SRCDIR)/startup.s

$(BUILDIR)/led_blink_ln_exper.txt: $(BUILDIR)/led_blink_ln_exper.bin
	xxd -e -c 4 $< | cut -d ' ' -f 2 > $@

$(BUILDIR)/led_blink_ln_exper.bin: $(BUILDIR)/led_blink_ln_exper.elf
	$(OBJC) -O binary $< $@

$(BUILDIR)/led_blink_ln_exper.elf: $(bld_src) $(BUILDIR)/.ld_timestamp.s | dirs
	$(CC) -o $@ $(CC_FLAGS) -T./linker.ld $^

$(BUILDIR)/.ld_timestamp.s: ./linker.ld | dirs
	@touch $(BUILDIR)/.ld_timestamp.s


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
