`include "riscv/datapath.svh"
`include "riscv/controller.svh"
`include "riscv/hazard_ctrl.svh"

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

/**
 * Outputs the proper register read value from the inputs,
 * given a forward type.
 *
 * @param fw_t Forward type.
 * @param rf_rd Register read value
 * @param alu_out_m ALU output from the memory stage
 * @param wd3_w Writeback value from the writeback stage.
 * @param rd Register read value. It will be one of the above three depending on
 *           the value of @param{fw_t}
 *
 */
module forward_mux(
    input  fw_type_e        fw_t,
    input  wire      [31:0] rf_rd,
    input  wire      [31:0] alu_out_m,
    input  wire      [31:0] wd3_w,
    output logic     [31:0] rd
);
    always_comb begin
        case (fw_t)
        FORW_NO:        rd = rf_rd;
        FORW_ALU_OUT_M: rd = alu_out_m;
        FORW_ALU_OUT_W: rd = wd3_w;
        default:        rd = 32'hffffffff;
        endcase
    end
endmodule

/**
 * Outputs the proper ALU operator from the inputs, given a operator source.
 *
 * @param oper_src ALU operator source
 * @param rf_rd Register read value
 * @param ext_imm Extended immediate
 * @param pc Program counter
 * @param alu_oper ALU operator. It will be one of the above three depending on
 *                 the value of @param{oper_src}
 *
 */
module alu_op_mux(
    input  alu_src_e      oper_src,
    input  wire  [31:0]   rf_rd,
    input  wire  [31:0]   ext_imm,
    input  wire  [31:0]   pc,
    output logic [31:0]   alu_oper
);
    // TODO possibly ALU_SRC_REG_2 should not exist:
    // alu_op_a can never be assigned to rd2, neither can
    // alu_op_b be assigned to rd1.
    always_comb begin
        case (oper_src)
        ALU_SRC_REG_1:   alu_oper = rf_rd;
        ALU_SRC_REG_2:   alu_oper = rf_rd;
        ALU_SRC_EXT_IMM: alu_oper = ext_imm;
        ALU_SRC_PC:      alu_oper = pc;
        default:         alu_oper = 32'hffffffff;
        endcase
    end
endmodule

/**
 * CPU datapath. The control signals receivec correspond to the fetch stage.
 * They will be properly propagated through the pipeline.
 *
 * @param instr Instruction to be executed.
 * @param mem_rd Data read from memory.
 * @param rf_we Register write enable. Synchronous (pos. edge)
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
 * @param stall Hazard controller stall signal
 * @param flush Hazard controller flush signal
 *
 * @param fw_rd1 Forward type for the register read value 1. Forwarding is used
 *               to prevent RAW hazards.
 *
 * @param fw_rd2 Same as @param{fw_rd1} but for the register read value 2.
 * @param pc Program counter.
 * @param m_addr Memory address to be accessed.
 *
 * @param alu_flags Flags produced by the ALU. UNUSED: the ALU produces useful
 *                  flags at the execute state. They can't be sent to the
 *                  singlecycle controller (which is expected to be use with
 *                  this datapath) because the latter will be generating the
 *                  control signals for the instruction in the fetch stage.
 *
 * @param write_data Data to be written in memory.
 * @param i_d Instruction in the decode stage.
 * @param i_e Instruction in the execute stage.
 * @param i_m Instruction in the memory stage.
 * @param i_w Instruction in the writeback stage.
 * @param rwe_m Register write-enable, memory stage.
 * @param rwe_w Register write-enable, write-back stage.
 * @param rs_e Result source, execute stage.
 * @param pcs_e PC source, execute stage.
 * @param rst Async. reset.
 * @param clk Clock signal
 */
module datapath(
    input  wire      [31:0] i,
    input  wire      [31:0] mem_rd,
    input  wire             rf_we,
    input  imm_src_e        imm_src,
    input  alu_op_e         alu_ctrl,
    input  alu_src_e        alu_src_a,
    input  alu_src_e        alu_src_b,
    input  res_src_e        result_src,
    input  pc_src_e         pc_src,
    input  wire             stall,
    input  wire             flush,
    input  fw_type_e        fw_rd1,
    input  fw_type_e        fw_rd2,

    output  wire     [31:0] pc,
    output  wire     [31:0] m_addr,
    output  wire     [3:0]  alu_flags,
    output  wire     [31:0] write_data,

    output  wire     [31:0] i_d,
    output  wire     [31:0] i_e,
    output  wire     [31:0] i_m,
    output  wire     [31:0] i_w,
    output  wire            rwe_m,
    output  wire            rwe_w,
    output  res_src_e       rs_e,
    output  pc_src_e        pcs_e,

    input   wire            rst,
    input   wire            clk
);
    //
    // Controller pipelined signals
    //
    localparam CTRL_LEN = 6*4 + 1;

    imm_src_e is_d,   is_e,   is_m,   is_w;
    alu_op_e  ac_d,   ac_e,   ac_m,   ac_w;
    alu_src_e as_a_d, as_a_e, as_a_m, as_a_w;
    alu_src_e as_b_d, as_b_e, as_b_m, as_b_w;
    res_src_e rs_d,           rs_m,   rs_w;
    pc_src_e  ps_d,   ps_e,   ps_m,   ps_w;
    wire      rwe_d,  rwe_e;


    //
    // Fetch
    //
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
    wire [31:0] pc_d, pc_plus_4_d, rd1_d, rd2_d, ext_imm_d;
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
    wire [31:0] rd1_e_aux, rd2_e_aux, rd1_e, rd2_e;
    wire [31:0] pc_e, ext_imm_e, pc_plus_4_e;
    wire [31:0] alu_op_a_e, alu_op_b_e, alu_out_e;

    clear_dff #(.N(CTRL_LEN)) dff_c_e(
        {is_d, ac_d, as_a_d, as_b_d, rs_d, ps_d, rwe_d},
        1'b1,
        {is_e, ac_e, as_a_e, as_b_e, rs_e, ps_e, rwe_e},
        stall | flush,
        clk,
        rst
    );

    clear_dff #(.N(32*6)) dff_e(
        {rd1_d,     rd2_d,      pc_d, ext_imm_d, pc_plus_4_d, i_d},
        1'b1,
        {rd1_e_aux, rd2_e_aux,  pc_e, ext_imm_e, pc_plus_4_e, i_e},
        stall | flush,
        clk,
        rst
    );

    alu_op_mux aod_a(as_a_e, rd1_e, ext_imm_e, pc_e, alu_op_a_e);
    alu_op_mux aod_b(as_b_e, rd2_e, ext_imm_e, pc_e, alu_op_b_e);

    alu alu0(alu_op_a_e, alu_op_b_e, ac_e, alu_out_e, alu_flags);

    branch_pc_src_dec bpsd(i_e[`OP], i_e[`F3], alu_flags, pcs_e);

    assign pc_plus_off_e = pc_e + ext_imm_e;
    assign pc_reg_plus_off_e = rd1_e + ext_imm_e;


    //
    // Mem. read/write
    //
    wire [31:0] alu_out_m, write_data_m, pc_plus_4_m, ext_imm_m;
    logic [31:0] exec_out_m;

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

    assign m_addr = alu_out_m;
    assign write_data = write_data_m;

    always_comb begin
        case (rs_m)
        RES_SRC_ALU_OUT:   exec_out_m = alu_out_m;
        RES_SRC_PC_PLUS_4: exec_out_m = pc_plus_4_m;
        RES_SRC_EXT_IMM:   exec_out_m = ext_imm_m;
        RES_SRC_MEM:       exec_out_m = mem_rd;
        default:           exec_out_m = 32'hffffffff;
        endcase
    end


    //
    // Write register
    //
    dff #(.N(CTRL_LEN)) dff_c_w(
        {is_m, ac_m, as_a_m, as_b_m, rs_m, ps_m, rwe_m},
        1'b1,
        {is_w, ac_w, as_a_w, as_b_w, rs_w, ps_w, rwe_w},
        clk,
        rst
    );

    dff #(.N(32*2)) dff_w(
        {exec_out_m,  i_m},
        1'b1,
        {wd3,  i_w},
        clk,
        rst
    );


    // TODO alu_out_m: Sometimes it will be necessary to forward from the
    // extender
    forward_mux fm_a(fw_rd1, rd1_e_aux, exec_out_m, wd3, rd1_e);
    forward_mux fm_b(fw_rd2, rd2_e_aux, exec_out_m, wd3, rd2_e);
endmodule
