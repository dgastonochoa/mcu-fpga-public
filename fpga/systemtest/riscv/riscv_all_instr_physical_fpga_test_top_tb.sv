`timescale 1ns/1ns

`include "riscv_all_instr_physical_fpga_test.svh"

`include "riscv/mem_map.svh"

`include "riscv/test/test_mcu.svh"
`include "riscv/test/test_cpu_mem.svh"

`ifndef VCD
    `define VCD "riscv_single_all_instr_top_tb.vcd"
`endif

`define WAIT_CLKS(clk, n)   repeat(n) @(posedge clk); #1

module riscv_all_instr_physical_fpga_test_top_tb;
    reg clk = 0;

    always #5 clk = ~clk;


    reg btnC = 0;
    wire [15:0] led;
    wire [7:0] ja;

    riscv_all_instr_physical_fpga_test_top dut(btnC, led, ja, clk);


    //
    // SPI slave
    //
    reg [7:0] s_wd = 8'd0;
    wire mosi, miso, ss, sck;
    wire s_busy, s_rdy;
    wire [7:0] s_rd;

    assign {mosi, miso, ss, sck} = ja[3:0];

    spi_slave spis(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, btnC, sck, clk);


    wire  [31:0] res [255];

    word_storage ws(s_rd, res, btnC, s_rdy);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, riscv_all_instr_physical_fpga_test_top_tb);

        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 0) === 32'h7f000113);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 1) === 32'h02500293);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 2) === 32'h00328313);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 455) === 32'hffc10113);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 456) === 32'h00012083);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 457) === 32'h00008067);

        // Reset
        #5  btnC = 1;
        #20 btnC = 0;

`ifdef CONFIG_RISCV_MULTICYCLE
        `WAIT_CLKS(clk, 4000);
`else
        `WAIT_CLKS(clk, 1000);
`endif

        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 0) === 37);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 1) === 40);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 2) === 24);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 3) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 4) === 32'h12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 5) === 32'hef);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 6) === 32'hcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 7) === 32'hab);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 8) === 32'hef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 9) === 32'habcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 10) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 11) === 32'hxxxxef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 12) === 32'hxxxxxx12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 13) === 32'h00000012);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 14) === 32'hffffffef);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 15) === 32'hffffffcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 16) === 32'hffffffab);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 17) === 32'hffffef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 18) === 32'h7ffff000);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 19) === 32'hcdef1200);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 20) === 32'h9bde2400);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 21) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 22) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 23) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 24) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 25) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 26) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 27) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 28) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 29) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 30) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 31) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 32) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 33) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 34) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 35) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 36) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 37) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 38) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 39) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 40) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 41) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 42) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 43) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 44) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 45) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 46) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 47) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 48) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 49) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 50) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 51) === 32'h0fffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 52) === 32'h00fffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 53) === 32'hffffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 54) === 32'hfffffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 55) === 32'hf0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 56) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 57) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 58) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 59) === 32'h0f);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 60) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 61) === 32'h04);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 62) === 32'hcdef1200);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 63) === 32'h9bde2400);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 64) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 65) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 66) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 67) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 68) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 69) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 70) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 71) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 72) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 73) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 74) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 75) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 76) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 77) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 78) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 79) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 80) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 81) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 82) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 83) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 84) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 85) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 86) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 87) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 88) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 89) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 90) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 91) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 92) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 93) === 32'h0fffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 94) === 32'h00fffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 95) === 32'hffffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 96) === 32'hfffffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 97) === 32'hf0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 98) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 99) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 100) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 101) === 32'h0f);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 102) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 103) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 104) === 25);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 105) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 106) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 107) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 108) === 25);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 109) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 110) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 111) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 112) === -20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 113) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 114) === 45);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 115) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 116) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 117) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 118) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 119) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 120) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 121) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 122) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 123) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 124) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 125) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), `SEC_DATA_W + 126) === 6);

        assert(led[0] === 1'b1);




        //
        // SPI sends all the results
        //
`ifdef CONFIG_RISCV_MULTICYCLE
        `WAIT_CLKS(clk, 400000);
`else
        `WAIT_CLKS(clk, 100000);
`endif

        assert(res[0] === 37);
        assert(res[1] === 40);
        assert(res[2] === 24);
        assert(res[3] === 32'habcdef12);
        assert(res[4] === 32'h12);
        assert(res[5] === 32'hef);
        assert(res[6] === 32'hcd);
        assert(res[7] === 32'hab);
        assert(res[8] === 32'hef12);
        assert(res[9] === 32'habcd);
        assert(res[10] === 32'habcdef12);
        assert(res[11] === 32'hxxxxef12);
        assert(res[12] === 32'hxxxxxx12);
        assert(res[13] === 32'h00000012);
        assert(res[14] === 32'hffffffef);
        assert(res[15] === 32'hffffffcd);
        assert(res[16] === 32'hffffffab);
        assert(res[17] === 32'hffffef12);
        assert(res[18] === 32'h7ffff000);
        assert(res[19] === 32'hcdef1200);
        assert(res[20] === 32'h9bde2400);
        assert(res[21] === 32'habcdef12);
        assert(res[22] === 32'h00);
        assert(res[23] === 0);
        assert(res[24] === 1);
        assert(res[25] === 0);
        assert(res[26] === 0);
        assert(res[27] === 0);
        assert(res[28] === 1);
        assert(res[29] === 0);
        assert(res[30] === 0);
        assert(res[31] === 0);
        assert(res[32] === 0);
        assert(res[33] === 1);
        assert(res[34] === 1);
        assert(res[35] === 1);
        assert(res[36] === 0);
        assert(res[37] === 1);
        assert(res[38] === 1);
        assert(res[39] === 0);
        assert(res[40] === 0);
        assert(res[41] === 1);
        assert(res[42] === 1);
        assert(res[43] === 0);
        assert(res[44] === 0);
        assert(res[45] === 0);
        assert(res[46] === 1);
        assert(res[47] === 0);
        assert(res[48] === 0);
        assert(res[49] === 32'hff);
        assert(res[50] === 32'h00);
        assert(res[51] === 32'h0fffff00);
        assert(res[52] === 32'h00fffff0);
        assert(res[53] === 32'hffffff00);
        assert(res[54] === 32'hfffffff0);
        assert(res[55] === 32'hf0);
        assert(res[56] === 32'hff);
        assert(res[57] === 32'hff);
        assert(res[58] === 32'hff);
        assert(res[59] === 32'h0f);
        assert(res[60] === 32'h00);
        assert(res[61] === 32'h04);
        assert(res[62] === 32'hcdef1200);
        assert(res[63] === 32'h9bde2400);
        assert(res[64] === 32'habcdef12);
        assert(res[65] === 0);
        assert(res[66] === 1);
        assert(res[67] === 0);
        assert(res[68] === 0);
        assert(res[69] === 0);
        assert(res[70] === 1);
        assert(res[71] === 0);
        assert(res[72] === 0);
        assert(res[73] === 0);
        assert(res[74] === 0);
        assert(res[75] === 1);
        assert(res[76] === 1);
        assert(res[77] === 1);
        assert(res[78] === 0);
        assert(res[79] === 1);
        assert(res[80] === 1);
        assert(res[81] === 0);
        assert(res[82] === 0);
        assert(res[83] === 1);
        assert(res[84] === 1);
        assert(res[85] === 0);
        assert(res[86] === 0);
        assert(res[87] === 0);
        assert(res[88] === 1);
        assert(res[89] === 0);
        assert(res[90] === 0);
        assert(res[91] === 32'hff);
        assert(res[92] === 32'h00);
        assert(res[93] === 32'h0fffff00);
        assert(res[94] === 32'h00fffff0);
        assert(res[95] === 32'hffffff00);
        assert(res[96] === 32'hfffffff0);
        assert(res[97] === 32'hf0);
        assert(res[98] === 32'hff);
        assert(res[99] === 32'hff);
        assert(res[100] === 32'hff);
        assert(res[101] === 32'h0f);
        assert(res[102] === 32'h00);
        assert(res[103] === 20);
        assert(res[104] === 25);
        assert(res[105] === 0);
        assert(res[106] === -5);
        assert(res[107] === 20);
        assert(res[108] === 25);
        assert(res[109] === 0);
        assert(res[110] === -5);
        assert(res[111] === 20);
        assert(res[112] === -20);
        assert(res[113] === -5);
        assert(res[114] === 45);
        assert(res[115] === 1);
        assert(res[116] === 1);
        assert(res[117] === 1);
        assert(res[118] === 1);
        assert(res[119] === 6);
        assert(res[120] === 6);
        assert(res[121] === 6);
        assert(res[122] === 6);
        assert(res[123] === 6);
        assert(res[124] === 6);
        assert(res[125] === 6);
        assert(res[126] === 6);

        assert(led[0] === 1'b0);
        assert(led[1] === 1'b1);

        #18 $finish;
    end
endmodule
