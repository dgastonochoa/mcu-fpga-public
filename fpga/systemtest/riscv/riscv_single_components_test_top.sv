/**
 * Top module for the riscv_single_components_test test.
 *
 */
module riscv_single_components_test_top(
    input   wire        CLK100MHZ,
    input   wire [15:0] sw,
    output  wire [15:0] LED,
    input   wire        btnC
);

    wire rst;

    debounce_filter df(btnC, CLK100MHZ, rst);

    riscv_single_components_test dut(sw[3:0], LED, CLK100MHZ, rst);

endmodule
