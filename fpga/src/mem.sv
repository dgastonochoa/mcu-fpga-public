
/**
 * Word-addressable memory module.
 * Writes on the clock pos. edge. Reads async.
 *
 * @param addr Word aligned address. (e.g. 0, 4, 8, 12...)
 * @param wd Write data
 * @param we Write enable. If 1, @p wd will be written in @p addr.
 *           Othrewise, @rd will contain the data at @p addr.
 * @param rd Read data
 * @param rst
 * @param clk
 */
module mem #(parameter N = 64)(
    input   wire [31:0] addr,
    input   wire [31:0] wd,
    input   wire        we,
    output  reg [31:0]  rd,
    input   wire        clk
);
    reg [31:0] _mem [N-1:0];

    always_ff @(posedge clk) begin
        if (we) begin
            _mem[addr[31:2]] <= wd;
        end
    end

    assign rd = _mem[addr[31:2]];
endmodule
