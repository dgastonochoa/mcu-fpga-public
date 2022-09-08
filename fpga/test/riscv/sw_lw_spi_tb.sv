`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_spi_tb.vcd"
`endif

module sw_spi_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    reg [7:0] s_wd = 8'haa;
    wire s_busy, s_rdy, mosi, miso, ss, sck;
    wire [7:0] s_rd;

    spi_slave spis(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, rst, sck, clk);


    wire [15:0] leds;

    mcu dut(mosi, miso, ss, sck, leds, rst, clk);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sw_spi_tb);

        `CPU_SET_R(`MCU_GET_C(dut), 3, 32'hdeadc0de);
        `CPU_SET_R(`MCU_GET_C(dut), 9, 32'h80000000);

        `CPU_MEM_SET_I(`MCU_GET_M(dut), 0, 32'h0034a023);  //         sw      x3, 0(x9)    # write data to be send
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 1, 32'h00400213);  //         addi    x4, x0, 0x04 # set send flag
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 2, 32'h0044a223);  //         sw      x4, 4(x9)    # trigger send
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 3, 32'h0044a183);  // .L1:    lw      x3, 4(x9)    # read status
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 4, 32'h0021f193);  //         andi    x3, x3, 0x2  # get busy flag
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 5, 32'hfe019ce3);  //         bne     x3, x0, .L1  # if busy != 0 keep polling
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 6, 32'h0044a183);  // .L2:    lw      x3, 4(x9)    # read status
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 7, 32'h0011f193);  //         andi    x3, x3, 0x1  # rdy flag
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 8, 32'hfe018ce3);  //         beq     x3, x0, .L2  # if rdy == 0 keep polling
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 9, 32'h0004a203);  //         lw      x4, 0(x9)    # read received data
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 10, 32'h000000ef); // .L3:    jal     .L3          # loop for ever


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_CLKS(clk, 100) assert(s_rdy === 1'b1);
                             assert(s_rd === 8'hde);
                             assert(`CPU_GET_R(`MCU_GET_C(dut), 4) === 8'haa);

        #5;
        $finish;
    end
endmodule
