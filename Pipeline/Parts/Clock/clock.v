module TheClock;
	
		reg clock;
	
		always begin
			#1 clock = ~clock;
		end
		
endmodule