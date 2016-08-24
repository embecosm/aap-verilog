module fetch(	clock,
				reset,
				nop_stop, 
				instruction_rd1, 
				instruction_rd1_out, 
				fetchoutput,
				pcchange, 
				pclocation,
				pcjumpenable, 
				previous_programcounter,
				programcounter,
				flush,
				LED,
				uart_stop,
				uart_continue,
				uart_step_enable,
				uart_step_volume,
				uart_reset
				);

	output [19:00]instruction_rd1;
	output [31:00]fetchoutput;
	output [05:00]previous_programcounter;
	output [05:00]programcounter;

	input clock;
	output reg reset;
	input nop_stop;
	input [15:00]instruction_rd1_out;
	
	input uart_step_enable;
	input uart_step_volume;
	
	input uart_stop;
	input uart_continue;
	input uart_reset;
	
	input [08:00]pcchange;
	input [05:00]pclocation;
	input [02:00]pcjumpenable;

	input flush;
	
	output [07:00] LED;
	
	wire clock;
	reg stop;

	wire [31:00] fetchoutput;

	reg [15:00] fetch1;
	reg [15:00] fetch2;

	wire [15:00] instruction_rd1_out;
	wire [19:00] instruction_rd1;

	reg [05:00]programcounter;
	reg [05:00]previous_programcounter;
	
	reg [05:00] uart_step_counter;

	assign fetchoutput [31:16] = fetch1;
	assign fetchoutput [15:00] = fetch2;

	assign instruction_rd1 = programcounter;
	assign LED[07:00] = fetchoutput[21:16];	

	always @(posedge clock) begin

		if (nop_stop == 1) begin
			stop = 1;
		end
		if (uart_stop == 1) begin
			stop = 1;
		end
/*		if (uart_step_counter == 1) begin
			stop = 1;
		end
*/		if (uart_continue == 1) begin
			stop = 0;
			reset = 0;
		end
		if (uart_reset == 1) begin
			reset = 1;
		end
		if (reset == 1) begin
			stop = 1;
		
		end
	//	else begin
	//		stop = 0;
	//	end
	
	end	
	
	
	
	always @(posedge clock) begin 				// ????????????????????????
		if (stop == 1) begin
			if (uart_step_enable == 1) begin
				programcounter <= uart_step_volume;
				fetch1 <= 0;
			end
			else begin
			uart_step_counter = 0;
			//programcounter = 0;
			end
		end
	
		else begin

			
			if (reset == 1) begin
				programcounter <= 0;
			end

			if (uart_step_enable == 1) begin
				programcounter <= uart_step_counter;
				fetch1 <= 0;
			end
			
			else begin	
				if (pcjumpenable == 1) begin 										//Relative Branch
					if (programcounter == previous_programcounter + pcchange -1) begin
					//	programcounter <= programcounter + 1; 				will cause to loop i think
						fetch1 <= fetch2;
						fetch2[07:00] <= instruction_rd1_out[15:08];
						fetch2[15:08] <= instruction_rd1_out[07:00];				end
					else begin
						programcounter <= programcounter + pcchange - 1;	
						previous_programcounter <= programcounter;
						fetch1 <= 0000000000000001;
						fetch2 <= 0000000000000001;
					end
				end

				if (pcjumpenable == 2) begin 										//Absolute Jump
					if (programcounter == pclocation) begin
						fetch1 <= 0;
						fetch2[07:00] <= instruction_rd1_out[15:08];
						fetch2[15:08] <= instruction_rd1_out[07:00];
					end
					else begin	
						programcounter <= pclocation;
						fetch1 <= 0000000000000001;
						fetch2 <= 0000000000000001;
					end
				end

				if (pcjumpenable == 3) begin 										//Absolute Jump and Link
					if (programcounter == pclocation) begin
						fetch1 <= 0;
						fetch2[07:00] <= instruction_rd1_out[15:08];
						fetch2[15:08] <= instruction_rd1_out[07:00];
					end
					else begin	
						programcounter <= pclocation;
						previous_programcounter <= programcounter;
						fetch1 <= 0000000000000001;
						fetch2 <= 0000000000000001;
					end
				end

				if (pcjumpenable == 4) begin 										//Relative branch and Link
					if (programcounter == previous_programcounter + pcchange - 1) begin
						fetch1 <= fetch2;
						fetch2[07:00] <= instruction_rd1_out[15:08];
						fetch2[15:08] <= instruction_rd1_out[07:00];
					end
					else begin
						programcounter <= programcounter + pcchange - 1;
						previous_programcounter <= programcounter;		
						fetch1 <= 0;
						fetch2 <= 0;
					end
				end
				
				if (pcjumpenable == 0) begin 										//Else increment program counter
						previous_programcounter <= programcounter;
						programcounter <= programcounter + 1;
						fetch1 <= fetch2;
						fetch2[07:00] <= instruction_rd1_out[15:08];
						fetch2[15:08] <= instruction_rd1_out[07:00];	
						uart_step_counter = uart_step_counter - 1;
				end

				if (flush == 1) begin 												
					fetch1 <= 0000000000000001; 	
				end
			end
		end
	end
	
		
		
endmodule