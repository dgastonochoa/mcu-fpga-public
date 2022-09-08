`timescale 10ps/1ps

`include "alu.svh"
`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "jal_tb.vcd"
`endif

module jal_tb;
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
        $dumpvars(1, jal_tb);

        `SET_MEM_I(0, 32'h00c000ef);   // jal ra, +12
        `SET_MEM_I(1, 32'h00000013);
        `SET_MEM_I(2, 32'h00000013);
        `SET_MEM_I(3, 32'h00000013);
        `SET_MEM_I(4, 32'h00000013);
        `SET_MEM_I(5, 32'h00000013);
        `SET_MEM_I(6, 32'h00000013);
        `SET_MEM_I(7, 32'hff9ff0ef);   // jal ra, 0x14

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        assert(pc === 0);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 12);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);

        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 16);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);
        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 20);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);
        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 24);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);
        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 28);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);

        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 20);
                                    assert(dut.rv.c.dp.rf._reg[1] === 32);

        // Modify first instr. to jump to itself
        `SET_MEM_I(0, 32'h000000ef);
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);
        `WAIT_CLKS(clk, `J_I_CYC)   assert(pc === 0);
                                    assert(dut.rv.c.dp.rf._reg[1] === 4);

        #5 $finish;
    end
endmodule
