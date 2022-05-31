`ifndef RISCV_PARAMS_H
`define RISCV_PARAMS_H

// datapath parameters

/**
 * Immediate source. Indicates the type of instruction
 * as a function of how is the immediate encoded in it.
 */
localparam imm_src_itype        = 2'b00;
localparam imm_src_stype        = 2'b01;
localparam imm_src_btype        = 2'b10;
localparam imm_src_jtype        = 2'b11;

/**
 * ALU's second operand source (register, immediate...)
 */
localparam alu_src_reg          = 1'b0;
localparam alu_src_ext_imm      = 1'b1;

/**
 * Source of the result to be written in the register file.
 */
localparam res_src_alu_out      = 2'b0;
localparam res_src_read_data    = 2'b1;
localparam res_src_pc_plus_4    = 2'b10;

/**
 * Indicates the source of the next PC (+4, +offset...)
 */
localparam pc_src_plus_4        = 2'b00;
localparam pc_src_plus_off      = 2'b01;

`endif // RISCV_PARAMS_H
