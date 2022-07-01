`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "bge_tb.vcd"
`endif

`ifdef CONFIG_RISCV_SINGLECYCLE
    `define N_CLKS 1
`elsif CONFIG_RISCV_MULTICYCLE
    `define N_CLKS 3
`endif

module bge_tb;
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
        $dumpvars(1, bge_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'd10;
        dut.rv.dp.rf._reg[5] = 32'd20;

        // bge'ing these 2 regs. (a < b; b = big. neg. num., a = 2)
        // will produce the special case in which comparing two
        // signed numbers a and b, begin a greater than b, won't cause
        // an ALU's neg flag to be 0, but an overflow.
        dut.rv.dp.rf._reg[6] = 32'd02;
        dut.rv.dp.rf._reg[7] = 32'h80000000;

        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h00025863;   // bge x4, x0, 16
        `MEM_INSTR[`INSTR_START_IDX + 4] = 32'h00425263;   // bge x4, x4, 4
        `MEM_INSTR[`INSTR_START_IDX + 5] = 32'h00735863;   // bge x6, x7, 4
        `MEM_INSTR[`INSTR_START_IDX + 9] = 32'hfc525ee3;   // blt x4, x5, -36
        `MEM_INSTR[`INSTR_START_IDX + 10] = 32'hfc42dce3;   // blt x5, x4, -40

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd16);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd20);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd36);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd40);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
