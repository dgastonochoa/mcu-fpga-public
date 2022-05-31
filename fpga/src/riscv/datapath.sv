`include "riscv/datapath.vh"

/**
 * Sign-extend a immediate contained in @p instr to 32 bits.
 *
 * @param instr Instruction containing the immediate.
 * @param imm_src Type of instruction (I-type, R-type etc.)
 * @param ext_imm SIgn-extended immediate
 */
module extend(
    input   wire    [31:0] instr,
    input   wire    [2:0]  imm_src,
    output  logic   [31:0] ext_imm
);
    wire [31:0] i_src, s_src, b_src, j_src, u_src;

    assign i_src = {{32-12{instr[31]}}, instr[31:20]};
    assign s_src = {{32-12{instr[31]}}, {instr[31:25], instr[11:7]}};
    assign b_src = {{32-13{instr[31]}}, {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}};
    assign j_src = {{32-21{instr[31]}}, {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}};
    assign u_src = {instr[31:12], {12{1'b0}}};

    always_comb begin
        case (imm_src)
        imm_src_itype: ext_imm = i_src;
        imm_src_stype: ext_imm = s_src;
        imm_src_btype: ext_imm = b_src;
        imm_src_jtype: ext_imm = j_src;
        imm_src_utype: ext_imm = u_src;
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

    input   wire [2:0]  imm_src,
    input   wire [3:0]  alu_ctrl,
    input   wire [1:0]  alu_src,
    input   wire [1:0]  result_src,
    input   wire [1:0]  pc_src,

    output  wire [31:0] pc,

    output  wire [31:0] alu_out,
    output  wire [3:0]  alu_flags,
    output  wire [31:0] write_data,

    input   wire        rst,
    input   wire        clk
);
    wire    [31:0] pc_plus_4;
    wire    [31:0] pc_plus_off;
    wire    [31:0] pc_reg_plus_off;
    logic   [31:0] pc_next;

    wire    [31:0] reg_rd1;
    wire    [31:0] reg_rd2;
    logic   [31:0] reg_wr_data;

    logic   [31:0] alu_srca;
    logic   [31:0] alu_srcb;

    wire    [31:0] ext_imm;

    dff pc_ff(pc_next, pc, rst, clk);

    regfile rf(instr[19:15], instr[24:20], instr[11:7], reg_wr_data, reg_we, reg_rd1, reg_rd2, clk);

    extend ext(instr, imm_src, ext_imm);

    alu alu0(alu_srca, alu_srcb, alu_ctrl, alu_out, alu_flags);

    always_comb begin
        case (pc_src)
        pc_src_plus_4:          pc_next = pc_plus_4;
        pc_src_plus_off:        pc_next = pc_plus_off;
        pc_src_reg_plus_off:    pc_next = pc_reg_plus_off;
        default:                pc_next = 2'bx;
        endcase
    end

    always_comb begin
        case (alu_src)
        alu_src_ext_imm:    {alu_srca, alu_srcb} = {reg_rd1, ext_imm};
        alu_src_reg:        {alu_srca, alu_srcb} = {reg_rd1, write_data};
        alu_src_pc_ext_imm: {alu_srca, alu_srcb} = {pc, ext_imm};
        default:            {alu_srca, alu_srcb} = {32'bx, 32'bx};
        endcase
    end

    always_comb begin
        case (result_src)
        res_src_alu_out:    reg_wr_data = alu_out;
        res_src_read_data:  reg_wr_data = read_data;
        res_src_pc_plus_4:  reg_wr_data = pc_plus_4;
        default:            reg_wr_data = 32'hx;
        endcase
    end

    assign pc_plus_4 = pc + 4;
    assign pc_plus_off = pc + ext_imm;
    assign pc_reg_plus_off = reg_rd1 + ext_imm;
    assign write_data = reg_rd2;
endmodule
