/*module fetch (fetchoutput);
	
	
/*	reg fetchoutput [15:00] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1}; */
/*	wire fetchoutput [15:00];
	assign fetchoutput [15:00] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
	
	output fetchoutput[15:00];
	
	
endmodule	
*/

//	always @(posedge speedy_clock)
//			fetchoutput <= 

module clock(CLOCK_50);
	
	initial begin
		CLOCK_50_REG = 1;
	end
	
	output CLOCK_50;

	wire CLOCK_50;
	
	reg CLOCK_50_REG;
	
	assign CLOCK_50 = CLOCK_50_REG;
//	assign CLOCK_50_REG = CLOCK_50;
	
	always begin
	  #5 CLOCK_50_REG = ~CLOCK_50_REG;
	end
	
endmodule

module SpeedClock(
	CLOCK_50);
	
	input CLOCK_50;
	
	reg [09:00] clock_divider_counter;
	reg speedy_clock;

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

module sixteenbitdecoder(fetchoutput, speedy_clock);

// Inputs & Putputs //

	input [00:15]fetchoutput;
	input speedy_clock;
	
// Registers //	
	
	reg [09:00] clock_divider_counter;
	reg destination;
	reg source_1;
	reg source_2;
	reg unsigned_immediate;
	reg operation;
	reg [7:0] slices_memory[00:63];

// Wire Declarations //
	wire [06:00] opcode;
	wire [00:15] fetchoutput;
	
///////////////////////////////////
	assign opcode[06:00] = fetchoutput[01:07];
/*	fetchoutput[01:07] = opcode; */

										  
	always @(posedge speedy_clock) begin
			//slices_memory[8'b<opcode>] = operation;
			/*fetchoutput[01:07] = opcode;*/				// the register of opcode becomes
//			[06:00]opcode = [01:07]fetchoutput;			// the value given by the first 6
																	// digits
	end
	
	
	
	
	
	
endmodule


////////////////////////////////////
// Testbench
////////////////////////////////////

module testbench (speedy_clock);

	input speedy_clock;
	
	initial begin
	   $dumpfile("test.vcd");
		$display($time,"speedy_clock changed to %d", speedy_clock);	
	   $dumpvars(0,testbench, sixteenbitdecoder, SpeedClock, clock);
	   $monitor($time,"speedy_clock is now %d", speedy_clock);
		#1;
		$monitor($time,"speedy_clock is now %d", speedy_clock);
		#1;
		$monitor($time,"speedy_clock is now %d", speedy_clock);
		#1;
		$monitor($time,"speedy_clock is now %d", speedy_clock);
		#100;
		$finish;
	end

endmodule // testbench
