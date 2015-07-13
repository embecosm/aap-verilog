module sixteenbitdecoder(fetchoutput, clock);

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
	
// Memory write //
	
	initial begin
 		$readmemb("opcodemem.list", opcodemem);
  	end
		
// Inputs & Putputs //

	input [15:00]fetchoutput;
	input clock;

// Wire Declarations //

	wire [15:00] fetchoutput;
	wire         bit_check;

///////////////////////////////////
	
	assign bit_check = fetchoutput[15]; 
	
/*	fetchoutput[01:07] = opcode; */

										  
	always @(posedge clock) begin
		if (bit_check == 0) begin
			slices_memory["0b:opcode"]= operation;
			/*fetchoutput[01:07] = opcode;*/				
			assign opcode      = fetchoutput [14:09];	
			assign destination = fetchoutput [08:06];
			assign source_1    = fetchoutput [05:03];
			assign source_2    = fetchoutput [02:00];
			assign unsigned_1  = fetchoutput [02:00];
			assign unsigned_2  = fetchoutput [05:00];
			assign unsigned_3  = fetchoutput [08:00];
			 operationnumber=opcodemem[opcode];

	end	
		
		else if (bit_check == 1) begin					
			
		end							
	end
	
endmodule

module sixteenbitdecoder_tb;
    
    reg           clock;
    wire [15:00]  fetchoutput;
    reg           operationnumber;
    reg		  opcodemem;

    sixteenbitdecoder sixteenbbitdecoder_test (fetchoutput[15:00], clock);
    fetch fetch_test (fetchoutput[15:00]);

    always begin
        #1 clock = ~clock;
    end

    initial begin
        clock = 1;
    end

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
    
    initial fetchvalue = 21845;
    
    assign fetchoutput = fetchvalue;

endmodule
