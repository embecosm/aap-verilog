// Main SRAM memory Verilog file

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

module Memory (input         clk50,
	       input 	     rst,
	       input [1:0]   clk_phase,

	       // Processor state

	       input [2:0]   state,

	       // External SRAM

	       output [17:0] ram_addr,
	       inout [15:0]  ram_data,
	       output 	     ram_oe,
	       output 	     ram_we,

	       // Data ports (64Kbyte)

	       input [15:0]  d_raddr,
	       input [15:0]  d_waddr,
	       output [7:0]  d_rdata,
	       input [7:0]   d_wdata,
	       input 	     d_we,

	       // Instruction ports (128Kword avail, so [16:0] actually used),
	       // read only.

	       input [23:0]  i_raddr,
	       output [15:0] i_rdata,

	       // Debug access to memory

	       input [15:0]  dbg_d_raddr,
	       input [15:0]  dbg_d_waddr,
	       output [7:0]  dbg_d_rdata,
	       input [7:0]   dbg_d_wdata,
	       input 	     dbg_d_we,

	       input [23:0]  dbg_i_raddr,
	       input [23:0]  dbg_i_waddr,
	       output [15:0] dbg_i_rdata,
	       input [15:0]  dbg_i_wdata,
	       input 	     dbg_i_we
	       );

   // Mux inputs according to whether we are in debug mode

   wire [15:0]  real_d_raddr = (state == `STATE_HALTED) ? dbg_d_raddr : d_raddr;
   wire [15:0] 	real_d_waddr = (state == `STATE_HALTED) ? dbg_d_waddr : d_waddr;
   wire [7:0] 	real_d_wdata = (state == `STATE_HALTED) ? dbg_d_wdata : d_wdata;
   wire 	real_d_we    = (state == `STATE_HALTED) ? dbg_d_we    : d_we;
   wire [23:0] 	real_i_raddr = (state == `STATE_HALTED) ? dbg_i_raddr : i_raddr;

   // Outputs for demuxing

   wire [7:0] 	real_d_rdata;
   wire [15:0] 	real_i_rdata;

   // write data temporary

   wire [15:0] wdata;

   // Combinatorial demux of outputs

   always @(*) begin
      if (state == `STATE_HALTED) begin
	 dbg_d_rdata = real_d_rdata;
	 dbg_i_rdata = real_i_rdata;
      end
      else begin
	 d_rdata = real_d_rdata;
	 i_rdata = real_i_rdata;
      end
   end

   // Combinatorial write of ram_data on phases after WE was assigned.

   always @(*) begin
      if ((clk_phase == 2'b00) || (clk_phase == 2'b11)) begin
	 ram_data = wdata;
      end
   end

   always @(posedge clk50 or posedge rst) begin
      if (rst == 1'b1) begin
	 ram_addr <= 18'b0;
	 ram_we   <= 1'b0;
	 ram_oe   <= 1'b0;
      end
      else begin

	 case (clk_phase)
	   2'b00: begin
	      // Set address for read data
	      ram_we   <= 0;
	      ram_oe   <= 1;
	      ram_addr <= {2'b10,real_d_raddr};
	   end

	   2'b01: begin
	      // Latch read data
	      real_d_rdata <= ram_data[7:0];
	      // Set address for read instr
	      ram_we   <= 0;
	      ram_oe   <= 1;
	      ram_addr <= {1'b0,real_i_raddr[16:0]};
	   end

	   2'b10: begin
	      // Latch read instr
	      real_i_rdata <= ram_data;
	      // Set address and data for write data
	      ram_we   <= real_d_we;
	      ram_oe   <= 0;
	      ram_addr <= {2'b10,real_d_waddr};
	      wdata    <= {8'b0,real_d_wdata};
	   end

	   2'b11: begin
	      // Set address and data for write instr
	      ram_we   <= dbg_i_we;
	      ram_oe   <= 0;
	      ram_addr <= {1'b0,dbg_i_waddr[16:0]};
	      wdata    <= dbg_i_wdata;
	   end
	 endcase // case (clk_phase)
      end
   end

endmodule
