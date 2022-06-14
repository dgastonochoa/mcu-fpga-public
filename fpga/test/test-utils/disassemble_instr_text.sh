#!/bin/bash

# Disassembly an assembled RISC-V file. The input file must be in
# little-endian

FILE=$1

# Used flags:
#
# -M no-aliases ->      use only canonical instructions
# -M numeric    ->      use raw register names
# -mabi=ilp32   ->      use risc-v most basic ABI ilp32
# -b binary     ->      input file is in binary format
# -m riscv      ->      RISCV arch.
# -D            ->      disassemble all

riscv64-unknown-elf-objdump -M no-aliases -M numeric -mabi=ilp32 -b binary -m riscv -D -m riscv -D $FILE
