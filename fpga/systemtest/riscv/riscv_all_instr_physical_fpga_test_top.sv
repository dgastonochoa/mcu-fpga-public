`include "alu.svh"
`include "mem.svh"
`include "errno.svh"
`include "riscv/datapath.svh"

`include "riscv_all_instr_physical_fpga_test.svh"

module riscv_all_instr_physical_fpga_test_top(
    input   wire        btnC,
    output  wire [15:0] LED,
    output  wire [7:0]  JA,
    input   wire        CLK100MHZ
);
    wire rst;

    debounce_filter #(.WAIT_CLK(`DEBOUNCE_FILTER_WAIT_CLK)) df(
        btnC, CLK100MHZ, rst);


    //
    // Clock generation
    //
    wire clk_1khz;

    clk_div #(.POL(1'd0), .PWIDTH(`CLK_PWIDTH)) cd(clk_1khz, CLK100MHZ, rst);


    //
    // RISC-V MCU
    //
    wire mosi, miso, ss, sck;

    mcu #(.DEFAULT_INSTR(1)) m(mosi, miso, ss, sck, LED, rst, clk_1khz);

    assign JA[3] = mosi;
    assign JA[2] = miso;
    assign JA[1] = ss;
    assign JA[0] = sck;
endmodule
