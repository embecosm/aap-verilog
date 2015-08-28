`include "Execute.v"
`include "RegisterFile.v"
`include "32bitdecoder.v"
`include "DataMemory.v"
`include "InstructionMemory.v"
`include "Fetch.v"


module testbench;

	reg clock;
	reg reset;
    wire stop;

	wire [05:00] reg_rd1;
	wire [05:00] reg_rd2;
	wire [05:00] reg_rd3;

	wire [08:00] data_rd1;
	wire [08:00] data_rd2;
	wire [08:00] data_rd3;
	wire [08:00] data_rd4;


	wire [15:00] reg_rd1_out;
	wire [15:00] reg_rd2_out;
	wire [15:00] reg_rd3_out;

	wire [31:00] data_rd1_out;
	wire [31:00] data_rd2_out;
	wire [31:00] data_rd3_out;
	wire [31:00] data_rd4_out;		

	wire [05:00] destination;

	wire [05:00] reg_wr1;
	wire [15:00] reg_wr1_data;
	wire 		 reg_wr1_enable;

	wire [05:00] reg_wr2;
	wire [15:00] reg_wr2_data;
	wire 		 reg_wr2_enable;

	wire [08:00] data_wr1;
	wire [31:00] data_wr1_data;
	wire		 data_wr1_enable;

	wire [08:00] data_wr2;
	wire [31:00] data_wr2_data;
	wire		 data_wr2_enable;

	wire [08:00] data_wr3;
	wire [31:00] data_wr3_data;
	wire		 data_wr3_enable;

	wire [08:00] data_wr4;
	wire [31:00] data_wr4_data;
	wire		 data_wr4_enable;

	reg [15:00] register [63:00]; 

	wire [31:00]  fetchoutput;
    wire [05:00]  operationnumber;
    reg		      opcodemem;

    wire [05:00] source_1;
    wire [05:00] source_2;

    wire [21:00] signed_1;
    wire [15:00] signed_2;
    wire [09:00] signed_3;

    wire [05:00] unsigned_1;
    wire [15:00] unsigned_2;
    wire [08:00] unsigned_3;
    wire [09:00] unsigned_4;
    wire [08:00] unsigned_5;

    wire [19:00] instruction_rd1;
    wire [19:00] instruction_rd2;
	wire [19:00] instruction_rd3;
	wire [19:00] instruction_rd4;
	wire [15:00] instruction_rd1_out;
	wire [15:00] instruction_rd2_out;
	wire [15:00] instruction_rd3_out;
	wire [15:00] instruction_rd4_out;

	wire [08:00]pcchange;
	wire [05:00]pclocation;

    wire [02:00]pcjumpenable;

    wire carrybit;
    wire carrybit_wr;
    wire carrybit_wr_enable; 

    reg [15:00] fetch1;
    reg [15:00] fetch2;

	wire [19:00] previous_programcounter;

    registerfile registerfile_tb( 
    	clock, 
    	reset, 
    	reg_rd1[05:00], 
    	reg_rd2[05:00], 
    	reg_rd3[05:00], 
    	reg_wr1[05:00], 
    	reg_wr2[05:00], 
    	reg_wr1_data, 
    	reg_wr2_data, 
    	reg_wr1_enable, 
    	reg_wr2_enable, 
    	reg_rd1_out[15:00], 
    	reg_rd2_out[15:00], 
    	reg_rd3_out[15:00],
        carrybit,
        carrybit_wr,
        carrybit_wr_enable
    	);

    decoder decoder_test (
    	fetchoutput[31:00], 
    	destination[05:00], 
    	operationnumber[05:00], 
    	source_1[05:00],
    	source_2[05:00], 
    	unsigned_1[05:00], 
    	unsigned_2[15:00], 
    	unsigned_3[08:00],
        unsigned_4[09:00],
        unsigned_5[08:00],
        signed_1[21:00],
        signed_2[15:00],
        signed_3[09:00],
        flush,
        super_duper_a,
        super_duper_b
    	);

    fetch fetch_test (
    	clock,
        reset,
    	instruction_rd1[19:00], 
    	instruction_rd1_out[15:00],
    	fetchoutput[31:00],
    	pcchange[08:00],
		pclocation[05:00],
        pcjumpenable[02:00],
		previous_programcounter[19:00],
        flush,
        stop
    	);

    execution execution_test (
    	clock, 
        reset,
        stop,
    	operationnumber[05:00], 
    	destination[05:00], 
    	source_1[05:00], 
    	source_2[05:00], 
    	unsigned_1[05:00], 
    	unsigned_2[15:00], 
    	unsigned_3[08:00],
        unsigned_4[09:00],
        unsigned_5[08:00],
        signed_3[09:00],
        signed_2[15:00],
        signed_1[21:00], 
    	reg_rd1[05:00], 
    	reg_rd2[05:00], 
    	reg_rd3[05:00], 
    	reg_wr1, 
    	reg_wr2, 
    	reg_wr1_data, 
    	reg_wr2_data, 
    	reg_wr1_enable, 
    	reg_wr2_enable, 
    	reg_rd1_out[15:00], 
    	reg_rd2_out[15:00], 
    	reg_rd3_out[15:00], 
    	data_rd1[08:00], 
    	data_rd2[08:00], 
    	data_rd3[08:00], 
    	data_rd4[08:00], 
    	data_wr1[08:00], 
    	data_wr2[08:00], 
    	data_wr3[08:00], 
    	data_wr4[08:00], 
    	data_wr1_data[31:00], 
    	data_wr2_data[31:00], 
    	data_wr3_data[31:00], 
    	data_wr4_data[31:00], 
    	data_wr1_enable, 
    	data_wr2_enable, 
    	data_wr3_enable, 
    	data_wr4_enable, 
    	data_rd1_out[31:00], 
    	data_rd2_out[31:00], 
    	data_rd3_out[31:00], 
    	data_rd4_out[31:00],
        pcchange[08:00],        
		pcjumpenable[02:00],
		pclocation[05:00],
		previous_programcounter[19:00],
        super_duper_a,
        super_duper_b,
        carrybit,
        carrybit_wr,
        carrybit_wr_enable
        );

    TheInstructionMemory TheInstructionMemory_test (
    	clock, 
    	reset, 
    	instruction_rd1[19:00], 
    	instruction_rd2[19:00], 
    	instruction_rd3[19:00], 
    	instruction_rd4[19:00], 
    	instruction_wr1[19:00], 
    	instruction_wr2[19:00], 
    	instruction_wr3[19:00], 
    	instruction_wr4[19:00], 
    	instruction_wr1_data[15:00], 
    	instruction_wr2_data[15:00], 
    	instruction_wr3_data[15:00], 
    	instruction_wr4_data[15:00], 
    	instruction_wr1_enable, 
    	instruction_wr2_enable, 
    	instruction_wr3_enable, 
    	instruction_wr4_enable, 
    	instruction_rd1_out[15:00], 
    	instruction_rd2_out[15:00], 
    	instruction_rd3_out[15:00], 
    	instruction_rd4_out[15:00]
    	);

    TheDataMemory TheDataMemory_test (
        clock, 
        reset, 
        data_rd1[08:00], 
        data_rd2[08:00], 
        data_rd3[08:00], 
        data_rd4[08:00], 
        data_wr1[08:00], 
        data_wr2[08:00], 
        data_wr3[08:00], 
        data_wr4[08:00], 
        data_wr1_data[31:00], 
        data_wr2_data[31:00], 
        data_wr3_data[31:00], 
        data_wr4_data[31:00], 
        data_wr1_enable, 
        data_wr2_enable, 
        data_wr3_enable, 
        data_wr4_enable, 
        data_rd1_out[31:00], 
        data_rd2_out[31:00], 
        data_rd3_out[31:00], 
        data_rd4_out[31:00]
        );

		initial begin
			$dumpfile ("execution_tb.vcd");
			$dumpvars (0, fetch_test, decoder_test, execution_test, registerfile_tb, TheInstructionMemory_test, TheDataMemory_test);
			clock = 0;
			#2
				reset = 1;
			#2
				reset = 0;
			#2
			//	register[0] = 0;
			//	register[1] = 3;
			//	register[2] = 2;

			#500
			$finish;

		end


	always 
		#1 clock = ~clock;
        
endmodule
