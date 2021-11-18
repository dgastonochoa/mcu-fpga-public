`timescale 1us/100ns

module spi_master_rx_tb;

  wire [7:0] data;
  wire ss, busy, rdy, sck;

  wire [1:0] _dbg_cs;
  wire [3:0] _dbg_idx;
  wire [7:0] _dbg_buff;

  reg miso, get, clk;
  reg [7:0] read_data;

  spi_master_rx smr(data, ss, busy, rdy, sck, _dbg_cs, _dbg_idx, _dbg_buff, miso, get, clk);

  initial begin
    $dumpfile("spi_master_rx_tb.vcd");
    $dumpvars(1, spi_master_rx_tb);

    //
    // Send one byte and wait. Then, send two bytes without waiting.
    //

    read_data <= 0;
    miso <= 1;
    get <= 1;
    @(posedge rdy);
    get <= 0;
    read_data <= data;

    #200;

    miso <= 0;
    get <= 1;
    @(posedge rdy);
    read_data <= data;

    miso <= 1;
    @(posedge rdy);
    get <= 0;
    read_data <= data;


    #800;
    $finish;
  end

  // slave tx simulator
  always @ (negedge ss) begin
    // slave tx works on negedge, therefore since ss is
    // set low wait for half sck cycle.
    #100;

    miso <= ~miso;
    repeat (7) begin
      #200 miso <= ~miso;
    end
  end

  initial begin
    clk <= 0;
    forever begin
      #2.5 clk <= ~clk;
    end
  end

endmodule
