`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "addi_tb.vcd"
`endif

module addi_tb;
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
        $dumpvars(1, addi_tb);

        //
        // init. x0 as 0
        //
        `CPU_SET_R(dut, 0, 32'd0);

        //
        // addi does not write on x0
        //
        `CPU_MEM_SET_I(cm, 0, 32'h01420013);   // addi x0, x4, 20

        //
        // load values work
        //
        `CPU_MEM_SET_I(cm, 1, 32'h00a00213);   // addi x4, x0, 10
        `CPU_MEM_SET_I(cm, 2, 32'h01400293);   // addi x5, x0, 20

        //
        // add possitive and negative, same reg., works
        //
        `CPU_MEM_SET_I(cm, 3, 32'hff620213);   // addi x4, x4, -10
        `CPU_MEM_SET_I(cm, 4, 32'hff620213);   // addi x4, x4, -10
        `CPU_MEM_SET_I(cm, 5, 32'h00a20213);   // addi x4, x4, 10
        `CPU_MEM_SET_I(cm, 6, 32'h00a20213);   // addi x4, x4, 10

        //
        // move from one reg. to other, reset to 0 and add other works
        //
        `CPU_MEM_SET_I(cm, 7, 32'h00028213);   // addi x4, x5, 0
        `CPU_MEM_SET_I(cm, 8, 32'h00000213);   // addi x4, zero, 0
        `CPU_MEM_SET_I(cm, 9, 32'h01428213);   // addi x4, x5, 20

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 0) === 32'd00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd10);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 5) === 32'd20);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === -10);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd10);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd20);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd40);

        $finish;
    end
endmodule
