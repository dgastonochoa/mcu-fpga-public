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
    wire [3:0] _sw;

    debounce_filter df(btnC, CLK100MHZ, rst);
    debounce_filter df2(btnR, CLK100MHZ, en);
    debounce_filter df3(sw[0], CLK100MHZ, _sw[0]);
    debounce_filter df4(sw[1], CLK100MHZ, _sw[1]);
    debounce_filter df5(sw[2], CLK100MHZ, _sw[2]);
    debounce_filter df6(sw[3], CLK100MHZ, _sw[3]);


    //
    // Clock generation
    //
    // 100e6 / 1e5 = 1 kHz; 1e5 / 2 = 5e4 -> pulse width = 5e4
    localparam CLK_PWIDTH = 32'd50000;

    wire clk_1khz;

    clk_div #(.POL(1'd0), .PWIDTH(CLK_PWIDTH)) cd(clk_1khz, CLK100MHZ, rst);


    //
    // SPI test
    //
    // pulse_width = 10 -> period = 20 -> 1 kHz / 20 = 50 Hz.
    localparam SCK_PULSE_WIDTH = 10;

    wire [7:0] m_wd, s_wd;
    wire mosi, mosi, ss, sck;

    cell_sync_n #(.N(1)) cs0(clk_1khz, rst, en, en_sync);

    spi_tests #(.SCK_PWIDTH(SCK_PULSE_WIDTH)) dut(
        en_sync,
        _sw,
        LED[7:0],
        m_wd,
        s_wd,
        mosi,
        miso,
        ss,
        sck,
        clk_1khz,
        rst
    );

    assign JA[0] = mosi;
    assign JA[1] = miso;
    assign JA[2] = ss;
    assign JA[3] = sck;
endmodule
