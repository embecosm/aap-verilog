// Main memory Verilog file. Small variant using block ram

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


// This memory has four ports: two read, two write, one of each for
// instruction memory and data memory.

// The basic SRAM is 256k of 16-bit words.

// Although AAP provides for up to 24-bits of instruction address, this
// implementation uses 17 bits, giving a total of 128KW.  The instruction
// memory is the first half of the SRAM.

// AAP has 16-bits of data address.  This uses the third quarter of the
// MyStorm memory and for simplicy just uses the bottom 8 bits of each word.

// We achieve the desired behavior by using the fast clock to access the
// memory four times during a main clock cycle.  We could do this better!

// - posedge 0 - read enable, set read data address
// - posedge 1 - read enable, set read instr  address
// - posedge 2 - latch read data data, write en and set write data address &
//               data
// - posedge 3 - latch read instr data, write en and set write instr address &
//               data

`include "aap.vh"

module MemorySmall (input         clk50,
		    input 	  rst,
		    input [1:0]   clk_phase,

		    // Processor state

		    input [2:0]   state,

		    // Data ports (2Kbyte avail, so [10:0] actually

		    input [15:0]  d_raddr,
		    input [15:0]  d_waddr,
		    output [7:0]  d_rdata,
		    input [7:0]   d_wdata,
		    input 	  d_we,

		    // Instruction ports (2Kword avail, so [10:0] actually
		    // used), read only.

		    input [23:0]  i_raddr,
		    output [15:0] i_rdata,

		    // Debug access to memory

		    input [15:0]  dbg_d_raddr,
		    input [15:0]  dbg_d_waddr,
		    output [7:0]  dbg_d_rdata,
		    input [7:0]   dbg_d_wdata,
		    input 	  dbg_d_we,

		    input [23:0]  dbg_i_raddr,
		    input [23:0]  dbg_i_waddr,
		    output [15:0] dbg_i_rdata,
		    input [15:0]  dbg_i_wdata,
		    input 	  dbg_i_we
		    );

   // Mux inputs according to whether we are in debug mode

   wire dbg_active = (state == `STATE_HALTED);

   wire [10:0]  real_d_raddr = dbg_active ? dbg_d_raddr[10:0] : d_raddr[10:0];
   wire [10:0] 	real_d_waddr = dbg_active ? dbg_d_waddr[10:0] : d_waddr[10:0];
   wire [7:0] 	real_d_wdata = dbg_active ? dbg_d_wdata       : d_wdata;
   wire 	real_d_we    = dbg_active ? dbg_d_we          : d_we;
   wire [10:0] 	real_i_raddr = dbg_active ? dbg_i_raddr[10:0] : i_raddr[10:0];
   wire [10:0] 	real_i_waddr =              dbg_i_waddr[10:0];

   // Register read data

   reg [7:0]  real_d_rdata;
   reg [15:0] real_i_rdata;

   // Memory *should* magically instantiate to block rams

   reg [15:0] 	imem [0:2047];
   reg [7:0] 	dmem [0:2047];

   // Do the memory access. This will take one cycle to latch the read data,,
   // but will be good by the end of the slow cycle.

   always @(posedge clk50) begin

      // Write memories

      if (real_d_we) begin
	 dmem[real_d_waddr] <= real_d_wdata;
      end

      if (dbg_i_we) begin
	 imem[real_i_waddr] <= dbg_i_wdata;
      end

      // Read memories

      real_d_rdata <= dmem[real_d_raddr];
      real_i_rdata <= imem[real_i_raddr];

   end // always @ (posedge clk50)

   // Demux the read data

   always @(*) begin
      if (dbg_active) begin
	 dbg_d_rdata = real_d_rdata;
	 dbg_i_rdata = real_i_rdata;
      end
      else begin
	 d_rdata = real_d_rdata;
	 i_rdata = real_i_rdata;
      end
   end

endmodule
