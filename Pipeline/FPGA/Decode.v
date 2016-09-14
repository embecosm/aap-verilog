// Verilog for processor decode

// Copyright Embecosm 2016.

// Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

// This file documents the AAP design for FPGA.  It describes Open Hardware
// and is licensed under the CERN OHL v. 1.2.

// You may redistribute and modify this documentation under the terms of the
// CERN OHL v.1.2. (http://ohwr.org/cernohl). This documentation is
// distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF
// MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR
// PURPOSE. Please see the CERN OHL v.1.2 for applicable conditions


// Decode is fully combinatorial

module Decode (input [31:0]  instr,
	       output [3:0]  opf_class,         // 0 top bits for 16-bit
	       output [7:0]  opf_opcode,        // 0 top bits for 16-bit
	       output [5:0]  opf_rd,            // 0 top bits for 16-bit
	       output [5:0]  opf_ra,            // 0 top bits for 16-bit
	       output [5:0]  opf_rb,            // 0 top bits for 16-bit
	       output [2:0]  opf_imm3,
	       output [2:0]  opf_smm3a,         // Multiple ways of doing sim3
	       output [2:0]  opf_smm3b,
	       output [5:0]  opf_imm6_16,	// 16-bit instr version
	       output [5:0]  opf_imm6_32,	// 32-bit instr version
	       output [5:0]  opf_simm6,
	       output [8:0]  opf_imm9,
	       output [8:0]  opf_simm9,
	       output [9:0]  opf_imm10,
	       output [9:0]  opf_simm10a,       // Multiple ways of doing sim10
	       output [9:0]  opf_simm10b,
	       output [11:0] opf_imm12,
	       output [15:0] opf_imm16,
	       output [15:0] opf_simm16,
	       output [21:0] opf_simm22
	       );

   // General fields

   assign opf_class   = {instr[14,13],instr[30:29]};
   assign opf_opcode  = {instr[12,9],instr[28:25]};
   assign opf_rd      = {instr[8:6],instr[24:22]};
   assign opf_ra      = {instr[5:3],instr[21:19]};
   assign opf_rb      = {instr[2:0],instr[18:16]};   

   // 16-bit instruction immediate fields

   assign opf_imm3    = instr[18:16];
   assign opf_sim3a   = instr[24:22];
   assign opf_sim3b   = instr[18:16];
   assign opf_imm6_16 = instr[21:16];
   assign opf_simm6   = instr[24:19];
   assign opf_simm9   = instr[24:16];

   // 32-bit instruction immediate fields
   assign opf_imm6_32 = {instr[2:0],instr[18:16]};
   assign opf_imm9    = {instr[12:10],instr[2:0],instr[18:16]};
   assign opf_imm10   = {instr[12:9],instr[2:0],instr[18:16]};
   assign opf_simm10a = {instr[12:6],instr[24:22]};
   assign opf_simm10b = {instr[12:9],instr[2:0],instr[18:16]};
   assign opf_imm12   = {instr[5:0],instr[21:16]};
   assign opf_imm16   = {instr[12:9],instr[5:0],instr[21:16]};
   assign opf_simm22  = {instr[12:0],instr[24:16]};

endmodule
