// Verilog for UART transmitter

// Copyright Embecosm 2016.

// Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

// This file documents the AAP design for FPGA.  It describes Open Hardware
// and is licensed under the CERN OHL v. 1.2.

// You may redistribute and modify this documentation under the terms of the
// CERN OHL v.1.2. (http://ohwr.org/cernohl). This documentation is
// distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF
// MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR
// PURPOSE. Please see the CERN OHL v.1.2 for applicable conditions


// The design of this UART receiver is inspired by the design at
// www.nanoland.com and described on edaplayground.com

// This receiver will send one start bit, 8 data bits, one stop bit and no
// parity bit when uart_tx_en is high.  Data is latched at the start of
// transmission and rx_ack is set high for the duration of the transmission.
// uart_tx_done is driven for one clock cycle on completion of transmit.

module UartTx
  #(parameter UART_BAUD = 921600,
              CLK_RATE  = 12500000)
   (input        clk,
    input 	 rst,

    output 	 uart_tx,
    input [7:0]  uart_tx_data,
    input 	 uart_tx_en,
    output 	 uart_tx_ack,
    output 	 uart_tx_done);

   localparam CLKS_PER_BIT = CLK_RATE / UART_BAUD;
   localparam CNT_BITS     = $clog2 (CLKS_PER_BIT + 1);

   reg 		      uart_tx_ack;
   reg 		      uart_tx_done;

   // Register to latch the data

   reg [7:0] 	      uart_tx_data_latched;

   // Clock count and state machines

   reg [CNT_BITS-1:0] clk_cnt;
   reg [3:0] 	      state;

   // State machine for transmit.
   // 0:     idle
   // 1:     start bit
   // 2 - 9: data bits
   // 11:    cleanup

   always @(posedge clk or posedge rst) begin
      if (rst == 1) begin
	 state         <= 4'd0;		// Idle
	 uart_tx       <= 1'b1;
	 uart_tx_ack   <= 1'b0;
	 uart_tx_done  <= 1'b0;
      end
      else begin
	 case (state)
	   0: begin
              uart_tx      <= 1'b1;		// Drive Line high for Idle
              uart_tx_done <= 1'b0;
              clk_cnt      <= 0;

              if (uart_tx_en == 1'b1) begin

		 // Enabled, so latch data to transmit and acknowledge

		 uart_tx_data_latched <= uart_tx_data;
		 uart_tx_ack          <= 1'b1;
		 state                <= state + 4'd1;	// Start bit
              end
           end // case: 0

	   1: begin

	      // Send out Start Bit - drive line low

              uart_tx <= 1'b0;

              // Wait CLKS_PER_BIT - 1 clock cycles for bit to finish

              if (clk_cnt == (CLKS_PER_BIT - 1)) begin

		 // Bit finished, reset count and start transmitting data

		 clk_cnt <= 0;
		 state   <= state + 4'd1;	// First data bit
	      end
              else begin

		 // Still transmitting this bit

		 clk_cnt <= clk_cnt + 1;
	      end
           end // case: 1

	   2, 3, 4, 5, 6, 7, 8, 9: begin

	      // Send data bits

              uart_tx <= uart_tx_data_latched[state - 2];

              // Wait CLKS_PER_BIT - 1 clock cycles for bit to finish

              if (clk_cnt == (CLKS_PER_BIT - 1)) begin

		 // Bit finished, reset count and advance to next bit

		 clk_cnt <= 0;
		 state   <= state + 4'd1;
	      end
	      else begin

		 // Still transmitting this bit

		 clk_cnt <= clk_cnt + 1;
	      end
           end // case: 2, 3, 4, 5, 6, 7, 8, 9

	   10: begin

	      // Send out Stop bit.  Stop bit = 1

              uart_tx <= 1'b1;

              // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish

              if (clk_cnt == (CLKS_PER_BIT - 1)) begin

		 // Bit finished, reset count and advance to next bit. Also
		 // clear ack and set done.

		 clk_cnt      <= 0;
		 state        <= state + 4'd1;
		 uart_tx_ack  <= 1'b0;
		 uart_tx_done <= 1'b1;
	      end
	      else begin

		 // Still transmitting this bit

		 clk_cnt <= clk_cnt + 1;
	      end // else: !if(clk_cnt == (CLKS_PER_BIT - 1))
	   end // case: 10

	   11: begin

	      // Cleanup. Stay here one clock to reset uart_tx_done bit.

              uart_tx_done <= 1'b1;
              state        <= 4'd0;		// Idle
           end

	   default: begin

	      // Should be impossible, but just in case go back to idling

              state <= 4'd0;			// Idle
	   end
	 endcase // case (state)
      end // else: !if(rst == 1)
   end // always @ (posedge clk | posedge rst)

endmodule
