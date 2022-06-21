`timescale 10ps/1ps

`ifndef VCD
    `define VCD "spi_several_slaves_tb.vcd"
`endif

`define CLK_P 6

module spi_several_slaves_tb;

    reg clk = 0;

    always #(`CLK_P / 2) clk = ~clk;


    reg en, rst;
    wire mosi, miso, sck, _ss;



    reg [7:0] m_wd = 8'd0;
    wire m_rdy, m_busy;
    wire [7:0] m_rd;

    spi_master dut1(miso, m_wd, mosi, _ss, m_rd, m_rdy, m_busy, sck, en, rst, clk);


    reg [7:0] s_wd [3];
    reg [2:0] ss;
    wire [2:0] s_busy, s_rdy;
    wire [7:0] s_rd [3];
    wire [3:0] __miso;

    spi_slave dut2(mosi, ss[0], s_wd[0], __miso[0], s_rd[0], s_rdy[0], s_busy[0], rst, sck, clk);
    spi_slave dut3(mosi, ss[1], s_wd[1], __miso[1], s_rd[1], s_rdy[1], s_busy[1], rst, sck, clk);
    spi_slave dut4(mosi, ss[2], s_wd[2], __miso[2], s_rd[2], s_rdy[2], s_busy[2], rst, sck, clk);

    wire [7:0] s_rd0, s_rd1, s_rd2;
    assign s_rd0 = s_rd[0];
    assign s_rd1 = s_rd[1];
    assign s_rd2 = s_rd[2];

    // TODO how to do this
    // spi_slave dut2 [2:0] (
    //     .mosi(mosi),
    //     .ss(ss[2:0]),
    //     .wd(s_wd[2:0]),
    //     .miso(miso),
    //     .rd(s_rd[2:0]),
    //     .rdy(s_rdy[2:0]),
    //     .busy(s_busy[2:0]),
    //     .rst(rst),
    //     .sck(sck),
    //     .clk(clk));

    integer i;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, spi_several_slaves_tb);

        //
        // Reset works
        //
        #4  rst = 1;
            ss = 3'b111;
        #4  rst = 0;
            assert(mosi === 1'b0);
            assert(sck === 1'b1);
            assert(s_rdy === 3'b000);
            assert(s_busy === 3'b000);
            assert(s_rd[0] === 8'b000);
            assert(s_rd[1] === 8'b000);
            assert(s_rd[1] === 8'b000);


        //
        // SPI master slave 1 half duplex works
        //
        m_wd = 8'haa;
        ss[0] = 1'b0;
        en = 1'b1;
        #4 en = 1'b0;
        @(posedge s_rdy[0]);
        #1  assert(s_rd[0] === 8'haa);
            assert(s_rd[1] === 8'b0);
            assert(s_rd[2] === 8'b0);
            assert(s_rdy[1] === 1'b0);
            assert(s_rdy[2] === 1'b0);
            assert(sck === 1'b1);
        ss[0] = 1'b1;

        for (i = 0; i < 10; i = i + 1) begin
            #`CLK_P assert(sck === 1'b1);
        end


        //
        // SPI master slave 2 half duplex works
        //
        m_wd = 8'hbb;
        ss[1] = 1'b0;
        en = 1'b1;
        #8 en = 1'b0;
        @(posedge s_rdy[1]);
        #1  assert(s_rd[0] === 8'haa);
            assert(s_rd[1] === 8'hbb);
            assert(s_rd[2] === 8'b0);
            assert(s_rdy[0] === 1'b1);
            assert(s_rdy[2] === 1'b0);
            assert(sck === 1'b1);
        ss[1] = 1'b1;

        for (i = 0; i < 10; i = i + 1) begin
            #`CLK_P assert(sck === 1'b1);
        end


        //
        // SPI master slave 3 half duplex works
        //
        m_wd = 8'hcc;
        ss[2] = 1'b0;
        en = 1'b1;
        #8 en = 1'b0;
        @(posedge s_rdy[2]);
        #1  assert(s_rd[0] === 8'haa);
            assert(s_rd[1] === 8'hbb);
            assert(s_rd[2] === 8'hcc);
            assert(s_rdy[0] === 1'b1);
            assert(s_rdy[1] === 1'b1);
            assert(sck === 1'b1);
        ss[2] = 1'b0;

        for (i = 0; i < 10; i = i + 1) begin
            #`CLK_P assert(sck === 1'b1);
        end

        #40;
        $finish;
    end

endmodule
