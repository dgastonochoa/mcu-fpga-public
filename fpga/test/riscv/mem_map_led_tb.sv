`timescale 10ps/1ps

`include "alu.svh"
`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "mem_map_led_tb.vcd"
`endif

module mem_map_led_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire mosi, miso, ss, sck;
    wire [15:0] leds;

    mcu dut(mosi, miso, ss, sck, leds, rst, clk);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_map_led_tb);

        `CPU_SET_R(dut.c, 11, 32'h80000040);               // set a1 as the led periph. base

        `CPU_MEM_SET_I(`MCU_GET_M(dut), 0,  32'h0aa00613); //         addi    a2, x0, 0xaa    # 1: load value to write in leds
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 1,  32'h00c5a023); //         sw      a2, 0(a1)       # 2: write leds
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 2,  32'h0005a683); //         lw      a3, 0(a1)       # 3: read leds back
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 3,  32'h05500613); //         addi    a2, x0, 0x55    # repeat 1
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 4,  32'h00c5a023); //         sw      a2, 0(a1)       # repeat 2
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 5,  32'h0005a683); //         lw      a3, 0(a1)       # repeat 3
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 6,  32'hfff00613); //         addi    a2, x0, -1      # load all 0xff's
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 7,  32'h00c5a023); //         sw      a2, 0(a1)       # repeat 2
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 8,  32'h0005a683); //         lw      a3, 0(a1)       # repeat 3
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 9,  32'h00000613); //         addi    a2, x0, 0       # repeat 1
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 10, 32'h00c5a023); //         sw      a2, 0(a1)       # repeat 2
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 11, 32'h0005a683); //         lw      a3, 0(a1)       # repeat 3
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 12, 32'h000000ef); // .END:   jal     ra, .END        # loop for ever


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        // TODO cycles...
        `WAIT_INIT_CYCLES(clk);

        `WAIT_CLKS(clk, 1) assert(leds === 16'h00aa);
        `WAIT_CLKS(clk, 3) assert(leds === 16'h0055);
        `WAIT_CLKS(clk, 3) assert(leds === 16'hffff);
        `WAIT_CLKS(clk, 3) assert(leds === 16'h0000);

        #5;
        $finish;
    end
endmodule
