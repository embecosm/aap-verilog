module sixteenbitdecoder(
	CLOCK_50,);
	
	input CLOCK_50;
	
	reg [09:00] clock_divider_counter;
	reg speedy_clock;
	reg opcode;
	reg operation;
	reg [7:0] slices_memory [0:63];

		always @(posedge CLOCK_50) begin
	//		if (reset == 1'b1) // reset if reset button hit
	//			clock_divider_counter <= 0;
			if (clock_divider_counter == 217) // reset if too high
				clock_divider_counter <= 0;
			else
				clock_divider_counter <= clock_divider_counter + 1;
		end

		always @(posedge CLOCK_50) begin
	//		if (reset == 1'b1)
	//			speedy_clock <= 0;
			if(clock_divider_counter == 217)
				speedy_clock <= ~speedy_clock;
		end
endmodule

module selector (fetchoutput, opcode, speedy_clock);
// Inputs & Putputs //

	input fetchoutput
	input opcode
	input speedy_clock

// Wire Declarations //

	wire [15:00] fetchoutput;

///////////////////////////////////
	
/*	fetchoutput[01:07] = opcode; */

										  
	always @(posedge speedy_clock) begin
	//		slices_memory[0b:"opcode"]= operation;
			fetchoutput [01:07] = opcode;				// the register of opcode becomes
																// the value given by the first 6
																// digits
	end
endmodule
	
	