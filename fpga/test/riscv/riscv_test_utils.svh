`ifndef RISCV_TEST_UTILS_SVH
`define RISCV_TEST_UTILS_SVH
/**
 * Test utilities to test different versions of the RISC-V CPU with the same
 * test benches.
 *
 */

`include "test_utils.svh"


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

`define __GET_REG_X0(rf)        \
    wire [31:0] x0;             \
    assign x0 = rf._reg[0]

`define __GET_REG_RA(rf)        \
    wire [31:0] ra;             \
    assign ra = rf._reg[1]

`define __GET_REG_SP(rf)        \
    wire [31:0] sp;             \
    assign sp = rf._reg[2]

`define __GET_REG_GP(rf)        \
    wire [31:0] gp;             \
    assign gp = rf._reg[3]

`define __GET_REG_TP(rf)        \
    wire [31:0] tp;             \
    assign tp = rf._reg[4]

`define __GET_REG_T0(rf)        \
    wire [31:0] t0;             \
    assign t0 = rf._reg[5]

`define __GET_REG_T1(rf)        \
    wire [31:0] t1;             \
    assign t1 = rf._reg[6]

`define __GET_REG_T2(rf)        \
    wire [31:0] t2;             \
    assign t2 = rf._reg[7]

`define __GET_REG_S0(rf)        \
    wire [31:0] s0;             \
    assign s0 = rf._reg[8]

`define __GET_REG_S1(rf)        \
    wire [31:0] s1;             \
    assign s1 = rf._reg[9]

`define __GET_REG_A0(rf)        \
    wire [31:0] a0;             \
    assign a0 = rf._reg[10]

`define __GET_REG_A1(rf)        \
    wire [31:0] a1;             \
    assign a1 = rf._reg[11]

`define __GET_REG_A2(rf)        \
    wire [31:0] a2;             \
    assign a2 = rf._reg[12]

`define __GET_REG_A3(rf)        \
    wire [31:0] a3;             \
    assign a3 = rf._reg[13]

`define __GET_REG_A4(rf)        \
    wire [31:0] a4;             \
    assign a4 = rf._reg[14]

`define __GET_REG_A5(rf)        \
    wire [31:0] a5;             \
    assign a5 = rf._reg[15]

`define __GET_REG_A6(rf)        \
    wire [31:0] a6;             \
    assign a6 = rf._reg[16]

`define __GET_REG_A7(rf)        \
    wire [31:0] a7;             \
    assign a7 = rf._reg[17]

`define __GET_REG_S2(rf)        \
    wire [31:0] s2;             \
    assign s2 = rf._reg[18]

`define __GET_REG_S3(rf)        \
    wire [31:0] s3;             \
    assign s3 = rf._reg[19]

`define __GET_REG_S4(rf)        \
    wire [31:0] s4;             \
    assign s4 = rf._reg[20]

`define __GET_REG_S5(rf)        \
    wire [31:0] s5;             \
    assign s5 = rf._reg[21]

`define __GET_REG_S6(rf)        \
    wire [31:0] s6;             \
    assign s6 = rf._reg[22]

`define __GET_REG_S7(rf)        \
    wire [31:0] s7;             \
    assign s7 = rf._reg[23]

`define __GET_REG_S8(rf)        \
    wire [31:0] s8;             \
    assign s8 = rf._reg[24]

`define __GET_REG_S9(rf)        \
    wire [31:0] s9;             \
    assign s9 = rf._reg[25]

`define __GET_REG_S10(rf)       \
    wire [31:0] s10;            \
    assign s10 = rf._reg[26]

`define __GET_REG_S11(rf)       \
    wire [31:0] s11;            \
    assign s11 = rf._reg[27]

`define __GET_REG_T3(rf)        \
    wire [31:0] t3;             \
    assign t3 = rf._reg[28]

`define __GET_REG_T4(rf)        \
    wire [31:0] t4;             \
    assign t4 = rf._reg[29]

`define __GET_REG_T5(rf)        \
    wire [31:0] t5;             \
    assign t5 = rf._reg[30]

`define __GET_REG_T6(rf)        \
    wire [31:0] t6;             \
    assign t6 = rf._reg[31]


`endif // RISCV_TEST_UTILS_SVH
