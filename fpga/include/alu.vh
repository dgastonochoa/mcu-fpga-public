`ifndef ALU_H
`define ALU_H

localparam alu_op_add = 4'b0000;
localparam alu_op_sub = 4'b0001;
localparam alu_op_and = 4'b0010;
localparam alu_op_or  = 4'b0011;
localparam alu_op_xor = 4'b0100;
localparam alu_op_sll = 4'b0101;
localparam alu_op_srl = 4'b0110;
localparam alu_op_sra = 4'b0111;

`endif // ALU_H