module declarations 

reg [15:00] pc_out;
wire[15:00] pc_out_input;
wire[15:00] pc_out_output;
assign pc_out = pc_out_output;
assign pc_out_input = pc_out;

reg [15:00] pc_new;
wire[15:00] pc_new_input;
wire[15:00] pc_new_output;
assign pc_new = pc_new_output;
assign pc_new_input = pc_new;

endmodule





module pc (
	pc_new_output
	pc_out_input
	);
	
	input [15:00] pc_new_output;
	output [15:00] pc_out_input;
	
	initial begin
		pc_out_input <= 0;
	end
	
	always @ (pc_new_output) begin
		pc_out_input <= pc_new_output;
	end

endmodule


module instruction

	(
	input fetch_instruction_request
	output fetch_instruction_response
	);
	
	always @ (posedge speedy_clock) begin
		reg [15:00]instruction_memory[0:256];
		fetch_instruction_response = instruction_memory[fetch_instruction_request];
	end
	
endmodule

module fetch 
	(
	input pc_out
	input fetch_instruction_response
	output fetch_instruction_request
	output fetch_out
	)
 
	fetch_instruction_request => pc_out
	fetch_out => fetch_instruction_response
	
endmodule

module bilbo (



	//////////// CLOCK //////////
	CLOCK_50,

	//////////// LED //////////
	LED,

	//////////// KEY //////////
	KEY,

	//////////// SW //////////
	SW,

	//////////// SDRAM //////////
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CLK,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_DQM,
	DRAM_RAS_N,
	DRAM_WE_N,

	//////////// EPCS //////////
	EPCS_ASDO,
	EPCS_DATA0,
	EPCS_DCLK,
	EPCS_NCSO,

	//////////// Accelerometer and EEPROM //////////
	G_SENSOR_CS_N,
	G_SENSOR_INT,
	I2C_SCLK,
	I2C_SDAT,

	//////////// ADC //////////
	ADC_CS_N,
	ADC_SADDR,
	ADC_SCLK,
	ADC_SDAT,

	//////////// 2x13 GPIO Header //////////
	GPIO_2,
	GPIO_2_IN,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	gpio_0,
	gpio_0_IN,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	gpio_1,
	gpio_1_IN 
);
	/////////////////Registers///////////////////

	reg [31:00] data //  
	reg [31:00] instruction // 
	reg [31:00] register // the stored data
	reg [15:00] pc // the list of adressess 

	/////////////////Clock Divider///////////////

	//reg//

	reg [09:00] clock_divider_counter
	reg speedy_clock;

		always @(posedge CLOCK_50) begin
			if (reset == 1'b1) // reset if reset button hit
				clock_divider_counter <= 0;
			else if (clock_divider_counter == 217) // reset if too high
				clock_divider_counter <= 0;
			else
				clock_divider_counter <= clock_divider_counter + 1;
		end

		always @(posedge CLOCK_50) begin
			if (reset == 1'b1)
				speedy_clock <= 0;
			else if(clock_divider_counter == 217)
				speedy_clock <= ~speedy_clock;
		end
					
endmodule
	