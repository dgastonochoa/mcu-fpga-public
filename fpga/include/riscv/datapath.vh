`ifndef RISCV_PARAMS_H
`define RISCV_PARAMS_H

// datapath parameters

/**
 * Immediate source. Indicates the type of instruction
 * as a function of how is the immediate encoded in it.
 */
localparam imm_src_itype        = 3'b000;
localparam imm_src_stype        = 3'b001;
localparam imm_src_btype        = 3'b010;
localparam imm_src_jtype        = 3'b011;

/**
 * ALU's second operand source (register, immediate...)
 */
localparam alu_src_reg          = 2'b00;
localparam alu_src_ext_imm      = 2'b01;

/**
 * Source of the result to be written in the register file.
 */
localparam res_src_alu_out      = 2'b00;
localparam res_src_read_data    = 2'b01;
localparam res_src_pc_plus_4    = 2'b10;

/**
 * Indicates the source of the next PC (+4, +offset...)
 */
localparam pc_src_plus_4        = 2'b00;
localparam pc_src_plus_off      = 2'b01;
localparam pc_src_reg_plus_off  = 2'b10;

`endif // RISCV_PARAMS_H
