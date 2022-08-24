`include "alu.svh"
`include "mem.svh"
`include "errno.svh"
`include "riscv/datapath.svh"

`include "riscv_all_instr_physical_fpga_test.svh"

module riscv_single_all_instr_top(
    input   wire        btnC,
    output  wire [15:0] LED,
    output  wire [7:0]  JA,
    input   wire        CLK100MHZ
);
    wire rst;

    debounce_filter #(.WAIT_CLK(`DEBOUNCE_FILTER_WAIT_CLK)) df(
        btnC, CLK100MHZ, rst);


    //
    // Clock generation
    //
    wire clk_1khz;

    clk_div #(.POL(1'd0), .PWIDTH(`CLK_PWIDTH)) cd(clk_1khz, CLK100MHZ, rst);


    //
    // RISC-V CPU
    //
    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;
    wire [31:0] pc, m_addr, wdata;
    wire [31:0] instr, mem_rd_data, m_wd;
    wire mosi, miso, ss, sck;

    riscv #(.DEFAULT_INSTR(1)) rv(
        reg_we,
        mem_we,
        imm_src,
        alu_ctrl,
        alu_src,
        res_src, pc_src,
        instr,
        m_addr,
        mem_rd_data,
        m_wd,
        pc,

        mosi,
        miso,
        ss,
        sck,

        LED,

        rst,
        clk_1khz
    );

    assign JA[3] = mosi;
    assign JA[2] = miso;
    assign JA[1] = ss;
    assign JA[0] = sck;
endmodule
