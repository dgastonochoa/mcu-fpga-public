#!/bin/bash

# Given a source assembly file, assembly it and display
# the hex values for each instruction

SRC_FILE=$1

RV_AS=riscv64-unknown-elf-as
RV_OBJCOPY=riscv64-unknown-elf-objcopy

$RV_AS -o /tmp/gen_asm_instr.elf $SRC_FILE
$RV_OBJCOPY -O binary /tmp/gen_asm_instr.elf /tmp/gen_asm_instr.bin
xxd -e -c 4 /tmp/gen_asm_instr.bin | cut -d ' ' -f 2
