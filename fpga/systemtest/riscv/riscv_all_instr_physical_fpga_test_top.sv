`include "alu.svh"
`include "mem.svh"
`include "errno.svh"
`include "riscv/datapath.svh"

`include "riscv_all_instr_physical_fpga_test.svh"

module riscv_all_instr_physical_fpga_test_top(
    input   wire        btnC,
    input   wire [3:0]  JA1,
    input   wire [7:0]  JB,

    output  wire [15:0] LED,
    output  wire [3:0]  JA,

    input   wire        CLK100MHZ
);
    wire rst;
    debounce_filter #(.WAIT_CLK(`DEBOUNCE_FILTER_WAIT_CLK)) df(
        btnC, CLK100MHZ, rst);


    wire clk;
    clk_div #(.POL(1'd0), .PWIDTH(`CLK_PWIDTH)) cd(clk, CLK100MHZ, rst);


    wire [7:0] JB_db, JB_db_sync;
    debounce_filter #(.WAIT_CLK(`DEBOUNCE_FILTER_WAIT_CLK * 2)) df2 [7:0] (
        JB, CLK100MHZ, JB_db[7:0]);
    cell_sync_n #(.N(8)) csn(clk, rst, JB_db, JB_db_sync);


    wire mosi, miso, ss, sck;
    mcu #(.DEFAULT_INSTR(1), .SPI_SCK_WIDTH_CLKS(`SPI_SCK_PWIDTH)) m(
        mosi, miso, ss, sck, JB_db_sync, LED, rst, clk);


    assign miso  = JA1[0];
    assign JA[3] = mosi;
    assign JA[1] = ss;
    assign JA[0] = sck;
endmodule
