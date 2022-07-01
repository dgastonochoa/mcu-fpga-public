`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "bltu_tb.vcd"
`endif

`ifdef CONFIG_RISCV_SINGLECYCLE
    `define N_CLKS 1
`elsif CONFIG_RISCV_MULTICYCLE
    `define N_CLKS 3
`endif

module bltu_tb;
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
        $dumpvars(1, bltu_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'd10;
        dut.rv.dp.rf._reg[5] = 32'hffff0000;
        dut.rv.dp.rf._reg[6] = 32'd20;

        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h00526863;   // bltu    x4, x5, 16
        `MEM_INSTR[`INSTR_START_IDX + 4] = 32'h00626263;   // bltu    x4, x6, 4
        `MEM_INSTR[`INSTR_START_IDX + 5] = 32'h00436863;   // bltu    x6, x4, 16
        `MEM_INSTR[`INSTR_START_IDX + 6] = 32'hfe4064e3;   // bltu    x0, x4, -24

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd16);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd20);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd24);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
