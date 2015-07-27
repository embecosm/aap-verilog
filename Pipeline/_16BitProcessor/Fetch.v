module fetch(clock, instruction_rd1, instruction_rd1_out, fetchoutput, pcchange, pcjumpenable, pclocation, previous_programcounter);

	output [19:00]instruction_rd1;
	output [15:00]fetchoutput;
	output [19:00]previous_programcounter;

	input clock;
	input [15:00]instruction_rd1_out;
	
	input [08:00]pcchange;
	input [02:00]pcjumpenable;
	input [02:00]pclocation;

	wire clock;

	wire [15:00] fetchoutput;
	wire [15:00] instruction_rd1_out;

	wire [19:00] instruction_rd1;

	reg [19:00]programcounter;
	reg [19:00]previous_programcounter;

	always @(posedge clock) begin
		if (pcjumpenable == 0) begin
			programcounter <= programcounter + 1;
		end
		if (pcjumpenable == 1) begin
			programcounter <= programcounter + pcchange;
		end
		if (pcjumpenable == 2) begin
			programcounter <= pclocation;
		end

		previous_programcounter <= programcounter;

	end

	assign instruction_rd1 = programcounter;	//finds the palce in memory that is equal to the value of programcounter
	assign fetchoutput = instruction_rd1_out;	// sets that as fetchoutput

	initial programcounter = 0;
	
endmodule
