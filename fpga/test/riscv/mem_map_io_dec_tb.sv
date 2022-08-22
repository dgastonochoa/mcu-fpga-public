`timescale 10ps/1ps

`ifndef VCD
    `define VCD "mem_map_spi_tb.vcd"
`endif

module mem_map_spi_tb;
    reg [31:0] m_addr;
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

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_map_spi_tb);

        m_addr = 0;
        m_we = 0;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'h0);
            assert(io_we === 4'h0);
            assert(io_addr === 8'h0);
            assert(rd_src === 4'h0);
        m_we = 1;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 1);
            assert(io_en === 4'h0);
            assert(io_we === 4'h0);
            assert(io_addr === 8'h0);
            assert(rd_src === 4'h0);


        m_addr = 32'h04;
        m_we = 0;
        #1  assert(dec_m_addr === 32'h04);
            assert(dec_m_we === 0);
            assert(io_en === 4'h0);
            assert(io_we === 4'h0);
            assert(io_addr === 8'h0);
            assert(rd_src === 4'h0);
        m_we = 1;
        #1  assert(dec_m_addr === 32'h04);
            assert(dec_m_we === 1);
            assert(io_en === 4'h0);
            assert(io_we === 4'h0);
            assert(io_addr === 8'h0);
            assert(rd_src === 4'h0);


        m_addr = 32'h80000000 - 4;
        m_we = 0;
        #1  assert(dec_m_addr === (32'h80000000 - 4));
            assert(dec_m_we === 0);
            assert(io_en === 4'h0);
            assert(io_we === 4'h0);
            assert(io_addr === 8'h0);
            assert(rd_src === 4'h0);
        m_we = 1;
        #1  assert(dec_m_addr === (32'h80000000 - 4));
            assert(dec_m_we === 1);
            assert(io_en === 4'h0);
            assert(io_we === 4'h0);
            assert(io_addr === 8'h0);
            assert(rd_src === 4'h0);


        m_addr = 32'h80000000;
        m_we = 0;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'b0001);
            assert(io_we === 4'h0);
            assert(io_addr === 8'h0);
            assert(rd_src === 4'd1);
        m_we = 1;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'b0001);
            assert(io_we === 4'h1);
            assert(io_addr === 8'h0);
            assert(rd_src === 4'd1);


        m_addr = 32'h80000004;
        m_we = 0;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'b0001);
            assert(io_we === 4'h0);
            assert(io_addr === 8'h4);
            assert(rd_src === 4'd1);
        m_we = 1;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'b0001);
            assert(io_we === 4'h1);
            assert(io_addr === 8'h4);
            assert(rd_src === 4'd1);


        m_addr = 32'h80000000 + 60;
        m_we = 0;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'b0001);
            assert(io_we === 4'h0);
            assert(io_addr === 8'd60);
            assert(rd_src === 4'd1);
        m_we = 1;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'b0001);
            assert(io_we === 4'h1);
            assert(io_addr === 8'd60);
            assert(rd_src === 4'd1);


        m_addr = 32'h80000000 + 64;
        m_we = 0;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'b0010);
            assert(io_we === 4'h0);
            assert(io_addr === 8'd64);
            assert(rd_src === 4'd2);
        m_we = 1;
        #1  assert(dec_m_addr === 32'h00);
            assert(dec_m_we === 0);
            assert(io_en === 4'b0010);
            assert(io_we === 4'b0010);
            assert(io_addr === 8'd64);
            assert(rd_src === 4'd2);

        #10 $finish;
    end
endmodule
