`include "riscv/controller.svh"

/**
 * Instruction field accessors
 *
 */
`define OP 6:0
`define F3 14:12
`define F7 31:25
`define A1 19:15
`define A2 24:20
`define A3 11:7

typedef enum logic [3:0]
{
    FORW_NO         = 4'd0,
    FORW_ALU_OUT_M  = 4'd1,
    FORW_ALU_OUT_W  = 4'd2
} forward_type_e;

module forward_dec(
    input  wire [4:0]      rf_src_e,
    input  wire [4:0]      rf_dst_m,
    input  wire [4:0]      rf_dst_w,
    input  wire            rf_we_m,
    input  wire            rf_we_w,
    output forward_type_e  fw_t
);
    wire nz, fw_alu_out_m, fw_alu_out_w;

    assign nz           = (rf_src_e != 5'd0);
    assign fw_alu_out_m = rf_we_m & (rf_src_e == rf_dst_m);
    assign fw_alu_out_w = rf_we_w & (rf_src_e == rf_dst_w);

    wire [2:0] flags;

    assign flags = {nz, fw_alu_out_m, fw_alu_out_w};

    always_comb begin
        case (flags)
        3'b110:  fw_t = FORW_ALU_OUT_M;
        3'b101:  fw_t = FORW_ALU_OUT_W;
        3'b111:  fw_t = FORW_ALU_OUT_M;
        default: fw_t = FORW_NO;
        endcase
    end
endmodule

module hazard_ctrl(
    input  wire [4:0]       a1_d,
    input  wire [4:0]       a2_d,
    input  wire [4:0]       a1_e,
    input  wire [4:0]       a2_e,
    input  wire [4:0]       a3_e,
    input  wire [4:0]       a3_m,
    input  wire [4:0]       a3_w,
    input  wire             rf_we_m,
    input  wire             rf_we_w,
    input  res_src_e        result_src_e,
    input  pc_src_e         ps_e,
    output forward_type_e   fw_type_a,
    output forward_type_e   fw_type_b,
    output logic            stall,
    output wire             flush
);
    forward_dec fda(a1_e, a3_m, a3_w, rf_we_m, rf_we_w, fw_type_a);
    forward_dec fdb(a2_e, a3_m, a3_w, rf_we_m, rf_we_w, fw_type_b);

    assign stall =
        (result_src_e == RES_SRC_MEM) && ((a3_e == a1_d) || (a3_e == a2_d));

    assign flush = ps_e != PC_SRC_PLUS_4;
endmodule

module alu_operand_dec(
    input  alu_src_e      oper_src,
    input  forward_type_e fw_t,
    input  wire  [31:0]   rf_rd,
    input  wire  [31:0]   ext_imm,
    input  wire  [31:0]   pc,
    input  wire  [31:0]   alu_out_m,
    input  wire  [31:0]   wd3,
    output logic [31:0]   alu_oper
);
    logic [31:0] rd;

    always_comb begin
        case (fw_t)
        FORW_NO:        rd = rf_rd;
        FORW_ALU_OUT_M: rd = alu_out_m;
        FORW_ALU_OUT_W: rd = wd3;
        default:        rd = 32'hffffffff;
        endcase
    end

    // TODO possibly ALU_SRC_REG_2 should not exist:
    // alu_op_a can never be assigned to rd2, neither can
    // alu_op_b be assigned to rd1.
    always_comb begin
        case (oper_src)
        ALU_SRC_REG_1:   alu_oper = rd;
        ALU_SRC_REG_2:   alu_oper = rd;
        ALU_SRC_EXT_IMM: alu_oper = ext_imm;
        ALU_SRC_PC:      alu_oper = pc;
        default:         alu_oper = 32'hffffffff;
        endcase
    end
endmodule

module branch_dec(
    input  wire     [6:0] op,
    input  wire     [2:0] func3,
    input  wire     [3:0] alu_flags,
    output pc_src_e       pc_src
);
    wire alu_ov, alu_cout, alu_zero, alu_neg;
    logic [3:0] pc_src_b_type;

    assign {alu_neg, alu_zero, alu_cout, alu_ov} = alu_flags[3:0];

    always_comb begin
        case (func3)
        3'b000: pc_src_b_type = alu_zero ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;             // beq
        3'b001: pc_src_b_type = alu_zero ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;             // bne
        3'b100: pc_src_b_type = (alu_neg ^ alu_ov) ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;   // blt
        3'b101: pc_src_b_type = (alu_neg ^ alu_ov) ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;   // bge
        3'b110: pc_src_b_type = alu_cout ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;             // bltu
        3'b111: pc_src_b_type = alu_cout ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;             // bgeu
        default: pc_src_b_type = PC_SRC_NONE;
        endcase
    end

    assign pc_src = (op == OP_B_TYPE ? pc_src_b_type : PC_SRC_PLUS_4);
endmodule

/**
 * CPU datapath.
 *
 * @param i Instruction to be executed.
 * @param mem_rd Data read from memory.
 * @param rf_we Register write enable. Synchronous (pos. edge)
 * @param imm_src Type of immediate depending on the instruction.
 *                  0 = I-Type instruction
 *                  1 = S-Type instruction
 *
 * @param alu_ctrl Operation that the ALU will perform. See alu.vh.
 * @param alu_src ALU's second operand source. See datapath.vh.
 * @param result_src Source of the result to be written in the reg. file.
 *                   See datapath.vh.
 *
 * @param alu_out ALU output.
 * @param write_data Data to be written in memory.
 * @param rst Reset.
 * @param clk Clock signal
 *
 */
module datapath(
    input   wire [31:0] i,

    input   wire [31:0] mem_rd,
    input   wire        rf_we,

    input   imm_src_e   imm_src,
    input   alu_op_e    alu_ctrl,
    input   alu_src_e   alu_src_a,
    input   alu_src_e   alu_src_b,
    input   res_src_e   result_src,
    input   pc_src_e    pc_src,

    output  wire [31:0] pc,

    output  wire [31:0] mem_wd,
    output  wire [3:0]  alu_flags,
    output  wire [31:0] write_data,

    input   wire        rst,
    input   wire        clk
);
    //
    // Controller pipelined signals
    //
    localparam CTRL_LEN = 6*4 + 1;

    imm_src_e is_d,   is_e,   is_m,   is_w;
    alu_op_e  ac_d,   ac_e,   ac_m,   ac_w;
    alu_src_e as_a_d, as_a_e, as_a_m, as_a_w;
    alu_src_e as_b_d, as_b_e, as_b_m, as_b_w;
    res_src_e rs_d,   rs_e,   rs_m,   rs_w;
    pc_src_e  ps_d,   ps_e,   ps_m,   ps_w;
    wire      rwe_d,  rwe_e,  rwe_m,  rwe_w;


    //
    // Fetch
    //
    wire stall;
    wire [31:0] pc_plus_4_f, pc_plus_off_e, pc_reg_plus_off_e;
    logic [31:0] pc_next;

    assign pc_plus_4_f = pc + 4;

    always_comb begin
        case (pcs_e)
        PC_SRC_PLUS_4:          pc_next = pc_plus_4_f;
        PC_SRC_PLUS_OFF:        pc_next = pc_plus_off_e;
        PC_SRC_REG_PLUS_OFF:    pc_next = pc_reg_plus_off_e;
        default:                pc_next = 32'hffffffff;
        endcase
    end

    dff dff_f(pc_next, ~stall, pc, clk, rst);


    //
    // Decode
    //
    wire flush;
    wire [31:0] pc_d, i_d, pc_plus_4_d, rd1_d, rd2_d, ext_imm_d;
    wire [4:0] a3_w;
    logic [31:0] wd3;

    clear_dff #(.N(CTRL_LEN)) dff_c_d(
        {imm_src, alu_ctrl, alu_src_a, alu_src_b, result_src, pc_src, rf_we},
        ~stall,
        {is_d,    ac_d,     as_a_d,    as_b_d,    rs_d,       ps_d,   rwe_d},
        flush,
        clk,
        rst
    );

    clear_dff #(.N(32*3)) dff_d(
        {pc,    i,   pc_plus_4_f},
        ~stall,
        {pc_d,  i_d, pc_plus_4_d},
        flush,
        clk,
        rst
    );

    regfile #(.EDGE(0)) rf(i_d[`A1], i_d[`A2], i_w[`A3], wd3, rwe_w, rd1_d, rd2_d, clk);

    extend ext(i_d, is_d, ext_imm_d);


    //
    // Execute
    //
    wire [31:0] rd1_e, rd2_e, pc_e, ext_imm_e, pc_plus_4_e, i_e;
    wire [31:0] alu_op_a_e, alu_op_b_e, alu_out_e;
    pc_src_e pcs_e;

    clear_dff #(.N(CTRL_LEN)) dff_c_e(
        {is_d, ac_d, as_a_d, as_b_d, rs_d, ps_d, rwe_d},
        ~stall,
        {is_e, ac_e, as_a_e, as_b_e, rs_e, ps_e, rwe_e},
        flush,
        clk,
        rst
    );

    clear_dff #(.N(32*6)) dff_e(
        {rd1_d, rd2_d,  pc_d, ext_imm_d, pc_plus_4_d, i_d},
        1'b1,
        {rd1_e, rd2_e,  pc_e, ext_imm_e, pc_plus_4_e, i_e},
        stall | flush,
        clk,
        rst
    );

    alu alu0(alu_op_a_e, alu_op_b_e, ac_e, alu_out_e, alu_flags);

    branch_dec bd(i_e[`OP], i_e[`F3], alu_flags, pcs_e);

    assign pc_plus_off_e = pc_e + ext_imm_e;
    assign pc_reg_plus_off_e = rd1_e + ext_imm_e;


    //
    // Mem. read/write
    //
    wire [31:0] alu_out_m, write_data_m, pc_plus_4_m, ext_imm_m, i_m;

    dff #(.N(CTRL_LEN)) dff_c_m(
        {is_e, ac_e, as_a_e, as_b_e, rs_e, ps_e, rwe_e},
        1'b1,
        {is_m, ac_m, as_a_m, as_b_m, rs_m, ps_m, rwe_m},
        clk,
        rst
    );

    dff #(.N(32*5)) dff_m(
        {alu_out_e, rd2_e,          pc_plus_4_e,    ext_imm_e,  i_e},
        1'b1,
        {alu_out_m, write_data_m,   pc_plus_4_m,    ext_imm_m,  i_m},
        clk,
        rst
    );

    assign mem_wd = alu_out_m;
    assign write_data = write_data_m;


    //
    // Write register
    //
    wire [31:0] pc_plus_4_w, alu_out_w, ext_imm_w, mem_rd_w, i_w;

    dff #(.N(CTRL_LEN)) dff_c_w(
        {is_m, ac_m, as_a_m, as_b_m, rs_m, ps_m, rwe_m},
        1'b1,
        {is_w, ac_w, as_a_w, as_b_w, rs_w, ps_w, rwe_w},
        clk,
        rst
    );

    dff #(.N(32*5)) dff_w(
        {pc_plus_4_m,   alu_out_m,  mem_rd,   ext_imm_m,  i_m},
        1'b1,
        {pc_plus_4_w,   alu_out_w,  mem_rd_w, ext_imm_w,  i_w},
        clk,
        rst
    );

    always_comb begin
        case (rs_w)
        RES_SRC_ALU_OUT:    wd3 = alu_out_w;
        RES_SRC_PC_PLUS_4:  wd3 = pc_plus_4_w;
        RES_SRC_EXT_IMM:    wd3 = ext_imm_w;
        RES_SRC_MEM:        wd3 = mem_rd_w;
        default:            wd3 = 32'hffffffff;
        endcase
    end


    //
    // Hazard controller
    //
    forward_type_e forward_alu_op_b;
    forward_type_e forward_alu_op_a;

    hazard_ctrl hc(
        i_d[`A1],
        i_d[`A2],
        i_e[`A1],
        i_e[`A2],
        i_e[`A3],
        i_m[`A3],
        i_w[`A3],
        rwe_m,
        rwe_w,
        rs_e,
        pcs_e,
        forward_alu_op_a,
        forward_alu_op_b,
        stall,
        flush
    );


    alu_operand_dec alu_op_b_dec(
        as_b_e,
        forward_alu_op_b,
        rd2_e,
        ext_imm_e,
        pc_e,
        alu_out_m,
        wd3,
        alu_op_b_e
    );

    alu_operand_dec alu_op_a_dec(
        as_a_e,
        forward_alu_op_a,
        rd1_e,
        ext_imm_e,
        pc_e,
        alu_out_m,
        wd3,
        alu_op_a_e
    );
endmodule
