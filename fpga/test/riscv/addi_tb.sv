`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "addi_tb.vcd"
`endif

module addi_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

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

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, addi_tb);

        //
        // init. x0 as 0
        //
        dut.rv.c.dp.rf._reg[0] = 32'd0;

        //
        // addi does not write on x0
        //
        `SET_MEM_I(0, 32'h01420013);   // addi x0, x4, 20

        //
        // load values work
        //
        `SET_MEM_I(1, 32'h00a00213);   // addi x4, x0, 10
        `SET_MEM_I(2, 32'h01400293);   // addi x5, x0, 20

        //
        // add possitive and negative, same reg., works
        //
        `SET_MEM_I(3, 32'hff620213);   // addi x4, x4, -10
        `SET_MEM_I(4, 32'hff620213);   // addi x4, x4, -10
        `SET_MEM_I(5, 32'h00a20213);   // addi x4, x4, 10
        `SET_MEM_I(6, 32'h00a20213);   // addi x4, x4, 10

        //
        // move from one reg. to other, reset to 0 and add other works
        //
        `SET_MEM_I(7, 32'h00028213);   // addi x4, x5, 0
        `SET_MEM_I(8, 32'h00000213);   // addi x4, zero, 0
        `SET_MEM_I(9, 32'h01428213);   // addi x4, x5, 20

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[0] === 32'd00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd10);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[5] === 32'd20);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === -10);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd10);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd20);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd00);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd40);

        $finish;
    end
endmodule
