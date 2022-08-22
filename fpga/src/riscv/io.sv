module rd_src_dec(
    input   wire    [3:0] io_en,
    output  logic   [3:0] rd_src
);
    // TODO reduce this to 4
    always_comb begin
        case (io_en)
        4'b0000: rd_src = 4'd0;
        4'b0001: rd_src = 4'd1;
        4'b0010: rd_src = 4'd2;
        4'b0100: rd_src = 4'd3;
        4'b1000: rd_src = 4'd4;
        default: rd_src = 4'hf;
        endcase
    end
endmodule

/**
 * Memory-mapped I/O decoder.
 *
 * addr > 0x80000000: memory
 * others: I/O
 *
 * Each I/O has 16 registers of 32 bits. Therefore each one has offsets
 * 0x00..0x40.
 *
 * I/O 0: 0x80000000
 *        0x80000004
 *        ...
 *        0x8000003c
 *
 * I/O 1: 0x80000040
 *        0x80000044
 *        ...
 *        0x8000007c
 * ...
 *
 */
module mem_map_io_dec(
    input  wire [31:0] m_addr,
    input  wire        m_we,

    output wire [31:0] dec_m_addr,
    output wire        dec_m_we,

    output wire [3:0]  io_en,
    output wire [3:0]  io_we,
    output wire [7:0]  io_addr,
    output wire [3:0]  rd_src
);
    wire is_io;

    // m_addr[31] == 1'b1 --> m_addr >= 0x80000000
    // m_addr[30:8] == 23'h00 --> having the above, this means
    // m_addr < 0x80000100.
    assign is_io = (m_addr[31] == 1'b1) && (m_addr[30:8] == 23'h00);

    assign io_addr = m_addr[7:0] & {8{is_io}};


    wire [3:0] io_en_aux;

    dec d(io_addr[7:6], io_en_aux);

    assign io_en = io_en_aux & {4{is_io}};


    assign io_we = io_en & {4{m_we}} & {4{is_io}};

    rd_src_dec c83(io_en, rd_src);

    assign dec_m_addr = m_addr & {32{~is_io}};
    assign dec_m_we = m_we & (~is_io);
endmodule

module mem_map_spi(
    input  wire         en,
    input  wire         we,
    input  wire  [31:0] wd,
    input  wire  [7:0]  addr,
    output logic [31:0] rd,

    input  wire         spi_rdy,
    input  wire         spi_busy,
    input  wire  [7:0]  spi_rd,
    output wire         spi_en,
    output wire  [7:0]  spi_wd,

    input  wire        clk,
    input  wire        rst
);
    dff #(.N(8)) wd_dff(wd[7:0], addr == 8'b0 && (we & en), spi_wd, clk, rst);

    assign spi_en = en & we & wd[2] & (addr == 8'h04);

    always_comb begin
        case (addr)
        8'h00:   rd = {24'b0, spi_rd};
        8'h04:   rd = {30'b0, spi_busy, spi_rdy};
        default: rd = 32'hff;
        endcase
    end
endmodule
