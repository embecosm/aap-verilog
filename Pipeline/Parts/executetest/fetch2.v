module fetch(clock, instruction_rd1, instruction_rd1_out, fetchoutput);

	output [19:00]instruction_rd1;
	output [15:00]fetchoutput;

	input clock;
	input [15:00]instruction_rd1_out;
	
	wire clock;

	wire [15:00] fetchoutput;
	wire [15:00] instruction_rd1_out;

	wire [19:00] instruction_rd1;

	reg [19:00]programcounter;

	always @(posedge clock) begin
		programcounter <= programcounter + 1;
	end

	assign instruction_rd1 = programcounter;	//finds the palce in memory that is equal to the value of programcounter
	assign fetchoutput = instruction_rd1_out;	// sets that as fetchoutput

	initial programcounter = 0;

endmodule


