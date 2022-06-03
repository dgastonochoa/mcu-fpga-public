module dec(
    input   wire    [1:0] d,
    output  logic   [3:0] q
);
    always_comb begin
        case (d)
        2'b00: q = 4'b0001;
        2'b01: q = 4'b0010;
        2'b10: q = 4'b0100;
        2'b11: q = 4'b1000;
        endcase
    end
endmodule

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
