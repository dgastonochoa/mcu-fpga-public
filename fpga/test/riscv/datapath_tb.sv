`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "datapath_tb.vcd"
`endif

module datapath_tb;
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
        $dumpvars(1, datapath_tb);

        `CPU_SET_R(dut, 9, (`CPU_MEM_DATA_START_IDX * 4) + 8);
        `CPU_SET_R(dut, 4, 32'd0);
        `CPU_SET_R(dut, 5, 32'hfffffffe);
        `CPU_SET_R(dut, 6, 32'd0);

        `CPU_MEM_SET_D(cm, 1, 32'hdeadc0de);
        `CPU_MEM_SET_D(cm, 4, 32'h00);

        `CPU_MEM_SET_I(cm, 0, 32'hffc4a303);    // lw x6, -4(x9)
        `CPU_MEM_SET_I(cm, 1, 32'h0064a423);    // sw x6, 8(x9)
        `CPU_MEM_SET_I(cm, 2, 32'h0062e233);    // or x4, x5, x6
        `CPU_MEM_SET_I(cm, 3, 32'hfe420ae3);    // beq x4, x4, L7

        // Reset
        #2  rst = 1;
        #2  rst = 0;
        assert(pc === 0);

        // First instr. executed
        `WAIT_CLKS(clk, `L_I_CYC) assert(pc === 4);
                                  assert(`CPU_GET_R(dut, 6) === 32'hdeadc0de);

        // Second instr. executed
        `WAIT_CLKS(clk, `S_I_CYC) assert(pc === 8);
                                  assert(`CPU_MEM_GET_D(cm, 4) === 32'hdeadc0de);

        // Third instr. executed
        `WAIT_CLKS(clk, `R_I_CYC) assert(pc === 12);
                                  assert(`CPU_GET_R(dut, 4) === 32'hfffffffe);

        // Fourth instr. executed, branched to
        // starting address.
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 0);

        // First instr. executed again.
        `WAIT_CLKS(clk, `L_I_CYC) assert(pc === 4);
                                  assert(`CPU_GET_R(dut, 6) === 32'hdeadc0de);

        // Second instr. executed again.
        `WAIT_CLKS(clk, `S_I_CYC) assert(pc === 8);
                                  assert(`CPU_MEM_GET_D(cm, 4) === 32'hdeadc0de);

        // Third instr. executed again
        `WAIT_CLKS(clk, `R_I_CYC) assert(pc === 12);
                                  assert(`CPU_GET_R(dut, 4) === 32'hfffffffe);

        // Fourth instr. executed again, branched to
        // starting address.
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 0);

        #5;
        $finish;
    end
endmodule
