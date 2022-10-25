`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "bltu_tb.vcd"
`endif

module bltu_tb;
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
        $dumpvars(1, bltu_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 4, 32'd1);
        `CPU_SET_R(dut, 5, 32'hffffffff);

        `CPU_MEM_SET_W(cm,  0, 32'h02026463);  // bltu    x4, x0, .L2
        `CPU_MEM_SET_W(cm,  1, 32'h02006263);  // bltu    x0, x0, .L2
        `CPU_MEM_SET_W(cm,  2, 32'h00406863);  // bltu    x0, x4, .L1
        `CPU_MEM_SET_W(cm,  3, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  4, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  5, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  6, 32'hfe5064e3);  // bltu    x0, x5, .L3
        `CPU_MEM_SET_W(cm,  7, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  8, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  9, 32'h00000013); // nop
        `CPU_MEM_SET_W(cm,  10, 32'h00000013); // nop
        `CPU_MEM_SET_W(cm,  11, 32'h00000013); // nop
        `CPU_MEM_SET_W(cm,  12, 32'h00000013); // nop


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd4);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd8);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd24);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
