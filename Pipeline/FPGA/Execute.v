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


// This module executes instructions

module Execute (input         clk,
		input 	      rst,

		input [2:0]   state, // Processor state
		input [31:0]  instr, // Instruction to process
		output [23:0] pc, // Program counter
		output [7:0]  status, // Status register
		output 	      exec_done, // When we finish executing

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

		// Data memory access.

		output [15:0] d_raddr,
		output [15:0] d_waddr,
		input [7:0]   d_rdata,
		output [7:0]  d_wdata,
		output 	      d_we,

		// Debug control

		input 	      dbg_halt_req,
		output 	      dbg_halt_ack,

		// Debug access to write PC and carry

		input [15:0]  dbg_pc_lsw,
		input 	      dbg_pc_lsw_en,
		input [15:0]  dbg_st_pc_msb,
		input 	      dbg_st_pc_msb_en
		);

   // Bits in the status register

   localparam C_BIT = 7;		// Carry bit

   // We own the PC

   reg [23:0]  pc;

   // We own the status register as well.

   reg [7:0]  status;

   // Flags to indicate when we are done and what we need next.

   reg 	       exec_done;	// Done all we can

   // Register the debug ack

   reg 	       dbg_halt_ack;

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

   // Net to ignore

   wire        dummy;

   // Read registers

   assign rega_rregnum = opf_ra;
   assign regb_rregnum = opf_rb;
   assign regd_rregnum = opf_rd;

   // Execute logic

   always @(posedge clk or posedge rst) begin
      if (rst == 1) begin

	 // Clear state

	 exec_done     <= 1'b0;
	 dbg_halt_ack  <= 1'b0;
	 status        <= 8'b0;
	 pc            <= 24'b0;
      end
      else begin

	 case (state)

	   `STATE_FETCH1: begin

	      // Reset state and turn of any reg/memory writing

	      exec_done    <= 1'b0;
	      dbg_halt_ack <= 1'b0;

	      rega_we <= 1'b0;
	      regb_we <= 1'b0;
	      regd_we <= 1'b0;
	      d_we    <= 1'b0;

	   end

	   `STATE_FETCH2, `STATE_FETCH3: begin

	      // Nothing to do

	   end

	   `STATE_EXEC1: begin

	      // First cycle of execution

	      if (instr[31] == 0) begin

		 // 16-bit instructions

		 case (opf_class[1:0])

		   // **********************************************************
		   //
		   // 16-bit ALU instructions first cycle
		   //
		   // **********************************************************

		   2'b00: begin

		      // Do the operation

		      case (opf_opcode[3:0])
			4'b0000: begin
			   // NOP
			end

			4'b0001: begin
			   // ADD
			   {status[C_BIT],regd_wdata} <= {1'b0,rega_rdata} +
							 {1'b0,regb_rdata};
			end

			4'b0010: begin
			   // SUB
			   {status[C_BIT],regd_wdata} <= {1'b0,rega_rdata} -
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
			   {dummy,regd_wdata} <= ({status[C_BIT],
						   rega_rdata} >>> regb_rdata);
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
			   {status[C_BIT],regd_wdata} <= {1'b0,rega_rdata} +
						         {14'b0,opf_imm3};
			end

			4'b1011: begin
			   // SUBI
			   {status[C_BIT],regd_wdata} <= {1'b0,rega_rdata} -
							 {14'b0,opf_imm3};
			end

			4'b1100: begin
			   // ASRI - will discard top bit.
			   {dummy,regd_wdata} <= ({status[C_BIT],
						   rega_rdata} >>> opf_imm3);
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

		      // All of these write the destination register

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b1;
		      d_we    <= 1'b0;

		      // ALU instructions are done in one cycle. Advance to
		      // the next instruction.

		      pc        <= pc + 24'b1;
		      exec_done <= 1'b1;

		      // Are we needed to halt?

		      if (dbg_halt_req) begin
			 dbg_halt_ack <= 1'b1;
		      end

		   end // case: 2'b00 (16-bit ALU instructions)

		   // **********************************************************
		   //
		   // 16-bit load/store instructions first cycle
		   //
		   // **********************************************************

		   2'b01: begin

		      // Top bit identifies direction (load or store)

		      // Next bit identifies size (byte or word)

		      // Bottow two bits identify the type of transfer (indexed,
		      // postinc, predec, unused)

		      if (opf_opcode[3] == 1'b0) begin

			 // Loads. First cycle is common to both byte and
			 // word loads.

			 // First cycle specify the memory read address
			 // for the data and register and optionally the
			 // register write address and data for
			 // postinc/predec.

			 case (opf_opcode[1:0])

			   2'b00: begin
			      // Indexed load byte
			      d_raddr <= rega_rdata + opf_simm3b;
			      // No change to index reg
			      rega_we      <= 1'b0;
			   end

			   2'b01: begin
			      // Indexed load byte with postinc
			      d_raddr <= rega_rdata + opf_simm3b;
			      // Inc the index reg
			      rega_wregnum <= opf_ra;
			      rega_wdata   <= rega_rdata + 16'b1;
			      rega_we      <= 1'b1;
			   end

			   2'b10: begin
			      // Indexed load byte with predec. How much to
			      // decrement depends on whether we are a byte
			      // or word load.
			      d_raddr <= rega_rdata + opf_simm3b - 16'b1 -
                                         {15'b0,opf_opcode[2]};
			      // Dec the index reg. Only subtract 1 here. If
			      // we are word load, we'll subtract another 1
			      // in the next cycle.
			      rega_wregnum <= opf_ra;
			      rega_wdata   <= rega_rdata - 16'b1;
			      rega_we      <= 1'b1;
			   end

			   2'b11: begin
			      // Invalid, do nothing
			      rega_we <= 1'b0;
			   end
			 endcase // case (opf_opcode[1:0])

			 //  Don't write any other regs or memory

			 regb_we <= 1'b0;
			 regd_we <= 1'b0;
			 d_we    <= 1'b0;

			 // Need one more cycle

			 exec_done <= 1'b0;

		      end // if (opf_opcode[3] == 1'b0)
		      else begin

			 // Stores. First cycle is common to both byte and
			 // word loads.

			 // First cycle specify the memory write address and
			 // data and optionally the register write address
			 // and data for postinc/predec.  Don't write any
			 // other regs

			 case (opf_opcode[1:0])

			   2'b00: begin
			      // Indexed store byte
			      d_waddr <= regd_rdata + opf_simm3b;
			      // No change to index reg
			      regd_we <= 1'b0;
			   end

			   2'b01: begin
			      // Indexed store byte with postinc
			      d_waddr <= regd_rdata + opf_simm3b;

			      // Inc the index reg again
			      regd_wregnum <= opf_rd;
			      regd_wdata   <= regd_rdata + 16'b1;
			      regd_we      <= 1'b1;
			   end

			   2'b10: begin
			      // Indexed store byte with predec. We were
			      // decremented last time, so are already
			      // pointing at the MSB address.
			      d_waddr <= regd_rdata + opf_simm3b;
			      // Dec the index reg again.
			      regd_wregnum <= opf_rd;
			      regd_wdata   <= regd_rdata - 16'b1;
			      regd_we      <= 1'b1;
			   end

			   2'b11: begin
			      // Invalid, do nothing
			      regd_we <= 1'b0;
			   end
			 endcase // case (opf_opcode[1:0])

			 // Write data always comes from reg A LSB, other regs
			 // are never written

			 rega_we <= 1'b0;
			 regb_we <= 1'b0;
			 d_wdata <= rega_rdata[7:0];
			 d_we    <= 1'b1;

			 if (opf_opcode[2] == 1'b0) begin
			    // Complete if a byte store. No writeback
			    pc        <= pc + 24'b1;
			    exec_done <= 1'b1;

			    // Are we needed to halt?

			    if (dbg_halt_req) begin
			       dbg_halt_ack <= 1'b1;
			    end
			 end
			 else begin
			    // One more cycle for a word store
			    exec_done <= 1'b0;
			 end
		      end // else: !if(opf_opcode[3] == 1'b0) End of stores
		   end // case: 2'b01 End of load/store

		   // **********************************************************
		   //
		   // 16-bit flow of control instructions first cycle
		   //
		   // **********************************************************

		   2'b10: begin

		      case (opf_opcode[3:0])
			4'b0000: begin
			   // Relative branch
			   pc <= pc + $signed (opf_simm9);
			end

			4'b0001: begin
			   // Relative branch and link, first save the
			   // link. Remember only 16-bits of instr address
			   regb_wregnum <= opf_rb;
			   regb_wdata   <= pc[15:0] + 1;
			   regb_we      <= 1;
			   // Relative branch
			   pc <= pc + $signed (opf_simm6);
			end

			4'b0010: begin
			   // Relative branch if equal
			   if (rega_rdata == regb_rdata) begin
			      pc <= pc + opf_simm3d;
			   end
			   else begin
			      pc <= pc + 24'b1;
			   end
			end // case: 4'b0010

			4'b0011: begin
			   // Relative branch if not equal
			   if (rega_rdata != regb_rdata) begin
			      pc <= pc + opf_simm3d;
			   end
			   else begin
			      pc <= pc + 24'b1;
			   end
			end // case: 4'b0011

			4'b0100: begin
			   // Relative branch if signed less than
			   if ($signed(rega_rdata) < $signed(regb_rdata)) begin
			      pc <= pc + opf_simm3d;
			   end
			   else begin
			      pc <= pc + 24'b1;
			   end
			end // case: 4'b0100


			4'b0101: begin
			   // Relative branch if signed less than or equal
			   if ($signed(rega_rdata) <= $signed(regb_rdata)) begin
			      pc <= pc + opf_simm3d;
			   end
			   else begin
			      pc <= pc + 24'b1;
			   end
			end // case: 4'b0101

			4'b0110: begin
			   // Relative branch if unsigned less than
			   if (rega_rdata < regb_rdata) begin
			      pc <= pc + opf_simm3d;
			   end
			   else begin
			      pc <= pc + 24'b1;
			   end
			end // case: 4'b0110

			4'b0111: begin
			   // Relative branch if unsigned less than or equal
			   if (rega_rdata <= regb_rdata) begin
			      pc <= pc + opf_simm3d;
			   end
			   else begin
			      pc <= pc + 24'b1;
			   end
			end // case: 4'b0111

			4'b1000: begin
			   // Absolute jump
			   pc[15:0] <= regd_rdata;
			end

			4'b1001: begin
			   // Absolute jump and link, first save the link (16-bit
			   // only)
			   regb_wregnum <= opf_rb;
			   regb_wdata   <= pc[15:0] + 1;
			   regb_we      <= 1;
			   // Absolute jump
			   pc[15:0] <= regd_rdata;
			end

			4'b1010: begin
			   // Absolute jump if equal
			   if (rega_rdata == regb_rdata) begin
			      pc[15:0] <= regd_rdata;
			   end
			   else begin
			      pc[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1010

			4'b1011: begin
			   // Absolute jump if not equal
			   if (rega_rdata != regb_rdata) begin
			      pc[15:0] <= regd_rdata;
			   end
			   else begin
			      pc[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1011

			4'b1100: begin
			   // Aboslute jump if signed less than
			   if ($signed(rega_rdata) < $signed(regb_rdata)) begin
			      pc[15:0] <= regd_rdata;
			   end
			   else begin
			      pc <= pc + 24'b1;
			   end
			end

			4'b1101: begin
			   // Aboslute jump if signed less than or equal
			   if ($signed(rega_rdata) <= $signed(regb_rdata)) begin
			      pc[15:0] <= regd_rdata;
			   end
			   else begin
			      pc[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1101

			4'b1110: begin
			   // Aboslute jump if unsigned less than
			   if (rega_rdata < regb_rdata) begin
			      pc[15:0] <= regd_rdata;
			   end
			   else begin
			      pc[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1110

			4'b1111: begin
			   // Aboslute jump if unsigned less than or equal
			   if (rega_rdata <= regb_rdata) begin
			      pc[15:0] <= regd_rdata;
			   end
			   else begin
			      pc[15:0] <= pc[15:0] + 1;
			   end
			end // case: 4'b1111

		      endcase // case (opf_class)

		      // No regs or memory are written.

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b0;
		      d_we    <= 1'b0;

		      // No more execution needed.

		      exec_done <= 1'b1;

		      // Are we needed to halt?

		      if (dbg_halt_req) begin
			 dbg_halt_ack <= 1'b1;
		      end

		   end // case: 2'b10

		   // **********************************************************
		   //
		   // 16-bit miscellaneous instructions first cycle
		   //
		   // **********************************************************

		   2'b11: begin

		      // Miscellaneous 16-bit operations. Only have one and
		      // ignore the rest.

		      if (opf_opcode[3:0] == 4'b0000) begin
			 // RETI
			 pc[15:0] <= regd_rdata;
		      end

		      // No regs or memory are written.

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b0;
		      d_we    <= 1'b0;

		      // No more execution or writeback needed.

		      exec_done <= 1'b1;

		      // Are we needed to halt?

		      if (dbg_halt_req) begin
			 dbg_halt_ack <= 1'b1;
		      end

		   end

		 endcase // case (opf_class)  End of 16-bit flow of control
	      end // if (instr[31] == 0) End of 16-bit
	      else begin

		 // 32-bit instructions

	      end // else: !if(instr[31] == 0)
	   end // case: `STATE_EXEC1

	   `STATE_EXEC2: begin

	      // Second cycle of execution.

	      if (instr[31] == 0) begin

		 // 16-bit instructions

		 case (opf_class[1:0])

		   // **********************************************************
		   //
		   // 16-bit ALU instructions second cycle
		   //
		   // **********************************************************

		   2'b00: begin

		      // Stop writing the D reg. No regs or memory are written.

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b0;
		      d_we    <= 1'b0;

		   end


		   // **********************************************************
		   //
		   // 16-bit load/store instructions second cycle
		   //
		   // **********************************************************

		   2'b01: begin

		      // Top bit identifies direction (load or store)

		      // Next bit identifies size (byte or word)

		      // Bottow two bits identify the type of transfer (indexed,
		      // postinc, predec, unused)

		      if (opf_opcode[3] == 1'b0) begin

			 // Loads. First cycle is common to both byte and
			 // word loads.

			 // Second cycle (we are now in `STATE_EXECUTE) has
			 // some common features

			 if (opf_opcode[2] == 1'b0) begin

			    // Byte loads are now done and we need no
			    // other registers written

			    rega_we   <= 1'b0;
			    pc        <= pc + 24'b1;
			    exec_done <= 1'b1;

			    // Are we needed to halt?

			    if (dbg_halt_req) begin
			       dbg_halt_ack <= 1'b1;
			    end
			 end
			 else begin

			    // Word load second cycle specify the memory read
			    // address for the data and register and
			    // optionally the register write address and data
			    // for postinc/predec.  Don't write the B source
			    // register.

			    regb_we <= 1'b0;

			    case (opf_opcode[1:0])

			      2'b00: begin
				 // Indexed load byte. Add 1 to get the second
				 // byte.
				 d_raddr <= rega_rdata + opf_simm3b + 1;
				 // No change to index reg
				 rega_we      <= 1'b0;
			      end

			      2'b01: begin
				 // Indexed load byte with postinc. No need to
				 // add 1, because this was post incremented
				 // last time.
				 d_raddr <= rega_rdata + opf_simm3b;
				 // Inc the index reg again
				 rega_wregnum <= opf_ra;
				 rega_wdata   <= rega_rdata + 16'b1;
				 rega_we      <= 1'b1;
			      end

			      2'b10: begin
				 // Indexed load byte with predec. We were
				 // decremented last time, so to get the MSB we
				 // need not subtract anything.
				 d_raddr <= rega_rdata + opf_simm3b ;
				 // Dec the index reg again
				 rega_wregnum <= opf_ra;
				 rega_wdata   <= rega_rdata - 16'b1;
				 rega_we      <= 1'b1;
			      end

			      2'b11: begin
				 // Invalid, do nothing
				 rega_we <= 1'b0;
			      end
			    endcase // case (opf_opcode[1:0])

			    // Store the result in the bottom half of the
			    // destination register. We also know that the B reg
			    // is not written for either word or byte. We know
			    // no memory is written.

			    regd_wregnum    <= opf_rd;
			    regd_wdata[7:0] <= d_rdata;
			    regd_we         <= 1'b1;
			    regb_we         <= 1'b0;
			    d_we            <= 1'b0;

			    // We need one more cycle

			    exec_done <= 1'b0;

			 end // else: !if(opf_opcode[2] = 1'b0)
		      end // if (opf_opcode[3] == 1'b0)
		      else begin

			 // Stores.

			 if (opf_opcode[2] == 1'b1) begin

			    // Second cycle is mostly only needed for store
			    // word.

			    // Reg A and reg B are never written

			    rega_we <= 1'b0;
			    regb_we <= 1'b0;

			    case (opf_opcode[1:0])

			      2'b00: begin
				 // Indexed store byte - upper byte this time.
				 d_waddr <= regd_rdata + opf_simm3b + 1;
				 // No change to index reg
				 regd_we <= 1'b0;
			      end

			      2'b01: begin
				 // Indexed store byte with postinc. No need to
				 // inc address - was done on prev cycle.
				 d_waddr <= regd_rdata + opf_simm3b;

				 // Inc the index reg
				 regd_wregnum <= opf_rd;
				 regd_wdata   <= regd_rdata + 16'b1;
				 regd_we      <= 1'b1;
			      end

			      2'b10: begin
				 // Indexed store byte with predec.
				 d_waddr <= regd_rdata + opf_simm3b - 16'b1 -
                                            {15'b0,opf_opcode[2]};
				 // Dec the index reg. Only subtract 1 here. If
				 // we are word store, we'll subtract another 1
				 // in the next cycle.
				 regd_wregnum <= opf_rd;
				 regd_wdata   <= regd_rdata - 16'b1;
				 regd_we      <= 1'b1;
			      end

			      2'b11: begin
				 // Invalid, do nothing
				 regd_we <= 1'b0;
			      end
			    endcase // case (opf_opcode[1:0])

			    // Write data always comes from reg A MSB. A & B
			    // regs are never written.

			    d_wdata <= rega_rdata[15:8];
			    d_we    <= 1'b1;
			    rega_we <= 1'b0;
			    regb_we <= 1'b0;

			    // Complete.

			    pc        <= pc + 24'b1;
			    exec_done <= 1'b1;

			    // Are we needed to halt?

			    if (dbg_halt_req) begin
			       dbg_halt_ack <= 1'b1;
			    end
			 end // if (opf_opcode[2] == 1'b1)
			 else begin

			    // For byte stores, we just need to turn off the
			    // reg D write if it was enabled for pre/post-inc.

			    regd_we <= 1'b0;
			 end
		      end // else: !if(opf_opcode[3] == 1'b0) End of stores
		   end // case: 2'b01 End of load/store

		   // **********************************************************
		   //
		   // 16-bit flow of control instructions second cycle
		   //
		   // **********************************************************

		   2'b10: begin

		      // Nothing to do. Make sure we aren't writing anything.

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b0;
		      d_we    <= 1'b0;

		   end // case: 2'b10


		   // **********************************************************
		   //
		   // 16-bit flow of miscellaneous instructions second cycle
		   //
		   // **********************************************************

		   2'b11: begin

		      // Nothing to do. Make sure we aren't writing anything.

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b0;
		      d_we    <= 1'b0;

		   end

		 endcase // case (opf_class)  End of 16-bit flow of control
	      end // if (instr[31] == 0) End of 16-bit
	      else begin

		 // 32-bit instructions

	      end // else: !if(instr[31] == 0)
	   end // case: `STATE_EXEC2

	   // Third cycle of execution

	   `STATE_EXEC3: begin

	      // Third cycle of execution.

	      if (instr[31] == 0) begin

		 // 16-bit instructions

		 case (opf_class[1:0])

		   // **********************************************************
		   //
		   // 16-bit ALU instructions (third cycle)
		   //
		   // **********************************************************

		   2'b00: begin

		      // Nothing to do. Make sure we aren't writing anything.

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b0;
		      d_we    <= 1'b0;

		   end

		   // **********************************************************
		   //
		   // 16-bit load/store instructions (third cycle)
		   //
		   // **********************************************************

		   2'b01: begin

		      // Top bit identifies direction (load or store)

		      // Next bit identifies size (byte or word)

		      // Bottow two bits identify the type of transfer (indexed,
		      // postinc, predec, unused)

		      if (opf_opcode[3:2] == 2'b01) begin

			 // Word Loads

			 // Third execute cycle. This is only for word
			 // loads.

			 // Store the result in the bottom half of the
			 // destination register. We also know that no other
			 // regs need writing.

			 regd_wregnum     <= opf_rd;
			 regd_wdata[15:8] <= d_rdata;
			 regd_we          <= 1'b1;
			 rega_we          <= 1'b0;
			 regb_we          <= 1'b0;

			 // Word loads are now done and we need no writeback.

			 pc        <= pc + 24'b1;
			 exec_done <= 1'b1;

			 // Are we needed to halt?

			 if (dbg_halt_req) begin
			    dbg_halt_ack <= 1'b1;
			 end

		      end // if (opf_opcode[3] == 1'b0) End of loads
		      else begin

			 // Byte loads and all stores. Nothing to do, except
			 // ensure we aren't writing any regs

			 rega_we <= 1'b0;
			 regb_we <= 1'b0;
			 regd_we <= 1'b0;
			 d_we    <= 1'b0;

		      end // else: !if(opf_opcode[3] == 1'b0)
		   end // case: 2'b01

		   // **********************************************************
		   //
		   // 16-bit flow of control instructions (third cycle)
		   //
		   // **********************************************************

		   2'b10: begin

		      // Nothing to do. Make sure we aren't writing anything.

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b0;
		      d_we    <= 1'b0;

		   end

		   // **********************************************************
		   //
		   // 16-bit miscellaneous instructions (third cycle)
		   //
		   // **********************************************************

		   2'b11: begin

		      // Nothing to do. Make sure we aren't writing anything.

		      rega_we <= 1'b0;
		      regb_we <= 1'b0;
		      regd_we <= 1'b0;
		      d_we    <= 1'b0;

		   end

		 endcase // case (opf_class)  End of 16-bit flow of control
	      end // if (instr[31] == 0) End of 16-bit
	      else begin

		 // 32-bit instructions

	      end // else: !if(instr[31] == 0)
	   end // case: `STATE_EXEC3

	   `STATE_HALTED: begin

	      // Turn off any general reg/memory writing

	      rega_we <= 1'b0;
	      regb_we <= 1'b0;
	      regd_we <= 1'b0;
	      d_we    <= 1'b0;

	      // Permit debug writing of PC and status register

	      if (dbg_st_pc_msb_en == 1'b1) begin
		 status    <= dbg_st_pc_msb[15:8];
		 pc[23:16] <= dbg_st_pc_msb[7:0];
	      end

	      if (dbg_pc_lsw_en == 1'b1) begin
		 pc[15:0] <= dbg_pc_lsw;
	      end
	   end // case: `STATE_HALTED

	   default: begin

	      // Should be impossible, do nothing

	   end
	 endcase // case (state)
      end // else: !if(rst == 1)
   end // always @ (posedge clk)

endmodule
