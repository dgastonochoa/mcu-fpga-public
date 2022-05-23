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
    input   wire [31:0] imm,
    input   wire        imm_src,
    output  wire [31:0] ext_imm
);
    wire [31:0] i_src, s_src;

    assign i_src = {{32-N{imm[31]}}, imm[31:20]};
    assign s_src = {{32-N{imm[31]}}, {imm[31:25], imm[11:7]}};
    assign ext_imm = imm_src == 1 ? s_src : i_src;
endmodule
