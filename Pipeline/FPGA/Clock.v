
module Clock (CLOCK_50, clock, LED);

	output clock;
	input CLOCK_50;
	output [7:0] LED;
	
	wire clock = CLOCK_50;

	wire [07:00] leds_out;
	
	assign LED[07:00] = leds_out;
	assign leds_out = 1;
	
endmodule
