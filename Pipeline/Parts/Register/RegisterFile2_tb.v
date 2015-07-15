`include "RegisterFile2.v"

module Register2_tb;

	reg clock;
	reg reset;

	reg [01:00] rd1;
	reg [01:00] rd2;
	reg [01:00] rd3;

	reg [01:00] wr1;
	reg [15:00] wr1_data;
	reg 		wr1_enable;

	reg [01:00] wr2;
	reg [15:00] wr2_data;
	reg 		wr2_enable;


	wire [15:00] rd1_data;
	wire [15:00] rd2_data;
	wire [15:00] rd3_data;

	registerfile registerfile_tb(clock, reset, rd1, rd2, rd3, wr1, wr2, wr1_data, wr2_data, wr1_enable, wr2_enable, rd1_out, rd2_out, rd3_out);
		initial begin
			clock = 0;
			reset = 0;
			rd1 = 0;
			rd2 = 0;
			rd3 = 0;
			wr1 = 0;
			wr2 = 0;
			wr1_enable = 0;
			wr2_enable = 0;
			wr1_data = 0;
			wr2_data = 0;
			$dumpvars;

			// Initial reset //
			#5 	reset = 1;
			#20 reset = 0;

			// Tests //
			#20
				// Write 0x10 to register 0
			    wr1_data    = 16'h0010;
			    wr1         = 1;
			    wr1_enable  = 1;

			    // // Also write 0x20 to register 1
			    wr2_data    = 16'h0020;
			    wr2         = 3;
			    wr2_enable  = 1;
			#20
				    // Write 0x20 to register 2
			    wr1_data    = 16'hABCD;
			    wr1         = 2;
			    wr1_enable  = 1;
			#20
				// Read registers 3 and 1
				rd1 = 1;
				rd2 = 3;
			#20
				//Read register 2 //
				rd1 = 2;
			#20 
				reset = 1;
				wr1_enable = 0;
				wr2_enable = 0;
			#20
				reset = 0;
			#20
				$finish;

		end

	always 
		#1 clock = ~clock;
endmodule