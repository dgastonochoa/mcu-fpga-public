`timescale 10ps/1ps

`include "test_utils.svh"

`ifndef VCD
    `define VCD "mem_map_spi_tb.vcd"
`endif

module mem_map_spi_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    reg [31:0] m_addr, m_wd;
    reg m_we;

    wire [31:0] dec_m_addr;
    wire [7:0] io_addr;
    wire [3:0] io_en, io_we, rd_src;
    wire dec_m_we;

    mem_map_io_dec mmid(
        m_addr,
        m_we,
        dec_m_addr,
        dec_m_we,
        io_en,
        io_we,
        io_addr,
        rd_src
    );


    wire spi_rdy, spi_busy, spi_en, miso, mosi, ss, sck;
    wire [7:0] spi_rd, spi_wd;

    spi_master spim(
        miso, spi_wd, mosi, ss, spi_rd, spi_rdy, spi_busy, sck, spi_en, rst, clk);


    reg [7:0] s_wd = 8'haa;
    wire s_busy, s_rdy;
    wire [7:0] s_rd;

    spi_slave spis(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, rst, sck, clk);


    wire [31:0] rd;

    mem_map_spi dut(
        io_en[0],
        io_we[0],
        m_wd,
        io_addr,
        rd,

        spi_rdy,
        spi_busy,
        spi_rd,
        spi_en,
        spi_wd,

        clk,
        rst
    );

    integer i = 0;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_map_spi_tb);

        #1  rst = 1;
            m_addr = 0;
            m_wd = 0;
            m_we = 0;
        #1  rst = 0;
            assert(rd === 32'h00);

        // Read SPI ctrl reg
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000004;
                           #1 assert(rd === 32'h00);

        //
        // SPI transaction
        //
        // Verify the SPI slave has nothing
        assert(s_rdy === 1'b0);
        assert(s_rd === 8'h00);

        // Write data to be sent
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000000;
                           m_we = 1;
                           m_wd = 32'hc001c0de;

        // Trigger send
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000004;
                           m_we = 1;
                           m_wd = 32'b100;
        `WAIT_CLKS(clk, 1) m_we = 0;


        // Veriy ctrl. reg. indicates busy but not ready
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000004;
                           m_we = 0;
                           m_wd = 32'h00;
                           #1 assert(rd === 32'b10);

        // Veriy ctrl. reg. indicates busy during the whole SPI transaction.
        // 8 bits * 4 pulses per sck edge * 2 edges per bit
        repeat (8 * 4 * 2) begin
            `WAIT_CLKS(clk, 1) assert(rd[1] === 1'b1);
        end

        // Wait some cycles more just in case and:
        // Verify the SPI slave received correctly the data although m_wd was
        // set to 0 in cycle next to the one in which it was set to c001c0de.
        `WAIT_CLKS(clk, 6) assert(s_rdy === 1'b1);
                           assert(s_rd === 8'hde);

        // Verify that after some clks. busy goes low again and rdy remains high
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000004;
                           m_we = 0;
                           #1 assert(rd[1] === 0);
                              assert(rd[0] === 1);

        // Verify that the SPI read value can be read by using the right addr.
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000000;
                           m_we = 0;
                           #1 assert(rd[7:0] === 8'haa);


        //
        // SPI write after read
        //
        // Change values and repeat the above
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000000;
                           m_we = 1;
                           m_wd = 32'hdeadbeef;
                           s_wd = 32'h55555555;

        // Trigger send
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000004;
                           m_we = 1;
                           m_wd = 32'b100;
        `WAIT_CLKS(clk, 1) m_we = 0;


        // Veriy ctrl. reg. indicates busy but not ready
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000004;
                           m_we = 0;
                           m_wd = 32'h00;
                           #1 assert(rd === 32'b10);

        // Veriy ctrl. reg. indicates busy during the whole SPI transaction.
        // 8 bits * 4 pulses per sck edge * 2 edges per bit
        repeat (8 * 4 * 2) begin
            `WAIT_CLKS(clk, 1) assert(rd[1] === 1'b1);
        end

        // Wait some cycles more just in case and:
        // Verify the SPI slave received correctly the data although m_wd was
        // set to 0 in cycle next to the one in which it was set to c001c0de.
        `WAIT_CLKS(clk, 6) assert(s_rdy === 1'b1);
                           assert(s_rd === 8'hef);

        // Verify that after some clks. busy goes low again and rdy remains high
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000004;
                           m_we = 0;
                           #1 assert(rd[1] === 0);
                              assert(rd[0] === 1);

        // Verify that the SPI read value can be read by using the right addr.
        `WAIT_CLKS(clk, 1) m_addr = 32'h80000000;
                           m_we = 0;
                           #1 assert(rd[7:0] === 8'h55);

        #32 $finish;
    end
endmodule
