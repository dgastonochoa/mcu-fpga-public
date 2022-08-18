`ifndef TEST_UTILS_SVH
`define TEST_UTILS_SVH

/**
 * Waits for 'n' clock cycles.
 *
 */
`define WAIT_CLKS(clk, n)           repeat(n) @(posedge clk); #1

`endif // TEST_UTILS_SVH
