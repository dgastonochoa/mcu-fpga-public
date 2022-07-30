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
        default: ext_imm = 32'hffffffff;
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
module regfile #(parameter EDGE = 1) (
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

    generate
        if (EDGE == 0)
            always_ff @(negedge clk) begin
                if (we) begin
                    if (addr3 != 5'b00) begin
                        _reg[addr3] <= wd3;
                    end
                end
            end
        else
            always_ff @(posedge clk) begin
                if (we) begin
                    if (addr3 != 5'b00) begin
                        _reg[addr3] <= wd3;
                    end
                end
            end
    endgenerate

    assign rd1 = addr1 == 5'b0 ? 32'b0 : _reg[addr1];
    assign rd2 = addr2 == 5'b0 ? 32'b0 : _reg[addr2];
endmodule
