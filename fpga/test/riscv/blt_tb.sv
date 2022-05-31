`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "blt_tb.vcd"
`endif

module blt_tb;
    wire reg_we, mem_we, alu_src;
    wire [1:0] imm_src, res_src, pc_src;
    wire [3:0] alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    reg clk = 0, rst;

    riscv_single_top dut(
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

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[4] = 32'd10;
        dut.dp.rf._reg[5] = 32'd20;

        // blt'ing these 2 regs. (a < b; a = big. neg. num., b = 2)
        // will produce the special case in which comparing two
        // signed numbers a and b, begin a less than b, won't cause
        // an ALU's neg flag, but an overflow.
        dut.dp.rf._reg[6] = 32'h80000000;
        dut.dp.rf._reg[7] = 32'h00000002;

        dut.instr_mem._mem[0] = 32'h00404863;   // blt x0, x4, 16
        dut.instr_mem._mem[4] = 32'h00424a63;   // blt x4, x4, 20
        dut.instr_mem._mem[5] = 32'h00734863;   // blt x6, x7, 16
        dut.instr_mem._mem[9] = 32'hfc42cee3;   // blt x5, x4, -36

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        #11 assert(pc === 32'd16);
        #20 assert(pc === 32'd20);
        #20 assert(pc === 32'd36);

        #5;
        $finish;
    end

endmodule
