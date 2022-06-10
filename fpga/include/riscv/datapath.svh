`ifndef DATAPATH_H
`define DATAPATH_H

/**
 * Immediate source. Indicates the type of instruction
 * as a function of how is the immediate encoded in it.
 */
typedef enum logic [2:0]
{
    IMM_SRC_ITYPE        = 3'b000,
    IMM_SRC_STYPE        = 3'b001,
    IMM_SRC_BTYPE        = 3'b010,
    IMM_SRC_JTYPE        = 3'b011,
    IMM_SRC_UTYPE        = 3'b100,

    // slli, srai and srli immediate is trated differently
    // from other I-type instructions (its extended must be
    // unsigned and it's only 5 bits length)
    IMM_SRC_ITYPE2       = 3'b101

} imm_src_e;

/**
 * ALU's second operand source (register, immediate...)
 */
typedef enum logic [1:0]
{
    ALU_SRC_REG          = 2'b00,
    ALU_SRC_EXT_IMM      = 2'b01,
    ALU_SRC_PC_EXT_IMM   = 2'b10
} alu_src_e;

/**
 * Source of the result to be written in the register file.
 */
typedef enum logic [3:0]
{
    RES_SRC_ALU_OUT      = 4'b0000,
    RES_SRC_PC_PLUS_4    = 4'b0010,
    RES_SRC_MEM_BYTE     = 4'b00_01,
    RES_SRC_MEM_HALF     = 4'b01_01,
    RES_SRC_MEM_WORD     = 4'b10_01,
    RES_SRC_X            = 4'bx
} res_src_e;

/**
 * Indicates the source of the next PC (+4, +offset...)
 */
typedef enum logic [1:0]
{
    PC_SRC_PLUS_4        = 2'b00,
    PC_SRC_PLUS_OFF      = 2'b01,
    PC_SRC_REG_PLUS_OFF  = 2'b10
} pc_src_e;

`endif // RISCV_PARAMS_H
