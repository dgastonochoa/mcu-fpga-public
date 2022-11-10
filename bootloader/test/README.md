# Summary

This folder contains tests meant to be executed on a SiFive E emulated on qemu. The original
SiFive E linker script has been modified for testint purposes.

These tests aren't built from the project root folder as the bootloader. Instead, do:

    mkdir build
    cd build
    cmake ..
    make

And run qemu as explaned below.


# Commands to launch qemu

## With gdbserver

    qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel ./build/elfile.elf -s -S


## Without gdbserver

    qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel ./build/elfile.elf


# TODO

This should either be unit tests (they cannot be for now, because the bootloader is written in
RISC-V assembly) or be executed in a qemu emulator for a `simpleriscv` soc. Since none of the
above can be done for now, they are executed in a SiFive E qemu emulated soc, with its linker
script adapted to support `_fwimg`.
