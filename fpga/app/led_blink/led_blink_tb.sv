`timescale 10ps/1ps

`ifndef VCD
    `define VCD "led_blink_tb.vcd"
`endif

module led_blink_tb;

    //
    // Debug signals
    //
    wire slow_clk;
    wire blink_led;
    wire [31:0] timer;


    wire [15:0] leds;
    reg clk = 0;
    reg rst = 1'bx;
    reg sw = 1'bx;

    led_blink lb(sw, leds, slow_clk, blink_led, timer, clk, rst);

    always #1 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, led_blink_tb);
        #20 rst = 1;
        #10 rst = 0;
        #100;
        $finish;
    end
endmodule
