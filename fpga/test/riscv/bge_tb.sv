`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "bge_tb.vcd"
`endif

module bge_tb;
    wire reg_we, mem_we, alu_src, pc_src;
    wire [1:0] imm_src, res_src;
    wire [2:0] alu_ctrl;

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
        $dumpvars(1, bge_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[4] = 32'd10;
        dut.dp.rf._reg[5] = 32'd20;

        dut.instr_mem._mem[0] = 32'h00025863;       // bge x4, x0, 16
        dut.instr_mem._mem[4] = 32'h00425263;       // bge x4, x4, 20
        dut.instr_mem._mem[5] = 32'hfe42d6e3;       // bge x5, x4, 0


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        #11 assert(pc === 32'd16);
        #20 assert(pc === 32'd20);
        #20 assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
