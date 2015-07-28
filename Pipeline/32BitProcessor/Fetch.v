module fetch(	clock, 
				instruction_rd1, 
				instruction_rd1_out, 
				fetchoutput, pcchange, 
				pcjumpenable, pclocation, 
				previous_programcounter,
				flush
				);

	output [19:00]instruction_rd1;
	output [31:00]fetchoutput;
	output [19:00]previous_programcounter;

	input clock;
	input [15:00]instruction_rd1_out;
	
	input [08:00]pcchange;
	input [02:00]pcjumpenable;
	input [02:00]pclocation;

	input flush;

	wire clock;

	wire [31:00] fetchoutput;
	reg [15:00] fetch1;
	reg [15:00] fetch2;

	assign fetchoutput [31:16] = fetch1;
	assign fetchoutput [15:00] = fetch2;

	wire [15:00] instruction_rd1_out;

	wire [19:00] instruction_rd1;

	reg [19:00]programcounter;
	reg [19:00]previous_programcounter;

	assign instruction_rd1 = programcounter;		


	always @(posedge clock) begin

		fetch1 = fetch2;
		fetch2 = instruction_rd1_out;
		previous_programcounter = programcounter;

		if (pcjumpenable == 0) begin
			programcounter <= programcounter + 1;
		end

		if (pcjumpenable == 1) begin
			programcounter <= programcounter + pcchange;
		end

		if (pcjumpenable == 2) begin
			programcounter <= pclocation;
		end

		if (flush == 1) begin
			fetch1 = 0000000000000000;
		end



		
	end

/*
	if (instructionlength_check == 0) begin	

		if (bit_check == 0)
			assign fetchoutput = instruction_rd1_out;	

		if (bit_check == 1) begin
			assign instructionwait = instruction_rd1_out;
			assign instructionlength_check = 1;		
		end
	
	end

	if (instructionlength_check == 1) begin
			
		if (bit_check == 0) begin
			assign fetchoutput[31:16] = instructionwait;
			assign fetchoutput[15:00] = instruction_rd1_out;
		end
	
	end
*/
	initial programcounter = 0;
	
endmodule
