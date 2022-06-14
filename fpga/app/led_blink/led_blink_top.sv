// TODO declare inputs/outputs as in normal source files
module led_blink_top(
    input   wire        CLK100MHZ,
    input   wire [15:0] sw,
    output  wire        vauxp6,
    output  wire        vauxp14,
    output  wire [15:0] LED,
    input   wire        btnC
);

    wire rst;

    debounce_filter df(btnC, CLK100MHZ, rst);

    wire slow_clk, blink_led;
    wire [31:0] timer;

    led_blink dut(sw, LED, slow_clk, blink_led, timer, CLK100MHZ, rst);

    assign vauxp6 = slow_clk;
    assign vauxp14 = blink_led;
endmodule
