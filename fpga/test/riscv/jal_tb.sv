`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "jal_tb.vcd"
`endif

`ifdef CONFIG_RISCV_SINGLECYCLE
    `define N_CLKS 1
`elsif CONFIG_RISCV_MULTICYCLE
    `define N_CLKS 3
`endif

module jal_tb;
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
        $dumpvars(1, jal_tb);

        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h00c000ef;   // jal ra, +12
        `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h00000013;
        `MEM_INSTR[`INSTR_START_IDX + 2] = 32'h00000013;
        `MEM_INSTR[`INSTR_START_IDX + 3] = 32'h00000013;
        `MEM_INSTR[`INSTR_START_IDX + 4] = 32'h00000013;
        `MEM_INSTR[`INSTR_START_IDX + 5] = 32'h00000013;
        `MEM_INSTR[`INSTR_START_IDX + 6] = 32'h00000013;
        `MEM_INSTR[`INSTR_START_IDX + 7] = 32'hff9ff0ef;   // jal ra, -8

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        assert(pc === 0);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 12);
                                    assert(dut.rv.dp.rf._reg[1] === 4);

        `WAIT_INSTR(clk)            assert(pc === 16);
                                    assert(dut.rv.dp.rf._reg[1] === 4);
        `WAIT_INSTR(clk)            assert(pc === 20);
                                    assert(dut.rv.dp.rf._reg[1] === 4);
        `WAIT_INSTR(clk)            assert(pc === 24);
                                    assert(dut.rv.dp.rf._reg[1] === 4);
        `WAIT_INSTR(clk)            assert(pc === 28);
                                    assert(dut.rv.dp.rf._reg[1] === 4);

        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 20);
                                    assert(dut.rv.dp.rf._reg[1] === 32);

        // Modify first instr. to jump to itself
        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h000000ef;
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 0);
                                    assert(dut.rv.dp.rf._reg[1] === 4);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 0);
                                    assert(dut.rv.dp.rf._reg[1] === 4);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 0);
                                    assert(dut.rv.dp.rf._reg[1] === 4);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 0);
                                    assert(dut.rv.dp.rf._reg[1] === 4);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(pc === 0);
                                    assert(dut.rv.dp.rf._reg[1] === 4);

        #5 $finish;
    end
endmodule
