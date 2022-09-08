`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "pipeline_jalr_tb.vcd"
`endif

module pipeline_jalr_tb;
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
        $dumpvars(1, pipeline_jalr_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 1, 32'd00);
        `CPU_SET_R(dut, 2, 32'd2);
        `CPU_SET_R(dut, 3, 32'd3);
        `CPU_SET_R(dut, 4, 32'd4);
        `CPU_SET_R(dut, 5, 32'd5);
        `CPU_SET_R(dut, 6, 32'd6);
        `CPU_SET_R(dut, 7, 32'd4);

        `CPU_MEM_SET_I(cm, 0, 32'h00c380e7); // jalr    x1, x7, 12
        `CPU_MEM_SET_I(cm, 1, 32'h00510113); // addi    x2, x2, 5
        `CPU_MEM_SET_I(cm, 2, 32'h00518193); // addi    x3, x3, 5
        `CPU_MEM_SET_I(cm, 3, 32'h00520213); // addi    x4, x4, 5
        `CPU_MEM_SET_I(cm, 4, 32'h00a28293); // addi    x5, x5, 10
        `CPU_MEM_SET_I(cm, 5, 32'hffc38367); // jalr    x6, x7, -4
        `CPU_MEM_SET_I(cm, 6, 32'h00000013); // nop
        `CPU_MEM_SET_I(cm, 7, 32'h00000013); // nop


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);

        `WAIT_CLKS(clk, 3) assert(pc === 32'd16);
        `WAIT_CLKS(clk, 2) assert(`CPU_GET_R(dut, 1) === 32'd4);
        `WAIT_CLKS(clk, 2) assert(pc === 32'd0);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 2) === 32'd2);
                           assert(`CPU_GET_R(dut, 3) === 32'd3);
                           assert(`CPU_GET_R(dut, 5) === 32'd15);


        // This first wait must be only 2 because of the last wait in the
        // above section
        `WAIT_CLKS(clk, 2) assert(pc === 32'd16);
        `WAIT_CLKS(clk, 2) assert(`CPU_GET_R(dut, 1) === 32'd4);
        `WAIT_CLKS(clk, 2) assert(pc === 32'd0);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 2) === 32'd2);
                           assert(`CPU_GET_R(dut, 3) === 32'd3);
                           assert(`CPU_GET_R(dut, 5) === 32'd25);

        // Same as above
        `WAIT_CLKS(clk, 2) assert(pc === 32'd16);
        `WAIT_CLKS(clk, 2) assert(`CPU_GET_R(dut, 1) === 32'd4);
        `WAIT_CLKS(clk, 2) assert(pc === 32'd0);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 2) === 32'd2);
                           assert(`CPU_GET_R(dut, 3) === 32'd3);
                           assert(`CPU_GET_R(dut, 5) === 32'd35);

        #5;
        $finish;
    end

endmodule
