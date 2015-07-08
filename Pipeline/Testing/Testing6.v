/*module fetch (fetchoutput);
	
	
/*	reg fetchoutput [15:00] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1}; */
/*	wire fetchoutput [15:00];
	assign fetchoutput [15:00] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
	
	output fetchoutput[15:00];
	
	
endmodule	
*/

//	always @(posedge speedy_clock)
//			fetchoutput <= 

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
	reg [7:0] slices_memory [0:63];

// Wire Declarations //
	wire [00:06] opcode;
	wire [00:15] fetchoutput;
	
///////////////////////////////////
	assign opcode = fetchoutput[01:07];
/*	fetchoutput[01:07] = opcode; */

										  
	always @(posedge speedy_clock) begin
			slices_memory["0b:opcode"] = operation;
			/*fetchoutput[01:07] = opcode;*/				// the register of opcode becomes
//			[06:00]opcode = [01:07]fetchoutput;			// the value given by the first 6
																	// digits
	end
	
	
	
	
	
	
endmodule
	

	
module foo( clock, reset, enable, out);
	input clock;
	input enable;
	input reset;
	output [3:0] out;

	// Note all inputs should be wires, output can be wire or reg
	wire clock;
	wire enable;
	wire reset;
	reg [3:0] out;

	always @ (posedge clock) begin
	  if (reset == 1'b1) begin
		 out <= 4'b0000;
	  end

	  else if (enable == 1'b1) begin
		 out <= out + 1;
	  end
	end

endmodule // foo


////////////////////////////////////
// Testbench
////////////////////////////////////

module testbench();
	reg clock, reset, enable;
	wire [3:0] out;

	//Init
	initial begin
	  // Log
	  $monitor ("%g\t%b\t%b\t%b\t%b", $time, clock, reset, enable, out);
	  $dumpfile("test.vcd");
	  $dumpvars(clock, reset, enable, out);
	  clock = 1;
	  reset = 0;
	  enable = 0;
	  #5 reset = 1;
	  #10 reset = 0;
	  #10 enable = 1;
	  #100 enable = 0;
	  #5 $finish;
	end

	//Clkgen
	always begin
	  #5 clock = ~clock;
	end

	// Build foo
	foo myFoo (clock, reset, enable, out);

endmodule // testbench
