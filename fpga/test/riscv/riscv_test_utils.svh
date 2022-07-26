`ifndef RISCV_TEST_UTILS_SVH
`define RISCV_TEST_UTILS_SVH
/**
 * Test utilities to test different versions of the RISC-V CPU with the same
 * test benches.
 *
 */

`ifdef CONFIG_RISCV_SINGLECYCLE
    /**
     * Work-arround the fact that SystemVerilog doesn't support statements like
     * `if defined(X) || defined(Y) ... `endif
     *
     */
    `define RISCV_ONE_CYCLE 1

    `define WAIT_INIT_CYCLES(clk)

`elsif CONFIG_RISCV_PIPELINE
    `define RISCV_ONE_CYCLE 1
    `define WAIT_INIT_CYCLES(clk)   `WAIT_INSTR_C(clk, 4)

`elsif CONFIG_RISCV_MULTICYCLE
    `define WAIT_INIT_CYCLES(clk)

`endif // CONFIG_RISCV_SINGLECYCLE

/**
 * Waits for 'n' clock cycles.
 *
 */
`define WAIT_INSTR_C(clk, n)        repeat(n) @(posedge clk); #1

`ifdef RISCV_ONE_CYCLE
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
    `define WAIT_INSTR(clk)         `WAIT_INSTR_C(clk, 1)

    /**
     * See CONFIG_RISCV_MULTICYCLE section in this file.
     *
     */
    `define L_I_CYC                 1
    `define S_I_CYC                 1
    `define R_I_CYC                 1
    `define I_I_CYC                 1
    `define B_I_CYC                 1
    `define J_I_CYC                 1
    `define U_I_CYC                 1

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
    `define WAIT_INSTR(clk)         `WAIT_INSTR_C(clk, 4)

    /**
     * Cycles required per instruction in multi-cycle CPU mode.
     *
     */
    `define L_I_CYC                 5   // load-type instr.
    `define S_I_CYC                 4   // store-type instr.
    `define R_I_CYC                 4   // r-type instr.
    `define I_I_CYC                 4   // i-type instr.
    `define B_I_CYC                 3   // b-type instr.
    `define J_I_CYC                 3   // j-type instr.
    `define U_I_CYC                 3   // u-type instr.
`endif

`endif // RISCV_TEST_UTILS_SVH
