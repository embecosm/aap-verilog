module execution (	clock, 
					operationnumber,
					destination,
					source_1,
					source_2,
					unsigned_1,
					unsigned_2,
					unsigned_3,
					reg_rd1,
					reg_rd2, 
					reg_rd3, 
					reg_wr1, 
					reg_wr2, 
					reg_wr1_data, 
					reg_wr2_data, 
					reg_wr1_enable, 
					reg_wr2_enable, 
					reg_rd1_out, 
					reg_rd2_out, 
					reg_rd3_out
					);
	
	input clock;
	input [05:00]operationnumber;
	input [02:00]destination; 
	input [02:00]source_2;
	input [02:00]source_1;
	input [08:00]unsigned_3;
	input [05:00]unsigned_2;
	input [02:00]unsigned_1;

	input [15:00]reg_rd1_out;
	input [15:00]reg_rd2_out;
	input [15:00]reg_rd3_out;

	output [01:00]reg_wr1;
	output [01:00]reg_wr2;
	output reg_wr1_enable;
	output reg_wr2_enable;
	output [15:00]reg_wr1_data;
	output [15:00]reg_wr2_data;

	output [05:00]reg_rd1;
	output [05:00]reg_rd2;
	output [05:00]reg_rd3;

	// input [63:00]register;

	reg [01:00]reg_wr1;
	reg [01:00]reg_wr2;
	reg reg_wr1_enable;
	reg reg_wr2_enable;
	reg [15:00] reg_wr1_data;
	reg [15:00] reg_wr2_data;
	wire [05:00] operationnumber;

	reg [05:00]reg_rd1;
	reg [05:00]reg_rd2;
	reg [05:00]reg_rd3;

	wire [02:00] destination;	

	always @(posedge clock) begin

		reg_wr1_enable = 0;
		reg_wr2_enable = 0;
		
		if (operationnumber == 0) begin 	//no operation
			
		end
		
		if (operationnumber == 1) begin 	//unsigned add			
			reg_wr1 = destination;
			reg_wr1_data = source_1 + source_2; // it's just adding the two values...
			reg_wr1_enable = 1;

		end

		if (operationnumber == 2) begin 	//unsigned subtract
			reg_wr1 = destination;
			reg_wr1_data = source_1 - source_2;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 3) begin 	//bitwise AND 
			reg_wr1 = destination;
			reg_wr1_data = source_1 & source_2;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 4) begin 	//bitwise OR
			reg_wr1 = destination;
			reg_wr1_data = source_1 | source_2;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 5) begin 	//bitwise exclusive OR
			reg_wr1 = destination;
			reg_wr1_data = source_1 ^ source_2;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 6) begin 	// arithmetic shift right
			reg_wr1 = destination;
			reg_wr1_data = source_1 >>> source_2;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 7) begin 	// Logical left shift
			reg_wr1 = destination;
			reg_wr1_data = source_1 << source_2;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 8) begin 	// Logical right shift
			reg_wr1 = destination;
			reg_wr1_data = source_1 >> source_2;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 9) begin 	// move register to register
			
		end

		if (operationnumber == 10) begin 	//unsigned add immediate
			reg_wr1 = destination;
			reg_wr1_data = source_1 + unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 11) begin 	//unsigned subtract immediate
			reg_wr1 = destination;
			reg_wr1_data = source_1 - unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 12) begin 	//arithmetic shift right immediate
			reg_wr1 = destination;
			reg_wr1_data = source_1 >>> unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 13) begin 	//logical shift left immediate
			reg_wr1 = destination;
			reg_wr1_data = source_1 << unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 14) begin 	//logical shift right immediate
			reg_wr1 = destination;
			reg_wr1_data = source_1 >> unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 15) begin 	//Move immeidate to register
			reg_wr1 = destination;
			reg_wr1_data = unsigned_2;
			reg_wr1_enable = 1;
		end

		if (operationnumber == 16) begin 	//indexed load byte
			reg_wr1 = destination;
			reg_wr1_data[07:00] = unsigned_1;
			reg_wr1_data[15:08] = 0;
			reg_wr1_enable = 1;
		end
		if (operationnumber == 17) begin 	//indexed load word
			reg_wr1 = destination;
			reg_wr1_data = unsigned_2;
			reg_wr1_enable = 1;
		end


	end
endmodule