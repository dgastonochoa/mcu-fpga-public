`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "addi_tb.vcd"
`endif

module addi_tb;
    wire reg_we, mem_we, alu_src, res_src, pc_src;
    wire [1:0] imm_src, alu_ctrl;

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
        $dumpvars(1, addi_tb);

        //
        // init. x0 as 0
        //
        dut.dp.rf._reg[0] = 32'd0;

        //
        // addi does not write on x0
        //
        dut.instr_mem._mem[0] = 32'h01420013;   // addi x0, x4, 20

        //
        // load values work
        //
        dut.instr_mem._mem[1] = 32'h00a00213;   // addi x4, x0, 10
        dut.instr_mem._mem[2] = 32'h01400293;   // addi x5, x0, 20

        //
        // add possitive and negative, same reg., works
        //
        dut.instr_mem._mem[3] = 32'hff620213;   // addi x4, x4, -10
        dut.instr_mem._mem[4] = 32'hff620213;   // addi x4, x4, -10
        dut.instr_mem._mem[5] = 32'h00a20213;   // addi x4, x4, 10
        dut.instr_mem._mem[6] = 32'h00a20213;   // addi x4, x4, 10

        //
        // move from one reg. to other, reset to 0 and add other works
        //
        dut.instr_mem._mem[7] = 32'h00028213;   // addi x4, x5, 0
        dut.instr_mem._mem[8] = 32'h00000213;   // addi x4, zero, 0
        dut.instr_mem._mem[9] = 32'h01428213;   // addi x4, x5, 20

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(dut.dp.rf._reg[0] === 32'd00);
        #20 assert(dut.dp.rf._reg[4] === 32'd10);
        #20 assert(dut.dp.rf._reg[5] === 32'd20);
        #20 assert(dut.dp.rf._reg[4] === 32'd00);
        #20 assert(dut.dp.rf._reg[4] === -10);
        #20 assert(dut.dp.rf._reg[4] === 32'd00);
        #20 assert(dut.dp.rf._reg[4] === 32'd10);
        #20 assert(dut.dp.rf._reg[4] === 32'd20);
        #20 assert(dut.dp.rf._reg[4] === 32'd00);
        #20 assert(dut.dp.rf._reg[4] === 32'd40);

        $finish;
    end
endmodule
