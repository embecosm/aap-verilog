module sixteenbitdecoder(fetchoutput, clock);

// Registers //	
	reg [09:00] clock_divider_counter;
	reg         opcode;
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
			operationnumber[05:00]=opcodemem[opcode];
/*
			case (opcode) 
				0 :operationnumber =  'b0;
				1 :operationnumber =  'b1;
				2 :operationnumber =  'b10;
				3 :operationnumber =  'b11;
				4 :operationnumber =  'b100;
				5 :operationnumber =  'b101;
				6 :operationnumber =  'b110;
				7 :operationnumber =  'b111;
				8 :operationnumber =  'b1000;
				9 :operationnumber =  'b1001;
				10:operationnumber =  'b1010;
				11:operationnumber =  'b1011;
				12:operationnumber =  'b1100;
				13:operationnumber =  'b1101;
				14:operationnumber =  'b1110;
				15:operationnumber =  'b1111;
				16:operationnumber =  'b10000;
				17:operationnumber =  'b10001;
				18:operationnumber =  'b10010;
				19:operationnumber =  'b10011;
				20:operationnumber =  'b10100;
				21:operationnumber =  'b10101;
				22:operationnumber =  'b10110;
				23:operationnumber =  'b10111;
				24:operationnumber =  'b11000;
				25:operationnumber =  'b11001;
				26:operationnumber =  'b11010;
				27:operationnumber =  'b11011;
				28:operationnumber =  'b11100;
				29:operationnumber =  'b11101;
				30:operationnumber =  'b11110;
				31:operationnumber =  'b11111;
				32:operationnumber =  'b100000;
				33:operationnumber =  'b100001;
				34:operationnumber =  'b100010;
				35:operationnumber =  'b100011;
				36:operationnumber =  'b100100;
				37:operationnumber =  'b100101;
				38:operationnumber =  'b100110;
				39:operationnumber =  'b100111;
				40:operationnumber =  'b101000;
				41:operationnumber =  'b101001;
				42:operationnumber =  'b101010;
				43:operationnumber =  'b101011;
				44:operationnumber =  'b101100;
				45:operationnumber =  'b101101;
				46:operationnumber =  'b101110;
				47:operationnumber =  'b101111;
				48:operationnumber =  'b110000;
				49:operationnumber =  'b110001;
				50:operationnumber =  'b110010;
				51:operationnumber =  'b110011;
				52:operationnumber =  'b110100;
				53:operationnumber =  'b110101;
				54:operationnumber =  'b110110;
				55:operationnumber =  'b110111;
				56:operationnumber =  'b111000;
				57:operationnumber =  'b111001;
				58:operationnumber =  'b111010;
				59:operationnumber =  'b111011;
				60:operationnumber =  'b111100;
				61:operationnumber =  'b111101;
				62:operationnumber =  'b111110;
				064:operationnumber = 'b1000000;
				065:operationnumber = 'b1000001;
				066:operationnumber = 'b1000010;
				067:operationnumber = 'b1000011;
				068:operationnumber = 'b1000100;
				069:operationnumber = 'b1000101;
				070:operationnumber = 'b1000110;
				071:operationnumber = 'b1000111;
				072:operationnumber = 'b1001000;
				073:operationnumber = 'b1001001;
				074:operationnumber = 'b1001010;
				075:operationnumber = 'b1001011;
				076:operationnumber = 'b1001100;
				077:operationnumber = 'b1001101;
				078:operationnumber = 'b1001110;
				079:operationnumber = 'b1001111;
				080:operationnumber = 'b1010000;
				081:operationnumber = 'b1010001;
				082:operationnumber = 'b1010010;
				083:operationnumber = 'b1010011;
				084:operationnumber = 'b1010100;
				085:operationnumber = 'b1010101;
				086:operationnumber = 'b1010110;
				087:operationnumber = 'b1010111;
				088:operationnumber = 'b1011000;
				089:operationnumber = 'b1011001;
				090:operationnumber = 'b1011010;
				091:operationnumber = 'b1011011;
				092:operationnumber = 'b1011100;
				093:operationnumber = 'b1011101;
				094:operationnumber = 'b1011110;
				095:operationnumber = 'b1011111;
				096:operationnumber = 'b1100000;
				097:operationnumber = 'b1100001;
				098:operationnumber = 'b1100010;
				099:operationnumber = 'b1100011;
				100:operationnumber = 'b1100100;
				101:operationnumber = 'b1100101;
				102:operationnumber = 'b1100110;
				103:operationnumber = 'b1100111;
				104:operationnumber = 'b1101000;
				105:operationnumber = 'b1101001;
				106:operationnumber = 'b1101010;
				107:operationnumber = 'b1101011;
				108:operationnumber = 'b1101100;
				109:operationnumber = 'b1101101;
				110:operationnumber = 'b1101110;
				111:operationnumber = 'b1101111;
				112:operationnumber = 'b1110000;
				113:operationnumber = 'b1110001;
				114:operationnumber = 'b1110010;
				115:operationnumber = 'b1110011;
				116:operationnumber = 'b1110100;
				117:operationnumber = 'b1110101;
				118:operationnumber = 'b1110110;
				119:operationnumber = 'b1110111;
				120:operationnumber = 'b1111000;
				121:operationnumber = 'b1111001;
				122:operationnumber = 'b1111010;
				123:operationnumber = 'b1111011;
				124:operationnumber = 'b1111100;
				125:operationnumber = 'b1111101;
				126:operationnumber = 'b1111110;
				127:operationnumber = 'b1111111;
			endcase
*/		end	
		
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
