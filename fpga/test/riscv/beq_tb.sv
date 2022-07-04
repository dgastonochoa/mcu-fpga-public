`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "beq_tb.vcd"
`endif

`ifdef CONFIG_RISCV_SINGLECYCLE
    `define N_CLKS 1
`elsif CONFIG_RISCV_MULTICYCLE
    `define N_CLKS 3
`endif

module beq_tb;
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
        $dumpvars(1, beq_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'd01;

        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h00400a63;    // beq x0, x4, 20;  pc = 20
        `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h00000863;    // beq x0, x0, 16;  pc = 20
        `MEM_INSTR[`INSTR_START_IDX + 2] = 32'h00000013;    // nop
        `MEM_INSTR[`INSTR_START_IDX + 3] = 32'h00000013;    // nop
        `MEM_INSTR[`INSTR_START_IDX + 4] = 32'h00000013;    // nop
        `MEM_INSTR[`INSTR_START_IDX + 5] = 32'h00400463;    // beq x0, x4, 8;   pc = 28
        `MEM_INSTR[`INSTR_START_IDX + 6] = 32'hfe0004e3;    // beq x0, x0, -24; pc = 0
        `MEM_INSTR[`INSTR_START_IDX + 7] = 32'h00000013;    // nop
        `MEM_INSTR[`INSTR_START_IDX + 8] = 32'h00000013;    // nop
        `MEM_INSTR[`INSTR_START_IDX + 9] = 32'h00000013;    // nop


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);

        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd4);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd20);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd24);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd0);

        #5;
        $finish;
    end

endmodule
