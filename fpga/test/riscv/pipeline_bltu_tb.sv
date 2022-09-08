`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "pipeline_bltu_tb.vcd"
`endif

module pipeline_bltu_tb;
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
        $dumpvars(1, pipeline_bltu_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 4, 32'd04);
        `CPU_SET_R(dut, 5, 32'hffffffff);


        `CPU_MEM_SET_I(cm, 0, 32'h02026e63);  // .L0:    bltu    x4, x0, .Lx
        `CPU_MEM_SET_I(cm, 1, 32'h00406263);  //         bltu    x0, x4, .L2
        `CPU_MEM_SET_I(cm, 2, 32'h00406863);  // .L2:    bltu    x0, x4, .L3
        `CPU_MEM_SET_I(cm, 3, 32'h00000013);  //         nop
        `CPU_MEM_SET_I(cm, 4, 32'h00000013);  //         nop
        `CPU_MEM_SET_I(cm, 5, 32'h00000013);  //         nop
        `CPU_MEM_SET_I(cm, 6, 32'h0202e263);  // .L3:    bltu    x5, x0, .Lx
        `CPU_MEM_SET_I(cm, 7, 32'h00506863);  //         bltu    x0, x5, .L4
        `CPU_MEM_SET_I(cm, 8, 32'h00000013);  //         nop
        `CPU_MEM_SET_I(cm, 9, 32'h00000013);  //         nop
        `CPU_MEM_SET_I(cm, 10, 32'h00000013); //         nop
        `CPU_MEM_SET_I(cm, 11, 32'h00026863); // .L4:    bltu    x4, x0, .Lx
        `CPU_MEM_SET_I(cm, 12, 32'hfc5268e3); //         bltu    x4, x5, .L0
        `CPU_MEM_SET_I(cm, 13, 32'h00000013); //         nop
        `CPU_MEM_SET_I(cm, 14, 32'h00000013); //         nop
        `CPU_MEM_SET_I(cm, 15, 32'h00000013); // .Lx:    nop

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);

        repeat(3) begin
            `WAIT_CLKS(clk, 1);                       // .L0 doesn't jump
            `WAIT_CLKS(clk, 3) assert(pc === 32'd8);
            `WAIT_CLKS(clk, 3) assert(pc === 32'd24);
            `WAIT_CLKS(clk, 1);                       // .L3 doesn't jump
            `WAIT_CLKS(clk, 3) assert(pc === 32'd44);
            `WAIT_CLKS(clk, 1);                       // .L4 doesn't jump
            `WAIT_CLKS(clk, 3) assert(pc === 32'd00);
        end

        #5;
        $finish;
    end

endmodule
