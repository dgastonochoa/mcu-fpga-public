`timescale 1ns/100ps

`ifndef VCD
    `define VCD "riscv_single_all_instr_top_tb.vcd"
`endif

`include "riscv_test_utils.svh"

/**
 * Address from which the data will be written. It is added to the 'sp' register
 * (x2) in 'all_instr_program_test_instr_mem.txt' (first instruction). The
 * test program is expected to write all data using this register as base.
 *
 * Therefore it is expected tha the first instruction of the test program sets
 * the 'sp' register to this value, and all store instructions use 'sp' as base.
 *
 */
`define DATA_OFFS   1728

/**
 * The memory will be checked by accessing it in terms of words.
 *
 */
`define DATA_IDX    (`DATA_OFFS / 4)

module riscv_single_all_instr_top_tb;
    reg clk = 0;

    always #5 clk = ~clk;


    reg btnC = 0;
    wire [15:0] led;
    wire [7:0] ja;

    riscv_single_all_instr_top dut(btnC, led, ja, clk);


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
            3'd0: word[31:24] <= s_rd;
            3'd1: word[23:16] <= s_rd;
            3'd2: word[15:8]  <= s_rd;
            3'd3: word[7:0]   <= s_rd;
            endcase
            cnt <= (cnt == 3'd3 ? 3'd0 : cnt + 1);

            if (cnt == 3'd3) begin
                #1  res[cnt2] <= word;
                cnt2 <= cnt2 + 1;
            end
        end
    end


    integer i = 0;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, riscv_single_all_instr_top_tb);

        // Reset
        #5  btnC = 1;
        #20 btnC = 0;

        //
        // Program finishes correctly
        //
        wait(dut.pc === 32'h680);
        assert(`MEM_DATA[`DATA_IDX + 0] === 37);
        assert(`MEM_DATA[`DATA_IDX + 1] === 40);
        assert(`MEM_DATA[`DATA_IDX + 2] === 24);
        assert(`MEM_DATA[`DATA_IDX + 3] === 32'habcdef12);
        assert(`MEM_DATA[`DATA_IDX + 4] === 32'h12);
        assert(`MEM_DATA[`DATA_IDX + 5] === 32'hef);
        assert(`MEM_DATA[`DATA_IDX + 6] === 32'hcd);
        assert(`MEM_DATA[`DATA_IDX + 7] === 32'hab);
        assert(`MEM_DATA[`DATA_IDX + 8] === 32'hef12);
        assert(`MEM_DATA[`DATA_IDX + 9] === 32'habcd);
        assert(`MEM_DATA[`DATA_IDX + 10] === 32'habcdef12);
        assert(`MEM_DATA[`DATA_IDX + 11] === 32'hxxxxef12);
        assert(`MEM_DATA[`DATA_IDX + 12] === 32'hxxxxxx12);
        assert(`MEM_DATA[`DATA_IDX + 13] === 32'h00000012);
        assert(`MEM_DATA[`DATA_IDX + 14] === 32'hffffffef);
        assert(`MEM_DATA[`DATA_IDX + 15] === 32'hffffffcd);
        assert(`MEM_DATA[`DATA_IDX + 16] === 32'hffffffab);
        assert(`MEM_DATA[`DATA_IDX + 17] === 32'hffffef12);
        assert(`MEM_DATA[`DATA_IDX + 18] === 32'h7ffff000);
        assert(`MEM_DATA[`DATA_IDX + 19] === 32'hcdef1200);
        assert(`MEM_DATA[`DATA_IDX + 20] === 32'h9bde2400);
        assert(`MEM_DATA[`DATA_IDX + 21] === 32'habcdef12);
        assert(`MEM_DATA[`DATA_IDX + 22] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 23] === 0);
        assert(`MEM_DATA[`DATA_IDX + 24] === 1);
        assert(`MEM_DATA[`DATA_IDX + 25] === 0);
        assert(`MEM_DATA[`DATA_IDX + 26] === 0);
        assert(`MEM_DATA[`DATA_IDX + 27] === 0);
        assert(`MEM_DATA[`DATA_IDX + 28] === 1);
        assert(`MEM_DATA[`DATA_IDX + 29] === 0);
        assert(`MEM_DATA[`DATA_IDX + 30] === 0);
        assert(`MEM_DATA[`DATA_IDX + 31] === 0);
        assert(`MEM_DATA[`DATA_IDX + 32] === 0);
        assert(`MEM_DATA[`DATA_IDX + 33] === 1);
        assert(`MEM_DATA[`DATA_IDX + 34] === 1);
        assert(`MEM_DATA[`DATA_IDX + 35] === 1);
        assert(`MEM_DATA[`DATA_IDX + 36] === 0);
        assert(`MEM_DATA[`DATA_IDX + 37] === 1);
        assert(`MEM_DATA[`DATA_IDX + 38] === 1);
        assert(`MEM_DATA[`DATA_IDX + 39] === 0);
        assert(`MEM_DATA[`DATA_IDX + 40] === 0);
        assert(`MEM_DATA[`DATA_IDX + 41] === 1);
        assert(`MEM_DATA[`DATA_IDX + 42] === 1);
        assert(`MEM_DATA[`DATA_IDX + 43] === 0);
        assert(`MEM_DATA[`DATA_IDX + 44] === 0);
        assert(`MEM_DATA[`DATA_IDX + 45] === 0);
        assert(`MEM_DATA[`DATA_IDX + 46] === 1);
        assert(`MEM_DATA[`DATA_IDX + 47] === 0);
        assert(`MEM_DATA[`DATA_IDX + 48] === 0);
        assert(`MEM_DATA[`DATA_IDX + 49] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 50] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 51] === 32'h0fffff00);
        assert(`MEM_DATA[`DATA_IDX + 52] === 32'h00fffff0);
        assert(`MEM_DATA[`DATA_IDX + 53] === 32'hffffff00);
        assert(`MEM_DATA[`DATA_IDX + 54] === 32'hfffffff0);
        assert(`MEM_DATA[`DATA_IDX + 55] === 32'hf0);
        assert(`MEM_DATA[`DATA_IDX + 56] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 57] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 58] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 59] === 32'h0f);
        assert(`MEM_DATA[`DATA_IDX + 60] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 61] === 32'h04);
        assert(`MEM_DATA[`DATA_IDX + 62] === 32'hcdef1200);
        assert(`MEM_DATA[`DATA_IDX + 63] === 32'h9bde2400);
        assert(`MEM_DATA[`DATA_IDX + 64] === 32'habcdef12);
        assert(`MEM_DATA[`DATA_IDX + 65] === 0);
        assert(`MEM_DATA[`DATA_IDX + 66] === 1);
        assert(`MEM_DATA[`DATA_IDX + 67] === 0);
        assert(`MEM_DATA[`DATA_IDX + 68] === 0);
        assert(`MEM_DATA[`DATA_IDX + 69] === 0);
        assert(`MEM_DATA[`DATA_IDX + 70] === 1);
        assert(`MEM_DATA[`DATA_IDX + 71] === 0);
        assert(`MEM_DATA[`DATA_IDX + 72] === 0);
        assert(`MEM_DATA[`DATA_IDX + 73] === 0);
        assert(`MEM_DATA[`DATA_IDX + 74] === 0);
        assert(`MEM_DATA[`DATA_IDX + 75] === 1);
        assert(`MEM_DATA[`DATA_IDX + 76] === 1);
        assert(`MEM_DATA[`DATA_IDX + 77] === 1);
        assert(`MEM_DATA[`DATA_IDX + 78] === 0);
        assert(`MEM_DATA[`DATA_IDX + 79] === 1);
        assert(`MEM_DATA[`DATA_IDX + 80] === 1);
        assert(`MEM_DATA[`DATA_IDX + 81] === 0);
        assert(`MEM_DATA[`DATA_IDX + 82] === 0);
        assert(`MEM_DATA[`DATA_IDX + 83] === 1);
        assert(`MEM_DATA[`DATA_IDX + 84] === 1);
        assert(`MEM_DATA[`DATA_IDX + 85] === 0);
        assert(`MEM_DATA[`DATA_IDX + 86] === 0);
        assert(`MEM_DATA[`DATA_IDX + 87] === 0);
        assert(`MEM_DATA[`DATA_IDX + 88] === 1);
        assert(`MEM_DATA[`DATA_IDX + 89] === 0);
        assert(`MEM_DATA[`DATA_IDX + 90] === 0);
        assert(`MEM_DATA[`DATA_IDX + 91] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 92] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 93] === 32'h0fffff00);
        assert(`MEM_DATA[`DATA_IDX + 94] === 32'h00fffff0);
        assert(`MEM_DATA[`DATA_IDX + 95] === 32'hffffff00);
        assert(`MEM_DATA[`DATA_IDX + 96] === 32'hfffffff0);
        assert(`MEM_DATA[`DATA_IDX + 97] === 32'hf0);
        assert(`MEM_DATA[`DATA_IDX + 98] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 99] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 100] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 101] === 32'h0f);
        assert(`MEM_DATA[`DATA_IDX + 102] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 103] === 20);
        assert(`MEM_DATA[`DATA_IDX + 104] === 25);
        assert(`MEM_DATA[`DATA_IDX + 105] === 0);
        assert(`MEM_DATA[`DATA_IDX + 106] === -5);
        assert(`MEM_DATA[`DATA_IDX + 107] === 20);
        assert(`MEM_DATA[`DATA_IDX + 108] === 25);
        assert(`MEM_DATA[`DATA_IDX + 109] === 0);
        assert(`MEM_DATA[`DATA_IDX + 110] === -5);
        assert(`MEM_DATA[`DATA_IDX + 111] === 20);
        assert(`MEM_DATA[`DATA_IDX + 112] === -20);
        assert(`MEM_DATA[`DATA_IDX + 113] === -5);
        assert(`MEM_DATA[`DATA_IDX + 114] === 45);
        assert(`MEM_DATA[`DATA_IDX + 115] === 1);
        assert(`MEM_DATA[`DATA_IDX + 116] === 1);
        assert(`MEM_DATA[`DATA_IDX + 117] === 1);
        assert(`MEM_DATA[`DATA_IDX + 118] === 1);
        assert(`MEM_DATA[`DATA_IDX + 119] === 6);
        assert(`MEM_DATA[`DATA_IDX + 120] === 6);
        assert(`MEM_DATA[`DATA_IDX + 121] === 6);
        assert(`MEM_DATA[`DATA_IDX + 122] === 6);
        assert(`MEM_DATA[`DATA_IDX + 123] === 6);
        assert(`MEM_DATA[`DATA_IDX + 124] === 6);
        assert(`MEM_DATA[`DATA_IDX + 125] === 6);
        assert(`MEM_DATA[`DATA_IDX + 126] === 6);


        //
        // SPI sends all the results
        //
        wait(dut.msc.cs === 3'd4);
        #100;
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

        #18 $finish;
    end
endmodule
