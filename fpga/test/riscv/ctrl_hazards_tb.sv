`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "ctrl_hazards_tb.vcd"
`endif

module ctrl_hazards_tb;
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
        $dumpvars(1, ctrl_hazards_tb);

        //
        // beq correctly flushes if required
        //
        #2  rst = 1;
            `CPU_SET_R(dut, 1, 32'h01);
            `CPU_SET_R(dut, 2, 32'd01);
            `CPU_SET_R(dut, 3, 32'd04);
            `CPU_SET_R(dut, 4, 32'd25);
            `CPU_SET_R(dut, 5, 32'd7);

            `CPU_MEM_SET_W(cm, 0, 32'h00208a63); //         beq x1, x2, .L1
            `CPU_MEM_SET_W(cm, 1, 32'h401201b3); //         sub x3, x4, x1
            `CPU_MEM_SET_W(cm, 2, 32'h0020e233); //         or  x4, x1, x2
            `CPU_MEM_SET_W(cm, 3, 32'h00000013); //         nop
            `CPU_MEM_SET_W(cm, 4, 32'h00000013); //         nop
            `CPU_MEM_SET_W(cm, 5, 32'h001281b3); // .L1:    add x3, x5, x1
        #2  rst = 0;

        `WAIT_CLKS(clk, 5); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd4);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        `WAIT_CLKS(clk, 1); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd4);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        `WAIT_CLKS(clk, 1); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd4);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        `WAIT_CLKS(clk, 1); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd8);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);


        //
        // beq correctly flushes if required 2
        //
        #2  rst = 1;
            `CPU_SET_R(dut, 1, 32'h01);
            `CPU_SET_R(dut, 2, 32'd01);
            `CPU_SET_R(dut, 3, 32'd04);
            `CPU_SET_R(dut, 4, 32'd25);
            `CPU_SET_R(dut, 5, 32'd7);

            `CPU_MEM_SET_W(cm, 0, 32'h00208a63); //         beq x1, x2, .L1
            `CPU_MEM_SET_W(cm, 1, 32'h401201b3); //         sub x3, x4, x1
            `CPU_MEM_SET_W(cm, 2, 32'h0020e233); //         or  x4, x1, x2
            `CPU_MEM_SET_W(cm, 3, 32'h00000013); //         nop
            `CPU_MEM_SET_W(cm, 4, 32'h00000013); //         nop
            `CPU_MEM_SET_W(cm, 5, 32'h003280b3); // .L1:    add x1, x5, x3
        #2  rst = 0;

        `WAIT_CLKS(clk, 5); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd4);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        `WAIT_CLKS(clk, 1); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd4);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        `WAIT_CLKS(clk, 1); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd4);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        `WAIT_CLKS(clk, 1); assert(`CPU_GET_R(dut, 1) === 32'd11);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd4);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);


        //
        // beq does not flush if not required
        //
        #2  rst = 1;
            `CPU_SET_R(dut, 1, 32'h01);
            `CPU_SET_R(dut, 2, 32'd01);
            `CPU_SET_R(dut, 3, 32'd04);
            `CPU_SET_R(dut, 4, 32'd25);
            `CPU_SET_R(dut, 5, 32'd7);

            `CPU_MEM_SET_W(cm, 0, 32'h00308a63); //         beq x1, x3, .L1
            `CPU_MEM_SET_W(cm, 1, 32'h401201b3); //         sub x3, x4, x1
            `CPU_MEM_SET_W(cm, 2, 32'h0020e233); //         or  x4, x1, x2
            `CPU_MEM_SET_W(cm, 3, 32'h00000013); //         nop
            `CPU_MEM_SET_W(cm, 4, 32'h00000013); //         nop
            `CPU_MEM_SET_W(cm, 5, 32'h003280b3); // .L1:    add x1, x5, x3
        #2  rst = 0;

        `WAIT_CLKS(clk, 5); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd4);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        `WAIT_CLKS(clk, 1); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd24);
                            assert(`CPU_GET_R(dut, 4) === 32'd25);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        `WAIT_CLKS(clk, 1); assert(`CPU_GET_R(dut, 1) === 32'd1);
                            assert(`CPU_GET_R(dut, 2) === 32'd1);
                            assert(`CPU_GET_R(dut, 3) === 32'd24);
                            assert(`CPU_GET_R(dut, 4) === 32'd1);
                            assert(`CPU_GET_R(dut, 5) === 32'd7);

        #20;
        $finish;
    end
endmodule
