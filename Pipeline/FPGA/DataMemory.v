// Data memory Verilog file

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


module DataMemory (input        clock,
		   input [7:0] 	d_rd1,
		   input [7:0] 	d_rd2,
		   input [7:0] 	d_rd3,
		   input [7:0] 	d_rd4,
		   output [7:0] d_rd1_out,
		   output [7:0] d_rd2_out,
		   output [7:0] d_rd3_out,
		   output [7:0] d_rd4_out,
		   input [7:0] 	d_wr1,
		   input [7:0] 	d_wr2,
		   input [7:0] 	d_wr3,
		   input [7:0] 	d_wr4,
		   input [7:0] 	d_wr1_data,
		   input [7:0] 	d_wr2_data,
		   input [7:0] 	d_wr3_data,
		   input [7:0] 	d_wr4_data,
		   input 	d_wr1_en,
		   input 	d_wr2_en,
		   input 	d_wr3_en,
		   input 	d_wr4_en );

   // This register has eight ports: four read, four write

   // Registers //
   reg [7:0] d_memory [128:0];

   // Read logic //
   // This is combinatoral, this happens automatically
   assign d_rd1_out = d_memory[d_rd1];
   assign d_rd2_out = d_memory[d_rd2];
   assign d_rd3_out = d_memory[d_rd3];
   assign d_rd4_out = d_memory[d_rd4];

   // Write logic //
   // this is sequential, it will only happen on the clock or reset
   always @(posedge clock) begin
      if (d_wr1_en == 1) begin
	 d_memory[d_wr1] <= d_wr1_data;
      end

      if (d_wr2_en == 1) begin
	 d_memory[d_wr2] <= d_wr2_data;
      end

      if (d_wr3_en == 1) begin
	 d_memory[d_wr3] <= d_wr3_data;
      end

      if (d_wr4_en == 1) begin
	 d_memory[d_wr4] <= d_wr4_data;
      end
   end

endmodule
