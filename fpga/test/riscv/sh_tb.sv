`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sh_tb.vcd"
`endif

module sh_tb;
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
        $dumpvars(1, sh_tb);

        dut.rv.dp.rf._reg[9] = (`DATA_START_IDX * 4) + 32;
        dut.rv.dp.rf._reg[6] = 32'hdeadc0de;
        dut.rv.dp.rf._reg[7] = 32'hdeadbeef;
        dut.rv.dp.rf._reg[8] = 32'hc001c0de;

        `SET_MEM_D(5, 32'h00);
        `SET_MEM_D(10, 32'h00);
        `SET_MEM_D(11, 32'h00);

        `SET_MEM_I(0, 32'hfe649a23);  // sh x6, -12(x9)
        `SET_MEM_I(1, 32'h00749423);  // sh x7, 8(x9)
        `SET_MEM_I(2, 32'h00849623);  // sh x8, 12(x9)
        `SET_MEM_I(3, 32'h00049623);  // sh x0, 12(x9)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

`ifdef CONFIG_RISCV_PIPELINE
        `WAIT_CLKS(clk, 3);
`endif
        `WAIT_CLKS(clk, `S_I_CYC) assert(`GET_MEM_D(5) === 32'h0000c0de);
        `WAIT_CLKS(clk, `S_I_CYC) assert(`GET_MEM_D(10) === 32'h0000beef);
        `WAIT_CLKS(clk, `S_I_CYC) assert(`GET_MEM_D(11) === 32'h0000c0de);
        `WAIT_CLKS(clk, `S_I_CYC) assert(`GET_MEM_D(11) === 32'h00000000);

        #5;
        $finish;
    end

endmodule
