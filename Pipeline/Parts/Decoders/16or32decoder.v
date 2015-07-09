module sixteenbitdecoder(fetchoutput, speedy_clock);

// Registers //	
	reg [09:00] clock_divider_counter;
	reg opcode;
	reg operation;
	reg [7:0] slices_memory [0:63];
	reg [02:00] destination;
	reg [02:00] source_1;
	reg [02:00] source_2;
	reg [02:00] unsigned_1;
	reg [05:00] unsigned_2;
	reg [08:00] unsigned_3;
	
	
// Inputs & Putputs //

	input fetchoutput;
	input speedy_clock;

// Wire Declarations //

	wire [15:00] fetchoutput;
	wire bit_check;

///////////////////////////////////
	
	assign bit_check = fetchoutput[00]; 
	
/*	fetchoutput[01:07] = opcode; */

										  
	always @(posedge speedy_clock) begin
	
		if (bit_check == 0) begin
			slices_memory["0b:opcode"]= operation;
			/*fetchoutput[01:07] = opcode;*/				
			opcode = fetchoutput[01:07];	
			destination = fetchoutput[08:10];
			source_1 = fetchoutput [11:13];
			source_2 = fetchoutput [14:16];
			unsigned_1 = fetchoutput[14:16];
			unsigned_2 = fetchoutput [11:16];
			unsigned_3 = fetchoutput [08:16];
			
		end	
		
		else if (bit_check == 1) begin					
			
		end							
	end
	
endmodule
