`timescale 10ps/1ps

`ifndef VCD
    `define VCD "mem_send_ctrl_tb.vcd"
`endif

module mem_send_ctrl_tb;
    reg clk = 0;

    always #3 clk = ~clk;

    reg rst = 0;

    reg si_busy;
    wire [31:0] tm_d_addr;
    wire tm, si_en;

    mem_send_ctrl dut(si_busy, tm_d_addr, tm, si_en, clk, rst);


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_send_ctrl_tb);
        #12 rst = 1'b1;
        #12 rst = 1'b0;
            si_busy = 1'b0;

        @(posedge si_en);
            assert(tm_d_addr === 32'd00);
            assert(tm === 1'b1);

        #12 si_busy = 1'b1;
        #36 si_busy = 1'b0;

        @(posedge si_en);
            assert(tm_d_addr === 32'd04);
            assert(tm === 1'b1);

        #12 si_busy = 1'b1;
        #36 si_busy = 1'b0;

        @(posedge si_en);
            assert(tm_d_addr === 32'd08);
            assert(tm === 1'b1);

        #12 si_busy = 1'b1;
        #36 si_busy = 1'b0;

        @(posedge si_en);
            assert(tm_d_addr === 32'd12);
            assert(tm === 1'b1);

        #12 si_busy = 1'b1;
        #36 si_busy = 1'b0;


        #1  assert(tm_d_addr === 32'd00);
            assert(tm === 1'b0);
            assert(si_en === 1'b0);

        #18 $finish;
    end
endmodule
