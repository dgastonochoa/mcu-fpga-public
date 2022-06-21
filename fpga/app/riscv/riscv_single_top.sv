// TODO declare inputs/outputs as in normal source files
module risc_single_top(
    input   wire        CLK100MHZ,
    input   wire [15:0] sw,
    output  wire [15:0] LED,
    input   wire        btnC
);

    wire rst;

    debounce_filter df(btnC, CLK100MHZ, rst);

    riscv_single dut(sw[3:0], LED, CLK100MHZ, rst);

endmodule
