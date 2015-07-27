`include "Execute2.v"
`include "RegisterFile3.v"
`include "16or32decoder5_tb.v"

module testbench;

	reg clock;
	reg reset;

	wire [05:00] reg_rd1;
	wire [05:00] reg_rd2;
	wire [05:00] reg_rd3;

	wire [15:00] reg_rd1_out;
	wire [15:00] reg_rd2_out;
	wire [15:00] reg_rd3_out;

	wire [02:00] destination;

	wire [01:00] reg_wr1;
	wire [15:00] reg_wr1_data;
	wire 		 reg_wr1_enable;

	wire [01:00] reg_wr2;
	wire [15:00] reg_wr2_data;
	wire 		 reg_wr2_enable;


	wire [15:00] reg_rd1_data;
	wire [15:00] reg_rd2_data;
	wire [15:00] reg_rd3_data;

	reg [15:00] register [63:00]; 

	wire [15:00]  fetchoutput;
    wire [05:00]  operationnumber;
    reg		      opcodemem;

    wire [02:00] source_1;
    wire [02:00] source_2;

    wire [02:00] unsigned_1;
    wire [05:00] unsigned_2;
    wire [08:00] unsigned_3;

    registerfile registerfile_tb( clock, reset, reg_rd1[05:00], reg_rd2[05:00], reg_rd3[05:00], reg_wr1, reg_wr2, reg_wr1_data, reg_wr2_data, reg_wr1_enable, reg_wr2_enable, reg_rd1_out[15:00], reg_rd2_out[15:00], reg_rd3_out[15:00]);
    sixteenbitdecoder sixteenbbitdecoder_test (fetchoutput[15:00], destination[02:00], operationnumber[05:00], source_1[02:00], source_2[02:00], unsigned_1[02:00], unsigned_2[05:00], unsigned_3[08:00]);
    fetch fetch_test (fetchoutput[15:00]);
    execution execution_test (clock, operationnumber[05:00], destination[02:00], source_1[02:00], source_2[02:00], unsigned_1[02:00], unsigned_2[05:00], unsigned_3[08:00], reg_rd1[05:00], reg_rd2[05:00], reg_rd3[05:00], reg_wr1, reg_wr2, reg_wr1_data, reg_wr2_data, reg_wr1_enable, reg_wr2_enable, reg_rd1_out[15:00], reg_rd2_out[15:00], reg_rd3_out[15:00]);

		initial begin
			clock = 0;

			#2
				reset = 1;
			#2
				reset = 0;

			#2

		/*	reg_rd1 = 0;
			reg_rd2 = 0;
			reg_rd3 = 0;
			reg_wr1 = 0;
			reg_wr2 = 0;
		*/	
		/*	reg_wr1_enable = 0;
			reg_wr2_enable = 0;
			reg_wr1_data = 0;
			reg_wr2_data = 0;
			fetchoutput = 0;
			
		*/	
			#10
			$dumpfile ("execution_tb.vcd");
			$dumpvars (0, registerfile_tb, sixteenbbitdecoder_test, fetch_test, execution_test);
			#50
			$finish;

		end


	always 
		#1 clock = ~clock;
endmodule
