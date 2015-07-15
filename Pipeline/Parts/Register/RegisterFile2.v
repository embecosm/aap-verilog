module registerfile (clock, reset, rd1, rd2, rd3, wr1, wr2, wr1_data, wr2_data, wr1_enable, wr2_enable, rd1_out, rd2_out, rd3_out);
	
	input clock;
	input reset;


// This register has five ports: three read, two write

// read inputs and outputs //


	input [01:00]rd1; 		//Which register to read from
	input [01:00]rd2;
	input [01:00]rd3;

	output [15:00]rd1_out; 	//What is in that register
	output [15:00]rd2_out;
	output [15:00]rd3_out;

// write inputs and outputs //
	
	input  [01:00]wr1;		//Where to write, which register
	input  [01:00]wr2;
	input  [15:00]wr1_data;	//What to write
	input  [15:00]wr2_data;
	input wr1_enable;		//Should it write
	input wr2_enable;

// Registers //
	
	reg [15:00] data [03:00]; 

// Read logic //
	
	assign rd1_out = data[rd1]; // this is combinatoral, this happens automatically
	assign rd2_out = data[rd2];
	assign rd3_out = data[rd3];
	

// Write logic //

	always @(posedge clock or posedge reset) begin // this is sequential, it will only happen on the clock or reset
		if (reset) begin 	// Reset all data
			data[0] = 0;
			data[1] = 0;
			data[2] = 0;
			data[3] = 0;
		end
		else begin
		
			if (wr1_enable == 1) begin
				data[wr1] = wr1_data;
			end

			if (wr2_enable == 1) begin
				data[wr2] = wr2_data;
			end
		end
	end

endmodule