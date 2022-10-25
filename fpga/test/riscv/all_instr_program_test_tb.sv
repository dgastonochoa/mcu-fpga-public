`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv/mem_map.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "example_program_tb.vcd"
`endif

module example_program_tb;
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
        $dumpvars(1, example_program_tb);

        $readmemh(
            "./riscv/mem_maps/all_instr_program_test_instr.txt",
            `CPU_MEM_GET_M(`MCU_GET_M(dut)),
            0,
            457
        );

        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), 0) === 32'h7f000113);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), 1) === 32'h02500293);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), 2) === 32'h00328313);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), 455) === 32'hffc10113);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), 456) === 32'h00012083);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), 457) === 32'h00008067);

        // Reset
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 0);

        wait(pc === 32'h680);

        // Wait for some cycles to let the last instr. go to all the stages if
        // applicable.
        `WAIT_CLKS(clk, 20);

        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 0) === 37);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 1) === 40);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 2) === 24);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 3) === 32'habcdef12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 4) === 32'h12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 5) === 32'hef);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 6) === 32'hcd);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 7) === 32'hab);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 8) === 32'hef12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 9) === 32'habcd);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 10) === 32'habcdef12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 11) === 32'hxxxxef12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 12) === 32'hxxxxxx12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 13) === 32'h00000012);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 14) === 32'hffffffef);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 15) === 32'hffffffcd);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 16) === 32'hffffffab);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 17) === 32'hffffef12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 18) === 32'h7ffff000);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 19) === 32'hcdef1200);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 20) === 32'h9bde2400);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 21) === 32'habcdef12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 22) === 32'h00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 23) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 24) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 25) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 26) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 27) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 28) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 29) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 30) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 31) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 32) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 33) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 34) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 35) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 36) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 37) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 38) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 39) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 40) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 41) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 42) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 43) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 44) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 45) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 46) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 47) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 48) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 49) === 32'hff);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 50) === 32'h00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 51) === 32'h0fffff00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 52) === 32'h00fffff0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 53) === 32'hffffff00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 54) === 32'hfffffff0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 55) === 32'hf0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 56) === 32'hff);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 57) === 32'hff);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 58) === 32'hff);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 59) === 32'h0f);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 60) === 32'h00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 61) === 32'h04);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 62) === 32'hcdef1200);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 63) === 32'h9bde2400);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 64) === 32'habcdef12);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 65) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 66) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 67) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 68) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 69) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 70) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 71) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 72) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 73) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 74) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 75) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 76) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 77) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 78) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 79) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 80) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 81) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 82) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 83) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 84) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 85) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 86) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 87) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 88) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 89) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 90) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 91) === 32'hff);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 92) === 32'h00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 93) === 32'h0fffff00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 94) === 32'h00fffff0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 95) === 32'hffffff00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 96) === 32'hfffffff0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 97) === 32'hf0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 98) === 32'hff);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 99) === 32'hff);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 100) === 32'hff);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 101) === 32'h0f);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 102) === 32'h00);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 103) === 20);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 104) === 25);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 105) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 106) === -5);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 107) === 20);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 108) === 25);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 109) === 0);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 110) === -5);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 111) === 20);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 112) === -20);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 113) === -5);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 114) === 45);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 115) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 116) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 117) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 118) === 1);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 119) === 6);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 120) === 6);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 121) === 6);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 122) === 6);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 123) === 6);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 124) === 6);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 125) === 6);
        assert(`CPU_MEM_GET_W(`MCU_GET_M(dut), `SEC_DATA_W + 126) === 6);

        #40 $finish;
    end
endmodule
