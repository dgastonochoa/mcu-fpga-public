// Code your testbench here
// or browse Examples
module neg_edge_det_tb;
	reg sig;                                  // Declare internal TB signal called sig to drive the sig pin of the design
	reg clk;                                  // Declare internal TB signal called clk to drive clock to the design

	// Instantiate the design in TB and connect with signals in TB
	neg_edge_det ned (.sig(sig), .clk(clk), .pe(pe));

	// Generate a clock of 100MHz
	always #5 clk = ~clk;

	// Drive stimulus to the design
	initial begin
		clk <= 0;
		sig <= 1;
		#20 sig <= 0;
		#100
    sig <= 1;
    #100;
    sig <= 0;
    #100;
		sig <= 1;
    #1 sig <= 0;
    #1 sig <= 1;
    #1 sig <= 0;
    #1 sig <= 1;
		#1;

		#105;
		#5 sig <= 1;
    #10 sig <= 0;
    #10 sig <= 1;
    #10 sig <= 0;
    #10 sig <= 1;
    #100;
    $finish;
	end

  	initial begin
      $dumpfile("neg_edge_det_tb.vcd");
      $dumpvars(1, neg_edge_det_tb);
    end
endmodule