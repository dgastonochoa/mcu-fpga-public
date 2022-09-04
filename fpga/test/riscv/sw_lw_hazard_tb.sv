`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_lw_hazard_tb.vcd"
`endif

module sw_lw_hazard_tb;
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
        $dumpvars(1, sw_lw_hazard_tb);

        dut.rv.c.dp.rf._reg[2] = 32'h00;
        dut.rv.c.dp.rf._reg[5] = 32'h00;
        dut.rv.c.dp.rf._reg[6] = 32'h00;

        `MEM_DATA[0] = 32'hdeadc0de;
        `MEM_DATA[1] = 32'hdeadbeef;


        `SET_MEM_I(0, 32'h02000113); //         addi    x2, x0, 32
        `SET_MEM_I(1, 32'h00202023); //         sw      x2, (0)(x0)
        `SET_MEM_I(2, 32'h00002183); //         lw      x3, (0)(x0)
        `SET_MEM_I(3, 32'h00302223); //         sw      x3, (4)(x0)
        `SET_MEM_I(4, 32'h0000006f); // .L0:    jal     x0, .L0


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_CLKS(clk, 20) assert(dut.rv.c.dp.rf._reg[2] === 32'd32);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd32);
                            assert(`MEM_DATA[0] === 32'd32);
                            assert(`MEM_DATA[1] === 32'd32);

        #5;
        $finish;
    end
endmodule
