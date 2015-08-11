module decoder(
				fetchoutput,
				destination, 
				operationnumber, 
				source_1, 
				source_2, 
				unsigned_1, 
				unsigned_2, 
				unsigned_3,
				unsigned_4,
				unsigned_5,
				signed_1,
				signed_2,
				signed_3,
				flush,
				super_duper_a,
				super_duper_b
				);

//	Inputs & Putputs //

	output [05:00]destination;

	output [05:00]operationnumber;

	output [05:00]source_1;
	output [05:00]source_2;

	output [05:00]unsigned_1;
	output [15:00]unsigned_2;
	output [08:00]unsigned_3;
	output [09:00]unsigned_4;
	output [08:00]unsigned_5;

	output [21:00]signed_1;
	output [15:00]signed_2;
	output [09:00]signed_3;

	output super_duper_a;
	output super_duper_b;

	output flush;

	input [31:00]fetchoutput;

	

	

// Registers //	
	reg [05:00] opcode;
	reg         operation;
	reg [05:00] destination;
	reg [05:00] source_1;
	reg [05:00] source_2;
	reg [05:00] unsigned_1;
	reg [15:00] unsigned_2;
	reg [08:00] unsigned_3;
	reg [09:00]	unsigned_4;
	reg [08:00] unsigned_5;
	reg [05:00] operationnumber;

	reg [21:00] signed_1;
	reg [15:00] signed_2;
	reg [09:00] signed_3;

	reg super_duper_a; // used for 32 bit instructions that cannot be different using operation number alone
	reg super_duper_b;
	
// Memory write //
	
		

// Wire Declarations //

	wire [31:00] 	fetchoutput;
	wire         	bit_check;
	wire 			flush;

///////////////////////////////////
	
	assign bit_check 	= 	fetchoutput[31];
	assign flush 		= 	bit_check;  
	
/*	fetchoutput[01:07] = opcode; */
	
	always @(fetchoutput) begin
			
			  
		if (bit_check == 0) begin				
			opcode      		= fetchoutput 	[30:25];	
			destination		 	= fetchoutput 	[24:22];
			source_1    		= fetchoutput 	[21:19];
			source_2    		= fetchoutput 	[18:16];
			unsigned_1  		= fetchoutput 	[18:16];
			unsigned_2  		= fetchoutput 	[21:16];
			unsigned_3  		= fetchoutput 	[24:16];
			signed_1			= fetchoutput 	[24:16];
			signed_2			= fetchoutput 	[24:16];
			signed_3			= fetchoutput	[24:16];
			operationnumber		= opcode;
			super_duper_a = 0;
			super_duper_b = 0;
		end	
	

		else if (bit_check == 1) begin	

			destination[02:00]	= fetchoutput	[24:22];
			destination[05:03]  = fetchoutput	[08:06];
			source_1[02:00]		= fetchoutput 	[21:19];
			source_1[05:03]		= fetchoutput	[05:03];
			source_2[02:00]		= fetchoutput 	[18:16];
			source_2[05:03]		= fetchoutput 	[02:00];
			unsigned_1[02:00]	= fetchoutput	[18:16];
			unsigned_1[05:03]	= fetchoutput	[02:00];
			unsigned_2[05:00]	= fetchoutput	[21:16];
			unsigned_2[09:06]	= fetchoutput	[12:09];
			unsigned_2[15:10]	= fetchoutput	[05:00];
			unsigned_4[02:00]	= fetchoutput	[18:16];
			unsigned_4[06:03]	= fetchoutput	[12:09];
			unsigned_4[09:07]	= fetchoutput	[02:00];
			unsigned_5[02:00]	= fetchoutput	[18:16];
			unsigned_5[05:03]	= fetchoutput	[12:08];
			unsigned_5[08:06]	= fetchoutput	[02:00];
			signed_1[08:00]		= fetchoutput	[24:16];
			signed_1[21:09]		= fetchoutput	[12:00];
			signed_2[02:00]		= fetchoutput	[24:22];
			signed_2[05:03]		= fetchoutput	[18:16];
			signed_2[12:06]		= fetchoutput	[12:06];
			signed_2[15:13]		= fetchoutput	[02:00];
			signed_3[02:00]		= fetchoutput	[24:22];
			signed_3[09:03]		= fetchoutput	[12:06];
			opcode      		= fetchoutput 	[30:25];
			operationnumber		= opcode;

			if (fetchoutput[15:09] !== 0) begin 	// for 32 bit commands that have the same operation code but extra criteria
				super_duper_a = 1;		
			end
			if (fetchoutput[9] !== 0) begin 		// for the b_itwise commands that need to be different
				super_duper_b = 1;
			end
			else begin
				super_duper_a = 0;
				super_duper_b = 0;
			end

		end
		
	end							

endmodule
