`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_2_tb.vcd"
`endif

module sw_2_tb;
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
        $dumpvars(1, sw_2_tb);

        dut.rv.dp.rf._reg[2] = 32'h00;
        dut.rv.dp.rf._reg[5] = 32'h00;
        dut.rv.dp.rf._reg[6] = 32'h00;

        `MEM_DATA[8] = 32'hdeadc0de;
        `MEM_DATA[9] = 32'hdeadbeef;


        `SET_MEM_I(0, 32'h02000113); //         addi    x2, x0, 32
        `SET_MEM_I(1, 32'h02500293); //         addi    x5, x0, 37
        `SET_MEM_I(2, 32'h00328313); //         addi    x6, x5, 3
        `SET_MEM_I(3, 32'h00512023); //         sw      x5, (0*4)(x2)
        `SET_MEM_I(4, 32'h00612223); //         sw      x6, (1*4)(x2)
        `SET_MEM_I(5, 32'h0000006f); // .L0:    jal     x0, .L0

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_CLKS(clk, 20) assert(dut.rv.dp.rf._reg[2] === 32'd32);
                            assert(dut.rv.dp.rf._reg[5] === 32'd37);
                            assert(dut.rv.dp.rf._reg[6] === 32'd40);
                            assert(`MEM_DATA[8] === 32'd37);
                            assert(`MEM_DATA[9] === 32'd40);

        #5;
        $finish;
    end
endmodule
