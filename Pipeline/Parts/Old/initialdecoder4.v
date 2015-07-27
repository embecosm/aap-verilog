module sixteenbitdecoder(fetchoutput, opcode, speedy_clock);

// Registers //	
	reg [09:00] clock_divider_counter;
	reg opcode;
	reg operation;
	reg [7:0] slices_memory [0:63];

// Inputs & Putputs //

	input fetchoutput;
	input speedy_clock;

// Wire Declarations //

	wire [15:00] fetchoutput;

///////////////////////////////////
	
/*	fetchoutput[01:07] = opcode; */

										  
	always @(posedge speedy_clock) begin
			slices_memory[0b:'opcode']= operation;
			fetchoutput [01:07] = opcode;				// the register of opcode becomes															// the value given by the first 6														// digits
	end
	
endmodule
	
	