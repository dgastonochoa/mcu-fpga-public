`ifndef DATAPATH_H
`define DATAPATH_H

/**
 * Immediate source. Indicates the type of instruction
 * as a function of how is the immediate encoded in it.
 */
typedef enum logic [3:0]
{
    IMM_SRC_ITYPE        = 4'b000,
    IMM_SRC_STYPE        = 4'b001,
    IMM_SRC_BTYPE        = 4'b010,
    IMM_SRC_JTYPE        = 4'b011,
    IMM_SRC_UTYPE        = 4'b100,

    // slli, srai and srli immediate is trated differently
    // from other I-type instructions (its extended must be
    // unsigned and it's only 5 bits length)
    IMM_SRC_ITYPE2       = 4'b101,

    IMM_SRC_NONE         = 4'hf
} imm_src_e;

/**
 * ALU's second operand source (register, immediate...)
 */
typedef enum logic [3:0]
{
    ALU_SRC_REG_1        = 4'b000,
    ALU_SRC_REG_2        = 4'b001,
    ALU_SRC_EXT_IMM      = 4'b010,
    ALU_SRC_PC           = 4'b011,
    ALU_SRC_4            = 4'b100,
    ALU_SRC_PC_OLD       = 4'b101,
    ALU_SRC_NONE         = 4'hf
} alu_src_e;

/**
 * Source of the result to be written in the register file.
 */
typedef enum logic [3:0]
{
    RES_SRC_ALU_OUT      = 4'b0000,
    RES_SRC_PC_PLUS_4    = 4'b0001,
    RES_SRC_EXT_IMM      = 4'b0010,
    RES_SRC_MEM          = 4'b0011,
    RES_SRC_NONE         = 4'hf
} res_src_e;

/**
 * Indicates the source of the next PC (+4, +offset...)
 */
typedef enum logic [3:0]
{
    PC_SRC_PLUS_4        = 4'b00,
    PC_SRC_PLUS_OFF      = 4'b01,
    PC_SRC_REG_PLUS_OFF  = 4'b10,
    PC_SRC_NONE          = 4'hf
} pc_src_e;

`ifdef CONFIG_RISCV_MULTICYCLE
/**
 * Indicates the source of the register file write pin
 */
typedef enum logic [3:0]
{
    RF_WD_SRC_RES       = 4'b00,
    RF_WD_SRC_PC        = 4'b01,
    RF_WD_SRC_IMM       = 4'b10,
    RF_WD_SRC_NONE      = 4'hf
} rf_wd_src_e;
`endif // CONFIG_RISCV_MULTICYCLE

`endif // RISCV_PARAMS_H
