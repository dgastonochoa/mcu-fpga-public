`timescale 1ns/1ns

`include "riscv_all_instr_physical_fpga_test.svh"

`include "riscv/test/test_mcu.svh"
`include "riscv/test/test_cpu_mem.svh"

`ifndef VCD
    `define VCD "riscv_single_all_instr_top_tb.vcd"
`endif

`ifdef CONFIG_RISCV_MULTICYCLE
    /**
     * Expected first instruction (set the sp to `DATA_OFFS)
     *
     */
    `define FIRST_INSTR 32'h6c000113

`else
    `define FIRST_INSTR 32'h00000113
`endif // CONFIG_RISCV_MULTICYCLE

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
    reg [31:0] res [255];
    reg [7:0] s_wd = 8'd0;
    wire mosi, miso, ss, sck;
    wire s_busy, s_rdy;
    wire [7:0] s_rd;

    assign {mosi, miso, ss, sck} = ja[3:0];

    spi_slave spis(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, btnC, sck, clk);

    reg [31:0] word, cnt2;
    reg [3:0] cnt;

    always @(posedge s_rdy, posedge btnC) begin
        if (btnC) begin
            cnt <= 0;
            cnt2 <= 0;
            word <= 0;
        end else begin
            #1 case (cnt)
            3'd0: word[7:0]   <= s_rd;
            3'd1: word[15:8]  <= s_rd;
            3'd2: word[23:16] <= s_rd;
            3'd3: word[31:24] <= s_rd;
            endcase
            cnt <= (cnt == 3'd3 ? 3'd0 : cnt + 1);

            if (cnt == 3'd3) begin
                #1  res[cnt2] <= word;
                cnt2 <= cnt2 + 1;
            end
        end
    end

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, riscv_all_instr_physical_fpga_test_top_tb);

        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 0) === `FIRST_INSTR);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 1) === 32'h02500293);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 2) === 32'h00328313);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 455) === 32'hffc10113);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 456) === 32'h00012083);
        assert(`CPU_MEM_GET_I(`MCU_GET_M(dut.m), 457) === 32'h00008067);

        // Reset
        #5  btnC = 1;
        #20 btnC = 0;

        `WAIT_CLKS(clk, 1000);

        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 0) === 37);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 1) === 40);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 2) === 24);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 3) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 4) === 32'h12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 5) === 32'hef);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 6) === 32'hcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 7) === 32'hab);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 8) === 32'hef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 9) === 32'habcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 10) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 11) === 32'hxxxxef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 12) === 32'hxxxxxx12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 13) === 32'h00000012);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 14) === 32'hffffffef);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 15) === 32'hffffffcd);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 16) === 32'hffffffab);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 17) === 32'hffffef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 18) === 32'h7ffff000);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 19) === 32'hcdef1200);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 20) === 32'h9bde2400);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 21) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 22) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 23) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 24) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 25) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 26) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 27) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 28) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 29) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 30) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 31) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 32) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 33) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 34) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 35) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 36) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 37) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 38) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 39) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 40) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 41) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 42) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 43) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 44) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 45) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 46) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 47) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 48) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 49) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 50) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 51) === 32'h0fffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 52) === 32'h00fffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 53) === 32'hffffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 54) === 32'hfffffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 55) === 32'hf0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 56) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 57) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 58) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 59) === 32'h0f);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 60) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 61) === 32'h04);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 62) === 32'hcdef1200);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 63) === 32'h9bde2400);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 64) === 32'habcdef12);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 65) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 66) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 67) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 68) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 69) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 70) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 71) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 72) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 73) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 74) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 75) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 76) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 77) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 78) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 79) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 80) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 81) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 82) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 83) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 84) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 85) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 86) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 87) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 88) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 89) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 90) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 91) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 92) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 93) === 32'h0fffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 94) === 32'h00fffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 95) === 32'hffffff00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 96) === 32'hfffffff0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 97) === 32'hf0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 98) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 99) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 100) === 32'hff);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 101) === 32'h0f);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 102) === 32'h00);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 103) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 104) === 25);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 105) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 106) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 107) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 108) === 25);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 109) === 0);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 110) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 111) === 20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 112) === -20);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 113) === -5);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 114) === 45);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 115) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 116) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 117) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 118) === 1);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 119) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 120) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 121) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 122) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 123) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 124) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 125) === 6);
        assert(`CPU_MEM_GET_D(`MCU_GET_M(dut.m), 126) === 6);

        assert(led[0] === 1'b1);




        //
        // SPI sends all the results
        //
        `WAIT_CLKS(clk, 100000);

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
