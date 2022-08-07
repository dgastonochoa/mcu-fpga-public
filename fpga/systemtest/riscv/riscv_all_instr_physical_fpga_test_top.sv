`include "alu.svh"
`include "mem.svh"
`include "errno.svh"
`include "riscv/datapath.svh"

`include "riscv_all_instr_physical_fpga_test.svh"

module mem_send_ctrl #(parameter START_ADDR = 0, parameter END_ADDR = 12) (
    input   wire         si_busy,
    output  logic [31:0] tm_d_addr,
    output  logic        tm,
    output  logic        si_en,
    input   wire         clk,
    input   wire         rst
);
    typedef enum reg [2:0]
    {
        IDLE,
        SEND_WORD,
        WAIT_BUSY,
        WAIT_WORD,
        FINISHED
    } state_e;

    state_e cs;
    reg [31:0] addr_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cs <= IDLE;
            addr_reg <= START_ADDR;
        end else begin
            case (cs)
            IDLE:      cs <= SEND_WORD;
            SEND_WORD: cs <= WAIT_BUSY;
            WAIT_BUSY: cs <= si_busy == 1'b1 ? WAIT_WORD : WAIT_BUSY;

            WAIT_WORD: begin
                if (si_busy == 1'b0) begin
                    cs <= addr_reg == END_ADDR ? FINISHED : SEND_WORD;
                    addr_reg <= addr_reg == END_ADDR ? 0 : addr_reg + 4;
                end
            end
            endcase
        end
    end


    always_comb begin
        case (cs)
        IDLE:      {si_en, tm_d_addr, tm} = 34'h00;
        SEND_WORD: {si_en, tm_d_addr, tm} = {1'b1, addr_reg, 1'b1};
        WAIT_BUSY: {si_en, tm_d_addr, tm} = {1'b1, addr_reg, 1'b1};
        WAIT_WORD: {si_en, tm_d_addr, tm} = {1'b0, addr_reg, 1'b1};
        FINISHED:  {si_en, tm_d_addr, tm} = 34'h00;
        default:   {si_en, tm_d_addr, tm} = 34'h00;
        endcase
    end
endmodule

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
    imm_src_e   imm_src;
    alu_op_e    alu_op;
    alu_src_e   alu_src;
    res_src_e   res_src;
    pc_src_e    pc_src;
    wire        reg_we, mem_we;
    wire [31:0] instr, alu_out, mem_rd_data, mem_wd_data, pc;

    wire        tm;
    reg  [31:0] tm_d_addr;
    wire [31:0] tm_d_wd;
    wire        tm_d_we;
    mem_dt_e    tm_d_dt;
    wire [31:0] tm_d_rd;
    errno_e     tm_d_err;

    assign tm_d_we = 1'b0;
    assign tm_d_wd = 32'h00;
    assign tm_d_dt = MEM_DT_WORD;

    riscv #(.DEFAULT_INSTR(1)) rv(
        reg_we,
        mem_we,
        imm_src,
        alu_op,
        alu_src,
        res_src,
        pc_src,
        instr,
        alu_out,
        mem_rd_data,
        mem_wd_data,
        pc,

        tm,
        tm_d_addr,
        tm_d_wd,
        tm_d_we,
        tm_d_dt,
        tm_d_rd,
        tm_d_err,

        rst,
        clk_1khz
    );


`ifdef CONFIG_RISCV_MULTICYCLE
    localparam LAST_PC = 32'h684;
`else
    localparam LAST_PC = 32'h680;
`endif

    reg pr_finished;

    always @(posedge clk_1khz, posedge rst) begin
        if (rst)
            pr_finished <= 1'b0;
        else if (pc == LAST_PC && pr_finished == 1'b0)
            pr_finished <= 1'b1;
    end

`ifdef CONFIG_RISCV_PIPELINE
    reg [7:0] cnt;
    wire after_20;

    always @(posedge clk_1khz, posedge rst) begin
        if (rst)
            cnt <= 8'h00;
        else if (pr_finished == 1'b1)
            cnt <= (cnt == 8'd20 ? cnt : cnt + 1);
    end

    assign after_20 = cnt == 8'd20;
    assign LED[0] = after_20;
    assign LED[1] = pr_finished;

`else
    assign LED[0] = pr_finished;

`endif // CONFIG_RISCV_PIPELINE


    //
    // Memory send controller
    //
    wire si_busy;
    wire si_en;

    mem_send_ctrl #(.START_ADDR(`DATA_START_ADDR),
                    .END_ADDR(`DATA_END_ADDR)) msc(
        si_busy, tm_d_addr, tm, si_en, clk_1khz, ~`FINISH_SIGNAL);


    //
    // SPI master w
    //
    // pulse_width = 5 -> period = 10 -> 100 kHz / 10 = 10 kHz.
    localparam SCK_PULSE_WIDTH = 5;

    wire mosi, miso, ss, sck;

    spi_master_w #(.SCK_WIDTH_CLKS(SCK_PULSE_WIDTH)) smw(
        mosi, miso, ss, sck, tm_d_rd, si_en, si_busy, clk_1khz, rst | ~tm);

    assign JA[3] = mosi;
    assign JA[2] = miso;
    assign JA[1] = ss;
    assign JA[0] = sck;
endmodule
