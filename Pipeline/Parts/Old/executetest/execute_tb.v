`include "Execute.v"
`include "RegisterFile2.v"
`include "16or32decoder5_tb.v"

module testbench;

	reg clock;
	reg reset;

	wire [05:00] rd1;
	wire [05:00] rd2;
	wire [05:00] rd3;

	wire [15:00] rd1_out;
	wire [15:00] rd2_out;
	wire [15:00] rd3_out;

	wire [02:00] destination;

	wire [01:00] wr1;
	wire [15:00] wr1_data;
	wire 		 wr1_enable;

	wire [01:00] wr2;
	wire [15:00] wr2_data;
	wire 		 wr2_enable;


	wire [15:00] rd1_data;
	wire [15:00] rd2_data;
	wire [15:00] rd3_data;

	reg [15:00] data [63:00]; 

	wire [15:00]  fetchoutput;
    wire [05:00]  operationnumber;
    reg		      opcodemem;

    wire [02:00] source_1;
    wire [02:00] source_2;

    wire [02:00] unsigned_1;
    wire [05:00] unsigned_2;
    wire [08:00] unsigned_3;

    registerfile registerfile_tb( clock, reset, rd1[05:00], rd2[05:00], rd3[05:00], wr1, wr2, wr1_data, wr2_data, wr1_enable, wr2_enable, rd1_out[15:00], rd2_out[15:00], rd3_out[15:00]);
    sixteenbitdecoder sixteenbbitdecoder_test (fetchoutput[15:00], destination[02:00], operationnumber[05:00], source_1[02:00], source_2[02:00], unsigned_1[02:00], unsigned_2[05:00], unsigned_3[08:00]);
    fetch fetch_test (fetchoutput[15:00]);
    execution execution_test (clock, operationnumber[05:00], destination[02:00], source_1[02:00], source_2[02:00], unsigned_1[02:00], unsigned_2[05:00], unsigned_3[08:00], rd1[05:00], rd2[05:00], rd3[05:00], wr1, wr2, wr1_data, wr2_data, wr1_enable, wr2_enable, rd1_out[15:00], rd2_out[15:00], rd3_out[15:00]);

		initial begin
			clock = 0;
			reset = 0;
		/*	rd1 = 0;
			rd2 = 0;
			rd3 = 0;
			wr1 = 0;
			wr2 = 0;
		*/	data [00] =0;
			data [01] = 2;
			data [02] = 3;
			data [03] = 0;
		/*	wr1_enable = 0;
			wr2_enable = 0;
			wr1_data = 0;
			wr2_data = 0;
			fetchoutput = 0;
		*/	$dumpfile ("execution_tb.vcd");
			$dumpvars (0, registerfile_tb, sixteenbbitdecoder_test, fetch_test, execution_test);

			// Initial reset //
			#5 	reset = 1;
			#20 reset = 0;
			#5
			data [00] = 0;
			data [01] = 2;
			data [02] = 3;
			#50
			$finish;

		end

	always 
		#1 clock = ~clock;
endmodule
