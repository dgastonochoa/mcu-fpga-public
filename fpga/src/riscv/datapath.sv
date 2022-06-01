`include "riscv/datapath.svh"

/**
* Sign-extend a immediate contained in @p instr to 32 bits.
*
* @param instr Instruction containing the immediate.
* @param imm_src Type of instruction (I-type, R-type etc.)
* @param ext_imm SIgn-extended immediate
*/
module extend(
    input   wire    [31:0]  instr,
    input   imm_src_e       imm_src,
    output  logic   [31:0]  ext_imm
);
    wire [31:0] i_src, s_src, b_src, j_src, u_src, i2_src;

    assign i_src = {{32-12{instr[31]}}, instr[31:20]};
    assign s_src = {{32-12{instr[31]}}, {instr[31:25], instr[11:7]}};
    assign b_src = {{32-13{instr[31]}}, {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}};
    assign j_src = {{32-21{instr[31]}}, {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}};
    assign u_src = {instr[31:12], {12{1'b0}}};
    assign i2_src = {{(32-5){1'b0}}, instr[24:20]};

    always_comb begin
        case (imm_src)
        IMM_SRC_ITYPE: ext_imm = i_src;
        IMM_SRC_STYPE: ext_imm = s_src;
        IMM_SRC_BTYPE: ext_imm = b_src;
        IMM_SRC_JTYPE: ext_imm = j_src;
        IMM_SRC_UTYPE: ext_imm = u_src;
        IMM_SRC_ITYPE2: ext_imm = i2_src;
        default: ext_imm = 32'bx;
        endcase
    end
endmodule


/**
* Register file. Writes sync. (pos. edge). Reads async.
*
* @param addr1 Address of source reg. 1
* @param addr2 Address of source reg. 2
* @param addr3 Address of dst. reg.
* @param wd3 Value to write in the reg. whose address is @p addr3.
* @param we Write enable. If 0, @p addr3 and @p wd3 are ignored. If 1,
*           the data in @p wd3 will be written in the next clk. pos. edge
*
* @param rd1 Value of the regiser whose address is @p addr1
* @param rd2 Value of the regiser whose address is @p addr2
* @param clk
*/
module regfile(
    input   wire [4:0]  addr1,
    input   wire [4:0]  addr2,
    input   wire [4:0]  addr3,
    input   wire [31:0] wd3,
    input   wire        we,
    output  wire [31:0] rd1,
    output  wire [31:0] rd2,
    input   wire        clk
);
    reg [31:0] _reg [32];

    always_ff @(posedge clk) begin
        if (we) begin
            if (addr3 != 5'b00) begin
                _reg[addr3] <= wd3;
            end
        end
    end

    assign rd1 = addr1 == 5'b0 ? 32'b0 : _reg[addr1];
    assign rd2 = addr2 == 5'b0 ? 32'b0 : _reg[addr2];
endmodule

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
 * @param alu_src ALU's second operand source. See datapath.vh.
 * @param result_src Source of the result to be written in the reg. file.
 *                   See datapath.vh.
 *
 * @param alu_out ALU output.
 * @param write_data Data to be written in memory.
 * @param rst Reset.
 * @param clk Clock signal
 */
module datapath(
    input   wire [31:0] instr,

    input   wire [31:0] read_data,
    input   wire        reg_we,

    input   imm_src_e   imm_src,
    input   alu_op_e    alu_ctrl,
    input   alu_src_e   alu_src,
    input   res_src_e   result_src,
    input   pc_src_e    pc_src,

    output  wire [31:0] pc,

    output  wire [31:0] alu_out,
    output  wire [3:0]  alu_flags,
    output  wire [31:0] write_data,

    input   wire        rst,
    input   wire        clk
);

    // Next PC logic
    wire    [31:0] pc_plus_4;
    wire    [31:0] pc_plus_off;
    wire    [31:0] pc_reg_plus_off;
    logic   [31:0] pc_next;

    assign pc_plus_4 = pc + 4;
    assign pc_plus_off = pc + ext_imm;
    assign pc_reg_plus_off = reg_rd1 + ext_imm;

    dff pc_ff(pc_next, pc, rst, clk);

    always_comb begin
        case (pc_src)
        PC_SRC_PLUS_4:          pc_next = pc_plus_4;
        PC_SRC_PLUS_OFF:        pc_next = pc_plus_off;
        PC_SRC_REG_PLUS_OFF:    pc_next = pc_reg_plus_off;
        default:                pc_next = 2'bx;
        endcase
    end


    // Register file logic
    wire    [31:0] reg_rd1;
    wire    [31:0] reg_rd2;
    logic   [31:0] reg_wr_data;

    regfile rf(instr[19:15], instr[24:20], instr[11:7], reg_wr_data, reg_we, reg_rd1, reg_rd2, clk);

    always_comb begin
        case (result_src)
        RES_SRC_ALU_OUT:    reg_wr_data = alu_out;
        RES_SRC_READ_DATA:  reg_wr_data = read_data;
        RES_SRC_PC_PLUS_4:  reg_wr_data = pc_plus_4;
        default:            reg_wr_data = 32'hx;
        endcase
    end


    // ALU and extender logic
    logic   [31:0] alu_srca;
    logic   [31:0] alu_srcb;
    wire    [31:0] ext_imm;

    extend ext(instr, imm_src, ext_imm);

    alu alu0(alu_srca, alu_srcb, alu_ctrl, alu_out, alu_flags);

    always_comb begin
        case (alu_src)
        ALU_SRC_EXT_IMM:    {alu_srca, alu_srcb} = {reg_rd1, ext_imm};
        ALU_SRC_REG:        {alu_srca, alu_srcb} = {reg_rd1, write_data};
        ALU_SRC_PC_EXT_IMM: {alu_srca, alu_srcb} = {pc, ext_imm};
        default:            {alu_srca, alu_srcb} = {32'bx, 32'bx};
        endcase
    end


    // Outputs
    assign write_data = reg_rd2;
endmodule
