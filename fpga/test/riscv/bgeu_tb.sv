`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "bltu_tb.vcd"
`endif

module bltu_tb;
    wire reg_we, mem_we, alu_src;
    wire [1:0] res_src, pc_src;
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

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, bltu_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[4] = 32'hffff0000;
        dut.dp.rf._reg[5] = 32'd10;
        dut.dp.rf._reg[6] = 32'd20;

        dut.instr_mem._mem[0] = 32'h00527863;   // bgeu    x4, x5, 16
        dut.instr_mem._mem[4] = 32'h00627263;   // bgeu    x4, x6, 4
        dut.instr_mem._mem[5] = 32'h00437863;   // bgeu    x6, x4, 20
        dut.instr_mem._mem[6] = 32'h00007263;   // bgeu    x0, x0, 4
        dut.instr_mem._mem[7] = 32'hfe0272e3;   // bgeu    x4, x0, -28

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        #11 assert(pc === 32'd16);
        #20 assert(pc === 32'd20);
        #20 assert(pc === 32'd24);
        #20 assert(pc === 32'd28);
        #20 assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
