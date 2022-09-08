`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "lw_hazards_tb.vcd"
`endif

module lw_hazards_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire [31:0] instr, d_rd, d_addr, d_wd, pc;
    wire d_we;
    mem_dt_e d_dt;

    cpu dut(instr, d_rd, d_addr, d_we, d_wd, d_dt, pc, rst, clk);


    errno_e  err;

    cpu_mem cm(
        pc, d_addr, d_wd, d_we, d_dt, instr, d_rd, err, clk);


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, lw_hazards_tb);

        //
        // Basic stall works
        //
        #2  rst = 1;
            `CPU_SET_R(dut, 1, 32'h00);
            `CPU_SET_R(dut, 2, 32'd3);
            `CPU_SET_R(dut, 3, 32'h00);
            `CPU_SET_R(dut, 4, 32'h00);
            `CPU_SET_R(dut, 5, 32'd7);
            `CPU_SET_R(dut, 6, 32'h00);
            `CPU_SET_R(dut, 7, 32'd1);

            `CPU_MEM_SET_D(cm, 0, 32'hdeadc0de);

            `CPU_MEM_SET_I(cm, 0, 32'h00002083); // lw  x1, 0(x0)
            `CPU_MEM_SET_I(cm, 1, 32'h0020f1b3); // and x3, x1, x2
            `CPU_MEM_SET_I(cm, 2, 32'h0012e233); // or  x4, x5, x1
            `CPU_MEM_SET_I(cm, 3, 32'h40708333); // sub x6, x1, x7
        #2  rst = 0;

        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 1) === 32'hdeadc0de);
        `WAIT_CLKS(clk, 1); // stall
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 3) === 32'h2);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 4) === 32'hdeadc0df);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 6) === 32'hdeadc0dd);


        //
        // Stall and then forward works
        //
        #2  rst = 1;
            `CPU_SET_R(dut, 1, 32'h00);
            `CPU_SET_R(dut, 2, 32'd3);
            `CPU_SET_R(dut, 3, 32'h5);
            `CPU_SET_R(dut, 4, 32'h00);

            `CPU_MEM_SET_D(cm, 0, 32'hdeadc0de);

            `CPU_MEM_SET_I(cm, 0, 32'h00002083); // lw  x1, 0(x0)
            `CPU_MEM_SET_I(cm, 1, 32'h003100b3); // add x1, x2, x3
            `CPU_MEM_SET_I(cm, 2, 32'h00208233); // add x4, x1, x2
        #2  rst = 0;

        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 1) === 32'hdeadc0de);
        `WAIT_CLKS(clk, 1); // stall
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 1) === 32'd8);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 4) === 32'd11);

        #20;
        $finish;
    end
endmodule
