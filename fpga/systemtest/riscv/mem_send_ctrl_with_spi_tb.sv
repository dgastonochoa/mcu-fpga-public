`timescale 10ps/1ps

`ifndef VCD
    `define VCD "mem_send_ctrl_with_spi_tb.vcd"
`endif

module mem_send_ctrl_with_spi_tb;
    reg clk = 0;

    always #3 clk = ~clk;

    reg rst = 0;


    //
    // Memory send controller (DUT)
    //
    wire si_busy;
    wire [31:0] tm_d_addr;
    wire tm;
    wire si_en;

    mem_send_ctrl dut(si_busy, tm_d_addr, tm, si_en, clk, rst);


    //
    // Memory mock
    //
    logic [31:0] tm_d_rd;

    always_comb begin
        case (tm_d_addr)
        4'd00: tm_d_rd = 32'haaaaaaaa;
        4'd04: tm_d_rd = 32'hffffffff;
        4'd08: tm_d_rd = 32'h55555555;
        4'd12: tm_d_rd = 32'h00000000;
        default: tm_d_rd = 32'bx;
        endcase
    end


    //
    // SPI master w
    //
    // pulse_width = 10 -> period = 20 -> 1 kHz / 20 = 50 Hz.
    localparam SCK_PULSE_WIDTH = 10;

    wire mosi, miso, ss, sck;

    spi_master_w #(.SCK_WIDTH_CLKS(SCK_PULSE_WIDTH)) smw(
        mosi, miso, ss, sck, tm_d_rd, si_en, si_busy, clk, rst);


    //
    // SPI slave
    //
    reg [7:0] s_wd = 8'd0;
    wire s_busy, s_rdy;
    wire [7:0] s_rd;

    spi_slave spis(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, rst, sck, clk);

    reg [31:0] word;
    reg [2:0] cnt;
    reg word_rdy;
    wire s_rdy_sync;

    cell_sync_n #(.N(1)) c_sync0(clk, rst, s_rdy, s_rdy_sync);

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


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_send_ctrl_with_spi_tb);
        #12 rst = 1'b1;
        #12 rst = 1'b0;

        @(negedge si_busy);
            assert(word === 32'haaaaaaaa);

        @(negedge si_busy);
            assert(word === 32'hffffffff);

        @(negedge si_busy);
            assert(word === 32'h55555555);

        @(negedge si_busy);
            assert(word === 32'h00000000);

        #1000 $finish;
    end
endmodule
