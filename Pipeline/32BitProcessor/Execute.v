module execution (	clock, 
					reset,
					operationnumber,
					destination,
					source_1,
					source_2,
					unsigned_1,
					unsigned_2,
					unsigned_3,
					unsigned_4,
					unsigned_5,
					signed_3,
					signed_2,
					signed_1,
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
					data_rd4_out,
					pcchange,
					pcjumpenable,
					pclocation,
					previous_programcounter,
					super_duper_a,
					super_duper_b
					);
	
	input clock;
	input reset;
	
	// Decoder //

	input [05:00]operationnumber;
	input [05:00]destination; 
	input [05:00]source_2;
	input [05:00]source_1;
	input [08:00]unsigned_5;
	input [09:00]unsigned_4;
	input [08:00]unsigned_3;
	input [15:00]unsigned_2;
	input [05:00]unsigned_1;
	input [21:00]signed_1;
	input [15:00]signed_2;
	input [09:00]signed_3;

	output [08:00]pcchange;
	output [02:00]pcjumpenable;
	output [05:00]pclocation;

	input [19:00]previous_programcounter;

	input super_duper_a;
	input super_duper_b;

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

	reg [05:00]	reg_wr1;
	reg [05:00]	reg_wr2;

	reg [05:00]	reg_rd1;
	reg [05:00]	reg_rd2;
	reg [05:00]	reg_rd3;

	reg 		reg_wr1_enable;
	reg 		reg_wr2_enable;

	reg [15:00] reg_wr1_data;
	reg [15:00] reg_wr2_data;

	wire [05:00]operationnumber;

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

	reg 		carrybit;
	reg [16:00] carryreg;

	wire [05:00] destination;	

	reg [08:00]	pcchange;
	reg [02:00]	pcjumpenable;
	reg [05:00]	pclocation;

	wire 		super_duper_a;
	wire 		super_duper_b;

	always @(posedge clock) begin

		reg_wr1_enable = 0;
		reg_wr2_enable = 0;
		data_wr1_enable = 0;
		data_wr2_enable = 0;
		data_wr3_enable = 0;
		data_wr4_enable = 0;
		reg_rd1 = source_1;
		reg_rd2 = source_2;
		reg_rd3 = destination;
		pcjumpenable = 0;
		
		if (operationnumber == 0) begin 	//no operation
			reg_wr1_enable = 0;
			reg_wr2_enable = 0;
		end
		
		if (operationnumber == 1) begin 	//unsigned add	
		if (super_duper_a == 1) begin 	//unsigned add with carry ??
				reg_wr1 = destination;
				carryreg = reg_rd1_out + reg_rd2_out + carrybit;
				reg_wr1_data = carryreg[15:00];
				carrybit = carryreg[16];
				reg_wr1_enable = 1;
			end
			else begin
				reg_wr1 = destination;
				reg_wr1_data = reg_rd1_out + reg_rd2_out;
				reg_wr1_enable = 1;
			end
		end
		if (operationnumber == 2) begin 	//unsigned subtract 	
			if (super_duper_a == 1 ) begin 	//unsigned subtract with carry ??
				reg_wr1 = destination;
					carryreg = reg_rd1_out - reg_rd2_out - carrybit;
				reg_wr1_data = carryreg[15:00];
			carrybit = carryreg[16];
				reg_wr1_enable = 1;
			end
			else begin
				reg_wr1 = destination;
				reg_wr1_data = reg_rd1_out - reg_rd2_out;
				reg_wr1_enable = 1;
			end
		end
		if (operationnumber == 3) begin 	//bitwise AND 
			if (super_duper_b == 1) begin 	//bitwise AND immediate
				reg_wr1 = destination;
				reg_wr1_data = reg_rd1_out & unsigned_5;
				reg_wr1_enable = 1;	
			end
			else begin
				reg_wr1 = destination;
			reg_wr1_data = reg_rd1_out & reg_rd2_out;
				reg_wr1_enable = 1;
			end
		end
		if (operationnumber == 4) begin 	//bitwise OR
			if (super_duper_b == 1) begin 	//bitwise OR immediate
				reg_wr1 = destination;
				reg_wr1_data = reg_rd1_out | unsigned_5;
				reg_wr1_enable = 1;
			end
			else begin
				reg_wr1 = destination;
				reg_wr1_data = reg_rd1_out | reg_rd2_out;
				reg_wr1_enable = 1;
			end
		end
		if (operationnumber == 5) begin 	//bitwise exclusive OR
			if (super_duper_b == 1) begin 	//bitwise exclusive OR immediate
				reg_wr1 = destination;
				reg_wr1_data = reg_rd1_out ^ unsigned_5;
				reg_wr1_enable = 1;
			end
			else begin
				reg_wr1 = destination;
				reg_wr1_data = reg_rd1_out ^ reg_rd2_out;
				reg_wr1_enable = 1;
			end
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
			reg_rd1 = source_1;
			reg_wr1 = destination;
		reg_wr1_data = reg_rd1_out;
			reg_wr1_enable = 1;
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
			reg_rd1 = source_1;
			data_rd1 = (reg_rd1_out + unsigned_1);
			reg_wr1_data[07:00] = data_rd1_out[07:00];
			reg_wr1_enable = 1;
			pcjumpenable = 0;
		end
		if (operationnumber == 17) begin 	//indexed load byte with predecrement
			reg_rd2 = source_1;
			reg_wr2 = source_1;
			reg_wr2_data = reg_rd2_out - 1;
			reg_wr2_enable = 1;
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_rd1 = (reg_rd1_out + unsigned_1);
			reg_wr1_data[07:00] = data_rd1_out[07:00];
			reg_wr1_enable = 1;
		end
		if (operationnumber == 18) begin 	//indexed load byte with postincrement
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_rd1 = (reg_rd1_out + unsigned_1);
			reg_wr1_data[07:00] = data_rd1_out[07:00];
			reg_wr1_enable = 1;
			reg_rd2 = source_1;
			reg_wr2 = source_1;
			reg_wr2_data = reg_rd2_out + 1;
			reg_wr2_enable = 1;
		end
		if (operationnumber == 20) begin 	//indexed load word
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_rd1 = (reg_rd1_out + unsigned_1);
			reg_wr1_data = data_rd1_out;
			reg_wr1_enable = 1;
		end
		if (operationnumber == 21) begin 	//indexed load word with predecrement
			reg_rd2 = source_1;
			reg_wr2 = source_1;
			reg_wr2_data = reg_rd2_out - 2;
			reg_wr2_enable = 1;
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_rd1 = (reg_rd1_out + unsigned_1);
				reg_wr1_data = data_rd1_out;
			reg_wr1_enable = 1;
		end
		if (operationnumber == 22) begin 	//indexed load word with postincrement
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_rd1 = (reg_rd1_out + unsigned_1);
			reg_wr1_data = data_rd1_out;
			reg_wr1_enable = 1;
		reg_rd2 = source_1;
			reg_wr2 = source_1;
			reg_wr2_data = reg_rd2_out + 2;
			reg_wr2_enable = 1;
		end

		if (operationnumber == 24) begin 	//indexed store byte
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_wr1 = (reg_rd1_out + unsigned_1);
			data_wr1_data[07:00] = reg_rd1_out[07:00];
			data_wr1_enable = 1;
			end
		if (operationnumber == 25) begin 	//indexed store byte with predecrement
			reg_rd2 = source_1;
			reg_wr2 = source_1;
			reg_wr2_data = reg_rd2_out - 1;
			reg_wr2_enable = 1;			
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_wr1 = (reg_rd1_out + unsigned_1);
			data_wr1_data[07:00] = reg_rd1_out[07:00];
			data_wr1_enable = 1;
		end
		if (operationnumber == 26) begin 	//indexed store byte with postincrement
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_wr1 = (reg_rd1_out + unsigned_1);
			data_wr1_data[07:00] = reg_rd1_out[07:00];
			data_wr1_enable = 1;
			reg_rd2 = source_1;
			reg_wr2 = source_1;
			reg_wr2_data = reg_rd2_out + 1;
			reg_wr2_enable = 1;
		end
		if (operationnumber == 28) begin 	//indexed store word
			data_wr1 = destination;
			reg_rd1 = source_1;
			data_wr1_data = (reg_rd1_out + unsigned_1);
			//data_wr1_data = reg_rd1_out;
			data_wr1_enable = 1;
		end
		if (operationnumber == 29) begin 	//indexed store word with predecrement
			reg_rd2 = source_1;
			reg_wr2 = source_1;
			reg_wr2_data = reg_rd2_out - 2;
			reg_wr2_enable = 1;			
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_wr1 = (reg_rd1_out + unsigned_1);
			data_wr1_data = reg_rd1_out;
			data_wr1_enable = 1;
		end
		if (operationnumber == 30) begin 	//indexed store word with postincrement
			reg_wr1 = destination;
			reg_rd1 = source_1;
			data_wr1 = (reg_rd1_out + unsigned_1);
			data_wr1_data[15:00] = reg_rd1_out;
			data_wr1_enable = 1;
			reg_rd2 = source_1;
			reg_wr2 = source_1;
			reg_wr2_data = reg_rd2_out + 2;
			reg_wr2_enable = 1;
		end

		if (operationnumber == 32) begin        //relative branch
			pcchange = signed_1;
			pcjumpenable = 1;
		end
		if (operationnumber == 33) begin        //relative branch and link
			pcchange = signed_2;
			pcjumpenable = 4;
		end
		if (operationnumber == 34) begin        //relative branch if equal
			if (source_1 == source_2) begin
				pcchange = signed_3;
				pcjumpenable = 1;
			end
		end

		if (operationnumber == 35) begin        //relative branch if not equal
			if (source_1 !== source_2) begin
				pcchange = signed_3;
				pcjumpenable = 1;
			end
		end
		if (operationnumber == 38) begin        //relative branch if unsigned less than
			if (source_1 < source_2) begin
				pcchange = signed_3;
				pcjumpenable = 1;
			end
		end
		if (operationnumber == 39) begin        //relative branch if unsigned greater than
			if (source_1 > source_2) begin
			pcchange = signed_3;
				pcjumpenable = 1;
			end
		end
		if (operationnumber == 38) begin        //relative branch if signed less than
			if ($signed(source_1) < $signed (source_2)) begin
				pcchange = signed_3;
				pcjumpenable = 1;
			end
		end
		if (operationnumber == 39) begin        //relative branch if signed greater than
			if ($signed(source_1) > $signed(source_2)) begin
				pcchange = signed_3;
				pcjumpenable = 1;
			end
		end

		if (operationnumber == 40) begin        //absolute jump
			pclocation = destination;
			pcjumpenable = 2;
		end
		if (operationnumber == 41) begin 		//absolute jump and link
			pclocation = destination;
			pcjumpenable = 3;
			//pclocation <= previous_programcounter;
		end
		if (operationnumber == 42) begin        //absolute jump if equal
			if (source_1 == source_2) begin
				pclocation = destination;
				pcjumpenable = 2;
			end
		end
		if (operationnumber == 43) begin        //absolute jump if not equal
			if (source_1 !== source_2) begin
				pclocation = destination;
			pcjumpenable = 2;
			end
		end
		if (operationnumber == 44) begin        //absolute jump if signed less than
			if ($signed(source_1) < $signed(source_2)) begin
				pclocation = destination;
			pcjumpenable = 2;
			end
		end
		if (operationnumber == 45) begin        //absolute jump if signed greater than
			if ($signed(source_1) > $signed(source_2)) begin
				pclocation = destination;
				pcjumpenable = 2;
			end
		end

		if (operationnumber == 46) begin        //absolute jump if unsigned less than
			if (source_1 < source_2) begin
				pclocation = destination;
				pcjumpenable = 2;
				end
		end
		if (operationnumber == 47) begin        //absolute jump if unsigned greater than
			if (source_1 > source_2) begin
				pclocation = destination;
				pcjumpenable = 2;
			end
		end
		
	end
endmodule