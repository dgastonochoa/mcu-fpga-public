`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "auipc_tb.vcd"
`endif

`ifdef CONFIG_RISCV_SINGLECYCLE
    `define N_CLKS 1
`elsif CONFIG_RISCV_MULTICYCLE
    `define N_CLKS 3
`endif

module auipc_tb;
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
        $dumpvars(1, auipc_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[1] = 32'd12;

        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h00014097;   // auipc   x1, 20
        `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h00014097;   // auipc   x1, 20

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        assert(pc === 32'd0);

        `WAIT_INSTR_C(clk, `N_CLKS) assert(dut.rv.dp.rf._reg[1] === (32'd20 << 12));
                                    assert(pc === 32'd4);

        `WAIT_INSTR_C(clk, `N_CLKS) assert(dut.rv.dp.rf._reg[1] === (32'd20 << 12) + 4);
                                    assert(pc === 32'd8);

        #5;
        $finish;
    end

endmodule
