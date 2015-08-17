module uart (	clock,
					reset,
					UART_TX,
					UART_GND,
					UART_RX,
					reg_rd3,
					reg_rd3_out,
					LED,
					reg_wr3_data,
					reg_wr3,
					reg_wr3_enable,
					instruction_rd2,
					instruction_rd2_out,
					instruction_wr2,
					instruction_wr2_data,
					instruction_wr2_enable
				);
				
	input				clock;
	input 			reset;

	output reg 		UART_TX;
	output 			UART_GND;
	input				UART_RX;
	
	output			[05:00]reg_rd3;
	input				[15:00]reg_rd3_out;
	output			[15:00]reg_wr3_data;
	output 			[05:00]reg_wr3;
	output 			reg_wr3_enable;
	
	output	[05:00]	instruction_rd2;
	input		[15:00]	instruction_rd2_out;
	output	[05:00]	instruction_wr2;
	output	[15:00]	instruction_wr2_data;
	output	instruction_wr2_enable;
	
	reg [05:00] reg_rd3;
	reg [05:00] reg_wr3;
	reg [15:00] reg_wr3_data;
	reg reg_wr3_enable;
	
	reg	[05:00]	instruction_rd2;
	reg	[05:00]	instruction_wr2;
	reg	[15:00]	instruction_wr2_data;
	reg	instruction_wr2_enable;
	
	output [07:00] LED;
	
	//UART transmit at 300 baud from 50MHz clock
	reg [16:0] 		clock_divider_counter;
   reg 				uart_clock;
	
	// Clock counter
	always @(posedge clock) begin
     if (reset == 1'b1)
			clock_divider_counter = 0;
		else if (clock_divider_counter == 83333)
			clock_divider_counter = 0;
		else
			clock_divider_counter = clock_divider_counter + 1; 	// Otherwise increment the counter
	end		
	
	// Generate a clock (toggle this register)
   always @(posedge clock) begin
		if (reset == 1'b1)
			uart_clock <= 0;
		else if (clock_divider_counter == 83333)
			uart_clock = ~uart_clock;
	end	


	// UART_TX state machine
	
		reg [3:0] transmit_state;
		reg [7:0] transmit_data;		
	
	   always @(posedge uart_clock or posedge reset) begin
			if (reset) begin
			// Reset to the "IDLE" state
				transmit_state <= 0;
	     // The UART line is set to '1' when idle, or reset
				UART_TX = 1;
	     // Data we'll transmit - start at ASCII '0'
			end
			
			else begin
				case (transmit_state)
					0:
						begin
							if (transmit_data_state == 0)
								if (write_enable == 1)		
									transmit_state = 1;
							if (transmit_data_state !== 0)
								transmit_state = 1;
						end
					1:
						begin
							UART_TX = 0;
							transmit_state = 2;
						end
					2,3,4,5,6,7,8,9:
						begin
							UART_TX = transmit_data[transmit_state - 2];
							transmit_state = transmit_state + 1;
						end
					10:
						begin
							transmit_state = 0;
							UART_TX = 1;
							
							if (transmit_data_state !== transmit_data_state_max) // increment countr
								transmit_data_state = transmit_data_state + 1;
							else 
								transmit_data_state = 0;
								
							
						end
						
					default:
						begin
							transmit_state = 0;
						end
				endcase
			end
			
		end
		
		
		// UART_RX state machine
		
		reg [5:0] 	recieve_state;
		reg [7:00] recieved;
		reg [15:00] amountrecieved;
		reg write_enable;
		reg [7:0] transmit_storage [63:00];
		reg [5:0] transmit_data_state;
		reg [5:0] transmit_data_state_max;
		reg [5:0] saved;
		
		
		always @(posedge uart_clock or posedge reset) begin
			if (reset) begin
	     // Reset to the "IDLE" state
				recieve_state <= 0;
				saved_counter = 0;
			end	
			else begin
				case (recieve_state)
			
					0:
						begin
							write_enable = 0;
							if (UART_RX == 0) 
								recieve_state = 1;
							//	saved = recieved;
							
						end					
					1,2,3,4,5,6,7,8:
						begin
							recieved[recieve_state - 1] = UART_RX;
							recieve_state <= recieve_state + 1;
							
						end
					9:
						begin
							recieve_state <= 0;
							amountrecieved = amountrecieved + 1;
							write_enable = 1;
							saved_memory[saved_counter] = recieved;
							if (saved_memory[saved_counter] == 13)
								saved_counter <= 0;
							else 
								saved_counter <= saved_counter + 1;
						end
					default:
						recieve_state = 0;
				endcase
			end
		
		end
		
		always @(posedge uart_clock) begin
			transmit_data = transmit_storage[transmit_data_state];
		
		end
		
		always @(posedge uart_clock) begin
			reg_wr3_enable = 0;
			if (recieved == 13) begin
				//saved_counter <= 0;
				if (saved_memory[0] == 42) begin
					transmit_data_state_max = 4;
					transmit_storage[0] = 32;
					transmit_storage[1] = 68;
					transmit_storage[2] = 97;
					transmit_storage[3] = 110;
					transmit_storage[4] = 33;  
				end
				if (saved_memory[0] == 47) begin
					transmit_data_state_max = 8;
					transmit_storage[0] = 32;
					transmit_storage[1] = 78;
					transmit_storage[2] = 111;
					transmit_storage[3] = 116;
					transmit_storage[4] = 32;
					transmit_storage[5] = 68;
					transmit_storage[6] = 97;
					transmit_storage[7] = 110;
					transmit_storage[8] = 33;  
				end
				if (saved_memory[0] == 71) begin // Read a register
					transmit_data_state_max = 16; 
					//reg_rd3 = [01:06]saved_memory; 
					
					if (saved_memory[07] == 48) 
						reg_rd3[00] = 0;
					else 
						reg_rd3[00] = 1;
						
					if (saved_memory[06] == 48)
						reg_rd3[01] = 0;
					else 
						reg_rd3[01] = 1;
						
					if (saved_memory[05] == 48)
						reg_rd3[02] = 0;
					else 
						reg_rd3[02] = 1;
						
					if (saved_memory[04] == 48)
						reg_rd3[03] = 0;
					else 
						reg_rd3[03] = 1;
						
					if (saved_memory[03] == 48)
						reg_rd3[04] = 0;
					else 
						reg_rd3[04] = 1;
						
					if (saved_memory[02] == 48)
						reg_rd3[05] = 0;
					else 
						reg_rd3[05] = 1;
					
					
					
					transmit_storage[0] = 32;
					
					if (reg_rd3_out[15] == 0)
						transmit_storage[1] = 48;
					else 
						transmit_storage[1] = 49;
						
					if (reg_rd3_out[14] == 0)
						transmit_storage[2] = 48;
					else 
						transmit_storage[2] = 49;
						
					if (reg_rd3_out[13] == 0)
						transmit_storage[3] = 48;
					else 
						transmit_storage[3] = 49;
						
					if (reg_rd3_out[12] == 0)
						transmit_storage[4] = 48;
					else 
						transmit_storage[4] = 49;
						
					if (reg_rd3_out[11] == 0)
						transmit_storage[5] = 48;
					else 
						transmit_storage[5] = 49;
						
					if (reg_rd3_out[10] == 0)
						transmit_storage[6] = 48;
					else 
						transmit_storage[6] = 49;
						
					if (reg_rd3_out[9] == 0)
						transmit_storage[7] = 48;
					else 
						transmit_storage[7] = 49;
						
					if (reg_rd3_out[8] == 0)
						transmit_storage[8] = 48;
					else 
						transmit_storage[8] = 49;
						
					if (reg_rd3_out[7] == 0)
						transmit_storage[9] = 48;
					else 
						transmit_storage[9] = 49;
						
					if (reg_rd3_out[6] == 0)
						transmit_storage[10] = 48;
					else 
						transmit_storage[10] = 49;
						
					if (reg_rd3_out[5] == 0)
						transmit_storage[11] = 48;
					else 
						transmit_storage[11] = 49;
						
					if (reg_rd3_out[4] == 0)
						transmit_storage[12] = 48;
					else 
						transmit_storage[12] = 49;
						
					if (reg_rd3_out[3] == 0)
						transmit_storage[13] = 48;
					else 
						transmit_storage[13] = 49;
						
					if (reg_rd3_out[2] == 0)
						transmit_storage[14] = 48;
					else 
						transmit_storage[14] = 49;
						
					if (reg_rd3_out[1] == 0)
						transmit_storage[15] = 48;
					else 
						transmit_storage[15] = 49;
						
					if (reg_rd3_out[0] == 0)
						transmit_storage[16] = 48;
					else 
						transmit_storage[16] = 49;
				end
				
				if (saved_memory[0] == 87) begin // Write to register
					transmit_data_state_max = 16;
					reg_wr3_enable = 1;
					//reg_rd3 = [01:06]saved_memory; 
					
					if (saved_memory[07] == 48)
						reg_wr3[00] = 0;
					else 
						reg_wr3[00] = 1;
						
					if (saved_memory[06] == 48)
						reg_wr3[01] = 0;
					else 
						reg_wr3[01] = 1;
						
					if (saved_memory[05] == 48)
						reg_wr3[02] = 0;
					else 
						reg_wr3[02] = 1;
						
					if (saved_memory[04] == 48)
						reg_wr3[03] = 0;
					else 
						reg_wr3[03] = 1;
						
					if (saved_memory[03] == 48)
						reg_wr3[04] = 0;
					else 
						reg_wr3[04] = 1;
						
					if (saved_memory[02] == 48)
						reg_wr3[05] = 0;
					else 
						reg_wr3[05] = 1;
					
					
					
				
					if (saved_memory[24] == 48)
						reg_wr3_data[0] = 0;
					else
						reg_wr3_data[0] = 1;
					
					if (saved_memory[23] == 48)
						reg_wr3_data[1] = 0;
					else
						reg_wr3_data[1] = 1;
					
					if (saved_memory[22] == 48)
						reg_wr3_data[2] = 0;
					else
						reg_wr3_data[2] = 1;
					
					if (saved_memory[21] == 48)
						reg_wr3_data[3] = 0;
					else
						reg_wr3_data[3] = 1;
					
					if (saved_memory[20] == 48)
						reg_wr3_data[4] = 0;
					else
						reg_wr3_data[4] = 1;
					
					if (saved_memory[19] == 48)
						reg_wr3_data[5] = 0;
					else
						reg_wr3_data[5] = 1;
					
					if (saved_memory[18] == 48)
						reg_wr3_data[6] = 0;
					else
						reg_wr3_data[6] = 1;
					
					if (saved_memory[17] == 48)
						reg_wr3_data[7] = 0;
					else
						reg_wr3_data[7] = 1;
					
					if (saved_memory[16] == 48)
						reg_wr3_data[8] = 0;
					else
						reg_wr3_data[8] = 1;
					
					if (saved_memory[15] == 48)
						reg_wr3_data[9] = 0;
					else
						reg_wr3_data[9] = 1;
					
					if (saved_memory[14] == 48)
						reg_wr3_data[10] = 0;
					else
						reg_wr3_data[10] = 1;
					
					if (saved_memory[13] == 48)
						reg_wr3_data[11] = 0;
					else
						reg_wr3_data[11] = 1;
					
					if (saved_memory[12] == 48)
						reg_wr3_data[12] = 0;
					else
						reg_wr3_data[12] = 1;
					
					if (saved_memory[11] == 48)
						reg_wr3_data[13] = 0;
					else
						reg_wr3_data[13] = 1;
					
					if (saved_memory[10] == 48)
						reg_wr3_data[14] = 0;
					else
						reg_wr3_data[14] = 1;
					
					if (saved_memory[9] == 48)
						reg_wr3_data[15] = 0;
					else
						reg_wr3_data[15] = 1;
				end	
				
				if (saved_memory[0] == 73) begin // Read from Instruction memory
					transmit_data_state_max = 16;
					
					if (saved_memory[07] == 48) 
						instruction_rd2[00] = 0;
					else 
						instruction_rd2[00] = 1;
						
					if (saved_memory[06] == 48)
						instruction_rd2[01] = 0;
					else 
						instruction_rd2[01] = 1;
						
					if (saved_memory[05] == 48)
						instruction_rd2[02] = 0;
					else 
						instruction_rd2[02] = 1;
						
					if (saved_memory[04] == 48)
						instruction_rd2[03] = 0;
					else 
						instruction_rd2[03] = 1;
						
					if (saved_memory[03] == 48)
						instruction_rd2[04] = 0;
					else 
						instruction_rd2[04] = 1;
						
					if (saved_memory[02] == 48)
						instruction_rd2[05] = 0;
					else 
						instruction_rd2[05] = 1;
					
					
					
					transmit_storage[0] = 32;
					
					if (instruction_rd2_out[15] == 0)
						transmit_storage[1] = 48;
					else 
						transmit_storage[1] = 49;
						
					if (instruction_rd2_out[14] == 0)
						transmit_storage[2] = 48;
					else 
						transmit_storage[2] = 49;
						
					if (instruction_rd2_out[13] == 0)
						transmit_storage[3] = 48;
					else 
						transmit_storage[3] = 49;
						
					if (instruction_rd2_out[12] == 0)
						transmit_storage[4] = 48;
					else 
						transmit_storage[4] = 49;
						
					if (instruction_rd2_out[11] == 0)
						transmit_storage[5] = 48;
					else 
						transmit_storage[5] = 49;
						
					if (instruction_rd2_out[10] == 0)
						transmit_storage[6] = 48;
					else 
						transmit_storage[6] = 49;
						
					if (instruction_rd2_out[9] == 0)
						transmit_storage[7] = 48;
					else 
						transmit_storage[7] = 49;
						
					if (instruction_rd2_out[8] == 0)
						transmit_storage[8] = 48;
					else 
						transmit_storage[8] = 49;
						
					if (instruction_rd2_out[7] == 0)
						transmit_storage[9] = 48;
					else 
						transmit_storage[9] = 49;
						
					if (instruction_rd2_out[6] == 0)
						transmit_storage[10] = 48;
					else 
						transmit_storage[10] = 49;
						
					if (instruction_rd2_out[5] == 0)
						transmit_storage[11] = 48;
					else 
						transmit_storage[11] = 49;
						
					if (instruction_rd2_out[4] == 0)
						transmit_storage[12] = 48;
					else 
						transmit_storage[12] = 49;
						
					if (instruction_rd2_out[3] == 0)
						transmit_storage[13] = 48;
					else 
						transmit_storage[13] = 49;
						
					if (instruction_rd2_out[2] == 0)
						transmit_storage[14] = 48;
					else 
						transmit_storage[14] = 49;
						
					if (instruction_rd2_out[1] == 0)
						transmit_storage[15] = 48;
					else 
						transmit_storage[15] = 49;
						
					if (instruction_rd2_out[0] == 0)
						transmit_storage[16] = 48;
					else 
						transmit_storage[16] = 49;
				end
				
				if (saved_memory[0] == 74) begin // Write to Instruction Memory
					transmit_data_state_max = 17;
					instruction_wr2_enable = 1;
					
					if (saved_memory[07] == 48)
						instruction_wr2[00] = 0;
					else 
						instruction_wr2[00] = 1;
						
					if (saved_memory[06] == 48)
						instruction_wr2[01] = 0;
					else 
						instruction_wr2[01] = 1;
						
					if (saved_memory[05] == 48)
						instruction_wr2[02] = 0;
					else 
						instruction_wr2[02] = 1;
						
					if (saved_memory[04] == 48)
						instruction_wr2[03] = 0;
					else 
						instruction_wr2[03] = 1;
						
					if (saved_memory[03] == 48)
						instruction_wr2[04] = 0;
					else 
						instruction_wr2[04] = 1;
						
					if (saved_memory[02] == 48)
						instruction_wr2[05] = 0;
					else 
						instruction_wr2[05] = 1;
					
					
					
				
					if (saved_memory[24] == 48)
						instruction_wr2_data[0] = 0;
					else
						instruction_wr2_data[0] = 1;
					
					if (saved_memory[23] == 48)
						instruction_wr2_data[1] = 0;
					else
						instruction_wr2_data[1] = 1;
					
					if (saved_memory[22] == 48)
						instruction_wr2_data[2] = 0;
					else
						instruction_wr2_data[2] = 1;
					
					if (saved_memory[21] == 48)
						instruction_wr2_data[3] = 0;
					else
						instruction_wr2_data[3] = 1;
					
					if (saved_memory[20] == 48)
						instruction_wr2_data[4] = 0;
					else
						instruction_wr2_data[4] = 1;
					
					if (saved_memory[19] == 48)
						instruction_wr2_data[5] = 0;
					else
						instruction_wr2_data[5] = 1;
					
					if (saved_memory[18] == 48)
						instruction_wr2_data[6] = 0;
					else
						instruction_wr2_data[6] = 1;
					
					if (saved_memory[17] == 48)
						instruction_wr2_data[7] = 0;
					else
						instruction_wr2_data[7] = 1;
					
					if (saved_memory[16] == 48)
						instruction_wr2_data[8] = 0;
					else
						instruction_wr2_data[8] = 1;
					
					if (saved_memory[15] == 48)
						instruction_wr2_data[9] = 0;
					else
						instruction_wr2_data[9] = 1;
					
					if (saved_memory[14] == 48)
						instruction_wr2_data[10] = 0;
					else
						instruction_wr2_data[10] = 1;
					
					if (saved_memory[13] == 48)
						instruction_wr2_data[11] = 0;
					else
						instruction_wr2_data[11] = 1;
					
					if (saved_memory[12] == 48)
						instruction_wr2_data[12] = 0;
					else
						instruction_wr2_data[12] = 1;
					
					if (saved_memory[11] == 48)
						instruction_wr2_data[13] = 0;
					else
						instruction_wr2_data[13] = 1;
					
					if (saved_memory[10] == 48)
						instruction_wr2_data[14] = 0;
					else
						instruction_wr2_data[14] = 1;
					
					if (saved_memory[9] == 48)
						instruction_wr2_data[15] = 0;
					else
						instruction_wr2_data[15] = 1;
				end	
						
					
			end
			else begin
				transmit_data_state_max = 0;
				transmit_storage[0] = recieved;
			end
		end
		
		// Saved memory
		
		reg [07:00] saved_memory [24:00];
		reg [04:00] saved_counter;
		
		assign LED[07:00] = saved_memory[0];
		
				
endmodule