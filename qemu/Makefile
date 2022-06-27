APP ?= riscv_all_instr_test

CC=riscv64-unknown-elf-gcc

CC_FLAGS=-march=rv32g -mabi=ilp32 -static -mcmodel=medany \
	-fvisibility=hidden -nostdlib -nostartfiles -Tsifive_e/sifive_e.ld \
	-Isifive_e -g

CC_DEFS=-DQEMU_SIMUL

BUILDIR=build

$(BUILDIR)/$(APP).elf: $(APP).s

$(BUILDIR)/%.elf:
	@if [ ! -d "./build" ]; then mkdir build; fi
	$(CC) -o $@ $(CC_FLAGS) $(CC_DEFS) $^

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
clean:
	rm -rf $(BUILDIR)
