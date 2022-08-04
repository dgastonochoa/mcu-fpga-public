`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "pipeline_blt_tb.vcd"
`endif

module pipeline_blt_tb;
    wire reg_we, mem_we;
    res_src_e res_src;
	pc_src_e pc_src;
	alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    reg clk = 0, rst;

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

    always #10 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, pipeline_blt_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'd04;
        dut.rv.dp.rf._reg[5] = 32'hffffffff;


        `MEM_INSTR[`INSTR_START_IDX + 0]  = 32'h02024e63; // .L0:    blt     x4, x0, .Lx
        `MEM_INSTR[`INSTR_START_IDX + 1]  = 32'h00404263; //         blt     x0, x4, .L2
        `MEM_INSTR[`INSTR_START_IDX + 2]  = 32'h00404863; // .L2:    blt     x0, x4, .L3
        `MEM_INSTR[`INSTR_START_IDX + 3]  = 32'h00000013; //         nop
        `MEM_INSTR[`INSTR_START_IDX + 4]  = 32'h00000013; //         nop
        `MEM_INSTR[`INSTR_START_IDX + 5]  = 32'h00000013; //         nop
        `MEM_INSTR[`INSTR_START_IDX + 6]  = 32'h02504263; // .L3:    blt     x0, x5, .Lx
        `MEM_INSTR[`INSTR_START_IDX + 7]  = 32'h0002c863; //         blt     x5, x0, .L4
        `MEM_INSTR[`INSTR_START_IDX + 8]  = 32'h00000013; //         nop
        `MEM_INSTR[`INSTR_START_IDX + 9]  = 32'h00000013; //         nop
        `MEM_INSTR[`INSTR_START_IDX + 10] = 32'h00000013; //         nop
        `MEM_INSTR[`INSTR_START_IDX + 11] = 32'h00024863; // .L4:    blt     x4, x0, .Lx
        `MEM_INSTR[`INSTR_START_IDX + 12] = 32'hfc42c8e3; //         blt     x5, x4, .L0
        `MEM_INSTR[`INSTR_START_IDX + 13] = 32'h00000013; //         nop
        `MEM_INSTR[`INSTR_START_IDX + 14] = 32'h00000013; //         nop
        `MEM_INSTR[`INSTR_START_IDX + 15] = 32'h00000013; // .Lx:    nop

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);

        // repeat(3) begin
            `WAIT_INSTR_C(clk, 1);                       // .L0 doesn't jump
            `WAIT_INSTR_C(clk, 3) assert(pc === 32'd8);
            `WAIT_INSTR_C(clk, 3) assert(pc === 32'd24);
            `WAIT_INSTR_C(clk, 1);                       // .L3 doesn't jump
            `WAIT_INSTR_C(clk, 3) assert(pc === 32'd44);
            `WAIT_INSTR_C(clk, 1);                       // .L4 doesn't jump
            `WAIT_INSTR_C(clk, 3) assert(pc === 32'd00);
        // end

        #5;
        $finish;
    end

endmodule
