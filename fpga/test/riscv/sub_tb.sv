`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sub_tb.vcd"
`endif

module sub_tb;
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
        $dumpvars(1, sub_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 4, 32'd50);
        `CPU_SET_R(dut, 5, 32'd50);
        `CPU_SET_R(dut, 6, 32'd100);

        `CPU_MEM_SET_W(cm, 0, 32'h40620033);  // sub x0, x4, x6
        `CPU_MEM_SET_W(cm, 1, 32'h40520233);  // sub x4, x4, x5
        `CPU_MEM_SET_W(cm, 2, 32'h40620233);  // sub x4, x4, x6

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `R_I_CYC) assert(`CPU_GET_R(dut, 0) === 32'h00);
        `WAIT_CLKS(clk, `R_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'h00);
        `WAIT_CLKS(clk, `R_I_CYC) assert(`CPU_GET_R(dut, 4) === -100);

        #5;
        $finish;
    end

endmodule
