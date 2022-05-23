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
 * @param instr     Instruction to be executed.
 * @param data_in   Data read from memory.
 * @param reg_we    Register write enable. Synchronous (pos. edge)
 * @param imm_src   Type of immediate depending on the instruction.
 *                    0 = I-Type instruction
 *                    1 = S-Type instruction
 * @param alu_out   ALU output.
 * @param data_out  Data to be written in memory.
 * @param rst       Reset.
 * @param clk       Clock signal
 */
module datapath(
    input   wire [31:0] instr,

    input   wire [31:0] data_in,
    input   wire        reg_we,

    input   wire        imm_src,

    output  wire [31:0] pc,

    output  wire [31:0] alu_out,
    output  wire [31:0] data_out,

    input   wire        rst,
    input   wire        clk
);
    wire [31:0] pc_next;
    dff pc_ff(pc_next, pc, rst, clk);

    assign pc_next = pc + 4;


    wire [31:0] srca;
    regfile rf(instr[19:15], instr[24:20], instr[11:7], data_in, reg_we, srca, data_out, clk);


    wire [31:0] srcb;
    extend ext(instr, imm_src, srcb);


    wire [3:0] alu_flags;
    alu alu0(srca, srcb, `ALU_OP_ADD, alu_out, alu_flags);
endmodule
