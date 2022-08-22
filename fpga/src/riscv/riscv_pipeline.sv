`include "errno.svh"
`include "mem.svh"
`include "synth.svh"

/**
 * RISC-V top module. Connects the RISC-V CPU with external
 * memories.
 *
 * @param reg_we For debugging purposes. Register write-enable.
 * @param mem_we For debugging purposes. Memory write-enable.
 * @param imm_src For debugging purposes. @see{datapath.svh}
 * @param alu_op For debugging purposes. @see{datapath.svh}
 * @param alu_src For debugging purposes. @see{datapath.svh}
 * @param res_src For debugging purposes. @see{datapath.svh}
 * @param pc_src For debugging purposes. @see{datapath.svh}
 * @param instr For debugging purposes. Instruction being processed.
 * @param alu_out For debugging purposes. ALU result.
 * @param m_rd For debugging purposes. Data read from mem. (if any)
 * @param m_wd For debugging purposes. Data written to mem. (if any)
 * @param pc For debugging purposes. Program counter.
 *
 * @param tm Test-mode signal. Enables test mode, which disconnects the data
 *           memory from the CPU and connects it to the other test-mode signals,
 *           so it can be accessed from outside.
 *
 * @param tm_d_addr Test-mode signal. Data memory address.
 * @param tm_d_wd Test-mode signal. Data memory data to write (if any).
 * @param tm_d_we Test-mode signal. Data memory write enable.
 * @param tm_d_dt Test-mode signal. Data memory data type (to be read/write).
 * @param tm_d_rd Test-mode signal. Data memory data to read (if any).
 * @param tm_d_err Test-mode signal. Data memory error.
 *
 * @param rst Reset.
 * @param clk Clock.
 */
module riscv #(parameter DEFAULT_INSTR = 0, parameter SPI_SCK_WIDTH_CLKS = 4) (
    // Signals exposed for debugging purposes
    output  wire        reg_we,
    output  wire        mem_we,
    output  imm_src_e   imm_src,
    output  alu_op_e    alu_op,
    output  alu_src_e   alu_src,
    output  res_src_e   res_src,
    output  pc_src_e    pc_src,
    output  wire [31:0] instr,
    output  wire [31:0] m_addr,
    output  wire [31:0] m_rd,
    output  wire [31:0] m_wd,
    output  wire [31:0] pc,
    ///////

    output  wire        mosi,
    output  wire        miso,
    output  wire        ss,
    output  wire        sck,

    input   wire        rst,
    input   wire        clk
);
    alu_src_e alu_src_a, alu_src_b;
    wire [3:0] alu_flags;
    wire rwe_m, rwe_w;
    mem_dt_e dt;

    wire stall, flush;
    wire [31:0] i_d, i_e, i_m, i_w;
    res_src_e rs_e;
    pc_src_e pcs_e;
    fw_type_e fw_rd2;
    fw_type_e fw_rd1;

    hazard_ctrl hc(
        i_d[`A1],
        i_d[`A2],
        i_e[`A1],
        i_e[`A2],
        i_e[`A3],
        i_m[`A3],
        i_w[`A3],
        rwe_m,
        rwe_w,
        rs_e,
        pcs_e,
        fw_rd1,
        fw_rd2,
        stall,
        flush
    );

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
        stall,
        flush,
        fw_rd1,
        fw_rd2,
        pc,
        m_addr,
        alu_flags,
        m_wd,
        i_d,
        i_e,
        i_m,
        i_w,
        rwe_m,
        rwe_w,
        rs_e,
        pcs_e,
        rst,
        clk
    );

    controller co(
        instr,
        alu_flags,
        reg_we,
        mem_we,
        alu_src_a,
        alu_src_b,
        res_src,
        pc_src,
        imm_src,
        alu_op,
        dt
    );

    mem_dt_e dt_m;
    wire m_we_m;

    mem_pipeline mdp(flush, stall, dt, mem_we, dt_m, m_we_m, clk, rst);

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


    wire [31:0] m_data_rd;
    errno_e m_err;

    mem #(.N(128)) data_mem(
        dec_m_addr, m_wd, dec_m_we, dt_m, m_data_rd, m_err, clk);


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

    mux4to1 m41(m_data_rd, si_rd, 32'h00, 32'h00, rd_src[1:0], m_rd);


    //
    // Instruction memory logic
    //
    mem_dt_e dt_instr;
    errno_e err_instr;

    assign dt_instr = MEM_DT_WORD;

    mem #(.N(512), .INIT_VALS(DEFAULT_INSTR)) instr_mem(
        pc, 32'b00, 1'b0, dt_instr, instr, err_instr, clk);
endmodule

/**
 * RISC-V top module. Connects the RISC-V CPU with external
 * memories.
 */
module riscv_legacy(
    // Signals exposed for debugging purposes
    output  wire        reg_we,
    output  wire        mem_we,
    output  imm_src_e   imm_src,
    output  alu_op_e    alu_op,
    output  alu_src_e   alu_src,
    output  res_src_e   res_src,
    output  pc_src_e    pc_src,
    output  wire [31:0] instr,
    output  wire [31:0] alu_out,
    output  wire [31:0] m_rd,
    output  wire [31:0] m_wd,
    output  wire [31:0] pc,
    ///////

    input   wire        rst,
    input   wire        clk
);
    wire mosi;
    wire miso;
    wire ss;
    wire sck;

    riscv rv(
        reg_we,
        mem_we,
        imm_src,
        alu_op,
        alu_src,
        res_src,
        pc_src,
        instr,
        alu_out,
        m_rd,
        m_wd,
        pc,
        mosi,
        miso,
        ss,
        sck,
        rst,
        clk
    );
endmodule
