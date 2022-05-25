/**
 * D flip-flop
 *
 */
module dff #(parameter N = 32) (
    input wire [N-1:0] d,
    output reg [N-1:0] q,
    input wire rst,
    input wire clk
);
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            q <= 32'b0;
        else
            q <= d;
    end
endmodule

/**
 * Sign-extend @p a to a 32 bit output.
 *
 */
module extend #(parameter N = 12) (
    input   wire    [31:0] instr,
    input   wire    [1:0]  imm_src,
    output  logic   [31:0] ext_imm
);
    wire [31:0] i_src, s_src, b_src;

    assign i_src = {{32-N{instr[31]}}, instr[31:20]};
    assign s_src = {{32-N{instr[31]}}, {instr[31:25], instr[11:7]}};
    assign b_src = {{32-(N-1){instr[31]}}, {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}};

    always_comb begin
        case (imm_src)
        2'b00: ext_imm = i_src;
        2'b01: ext_imm = s_src;
        2'b10: ext_imm = b_src;
        endcase
    end
endmodule
