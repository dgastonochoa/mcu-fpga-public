`timescale 10ps/1ps

`ifndef VCD
    `define VCD "spi_tb.vcd"
`endif

`define CLK_P 6

module spi_tb;

    reg clk = 0;

    always #(`CLK_P / 2) clk = ~clk;


    reg en, rst;
    wire miso, mosi, ss, sck;


    reg [7:0] m_wd = 8'd0;
    wire m_rdy, m_busy;
    wire [7:0] m_rd;

    spi_master dut1(miso, m_wd, mosi, ss, m_rd, m_rdy, m_busy, sck, en, rst, clk);


    reg [7:0] s_wd = 8'd0;
    wire s_busy, s_rdy;
    wire [7:0] s_rd;

    spi_slave dut2(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, rst, sck, clk);


    integer i = 0;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, spi_tb);

        //
        // Reset works
        //
        #4  rst = 1;
        #4  rst = 0;
            assert(miso === 1'b0);
            assert(mosi === 1'b0);
            assert(ss === 1'b1);
            assert(sck === 1'b1);
            assert(m_rdy === 1'b0);
            assert(m_rd === 8'b0);
            assert(m_busy === 1'b0);
            assert(s_rdy === 1'b0);
            assert(s_rd === 8'b0);
            assert(s_busy === 1'b0);


        //
        // SPI master slave full duplex works
        //
        m_wd = 8'haa;
        s_wd = 8'h55;
        en = 1'b1;
        #4 en = 1'b0;
        @(posedge m_rdy, posedge s_rdy);
        #1  assert(m_rd === 8'h55);
            assert(s_rd === 8'haa);
            assert(sck === 1'b1);

        @(posedge ss);

        for (i = 0; i < 10; i = i + 1) begin
            #`CLK_P assert(sck === 1'b1);
        end


        //
        // SPI master slave full duplex works 8x bits
        //
        m_wd = 8'haa;
        s_wd = 8'h55;
        en = 1'b1;
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge m_rdy, posedge s_rdy) begin
                #1  assert(m_rd === 8'h55);
                    assert(s_rd === 8'haa);
                    assert(sck === 1'b1);
                    @(posedge ss);
            end
        end
        en = 1'b0;

        #40;
        $finish;
    end

endmodule
