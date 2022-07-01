`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "blt_tb.vcd"
`endif

`ifdef CONFIG_RISCV_SINGLECYCLE
    `define N_CLKS 1
`elsif CONFIG_RISCV_MULTICYCLE
    `define N_CLKS 3
`endif

module blt_tb;
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
        $dumpvars(1, blt_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'd10;
        dut.rv.dp.rf._reg[5] = 32'd20;

        // blt'ing these 2 regs. (a < b; a = big. neg. num., b = 2)
        // will produce the special case in which comparing two
        // signed numbers a and b, begin a less than b, won't cause
        // an ALU's neg flag, but an overflow.
        dut.rv.dp.rf._reg[6] = 32'h80000000;
        dut.rv.dp.rf._reg[7] = 32'h00000002;

        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h00404863;   // blt x0, x4, 16
        `MEM_INSTR[`INSTR_START_IDX + 4] = 32'h00424a63;   // blt x4, x4, 20
        `MEM_INSTR[`INSTR_START_IDX + 5] = 32'h00734863;   // blt x6, x7, 16
        `MEM_INSTR[`INSTR_START_IDX + 9] = 32'hfc42cee3;   // blt x5, x4, -36

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd16);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd20);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd36);

        #5;
        $finish;
    end

endmodule
