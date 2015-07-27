module TheInstructionMemory (clock, reset, instruction_rd1, instruction_rd2, instruction_rd3, instruction_rd4, instruction_wr1, instruction_wr2, instruction_wr3, instruction_wr4, instruction_wr1_data, instruction_wr2_data, instruction_wr3_data, instruction_wr4_data, instruction_wr1_enable, instruction_wr2_enable, instruction_wr3_enable, instruction_wr4_enable, instruction_rd1_out, instruction_rd2_out, instruction_rd3_out, instruction_rd4_out);
	
	input clock;
	input reset;


// This register has five ports: three read, two write

// read inputs and outputs //


	input  [19:00] instruction_rd1; 	                            //Which register to read from
	input  [19:00] instruction_rd2;		                            //20 bits wide because we have up to 1048576 data
	input  [19:00] instruction_rd3;
	input  [19:00] instruction_rd4;				

	output [15:00] instruction_rd1_out;                         	//What is in that register
	output [15:00] instruction_rd2_out;
	output [15:00] instruction_rd3_out;
	output [15:00] instruction_rd4_out;

// write inputs and outputs //
	
	input  [19:00] instruction_wr1;	                               	//Where to write, which register
	input  [19:00] instruction_wr2;
	input  [19:00] instruction_wr3;	                               	//Where to write, which register
	input  [19:00] instruction_wr4;

	input  [15:00] instruction_wr1_data;	                        //What to write
	input  [15:00] instruction_wr2_data;
	input  [15:00] instruction_wr3_data;	                        //What to write
	input  [15:00] instruction_wr4_data;

	input          instruction_wr1_enable;		                    //Should it write
	input 		   instruction_wr2_enable;
	input          instruction_wr3_enable;		                    //Should it write
	input 		   instruction_wr4_enable;

// Other output //


// Registers //
	
	reg [15:00] instruction_memory [1048575:00]; 

// Read logic //
	
	assign rd1_out = instruction_memory[rd1];                       //this is combinatoral, this happens automatically
	assign rd2_out = instruction_memory[rd2];
	assign rd3_out = instruction_memory[rd3];
	assign rd4_out = instruction_memory[rd4];

// Write logic //

	always @(posedge clock or posedge reset) begin                  // this is sequential, it will only happen on the clock or reset
		if (reset) begin 	                                        // Reset all Registers
			instruction_memory[0] = 0;
		end
		else begin
		
			if (instruction_wr1_enable == 1) begin
				instruction_memory[instruction_wr1] = instruction_wr1_data;
			end

			if (instruction_wr2_enable == 1) begin
				instruction_memory[instruction_wr2] = instruction_wr2_data;
			end

			if (instruction_wr3_enable == 1) begin
				instruction_memory[instruction_wr3] = instruction_wr3_data;
			end

			if (instruction_wr4_enable == 1) begin
				instruction_memory[instruction_wr4] = instruction_wr4_data;
			end
		end
	end

endmodule