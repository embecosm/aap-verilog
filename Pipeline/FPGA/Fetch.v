// Verilog for processor fetch

// Copyright Embecosm 2015, 2016.

// Contributor Dan Gorringe <dan.gorringe@embecosm.com>
// Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

// This file documents the AAP design for FPGA.  It describes Open Hardware
// and is licensed under the CERN OHL v. 1.2.

// You may redistribute and modify this documentation under the terms of the
// CERN OHL v.1.2. (http://ohwr.org/cernohl). This documentation is
// distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF
// MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR
// PURPOSE. Please see the CERN OHL v.1.2 for applicable conditions


// Common constants

`include "aap.h"


// Fetch gets the next instruction. If it is a 16-bit instruction, it will use
// the top 16 bits of the instr register, if it is  32-bit instruction, the
// second word (at the higher address) will be in the bottom 16-bits.

module Fetch (input         clk,
	      input 	    rst,

	      input [1:0]   state,       // Processor state
	      output [31:0] instr,       // Instruction fetched
	      input [23:0]  pc,          // Program counter
	      output 	    fetch_done,  // When we finish fetching

	      // Memory access

	      output [23:0] i_raddr,
	      input [15:0]  i_rdata
	      );

   // We own the instruction register

   reg [31:0]  instr;

   // Fetch is complete if the top bit of the first 16-bits we read was 1'b0
   // or we have read 32 bits. We have no mechanism to read more than 32-bits.

   reg 	       fetch_done;

   // Fetch an instruction

   always @(posedge clk) begin
      if (rst == 1) begin
	 instr      <= 32'b0;
	 fetch_done <= 1'b0;
      end
      else begin
	 case (state)
	   `STATE_FETCH: begin

	      // Read second word of instruction. We are always done after
	      // this.

	      i_raddr     <= pc + 1;
	      instr[15:0] <= i_rdata;
	      fetch_done  <= 1'b1;
	   end

	   default: begin

	      // In other states, just reinforce that fetch is complete.

	      fetch_done  <= 1'b1;

	   end
	 endcase // case (state)

      end // if (rst != 1)

   end // always @ (posedge clk)

endmodule
