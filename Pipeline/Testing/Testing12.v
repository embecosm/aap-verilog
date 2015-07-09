/*module fetch (clock ,fetchoutput);
	
	output fetchoutput;
	input clock;
	reg fetchvalue;
	assign fetchvalue = 16'b1;
	assign fetchoutput = fetchvalue;
//	reg fetchoutput [15:00] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1}; 
	wire fetchoutput [15:00];
//	assign fetchoutput [15:00] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
	
	
	
	
endmodule	
*/

module fetch (fetchoutput, clock);

	input clock;
	output [15:00]fetchoutput;
	
	wire  [15:00]fetchoutput;
	reg [15:00]fetchvalue;
	
	assign fetchoutput = fetchvalue;
	
/*	always @ (posedge clock) begin
		fetchvalue <= fetchvalue + 1;
	end
*/

	initial fetchvalue = 21845;
	
endmodule	

//	always @(posedge speedy_clock)
//			fetchoutput <= 
/*
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

*/

module SpeedClock(
	speedy_clock);

	wire CLOCK_50;
	
	reg CLOCK_50_REG;
	
	assign CLOCK_50 = CLOCK_50_REG;
	
	always begin
		#1 CLOCK_50_REG = ~CLOCK_50_REG;
	end

	output speedy_clock;
	
	
	
	initial begin	
		//CLOCK_50 = 1;
		CLOCK_50_REG = 1;
		speedy_clock = 1;
		clock_divider_counter = 1;
	end
	
	reg [09:00] clock_divider_counter;
	reg speedy_clock;
	
		always @(posedge CLOCK_50) begin
	//		if (reset == 1'b1) // reset if reset button hit
	//			clock_divider_counter <= 0;
			if (clock_divider_counter == 217) // reset if too high
				clock_divider_counter <= 0;
			else
				clock_divider_counter <= clock_divider_counter + 1;
				speedy_clock <= ~speedy_clock;
		end
/*
		always @(posedge CLOCK_50) begin
	//		if (reset == 1'b1)
	//			speedy_clock <= 0;
			if(clock_divider_counter == 217)
		
		end
*/				
endmodule

module sixteenbitdecoder(fetchoutput[15:00], clock);

// Inputs & Putputs //

	input [15:00]fetchoutput;
	input clock;
	
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
	
//	wire [15:00] fetchoutput;

	wire clock;
	
	
// Initials //
	
///////////////////////////////////
	assign opcode[06:00] = fetchoutput[07:01];
	
/*	fetchoutput[01:07] = opcode; */

										  
	always @(posedge clock) begin
			//slices_memory[8'b<opcode>] = operation;
			/*fetchoutput[01:07] = opcode;*/				// the register of opcode becomes
//			[06:00]opcode = [01:07]fetchoutput;			// the value given by the first 6
																	// digits
	end
	
	
	
	
	
	
endmodule


////////////////////////////////////
// Testbench
////////////////////////////////////

module testbench ();
		
	reg clock;
	
	always begin
	  #1 clock = ~clock;
	end	
	
	initial begin
	   $dumpfile("test.vcd");
	   $dumpvars(0, clock, testbench, SpeedClock);
		#10000;
		$finish;
	end
		
	initial clock = 1;
	
	sixteenbitdecoder sixteenbitdecoder_test(fetchoutput, clock);
	fetch fetch_test (fetchoutput, clock);
	
endmodule // testbench
