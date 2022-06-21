module spi_tests #(parameter SCK_PWIDTH = 10) (
    output wire          mosi,
    output wire          miso,
    output wire          ss,
    output wire          sck,

    output wire          m_rdy,
    output wire          m_busy,
    output wire          s_rdy,
    output wire          s_busy,

    input  wire          en_sync,
    input  wire  [3:0]   sw,
    output wire  [7:0]   leds,
    input  wire          clk,
    input  wire          rst
);
    reg [7:0] cte55, cteaa, cte00;

    always @(posedge rst) begin
        cte55 <= 8'h55;
        cteaa <= 8'haa;
        cte00 <= 8'h00;
    end

    wire [7:0] m_wd, s_wd;

    assign m_wd = (sw[1] == 1'b1 ? cte55 : cteaa);
    assign s_wd = (sw[2] == 1'b1 ? cteaa : cte55);


    wire [7:0] m_rd;

    spi_master #(.SCK_WIDTH_CLKS(SCK_PWIDTH)) dut1(
        miso, m_wd, mosi, ss, m_rd, m_rdy, m_busy, sck, en_sync, rst, clk);


    wire [7:0] s_rd;

    spi_slave dut2(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, rst, sck, clk);


    wire [7:0] m_data, s_data;

    // assign m_data = m_rdy == 1'b1 ? m_rd : cte00;
    // assign s_data = s_rdy == 1'b1 ? s_rd :  cte00;

    // assign leds[7:0] = sw[0] == 1'b1 ? s_data : m_data;

    assign leds[7:0] = sw[0] == 1'b1 ? s_rd : m_rd;
endmodule
