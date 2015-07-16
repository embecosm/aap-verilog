module TheDataMemory (clock, reset, data_rd1, data_rd2, data_rd3, data_rd4, data_wr1, data_wr2, data_wr3, data_wr4, data_wr1_data, data_wr2_data, data_wr3_data, data_wr4_data, data_wr1_enable, data_wr2_enable, data_wr3_enable, data_wr4_enable, data_rd1_out, data_rd2_out, data_rd3_out, data_rd4_out);
	
	input clock;
	input reset;


// This register has five ports: three read, two write

// read inputs and outputs //


	input  [08:00] data_rd1; 	                            //Which register to read from
	input  [08:00] data_rd2;		                        //20 bits wide because we have up to 512 data
	input  [08:00] data_rd3;
	input  [08:00] data_rd4;				

	output [15:00] data_rd1_out;                         	//What is in that register
	output [15:00] data_rd2_out;
	output [15:00] data_rd3_out;
	output [15:00] data_rd4_out;

// write inputs and outputs //
	
	input  [08:00] data_wr1;	                            //Where to write, which register
	input  [08:00] data_wr2;
	input  [08:00] data_wr3;	                            //Where to write, which register
	input  [08:00] data_wr4;
	input  [31:00] data_wr1_data;	                        //What to write
	input  [31:00] data_wr2_data;
	input  [31:00] data_wr3_data;	                        //What to write
	input  [31:00] data_wr4_data;
	input          data_wr1_enable;		                    //Should it write
	input 		   data_wr2_enable;
	input          data_wr3_enable;		                    //Should it write
	input 		   data_wr4_enable;

// Other output //


// Registers //
	
	reg [31:00] data_memory [511:00]; 

// Read logic //
	
	assign rd1_out = data_memory[rd1];                      //this is combinatoral, this happens automatically
	assign rd2_out = data_memory[rd2];
	assign rd3_out = data_memory[rd3];
	assign rd4_out = data_memory[rd4];

// Write logic //

	always @(posedge clock or posedge reset) begin          // this is sequential, it will only happen on the clock or reset
		if (reset) begin 	                                // Reset all Registers
			data_memory[0:31:511] = 0;
		end
		else begin
		
			if (data_wr1_enable == 1) begin
				data_memory[data_wr1] = data_wr1_data;
			end

			if (data_wr2_enable == 1) begin
				data_memory[data_wr2] = data_wr2_data;
			end

			if (data_wr3_enable == 1) begin
				data_memory[data_wr3] = data_wr3_data;
			end

			if (data_wr4_enable == 1) begin
				data_memory[data_wr4] = data_wr4_data;
			end
		end
	end

endmodule