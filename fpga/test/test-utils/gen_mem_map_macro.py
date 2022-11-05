#!/bin/env python3

import sys

if __name__ == '__main__':
    p = sys.argv[1]

    with open(p, 'r') as f:
        lines = f.readlines()

    print('`ifndef RISCV_MULTI_ALL_INSTR_MEM_MAP_SVH')
    print('`define RISCV_MULTI_ALL_INSTR_MEM_MAP_SVH')
    print('`define INIT_MEM_F(mem_reg) \\')
    for i in range(len(lines)):
        s = "mem_reg[{}] = 32'h{};".format(i, lines[i].strip())
        if i < (len(lines) - 1):
            print('{0:<60}\\'.format(s))
        else:
            print('{0:<60}'.format(s))

    print('')
    print('`endif // RISCV_MULTI_ALL_INSTR_MEM_MAP_SVH')
