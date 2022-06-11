`timescale 1us/100ns

module debounce_filter
  #(parameter WAIT_CLK = 100)(
  input wire signal,
  input wire clk,
  output reg debc_sig
);
  reg [20:0] cnt = 0;

  initial begin
    debc_sig <= 0;
  end

  always @ (posedge clk) begin
    if (debc_sig != signal) begin
      cnt <= cnt + 1;      
    end else begin
      cnt <= 0;
    end
    if (cnt >= WAIT_CLK) begin
      debc_sig <= signal;
      cnt <= 0;
    end
  end

endmodule
