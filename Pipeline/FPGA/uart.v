module uart (	clock,
					superclock,
					reset,
					UART_TX,
					UART_RX,
					reg_rd3,
					reg_rd3_out,
					reg_wr3_data,
					reg_wr3,
					reg_wr3_en,
					i_rd2_addr,
					i_rd2_out,
					i_wr2_addr,
					i_wr2_data,
					i_wr2_en,
					d_rd3,
					d_rd3_out,
					d_wr3,
					d_wr3_data,
					d_wr3_en,
					pc,
					prev_pc,
					uart_stop,
					uart_continue,
					uart_step_en,
					uart_step_volume,
					uart_reset
				);

	input				clock;
	input				reset;
	input				superclock;

	output reg		uart_reset;

	output reg 		UART_TX;
	input				UART_RX;

	output	[05:00]reg_rd3;
	input		[15:00]reg_rd3_out;
	output	[15:00]reg_wr3_data;
	output 	[05:00]reg_wr3;
	output 	reg_wr3_en;

	output	[05:00]	i_rd2_addr;
	input		[15:00]	i_rd2_out;
	output	[15:00]	i_wr2_data;
	output	[05:00]	i_wr2_addr;
	output	i_wr2_en;

	output	[07:00]	d_rd3;
	input		[07:00]	d_rd3_out;
	output	[07:00]	d_wr3;
	output	[07:00]	d_wr3_data;
	output	d_wr3_en;

	output reg uart_stop;
	output reg uart_continue;
	output reg uart_step_en;
	output reg [05:00] uart_step_volume;



	input [05:00] prev_pc;
	input [05:00] pc;

	reg [05:00] reg_rd3;
	reg [05:00] reg_wr3;
	reg [15:00] reg_wr3_data;
	reg reg_wr3_en;

	reg [05:00]	i_rd2_addr;
	reg [05:00]	i_wr2_addr;
	reg [15:00]	i_wr2_data;
	reg i_wr2_en;

	reg [07:00] d_rd3;
	reg [07:00] d_wr3;
	reg [07:00] d_wr3_data;
	reg d_wr3_en;

 	//output [07:00] LED;

	//UART transmit at 300 baud from 50MHz clock
	reg [16:00] 		clock_divider_counter;
   reg 				uart_clock;

	// Clock counter
	always @(posedge superclock) begin
     if (reset == 1'b1)
			//uart_clock = 0;
			clock_divider_counter = 0;
		else if (clock_divider_counter == 83333)
			clock_divider_counter = 0;
		else
			clock_divider_counter = clock_divider_counter + 1; 	// Otherwise increment the counter
	end

	// Generate a clock (toggle this register)
   always @(posedge superclock) begin
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
							if (transmit_d_state == 0) 	// Waiting to be allowed to transmit
								if (write_en == 1)
									transmit_state = 1;
							if (transmit_d_state !== 0) 	// If transmitting stuff carry on
								transmit_state = 1;
						end
					1:
						begin
							UART_TX = 0;			//bit goes down
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

							if (transmit_d_state !== transmit_d_state_max) // Transmitted everything?
								transmit_d_state = transmit_d_state + 1;		//increment counter
							else
								transmit_d_state = 0;


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
		reg write_en;
		reg [7:0] transmit_storage [63:00];
		reg [5:0] transmit_d_state;
		reg [5:0] transmit_d_state_max;
		reg [5:0] saved;

		// Saved memory

		reg [07:00] saved_memory [31:00];
		reg [07:00] saved_counter;

		always @(posedge uart_clock or posedge reset) begin 		// Recieve
			if (reset) begin
	     // Reset to the "IDLE" state
				recieve_state <= 0;
				saved_counter = 0;
			end
			else begin
				case (recieve_state)

					0:
						begin
							write_en = 0;
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
							write_en = 1;
							saved_memory[saved_counter] = recieved;
							if (saved_memory[saved_counter] == 13)	// if enter
								saved_counter <= 0;						// reset
							else
								saved_counter <= saved_counter + 1;	// else increment
						end
					default:
						recieve_state = 0;
				endcase
			end

		end

		always @(posedge clock) begin
			transmit_data = transmit_storage[transmit_d_state];
		end

		always @(posedge uart_clock) begin
			reg_wr3_en = 0;
			d_wr3_en = 0;
			i_wr2_en = 0;
			uart_step_en = 0;
			uart_stop = 0;
			uart_continue = 0;
			uart_reset = 0;
			if (recieved == 13) begin
				//saved_counter <= 0;
				if (saved_memory[0] == 67) begin// Continue
					uart_continue = 1;
					transmit_storage[0] <= 32;
					uart_step_en = 0;
				end
				if (saved_memory[0] == 83) begin//Stop
					uart_stop = 1;
					transmit_storage[0] <= 32;
				end
				if (saved_memory[0] == 43) begin//Step
					uart_step_en = 1;

					uart_step_volume[00] = saved_memory[07] - 48;
					uart_step_volume[01] = saved_memory[06] - 48;
					uart_step_volume[02] = saved_memory[05] - 48;
					uart_step_volume[03] = saved_memory[04] - 48;
					uart_step_volume[04] = saved_memory[03] - 48;
					uart_step_volume[05] = saved_memory[02] - 48;
				end
				if (saved_memory[0] == 82) begin//Reset
					uart_reset = 1;
					transmit_storage[0] <= 32;
				end
				if (saved_memory[0] == 42) begin
					transmit_d_state_max = 4;
					transmit_storage[0] <= 32;
					transmit_storage[1] <= 68;
					transmit_storage[2] <= 97;
					transmit_storage[3] <= 110;
					transmit_storage[4] <= 33;
				end
				if (saved_memory[0] == 47) begin
					transmit_d_state_max = 8;
					transmit_storage[0] <= 32;
					transmit_storage[1] <= 78;
					transmit_storage[2] <= 111;
					transmit_storage[3] <= 116;
					transmit_storage[4] <= 32;
					transmit_storage[5] <= 68;
					transmit_storage[6] <= 97;
					transmit_storage[7] <= 110;
					transmit_storage[8] <= 33;
				end

				if (saved_memory[0] == 126) begin // previous program counter
					transmit_d_state_max = 6;
					transmit_storage[0] <= 32;

					if (prev_pc[05] == 0)
						transmit_storage[01] <= 48;
					if (prev_pc[05] == 1)
						transmit_storage[01] <= 49;

					if (prev_pc[04] == 0)
						transmit_storage[02] <= 48;
					if (prev_pc[04] == 1)
						transmit_storage[02] <= 49;

					if (prev_pc[03] == 0)
						transmit_storage[03] <= 48;
					if (prev_pc[03] == 1)
						transmit_storage[03] <= 49;

					if (prev_pc[02] == 0)
						transmit_storage[04] <= 48;
					if (prev_pc[02] == 1)
						transmit_storage[04] <= 49;

					if (prev_pc[01] == 0)
						transmit_storage[05] <= 48;
					if (prev_pc[01] == 1)
						transmit_storage[05] <= 49;

					if (prev_pc[00] == 0)
						transmit_storage[06] <= 48;
					if (prev_pc[00] == 1)
						transmit_storage[06] <= 49;


				end

				if (saved_memory[0] == 112) begin // current pc (dosnt work?)
					transmit_d_state_max = 6;
					transmit_storage[0] <= 32;

					if (pc[05] == 0)
						transmit_storage[01] <= 48;
					if (pc[05] == 1)
						transmit_storage[01] <= 49;

					if (pc[04] == 0)
						transmit_storage[02] <= 48;
					if (pc[04] == 1)
						transmit_storage[02] <= 49;

					if (pc[03] == 0)
						transmit_storage[03] <= 48;
					if (pc[03] == 1)
						transmit_storage[03] <= 49;

					if (pc[02] == 0)
						transmit_storage[04] <= 48;
					if (pc[02] == 1)
						transmit_storage[04] <= 49;

					if (pc[01] == 0)
						transmit_storage[05] <= 48;
					if (pc[01] == 1)
						transmit_storage[05] <= 49;

					if (pc[00] == 0)
						transmit_storage[06] <= 48;
					if (pc[00] == 1)
						transmit_storage[06] <= 49;


				end

				if (saved_memory[0] == 71) begin // Read a register

					transmit_d_state_max = 16;

					reg_rd3[00] = saved_memory[07] - 48;
					reg_rd3[01] = saved_memory[06] - 48;
					reg_rd3[02] = saved_memory[05] - 48;
					reg_rd3[03] = saved_memory[04] - 48;
					reg_rd3[04] = saved_memory[03] - 48;
					reg_rd3[05] = saved_memory[02] - 48;

					transmit_storage[00] <= 32;
					transmit_storage[01] <= reg_rd3_out[15] + 48;
					transmit_storage[02] <= reg_rd3_out[14] + 48;
					transmit_storage[03] <= reg_rd3_out[13] + 48;
					transmit_storage[04] <= reg_rd3_out[12] + 48;
					transmit_storage[05] <= reg_rd3_out[11] + 48;
					transmit_storage[06] <= reg_rd3_out[10] + 48;
					transmit_storage[07] <= reg_rd3_out[09] + 48;
					transmit_storage[08] <= reg_rd3_out[08] + 48;
					transmit_storage[09] <= reg_rd3_out[07] + 48;
					transmit_storage[10] <= reg_rd3_out[06] + 48;
					transmit_storage[11] <= reg_rd3_out[05] + 48;
					transmit_storage[12] <= reg_rd3_out[04] + 48;
					transmit_storage[13] <= reg_rd3_out[03] + 48;
					transmit_storage[14] <= reg_rd3_out[02] + 48;
					transmit_storage[15] <= reg_rd3_out[01] + 48;
					transmit_storage[16] <= reg_rd3_out[00] + 48;

				end

				if (saved_memory[0] == 87) begin // Write to register
					transmit_d_state_max = 16;
					reg_wr3_en = 1;

					reg_wr3[00] = saved_memory[07] - 48;
					reg_wr3[01] = saved_memory[06] - 48;
					reg_wr3[02] = saved_memory[05] - 48;
					reg_wr3[03] = saved_memory[04] - 48;
					reg_wr3[04] = saved_memory[03] - 48;
					reg_wr3[05] = saved_memory[02] - 48;

					reg_wr3_data[00] = saved_memory[24] - 48;
					reg_wr3_data[01] = saved_memory[23] - 48;
					reg_wr3_data[02] = saved_memory[22] - 48;
					reg_wr3_data[03] = saved_memory[21] - 48;
					reg_wr3_data[04] = saved_memory[20] - 48;
					reg_wr3_data[05] = saved_memory[19] - 48;
					reg_wr3_data[06] = saved_memory[18] - 48;
					reg_wr3_data[07] = saved_memory[17] - 48;
					reg_wr3_data[08] = saved_memory[16] - 48;
					reg_wr3_data[09] = saved_memory[15] - 48;
					reg_wr3_data[10] = saved_memory[14] - 48;
					reg_wr3_data[11] = saved_memory[13] - 48;
					reg_wr3_data[12] = saved_memory[12] - 48;
					reg_wr3_data[13] = saved_memory[11] - 48;
					reg_wr3_data[14] = saved_memory[10] - 48;
					reg_wr3_data[15] = saved_memory[09] - 48;

				end

				if (saved_memory[0] == 68) begin // Read data memory
					transmit_d_state_max = 8;

					d_rd3[00] = saved_memory[09] - 48;
					d_rd3[01] = saved_memory[08] - 48;
					d_rd3[02] = saved_memory[07] - 48;
					d_rd3[03] = saved_memory[06] - 48;
					d_rd3[04] = saved_memory[05] - 48;
					d_rd3[05] = saved_memory[04] - 48;
					d_rd3[06] = saved_memory[03] - 48;
					d_rd3[07] = saved_memory[02] - 48;

					transmit_storage[00] <= 32;
					transmit_storage[01] <= d_rd3_out[07] + 48;
					transmit_storage[02] <= d_rd3_out[06] + 48;
					transmit_storage[03] <= d_rd3_out[05] + 48;
					transmit_storage[04] <= d_rd3_out[04] + 48;
					transmit_storage[05] <= d_rd3_out[03] + 48;
					transmit_storage[06] <= d_rd3_out[02] + 48;
					transmit_storage[07] <= d_rd3_out[01] + 48;

				end

				if (saved_memory[0] == 69) begin // Write data memory

					transmit_d_state_max = 18;
					d_wr3_en = 1;

					d_wr3[01] = saved_memory[08] - 48;
					d_wr3[02] = saved_memory[07] - 48;
					d_wr3[03] = saved_memory[06] - 48;
					d_wr3[04] = saved_memory[05] - 48;
					d_wr3[05] = saved_memory[04] - 48;
					d_wr3[06] = saved_memory[03] - 48;
					d_wr3[07] = saved_memory[02] - 48;

					d_wr3_data[00] = saved_memory[17] - 48;
					d_wr3_data[01] = saved_memory[16] - 48;
					d_wr3_data[02] = saved_memory[15] - 48;
					d_wr3_data[03] = saved_memory[14] - 48;
					d_wr3_data[04] = saved_memory[13] - 48;
					d_wr3_data[05] = saved_memory[12] - 48;
					d_wr3_data[06] = saved_memory[11] - 48;
					d_wr3_data[07] = saved_memory[10] - 48;

				/*
					transmit_storage[00] = 32;
					transmit_storage[01] = d_wr3[05] + 48;
					transmit_storage[02] = d_wr3[04] + 48;
					transmit_storage[03] = d_wr3[03] + 48;
					transmit_storage[04] = d_wr3[02] + 48;
					transmit_storage[05] = d_wr3[01] + 48;
					transmit_storage[06] = d_wr3[00] + 48;
					transmit_storage[07] = 32;
					transmit_storage[08] = d_wr3_data[07] + 48;
					transmit_storage[09] = d_wr3_data[06] + 48;
					transmit_storage[10] = d_wr3_data[05] + 48;
					transmit_storage[11] = d_wr3_data[04] + 48;
					transmit_storage[12] = d_wr3_data[03] + 48;
					transmit_storage[13] = d_wr3_data[02] + 48;
					transmit_storage[14] = d_wr3_data[01] + 48;
					transmit_storage[15] = d_wr3_data[00] + 48;
					transmit_storage[16] = 32;
					transmit_storage[17] = d_wr3_en + 48;
				*/
				end

				if (saved_memory[0] == 73) begin // Read from Instruction memory
					transmit_d_state_max = 16;

					i_rd2_addr[00] = saved_memory[07] - 48;
					i_rd2_addr[01] = saved_memory[06] - 48;
					i_rd2_addr[02] = saved_memory[05] - 48;
					i_rd2_addr[03] = saved_memory[04] - 48;
					i_rd2_addr[04] = saved_memory[03] - 48;
					i_rd2_addr[05] = saved_memory[02] - 48;

					transmit_storage[00] <= 32;
					transmit_storage[01] <= i_rd2_out[15] + 48;
					transmit_storage[02] <= i_rd2_out[14] + 48;
					transmit_storage[03] <= i_rd2_out[13] + 48;
					transmit_storage[04] <= i_rd2_out[12] + 48;
					transmit_storage[05] <= i_rd2_out[11] + 48;
					transmit_storage[06] <= i_rd2_out[10] + 48;
					transmit_storage[07] <= i_rd2_out[09] + 48;
					transmit_storage[08] <= i_rd2_out[08] + 48;
					transmit_storage[09] <= i_rd2_out[07] + 48;
					transmit_storage[10] <= i_rd2_out[06] + 48;
					transmit_storage[11] <= i_rd2_out[05] + 48;
					transmit_storage[12] <= i_rd2_out[04] + 48;
					transmit_storage[13] <= i_rd2_out[03] + 48;
					transmit_storage[14] <= i_rd2_out[02] + 48;
					transmit_storage[15] <= i_rd2_out[01] + 48;
					transmit_storage[16] <= i_rd2_out[00] + 48;



				end

				if (saved_memory[0] == 74) begin // Write to Instruction Memory

					transmit_d_state_max = 26;

					i_wr2_en = 1;

					i_wr2_addr[00] = saved_memory[07] - 48;
					i_wr2_addr[01] = saved_memory[06] - 48;
					i_wr2_addr[02] = saved_memory[05] - 48;
					i_wr2_addr[03] = saved_memory[04] - 48;
					i_wr2_addr[04] = saved_memory[03] - 48;
					i_wr2_addr[05] = saved_memory[02] - 48;

					i_wr2_data[00] = saved_memory[24] - 48; // 48 = ascii 0
					i_wr2_data[01] = saved_memory[23] - 48;
					i_wr2_data[02] = saved_memory[22] - 48;
					i_wr2_data[03] = saved_memory[21] - 48;
					i_wr2_data[04] = saved_memory[20] - 48;
					i_wr2_data[05] = saved_memory[19] - 48;
					i_wr2_data[06] = saved_memory[18] - 48;
					i_wr2_data[07] = saved_memory[17] - 48;
					i_wr2_data[08] = saved_memory[16] - 48;
					i_wr2_data[09] = saved_memory[15] - 48;
					i_wr2_data[10] = saved_memory[14] - 48;
					i_wr2_data[11] = saved_memory[13] - 48;
					i_wr2_data[12] = saved_memory[12] - 48;
					i_wr2_data[13] = saved_memory[11] - 48;
					i_wr2_data[14] = saved_memory[10] - 48;
					i_wr2_data[15] = saved_memory[09] - 48;


					transmit_storage[00] <= 32;
					transmit_storage[01] <= i_wr2_addr[05] + 48;
					transmit_storage[02] <= i_wr2_addr[04] + 48;
					transmit_storage[03] <= i_wr2_addr[03] + 48;
					transmit_storage[04] <= i_wr2_addr[02] + 48;
					transmit_storage[05] <= i_wr2_addr[01] + 48;
					transmit_storage[06] <= i_wr2_addr[00] + 48;
					transmit_storage[07] <= 32;
					transmit_storage[08] <= i_wr2_data[15] + 48;
					transmit_storage[09] <= i_wr2_data[14] + 48;
					transmit_storage[10] <= i_wr2_data[13] + 48;
					transmit_storage[11] <= i_wr2_data[12] + 48;
					transmit_storage[12] <= i_wr2_data[11] + 48;
					transmit_storage[13] <= i_wr2_data[10] + 48;
					transmit_storage[14] <= i_wr2_data[09] + 48;
					transmit_storage[15] <= i_wr2_data[08] + 48;
					transmit_storage[16] <= i_wr2_data[07] + 48;
					transmit_storage[17] <= i_wr2_data[06] + 48;
					transmit_storage[18] <= i_wr2_data[05] + 48;
					transmit_storage[19] <= i_wr2_data[04] + 48;
					transmit_storage[20] <= i_wr2_data[03] + 48;
					transmit_storage[21] <= i_wr2_data[02] + 48;
					transmit_storage[22] <= i_wr2_data[01] + 48;
					transmit_storage[23] <= i_wr2_data[00] + 48;
					transmit_storage[24] <= 32;
					transmit_storage[25] <= i_wr2_en + 48;

				end

				else begin //Space
					//transmit_d_state_max = 1;
					transmit_storage[0] <= 32;
				end

			//	else begin
			//	transmit_d_state_max = 0;
			//	transmit_storage[0] = recieved;
			//	end

			end

			else begin									// Transmit what is being typed
				transmit_d_state_max = 0;
				transmit_storage[0] <= recieved;
			end
		end

//		assign LED[07:00] = saved_memory[0];
//		assign LED[07:00] = prev_pc;


endmodule
