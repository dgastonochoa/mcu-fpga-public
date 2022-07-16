module seven_seg_decoder(
    input   wire    [3:0] digit,
    output  logic   [6:0] segs
);
    always_comb begin
        case (digit)
            4'b0000: segs = 7'b1000000;
            4'b0001: segs = 7'b1111001;
            4'b0010: segs = 7'b0100100;
            4'b0011: segs = 7'b0110000;
            4'b0100: segs = 7'b0011001;
            4'b0101: segs = 7'b0010010;
            4'b0110: segs = 7'b0000010;
            4'b0111: segs = 7'b1111000;
            4'b1000: segs = 7'b0000000;
            4'b1001: segs = 7'b0010000;
            4'b1010: segs = 7'b0001000;
            4'b1011: segs = 7'b0000011;
            4'b1100: segs = 7'b1000110;
            4'b1101: segs = 7'b0100001;
            4'b1110: segs = 7'b0000110;
            4'b1111: segs = 7'b0001110;
            default: segs = 7'b1000000;
        endcase
    end
endmodule

module seven_seg_ctrl(
    input   wire    [15:0] num,
    output  logic   [3:0]  anode_en,
    output  logic   [6:0]  segs,
    input   wire           clk,
    input   wire           rst
);

    wire [3:0] d0, d1, d2, d3;

    assign d0 = num[3:0];
    assign d1 = num[7:4];
    assign d2 = num[11:8];
    assign d3 = num[15:12];


    reg [2:0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst)
            cnt <= 0;
        else
            cnt <= (cnt == 3 ? 0 : cnt + 1);
    end


    wire [6:0] seg0, seg1, seg2, seg3;

    seven_seg_decoder ssd0(d0, seg0);
    seven_seg_decoder ssd1(d1, seg1);
    seven_seg_decoder ssd2(d2, seg2);
    seven_seg_decoder ssd3(d3, seg3);

    always_comb begin
        case (cnt)
        3'd00:   {anode_en, segs} = {4'b1110, seg0};
        3'd01:   {anode_en, segs} = {4'b1101, seg1};
        3'd02:   {anode_en, segs} = {4'b1011, seg2};
        3'd03:   {anode_en, segs} = {4'b0111, seg3};
        default: {anode_en, segs} = {4'b1111, 7'h0};
        endcase
    end
endmodule
