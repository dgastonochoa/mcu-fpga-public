`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "blt_tb.vcd"
`endif

module blt_tb;
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
        $dumpvars(1, blt_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 4, 32'd4);
        `CPU_SET_R(dut, 5, 32'hffffffff);

        // blt'ing these 2 regs. (a < b; a = big. neg. num., b = 2)
        // will produce the special case in which comparing two
        // signed numbers a and b, begin a less than b, won't cause
        // an ALU's neg flag, but an overflow.
        `CPU_SET_R(dut, 6, 32'h80000000);
        `CPU_SET_R(dut, 7, 32'h00000002);


        `CPU_MEM_SET_I(cm,  0, 32'h02024e63);
        `CPU_MEM_SET_I(cm,  1, 32'h02004c63);
        `CPU_MEM_SET_I(cm,  2, 32'h00404863);
        `CPU_MEM_SET_I(cm,  3, 32'h00000013);
        `CPU_MEM_SET_I(cm,  4, 32'h00000013);
        `CPU_MEM_SET_I(cm,  5, 32'h00000013);
        `CPU_MEM_SET_I(cm,  6, 32'h02504263);
        `CPU_MEM_SET_I(cm,  7, 32'h0002c863);
        `CPU_MEM_SET_I(cm,  8, 32'h00000013);
        `CPU_MEM_SET_I(cm,  9, 32'h00000013);
        `CPU_MEM_SET_I(cm,  10, 32'h00000013);
        `CPU_MEM_SET_I(cm,  11, 32'h00024863);
        `CPU_MEM_SET_I(cm,  12, 32'h0002c463);
        `CPU_MEM_SET_I(cm,  13, 32'h00000013);
        `CPU_MEM_SET_I(cm,  14, 32'hfc7344e3);
        `CPU_MEM_SET_I(cm,  15, 32'h00000013);
        `CPU_MEM_SET_I(cm,  16, 32'h00000013);
        `CPU_MEM_SET_I(cm,  17, 32'h00000013);


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd4);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd8);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd24);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd28);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd44);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd48);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd56);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
