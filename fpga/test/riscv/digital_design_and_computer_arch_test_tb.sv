`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "digital_design_and_computer_arch_test_tb.vcd"
`endif

module digital_design_and_computer_arch_test_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire [31:0] instr, d_rd, d_addr, d_wd, pc;
    wire d_we;
    mem_dt_e d_dt;

    cpu dut(instr, d_rd, d_addr, d_we, d_wd, d_dt, pc, rst, clk);


    errno_e  err;

    cpu_mem cm(
        pc, d_addr, d_wd, d_we, d_dt, instr, d_rd, err, clk);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, digital_design_and_computer_arch_test_tb);

        $readmemh(
            "./riscv/mem_maps/digital-design-and-computer-arch-riscvtest.txt",
            `CPU_MEM_GET_I_M(cm),
            0,
            20
        );

        // Reset
        #5  rst = 1;
        #1  assert(pc === 0);
        #1  rst = 0;

        // addi    x2,x0,5
        #4  assert(pc === 4);
            assert(`CPU_GET_R(dut, 2) === 32'b0101);

        // addi    x3,x0,12
        #20 assert(pc === 8);
            assert(`CPU_GET_R(dut, 3) === 32'b1100);

        // addi    x7,x3,-9
        #20 assert(pc === 12);
            assert(`CPU_GET_R(dut, 7) === 32'b0011);

        // or      x4,x7,x2
        #20 assert(pc === 16);
            assert(`CPU_GET_R(dut, 4) === 32'b0111);

        // and     x5,x3,x4
        #20 assert(pc === 20);
            assert(`CPU_GET_R(dut, 5) === 32'b0100);

        // add     x5,x5,x4
        #20 assert(pc === 24);
            assert(`CPU_GET_R(dut, 5) === 32'b1011);

        // beq     x5,x7,0x48
        #20 assert(pc === 28);

        // slt     x4,x3,x4
        #20 assert(pc === 32);
            assert(`CPU_GET_R(dut, 4) === 32'b0000);

        // beq     x4,x0,0x28
        #20 assert(pc === 40);

        // slt     x4,x7,x2
        #20 assert(pc === 44);
            assert(`CPU_GET_R(dut, 4) === 32'b0001);

        // add     x7,x4,x5
        #20 assert(pc === 48);
            assert(`CPU_GET_R(dut, 7) === 32'b1100);

        // sub     x7,x7,x2
        #20 assert(pc === 52);
            assert(`CPU_GET_R(dut, 7) === 32'b0111);

        // sw      x7,84(x3)
        #20 assert(pc === 56);
            assert(`CPU_MEM_GET_D(cm, 24) === 32'b0111);

        // lw      x2,96(x0)
        #20 assert(pc === 60);
            assert(`CPU_GET_R(dut, 2) === 32'b0111);

        // add     x9,x2,x5
        #20 assert(pc === 64);
            assert(`CPU_GET_R(dut, 9) === 32'b10010);

        // jal     x3,0x48
        #20 assert(pc === 32'd72);
            assert(`CPU_GET_R(dut, 3) === 68);

        // add     x2,x2,x9
        #20 assert(pc === 32'd76);
            assert(`CPU_GET_R(dut, 2) === 32'd25);

        // sw      x2,32(x3)
        #20 assert(pc === 32'd80);
            assert(`CPU_MEM_GET_D(cm, 25) === 32'd25);

        // beq     x2,x2,0x50
        #20 assert(pc === 32'd80);
        #20 assert(pc === 32'd80);
        #20 assert(pc === 32'd80);
        #20 assert(pc === 32'd80);

        #5;
        $finish;
    end


endmodule
