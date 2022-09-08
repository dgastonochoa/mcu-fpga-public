`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "ori_tb.vcd"
`endif

module ori_tb;
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
        $dumpvars(1, ori_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 4, 32'd00);
        `CPU_SET_R(dut, 5, 32'h01);
        `CPU_SET_R(dut, 6, 32'hfe);

        `CPU_MEM_SET_I(cm, 0, 32'h0fe26013);  // ori x0, x4, 0xfe
        `CPU_MEM_SET_I(cm, 1, 32'h0002e213);  // ori x4, x5, 0x00
        `CPU_MEM_SET_I(cm, 2, 32'h0fe26213);  // ori x4, x4, 0xfe

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 0) === 32'h00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'h01);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'hff);

        #5;
        $finish;
    end

endmodule
