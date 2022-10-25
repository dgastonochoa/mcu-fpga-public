`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv/mem_map.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "lbu_tb.vcd"
`endif

module lbu_tb;
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
        $dumpvars(1, lbu_tb);

        // Set register init. vals
        `CPU_SET_R(dut, 0, 32'd0);
        `CPU_SET_R(dut, 2, (`SEC_DATA_W * 4) + 8);
        `CPU_SET_R(dut, 6, 32'd0);

        // Set mem. init. vals
        `CPU_MEM_SET_D(cm, `SEC_DATA_W + 1, 32'hdeadc0de);
        `CPU_MEM_SET_D(cm, `SEC_DATA_W + 2, 32'hdeadbeef);
        `CPU_MEM_SET_D(cm, `SEC_DATA_W + 3, 32'hc001c0de);

        // Load words with different addresses
        // Last instr. is to try to load word into x0
        `CPU_MEM_SET_I(cm, 0, 32'hffc14303);    // lbu x6, -4(sp)
        `CPU_MEM_SET_I(cm, 1, 32'h00014303);    // lbu x6, 0(sp)
        `CPU_MEM_SET_I(cm, 2, 32'h00414303);    // lbu x6, 4(sp)
        `CPU_MEM_SET_I(cm, 3, 32'h00414003);    // lbu x0, 4(sp)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `L_I_CYC) assert(`CPU_GET_R(dut, 6) === 32'h000000de);
        `WAIT_CLKS(clk, `L_I_CYC) assert(`CPU_GET_R(dut, 6) === 32'h000000ef);
        `WAIT_CLKS(clk, `L_I_CYC) assert(`CPU_GET_R(dut, 6) === 32'h000000de);
        `WAIT_CLKS(clk, `L_I_CYC) assert(`CPU_GET_R(dut, 0) === 32'h00000000);

        #20;
        $finish;
    end
endmodule
