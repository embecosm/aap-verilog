module sixteenbitdecoder(fetchoutput);

// Registers //	
	reg [09:00] clock_divider_counter;
	reg [05:00] opcode;
	reg         operation;
	reg [07:00]   slices_memory [0:63];
	reg [02:00] destination;
	reg [02:00] source_1;
	reg [02:00] source_2;
	reg [02:00] unsigned_1;
	reg [05:00] unsigned_2;
	reg [08:00] unsigned_3;
	reg [05:00] operationnumber;
	reg [05:00] opcodemem [125:000];
	reg [02:00] destiantionmem [04:00];
	reg [02:00] source_1_mem [04:00];
	reg [02:00] source_2_mem [04:00];

	
// Memory write //
	
	initial begin
 		$readmemb("opcodemem.list", opcodemem);
  	end
		
// Inputs & Putputs //

	input [15:00]fetchoutput;

// Wire Declarations //

	wire [15:00] fetchoutput;
	wire         bit_check;

///////////////////////////////////
	
	assign bit_check = fetchoutput[15]; 
	
/*	fetchoutput[01:07] = opcode; */
	
	always @(fetchoutput) begin
			
			  
		if (bit_check == 0) begin
			//slices_memory["0b:opcode"]= operation;
			/*fetchoutput[01:07] = opcode;*/				
			opcode      	= fetchoutput 	[14:09];	
			destination 	= fetchoutput 	[08:06];
			source_1    	= fetchoutput 	[05:03];
			source_2    	= fetchoutput 	[02:00];
			unsigned_1  	= fetchoutput 	[02:00];
			unsigned_2  	= fetchoutput 	[05:00];
			unsigned_3  	= fetchoutput 	[08:00];
			operationnumber	= opcodemem		[opcode];	
		end	
	

		else if (bit_check == 1) begin					
	
		end
	end							

endmodule

module sixteenbitdecoder_tb;
    

    wire [15:00]  fetchoutput;
    reg           operationnumber;
    reg		  opcodemem;


    sixteenbitdecoder sixteenbbitdecoder_test (fetchoutput[15:00]);
    fetch fetch_test (fetchoutput[15:00]);

    initial begin 
        $dumpfile ("16or32bitdecoder.vcd");
        $dumpvars (0, sixteenbbitdecoder_test, fetch_test);
	#100
        $finish;
    end

endmodule

module fetch(fetchoutput[15:00]);
    
    output [15:00]fetchoutput;
    
    wire [15:00] fetchoutput;

    reg [15:00] fetchvalue;
    
  initial begin
	fetchvalue = 27323;
	#11
	fetchvalue = 27232+32768;
	#20 
	fetchvalue = 23727;
	#100
	$finish;

  end
    assign fetchoutput = fetchvalue;

endmodule
