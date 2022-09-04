`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "lh_tb.vcd"
`endif

module lh_tb;
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
        $dumpvars(1, lh_tb);

        // Set register init. vals
        dut.rv.c.dp.rf._reg[0] = 32'd0;
        dut.rv.c.dp.rf._reg[6] = 32'd0;
        dut.rv.c.dp.rf._reg[9] = (`DATA_START_IDX * 4) + 8;

        // Set mem. init. vals
        `SET_MEM_D(1, 32'hdeadc0de);
        `SET_MEM_D(2, 32'hdeadbeef);
        `SET_MEM_D(3, 32'hc001c0de);

        // Load words with different addresses
        // Last instr. is to try to load word into x0
        `SET_MEM_I(0, 32'hffc49303);  // lb x6, -4(x9)
        `SET_MEM_I(1, 32'h00049303);  // lb x6, 0(x9)
        `SET_MEM_I(2, 32'h00449303);  // lb x6, 4(x9)
        `SET_MEM_I(3, 32'h00449003);  // lb x0, 4(x9)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `L_I_CYC) assert(dut.rv.c.dp.rf._reg[6] === 32'hffffc0de);
        `WAIT_CLKS(clk, `L_I_CYC) assert(dut.rv.c.dp.rf._reg[6] === 32'hffffbeef);
        `WAIT_CLKS(clk, `L_I_CYC) assert(dut.rv.c.dp.rf._reg[6] === 32'hffffc0de);
        `WAIT_CLKS(clk, `L_I_CYC) assert(dut.rv.c.dp.rf._reg[0] === 32'h00000000);

        #20;
        $finish;
    end
endmodule
