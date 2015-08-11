module fetch(	clock,
				reset, 
				instruction_rd1, 
				instruction_rd1_out, 
				fetchoutput,
				pcchange, 
				pclocation,
				pcjumpenable, 
				previous_programcounter,
				flush
				);

	output [19:00]instruction_rd1;
	output [31:00]fetchoutput;
	output [19:00]previous_programcounter;

	input clock;
	input reset;
	input [15:00]instruction_rd1_out;
	
	input [08:00]pcchange;
	input [05:00]pclocation;
	input [02:00]pcjumpenable;

	input flush;

	wire clock;
	wire reset;

	wire [31:00] fetchoutput;

	reg [15:00] fetch1;
	reg [15:00] fetch2;

	wire [15:00] instruction_rd1_out;
	wire [19:00] instruction_rd1;

	reg [19:00]programcounter;
	reg [19:00]previous_programcounter;

	assign fetchoutput [31:16] = fetch1;
	assign fetchoutput [15:00] = fetch2;

	assign instruction_rd1 = programcounter;		

	always @(posedge clock) begin 				// ????????????????????????

			if (reset == 1) begin
				programcounter = 0;
			end

			else begin		

				if (pcjumpenable == 1) begin 										//Relative Branch
					if (programcounter == previous_programcounter + pcchange -1) begin
					//	programcounter = programcounter + 1; 				will cause to loop i think
						fetch1 = fetch2;
						fetch2[07:00] = instruction_rd1_out[15:08];
						fetch2[15:08] = instruction_rd1_out[07:00];				end
					else begin
						programcounter = programcounter + pcchange - 1;		
						fetch1 = 0000000000000001;
						fetch2 = 0000000000000001;
					end
				end

				if (pcjumpenable == 2) begin 										//Absolute Jump
					if (programcounter == pclocation) begin
						fetch1 = 0;
						fetch2[07:00] = instruction_rd1_out[15:08];
						fetch2[15:08] = instruction_rd1_out[07:00];
					end
					else begin	
						programcounter = pclocation;
						fetch1 = 0000000000000001;
						fetch2 = 0000000000000001;
					end
				end

				if (pcjumpenable == 3) begin 										//Absolute Jump and Link
					if (programcounter == pclocation) begin
						fetch1 = 0;
						fetch2[07:00] = instruction_rd1_out[15:08];
						fetch2[15:08] = instruction_rd1_out[07:00];
					end
					else begin	
						programcounter = pclocation;
						fetch1 = 0000000000000001;
						fetch2 = 0000000000000001;
					end
				end

				if (pcjumpenable == 4) begin 										//Relative branch and Link
					if (programcounter == previous_programcounter + pcchange - 1) begin
						fetch1 = fetch2;
						fetch2[07:00] = instruction_rd1_out[15:08];
						fetch2[15:08] = instruction_rd1_out[07:00];
					end
					else begin
						programcounter = programcounter + pcchange - 1;		
						fetch1 = 0;
						fetch2 = 0;
					end
				end
				
				if (pcjumpenable == 0) begin 										//Else increment program counter
					programcounter = programcounter + 1;
					fetch1 = fetch2;
					fetch2[07:00] = instruction_rd1_out[15:08];
					fetch2[15:08] = instruction_rd1_out[07:00];
					previous_programcounter = programcounter;			
				end

				if (flush == 1) begin 												
					fetch1 = 0000000000000001; 	
				end

			end
	
	end
	
endmodule