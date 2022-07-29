module hazard_ctrl(
    input  wire [4:0] a1_e,
    input  wire [4:0] a2_e,
    input  wire [4:0] a3_m,
    input  wire       rf_we_m,
    output wire       forward_alu_out_m_a,
    output wire       forward_alu_out_m_b
);
    assign forward_alu_out_m_a = ((a1_e != 4'd0) && rf_we_m && (a1_e == a3_m));
    assign forward_alu_out_m_b = ((a2_e != 4'd0) && rf_we_m && (a2_e == a3_m));
endmodule

/**
 * CPU datapath.
 *
 * @param instr Instruction to be executed.
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
    input   wire [31:0] instr,

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
    // Fetch
    //
    wire    [31:0] pc_plus_4;

    assign pc_plus_4 = pc + 4;

    logic [31:0] pc_next;

    always_comb begin
        case (pc_src)
        PC_SRC_PLUS_4:          pc_next = pc_plus_4;
        PC_SRC_PLUS_OFF:        pc_next = pc_plus_off;
        PC_SRC_REG_PLUS_OFF:    pc_next = pc_reg_plus_off;
        default:                pc_next = 32'hffffffff;
        endcase
    end

    dff pc_ff(pc_next, 1'b1, pc, clk, rst);

    wire [31:0] pc_d, instr_d, pc_plus_4_d;

    dff #(.N(32*3)) dff_fetch(
        {pc,    instr,      pc_plus_4},
        1'b1,
        {pc_d,  instr_d,    pc_plus_4_d},
        clk,
        rst
    );

    imm_src_e   imm_src_d;
    alu_op_e    alu_ctrl_d;
    alu_src_e   alu_src_a_d;
    alu_src_e   alu_src_b_d;
    res_src_e   result_src_d;
    pc_src_e    pc_src_d;
    wire        rf_we_d;
    dff #(.N(6*4 + 1)) dff_ctrl_fetch(
        {imm_src,   alu_ctrl,   alu_src_a,   alu_src_b,   result_src,   pc_src,   rf_we},
        1'b1,
        {imm_src_d, alu_ctrl_d, alu_src_a_d, alu_src_b_d, result_src_d, pc_src_d, rf_we_d},
        clk,
        rst
    );


    //
    // Decode
    //
    wire  [31:0] rd1, rd2;
    wire  [4:0] a3_w;
    logic [31:0] wd3;
    wire  rf_we_w;

    regfile rf(instr_d[19:15], instr_d[24:20], a3_w, wd3, rf_we_w, rd1, rd2, clk);


    wire    [31:0] ext_imm;

    extend ext(instr_d, imm_src_d, ext_imm);

    wire [31:0] rd1_e, rd2_e, pc_e, ext_imm_e, pc_plus_4_e;
    wire [4:0] a1_e, a2_e, a3_e;

    dff #(.N(32*5 + 3*5)) dff_decode(
        {rd1,   rd2,    pc_d, ext_imm,      pc_plus_4_d, instr_d[19:15], instr_d[24:20], instr_d[11:7]},
        1'b1,
        {rd1_e, rd2_e,  pc_e, ext_imm_e,    pc_plus_4_e, a1_e,           a2_e,           a3_e},
        clk,
        rst
    );

    imm_src_e   _imm_src_e;
    alu_op_e    _alu_ctrl_e;
    alu_src_e   _alu_src_a_e;
    alu_src_e   _alu_src_b_e;
    res_src_e   _result_src_e;
    pc_src_e    _pc_src_e;
    wire        _rf_we_e;
    dff #(.N(6*4 + 1)) dff_ctrl_decode(
        {imm_src_d,  alu_ctrl_d,  alu_src_a_d,  alu_src_b_d,  result_src_d,  pc_src_d,  rf_we_d},
        1'b1,
        {_imm_src_e, _alu_ctrl_e, _alu_src_a_e, _alu_src_b_e, _result_src_e, _pc_src_e, _rf_we_e},
        clk,
        rst
    );


    //
    // Execute
    //
    logic [31:0] alu_op_a, alu_op_b;
    wire [31:0] alu_out;
    wire [31:0] alu_op_a_rd1, alu_op_b_rd1;

    assign alu_op_a_rd1 = forward_alu_out_m_a ? alu_out_m : rd1_e;
    assign alu_op_b_rd1 = forward_alu_out_m_b ? alu_out_m : rd2_e;

    always_comb begin
        case (_alu_src_a_e)
        ALU_SRC_REG_1:   alu_op_a = alu_op_a_rd1;
        ALU_SRC_REG_2:   alu_op_a = rd2_e;
        ALU_SRC_EXT_IMM: alu_op_a = ext_imm_e;
        ALU_SRC_PC:      alu_op_a = pc_e;
        default:         alu_op_a = 32'hffffffff;
        endcase
    end

    always_comb begin
        case (_alu_src_b_e)
        ALU_SRC_REG_1:   alu_op_b = rd1_e;
        ALU_SRC_REG_2:   alu_op_b = alu_op_b_rd1;
        ALU_SRC_EXT_IMM: alu_op_b = ext_imm_e;
        ALU_SRC_PC:      alu_op_b = pc_e;
        default:         alu_op_a = 32'hffffffff;
        endcase
    end

    alu alu0(alu_op_a, alu_op_b, _alu_ctrl_e, alu_out, alu_flags);

    wire    [31:0] pc_plus_off;
    wire    [31:0] pc_reg_plus_off;

    assign pc_plus_off = pc_e + ext_imm_e;
    assign pc_reg_plus_off = rd1_e + ext_imm_e;

    wire [31:0] alu_out_m, write_data_m, pc_plus_4_m, ext_imm_m;
    wire [4:0] a3_m;

    dff #(.N(32*4 + 5)) dff_execute(
        {alu_out,   rd2_e,          pc_plus_4_e,    ext_imm_e,  a3_e},
        1'b1,
        {alu_out_m, write_data_m,   pc_plus_4_m,    ext_imm_m,  a3_m},
        clk,
        rst
    );

    imm_src_e   imm_src_m;
    alu_op_e    alu_ctrl_m;
    alu_src_e   alu_src_a_m;
    alu_src_e   alu_src_b_m;
    res_src_e   result_src_m;
    pc_src_e    pc_src_m;
    wire        rf_we_m;
    dff #(.N(6*4 + 1)) dff_ctrl_execute(
        {_imm_src_e, _alu_ctrl_e, _alu_src_a_e, _alu_src_b_e, _result_src_e, _pc_src_e, _rf_we_e},
        1'b1,
        {imm_src_m,  alu_ctrl_m,  alu_src_a_m,  alu_src_b_m,  result_src_m,  pc_src_m,  rf_we_m},
        clk,
        rst
    );


    //
    // Mem. read/write
    //
    assign mem_wd = alu_out_m;
    assign write_data = write_data_m;

    wire [31:0] pc_plus_4_w, alu_out_w, ext_imm_w, mem_rd_w;

    dff #(.N(32*4 + 5)) dff_mem_read_write(
        {pc_plus_4_m,   alu_out_m,  mem_rd,   ext_imm_m,  a3_m},
        1'b1,
        {pc_plus_4_w,   alu_out_w,  mem_rd_w, ext_imm_w,  a3_w},
        clk,
        rst
    );

    imm_src_e   imm_src_w;
    alu_op_e    alu_ctrl_w;
    alu_src_e   alu_src_a_w;
    alu_src_e   alu_src_b_w;
    res_src_e   result_src_w;
    pc_src_e    pc_src_w;
    dff #(.N(6*4 + 1)) dff_ctrl_mem_read_write(
        {imm_src_m,  alu_ctrl_m,  alu_src_a_m,  alu_src_b_m,  result_src_m,  pc_src_m,  rf_we_m},
        1'b1,
        {imm_src_w,  alu_ctrl_w,  alu_src_a_w,  alu_src_b_w,  result_src_w,  pc_src_w,  rf_we_w},
        clk,
        rst
    );


    //
    // Write register
    //
    always_comb begin
        case (result_src_w)
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
    wire forward_alu_out_m_a, forward_alu_out_m_b;

    hazard_ctrl hc(
        a1_e, a2_e, a3_m, rf_we_m, forward_alu_out_m_a, forward_alu_out_m_b);
endmodule
