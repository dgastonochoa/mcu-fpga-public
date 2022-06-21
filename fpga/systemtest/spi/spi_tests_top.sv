/**
 * Top module for the riscv_single_components_test test.
 *
 */
module spi_tests_top(
    output  wire [7:0]  JA,
    input   wire [15:0] sw,
    input   wire        btnR,
    output  wire [15:0] LED,
    input   wire        CLK100MHZ,
    input   wire        btnC
);
    //
    // Signal filtering
    //
    wire rst, en;

    debounce_filter df(btnC, CLK100MHZ, rst);
    debounce_filter df2(btnR, CLK100MHZ, en);


    //
    // Clock generation
    //
    // 100e6 / 1e5 = 1 kHz
    localparam CLK_PWIDTH = 32'd50000;

    wire clk_1khz;

    clk_div #(.POL(1'd0), .PWIDTH(CLK_PWIDTH)) cd(clk_1khz, CLK100MHZ, rst);


    //
    // SPI test
    //
    // pulse_width = 5 -> period = 10 -> 1 kHz / 10 = 160 Hz.
    localparam SCK_PULSE_WIDTH = 5;

    wire mosi, miso, ss, sck, en_sync;
    wire m_rdy, m_busy, s_rdy, s_busy;

    cell_sync_n #(.N(1)) cs0(clk_1khz, rst, en, en_sync);

    spi_tests #(.SCK_PWIDTH(SCK_PULSE_WIDTH)) dut(
        mosi, miso, ss, sck,
        m_rdy, m_busy, s_rdy, s_busy,
        en_sync, sw[3:0], LED[7:0], clk_1khz, rst);


    //
    // Debug signals
    //
    assign JA[0] = m_rdy;
    assign JA[1] = m_busy;
    assign JA[2] = s_rdy;
    assign JA[3] = s_busy;

    // assign JA[4] = ss;
    // assign JA[5] = sck;

endmodule
