module cell_sync (
    input wire clk,
    input wire rst,
    input wire in_p,
    output wire out_p
);

reg in_meta;
reg in_sync;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        in_meta <= 1'b0;
        in_sync <= 1'b0;
    end else begin
        in_meta <= in_p;
        in_sync <= in_meta;
    end
end

assign out_p = in_sync;

endmodule
