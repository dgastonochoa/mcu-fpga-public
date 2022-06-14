`ifndef WAIT_CLKS
    `define WAIT_CLKS  32'h2faf080  // 500e5; 100e6 / 500e5 = 2
`endif

module led_blink(
    input  wire         sw,
    output wire [15:0]  leds,

    //
    // Debug signals
    //
    output wire         _slow_clk,
    output wire         _blink_led,
    output wire [31:0]  _timer,

    input  wire         clk,
    input  wire         rst
);
    reg slow_clk;
    reg [31:0] timer;

    reg blink_led;

    assign leds[0] = rst;
    assign leds[1] = blink_led;
    assign leds[2] = sw;
    assign leds[15:3] = {13{1'b0}};

    assign _slow_clk = slow_clk;
    assign _blink_led = blink_led;
    assign _timer = timer;

    always @(posedge clk) begin
        if (rst) begin
            slow_clk <= 0;
            timer <= 0;
        end else begin
            if (timer < `WAIT_CLKS) begin
                timer <= timer + 1;
            end else begin
                timer <= 0;
                slow_clk = ~slow_clk;
            end
        end
    end

    always @(posedge slow_clk or posedge rst) begin
        if (rst)
            blink_led <= 1'b0;
        else
            blink_led = ~blink_led;
    end

endmodule