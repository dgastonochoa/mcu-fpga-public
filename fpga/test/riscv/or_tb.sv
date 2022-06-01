`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "or_tb.vcd"
`endif

module or_tb;
    wire reg_we, mem_we;
    wire [1:0] res_src, pc_src, alu_src;
    wire [2:0] imm_src;
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

    wire [9:0] _ctrls;
    assign _ctrls = dut.co.ctrls;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, or_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[4] = 32'd00;
        dut.dp.rf._reg[5] = 32'h01;
        dut.dp.rf._reg[6] = 32'hfe;

        dut.instr_mem._mem[0] = 32'h00626033;           // or x0, x4, x6
        dut.instr_mem._mem[1] = 32'h0002e233;           // or x4, x5, x0
        dut.instr_mem._mem[2] = 32'h00626233;           // or x4, x4, x6

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(dut.dp.rf._reg[0] === 32'h00);
        #20 assert(dut.dp.rf._reg[4] === 32'h01);
        #20 assert(dut.dp.rf._reg[4] === 32'hff);

        #5;
        $finish;
    end

endmodule
