`ifndef TEST_CPU_MEM_SVH
`define TEST_CPU_MEM_SVH

/**
 * Get/set a word from/to memory. @param{w} must be
 * 4 bytes aligned.
 *
 */
`define CPU_MEM_GET_W(cm, w)      cm.m._mem._mem[w]
`define CPU_MEM_SET_W(cm, w, d)   cm.m._mem._mem[w] = d

`define CPU_MEM_GET_M(cm)         cm.m._mem._mem

`endif // TEST_CPU_MEM_SVH