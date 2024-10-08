`ifndef RISCV_MULTI_ALL_INSTR_MEM_MAP_SVH
`define RISCV_MULTI_ALL_INSTR_MEM_MAP_SVH
`define INIT_MEM_F(mem_reg) \
mem_reg[0] = 32'h00001117;                                  \
mem_reg[1] = 32'h80010113;                                  \
mem_reg[2] = 32'h0040006f;                                  \
mem_reg[3] = 32'h3d4000ef;                                  \
mem_reg[4] = 32'h22c000ef;                                  \
mem_reg[5] = 32'h334000ef;                                  \
mem_reg[6] = 32'hff9ff06f;                                  \
mem_reg[7] = 32'h00000000;                                  \
mem_reg[8] = 32'hffc10113;                                  \
mem_reg[9] = 32'h00112023;                                  \
mem_reg[10] = 32'h80000537;                                 \
mem_reg[11] = 32'h08050513;                                 \
mem_reg[12] = 32'h00100593;                                 \
mem_reg[13] = 32'h00200293;                                 \
mem_reg[14] = 32'h02590063;                                 \
mem_reg[15] = 32'h00300293;                                 \
mem_reg[16] = 32'h02590263;                                 \
mem_reg[17] = 32'h00400293;                                 \
mem_reg[18] = 32'h02590c63;                                 \
mem_reg[19] = 32'h00500293;                                 \
mem_reg[20] = 32'h04590463;                                 \
mem_reg[21] = 32'h05590863;                                 \
mem_reg[22] = 32'h3a8000ef;                                 \
mem_reg[23] = 32'h00300913;                                 \
mem_reg[24] = 32'h044000ef;                                 \
mem_reg[25] = 32'h0ff00293;                                 \
mem_reg[26] = 32'h00500913;                                 \
mem_reg[27] = 32'h0ff00313;                                 \
mem_reg[28] = 32'h02699a63;                                 \
mem_reg[29] = 32'h38c000ef;                                 \
mem_reg[30] = 32'h00400913;                                 \
mem_reg[31] = 32'h028000ef;                                 \
mem_reg[32] = 32'h0ff00293;                                 \
mem_reg[33] = 32'h00500913;                                 \
mem_reg[34] = 32'h0ff00313;                                 \
mem_reg[35] = 32'h00698c63;                                 \
mem_reg[36] = 32'h01500933;                                 \
mem_reg[37] = 32'h010000ef;                                 \
mem_reg[38] = 32'h368000ef;                                 \
mem_reg[39] = 32'h00300913;                                 \
mem_reg[40] = 32'h004000ef;                                 \
mem_reg[41] = 32'h00000513;                                 \
mem_reg[42] = 32'h00012083;                                 \
mem_reg[43] = 32'h00410113;                                 \
mem_reg[44] = 32'h00008067;                                 \
mem_reg[45] = 32'hffc10113;                                 \
mem_reg[46] = 32'h00112023;                                 \
mem_reg[47] = 32'h00200293;                                 \
mem_reg[48] = 32'h02590063;                                 \
mem_reg[49] = 32'h00300293;                                 \
mem_reg[50] = 32'h02590063;                                 \
mem_reg[51] = 32'h00400293;                                 \
mem_reg[52] = 32'h02590663;                                 \
mem_reg[53] = 32'h00500293;                                 \
mem_reg[54] = 32'h02590c63;                                 \
mem_reg[55] = 32'h05590063;                                 \
mem_reg[56] = 32'h00000993;                                 \
mem_reg[57] = 32'h0380006f;                                 \
mem_reg[58] = 32'h80000537;                                 \
mem_reg[59] = 32'h3e8000ef;                                 \
mem_reg[60] = 32'h00c00533;                                 \
mem_reg[61] = 32'h00b009b3;                                 \
mem_reg[62] = 32'h0240006f;                                 \
mem_reg[63] = 32'h80000537;                                 \
mem_reg[64] = 32'h3d4000ef;                                 \
mem_reg[65] = 32'h00c00533;                                 \
mem_reg[66] = 32'h00b009b3;                                 \
mem_reg[67] = 32'h0100006f;                                 \
mem_reg[68] = 32'h013a0023;                                 \
mem_reg[69] = 32'h001a0a13;                                 \
mem_reg[70] = 32'h0040006f;                                 \
mem_reg[71] = 32'h00000513;                                 \
mem_reg[72] = 32'h00012083;                                 \
mem_reg[73] = 32'h00410113;                                 \
mem_reg[74] = 32'h00008067;                                 \
mem_reg[75] = 32'hffc10113;                                 \
mem_reg[76] = 32'h00112023;                                 \
mem_reg[77] = 32'h80000537;                                 \
mem_reg[78] = 32'h08050513;                                 \
mem_reg[79] = 32'h00100593;                                 \
mem_reg[80] = 32'h00600293;                                 \
mem_reg[81] = 32'h00590a63;                                 \
mem_reg[82] = 32'h00700293;                                 \
mem_reg[83] = 32'h00590c63;                                 \
mem_reg[84] = 32'h0ff00293;                                 \
mem_reg[85] = 32'h02590463;                                 \
mem_reg[86] = 32'h2a8000ef;                                 \
mem_reg[87] = 32'h00700913;                                 \
mem_reg[88] = 32'h01c0006f;                                 \
mem_reg[89] = 32'h01600933;                                 \
mem_reg[90] = 32'h00200293;                                 \
mem_reg[91] = 32'h00598863;                                 \
mem_reg[92] = 32'h290000ef;                                 \
mem_reg[93] = 32'h00700913;                                 \
mem_reg[94] = 32'h0040006f;                                 \
mem_reg[95] = 32'h00000513;                                 \
mem_reg[96] = 32'h00012083;                                 \
mem_reg[97] = 32'h00410113;                                 \
mem_reg[98] = 32'h00008067;                                 \
mem_reg[99] = 32'hffc10113;                                 \
mem_reg[100] = 32'h00112023;                                \
mem_reg[101] = 32'h80000537;                                \
mem_reg[102] = 32'h08050513;                                \
mem_reg[103] = 32'h00100593;                                \
mem_reg[104] = 32'h00600293;                                \
mem_reg[105] = 32'h00590a63;                                \
mem_reg[106] = 32'h00700293;                                \
mem_reg[107] = 32'h00590a63;                                \
mem_reg[108] = 32'h0ff00293;                                \
mem_reg[109] = 32'h02590263;                                \
mem_reg[110] = 32'h00000993;                                \
mem_reg[111] = 32'h01c0006f;                                \
mem_reg[112] = 32'h80000537;                                \
mem_reg[113] = 32'h014005b3;                                \
mem_reg[114] = 32'h020000ef;                                \
mem_reg[115] = 32'h00c009b3;                                \
mem_reg[116] = 32'h00b00a33;                                \
mem_reg[117] = 32'h0040006f;                                \
mem_reg[118] = 32'h00000513;                                \
mem_reg[119] = 32'h00012083;                                \
mem_reg[120] = 32'h00410113;                                \
mem_reg[121] = 32'h00008067;                                \
mem_reg[122] = 32'hffc10113;                                \
mem_reg[123] = 32'h00112023;                                \
mem_reg[124] = 32'hffc10113;                                \
mem_reg[125] = 32'h01212023;                                \
mem_reg[126] = 32'hffc10113;                                \
mem_reg[127] = 32'h01312023;                                \
mem_reg[128] = 32'h00a00933;                                \
mem_reg[129] = 32'h00b009b3;                                \
mem_reg[130] = 32'h00058583;                                \
mem_reg[131] = 32'h280000ef;                                \
mem_reg[132] = 32'h01200533;                                \
mem_reg[133] = 32'h314000ef;                                \
mem_reg[134] = 32'h00b00633;                                \
mem_reg[135] = 32'h00198593;                                \
mem_reg[136] = 32'h00012983;                                \
mem_reg[137] = 32'h00410113;                                \
mem_reg[138] = 32'h00012903;                                \
mem_reg[139] = 32'h00410113;                                \
mem_reg[140] = 32'h00012083;                                \
mem_reg[141] = 32'h00410113;                                \
mem_reg[142] = 32'h00008067;                                \
mem_reg[143] = 32'hffc10113;                                \
mem_reg[144] = 32'h00112023;                                \
mem_reg[145] = 32'h0ff00293;                                \
mem_reg[146] = 32'h0c590a63;                                \
mem_reg[147] = 32'h00800293;                                \
mem_reg[148] = 32'h08590a63;                                \
mem_reg[149] = 32'h00000293;                                \
mem_reg[150] = 32'h06590a63;                                \
mem_reg[151] = 32'h00100293;                                \
mem_reg[152] = 32'h00500313;                                \
mem_reg[153] = 32'h00591463;                                \
mem_reg[154] = 32'h08698263;                                \
mem_reg[155] = 32'h00100293;                                \
mem_reg[156] = 32'h00300313;                                \
mem_reg[157] = 32'h00591463;                                \
mem_reg[158] = 32'h06698e63;                                \
mem_reg[159] = 32'h00100293;                                \
mem_reg[160] = 32'h00400313;                                \
mem_reg[161] = 32'h00591463;                                \
mem_reg[162] = 32'h06698a63;                                \
mem_reg[163] = 32'h00100293;                                \
mem_reg[164] = 32'h00200313;                                \
mem_reg[165] = 32'h00591463;                                \
mem_reg[166] = 32'h06698663;                                \
mem_reg[167] = 32'h01200533;                                \
mem_reg[168] = 32'h00200593;                                \
mem_reg[169] = 32'h00500613;                                \
mem_reg[170] = 32'h084000ef;                                \
mem_reg[171] = 32'h06051063;                                \
mem_reg[172] = 32'h01200533;                                \
mem_reg[173] = 32'h00600593;                                \
mem_reg[174] = 32'h00700613;                                \
mem_reg[175] = 32'h070000ef;                                \
mem_reg[176] = 32'h04051a63;                                \
mem_reg[177] = 32'h00000913;                                \
mem_reg[178] = 32'h0540006f;                                \
mem_reg[179] = 32'h80000537;                                \
mem_reg[180] = 32'h08050513;                                \
mem_reg[181] = 32'h00100593;                                \
mem_reg[182] = 32'h128000ef;                                \
mem_reg[183] = 32'h00100913;                                \
mem_reg[184] = 32'h03c0006f;                                \
mem_reg[185] = 32'h01100933;                                \
mem_reg[186] = 32'h0340006f;                                \
mem_reg[187] = 32'h00800913;                                \
mem_reg[188] = 32'h02c0006f;                                \
mem_reg[189] = 32'h00200913;                                \
mem_reg[190] = 32'h0240006f;                                \
mem_reg[191] = 32'h00600913;                                \
mem_reg[192] = 32'h01c0006f;                                \
mem_reg[193] = 32'h00000913;                                \
mem_reg[194] = 32'h0140006f;                                \
mem_reg[195] = 32'hd15ff0ef;                                \
mem_reg[196] = 32'h00c0006f;                                \
mem_reg[197] = 32'he19ff0ef;                                \
mem_reg[198] = 32'h0040006f;                                \
mem_reg[199] = 32'h00000513;                                \
mem_reg[200] = 32'h00012083;                                \
mem_reg[201] = 32'h00410113;                                \
mem_reg[202] = 32'h00008067;                                \
mem_reg[203] = 32'h00000293;                                \
mem_reg[204] = 32'h00c50663;                                \
mem_reg[205] = 32'h00b54663;                                \
mem_reg[206] = 32'h00c55463;                                \
mem_reg[207] = 32'h00100293;                                \
mem_reg[208] = 32'h00500533;                                \
mem_reg[209] = 32'h00008067;                                \
mem_reg[210] = 32'hffc10113;                                \
mem_reg[211] = 32'h00112023;                                \
mem_reg[212] = 32'h00000293;                                \
mem_reg[213] = 32'h04590263;                                \
mem_reg[214] = 32'h00100293;                                \
mem_reg[215] = 32'h04590663;                                \
mem_reg[216] = 32'h00800293;                                \
mem_reg[217] = 32'h04590a63;                                \
mem_reg[218] = 32'h0ff00293;                                \
mem_reg[219] = 32'h06590263;                                \
mem_reg[220] = 32'h01200533;                                \
mem_reg[221] = 32'h00200593;                                \
mem_reg[222] = 32'h00500613;                                \
mem_reg[223] = 32'hfb1ff0ef;                                \
mem_reg[224] = 32'h04051063;                                \
mem_reg[225] = 32'h01200533;                                \
mem_reg[226] = 32'h00600593;                                \
mem_reg[227] = 32'h00700613;                                \
mem_reg[228] = 32'hf9dff0ef;                                \
mem_reg[229] = 32'h02051a63;                                \
mem_reg[230] = 32'h00000993;                                \
mem_reg[231] = 32'h00000a17;                                \
mem_reg[232] = 32'h464a0a13;                                \
mem_reg[233] = 32'h02c0006f;                                \
mem_reg[234] = 32'h80000537;                                \
mem_reg[235] = 32'h128000ef;                                \
mem_reg[236] = 32'h00b009b3;                                \
mem_reg[237] = 32'h01c0006f;                                \
mem_reg[238] = 32'h000a00e7;                                \
mem_reg[239] = 32'h0140006f;                                \
mem_reg[240] = 32'hcf5ff0ef;                                \
mem_reg[241] = 32'h00c0006f;                                \
mem_reg[242] = 32'hdc5ff0ef;                                \
mem_reg[243] = 32'h0040006f;                                \
mem_reg[244] = 32'h00000513;                                \
mem_reg[245] = 32'h00012083;                                \
mem_reg[246] = 32'h00410113;                                \
mem_reg[247] = 32'h00008067;                                \
mem_reg[248] = 32'h00000913;                                \
mem_reg[249] = 32'h00000993;                                \
mem_reg[250] = 32'h00000a17;                                \
mem_reg[251] = 32'h418a0a13;                                \
mem_reg[252] = 32'h00000a93;                                \
mem_reg[253] = 32'h00000b13;                                \
mem_reg[254] = 32'h00000893;                                \
mem_reg[255] = 32'h00008067;                                \
mem_reg[256] = 32'hffc10113;                                \
mem_reg[257] = 32'h00112023;                                \
mem_reg[258] = 32'hffc10113;                                \
mem_reg[259] = 32'h01212023;                                \
mem_reg[260] = 32'h00a00933;                                \
mem_reg[261] = 32'h00000593;                                \
mem_reg[262] = 32'h024000ef;                                \
mem_reg[263] = 32'h01200533;                                \
mem_reg[264] = 32'h00100593;                                \
mem_reg[265] = 32'h018000ef;                                \
mem_reg[266] = 32'h00012903;                                \
mem_reg[267] = 32'h00410113;                                \
mem_reg[268] = 32'h00012083;                                \
mem_reg[269] = 32'h00410113;                                \
mem_reg[270] = 32'h00008067;                                \
mem_reg[271] = 32'hffc10113;                                \
mem_reg[272] = 32'h00112023;                                \
mem_reg[273] = 32'hffc10113;                                \
mem_reg[274] = 32'h01212023;                                \
mem_reg[275] = 32'hffc10113;                                \
mem_reg[276] = 32'h01312023;                                \
mem_reg[277] = 32'h00a00933;                                \
mem_reg[278] = 32'h00b009b3;                                \
mem_reg[279] = 32'h01200533;                                \
mem_reg[280] = 32'h013005b3;                                \
mem_reg[281] = 32'h0ec000ef;                                \
mem_reg[282] = 32'h0015f593;                                \
mem_reg[283] = 32'hff3598e3;                                \
mem_reg[284] = 32'h00012983;                                \
mem_reg[285] = 32'h00410113;                                \
mem_reg[286] = 32'h00012903;                                \
mem_reg[287] = 32'h00410113;                                \
mem_reg[288] = 32'h00012083;                                \
mem_reg[289] = 32'h00410113;                                \
mem_reg[290] = 32'h00008067;                                \
mem_reg[291] = 32'hffc10113;                                \
mem_reg[292] = 32'h00112023;                                \
mem_reg[293] = 32'hffc10113;                                \
mem_reg[294] = 32'h01212023;                                \
mem_reg[295] = 32'h00a00933;                                \
mem_reg[296] = 32'h0c0000ef;                                \
mem_reg[297] = 32'h01200533;                                \
mem_reg[298] = 32'h00400593;                                \
mem_reg[299] = 32'h0bc000ef;                                \
mem_reg[300] = 32'h01200533;                                \
mem_reg[301] = 32'h0a4000ef;                                \
mem_reg[302] = 32'h0025f593;                                \
mem_reg[303] = 32'hfe059ae3;                                \
mem_reg[304] = 32'h00012903;                                \
mem_reg[305] = 32'h00410113;                                \
mem_reg[306] = 32'h00012083;                                \
mem_reg[307] = 32'h00410113;                                \
mem_reg[308] = 32'h00008067;                                \
mem_reg[309] = 32'hffc10113;                                \
mem_reg[310] = 32'h00112023;                                \
mem_reg[311] = 32'hffc10113;                                \
mem_reg[312] = 32'h01212023;                                \
mem_reg[313] = 32'h00a00933;                                \
mem_reg[314] = 32'h00000593;                                \
mem_reg[315] = 32'hfa1ff0ef;                                \
mem_reg[316] = 32'h01200533;                                \
mem_reg[317] = 32'h064000ef;                                \
mem_reg[318] = 32'h0015f593;                                \
mem_reg[319] = 32'h00058a63;                                \
mem_reg[320] = 32'h01200533;                                \
mem_reg[321] = 32'h04c000ef;                                \
mem_reg[322] = 32'h00000513;                                \
mem_reg[323] = 32'h0080006f;                                \
mem_reg[324] = 32'h00100513;                                \
mem_reg[325] = 32'h00012903;                                \
mem_reg[326] = 32'h00410113;                                \
mem_reg[327] = 32'h00012083;                                \
mem_reg[328] = 32'h00410113;                                \
mem_reg[329] = 32'h00008067;                                \
mem_reg[330] = 32'hffc10113;                                \
mem_reg[331] = 32'h00112023;                                \
mem_reg[332] = 32'h020000ef;                                \
mem_reg[333] = 32'h00012083;                                \
mem_reg[334] = 32'h00410113;                                \
mem_reg[335] = 32'h00008067;                                \
mem_reg[336] = 32'h00000000;                                \
mem_reg[337] = 32'h00000000;                                \
mem_reg[338] = 32'h00000000;                                \
mem_reg[339] = 32'h00000000;                                \
mem_reg[340] = 32'h00052583;                                \
mem_reg[341] = 32'h00008067;                                \
mem_reg[342] = 32'h00452583;                                \
mem_reg[343] = 32'h00008067;                                \
mem_reg[344] = 32'h00b52023;                                \
mem_reg[345] = 32'h00008067;                                \
mem_reg[346] = 32'h00b52223;                                \
mem_reg[347] = 32'h00008067;                                \
mem_reg[348] = 32'h00000000;                                

`endif // RISCV_MULTI_ALL_INSTR_MEM_MAP_SVH
