`ifndef RISCV_PARAMS_H
`define RISCV_PARAMS_H

// datapath parameters
localparam alu_src_ext_imm      = 1'b1;
localparam alu_src_reg          = 1'b0;

localparam res_src_read_data    = 1'b1;
localparam res_src_alu_out      = 1'b0;

`endif // RISCV_PARAMS_H