`timescale 10ps/1ps

`ifndef VCD
    `define VCD "spi_master_w_tb.vcd"
`endif

`define CLK_P 6

module spi_master_w_tb;
    reg clk = 0;

    always #(`CLK_P / 2) clk = ~clk;


    reg en = 1'b0, rst = 1'b0;
    reg [31:0] m_wd = 8'd0;
    wire miso, mosi, ss, sck;
    wire m_busy;

    spi_master_w dut1(
        mosi,
        miso,
        ss,
        sck,
        m_wd,
        en,
        m_busy,
        clk,
        rst
    );


    reg [7:0] s_wd = 8'd0;
    wire s_busy, s_rdy;
    wire [7:0] s_rd;

    spi_slave dut2(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, rst, sck, clk);


    wire s_rdy_sync;

    cell_sync_n #(.N(1)) c_sync0(clk, rst, s_rdy, s_rdy_sync);


    integer i;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, spi_master_w_tb);

        //
        // Reset works
        //
        #4  rst = 1;
        #4  rst = 0;
            assert(miso === 1'b0);
            assert(mosi === 1'b0);
            assert(ss === 1'b1);
            assert(sck === 1'b1);
            assert(m_busy === 1'b0);
            assert(s_rdy === 1'b0);
            assert(s_rd === 8'b0);
            assert(s_busy === 1'b0);

        //
        // Can send a word
        //
        m_wd = 32'habcdef12;
        en = 1'b1;
        #4 en = 1'b0;
        @(negedge m_busy);
            assert(word === m_wd);
            assert(sck === 1'b1);
            assert(ss === 1'b1);

        for (i = 0; i < 10; i = i + 1) begin
            #8  assert(sck === 1'b1);
                assert(ss === 1'b1);
        end


        //
        // Can send several words
        //
        m_wd = 32'habcdef12;
        en = 1'b1;
        @(negedge m_busy);
            assert(word === m_wd);
            assert(sck === 1'b1);
            assert(ss === 1'b1);
            m_wd = 32'hffffffff;

        @(negedge m_busy);
            assert(word === m_wd);
            assert(sck === 1'b1);
            assert(ss === 1'b1);
            m_wd = 32'haaaaaaaa;

        @(negedge m_busy);
            assert(word === m_wd);
            assert(sck === 1'b1);
            assert(ss === 1'b1);
            m_wd = 32'h55555555;
            en = 1'b0;

        for (i = 0; i < 10; i = i + 1) begin
            #8  assert(sck === 1'b1);
                assert(ss === 1'b1);
        end


        #40;
        $finish;
    end


    reg [31:0] word;
    reg [2:0] cnt;

    always @(posedge s_rdy_sync, posedge rst) begin
        if (rst) begin
            cnt <= 0;
            word <= 0;
        end else begin
            case (cnt)
            3'd0: word[31:24] <= s_rd;
            3'd1: word[23:16] <= s_rd;
            3'd2: word[15:8]  <= s_rd;
            3'd3: word[7:0]   <= s_rd;
            endcase
            cnt <= (cnt == 3'd3 ? 3'd0 : cnt + 1);
        end
    end

endmodule
