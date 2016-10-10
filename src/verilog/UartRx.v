// Verilog for UART receiver

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

// This receiver will accept one start bit, 8 data bits, one stop bit and no
// parity bit.  uart_rx_valid is driven for one clock cycle on completion of
// receive.

module UartRx
  #(parameter UART_BAUD = 921600,
              CLK_RATE  = 12500000)
   (input 	 clk,
    input 	 rst,
    input 	 uart_rx,
    output 	 uart_rx_valid,
    output [7:0] uart_rx_data);

   localparam CLKS_PER_BIT = CLK_RATE / UART_BAUD;
   localparam CNT_BITS     = $clog2 (CLKS_PER_BIT + 1);

   // Register outputs

   reg                uart_rx_valid;
   reg [7:0] 	      uart_rx_data;

   // Clock count and state machine

   reg [CNT_BITS-1:0] clk_cnt;
   reg [3:0] 	      state;

   // State machine for receive.
   // 0:     idle
   // 1:     start bit
   // 2 - 9: data bits
   // 11:    cleanup

   always @(posedge clk or posedge rst) begin
      if (rst == 1) begin
	 state         <= 4'd0;			// Idle
	 uart_rx_valid <= 1'b0;
      end
      else begin
	 case (state)
	   0: begin

	      // Idle state

              uart_rx_valid <= 1'b0;
              clk_cnt       <= 0;

	      // 0 input is the start bit

              if (uart_rx == 1'b0) begin
		 state <= (uart_rx == 1'b0) ? 4'd1 : 4'd0;
	      end
           end

	   1: begin

	      // Check middle of start bit is still low

              if (clk_cnt == ((CLKS_PER_BIT - 1) / 2)) begin

		 // Found the middle of the bit

		 if (uart_rx == 1'b0)  begin

		    // Really is a start bit

		    clk_cnt <= 0;	// Reset counter, found the middle
		    state   <= 4'd2;	// First data bit
		 end
		 else begin

		    // Not really a start bit - try again

		    state <= 4'd0;	// Idle
		 end
              end
              else begin

		 // Still looking for the middle of the start bit

		 clk_cnt <= clk_cnt + 1;
              end
           end // case: 1

	   2, 3, 4, 5, 6, 7, 8, 9: begin

	      // Data bits. Wait CLKS_PER_BIT - 1 cycles to ensure we are in
	      // the middle of the UART bit.

              if (clk_cnt == (CLKS_PER_BIT - 1)) begin

		 // Found the middle of the bit, save the data and reset for
		 // the next bit and advance the state.

		 uart_rx_data[state - 2] <= uart_rx;
		 clk_cnt                 <= 0;
		 state                   <= state + 4'd1;
	      end
	      else begin

		 // Still waiting for the middle of the bit

		 clk_cnt <= clk_cnt + 1;
	      end
	   end // case: 2, 3, 4, 5, 6, 7, 8, 9


	   10: begin

	      // Stop bit. Wait CLKS_PER_BIT - 1 cycles to ensure we are in
	      // the middle of the UART bit.

	      if (clk_cnt == (CLKS_PER_BIT - 1)) begin

		 // Found the middle of the bit.  Mark the data as valid

       		 uart_rx_valid <= 1'b1;
		 clk_cnt       <= 0;
		 state         <= 11;		// Cleanup
	      end
	      else begin

		 // Still waiting for the middel of the bit

		 clk_cnt <= clk_cnt + 1;
	      end
	   end // case: 10

	   11: begin

	      // Cleanup - just stay for one clock cycle to toggle the valid
	      // flag.

              uart_rx_valid <= 1'b0;
              state         <= 0;		// Idle
           end

	   default: begin

	     // Should be impossible, but if we get here, go to the default
	     // state.

             state <= 0;
	   end
	 endcase // case (state)
      end // else: !if(rst == 1)
   end

endmodule // UartRx
