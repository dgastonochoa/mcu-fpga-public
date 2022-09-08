`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "lw_tb.vcd"
`endif

module lw_tb;
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
        $dumpvars(1, lw_tb);

        // Set register init. vals
        `CPU_SET_R(dut, 0, 32'd0);
        `CPU_SET_R(dut, 6, 32'd0);
        `CPU_SET_R(dut, 9, (`CPU_MEM_DATA_START_IDX * 4) + 8);

        // Set mem. init. vals
        `CPU_MEM_SET_D(cm, 1, 32'hdeadc0de);
        `CPU_MEM_SET_D(cm, 2, 32'hdeadbeef);
        `CPU_MEM_SET_D(cm, 3, 32'hc001c0de);

        // Load words with different addresses
        // Last instr. is to try to load word into x0
        `CPU_MEM_SET_I(cm, 0, 32'hffc4a303); // lw x6, -4(x9)
        `CPU_MEM_SET_I(cm, 1, 32'h0004a303); // lw x6, 0(x9)
        `CPU_MEM_SET_I(cm, 2, 32'h0044a303); // lw x6, 4(x9)
        `CPU_MEM_SET_I(cm, 3, 32'h0044a003); // lw x0, 4(x9)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `L_I_CYC) assert(`CPU_GET_R(dut, 6) === 32'hdeadc0de);
        `WAIT_CLKS(clk, `L_I_CYC) assert(`CPU_GET_R(dut, 6) === 32'hdeadbeef);
        `WAIT_CLKS(clk, `L_I_CYC) assert(`CPU_GET_R(dut, 6) === 32'hc001c0de);
        `WAIT_CLKS(clk, `L_I_CYC) assert(`CPU_GET_R(dut, 0) === 32'h00);

        #20;
        $finish;
    end
endmodule
