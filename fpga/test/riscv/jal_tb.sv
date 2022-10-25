`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "jal_tb.vcd"
`endif

module jal_tb;
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
        $dumpvars(1, jal_tb);

        `CPU_MEM_SET_W(cm, 0, 32'h00c000ef);   // jal ra, +12
        `CPU_MEM_SET_W(cm, 1, 32'h00000013);
        `CPU_MEM_SET_W(cm, 2, 32'h00000013);
        `CPU_MEM_SET_W(cm, 3, 32'h00000013);
        `CPU_MEM_SET_W(cm, 4, 32'h00000013);
        `CPU_MEM_SET_W(cm, 5, 32'h00000013);
        `CPU_MEM_SET_W(cm, 6, 32'h00000013);
        `CPU_MEM_SET_W(cm, 7, 32'hff9ff0ef);   // jal ra, 0x14

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        assert(pc === 0);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 12);
                                    assert(`CPU_GET_R(dut, 1) === 4);

        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 16);
                                    assert(`CPU_GET_R(dut, 1) === 4);
        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 20);
                                    assert(`CPU_GET_R(dut, 1) === 4);
        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 24);
                                    assert(`CPU_GET_R(dut, 1) === 4);
        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 28);
                                    assert(`CPU_GET_R(dut, 1) === 4);

        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 20);
                                    assert(`CPU_GET_R(dut, 1) === 32);

        // Modify first instr. to jump to itself
        `CPU_MEM_SET_W(cm, 0, 32'h000000ef);
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(`CPU_GET_R(dut, 1) === 4);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(`CPU_GET_R(dut, 1) === 4);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(`CPU_GET_R(dut, 1) === 4);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(`CPU_GET_R(dut, 1) === 4);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(`CPU_GET_R(dut, 1) === 4);

        #5 $finish;
    end
endmodule
