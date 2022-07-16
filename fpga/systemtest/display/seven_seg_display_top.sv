`ifdef IVERILOG
    `define CLK_PWIDTH 32'd1
    `define DEBOUNCE_FILTER_WAIT_CLK 1
`else
    // 100e6 / 1e3 = 100 kHz; 1e3 / 2 = 5e2 -> pulse width = 5e2
    `define CLK_PWIDTH 32'd500
    `define DEBOUNCE_FILTER_WAIT_CLK 100
`endif

module seven_seg_display_top(
    input   wire        btnC,
    input   wire [15:0] sw,
    output  wire [15:0] LED,
    output  wire [7:0]  JA,
    output  wire [3:0]  an,
    output  wire [6:0]  seg,
    input   wire        CLK100MHZ
);
    //
    // Deboucne inputs
    //
    wire rst;
    wire [15:0] num;

    debounce_filter #(.WAIT_CLK(`DEBOUNCE_FILTER_WAIT_CLK)) df(
        btnC, CLK100MHZ, rst);

    debounce_filter #(.WAIT_CLK(`DEBOUNCE_FILTER_WAIT_CLK)) df2 [15:0] (
        sw[15:0],
        CLK100MHZ,
        num
    );


    //
    // Clock generation
    //
    wire clk_1khz;

    clk_div #(.POL(1'd0), .PWIDTH(`CLK_PWIDTH)) cd(clk_1khz, CLK100MHZ, rst);


    //
    // 7 segment display controller
    //
    seven_seg_ctrl dut(num, an, seg, clk_1khz, rst);
endmodule
