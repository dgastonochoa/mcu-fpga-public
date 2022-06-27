`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "digital_design_and_computer_arch_test_tb.vcd"
`endif

module digital_design_and_computer_arch_test_tb;
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

    //
    // Debug signals
    //
    wire [31:0] x6, x9;
    assign x6 = dut.rv.dp.rf._reg[6];
    assign x9 = dut.rv.dp.rf._reg[9];

    wire [31:0] addr1, addr3;
    assign addr1 = dut.rv.dp.rf.addr1;
    assign addr3 = dut.rv.dp.rf.addr3;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, digital_design_and_computer_arch_test_tb);

        $readmemh(
            "./riscv/mem_maps/digital-design-and-computer-arch-riscvtest.txt",
            dut.rv.instr_mem._mem._mem,
            0,
            20
        );

        // Reset
        #5  rst = 1;
        #1  assert(pc === 0);
            assert(alu_out === 5);
        #1  rst = 0;

        // addi    x2,x0,5
        #4  assert(pc === 4);
            assert(dut.rv.dp.rf._reg[2] === 32'b0101);

        // addi    x3,x0,12
        #20 assert(pc === 8);
            assert(dut.rv.dp.rf._reg[3] === 32'b1100);

        // addi    x7,x3,-9
        #20 assert(pc === 12);
            assert(dut.rv.dp.rf._reg[7] === 32'b0011);

        // or      x4,x7,x2
        #20 assert(pc === 16);
            assert(dut.rv.dp.rf._reg[4] === 32'b0111);

        // and     x5,x3,x4
        #20 assert(pc === 20);
            assert(dut.rv.dp.rf._reg[5] === 32'b0100);

        // add     x5,x5,x4
        #20 assert(pc === 24);
            assert(dut.rv.dp.rf._reg[5] === 32'b1011);

        // beq     x5,x7,0x48
        #20 assert(pc === 28);

        // slt     x4,x3,x4
        #20 assert(pc === 32);
            assert(dut.rv.dp.rf._reg[4] === 32'b0000);

        // beq     x4,x0,0x28
        #20 assert(pc === 40);

        // slt     x4,x7,x2
        #20 assert(pc === 44);
            assert(dut.rv.dp.rf._reg[4] === 32'b0001);

        // add     x7,x4,x5
        #20 assert(pc === 48);
            assert(dut.rv.dp.rf._reg[7] === 32'b1100);

        // sub     x7,x7,x2
        #20 assert(pc === 52);
            assert(dut.rv.dp.rf._reg[7] === 32'b0111);

        // sw      x7,84(x3)
        #20 assert(pc === 56);
            assert(dut.rv.data_mem._mem._mem[24] === 32'b0111);

        // lw      x2,96(x0)
        #20 assert(pc === 60);
            assert(dut.rv.dp.rf._reg[2] === 32'b0111);

        // add     x9,x2,x5
        #20 assert(pc === 64);
            assert(dut.rv.dp.rf._reg[9] === 32'b10010);

        // jal     x3,0x48
        #20 assert(pc === 32'd72);
            assert(dut.rv.dp.rf._reg[3] === 68);

        // add     x2,x2,x9
        #20 assert(pc === 32'd76);
            assert(dut.rv.dp.rf._reg[2] === 32'd25);

        // sw      x2,32(x3)
        #20 assert(pc === 32'd80);
            assert(dut.rv.data_mem._mem._mem[25] === 32'd25);

        // beq     x2,x2,0x50
        #20 assert(pc === 32'd80);
        #20 assert(pc === 32'd80);
        #20 assert(pc === 32'd80);
        #20 assert(pc === 32'd80);

        #5;
        $finish;
    end


endmodule
