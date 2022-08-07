`ifndef RISCV_ALL_INSTR_PHYSICAL_FPGA_TEST_SVH
`define RISCV_ALL_INSTR_PHYSICAL_FPGA_TEST_SVH

`ifdef IVERILOG
    `define CLK_PWIDTH 32'd1
    `define DEBOUNCE_FILTER_WAIT_CLK 1
`else
    /**
     * Main clock width in pulses of the fpga input clock (CLK100MHZ)
     *
     * 100e6 / 1e3 = 100 kHz; 1e3 / 2 = 5e2 -> pulse width = 5e2
     */
    `define CLK_PWIDTH 32'd500

    /**
     * Cycle to wait by the debounce filter.
     *
     */
    `define DEBOUNCE_FILTER_WAIT_CLK 100
`endif

`ifdef CONFIG_RISCV_MULTICYCLE
    /**
     * Address of the first data written in memory. It is expected to be loaded
     * in the 'sp' register (x2) by the test-program's first instruction. The
     * test program is expected to write all data using this register as base.
     *
     * Note: in RISC-V multicycle, the data and instruction memory is the same
     * memory, therefore this address must not be 0 for multicycle RISC-V.
     *
     */
    `define DATA_START_ADDR 32'd1728

    /**
     * Address of the last data written in memory.
     *
     */
    `define DATA_END_ADDR (32'h1f8 + `DATA_START_ADDR)

`else
    `define DATA_START_ADDR  32'd00
    `define DATA_END_ADDR    32'h1f8
`endif // CONFIG_RISCV_MULTICYCLE

`ifdef CONFIG_RISCV_PIPELINE
    `define FINISH_SIGNAL after_20
`else
    `define FINISH_SIGNAL pr_finished
`endif // CONFIG_RISCV_PIPELINE

`endif // RISCV_ALL_INSTR_PHYSICAL_FPGA_TEST_SVH