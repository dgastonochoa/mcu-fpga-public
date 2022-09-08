`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "pipeline_beq_tb.vcd"
`endif

module pipeline_beq_tb;
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
        $dumpvars(1, pipeline_beq_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 4, 32'd01);

        `CPU_MEM_SET_I(cm, 0, 32'h00400a63);    // beq x0, x4, 20;  pc = 20
        `CPU_MEM_SET_I(cm, 1, 32'h00000863);    // beq x0, x0, 16;  pc = 20
        `CPU_MEM_SET_I(cm, 2, 32'h00000013);    // nop
        `CPU_MEM_SET_I(cm, 3, 32'h00000013);    // nop
        `CPU_MEM_SET_I(cm, 4, 32'h00000013);    // nop
        `CPU_MEM_SET_I(cm, 5, 32'h00400463);    // beq x0, x4, 8;   pc = 28
        `CPU_MEM_SET_I(cm, 6, 32'hfe0004e3);    // beq x0, x0, -24; pc = 0
        `CPU_MEM_SET_I(cm, 7, 32'h00000013);    // nop
        `CPU_MEM_SET_I(cm, 8, 32'h00000013);    // nop
        `CPU_MEM_SET_I(cm, 9, 32'h00000013);    // nop


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        `WAIT_CLKS(clk, 3) assert(pc === 32'd12);
        `WAIT_CLKS(clk, 1) assert(pc === 32'd20);
        `WAIT_CLKS(clk, 3) assert(pc === 32'd32);
        `WAIT_CLKS(clk, 1) assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
