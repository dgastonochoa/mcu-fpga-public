/**
 * In each cycle stores a byte in @param{res} like:
 *
 * clk 1: res[0][7:0]   = rd[0]
 * clk 2: res[0][15:8]  = rd[1]
 * clk 3: res[0][23:16] = rd[2]
 * clk 4: res[0][31:24] = rd[3]
 * clk 5: res[1][7:0]   = rd[0]
 * ...
 * ...
 *
 * This module is meant to be used in conjunction with serial ifaces. to
 * store the bytes the receive as words and verify results when testing.
 *
 */
module word_storage(
    input  wire [7:0]  rd,
    output reg  [31:0] res [255],
    input  wire        rst,
    input  wire        clk
);
    reg [31:0] word, cnt2;
    reg [3:0] cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 0;
            cnt2 <= 0;
            word <= 0;
        end else begin
            #1 case (cnt)
            3'd0: word[7:0]   <= rd;
            3'd1: word[15:8]  <= rd;
            3'd2: word[23:16] <= rd;
            3'd3: word[31:24] <= rd;
            endcase
            cnt <= (cnt == 3'd3 ? 3'd0 : cnt + 1);

            if (cnt == 3'd3) begin
                #1  res[cnt2] <= word;
                cnt2 <= cnt2 + 1;
            end
        end
    end
endmodule
