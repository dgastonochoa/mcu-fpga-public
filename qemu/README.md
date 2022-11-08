# Summary
This folder contains a RISC-V environment in qemu that allows to write
assembly programs and debug them with `qemu` and `gdb`.
See exercises/Makfile.


# Commands to launch qemu

## With gdbserver

    qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel ./build/elfile.elf -s -S


## Without gdbserver

    qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel ./build/elfile.elf