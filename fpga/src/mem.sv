`include "errno.svh"
`include "mem.svh"
`include "synth.svh"

/**
 * Byte-enableable word-length memory. Allows to perform read/write
 * operations in only the specified bytes within the word whose
 * address is @param{addr}.
 *
 * In other words, instead of just allowing to read/write full words,
 * allows to read/write one or more bytes within the specified word.
 *
 * @param addr Address of the word whose bytes will be read/written.
 * @param wd Data to be written (if @param{we} is enabled).
 *
 * @param be Byte selector. Allows to act only over the specified bytes.
 *           Allowed values are:
 *              0001, 0010, 0100, 1000: to access individual bytes.
 *              0011, 1100: to access the lower/upper word respectively.
 *              1111: to access the full word.
 *
 * @param we Write enable. Enable to write, disable to read. In combination
 *           with @param{be} allows to read/write subsets of the word.
 *
 * @param se Sign extend. On read, if enabled and not all bytes are selected, the
 *           upper bits will be filled with 0 or 1 depending on the selected bytes'
 *           MSB.
 *
 * @param rd Read value.
 * @param clk Clock signal.
 *
 * @warning Write is sync. with the provided clock signal. Read is
 *          asynchronous.
 *
 * @warning Address must be word-aligned when accessing the full word
 *          (@see{be}) and half-word-aligned when accessing half words.
 */
module mem_be #(parameter N = 64)(
    input   wire        [31:0]  addr,
    input   wire        [31:0]  wd,
    input   wire        [3:0]   be,
    input   wire                we,
    input   wire                se,
    output  logic       [31:0]  rd,
    input   wire                clk
);
    reg [31:0] _mem [N-1:0];

    //
    // Write logic
    //
    always_ff @(posedge clk) begin
        if (we) begin
            case (be)
            4'b0001: _mem[addr[31:2]][7:0]     <= wd[7:0];
            4'b0010: _mem[addr[31:2]][15:8]    <= wd[7:0];
            4'b0100: _mem[addr[31:2]][23:16]   <= wd[7:0];
            4'b1000: _mem[addr[31:2]][31:24]   <= wd[7:0];

            4'b0011: _mem[addr[31:2]][15:0]    <= wd[15:0];
            4'b1100: _mem[addr[31:2]][31:16]   <= wd[15:0];

            4'b1111: _mem[addr[31:2]]          <= wd;

            default: _mem[addr[31:2]]          <= 32'bx;
            endcase
        end
    end


    //
    // Read logic
    //
    wire [31:0] word;
    wire [7:0] b0, b1, b2, b3;
    wire s0, s1, s2, s3;

    assign word = _mem[addr[31:2]];

    assign b0 = word[7:0];
    assign b1 = word[15:8];
    assign b2 = word[23:16];
    assign b3 = word[31:24];

    assign s0 = se ? b0[7] : 1'b0;
    assign s1 = se ? b1[7] : 1'b0;
    assign s2 = se ? b2[7] : 1'b0;
    assign s3 = se ? b3[7] : 1'b0;

    always_comb begin
        case (be)
        4'b0001: rd = {{24{s0}}, b0};
        4'b0010: rd = {{24{s1}}, b1};
        4'b0100: rd = {{24{s2}}, b2};
        4'b1000: rd = {{24{s3}}, b3};

        4'b0011: rd = {{16{s1}}, b1, b0};
        4'b1100: rd = {{16{s3}}, b3, b2};

        4'b1111: rd = word;

        default: rd = 32'bx;
        endcase
    end
endmodule

/**
 * Strict-aligned word/half-word/byte addressable memory.
 * Writes on the clock pos. edge. Reads async.
 *
 * @param addr Address. It must be aligned with the provided
 *             data type.
 *
 * @param wd Write data.
 *
 * @param we Write enable. If 1, @param{wd} will be written in @param{addr}.
 *           Othrewise, @param{rd} will contain the data at @param{addr}.
 *
 * @param dt Data type. To read/write a particular data type. @param{addr}
 *           must have the right alignment for the provided data type.
 *
 * @param rd Read data.
 * @param err Error flags.
 * @param clk Clock signal.
 */
module mem #(parameter N = 64)(
    input   wire        [31:0]  addr,
    input   wire        [31:0]  wd,
    input   wire                we,
    input   mem_dt_e            dt,
    output  logic       [31:0]  rd,
    output  errno_e             err,
    input   wire                clk
);
    wire [3:0] b_be, h_be, w_be;
    logic [3:0] be;
    logic se;

    dec d(addr[1:0], b_be);

    assign h_be = addr[1] == 1'b1 ? 4'b1100 : 4'b0011;

    assign w_be = 4'b1111;

    always_comb begin
        case (dt)
        MEM_DT_BYTE:    {be, se} = {b_be, 1'b1};
        MEM_DT_HALF:    {be, se} = {h_be, 1'b1};
        MEM_DT_WORD:    {be, se} = {w_be, 1'b0};
        MEM_DT_UBYTE:   {be, se} = {b_be, 1'b0};
        MEM_DT_UHALF:   {be, se} = {h_be, 1'b0};
        default:        be = 32'bx;
        endcase
    end

    mem_be _mem(addr, wd, be, we, se, rd, clk);


    //
    // Error logic
    //
    errno_e err_half, err_word;

    assign err_half = `CAST(errno_e, addr[0]);
    assign err_word = `CAST(errno_e, (addr[1] | addr[0]));

    always_comb begin
        case (dt)
        MEM_DT_HALF: err = err_half;
        MEM_DT_WORD: err = err_word;
        default: err = `CAST(errno_e, 1'b0);
        endcase
    end
endmodule
