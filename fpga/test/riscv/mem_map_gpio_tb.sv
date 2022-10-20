`timescale 10ps/1ps

`include "alu.svh"

`include "riscv/mem_map.svh"

`include "riscv/test/test_mcu.svh"
`include "riscv/test/test_cpu.svh"
`include "riscv/test/test_cpu_mem.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "mem_map_gpio_tb.vcd"
`endif

module mem_map_gpio_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire mosi, miso, ss, sck;
    wire [15:0] leds;

    reg [7:0] gpios;

    mcu dut(mosi, miso, ss, sck, gpios, leds, rst, clk);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_map_gpio_tb);

        `CPU_SET_R(`MCU_GET_C(dut), 2, `SEC_DATA_W * 4);
        `CPU_SET_R(`MCU_GET_C(dut), 11, 32'h80000080);     // set a1 as the gpios periph. base
        `CPU_SET_R(`MCU_GET_C(dut), 6,  32'h00000000);     // set t1 as 0

        `CPU_MEM_SET_W(`MCU_GET_M(dut), 0,  32'h0005a303); //   lw      t1, 0(a1)   # read gpios
        `CPU_MEM_SET_W(`MCU_GET_M(dut), 1,  32'h00612023); //   sw      t1, 0(sp)   # store result
        `CPU_MEM_SET_W(`MCU_GET_M(dut), 2,  32'h0005a303); //   lw      t1, 0(a1)   # read gpios
        `CPU_MEM_SET_W(`MCU_GET_M(dut), 3,  32'h00612023); //   sw      t1, 0(sp)   # store result
        `CPU_MEM_SET_W(`MCU_GET_M(dut), 4,  32'h0005a303); //   lw      t1, 0(a1)   # read gpios
        `CPU_MEM_SET_W(`MCU_GET_M(dut), 5,  32'h00612023); //   sw      t1, 0(sp)   # store result

        // Reset and test
        gpios = 8'hff;

        #2  rst = 1;
        #2  rst = 0;

        // TODO Once GPIOs can be written, improve this test to not depend on the
        // amount of cycles (by improving the test program above)
        `WAIT_CLKS(clk, 2) gpios = 8'h55;
                           assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W) === 32'hff);

        `WAIT_CLKS(clk, 2) gpios = 8'haa;
                           assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W) === 32'h55);

        `WAIT_CLKS(clk, 2) assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W) === 32'haa);

        #5;
        $finish;
    end
endmodule
