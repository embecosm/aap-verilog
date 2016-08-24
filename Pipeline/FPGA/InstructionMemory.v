module TheInstructionMemory (	clock,
										reset,
										instruction_rd1,
										instruction_wr1,
										instruction_wr1_data,
										instruction_wr1_enable,
										instruction_rd1_out,										
										instruction_rd2,
										instruction_wr2,
										instruction_wr2_data,
										instruction_wr2_enable,
										instruction_rd2_out
									);
	
	input clock;
	input reset;

// This register has eight ports: four read, four Write 			?????????????????????

// read inputs and outputs //

	input  [05:00] instruction_rd1; 	                            //Which register to read from
	input  [05:00] instruction_rd2;		                            //20 bits wide because we have up to 1048576 data
//	input  [05:00] instruction_rd3;
//	input  [05:00] instruction_rd4;				

	output [15:00] instruction_rd1_out;                         	//What is in that register
	output [15:00] instruction_rd2_out;
//	output [15:00] instruction_rd3_out;
//	output [15:00] instruction_rd4_out;

// write inputs and outputs //
	
	input  [05:00] instruction_wr1;	                               	//Where to write, which register
	input  [05:00] instruction_wr2;
//	input  [05:00] instruction_wr3;	                               	//Where to write, which register
//	input  [05:00] instruction_wr4;

	input  [15:00] instruction_wr1_data;	                        //What to write
	input  [15:00] instruction_wr2_data;
//	input  [15:00] instruction_wr3_data;	                        //What to write
//	input  [15:00] instruction_wr4_data;

	input          instruction_wr1_enable;		                    //Should it write
	input 		   instruction_wr2_enable;
//	input          instruction_wr3_enable;		                    //Should it write
//	input 		   instruction_wr4_enable;

// Integers //
	
	reg [19:00]instructionloopcount;

// Registers //
	
	reg [15:00] instruction_memory [63:00]; 

// Read logic //
	
	assign instruction_rd1_out = instruction_memory[instruction_rd1];                       //this is combinatoral, this happens automatically
	assign instruction_rd2_out = instruction_memory[instruction_rd2];
//	assign instruction_rd3_out = instruction_memory[instruction_rd3];
//	assign instruction_rd4_out = instruction_memory[instruction_rd4];

// Write logic //

	always @(posedge clock or posedge reset) begin                  // this is sequential, it will only happen on the clock or reset
		
		if (reset == 1) begin
//			$readmemb("instructionmemory.list", instruction_memory);
			
			for (instructionloopcount = 0; instructionloopcount < 64; instructionloopcount = instructionloopcount +1) begin
				instruction_memory[instructionloopcount] = 1 /*64*/;
			end
	
		end
		else begin
		
			if (instruction_wr1_enable == 1) begin
				instruction_memory[instruction_wr1] = instruction_wr1_data;
			end

			if (instruction_wr2_enable == 1) begin
				instruction_memory[instruction_wr2] = instruction_wr2_data;
			end

//			if (instruction_wr3_enable == 1) begin
//				instruction_memory[instruction_wr3] = instruction_wr3_data;
//			end

//			if (instruction_wr4_enable == 1) begin
//				instruction_memory[instruction_wr4] = instruction_wr4_data;
//			end
		end
	end

endmodule