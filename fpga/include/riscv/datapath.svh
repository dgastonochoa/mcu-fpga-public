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
    IMM_SRC_UTYPE        = 3'b100
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
typedef enum logic [1:0]
{
    RES_SRC_ALU_OUT      = 2'b00,
    RES_SRC_READ_DATA    = 2'b01,
    RES_SRC_PC_PLUS_4    = 2'b10
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
