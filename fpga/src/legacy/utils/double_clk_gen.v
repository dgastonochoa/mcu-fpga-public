module double_clk_gen
    #(parameter CLK_DIV = 20,
      parameter CLK0_HS = 1,
      parameter CLK1_HS = 1'bz) (

    output reg clkout0,
    output reg clkout1,
    input wire en,
    input wire clk
);
    localparam CS_START = 0, CS_RUN = 1;

    parameter div = CLK_DIV / 2;

    reg [15:0] cnt;

    always @ (posedge clk) begin
        if (en) begin
            if (cnt < 1*div) begin
                clkout0 <= CLK0_HS;
                clkout1 <= 0;
            end else if ((cnt >= 1*div) && (cnt < 2*div)) begin
                clkout0 <= CLK0_HS;
                clkout1 <= CLK1_HS;
            end else if ((cnt >= 2*div) && (cnt < 3*div)) begin
                clkout0 <= 0;
                clkout1 <= CLK1_HS;
            end else if ((cnt >= 3*div) && (cnt < 4*div)) begin
                clkout0 <= 0;
                clkout1 <= 0;
            end else begin
                clkout0 <= clkout0;
                clkout1 <= clkout1;
            end

            if (cnt == 4*div - 1)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end else begin
            clkout0 <= 0;
            clkout1 <= CLK1_HS;
            cnt <= 0;
        end
    end

endmodule
