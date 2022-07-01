`ifndef RISCV_TEST_UTILS_SVH
`define RISCV_TEST_UTILS_SVH
/**
 * Test utilities to test different versions of the RISC-V CPU with the same
 * test benches.
 *
 */

/**
 * Waits for 'n' clock cycles.
 *
 */
`define WAIT_INSTR_C(clk, n)        repeat(n) @(posedge clk); #1

`ifdef CONFIG_RISCV_SINGLECYCLE
    `define MEM_DATA                dut.rv.data_mem._mem._mem
    `define MEM_INSTR               dut.rv.instr_mem._mem._mem

    /**
     * Index at which the data starts. Index means what index of the internal
     * memory matrix, therefore this is not the actual address. E.g. for a
     * 32 bit word based memory, indexes 0, 1, 2 will correspond to real
     * addresses 0, 4, 8.
     *
     */
    `define DATA_START_IDX          0

    /**
     * Same as @see{DATA_START_IDX} but fo the instruction memory.
     *
     */
    `define INSTR_START_IDX         0

    /**
     * Single cycle CPU intructions always take 1 clock cycle.
     *
     */
    `define WAIT_INSTR(clk)         @(posedge clk) #1
`elsif CONFIG_RISCV_MULTICYCLE
    `define MEM_DATA                dut.rv.id_mem._mem._mem
    `define MEM_INSTR               dut.rv.id_mem._mem._mem
    `define DATA_START_IDX          512
    `define INSTR_START_IDX         0

    /**
     * Multi cycle CPU intructions almost always take 4 clock cycles. In case
     * other number is required, use @see{WAIT_INSTR_C}
     *
     */
    `define WAIT_INSTR(clk)         repeat(4) @(posedge clk); #1
`endif

`endif // RISCV_TEST_UTILS_SVH
