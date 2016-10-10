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

`include "aap.vh"


// Fetch gets the next instruction. If it is a 16-bit instruction, it will use
// the top 16 bits of the instr register, if it is  32-bit instruction, the
// second word (at the higher address) will be in the bottom 16-bits.

module Fetch (input         clk,
	      input 	    rst,

	      input [2:0]   state,       // Processor state
	      output [31:0] instr,       // Instruction fetched
	      input [23:0]  pc,          // Program counter

	      // Memory access

	      output [23:0] i_raddr,
	      input [15:0]  i_rdata
	      );

   // We own the instruction register

   reg [31:0]  instr;

   // Fetch an instruction

   always @(posedge clk or posedge rst) begin
      if (rst == 1) begin
	 instr      <= 32'b0;
      end
      else begin
	 case (state)
	   `STATE_FETCH1: begin

	      // Set address to read first word of instruction.

	      i_raddr    <= pc;
	   end

	   `STATE_FETCH2: begin

	      // Capture first word of instruction

	      instr <= {i_rdata,16'b0};

	      // Optionally set address to read second word of instruction

	      if (i_rdata[15] == 1'b1) begin
		 i_raddr      <= pc + 1;
	      end
	   end

	   `STATE_FETCH3: begin

	      // Capture second word of instruction

	      instr [15:0] <= i_rdata;

	   end

	   default: begin

	      // In other states (including HALTED) there is nothing to do

	   end
	 endcase // case (state)
      end // if (rst != 1)

   end // always @ (posedge clk)

endmodule
