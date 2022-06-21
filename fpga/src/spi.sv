
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
    piso_reg pr0(wd, mosi, busy, rst, sck);
endmodule
