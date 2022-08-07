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
`define WAIT_CLKS(clk, n)           repeat(n) @(posedge clk); #1


`ifdef CONFIG_RISCV_SINGLECYCLE
    /**
     * Data storage memory
     *
     */
    `define MEM_DATA                dut.rv.data_mem._mem._mem

    /**
     * Instructions storage memory
     *
     */
    `define MEM_INSTR               dut.rv.instr_mem._mem._mem

    /**
     * Index (word), in memory, at which the data starts. This is required when
     * data and instructions are stored in the same memory.
     *
     */
    `define DATA_START_IDX          0

    /**
     * Index (word), in memory, at which the instructions start. This is required
     * when data and instructions are stored in the same memory.
     *
     */
    `define INSTR_START_IDX         0

    /**
     * Number of clock cycles that each instruction's execution takes.
     *
     */
    `define L_I_CYC                 1
    `define S_I_CYC                 1
    `define R_I_CYC                 1
    `define I_I_CYC                 1
    `define B_I_CYC                 1
    `define J_I_CYC                 1
    `define U_I_CYC                 1

    /**
     * Number of clock cycles to wait before the CPU can execute the first
     * instruction.
     *
     */
    `define WAIT_INIT_CYCLES(clk)

`elsif CONFIG_RISCV_PIPELINE
    `define MEM_DATA                dut.rv.data_mem._mem._mem
    `define MEM_INSTR               dut.rv.instr_mem._mem._mem
    `define DATA_START_IDX          0
    `define INSTR_START_IDX         0

    `define L_I_CYC                 1
    `define S_I_CYC                 1
    `define R_I_CYC                 1
    `define I_I_CYC                 1
    `define B_I_CYC                 1
    `define J_I_CYC                 1
    `define U_I_CYC                 1

    `define WAIT_INIT_CYCLES(clk)   `WAIT_CLKS(clk, 4)

`elsif CONFIG_RISCV_MULTICYCLE
    `define MEM_DATA                dut.rv.id_mem._mem._mem
    `define MEM_INSTR               dut.rv.id_mem._mem._mem
    `define DATA_START_IDX          512
    `define INSTR_START_IDX         0

    `define L_I_CYC                 5   // load-type instr.
    `define S_I_CYC                 4   // store-type instr.
    `define R_I_CYC                 4   // r-type instr.
    `define I_I_CYC                 4   // i-type instr.
    `define B_I_CYC                 3   // b-type instr.
    `define J_I_CYC                 3   // j-type instr.
    `define U_I_CYC                 3   // u-type instr.

    `define WAIT_INIT_CYCLES(clk)

`endif // CONFIG_RISCV_SINGLECYCLE


`define __GET_MEM(mem, off, idx)        mem[off+idx]
`define __SET_MEM(mem, off, idx, data)  `__GET_MEM(mem, off, idx) = data

/**
 * Set 'data', in data memory, at index 'idx'.
 *
 */
`define SET_MEM_D(idx, data)    \
    `__SET_MEM(`MEM_DATA, `DATA_START_IDX, idx, data)

/**
 * Set 'instr', in instruction memory, at index 'idx'.
 *
 */
`define SET_MEM_I(idx, instr)   \
    `__SET_MEM(`MEM_INSTR, `INSTR_START_IDX, idx, instr)

`define GET_MEM_D(idx)      \
    `__GET_MEM(`MEM_DATA, `DATA_START_IDX, idx)

`define GET_MEM_I(idx)      \
    `__GET_MEM(`MEM_INSTR, `INSTR_START_IDX, idx)

`endif // RISCV_TEST_UTILS_SVH
