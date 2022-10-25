`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv/mem_map.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_lw_hazard_tb.vcd"
`endif

module sw_lw_hazard_tb;
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
        $dumpvars(1, sw_lw_hazard_tb);

        `CPU_SET_R(dut, 2, (`SEC_DATA_W * 4));
        `CPU_SET_R(dut, 4, 32'h00);
        `CPU_SET_R(dut, 5, 32'h00);
        `CPU_SET_R(dut, 6, 32'h00);

        `CPU_MEM_SET_W(cm, 0, 32'hdeadc0de);
        `CPU_MEM_SET_W(cm, 1, 32'hdeadbeef);


        `CPU_MEM_SET_W(cm, 0, 32'h02000213); //         addi    x4, x0, 32
        `CPU_MEM_SET_W(cm, 1, 32'h00412023); //         sw      x4, (0x0)(sp)
        `CPU_MEM_SET_W(cm, 2, 32'h00012183); //         lw      x3, (0x0)(sp)
        `CPU_MEM_SET_W(cm, 3, 32'h00312223); //         sw      x3, (0x4)(sp)
        `CPU_MEM_SET_W(cm, 4, 32'h0000006f); // .L0:    jal     x0, .L0


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_CLKS(clk, 20) assert(`CPU_GET_R(dut, 4) === 32'd32);
                            assert(`CPU_GET_R(dut, 3) === 32'd32);
                            assert(`CPU_MEM_GET_W(cm, `SEC_DATA_W + 0) === 32'd32);
                            assert(`CPU_MEM_GET_W(cm, `SEC_DATA_W + 1) === 32'd32);

        #5;
        $finish;
    end
endmodule
