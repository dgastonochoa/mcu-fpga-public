
module spi_slave(
    input   wire        mosi,
    input   wire        ss,
    input   wire [7:0]  wd,
    output  wire        miso,
    output  reg  [7:0]  rd,
    output  reg         rdy,
    output  wire        busy,
    input   wire        rst,
    input   wire        sck,
    input   wire        clk
);
    wire g_sck;

    assign g_sck = ss | sck;

    sipo_reg sr0(mosi, rd, rdy, rst, g_sck);
    piso_reg pr0(wd, miso, busy, rst, g_sck);
endmodule

module spi_master_ctrl(
    input   wire en,
    input   wire sck,
    output  reg  ss,
    output  reg  en_sck,
    input   wire rst,
    input   wire clk
);
    //
    // Counter logic
    //
    wire s;

    cnt16 c(s, sck, ~en_sck);


    //
    // Synchronize async. variables
    //
    wire en_sync, s_sync;

    cell_sync_n #(.N(2)) c_sync0(clk, rst, {en, s}, {en_sync, s_sync});


    //
    // Next state logic
    //
    typedef enum reg [1:0] {IDLE, SELECT, GEN_CLK} state_e;

    state_e cs;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cs <= IDLE;
        end else begin
            case (cs)
            IDLE:    cs <= (en_sync ? SELECT : IDLE);
            SELECT:  cs <= GEN_CLK;
            GEN_CLK: cs <= (s_sync ? IDLE : GEN_CLK);
            endcase
        end
    end


    //
    // Outputs logic
    //
    always_comb begin
        case (cs)
        IDLE:    {ss, en_sck} = {1'b1, 1'b0};
        SELECT:  {ss, en_sck} = {1'b0, 1'b0};
        GEN_CLK: {ss, en_sck} = {1'b0, 1'b1};
        endcase
    end
endmodule

module spi_master #(parameter SCK_WIDTH_CLKS = 8'd4) (
    input   wire        miso,
    input   wire [7:0]  wd,
    output  wire        mosi,
    output  wire        ss,
    output  wire [7:0]  rd,
    output  wire        rdy,
    output  wire        busy,
    output  wire        sck,
    input   wire        en,
    input   wire        rst,
    input   wire        clk
);
    //
    // Controller and clk. gen.
    //
    wire en_sck;

    spi_master_ctrl smc(en, sck, ss, en_sck, rst, clk);

    clk_div #(.POL(1'd1), .PWIDTH(SCK_WIDTH_CLKS)) cd(
        sck, clk, rst | ~en_sck);


    // TODO should busy and rdy be directly those in sipo and piso, or should
    // they be high/low as a function of ss. Possibly ss. In case of multi-slave,
    // there is no problem in not wiring it, master is still busy generating the
    // sck signal.

    // TODO data lines are left in the level of the last bit sent. To fix it,
    // (if required) do `mosi & en_sck` or `mosi | ss`.
    //

    //
    // Receiver
    //
    sipo_reg sr0(miso, rd, rdy, rst, sck);


    //
    // Sender
    //
    wire p_busy;

    piso_reg pr0(wd, mosi, p_busy, rst, sck);

    // TODO busy flag is not necessary, ss is enough
    assign busy = ~ss;
endmodule

/**
 * Wrapper module for @ref{spi_master} to send words instead of bytes. It drives
 * an SPI master device to send 1 word as 4 bytes in a row.
 *
 * @param mosi SPI mosi
 * @param miso SPI miso
 * @param ss SPI ss
 * @param sck SPI sck
 * @param wd Word to be sent
 * @param en_sync Enable.
 * @param clk
 * @param rst
 *
 * @todo @param{en_sync} is named that way to inidicate it must be synchronous
 * with respect to @param{clk}, but this is always assumed. Rename it to 'en'
 *
 */
module spi_master_w #(parameter SCK_WIDTH_CLKS = 4)(
    output wire        mosi,
    output wire        miso,
    output wire        ss,
    output wire        sck,

    input  wire [31:0] wd,
    input  wire        en_sync,
    output logic       busy,
    input  wire        clk,
    input  wire        rst
);
    typedef enum reg [3:0]
    {
        IDLE,
        B3_SEND,
        B3_WAIT,
        B2_SEND,
        B2_WAIT,
        B1_SEND,
        B1_WAIT,
        B0_SEND,
        B0_WAIT
    } state_e;

    state_e cs;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cs <= IDLE;
        end else begin
            case (cs)
            IDLE:       cs <= (en_sync ? B3_SEND : IDLE);
            B3_SEND:    cs <= (m_busy ? B3_WAIT : B3_SEND);
            B3_WAIT:    cs <= (m_busy ? B3_WAIT : B2_SEND);
            B2_SEND:    cs <= (m_busy ? B2_WAIT : B2_SEND);
            B2_WAIT:    cs <= (m_busy ? B2_WAIT : B1_SEND);
            B1_SEND:    cs <= (m_busy ? B1_WAIT : B1_SEND);
            B1_WAIT:    cs <= (m_busy ? B1_WAIT : B0_SEND);
            B0_SEND:    cs <= (m_busy ? B0_WAIT : B0_SEND);
            B0_WAIT:    cs <= (m_busy ? B0_WAIT : IDLE);
            endcase
        end
    end


    wire [7:0] wd3, wd2, wd1, wd0;
    logic [7:0] m_wd;
    logic m_en;

    assign wd3 = wd[31:24];
    assign wd2 = wd[23:16];
    assign wd1 = wd[15:8];
    assign wd0 = wd[7:0];

    always_comb begin
        case (cs)
        IDLE:    {m_wd, m_en, busy} = {8'h00, 1'b0, 1'b0};
        B3_SEND: {m_wd, m_en, busy} = {wd3,   1'b1, 1'b1};
        B3_WAIT: {m_wd, m_en, busy} = {wd3,   1'b0, 1'b1};
        B2_SEND: {m_wd, m_en, busy} = {wd2,   1'b1, 1'b1};
        B2_WAIT: {m_wd, m_en, busy} = {wd2,   1'b0, 1'b1};
        B1_SEND: {m_wd, m_en, busy} = {wd1,   1'b1, 1'b1};
        B1_WAIT: {m_wd, m_en, busy} = {wd1,   1'b0, 1'b1};
        B0_SEND: {m_wd, m_en, busy} = {wd0,   1'b1, 1'b1};
        B0_WAIT: {m_wd, m_en, busy} = {wd0,   1'b0, 1'b1};
        default: {m_wd, m_en, busy} = {8'h00, 1'b0, 1'b0};
        endcase
    end


    wire [7:0] m_rd;
    wire m_rdy, m_busy;

    spi_master #(.SCK_WIDTH_CLKS(SCK_WIDTH_CLKS)) sm(
        miso, m_wd, mosi, ss, m_rd, m_rdy, m_busy, sck, m_en, rst, clk);
endmodule
