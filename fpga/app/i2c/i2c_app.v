/**
 * JA:      Pmod pins. Will be used to wire I2C sda and scl.
 * LED:     Leds to show results.
 * btnC:    Button to trigger an operation execution.
 * btnU:    Reset.
 * sw:      Switches to control which will the next op. do and which
 *          result will be displayedi n the LEDs
 */
module i2c_app(CLK100MHZ, JA, LED, btnC, btnU, sw);
    input wire CLK100MHZ;
    inout wire [7:0] JA;
    output wire [15:0] LED;
    input wire btnC, btnU;
    input wire [15:0] sw;

    parameter WAIT_CLKS = 25;

    localparam
        MCS_IDLE = 0,
        MCS_START = 1,
        MCS_WAIT_MASTER_BUSY = 2,
        MCS_RUNNING = 3;

    wire debc_btnC, debc_btnU;

    // Flags to determine wheter or not:
    // - The next op. is master read (otherwise is master write)
    // - The next transfer will be sent to slave 1 (otherwise is slave 0)
    // - Show slave 0 or 1, or master, leds. Master has priority: if `master_leds`
    //      is true, `s1_leds` is ignored.
    wire is_read_op, is_slave_1, s1_leds, master_leds;

    // `sync_` signals are those that come ou of a `cell_sync` (so they are synchronized)
    // `_p` signals are those that come out of a edge detector.
    wire sync_rst, rst_p, pre_en, sync_pre_en, sync_pre_en_p;

    // `en` will generate a pulse when `pre_en` is enabled. This is done because some
    // state needs to be set up after `pre_en` happens and before the actual op. occurs.
    reg en, clk;

    // Will store the state machine's state.
    reg [3:0] i2cmcs;

    // Counter to divide the main clock signal.
    reg [7:0] cnt;

    // Will show the state of the leds, depending on which slave or master is enabled.
    // See `s1_leds` and `master_leds`.
    reg [7:0] leds;

    // master signals
    // `master_data_rdy`: asserted when the master has data available to read.
    wire sda, scl, rst, master_busy, master_data_rdy;
    // Will store the data read by the master.
    wire [7:0] master_read_data;
    // I2C cmd. (address + r/w) and a buffer to store the last read master data.
    reg [7:0] cmd, master_write_data, master_read_data_buff;

    // slave 0 signals (similar to the master ones)
    wire s0_busy, s0_data_rdy, s0_data_rdy_p;
    wire [7:0] s0_read_data;
    reg [7:0] s0_read_data_buff;

    // slave 1 signals (similar to the master ones)
    wire s1_busy, s1_data_rdy, s1_data_rdy_p;
    wire [7:0] s1_read_data;
    reg [7:0] s1_read_data_buff;

    // slave 0 and 1 sda and scl lines
    wire s_sda, s_scl;

    // Debounce filters to avoid the switchs bouncing.
    // 500 because the switch was triggering the master - slave comm. several
    // times in just one press.
    debounce_filter #(.WAIT_CLK(500)) df1(btnC, CLK100MHZ, debc_btnC);
    debounce_filter #(.WAIT_CLK(500)) df2(btnU, CLK100MHZ, debc_btnU);

    // Synchronize rst (reset) and pre_en (pre-enable) signals
    cell_sync cs0(clk, 1'b0, rst, sync_rst);
    cell_sync cs1(clk, 1'b0, pre_en, sync_pre_en);


    // Edge detectors
    pos_edge_det ped(sync_rst, CLK100MHZ, rst_p);

    pos_edge_det psed0(s0_data_rdy, clk, s0_data_rdy_p);
    pos_edge_det psed1(s1_data_rdy, clk, s1_data_rdy_p);

    pos_edge_det psed2(sync_pre_en, clk, sync_pre_en_p);


    // Master and slaves
    i2c_master i2cm(sda, scl, en, sync_rst, cmd, master_write_data, master_busy, master_read_data, master_data_rdy, clk);

    i2c_slave #(.ADDRESS(7'h55), .DATA_TYPE(0)) i2cs0(s_sda, s_scl, s0_busy, s0_data_rdy, s0_read_data, sync_rst, clk);
    i2c_slave #(.ADDRESS(7'h77), .DATA_TYPE(1)) i2cs1(s_sda, s_scl, s1_busy, s1_data_rdy, s1_read_data, sync_rst, clk);


    // Application logic
    always @ (posedge clk) begin
        if (rst) begin
            cmd <= 0;
            master_write_data <= 8'h00;
            master_read_data_buff <= 0;
            s0_read_data_buff <= 0;
            s1_read_data_buff <= 0;
            en <= 0;
            i2cmcs <= MCS_IDLE;
            leds <= 0;
        end else begin

            // App. state machine. Sets up the next op. to perform based on the
            // signal fags and runs it.
            case (i2cmcs)
                MCS_IDLE: begin
                    if (sync_pre_en_p) begin
                        // cmd[0] == 1: master read
                        // cmd[0] == 0: master write
                        if (is_read_op)
                            cmd <= ( is_slave_1 ? ((7'h77 << 1) | 1) : ((7'h55 << 1) | 1) );
                        else
                            cmd <= ( is_slave_1 ? ((7'h77 << 1) | 0) : ((7'h55 << 1) | 0) );

                        i2cmcs <= MCS_START;
                        master_write_data <= master_write_data + 1;
                    end
                end

                MCS_START: begin
                    en <= 1;
                    i2cmcs <= MCS_WAIT_MASTER_BUSY;
                end

                MCS_WAIT_MASTER_BUSY: begin
                    if (master_busy)
                        i2cmcs <= MCS_RUNNING;
                end

                MCS_RUNNING: begin
                    en <= 0;
                    if (!master_busy) begin
                        i2cmcs <= MCS_IDLE;
                    end
                end
            endcase

            if (master_leds) begin
                leds <= master_read_data_buff;
            end else begin
                if (!s1_leds) begin
                    leds <= s0_read_data_buff;
                end else begin
                    leds <= s1_read_data_buff;
                end
            end

            if (s0_data_rdy_p) begin
                s0_read_data_buff <= s0_read_data;
            end

            if (s1_data_rdy_p) begin
                s1_read_data_buff <= s1_read_data;
            end

            if (master_data_rdy) begin
                master_read_data_buff <= master_read_data;
            end
        end
    end

    // Clock divider
    always @(posedge CLK100MHZ) begin
        if (rst_p) begin
            cnt <= 0;
            clk <= 0;
        end else begin
            if (cnt == WAIT_CLKS) begin
                clk <= ~clk;
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end


    assign pre_en = debc_btnC;
    assign rst = debc_btnU;
    assign is_read_op = sw[0];
    assign is_slave_1 = sw[1];

    // if master_leds == 1 => leds will display master last read val.
    // else, if s1_leds == 0 => leds slave 0, else leds slave 1.
    assign s1_leds = sw[2];
    assign master_leds = sw[3];

    assign LED[7:0] = leds;
    assign LED[15:8] = 0;

`ifdef TEST_BENCH
    // For some reason, if this is added to the test bench
    // module, it doesn't work well.
    pullup(sda);
    pullup(scl);
`endif

    assign JA[0] = sda;
    assign JA[1] = scl;
    assign JA[4] = s_sda;
    assign JA[5] = s_scl;

endmodule
