`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "pipeline_bne_tb.vcd"
`endif

module pipeline_bne_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    riscv_legacy dut(
        reg_we,
        mem_we,
        imm_src,
        alu_ctrl,
        alu_src,
        res_src, pc_src,
        instr,
        alu_out,
        mem_rd_data,
        mem_wd_data,
        pc,
        rst,
        clk
    );

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, pipeline_bne_tb);

        dut.rv.c.dp.rf._reg[0] = 32'd00;
        dut.rv.c.dp.rf._reg[4] = 32'd04;

        `SET_MEM_I(0, 32'h00001a63); // bne     x0, x0, .L1
        `SET_MEM_I(1, 32'h00401863); // bne     x0, x4, .L1
        `SET_MEM_I(2, 32'h00000013); // nop
        `SET_MEM_I(3, 32'h00000013); // nop
        `SET_MEM_I(4, 32'h00000013); // nop
        `SET_MEM_I(5, 32'h00001463); // bne     x0, x0, .L2
        `SET_MEM_I(6, 32'hfe4014e3); // bne     x0, x4, .L3
        `SET_MEM_I(7, 32'h00000013); // nop
        `SET_MEM_I(8, 32'h00000013); // nop
        `SET_MEM_I(9, 32'h00000013); // nop

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);

        repeat(3) begin
            `WAIT_CLKS(clk, 3) assert(pc === 32'd12);
            `WAIT_CLKS(clk, 1) assert(pc === 32'd20);
            `WAIT_CLKS(clk, 3) assert(pc === 32'd32);
            `WAIT_CLKS(clk, 1) assert(pc === 32'd0);
        end

        #5;
        $finish;
    end

endmodule
