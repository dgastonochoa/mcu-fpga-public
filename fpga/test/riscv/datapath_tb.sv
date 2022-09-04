`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "datapath_tb.vcd"
`endif

module datapath_tb;
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
        $dumpvars(1, datapath_tb);

        dut.rv.c.dp.rf._reg[9] = (`DATA_START_IDX * 4) + 8;
        dut.rv.c.dp.rf._reg[4] = 32'd0;
        dut.rv.c.dp.rf._reg[5] = 32'hfffffffe;
        dut.rv.c.dp.rf._reg[6] = 32'd0;

        `SET_MEM_D(1, 32'hdeadc0de);
        `SET_MEM_D(4, 32'h00);

        `SET_MEM_I(0, 32'hffc4a303);    // lw x6, -4(x9)
        `SET_MEM_I(1, 32'h0064a423);    // sw x6, 8(x9)
        `SET_MEM_I(2, 32'h0062e233);    // or x4, x5, x6
        `SET_MEM_I(3, 32'hfe420ae3);    // beq x4, x4, L7

        // Reset
        #2  rst = 1;
        #2  rst = 0;
        assert(pc === 0);

        // First instr. executed
        `WAIT_CLKS(clk, `L_I_CYC) assert(pc === 4);
                                  assert(dut.rv.c.dp.rf._reg[6] === 32'hdeadc0de);

        // Second instr. executed
        `WAIT_CLKS(clk, `S_I_CYC) assert(pc === 8);
                                  assert(`MEM_DATA[`DATA_START_IDX + 4] === 32'hdeadc0de);

        // Third instr. executed
        `WAIT_CLKS(clk, `R_I_CYC) assert(pc === 12);
                                  assert(dut.rv.c.dp.rf._reg[4] === 32'hfffffffe);

        // Fourth instr. executed, branched to
        // starting address.
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 0);

        // First instr. executed again.
        `WAIT_CLKS(clk, `L_I_CYC) assert(pc === 4);
                                  assert(dut.rv.c.dp.rf._reg[6] === 32'hdeadc0de);

        // Second instr. executed again.
        `WAIT_CLKS(clk, `S_I_CYC) assert(pc === 8);
                                 assert(`MEM_DATA[`DATA_START_IDX + 4] === 32'hdeadc0de);

        // Third instr. executed again
        `WAIT_CLKS(clk, `R_I_CYC) assert(pc === 12);
                                  assert(dut.rv.c.dp.rf._reg[4] === 32'hfffffffe);

        // Fourth instr. executed again, branched to
        // starting address.
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 0);

        #5;
        $finish;
    end
endmodule
