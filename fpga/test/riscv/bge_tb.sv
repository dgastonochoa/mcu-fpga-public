`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "bge_tb.vcd"
`endif

module bge_tb;
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
        $dumpvars(1, bge_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 4, 32'd04);
        `CPU_SET_R(dut, 5, 32'hffffffff);


        `CPU_MEM_SET_W(cm,  0, 32'h02405a63);  // bge     x0, x4, 52
        `CPU_MEM_SET_W(cm,  1, 32'h00005263);  // bge     x0, x0, 4
        `CPU_MEM_SET_W(cm,  2, 32'h00025863);  // bge     x4, x0, 12
        `CPU_MEM_SET_W(cm,  3, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  4, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  5, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  6, 32'h0002de63);  // bge     x5, x0, 36
        `CPU_MEM_SET_W(cm,  7, 32'h00505863);  // bge     x0, x5, 16
        `CPU_MEM_SET_W(cm,  8, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  9, 32'h00000013);  // nop
        `CPU_MEM_SET_W(cm,  10, 32'h00000013); // nop
        `CPU_MEM_SET_W(cm,  11, 32'h00405463); // bge     x0, x4, 8
        `CPU_MEM_SET_W(cm,  12, 32'hfc52d8e3); // bge     x5, x5, -48
        `CPU_MEM_SET_W(cm,  13, 32'h00000013); // nop
        `CPU_MEM_SET_W(cm,  14, 32'h00000013); // nop
        `CPU_MEM_SET_W(cm,  15, 32'h00000013); // nop


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
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd04);

        #5;
        $finish;
    end

endmodule
