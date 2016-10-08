// Verilog header file for MyStorm AAP

// Copyright Embecosm 2016.

// Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

// This file documents the AAP design for FPGA.  It describes Open Hardware
// and is licensed under the CERN OHL v. 1.2.

// You may redistribute and modify this documentation under the terms of the
// CERN OHL v.1.2. (http://ohwr.org/cernohl). This documentation is
// distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF
// MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR
// PURPOSE. Please see the CERN OHL v.1.2 for applicable conditions

`define STATE_FETCH1    3'b000
`define STATE_FETCH2    3'b001
`define STATE_FETCH3    3'b010
`define STATE_EXEC1     3'b011
`define STATE_EXEC2     3'b100
`define STATE_EXEC3     3'b101
`define STATE_HALTED    3'b110
