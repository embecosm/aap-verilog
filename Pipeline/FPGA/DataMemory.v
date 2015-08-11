module TheDataMemory (clock, reset, data_rd1, data_rd2, data_rd3, data_rd4, data_wr1, data_wr2, data_wr3, data_wr4, data_wr1_data, data_wr2_data, data_wr3_data, data_wr4_data, data_wr1_enable, data_wr2_enable, data_wr3_enable, data_wr4_enable, data_rd1_out, data_rd2_out, data_rd3_out, data_rd4_out);
	
	input clock;
	input reset;


// This register has five ports: three read, two write

// read inputs and outputs //


	input  [08:00] data_rd1; 	                            //Which register to read from
	input  [08:00] data_rd2;		                            //20 bits wide because we have up to 1048576 data
	input  [08:00] data_rd3;
	input  [08:00] data_rd4;				

	output [31:00] data_rd1_out;                         	//What is in that register
	output [31:00] data_rd2_out;
	output [31:00] data_rd3_out;
	output [31:00] data_rd4_out;

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

// Integers //
	reg [19:00] dataloopcount;

// Registers //
	
	reg [31:00] data_memory [128:00]; 

// Reset Loop //



// Read logic //
	
	assign data_rd1_out = data_memory[data_rd1];                      //this is combinatoral, this happens automatically
	assign data_rd2_out = data_memory[data_rd2];
	assign data_rd3_out = data_memory[data_rd3];
	assign data_rd4_out = data_memory[data_rd4];

// Write logic //

	always @(posedge clock or posedge reset) begin          // this is sequential, it will only happen on the clock or reset
		if (reset == 1) begin
//			$readmemb("instructionmemory.list", instruction_memory);
			
			for (dataloopcount = 0; dataloopcount < 128; dataloopcount = dataloopcount +1) begin
				data_memory[dataloopcount] = 0;
			end
	
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
