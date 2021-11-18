`timescale 1us/100ns

module spi_master_tx_tb();

  wire mosi, sck, ss, busy, _dbg_sck;
  wire [1:0] _dbg_cs;
  wire [3:0] _dbg_idx;
  wire [4:0] _dbg_timer;

  reg [7:0] data, recv_data, data_buff;
  reg [3:0] idx;
  reg send, clk;

  spi_master_tx smt(mosi, sck, ss, busy, _dbg_cs, _dbg_sck, _dbg_idx, _dbg_timer, data, send, clk);

  initial begin
    $dumpfile("spi_master_tx_tb.vcd");
    $dumpvars(1, spi_master_tx_tb);

    idx <= 0;
    data <= 0;
    recv_data <= 0;
    send <= 0;
    data_buff <= 0;
    #200;

    data <= 8'b01010101;
         send <= 1;
    #200 send <= 0;
    @(negedge busy);
    data_buff <= recv_data;

    recv_data <= 0;
    idx <= 0;
    data <= 8'b10101010;
    send <= 1;

    // Wait 205 (instead of 200) to be sure that the RDY state
    // sees send high. Otherwhise send will go high and low before
    // the RDY state is processed, therefore busy will never go high etc.
    #205 send <= 0;
    @(negedge busy);
    data_buff <= recv_data;

    recv_data <= 0;
    idx <= 0;
    data <= 8'h35;
    send <= 1;
    #205 send <= 0;
    @(negedge busy);
    data_buff <= recv_data;

    #500;
    $finish;
  end

  // receiver simulator
  always @(negedge ss) begin
    // wait 100 on negedge to read on the rising edge, to simulate
    // an actual spi receiver.
    #100;
    repeat (8) begin
      recv_data[idx] <= mosi;
      idx <= idx + 1;
      #200;
    end
  end

  initial begin
    clk <= 0;
    forever begin
      #2.5 clk <= ~clk;
    end
  end

endmodule
