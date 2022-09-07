`ifndef RISCV_TEST_UTILS_SVH
`define RISCV_TEST_UTILS_SVH
/**
 * Test utilities to test different versions of the RISC-V CPU with the same
 * test benches.
 *
 */

`include "test_utils.svh"

`include "riscv/test/test_cpu.svh"
`include "riscv/test/test_cpu_mem.svh"
`include "riscv/test/test_mcu.svh"


`ifdef CONFIG_RISCV_SINGLECYCLE
    /**
     * Number of clock cycles that each instruction's execution takes.
     *
     */
    `define L_I_CYC                 1 // load-type instr.
    `define S_I_CYC                 1 // store-type instr.
    `define R_I_CYC                 1 // r-type instr.
    `define I_I_CYC                 1 // i-type instr.
    `define B_I_CYC                 1 // b-type instr.
    `define J_I_CYC                 1 // j-type instr.
    `define U_I_CYC                 1 // u-type instr.

    /**
     * Number of clock cycles to wait before the CPU can execute the first
     * instruction.
     *
     */
    `define WAIT_INIT_CYCLES(clk)

`elsif CONFIG_RISCV_PIPELINE

    `define L_I_CYC                 1
    `define S_I_CYC                 1
    `define R_I_CYC                 1
    `define I_I_CYC                 1
    `define B_I_CYC                 1
    `define J_I_CYC                 1
    `define U_I_CYC                 1

    `define WAIT_INIT_CYCLES(clk)   `WAIT_CLKS(clk, 4)

`elsif CONFIG_RISCV_MULTICYCLE

    `define L_I_CYC                 5
    `define S_I_CYC                 4
    `define R_I_CYC                 4
    `define I_I_CYC                 4
    `define B_I_CYC                 3
    `define J_I_CYC                 3
    `define U_I_CYC                 3

    `define WAIT_INIT_CYCLES(clk)

`endif // CONFIG_RISCV_SINGLECYCLE

`endif // RISCV_TEST_UTILS_SVH
