module TheClock;
	
		reg clock;
	
		always begin
			#1 clock = ~clock;
		end
		
		initial clock = 1;

		
endmodule