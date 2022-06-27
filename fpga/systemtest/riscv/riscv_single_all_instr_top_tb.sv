`timescale 1ns/100ps

`ifndef VCD
    `define VCD "riscv_single_all_instr_top_tb.vcd"
`endif

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
        assert(dut.rv.data_mem._mem._mem[0] === 37);
        assert(dut.rv.data_mem._mem._mem[1] === 40);
        assert(dut.rv.data_mem._mem._mem[2] === 24);
        assert(dut.rv.data_mem._mem._mem[3] === 32'habcdef12);
        assert(dut.rv.data_mem._mem._mem[4] === 32'h12);
        assert(dut.rv.data_mem._mem._mem[5] === 32'hef);
        assert(dut.rv.data_mem._mem._mem[6] === 32'hcd);
        assert(dut.rv.data_mem._mem._mem[7] === 32'hab);
        assert(dut.rv.data_mem._mem._mem[8] === 32'hef12);
        assert(dut.rv.data_mem._mem._mem[9] === 32'habcd);
        assert(dut.rv.data_mem._mem._mem[10] === 32'habcdef12);
        assert(dut.rv.data_mem._mem._mem[11] === 32'hxxxxef12);
        assert(dut.rv.data_mem._mem._mem[12] === 32'hxxxxxx12);
        assert(dut.rv.data_mem._mem._mem[13] === 32'h00000012);
        assert(dut.rv.data_mem._mem._mem[14] === 32'hffffffef);
        assert(dut.rv.data_mem._mem._mem[15] === 32'hffffffcd);
        assert(dut.rv.data_mem._mem._mem[16] === 32'hffffffab);
        assert(dut.rv.data_mem._mem._mem[17] === 32'hffffef12);
        assert(dut.rv.data_mem._mem._mem[18] === 32'h7ffff000);
        assert(dut.rv.data_mem._mem._mem[19] === 32'hcdef1200);
        assert(dut.rv.data_mem._mem._mem[20] === 32'h9bde2400);
        assert(dut.rv.data_mem._mem._mem[21] === 32'habcdef12);
        assert(dut.rv.data_mem._mem._mem[22] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[23] === 0);
        assert(dut.rv.data_mem._mem._mem[24] === 1);
        assert(dut.rv.data_mem._mem._mem[25] === 0);
        assert(dut.rv.data_mem._mem._mem[26] === 0);
        assert(dut.rv.data_mem._mem._mem[27] === 0);
        assert(dut.rv.data_mem._mem._mem[28] === 1);
        assert(dut.rv.data_mem._mem._mem[29] === 0);
        assert(dut.rv.data_mem._mem._mem[30] === 0);
        assert(dut.rv.data_mem._mem._mem[31] === 0);
        assert(dut.rv.data_mem._mem._mem[32] === 0);
        assert(dut.rv.data_mem._mem._mem[33] === 1);
        assert(dut.rv.data_mem._mem._mem[34] === 1);
        assert(dut.rv.data_mem._mem._mem[35] === 1);
        assert(dut.rv.data_mem._mem._mem[36] === 0);
        assert(dut.rv.data_mem._mem._mem[37] === 1);
        assert(dut.rv.data_mem._mem._mem[38] === 1);
        assert(dut.rv.data_mem._mem._mem[39] === 0);
        assert(dut.rv.data_mem._mem._mem[40] === 0);
        assert(dut.rv.data_mem._mem._mem[41] === 1);
        assert(dut.rv.data_mem._mem._mem[42] === 1);
        assert(dut.rv.data_mem._mem._mem[43] === 0);
        assert(dut.rv.data_mem._mem._mem[44] === 0);
        assert(dut.rv.data_mem._mem._mem[45] === 0);
        assert(dut.rv.data_mem._mem._mem[46] === 1);
        assert(dut.rv.data_mem._mem._mem[47] === 0);
        assert(dut.rv.data_mem._mem._mem[48] === 0);
        assert(dut.rv.data_mem._mem._mem[49] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[50] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[51] === 32'h0fffff00);
        assert(dut.rv.data_mem._mem._mem[52] === 32'h00fffff0);
        assert(dut.rv.data_mem._mem._mem[53] === 32'hffffff00);
        assert(dut.rv.data_mem._mem._mem[54] === 32'hfffffff0);
        assert(dut.rv.data_mem._mem._mem[55] === 32'hf0);
        assert(dut.rv.data_mem._mem._mem[56] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[57] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[58] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[59] === 32'h0f);
        assert(dut.rv.data_mem._mem._mem[60] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[61] === 32'h04);
        assert(dut.rv.data_mem._mem._mem[62] === 32'hcdef1200);
        assert(dut.rv.data_mem._mem._mem[63] === 32'h9bde2400);
        assert(dut.rv.data_mem._mem._mem[64] === 32'habcdef12);
        assert(dut.rv.data_mem._mem._mem[65] === 0);
        assert(dut.rv.data_mem._mem._mem[66] === 1);
        assert(dut.rv.data_mem._mem._mem[67] === 0);
        assert(dut.rv.data_mem._mem._mem[68] === 0);
        assert(dut.rv.data_mem._mem._mem[69] === 0);
        assert(dut.rv.data_mem._mem._mem[70] === 1);
        assert(dut.rv.data_mem._mem._mem[71] === 0);
        assert(dut.rv.data_mem._mem._mem[72] === 0);
        assert(dut.rv.data_mem._mem._mem[73] === 0);
        assert(dut.rv.data_mem._mem._mem[74] === 0);
        assert(dut.rv.data_mem._mem._mem[75] === 1);
        assert(dut.rv.data_mem._mem._mem[76] === 1);
        assert(dut.rv.data_mem._mem._mem[77] === 1);
        assert(dut.rv.data_mem._mem._mem[78] === 0);
        assert(dut.rv.data_mem._mem._mem[79] === 1);
        assert(dut.rv.data_mem._mem._mem[80] === 1);
        assert(dut.rv.data_mem._mem._mem[81] === 0);
        assert(dut.rv.data_mem._mem._mem[82] === 0);
        assert(dut.rv.data_mem._mem._mem[83] === 1);
        assert(dut.rv.data_mem._mem._mem[84] === 1);
        assert(dut.rv.data_mem._mem._mem[85] === 0);
        assert(dut.rv.data_mem._mem._mem[86] === 0);
        assert(dut.rv.data_mem._mem._mem[87] === 0);
        assert(dut.rv.data_mem._mem._mem[88] === 1);
        assert(dut.rv.data_mem._mem._mem[89] === 0);
        assert(dut.rv.data_mem._mem._mem[90] === 0);
        assert(dut.rv.data_mem._mem._mem[91] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[92] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[93] === 32'h0fffff00);
        assert(dut.rv.data_mem._mem._mem[94] === 32'h00fffff0);
        assert(dut.rv.data_mem._mem._mem[95] === 32'hffffff00);
        assert(dut.rv.data_mem._mem._mem[96] === 32'hfffffff0);
        assert(dut.rv.data_mem._mem._mem[97] === 32'hf0);
        assert(dut.rv.data_mem._mem._mem[98] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[99] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[100] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[101] === 32'h0f);
        assert(dut.rv.data_mem._mem._mem[102] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[103] === 20);
        assert(dut.rv.data_mem._mem._mem[104] === 25);
        assert(dut.rv.data_mem._mem._mem[105] === 0);
        assert(dut.rv.data_mem._mem._mem[106] === -5);
        assert(dut.rv.data_mem._mem._mem[107] === 20);
        assert(dut.rv.data_mem._mem._mem[108] === 25);
        assert(dut.rv.data_mem._mem._mem[109] === 0);
        assert(dut.rv.data_mem._mem._mem[110] === -5);
        assert(dut.rv.data_mem._mem._mem[111] === 20);
        assert(dut.rv.data_mem._mem._mem[112] === -20);
        assert(dut.rv.data_mem._mem._mem[113] === -5);
        assert(dut.rv.data_mem._mem._mem[114] === 45);
        assert(dut.rv.data_mem._mem._mem[115] === 1);
        assert(dut.rv.data_mem._mem._mem[116] === 1);
        assert(dut.rv.data_mem._mem._mem[117] === 1);
        assert(dut.rv.data_mem._mem._mem[118] === 1);
        assert(dut.rv.data_mem._mem._mem[119] === 6);
        assert(dut.rv.data_mem._mem._mem[120] === 6);
        assert(dut.rv.data_mem._mem._mem[121] === 6);
        assert(dut.rv.data_mem._mem._mem[122] === 6);
        assert(dut.rv.data_mem._mem._mem[123] === 6);
        assert(dut.rv.data_mem._mem._mem[124] === 6);
        assert(dut.rv.data_mem._mem._mem[125] === 6);
        assert(dut.rv.data_mem._mem._mem[126] === 6);


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
