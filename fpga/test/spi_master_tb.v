`timescale 1us/100ns

module spi_master_tb;

  wire mosi, ss, sck, send_busy, recv_rdy, recv_busy;
  wire [7:0] recv_data;

  reg miso, send, read;
  reg [7:0] send_data;

  wire [7:0] _r_dbg_buff;
  wire [1:0] _r_dbg_cs, _s_dbg_cs;
  wire [3:0] _r_dbg_idx, _s_dbg_idx;
  wire [4:0] _s_dbg_timer;

  reg clk;

  reg [7:0] sim_buf1, sim_buf2, recv_buf;
  reg [4:0] simidx;

  spi_master sm(mosi,  ss,  sck,  miso,  clk,  send_busy,  send,
                send_data,  recv_rdy,  recv_busy,  recv_data,  read,
                _r_dbg_cs,  _r_dbg_idx,  _r_dbg_buff,  _s_dbg_cs,
                _s_dbg_idx,  _s_dbg_timer);

  initial begin
    $dumpfile("spi_master_tb.vcd");
    $dumpvars(1, spi_master_tb);
    #4500;
    $finish;
  end

  // Set up send op.
  initial begin
    sim_buf2 <= 0;
    send <= 0;
    send_data <= 0;
    simidx <= 0;
    #500;
    #5 send_data <= 8'hAA;
    #5 send <= 1;
    #200 send <= 0;
    #10 @(negedge send_busy);
    sim_buf2 <= sim_buf1;
  end

  // SPI slave rx fake
  always @(posedge sck) begin
    if (!ss) begin
      sim_buf1[simidx] <= mosi;
      simidx <= simidx + 1;
    end else begin
      sim_buf1 <= 0;
      simidx <= 0;
    end
  end


  // Set up read op.
  initial begin
    recv_buf <= 0;
    miso <= 1;
    read <= 0;
    #500;
    #5  read <= 1; // <= this fails
    #200 read <= 0;
    #10 @(posedge recv_rdy);
    recv_buf <= recv_data;
  end

  // SPI slave tx fake
  always @(negedge sck) begin
    if (!ss) begin
      repeat (8) begin
        miso <= ~miso;
      end
    end
  end

  initial begin
    #5 clk <= 1;
    forever begin
      #2.5 clk <= ~clk;
    end
  end

endmodule
