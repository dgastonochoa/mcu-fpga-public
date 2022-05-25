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
