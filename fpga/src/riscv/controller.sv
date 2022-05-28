`include "riscv/datapath.vh"

localparam op_i_type_l = 7'b0000011;
localparam op_i_type = 7'b0010011;
localparam op_s_type = 7'b0100011;
localparam op_r_type = 7'b0110011;
localparam op_b_type = 7'b1100011;
localparam op_j_type = 7'b1101111;

/**
 * Decodes the ALU control (op. to perform) based on the inputs
 *
 */
module alu_dec(
    input   wire    [6:0] op,
    input   wire    [2:0] func3,
    input   wire    [6:0] func7,
    output  logic   [2:0] alu_ctrl
);
    logic [2:0] r_type_alu_ctr;

    always_comb begin
        case (func3)
        3'b000: r_type_alu_ctr = func7 == 7'b0 ? alu_op_add : alu_op_sub;
        3'b110: r_type_alu_ctr = alu_op_or;
        3'b111: r_type_alu_ctr = alu_op_and;
        3'b100: r_type_alu_ctr = alu_op_xor;
        3'b001: r_type_alu_ctr = alu_op_sll;
        3'b101: r_type_alu_ctr = alu_op_srl;
        default: r_type_alu_ctr = 3'bx;
        endcase
    end

    always_comb begin
        case (op)
        op_r_type:      alu_ctrl = r_type_alu_ctr;
        op_i_type:      alu_ctrl = alu_op_add;
        op_i_type_l:    alu_ctrl = alu_op_add;
        op_s_type:      alu_ctrl = alu_op_add;
        op_b_type:      alu_ctrl = alu_op_sub;
        default:        alu_ctrl = 3'bx;
        endcase
    end
endmodule

/**
 * Outputs the CPU control signals based on the received instruction
 * and flags.
 *
 * @param instr Instruction
 * @param alu_zero ALU zero flag
 * @param reg_we Register file write enable
 * @param mem_we Memory write enable
 * @param alu_src ALU's second operand source (register, immediate...)
 * @param result_src Source of the result to be written in the register file.
 * @param pc_src Source of the next program counter (+4, +offset...)
 * @param imm_src Indicates the type of instr. with regards to how
 *                its immediate is stored
 *
 * @param alu_ctrl Operation to be performed by the ALU
 */
module controller(
    input   wire [31:0] instr,
    input   wire        alu_zero,

    output  wire        reg_we,
    output  wire        mem_we,

    output  wire        alu_src,
    output  wire [1:0]  result_src,
    output  wire        pc_src,
    output  wire [1:0]  imm_src,

    output  wire [2:0]  alu_ctrl
);
    wire [6:0] op;
    wire [2:0] func3;
    wire [6:0] func7;
    logic [9:0] ctrls;
    wire pc_src_beq;

    alu_dec ad(op, func3, func7, alu_ctrl);

    assign op = instr[6:0];
    assign func3 = instr[14:12];
    assign func7 = instr[31:25];
    assign {reg_we, mem_we, alu_src, result_src, pc_src, imm_src} = ctrls;
    assign pc_src_beq = alu_zero ? pc_src_plus_off : pc_src_plus_4;

    always_comb begin
        case (op)
        //                       reg_we  mem_we  alu_src            result_src        pc_src            imm_src
        op_i_type_l:    ctrls = {1'b1,  1'b0,    alu_src_ext_imm, res_src_read_data, pc_src_plus_4,     imm_src_itype};
        op_i_type:      ctrls = {1'b1,  1'b0,    alu_src_ext_imm, res_src_alu_out,   pc_src_plus_4,     imm_src_itype};
        op_s_type:      ctrls = {1'b0,  1'b1,    alu_src_ext_imm, res_src_read_data, pc_src_plus_4,     imm_src_stype};
        op_r_type:      ctrls = {1'b1,  1'b0,    alu_src_reg,     res_src_alu_out,   pc_src_plus_4,     2'bx         };
        op_b_type:      ctrls = {1'b0,  1'b0,    alu_src_reg,     2'bx,              pc_src_beq,        imm_src_btype};
        op_j_type:      ctrls = {1'b1,  1'b0,    1'bx,            res_src_pc_plus_4, pc_src_plus_off,   imm_src_jtype};
        default:        ctrls = 10'bx;
        endcase
    end
endmodule
