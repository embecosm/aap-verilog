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
					reg_rd3_out,
					data_rd1, 
					data_rd2, 
					data_rd3, 
					data_rd4, 
					data_wr1, 
					data_wr2, 
					data_wr3, 
					data_wr4, 
					data_wr1_data, 
					data_wr2_data, 
					data_wr3_data, 
					data_wr4_data, 
					data_wr1_enable, 
					data_wr2_enable, 
					data_wr3_enable, 
					data_wr4_enable, 
					data_rd1_out, 
					data_rd2_out, 
					data_rd3_out, 
					data_rd4_out
					);
	
	input clock;
	input [05:00]operationnumber;
	input [02:00]destination; 
	input [02:00]source_2;
	input [02:00]source_1;
	input [08:00]unsigned_3;
	input [05:00]unsigned_2;
	input [02:00]unsigned_1;

	// RegisterFile //

	input [15:00]reg_rd1_out;
	input [15:00]reg_rd2_out;
	input [15:00]reg_rd3_out;

	output [05:00]reg_wr1;
	output [05:00]reg_wr2;
	output reg_wr1_enable;
	output reg_wr2_enable;
	output [15:00]reg_wr1_data;
	output [15:00]reg_wr2_data;

	output [05:00]reg_rd1;
	output [05:00]reg_rd2;
	output [05:00]reg_rd3;

	// Data Register //

	input [31:00]data_rd1_out;
	input [31:00]data_rd2_out;
	input [31:00]data_rd3_out;
	input [31:00]data_rd4_out;

	output [08:00] data_rd1;
	output [08:00] data_rd2;
	output [08:00] data_rd3;
	output [08:00] data_rd4;

	output [08:00] 	data_wr1;
	output [08:00] 	data_wr2;
	output [08:00]	data_wr3;
	output [08:00]	data_wr4;
	output [31:00] 	data_wr1_data;
	output [31:00] 	data_wr2_data;
	output [31:00] 	data_wr3_data;
	output [31:00] 	data_wr4_data;
	output			data_wr1_enable;
	output			data_wr2_enable;
	output			data_wr3_enable;
	output 			data_wr4_enable;


	// input [63:00]register;

	reg [05:00]reg_wr1;
	reg [05:00]reg_wr2;

	reg [05:00]reg_rd1;
	reg [05:00]reg_rd2;
	reg [05:00]reg_rd3;

	reg reg_wr1_enable;
	reg reg_wr2_enable;

	reg [15:00] reg_wr1_data;
	reg [15:00] reg_wr2_data;

	wire [05:00] operationnumber;

	reg [08:00] data_rd1;
	reg [08:00] data_rd2;
	reg [08:00] data_rd3;
	reg [08:00] data_rd4;

	reg [08:00]	data_wr1;
	reg [08:00]	data_wr2;
	reg [08:00]	data_wr3;
	reg [08:00]	data_wr4;
	reg [31:00]	data_wr1_data;
	reg [31:00]	data_wr2_data;
	reg [31:00]	data_wr3_data;
	reg [31:00]	data_wr4_data;
	reg			data_wr1_enable;
	reg			data_wr2_enable;
	reg			data_wr3_enable;
	reg 		data_wr4_enable;

	wire [02:00] destination;	

	always @(posedge clock) begin

		reg_wr1_enable = 0;
		reg_wr2_enable = 0;
		reg_rd1 = source_1;
		reg_rd2 = source_2;
		reg_rd3 = destination;

		if (operationnumber == 0) begin 	//no operation
			
		end
		
		if (operationnumber == 1) begin 	//unsigned add	
			reg_wr1 = destination;
			
			reg_wr1_data = reg_rd1_out + reg_rd2_out;
			reg_wr1_enable = 1;


		end

		if (operationnumber == 2) begin 	//unsigned subtract
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out - reg_rd2_out;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 3) begin 	//bitwise AND 
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out & reg_rd2_out;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 4) begin 	//bitwise OR
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out | reg_rd2_out;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 5) begin 	//bitwise exclusive OR
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out ^ reg_rd2_out;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 6) begin 	// arithmetic shift right
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out >>> reg_rd2_out;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 7) begin 	// Logical left shift
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out << reg_rd2_out;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 8) begin 	// Logical right shift
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out >> reg_rd2_out;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 9) begin 	// move register to register
			
		end

		if (operationnumber == 10) begin 	//unsigned add immediate
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out + unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 11) begin 	//unsigned subtract immediate
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out - unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 12) begin 	//arithmetic shift right immediate
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out >>> unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 13) begin 	//logical shift left immediate
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out << unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 14) begin 	//logical shift right immediate
			reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out >> unsigned_1;
			reg_wr1_enable = 1;
			
		end

		if (operationnumber == 15) begin 	//Move immeidate to register
			reg_wr1 = destination;
			reg_wr1_data = unsigned_2;
			reg_wr1_enable = 1;
		end

		if (operationnumber == 16) begin 	//indexed load byte
			reg_wr1 = destination;
			data_rd1 = reg_rd1_out + unsigned_1;
			reg_wr1_data = data_rd1_out[07:00]; // ??
			reg_wr1_enable = 1;
			
		end
		if (operationnumber == 17) begin 	//indexed load word
			reg_wr1 = destination;
			data_rd1 = reg_rd1_out + unsigned_1;
			reg_wr1_data = data_rd1_out; // ??
			reg_wr1_enable = 1;
		end


	end
endmodule