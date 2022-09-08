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


        `CPU_MEM_SET_I(cm,  0, 32'h02407a63);  // bgeu    x0, x4, .L2
        `CPU_MEM_SET_I(cm,  1, 32'h00007263);  // bgeu    x0, x0, .L4
        `CPU_MEM_SET_I(cm,  2, 32'h00027863);  // bgeu    x4, x0, .L1
        `CPU_MEM_SET_I(cm,  3, 32'h00000013);  // nop
        `CPU_MEM_SET_I(cm,  4, 32'h00000013);  // nop
        `CPU_MEM_SET_I(cm,  5, 32'h00000013);  // nop
        `CPU_MEM_SET_I(cm,  6, 32'h00507e63);  // bgeu    x0, x5, .L2
        `CPU_MEM_SET_I(cm,  7, 32'h0002f863);  // bgeu    x5, x0, .L5
        `CPU_MEM_SET_I(cm,  8, 32'h00000013);  // nop
        `CPU_MEM_SET_I(cm,  9, 32'h00000013);  // nop
        `CPU_MEM_SET_I(cm,  10, 32'h00000013);  // nop
        `CPU_MEM_SET_I(cm,  11, 32'h00407463);  // bgeu    x0, x4, .L2
        `CPU_MEM_SET_I(cm,  12, 32'hfc52f8e3);  // bgeu    x5, x5, .L3
        `CPU_MEM_SET_I(cm,  13, 32'h00000013);  // nop
        `CPU_MEM_SET_I(cm,  14, 32'h00000013);  // nop
        `CPU_MEM_SET_I(cm,  15, 32'h00000013);  // nop

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
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
