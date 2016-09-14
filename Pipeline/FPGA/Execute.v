// Verilog for processor execute stage

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


// This module can read (combinatorially) and write (sequentially) 3 registers
// per clock cycle.

module Execute (input         clk,
		input 	      rst,

		// Register access

		output [5:0]  rega_rregnum,
		output [5:0]  rega_wregnum,
		input [15:0]  rega_rdata,
		output [15:0] rega_wdata,
		output 	      rega_we,

		output [5:0]  regb_rregnum,
		output [5:0]  regb_wregnum,
		input [15:0]  regb_rdata,
		output [15:0] regb_wdata,
		output 	      regb_we,

		output [5:0]  regd_rregnum,
		output [5:0]  regd_wregnum,
		input [15:0]  regd_rdata,
		output [15:0] regd_wdata,
		output 	      regd_we,

		// Memory access. Only set instruction reading.

		output [23:0] i_raddr,
		input [15:0]  i_rdata,

		output [15:0] d_raddr,
		output [15:0] d_waddr,
		input [7:0]   d_rdata,
		output [7:0]  d_wdata,
		output 	      d_we
		);

   // The instruction currently being processed.

   wire [31:0]  instr;

   // Processor state

   reg [23:0]  next_pc;
   wire [23:0] pc = next_pc;

   reg [2:0]   next_state;
   wire [2:0]  state = next_state ;

   reg 	       next_carry;
   wire	       carry = next_carry;

   // Generic opcode fields. 0 top bits for 16-bit

   wire [3:0]  opf_class   = {instr[14:13],instr[30:29]};
   wire [7:0]  opf_opcode  = {instr[12:9],instr[28:25]};
   wire [5:0]  opf_rd      = {instr[8:6],instr[24:22]};
   wire [5:0]  opf_ra      = {instr[5:3],instr[21:19]};
   wire [5:0]  opf_rb      = {instr[2:0],instr[18:16]};

   // 16-bit instruction immediate fields.

   // All signed fields are used for address calculation, so sign extended to
   // 16 (for data addresses) or 24 bits (for instruction addresses).  This
   // uses the formula ((x ^ n) - n) to sign extend from n bits, from the
   // Magic Aggregate Algorithms. See

   //   http://aggregate.org/MAGIC/#Sign%20Extension

   // Note that there are two variations of the 3-bit signed immediate and
   // there is a 32-bit variant of the 6-bit unsigned immediate.

   wire [2:0]  opf_imm3    = instr[18:16];
   wire [15:0] opf_simm3b  = (({13'b0,instr[18:16]} ^ 16'h4) - 16'h4);
   wire [23:0] opf_simm3d  = (({21'b0,instr[24:22]} ^ 24'h4) - 24'h4);
   wire [5:0]  opf_imm6_16 = instr[21:16];
   wire [23:0] opf_simm6   = (({18'b0,instr[24:19]} ^ 24'h20) - 24'h20);
   wire [23:0] opf_simm9   = (({15'b0,instr[24:16]} ^ 24'h100) - 24'h100);

   // 32-bit instruction immediate fields.  All signed fields are again used
   // for address calculation, so sign extended to 24 bits.

   // Note that there are two variations of the 10-bit signed immediate

/* -----\/----- EXCLUDED -----\/-----
   wire [5:0]  opf_imm6_32 = {instr[2:0],instr[18:16]};
   wire [8:0]  opf_imm9	   = {instr[12:10],instr[2:0],instr[18:16]};
   wire [9:0]  opf_imm10   = {instr[12:9],instr[2:0],instr[18:16]};
   wire [23:0] opf_simm10b = (({14'b0,instr[12:9],instr[2:0],instr[18:16]}
			       ^ 24'h200) - 24'h200);
   wire [23:0] opf_simm10d = (({14'b0,instr[12:6],instr[24:22]}
			       ^ 24'h200) - 24'h200);
   wire [11:0] opf_imm12   = {instr[5:0],instr[21:16]};
   wire [15:0] opf_imm16   = {instr[12:9],instr[5:0],instr[21:16]};
   wire [23:0] opf_simm16  = (({8'b0,instr[12:3],instr[24:19]}
			       ^ 24'h8000) - 24'h8000);
   wire [23:0] opf_simm22  = (({2'b0,instr[12:0],instr[24:16]}
			       ^ 24'h200000) - 24'h200000);
 -----/\----- EXCLUDED -----/\----- */

   // Net to ignore

   wire        dummy;

   // Execute logic

   always @(posedge clk) begin
      if (rst == 1) begin
	 next_carry <= 1'b0;
      end
      else begin
	 case (state)

	   `STATE_FETCH1: begin

	      // 16-bit instruction or first part of 32-bit instruction.

	      instr[31:16] <= i_rdata;
	      i_raddr      <= pc + 1;
	      next_state <= `STATE_FETCH2;
	   end

	   `STATE_FETCH2: begin

	      // second part of 32-bit instruction. Zero if first part is
	      // 16-bit.

	      if (instr[31] == 0) begin
		 // 16-bit instruction
		 instr[15:0] <= 16'b0;
	      end
	      else begin
		 // 32-bit instruction
		 instr[15:0] <= i_rdata;
	      end
	      next_state <= `STATE_EXECUTE;

	   end // case: `STATE_FETCH2

	   `STATE_EXECUTE: begin

	      rega_wregnum <= opf_rd;
	      rega_we      <= 1;

	      rega_rregnum <= opf_ra;
	      regb_rregnum <= opf_rb;
	      regd_rregnum <= opf_rd;

	      if (instr[31] == 0) begin

		 // 16-bit instructions

		 case (opf_class[1:0])
		   2'b00: begin

		      // 16-bit ALU instructions, do the operation

		      case (opf_opcode[3:0])
			4'b0000: begin
			   // NOP
			end

			4'b0001: begin
			   // ADD
			   {next_carry,regd_wdata} <= {1'b0,rega_rdata} +
						      {1'b0,regb_rdata};
			end

			4'b0010: begin
			   // SUB
			   {next_carry,regd_wdata} <= {1'b0,rega_rdata} -
						      {1'b0,regb_rdata};
			end

			4'b0011: begin
			   // AND
			   regd_wdata <= rega_rdata & regb_rdata;
			end

			4'b0100: begin
			   // OR
			   regd_wdata <= rega_rdata | regb_rdata;
			end

			4'b0101: begin
			   // XOR
			   regd_wdata <= rega_rdata ^ regb_rdata;
			end

			4'b0110: begin
			   // ASR - will discard top bit
			   {dummy,regd_wdata} <= ({carry, rega_rdata} >>> regb_rdata);
			end

			4'b0111: begin
			   // LSL
			   regd_wdata <= rega_rdata << regb_rdata;
			end

			4'b1000: begin
			   // LSR
			   regd_wdata <= rega_rdata >> regb_rdata;
			end

			4'b1001: begin
			   // MOV
			   regd_wdata <= rega_rdata;
			end

			4'b1010: begin
			   // ADDI
			   {next_carry,regd_wdata} <= {1'b0,rega_rdata} +
						      {14'b0,opf_imm3};
			end

			4'b1011: begin
			   // SUBI
			   {next_carry,regd_wdata} <= {1'b0,rega_rdata} -
						      {14'b0,opf_imm3};
			end

			4'b1100: begin
			   // ASRI - will discard top bit.
			   {dummy,regd_wdata} <= ({carry, rega_rdata} >>> opf_imm3);
			end

			4'b1101: begin
			   // LSLI
			   regd_wdata <= rega_rdata << opf_imm3;
			end

			4'b1110: begin
			   // LSR
			   regd_wdata <= rega_rdata >> opf_imm3;
			end

			4'b1111: begin
			   // MOVI
			   regd_wdata <= {10'b0,opf_imm6_16};
			end
		      endcase // case (opf_opcode)

		      // Advance the program counter

		      i_raddr <= pc + 1;
		      next_pc <= pc + 1;
		      next_state <= `STATE_FETCH1;

		   end // case: 2'b00

		   2'b01: begin

		      //16-bit load/store instructions.

		      case (opf_opcode[3:2])
			2'b00: begin

			   // Byte loads take one more cycle

			   case (opf_opcode[1:0])
			     2'b00: begin
				// Indexed load byte
				d_raddr <= rega_rdata + opf_simm3b;
			     end

			     2'b01: begin
				// Indexed load byte with postinc
				d_raddr <= rega_rdata + opf_simm3b;
				// Inc the index reg
				rega_wregnum <= opf_ra;
				rega_wdata   <= rega_rdata + 1;
				rega_we      <= 1;
			     end

			     2'b10: begin
				// Indexed load byte with predec
				d_raddr <= rega_rdata + opf_simm3b - 1;
				// Dec the index reg
				rega_wregnum <= opf_ra;
				rega_wdata   <= rega_rdata - 1;
				rega_we      <= 1;
			     end

			     2'b11: begin
				// Invalid, do nothing
			     end
			   endcase // case (opf_opcode[1:0])

			   next_state <= `STATE_WRITEBACK;

			end // case: 2'b00

			2'b01: begin

			   // Word loads take two more cycles

			   case (opf_opcode[1:0])
			     2'b00: begin
				// Indexed load word
				d_raddr <= rega_rdata + opf_simm3b;
			     end

			     2'b01: begin
				// Indexed load word with postinc
				d_raddr <= rega_rdata + opf_simm3b;
				// Inc the index reg
				rega_wregnum <= opf_ra;
				rega_wdata   <= rega_rdata + 2;
				rega_we      <= 1;
			     end

			     2'b10: begin
				// Indexed load word with predec
				d_raddr <= rega_rdata + opf_simm3b - 2;
				// Dec the index reg
				rega_wregnum <= opf_ra;
				rega_wdata   <= rega_rdata - 2;
				rega_we      <= 1;
			     end

			     2'b11: begin
				// Invalid, do nothing
			     end
			   endcase // case (opf_opcode[1:0])

			   next_state <= `STATE_WRITEBACK;

			end // case: 2'b01

			2'b10: begin

			   // Byte stores complete in this cycle.

			   case (opf_opcode[1:0])
			     2'b00: begin
				// Indexed store byte
				d_waddr <= regd_rdata + opf_simm3b;
				d_wdata <= rega_rdata[7:0];
				d_we    <= 1;
			     end

			     2'b01: begin
				// Indexed store byte with postinc
				d_waddr <= regd_rdata + opf_simm3b;
				d_wdata <= rega_rdata[7:0];
				d_we    <= 1;
				// Inc the index reg
				regd_wregnum <= opf_rd;
				regd_wdata   <= regd_rdata + 1;
				regd_we      <= 1;
			     end

			     2'b10: begin
				// Indexed store byte with predec
				d_waddr <= regd_rdata + opf_simm3b - 1;
				d_wdata <= rega_rdata[7:0];
				d_we    <= 1;
				// Dec the index reg
				regd_wregnum <= opf_rd;
				regd_wdata   <= regd_rdata - 1;
				regd_we      <= 1;
			     end

			     2'b11: begin
				// Invalid
			     end
			   endcase // case (opf_opcode[2:1])

			   i_raddr    <= pc + 1;
			   next_pc    <= pc + 1;
			   next_state <= `STATE_FETCH1;

			end // case: 2'b10

			2'b11: begin

			   // Word stores need one more cycle.

			   case (opf_opcode[1:0])
			     2'b00: begin
				// Indexed store word
				d_waddr <= regd_rdata + opf_simm3b;
				d_wdata <= rega_rdata[7:0];	// LSB
				d_we    <= 1;
			     end

			     2'b01: begin
				// Indexed store word with postinc
				d_waddr <= regd_rdata + opf_simm3b;
				d_wdata <= rega_rdata[7:0];	// LSB
				d_we    <= 1;
				// Inc the index reg
				regd_wregnum <= opf_rd;
				regd_wdata   <= regd_rdata + 2;
				regd_we      <= 1;
			     end

			     2'b10: begin
				// Indexed store word with predec
				d_waddr <= regd_rdata + opf_simm3b - 2;
				d_wdata <= rega_rdata[7:0];	// LSB
				d_we    <= 1;
				// Dec the index reg
				regd_wregnum <= opf_rd;
				regd_wdata   <= regd_rdata - 2;
				regd_we      <= 1;
			     end

			     2'b11: begin
				// Invalid
			     end
			   endcase // case (opf_opcode[1:0])

			   next_state <= `STATE_WRITEBACK;

			end // case: 2'b11

		      endcase // case (opf_opcode[3:2])

		   end // case: 2'b01

		   2'b10: begin

		      // 16-bit flow of control instructions

		      case (opf_opcode[3:0])
			4'b0000: begin
			   // Relative branch
			   next_pc <= pc + $signed (opf_simm9);
			   i_raddr <= pc + $signed (opf_simm9);
			end

			4'b0001: begin
			   // Relative branch and link, first save the
			   // link. Remember only 16-bits of instr address
			   regb_wregnum <= opf_rb;
			   regb_wdata   <= pc[15:0] + 1;
			   regb_we      <= 1;
			   // Relative branch
			   next_pc <= pc + $signed (opf_simm6);
			   i_raddr <= pc + $signed (opf_simm6);
			end

			4'b0010: begin
			   // Relative branch if equal
			   if (rega_rdata == regb_rdata) begin
			      next_pc <= pc + opf_simm3d;
			      i_raddr <= pc + opf_simm3d;
			   end
			   else begin
			      next_pc <= pc + 1;
			      i_raddr <= pc + 1;
			   end
			end // case: 4'b0010

			4'b0011: begin
			   // Relative branch if not equal
			   if (rega_rdata != regb_rdata) begin
			      next_pc <= pc + opf_simm3d;
			      i_raddr <= pc + opf_simm3d;
			   end
			   else begin
			      next_pc <= pc + 1;
			      i_raddr <= pc + 1;
			   end
			end // case: 4'b0011

			4'b0100: begin
			   // Relative branch if signed less than
			   if ($signed(rega_rdata) < $signed(regb_rdata)) begin
			      next_pc <= pc + opf_simm3d;
			      i_raddr <= pc + opf_simm3d;
			   end
			   else begin
			      next_pc <= pc + 1;
			      i_raddr <= pc + 1;
			   end
			end // case: 4'b0100


			4'b0101: begin
			   // Relative branch if signed less than or equal
			   if ($signed(rega_rdata) <= $signed(regb_rdata)) begin
			      next_pc <= pc + opf_simm3d;
			      i_raddr <= pc + opf_simm3d;
			   end
			   else begin
			      next_pc <= pc + 1;
			      i_raddr <= pc + 1;
			   end
			end // case: 4'b0101

			4'b0110: begin
			   // Relative branch if unsigned less than
			   if (rega_rdata < regb_rdata) begin
			      next_pc <= pc + opf_simm3d;
			      i_raddr <= pc + opf_simm3d;
			   end
			   else begin
			      next_pc <= pc + 1;
			      i_raddr <= pc + 1;
			   end
			end // case: 4'b0110

			4'b0111: begin
			   // Relative branch if unsigned less than or equal
			   if (rega_rdata <= regb_rdata) begin
			      next_pc <= pc + opf_simm3d;
			      i_raddr <= pc + opf_simm3d;
			   end
			   else begin
			      next_pc <= pc + 1;
			      i_raddr <= pc + 1;
			   end
			end // case: 4'b0111

			4'b1000: begin
			   // Absolute jump
			   next_pc[15:0] <= regd_rdata;
			   i_raddr[15:0] <= regd_rdata;
			end

			4'b1001: begin
			   // Absolute jump and link, first save the link (16-bit
			   // only)
			   regb_wregnum <= opf_rb;
			   regb_wdata   <= pc[15:0] + 1;
			   regb_we      <= 1;
			   // Absolute jump
			   next_pc[15:0] <= regd_rdata;
			   i_raddr[15:0] <= regd_rdata;
			end

			4'b1010: begin
			   // Absolute jump if equal
			   if (rega_rdata == regb_rdata) begin
			      next_pc[15:0] <= regd_rdata;
			      i_raddr[15:0] <= regd_rdata;
			   end
			   else begin
			      next_pc[15:0] <= pc[15:0] + 1;
			      i_raddr[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1010

			4'b1011: begin
			   // Absolute jump if not equal
			   if (rega_rdata != regb_rdata) begin
			      next_pc[15:0] <= regd_rdata;
			      i_raddr[15:0] <= regd_rdata;
			   end
			   else begin
			      next_pc[15:0] <= pc[15:0] + 1;
			      i_raddr[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1011

			4'b1100: begin
			   // Aboslute jump if signed less than
			   if ($signed(rega_rdata) < $signed(regb_rdata)) begin
			      next_pc[15:0] <= regd_rdata;
			      i_raddr[15:0] <= regd_rdata;
			   end
			   else begin
			      next_pc <= pc + 1;
			      i_raddr <= pc + 1;
			   end
			end

			4'b1101: begin
			   // Aboslute jump if signed less than or equal
			   if ($signed(rega_rdata) <= $signed(regb_rdata)) begin
			      next_pc[15:0] <= regd_rdata;
			      i_raddr[15:0] <= regd_rdata;
			   end
			   else begin
			      next_pc[15:0] <= pc[15:0] + 1;
			      i_raddr[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1101

			4'b1110: begin
			   // Aboslute jump if unsigned less than
			   if (rega_rdata < regb_rdata) begin
			      next_pc[15:0] <= regd_rdata;
			      i_raddr[15:0] <= regd_rdata;
			   end
			   else begin
			      next_pc[15:0] <= pc[15:0] + 1;
			      i_raddr[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1110

			4'b1111: begin
			   // Aboslute jump if unsigned less than or equal
			   if (rega_rdata <= regb_rdata) begin
			      next_pc[15:0] <= regd_rdata;
			      i_raddr[15:0] <= regd_rdata;
			   end
			   else begin
			      next_pc[15:0] <= pc[15:0] + 1;
			      i_raddr[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1111

		      endcase // case (opf_class)

		      next_state <= `STATE_FETCH1;

		   end // case: 2'b10

		   2'b11: begin

		      // Miscellaneous 16-bit operations. Only have one and
		      // ignore the rest.

		      if (opf_opcode[3:0] == 4'b0000) begin
			 next_pc[15:0] <= regd_rdata;
			 i_raddr[15:0] <= regd_rdata;
		      end
		   end

		 endcase // case (opf_class)
	      end // if (instr[31] == 0)
	      else begin

		 // 32-bit instructions

	      end // else: !if(instr[31] == 0)

	   end // case: `STATE_EXECUTE

	 endcase // case (state)

      end // if (rst != 1)

   end // always @ (posedge clk)

endmodule
