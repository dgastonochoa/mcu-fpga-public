`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "riscv_single_tb.vcd"
`endif

module riscv_single_tb;

    reg [3:0] sw;
    logic [15:0] leds;

    reg clk = 0, rst = 0;

    riscv_single dut(sw, leds, clk, rst);

    always #1 clk <= ~clk;

    wire slow_clk;

    assign slow_clk = dut.slow_clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, riscv_single_tb);
        #2  rst = 1;
            sw = 4'd0;
        #6  rst = 0;
            assert(leds[15:8] === 8'd0);
            assert(leds[7:0] === 8'd0);

        #4  assert(leds[15:8] === 8'd4);
            assert(leds[7:0] === 8'd1);

        #8  assert(leds[15:8] === 8'd8);
            assert(leds[7:0] === 8'd1);

        #8  assert(leds[15:8] === 8'd12);
            assert(leds[7:0] === 8'd2);

        #8  assert(leds[15:8] === 8'd16);
            assert(leds[7:0] === 8'd3);

        #8  assert(leds[15:8] === 8'd20);
            assert(leds[7:0] === 8'd4);

        #8  assert(leds[15:8] === 8'd24);

        #8  assert(leds[15:8] === 8'd00);

        #30 $finish;
    end
endmodule
