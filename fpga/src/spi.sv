
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
    //
    // Receiver
    //
    wire [7:0] rdb;
    wire s_rdy;

    sipo_reg sr0(mosi, rdb, s_rdy, rst | ss, sck);


    //
    // Sync. signals
    //
    wire s_rdy_sync;
    wire [7:0] rdb_sync;

    cell_sync_n #(.N(9)) csn(clk, rst, {rdb, s_rdy}, {rdb_sync, s_rdy_sync});

    //
    // Buffer logic
    //
    always @(posedge clk, posedge rst) begin
        if (s_rdy_sync) begin
            rdy <= 1'b1;
            rd <= rdb_sync;
        end else if (~ss | rst) begin
            rdy <= 1'b0;
            rd <= 8'b0;
        end
    end

    //
    // Sender
    //
    piso_reg pr0(wd, miso, busy, rst | ss, sck);
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

module spi_master(
    input   wire        miso,
    input   wire [7:0]  wd,
    output  wire        mosi,
    output  wire        ss,
    output  reg  [7:0]  rd,
    output  reg         rdy,
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

    clk_div #(.POL(1'd1)) cd(sck, 8'd4, clk, rst | ~en_sck);


    //
    // Receiver
    //
    wire [7:0] rdb;
    wire s_rdy;

    sipo_reg sr0(miso, rdb, s_rdy, rst | ss, sck);


    //
    // Sync. signals
    //
    wire s_rdy_sync;
    wire [7:0] rdb_sync;

    cell_sync_n #(.N(9)) csn(clk, rst, {rdb, s_rdy}, {rdb_sync, s_rdy_sync});


    //
    // Buffer logic
    //
    always @(posedge clk, posedge rst) begin
        if (s_rdy_sync) begin
            rdy <= 1'b1;
            rd <= rdb_sync;
        end else if (~ss | rst) begin
            rdy <= 1'b0;
            rd <= 8'b0;
        end
    end


    //
    // Sender
    //
    wire piso_busy;

    piso_reg pr0(wd, mosi, piso_busy, rst | ss, sck);

    assign busy = ~ss | en_sck;
endmodule
