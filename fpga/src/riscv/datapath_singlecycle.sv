`include "riscv/datapath.svh"

/**
 * CPU datapath.
 *
 * @param instr Instruction to be executed.
 * @param read_data Data read from memory.
 * @param reg_we Register write enable. Synchronous (pos. edge)
 * @param imm_src Type of immediate depending on the instruction.
 *                  0 = I-Type instruction
 *                  1 = S-Type instruction
 *
 * @param alu_ctrl Operation that the ALU will perform. See alu.vh.
 * @param alu_src_a ALU's first operand source. See datapath.vh.
 * @param alu_src_b ALU's second operand source. See datapath.vh.
 * @param result_src Source of the result to be written in the reg. file.
 *                   See datapath.vh.
 *
 * @param pc_src Program counter src. Determines which value will be used to
 *               update the program counter for the next cycle.
 *
 * @param pc Program counter.
 * @param alu_out ALU output.
 * @param alu_flags Flags produced by the ALU
 * @param write_data Data to be written in memory.
 * @param rst Async. reset.
 * @param clk Clock signal
 */
module datapath(
    input   wire [31:0] instr,

    input   wire [31:0] read_data,
    input   wire        reg_we,

    input   imm_src_e   imm_src,
    input   alu_op_e    alu_ctrl,
    input   alu_src_e   alu_src_a,
    input   alu_src_e   alu_src_b,
    input   res_src_e   result_src,
    input   pc_src_e    pc_src,

    output  wire [31:0] pc,

    output  wire [31:0] alu_out,
    output  wire [3:0]  alu_flags,
    output  wire [31:0] write_data,

    input   wire        rst,
    input   wire        clk
);
    //
    // Next PC logic
    //
    wire    [31:0] pc_plus_4;
    wire    [31:0] pc_plus_off;
    wire    [31:0] pc_reg_plus_off;
    logic   [31:0] pc_next;

    assign pc_plus_4 = pc + 4;
    assign pc_plus_off = pc + ext_imm;
    assign pc_reg_plus_off = reg_rd1 + ext_imm;

    always_comb begin
        case (pc_src)
        PC_SRC_PLUS_4:          pc_next = pc_plus_4;
        PC_SRC_PLUS_OFF:        pc_next = pc_plus_off;
        PC_SRC_REG_PLUS_OFF:    pc_next = pc_reg_plus_off;
        default:                pc_next = 32'hffffffff;
        endcase
    end

    dff pc_ff(pc_next, 1'b1, pc, clk, rst);


    //
    // Register file logic
    //
    wire    [31:0] reg_rd1;
    wire    [31:0] reg_rd2;
    logic   [31:0] reg_wr_data;

    always_comb begin
        case (result_src)
        RES_SRC_ALU_OUT:    reg_wr_data = alu_out;
        RES_SRC_PC_PLUS_4:  reg_wr_data = pc_plus_4;
        RES_SRC_EXT_IMM:    reg_wr_data = ext_imm;
        RES_SRC_MEM:        reg_wr_data = read_data;
        default:            reg_wr_data = 32'hffffffff;
        endcase
    end

    regfile rf(instr[19:15], instr[24:20], instr[11:7], reg_wr_data, reg_we, reg_rd1, reg_rd2, clk);

    assign write_data = reg_rd2;



    //
    // ALU and extender logic
    //
    wire    [31:0] ext_imm;

    extend ext(instr, imm_src, ext_imm);


    logic   [31:0] alu_op_a;
    logic   [31:0] alu_op_b;

    always_comb begin
        case (alu_src_a)
        ALU_SRC_REG_1:   alu_op_a = reg_rd1;
        ALU_SRC_REG_2:   alu_op_a = reg_rd2;
        ALU_SRC_EXT_IMM: alu_op_a = ext_imm;
        ALU_SRC_PC:      alu_op_a = pc;
        default:         alu_op_a = 32'hffffffff;
        endcase
    end

    always_comb begin
        case (alu_src_b)
        ALU_SRC_REG_1:   alu_op_b = reg_rd1;
        ALU_SRC_REG_2:   alu_op_b = reg_rd2;
        ALU_SRC_EXT_IMM: alu_op_b = ext_imm;
        ALU_SRC_PC:      alu_op_b = pc;
        default:         alu_op_b = 32'hffffffff;
        endcase
    end

    alu alu0(alu_op_a, alu_op_b, alu_ctrl, alu_out, alu_flags);
endmodule
