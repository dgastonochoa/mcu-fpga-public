CC=riscv64-unknown-elf-gcc

CC_FLAGS=-march=rv32g -mabi=ilp32 -static -mcmodel=medany \
	-fvisibility=hidden -nostdlib -nostartfiles -Tsifive_e/sifive_e.ld \
	-Isifive_e -g

BUILDIR=build

build/exercises.elf: exercises.s

$(BUILDIR)/%.elf:
	@if [ ! -d "./build" ]; then mkdir build; fi
	$(CC) -o $@ $(CC_FLAGS) $^

.PHONY:
qemu32:
	qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel build/exercises.elf

.PHONY:
qemu32.server: build/exercises.elf
	qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel build/exercises.elf -s -S

.PHONY:
gdb: build/exercises.elf
	riscv64-unknown-elf-gdb build/ex6.7.elf
