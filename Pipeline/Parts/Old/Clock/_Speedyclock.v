module SpeedClock(
	CLOCK_50,);
	
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