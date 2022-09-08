`include "errno.svh"
`include "mem.svh"
`include "synth.svh"

module cpu(
    input  wire     [31:0]  instr,
    input  wire     [31:0]  m_rd,

    output wire     [31:0]  m_addr,
    output wire             m_we,
    output wire     [31:0]  m_wd,
    output mem_dt_e         m_dt,
    output          [31:0]  pc,

    input  wire             rst,
    input  wire             clk
);
    wire        reg_we;
    imm_src_e   imm_src;
    alu_op_e    alu_op;
    alu_src_e   alu_src;
    res_src_e   res_src;
    pc_src_e    pc_src;

    alu_src_e alu_src_a, alu_src_b;
    wire [3:0] alu_flags;

    datapath dp(
        instr,
        m_rd,
        reg_we,
        imm_src,
        alu_op,
        alu_src_a,
        alu_src_b,
        res_src,
        pc_src,
        pc,
        m_addr,
        alu_flags,
        m_wd,
        rst,
        clk
    );

    controller co(
        instr,
        alu_flags,
        reg_we,
        m_we,
        alu_src_a,
        alu_src_b,
        res_src,
        pc_src,
        imm_src,
        alu_op,
        m_dt
    );
endmodule

module cpu_mem #(parameter D_SIZE = 256,
                 parameter I_SIZE = 512,
                 parameter INIT_VALS = 0) (
    input  wire     [31:0]  pc,
    input  wire     [31:0]  d_addr,
    input  wire     [31:0]  d_wd,
    input  wire             d_we,
    input  mem_dt_e         d_dt,

    output wire     [31:0]  instr,
    output wire     [31:0]  d_rd,
    output errno_e          err,

    input  wire             clk
);
    mem #(.N(D_SIZE)) dm(
        d_addr, d_wd, d_we, d_dt, d_rd, err, clk);


    mem_dt_e dt_instr;
    errno_e err_instr;

    assign dt_instr = MEM_DT_WORD;

    mem #(.N(I_SIZE), .INIT_VALS(INIT_VALS)) im(
        pc, 32'b00, 1'b0, dt_instr, instr, err_instr, clk);
endmodule

module mcu #(parameter DEFAULT_INSTR = 0, parameter SPI_SCK_WIDTH_CLKS = 4) (
    output  wire        mosi,
    output  wire        miso,
    output  wire        ss,
    output  wire        sck,

    output  wire [15:0] leds,

    input   wire        rst,
    input   wire        clk
);
    wire [31:0] instr, m_rd, m_addr, m_wd, pc;
    wire m_we_m;
    mem_dt_e dt_m;

    cpu c(
        instr,
        m_rd,
        m_addr,
        m_we_m,
        m_wd,
        dt_m,
        pc,
        rst,
        clk
    );


    wire [31:0] dec_m_addr;
    wire [7:0] io_addr;
    wire [3:0] io_en, io_we, rd_src;
    wire dec_m_we;

    mem_map_io_dec mmid(
        m_addr,
        m_we_m,
        dec_m_addr,
        dec_m_we,
        io_en,
        io_we,
        io_addr,
        rd_src
    );


    wire     [31:0]  m_data_rd;
    errno_e          m_err;

    cpu_mem #(.INIT_VALS(DEFAULT_INSTR)) cm(
        pc,
        dec_m_addr,
        m_wd,
        dec_m_we,
        dt_m,
        instr,
        m_data_rd,
        m_err,
        clk
    );


    wire spi_rdy, spi_busy, spi_en;
    wire [7:0] spi_rd, spi_wd;

    spi_master #(.SCK_WIDTH_CLKS(SPI_SCK_WIDTH_CLKS)) spim(
        miso, spi_wd, mosi, ss, spi_rd, spi_rdy, spi_busy, sck, spi_en, rst, clk);


    wire [31:0] si_rd;

    mem_map_spi mms(
        io_en[0],
        io_we[0],
        m_wd,
        io_addr,
        si_rd,

        spi_rdy,
        spi_busy,
        spi_rd,
        spi_en,
        spi_wd,

        clk,
        rst
    );


    wire [31:0] led_rd;

    mem_map_led mml(
        io_en[1],
        io_we[1],
        m_wd,
        io_addr,
        led_rd,
        leds,
        clk,
        rst
    );

    mux4to1 m41(m_data_rd, si_rd, led_rd, 32'h00, rd_src[1:0], m_rd);
endmodule
