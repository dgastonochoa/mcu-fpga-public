`ifndef RISCV_PARAMS_H
`define RISCV_PARAMS_H

// datapath parameters
localparam imm_src_itype        = 2'b00;
localparam imm_src_stype        = 2'b01;
localparam imm_src_btype        = 2'b10;

localparam alu_src_ext_imm      = 1'b1;
localparam alu_src_reg          = 1'b0;

localparam res_src_read_data    = 1'b1;
localparam res_src_alu_out      = 1'b0;

localparam pc_src_plus_4        = 1'b0;
localparam pc_src_plus_off      = 1'b1;

`endif // RISCV_PARAMS_H
