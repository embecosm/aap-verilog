module registerfile (clock, reset, reg_rd1, reg_rd2, reg_rd3, reg_wr1, reg_wr2, reg_wr1_data, reg_wr2_data, reg_wr1_enable, reg_wr2_enable, reg_rd1_out, reg_rd2_out, reg_rd3_out);
	
	input clock;
	input reset;


// This register has five ports: three read, two write

// read inputs and outputs //


	input [05:00]reg_rd1; 		//Which register to read from
	input [05:00]reg_rd2;		// 6 bits wide because we have up to 64 data
	input [05:00]reg_rd3;		

	output [15:00]reg_rd1_out; 	//What is in that register
	output [15:00]reg_rd2_out;
	output [15:00]reg_rd3_out;

// write inputs and outputs //
	
	input  [01:00]reg_wr1;		//Where to write, which register
	input  [01:00]reg_wr2;
	input  [15:00]reg_wr1_data;	//What to write
	input  [15:00]reg_wr2_data;
	input reg_wr1_enable;		//Should it write
	input reg_wr2_enable;

// Other output //


// Registers //
	
	reg [15:00] register [63:00]; 

// Read logic //
	
	assign reg_rd1_out = register[reg_rd1]; // this is combinatoral, this happens automatically
	assign reg_rd2_out = register[reg_rd2];
	assign reg_rd3_out = register[reg_rd3];
	

// Write logic //

	always @(posedge clock or posedge reset) begin // this is sequential, it will only happen on the clock or reset
		if (reset) begin 	// Reset all Registers
			register[0] = 0;
			register[1] = 0;
			register[2] = 0;
			register[3] = 0;
			register[4] = 0;
			register[5] = 0;
			register[6] = 0;
			register[7] = 0;
			register[8] = 0;
			register[9] = 0;
			register[10] = 0;
			register[11] = 0;
			register[12] = 0;
			register[13] = 0;
			register[14] = 0;
			register[15] = 0;
			register[16] = 0;
			register[27] = 0;
			register[18] = 0;
			register[19] = 0;
			register[20] = 0;
			register[21] = 0;
			register[22] = 0;
			register[23] = 0;
			register[24] = 0;
			register[25] = 0;
			register[26] = 0;
			register[27] = 0;
			register[28] = 0;
			register[29] = 0;
			register[30] = 0;
			register[31] = 0;
			register[32] = 0;
			register[32] = 0;
			register[33] = 0;
			register[34] = 0;
			register[35] = 0;
			register[36] = 0;
			register[37] = 0;
			register[38] = 0;
			register[39] = 0;
			register[50] = 0;
			register[51] = 0;
			register[52] = 0;
			register[53] = 0;
			register[54] = 0;
			register[55] = 0;
			register[56] = 0;
			register[57] = 0;
			register[58] = 0;
			register[59] = 0;
			register[60] = 0;
			register[61] = 0;
			register[62] = 0;
			register[63] = 0;
		end
		else begin
		
			if (reg_wr1_enable == 1) begin
				register[reg_wr1] = reg_wr1_data;
			end

			if (reg_wr2_enable == 1) begin
				register[reg_wr2] = reg_wr2_data;
			end
		end
	end

endmodule