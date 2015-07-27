module execution (	clock, 
					operationnumber,
					destination,
					source_1,
					source_2,
					unsigned_1,
					unsigned_2,
					unsigned_3,
					rd1,
					rd2, 
					rd3, 
					wr1, 
					wr2, 
					wr1_data, 
					wr2_data, 
					wr1_enable, 
					wr2_enable, 
					rd1_out, 
					rd2_out, 
					rd3_out
					);
	
	input clock;
	input [05:00]operationnumber;
	input [02:00]destination; 
	input [02:00]source_2;
	input [02:00]source_1;
	input [08:00]unsigned_3;
	input [05:00]unsigned_2;
	input [02:00]unsigned_1;

	input [15:00]rd1_out;
	input [15:00]rd2_out;
	input [15:00]rd3_out;

	output [01:00]wr1;
	output [01:00]wr2;
	output wr1_enable;
	output wr2_enable;
	output [15:00]wr1_data;
	output [15:00]wr2_data;

	output [05:00]rd1;
	output [05:00]rd2;
	output [05:00]rd3;

	// input [63:00]register;

	reg [01:00]wr1;
	reg [01:00]wr2;
	reg wr1_enable;
	reg wr2_enable;
	reg [15:00] wr1_data;
	reg [15:00] wr2_data;
	wire [05:00] operationnumber;

	reg [05:00]rd1;
	reg [05:00]rd2;
	reg [05:00]rd3;

	wire [02:00] destination;	

	always @(posedge clock) begin

		wr1_enable = 0;
		wr2_enable = 0;
		
		if (operationnumber == 0) begin 	//no operation
			
		end
		
		if (operationnumber == 1) begin 	//unsigned add			
			wr1 = destination;
			wr1_data = source_1 + source_2; // it's just adding the two values...
			wr1_enable = 1;

		end

		if (operationnumber == 2) begin 	//unsigned subtract
			wr1 = destination;
			wr1_data = source_1 - source_2;
			wr1_enable = 1;
			
		end

		if (operationnumber == 3) begin 	//bitwise AND 
			wr1 = destination;
			wr1_data = source_1 & source_2;
			wr1_enable = 1;
			
		end

		if (operationnumber == 4) begin 	//bitwise OR
			wr1 = destination;
			wr1_data = source_1 | source_2;
			wr1_enable = 1;
			
		end

		if (operationnumber == 5) begin 	//bitwise exclusive OR
			wr1 = destination;
			wr1_data = source_1 ^ source_2;
			wr1_enable = 1;
			
		end

		if (operationnumber == 6) begin 	// arithmetic shift right
			wr1 = destination;
			wr1_data = source_1 >>> source_2;
			wr1_enable = 1;
			
		end

		if (operationnumber == 7) begin 	// Logical left shift
			wr1 = destination;
			wr1_data = source_1 << source_2;
			wr1_enable = 1;
			
		end

		if (operationnumber == 8) begin 	// Logical right shift
			wr1 = destination;
			wr1_data = source_1 >> source_2;
			wr1_enable = 1;
			
		end

		if (operationnumber == 9) begin 	// move register to register
			
		end

		if (operationnumber == 10) begin 	//unsigned add immediate
			wr1 = destination;
			wr1_data = source_1 + unsigned_1;
			wr1_enable = 1;
			
		end

		if (operationnumber == 11) begin 	//unsigned subtract immediate
			wr1 = destination;
			wr1_data = source_1 - unsigned_1;
			wr1_enable = 1;
			
		end

		if (operationnumber == 12) begin 	//arithmetic shift right immediate
			wr1 = destination;
			wr1_data = source_1 >>> unsigned_1;
			wr1_enable = 1;
			
		end

		if (operationnumber == 13) begin 	//logical shift left immediate
			wr1 = destination;
			wr1_data = source_1 << unsigned_1;
			wr1_enable = 1;
			
		end

		if (operationnumber == 14) begin 	//logical shift right immediate
			wr1 = destination;
			wr1_data = source_1 >> unsigned_1;
			wr1_enable = 1;
			
		end

		if (operationnumber == 15) begin 	//Move immeidate to register
			wr1 = destination;
			wr1_data = unsigned_2;
			wr1_enable = 1;
		end

		if (operationnumber == 16) begin 	//indexed load byte
			wr1 = destination;
			wr1_data[07:00] = unsigned_1;
			wr1_data[15:08] = 0;
			wr1_enable = 1;
		end
		if (operationnumber == 17) begin 	//indexed load word
			wr1 = destination;
			wr1_data = unsigned_2;
			wr1_enable = 1;
		end


	end
endmodule