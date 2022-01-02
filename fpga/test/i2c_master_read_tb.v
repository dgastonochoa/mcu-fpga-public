`timescale 1us/100ns

module i2c_master_read_tb;

    wire sda;
    wire scl;

    wire master_busy;
    wire [7:0] read_data;
    reg en = 0;
    reg rst = 0;

    wire slave_busy;
    wire slave2_busy;
    wire slave3_busy;
    wire [7:0] s1_rd;
    wire [7:0] s2_rd;
    wire [7:0] s3_rd;

    reg [7:0] cmd = 0;
    reg [7:0] data = 8'haa;
    reg clk = 0;

    pullup(sda);
    pullup(scl);

    i2c_master i2cm(sda, scl, en, rst, cmd, data, master_busy, read_data, clk);
    i2c_slave #(.ADDRESS(7'h77)) i2cs(sda, scl, slave_busy, s1_rd, rst, clk);
    i2c_slave #(.ADDRESS(7'h2a)) i2cs2(sda, scl, slave2_busy, s2_rd, rst, clk);
    i2c_slave #(.ADDRESS(7'h54)) i2cs3(sda, scl, slave3_busy, s3_rd, rst, clk);

    always #2.5 clk <= ~clk;

    initial begin
        $dumpfile("i2c_master_read_tb.vcd");
        $dumpvars(1, i2c_master_read_tb);

        #10 rst <= 1;
        #10 rst <= 0;

            cmd <= (7'h77 << 1) | 1;
        #10 en <= 1;
        #10 en <= 0;
        @(negedge master_busy);

            cmd <= (7'h2a << 1) | 1;
        #10 en <= 1;
        #10 en <= 0;
        @(negedge master_busy);

            cmd <= (7'h12 << 1) | 1;
        #10 en <= 1;
        #10 en <= 0;
        @(negedge master_busy);

        #50;
        $finish;
    end

    wire _sda_clk;
    assign _sda_clk = i2cm.sda_clk;

    wire [7:0] _i2cm_idx;
    assign _i2cm_idx = i2cm.idx;

    wire [7:0] _i2cm_read_data;
    assign _i2cm_read_data = i2cm.read_data;

    wire [3:0] _i2cm_cs;
    assign _i2cm_cs = i2cm.cs;

    wire [5:0] _i2cm_err_flags;
    assign _i2cm_err_flags = i2cm.err_flags;

    //
    // Slave debug
    //
    wire [3:0] _i2cs_cs;
    assign _i2cs_cs = i2cs.cs;

    wire [3:0] _i2cs_idx;
    assign _i2cs_idx = i2cs.idx;

    wire [7:0] _i2cs_addr;
    assign _i2cs_addr = i2cs.cmd_buff[7:1];

    wire [7:0] _i2cs_rd_buff;
    assign _i2cs_rd_buff = i2cs.rd_buff;

    wire _i2cs_sda_reg;
    assign _i2cs_sda_reg = i2cs.sda_reg;

    wire _i2cs_np_scl;
    assign _i2cs_np_scl = i2cs.np_scl;

    wire _i2cs_p_sda;
    assign _i2cs_p_sda = i2cs.p_sda;


    wire [7:0] _i2cs_data_write;
    assign _i2cs_data_write = i2cs.data_write;

    //
    // Slave 2 debug
    //
    wire [3:0] _i2cs2_cs;
    assign _i2cs2_cs = i2cs2.cs;

    wire [7:0] _i2cs2_addr;
    assign _i2cs2_addr = i2cs2.cmd_buff[7:1];

    wire [7:0] _i2cs2_rd_buff;
    assign _i2cs2_rd_buff = i2cs2.rd_buff;


    //
    // Slave 3 debug
    //
    wire [3:0] _i2cs3_cs;
    assign _i2cs3_cs = i2cs3.cs;

    wire [7:0] _i2cs3_addr;
    assign _i2cs3_addr = i2cs3.cmd_buff[7:1];

    wire [7:0] _i2cs3_rd_buff;
    assign _i2cs3_rd_buff = i2cs3.rd_buff;

endmodule
