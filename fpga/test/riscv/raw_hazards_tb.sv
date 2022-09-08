`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "raw_hazards_tb.vcd"
`endif

module raw_hazards_tb;
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
        $dumpvars(1, raw_hazards_tb);


        //
        // Forwarding works for the next 3 instructions
        //
        `CPU_SET_R(dut, 1, 32'hff);
        `CPU_SET_R(dut, 2, 32'd0);
        `CPU_SET_R(dut, 3, 32'd1);
        `CPU_SET_R(dut, 4, 32'd1);
        `CPU_SET_R(dut, 5, 32'd2);
        `CPU_SET_R(dut, 6, 32'd13);
        `CPU_SET_R(dut, 7, 32'd0);
        `CPU_SET_R(dut, 8, 32'd0);
        `CPU_SET_R(dut, 9, 32'd0);

        `CPU_MEM_SET_I(cm, 0, 32'h00520433); // add x8, x4, x5  # x8 = 3
        `CPU_MEM_SET_I(cm, 1, 32'h40340133); // sub x2, x8, x3  # x2 = 2
        `CPU_MEM_SET_I(cm, 2, 32'h008364b3); // or  x9, x6, x8  # x9 = hff
        `CPU_MEM_SET_I(cm, 3, 32'h001473b3); // and x7, x8, x1  # x7 = hff

        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 8) === 32'd3);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 2) === 32'd2);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 9) === 32'hf);
        `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 7) === 32'd3);


        //
        // Forwarding works if:
        // instr[M].dst_reg == instr[W].dst_reg == instr[E].src_reg2
        //
        #2  rst = 1;
            `CPU_SET_R(dut, 1, 32'hff);
            `CPU_SET_R(dut, 2, 32'd2);
            `CPU_SET_R(dut, 3, 32'd3);
            `CPU_SET_R(dut, 4, 32'd4);
            `CPU_SET_R(dut, 5, 32'hff);

            `CPU_MEM_SET_I(cm, 0, 32'h003100b3); // add x1, x2, x3
            `CPU_MEM_SET_I(cm, 1, 32'h004180b3); // add x1, x3, x4
            `CPU_MEM_SET_I(cm, 2, 32'h002082b3); // add x5, x2, x1
        #2  rst = 0;

            `WAIT_INIT_CYCLES(clk);
            `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 1) === 32'd5);
            `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 1) === 32'd7);
            `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 5) === 32'd9);


        //
        // Forwarding works if:
        // instr[M].dst_reg == instr[W].dst_reg == instr[E].src_reg1
        //
        #2  rst = 1;
            `CPU_SET_R(dut, 1, 32'hff);
            `CPU_SET_R(dut, 2, 32'd2);
            `CPU_SET_R(dut, 3, 32'd3);
            `CPU_SET_R(dut, 4, 32'd4);
            `CPU_SET_R(dut, 5, 32'hff);

            `CPU_MEM_SET_I(cm, 0, 32'h003100b3); // add x1, x2, x3
            `CPU_MEM_SET_I(cm, 1, 32'h004180b3); // add x1, x3, x4
            `CPU_MEM_SET_I(cm, 2, 32'h001102b3); // add x5, x1, x2
        #2  rst = 0;

            `WAIT_INIT_CYCLES(clk);
            `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 1) === 32'd5);
            `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 1) === 32'd7);
            `WAIT_CLKS(clk, 1) assert(`CPU_GET_R(dut, 5) === 32'd9);

        #20;
        $finish;
    end
endmodule
