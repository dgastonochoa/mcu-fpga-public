// //// Debug signals
//     output wire          mosi,
//     output wire          miso,
//     output wire          ss,
//     output wire          sck,

//     output wire          m_rdy,
//     output wire          m_busy,
//     output wire          s_rdy,
//     output wire          s_busy,
//     ////

module spi_tests #(parameter SCK_PWIDTH = 10) (
    input  wire          en_sync,
    input  wire  [3:0]   _sw,
    output logic [7:0]   leds,
    output wire  [7:0]   m_wd,
    output wire  [7:0]   s_wd,
    output wire          mosi,
    output wire          miso,
    output wire          ss,
    output wire          sck,
    input  wire          clk,
    input  wire          rst
);
    reg [7:0] cte55, cteaa, cte00;

    always @(posedge rst) begin
        cte55 <= 8'h55;
        cteaa <= 8'haa;
        cte00 <= 8'h00;
    end

    assign m_wd = (_sw[1] == 1 ? cte55 : cteaa);

    // For some reason, using _sw[2] breaks the tests in the physical fpga.
    assign s_wd = (_sw[3] == 1 ? cteaa : cte55);


    wire [7:0] m_rd;
    wire m_rdy, m_busy;

    spi_master #(.SCK_WIDTH_CLKS(SCK_PWIDTH)) dut1(
        miso, m_wd, mosi, ss, m_rd, m_rdy, m_busy, sck, en_sync, rst, clk);


    wire [7:0] s_rd;
    wire s_rdy, s_busy;

    spi_slave dut2(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, rst, sck, clk);


    assign leds[7:0] = (_sw[0] == 1 ? s_rd : m_rd);
endmodule
