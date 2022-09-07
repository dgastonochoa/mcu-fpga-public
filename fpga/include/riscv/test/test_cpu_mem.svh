`ifndef TEST_CPU_MEM_SVH
`define TEST_CPU_MEM_SVH

`define CPU_MEM_GET_D(cm, idx)      cm.dm._mem._mem[idx]
`define CPU_MEM_SET_D(cm, idx, d)   cm.dm._mem._mem[idx] = d

`define CPU_MEM_GET_I(cm, idx)      cm.im._mem._mem[idx]
`define CPU_MEM_SET_I(cm, idx, i)   cm.im._mem._mem[idx] = i

`define CPU_MEM_GET_I_M(cm)         cm.im._mem._mem

`define CPU_MEM_DATA_START_IDX      0  // TODO multicycle = 512

`endif // TEST_CPU_MEM_SVH