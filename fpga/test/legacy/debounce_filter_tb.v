`timescale 1us/100ns

module debounce_filter_tb;
  reg clk = 0;
  reg sig = 0;

  debounce_filter #(.WAIT_CLK(10))  df(sig, clk, debc_sig);

  initial begin
    $dumpfile("debounce_filter_tb.vcd");
    $dumpvars(1, debounce_filter_tb);
    #5;

    repeat (5) begin
      #10 sig <= ~sig;
    end

        sig <= 1;
    #60 sig <= 0;

    #60 repeat (5) begin
      #10 sig <= ~sig;
    end
    
    #80;
    $finish;
  end

  initial begin
    #5 clk <= 1;
    forever begin
      #2.5 clk <= ~clk;
    end
  end

  wire [7:0] _dbg_debf_cnt;
  assign _dbg_debf_cnt = df.cnt;
endmodule
