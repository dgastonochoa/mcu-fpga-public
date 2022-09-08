`ifndef TEST_CPU_MEM_SVH
`define TEST_CPU_MEM_SVH

`ifdef CONFIG_RISCV_MULTICYCLE
    `define CPU_MEM_DATA_START_IDX      508

    `define CPU_MEM_GET_D(cm, idx)      cm.m._mem._mem[idx + `CPU_MEM_DATA_START_IDX]
    `define CPU_MEM_SET_D(cm, idx, d)   cm.m._mem._mem[idx + `CPU_MEM_DATA_START_IDX] = d

    `define CPU_MEM_GET_I(cm, idx)      cm.m._mem._mem[idx]
    `define CPU_MEM_SET_I(cm, idx, i)   cm.m._mem._mem[idx] = i

    `define CPU_MEM_GET_I_M(cm)         cm.m._mem._mem
`else
    `define CPU_MEM_DATA_START_IDX      0

    `define CPU_MEM_GET_D(cm, idx)      cm.dm._mem._mem[idx]
    `define CPU_MEM_SET_D(cm, idx, d)   cm.dm._mem._mem[idx] = d

    `define CPU_MEM_GET_I(cm, idx)      cm.im._mem._mem[idx]
    `define CPU_MEM_SET_I(cm, idx, i)   cm.im._mem._mem[idx] = i

    `define CPU_MEM_GET_I_M(cm)         cm.im._mem._mem
`endif




`endif // TEST_CPU_MEM_SVH