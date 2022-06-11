build/hello32.elf:
	@if [ ! -d "./build" ]; then mkdir build; fi
	riscv64-unknown-elf-gcc -march=rv32g -mabi=ilp32 -static -mcmodel=medany \
		-fvisibility=hidden -nostdlib -nostartfiles -Tsifive_e/hello.ld \
		-Isifive_e hello.s -o build/hello32.elf

.PHONY:
qemu32:
	qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel build/hello32.elf

.PHONY:
gdb.qemu32:
	qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel build/hello32.elf -s -S

