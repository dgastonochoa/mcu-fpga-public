`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "example_program_tb.vcd"
`endif

`ifdef CONFIG_RISCV_MULTICYCLE
    `define MEM_MAP_FILE "./riscv/mem_maps/all_instr_program_test_instr_mem_shared_instr_data_mem.txt"
    `define FIRST_INSTR (32'h7f000113)
`else
    `define MEM_MAP_FILE "./riscv/mem_maps/all_instr_program_test_instr_mem_separ_instr_data_mem.txt"
    `define FIRST_INSTR (32'h00000113)
`endif // CONFIG_RISCV_MULTICYCLE

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
            `MEM_MAP_FILE,
            `CPU_MEM_GET_I_M(`MCU_GET_M(dut)),
            0,
            457
        );

        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut), 0) === `FIRST_INSTR);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut), 1) === 32'h02500293);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut), 2) === 32'h00328313);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut), 455) === 32'hffc10113);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut), 456) === 32'h00012083);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut), 457) === 32'h00008067);

        // Reset
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 0);

        wait(pc === 32'h680);

        // Wait for some cycles to let the last instr. go to all the stages if
        // applicable.
        `WAIT_CLKS(clk, 20);

        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 0) === 37);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 1) === 40);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 2) === 24);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 3) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 4) === 32'h12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 5) === 32'hef);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 6) === 32'hcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 7) === 32'hab);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 8) === 32'hef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 9) === 32'habcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 10) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 11) === 32'hxxxxef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 12) === 32'hxxxxxx12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 13) === 32'h00000012);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 14) === 32'hffffffef);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 15) === 32'hffffffcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 16) === 32'hffffffab);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 17) === 32'hffffef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 18) === 32'h7ffff000);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 19) === 32'hcdef1200);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 20) === 32'h9bde2400);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 21) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 22) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 23) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 24) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 25) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 26) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 27) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 28) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 29) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 30) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 31) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 32) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 33) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 34) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 35) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 36) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 37) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 38) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 39) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 40) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 41) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 42) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 43) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 44) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 45) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 46) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 47) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 48) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 49) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 50) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 51) === 32'h0fffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 52) === 32'h00fffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 53) === 32'hffffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 54) === 32'hfffffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 55) === 32'hf0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 56) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 57) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 58) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 59) === 32'h0f);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 60) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 61) === 32'h04);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 62) === 32'hcdef1200);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 63) === 32'h9bde2400);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 64) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 65) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 66) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 67) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 68) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 69) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 70) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 71) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 72) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 73) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 74) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 75) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 76) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 77) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 78) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 79) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 80) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 81) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 82) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 83) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 84) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 85) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 86) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 87) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 88) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 89) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 90) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 91) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 92) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 93) === 32'h0fffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 94) === 32'h00fffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 95) === 32'hffffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 96) === 32'hfffffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 97) === 32'hf0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 98) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 99) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 100) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 101) === 32'h0f);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 102) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 103) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 104) === 25);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 105) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 106) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 107) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 108) === 25);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 109) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 110) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 111) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 112) === -20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 113) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 114) === 45);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 115) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 116) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 117) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 118) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 119) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 120) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 121) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 122) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 123) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 124) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 125) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut), 126) === 6);

        #40 $finish;
    end
endmodule
