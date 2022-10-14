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
module datapath_multicycle(
    input   wire      [31:0] m_rd,
    input   wire             rf_we,

    input   imm_src_e        imm_src,
    input   alu_op_e         alu_ctrl,
    input   alu_src_e        alu_src_a,
    input   alu_src_e        alu_src_b,
    input   res_src_e        res_src,

    input   wire             addr_src,
    input   wire             en_ir,
    input   wire             en_npc_r,
    input   wire             en_oldpc_r,
    input   rf_wd_src_e      rf_wd_src,

    output  wire      [31:0] m_addr,
    output  wire      [3:0]  alu_flags,
    output  wire      [31:0] m_wd,
    output  wire      [31:0] instr,
    output  wire      [31:0] pc,

    input   wire             clk,
    input   wire             rst
);
    //
    // Result
    //
    logic [31:0] result;

    always_comb begin
        case (res_src)
        RES_SRC_ALU_OUT: result = alu_out_r;
        RES_SRC_MEM:     result = m_rd_r;
        default:         result = 32'hffffffff;
        endcase
    end


    //
    // PC
    //
    wire [31:0] pc_next, pc_old;

    assign pc_next = result;

    dff pc_ff(pc_next, en_npc_r, pc, clk, rst);
    dff pc_old_ff(pc, en_oldpc_r, pc_old, clk, rst);


    //
    // Memory
    //
    wire [31:0] m_rd_r;

    dff mem_rd_r(m_rd, 1'b1, m_rd_r, clk, rst);

    assign m_addr = (addr_src == 1'b0 ? pc : result);


    //
    // Register file
    //
    dff i_r(m_rd, en_ir, instr, clk, rst);

    wire    [31:0] reg_rd1;
    wire    [31:0] reg_rd2;
    logic   [31:0] reg_wd3;

    always_comb begin
        case (rf_wd_src)
        RF_WD_SRC_RES:  reg_wd3 = result;
        RF_WD_SRC_PC:   reg_wd3 = pc;
        RF_WD_SRC_IMM:  reg_wd3 = ext_imm;
        RF_WD_SRC_NONE: reg_wd3 = 32'hffffffff;
        default:        reg_wd3 = 32'hffffffff;
        endcase
    end

    regfile rf(instr[19:15], instr[24:20], instr[11:7], reg_wd3, rf_we, reg_rd1, reg_rd2, clk);

    wire [31:0] rd1, rd2;

    dff rd_rd1_r(reg_rd1, 1'b1, rd1, clk, rst);
    dff rd_rd2_r(reg_rd2, 1'b1, rd2, clk, rst);

    assign m_wd = rd2;


    //
    // Extender
    //
    wire [31:0] ext_imm;

    extend ext(instr, imm_src, ext_imm);


    //
    // ALU
    //
    logic   [31:0] alu_op_a;
    logic   [31:0] alu_op_b;
    wire    [31:0] alu_out;

    always_comb begin
        case (alu_src_a)
        ALU_SRC_REG_1:   alu_op_a = rd1;
        ALU_SRC_REG_2:   alu_op_a = rd2;
        ALU_SRC_EXT_IMM: alu_op_a = ext_imm;
        ALU_SRC_PC:      alu_op_a = pc;
        ALU_SRC_PC_OLD:  alu_op_a = pc_old;
        ALU_SRC_4:       alu_op_a = 32'd4;
        default:         alu_op_a = 32'hffffffff;
        endcase
    end

    always_comb begin
        case (alu_src_b)
        ALU_SRC_REG_1:   alu_op_b = rd1;
        ALU_SRC_REG_2:   alu_op_b = rd2;
        ALU_SRC_EXT_IMM: alu_op_b = ext_imm;
        ALU_SRC_PC:      alu_op_b = pc;
        ALU_SRC_PC_OLD:  alu_op_b = pc_old;
        ALU_SRC_4:       alu_op_b = 32'd4;
        default:         alu_op_b = 32'hffffffff;
        endcase
    end

    alu alu0(alu_op_a, alu_op_b, alu_ctrl, alu_out, alu_flags);

    wire [31:0] alu_out_r;

    dff alu_out_reg(alu_out, 1'b1, alu_out_r, clk, rst);
endmodule
