// Instruction memory Verilog file

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


// This memory has four ports: two read, two write.  Although AAP provides for
// up to 24-bits of instruction address, this implementation uses just 17
// bits, giving a total of 128KW.  The MyStorm has a 256kW SRAM, and the
// instruction memory is the first half of this.

// We achieve the desired behavior by using the fast clock to access the
// memory four times during a main clock cycle.  We could do this better!

// - posedge 0 - read enable, set read1 address
// - posedge 1 - latch read1 data, write enable and set write1 address & data
// - posedge 2 - read enable, set read2 address
// - posedge 3 - latch read2 data, write enable and set write2 address & data

module InstructionMemory (input         clk50,
			  input [1:0]	clk_phase,

			  // External SRAM

			  output 	ram_we,
			  output 	ram_oe,

			  output [17:0] ram_addr,
			  inout [15:0] 	ram_data,

			  // Port 1

			  input [16:0] 	i_rd1_addr,
			  input [16:0] 	i_wr1_addr,
			  input [15:0] 	i_wr1_data,
			  input 	i_wr1_en,
			  output [15:0] i_rd1_data,

			  // Port 2

			  input [16:0] 	i_rd2_addr,
			  input [16:0] 	i_wr2_addr,
			  input [15:0] 	i_wr2_data,
			  input 	i_wr2_en,
			  output [15:0] i_rd2_data );

   reg [15:0] i_rd1_data_latched;
   reg [15:0] i_rd2_data_latched;

   assign i_rd1_data = i_rd1_data_latched;
   assign i_rd2_data = i_rd2_data_latched;

   always @(posedge clk50) begin
      case (clk_phase)
	2'b00: begin
	   ram_we <= 0;
	   ram_oe <= 1;
	   ram_addr <= {1'b0,i_rd1_addr};
	end

	2'b01: begin
	   i_rd1_data_latched <= ram_data;
	   ram_we <= i_wr1_en;
	   ram_oe <= 0;
	   ram_addr <= {1'b0,i_wr1_addr};
	   ram_data <= i_wr1_data;
	end

	2'b10: begin
	   ram_we <= 0;
	   ram_oe <= 1;
	   ram_addr <= {1'b0,i_rd2_addr};
	end

	2'b11: begin
	   i_rd2_data_latched <= ram_data;
	   ram_we <= i_wr2_en;
	   ram_oe <= 0;
	   ram_addr <= {1'b0,i_wr2_addr};
	   ram_data <= i_wr2_data;
	end
      endcase // case (clk_phase)
   end

endmodule
