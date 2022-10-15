`ifndef RISCV_ALL_INSTR_PHYSICAL_FPGA_TEST_SVH
`define RISCV_ALL_INSTR_PHYSICAL_FPGA_TEST_SVH

`ifdef IVERILOG
    `define CLK_PWIDTH 32'd1
    `define DEBOUNCE_FILTER_WAIT_CLK 1
    `define SPI_SCK_PWIDTH 4
`else
    `ifdef CONFIG_RISCV_SINGLECYCLE
        /**
         * Main clock width in pulses of the fpga input clock (CLK100MHZ)
         *
         * 2 * 2 = 4; 100e6 / 4 = 25 MHz
         */
        `define CLK_PWIDTH 2

        /**
         * 780 * 2 = 1560; 25 MHz / 1560 ~ 16 kHz
         *
         * Note: the SPI reader curently prints the data as it reads through a
         * UART, which works at 115200 bps. It seems that the SPI data rate
         * needs to be way lower than that for the UART to work.
         *
         */
        `define SPI_SCK_PWIDTH 780

        /**
         * Cycle to wait by the debounce filter.
         *
         */
        `define DEBOUNCE_FILTER_WAIT_CLK 100
    `elsif CONFIG_RISCV_MULTICYCLE
        /**
         * Main clock width in pulses of the fpga input clock (CLK100MHZ)
         *
         * 1 * 2 = 2; 100e6 / 2 = 50 MHz
         */
        `define CLK_PWIDTH 1

        /**
         * 1560 * 2 = 3120; 50 MHz / 3120 ~ 16 kHz
         *
         * Note: the SPI reader curently prints the data as it reads through a
         * UART, which works at 115200 bps. It seems that the SPI data rate
         * needs to be way lower than that for the UART to work.
         *
         */
        `define SPI_SCK_PWIDTH 1560

        /**
         * Cycle to wait by the debounce filter.
         *
         */
        `define DEBOUNCE_FILTER_WAIT_CLK 100
    `elsif CONFIG_RISCV_PIPELINE
        /**
         * Main clock width in pulses of the fpga input clock (CLK100MHZ)
         *
         * 2 * 2 = 4; 100e6 / 4 = 25 MHz
         */
        `define CLK_PWIDTH 2

        /**
         * 780 * 2 = 1560; 25 MHz / 1560 ~ 16 kHz
         *
         * Note: the SPI reader curently prints the data as it reads through a
         * UART, which works at 115200 bps. It seems that the SPI data rate
         * needs to be way lower than that for the UART to work.
         *
         */
        `define SPI_SCK_PWIDTH 780

        /**
         * Cycle to wait by the debounce filter.
         *
         */
        `define DEBOUNCE_FILTER_WAIT_CLK 100
    `endif
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