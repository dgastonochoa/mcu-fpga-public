`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "srai_tb.vcd"
`endif

module srai_tb;
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
        $dumpvars(1, srai_tb);

        `CPU_SET_R(dut, 4, 32'b00);
        `CPU_SET_R(dut, 5, 32'h08);
        `CPU_SET_R(dut, 7, 32'hfffffff8);

        `CPU_MEM_SET_W(cm, 0, 32'h4022d213);   // srai     x4, x5, 2
        `CPU_MEM_SET_W(cm, 1, 32'h4023d213);   // srai     x4, x7, 2

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'h02);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'hfffffffe);

        #5;
        $finish;
    end

endmodule
