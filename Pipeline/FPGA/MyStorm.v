// Top level Verilog file for MyStorm AAP

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


// This is a very simple implementation.  The main logic is clocked at
// 12.5MHz.  This allows us to read/write both instruction and data memory
// each cycle by using the 50MHz clock.

// Each instruction takes multiple cycles, controlled by a state machine.  At
// this stage we don't try to overlap anything, let alone pipeline so there
// are lots of wasted cyles. The states are as follows:

// Transitions are as follows.

// `STATE_FETCH1

//     Memory Module action:   Fetch from instruction memory
//     Register Module action: Nothing
//     Fetch Module action:    Fetch first word of next instruction
//     Execute Module action:  Clear exec_done and dbg_halt_ack

//     Next state: STATE_FETCH2

// `STATE_FETCH2

//     Memory Module action:   Fetch from instruction memory if enabled
//     Register Module action: Nothing
//     Fetch Module action:    If first word had top bit set fetch second word
//                             of next instruction.
//     Execute Module action:  Nothing

//     Next state: `STATE_EXEC1

// `STATE_EXEC1

//     Memory Module action:   Read/write memory as enabled
//     Register Module action: Read/write registers as enabled
//     Fetch Module action:    Nothing
//     Execute Module action:  Execute first cycle of action and if complete
//                             set exec_done.

//     Next state: `STATE_EXEC2

// `STATE_EXEC2

//     Memory Module action:   Read/write memory as enabled
//     Register Module action: Read/write registers as enabled
//     Fetch Module action:    Nothing
//     Execute Module action:  if exec_done & dgb_halt_req set dbg_halt_ack
//                             else execute second cycle of action
//                             and if complete set exec_done.

//     Next state: if exec_done & dbg_halt_req `STATE_HALTED
//                 else if exec_done `STATE_FETCH1
//                 else `STATE_EXEC3

// `STATE_EXEC3

//     Memory Module action:   Read/write memory as enabled
//     Register Module action: Read/write registers as enabled
//     Fetch Module action:    Nothing
//     Execute Module action:  if not exec_done, execute fhird cycle of action
//                             and set exec_done.
//                             if dbg_halt_req, set dbg_halt_ack

//     Next state: if dbg_halt_req, `STATE_HALTED else `STATE_FETCH1

// `STATE_HALTED

//     Memory Module action:   Read/write debug memory as enabled
//     Register Module action: Read/write debug register as enabled
//     Fetch Module action:    Nothing
//     Execute Module action:  Nothing

//     Next state: if dbg_halt_req `STATE_HALTED else `STATE_FETCH1

// Modules are:

// Memory
//     Implements combinatorial read access and sequential write access to
//     RAM for instruction memory and data memory.

// RegisterFile
//     Implements three read and three write port register
//     memory. Combinatorial read and sequential write.

// Fetch
//     Gets the instruction from memory

// Execute
//     Executes the behavior of the opcode

// Our major clock speed is one quarter the speed of the master clock. This
// allows us to use the external SRAM for simulataneous data and instruction
// access to by clocking it with the master clock.


module MyStorm ( input         CLOCK_50, // 50 MHz Clock
                 input 	       RESET, // Posedge reset

                 // User I/O

                 // output [3:0]  LED,      // LED bank
                 // input [2:0]   KEY,      // DIP switches

                 // UART

                 output        UART_TX,
                 input 	       UART_RX,

		 // Memory (static RAM)

		 output        RAM_CS, // Chip select
		 output        RAM_WE, // Write enable
		 output        RAM_OE, // Output enable

		 output [17:0] RAM_A, // Address
		 inout [15:0]  RAM_D     // Data
		 );

   //=======================================================
   //  REG/WIRE declarations
   //=======================================================

   // Each register is read continuously and written on any clock edge where
   // write-enable is set.

   wire [5:0]  rega_rregnum;
   wire [5:0]  rega_wregnum;
   wire [15:0] rega_rdata;
   wire [15:0] rega_wdata;
   wire        rega_we;

   wire [5:0]  regb_rregnum;
   wire [5:0]  regb_wregnum;
   wire [15:0] regb_rdata;
   wire [15:0] regb_wdata;
   wire        regb_we;

   wire [5:0]  regd_rregnum;
   wire [5:0]  regd_wregnum;
   wire [15:0] regd_rdata;
   wire [15:0] regd_wdata;
   wire        regd_we;

   // Debug register access

   wire [5:0]  dbg_reg_rregnum;
   wire [5:0]  dbg_reg_wregnum;
   wire [15:0] dbg_reg_rdata;
   wire [15:0] dbg_reg_wdata;
   wire        dbg_reg_we;

   // Debug access to PC and status

   wire [15:0] dbg_pc_lsw;
   wire        dbg_pc_lsw_en;
   wire [15:0] dbg_st_pc_msb;
   wire        dbg_st_pc_msb_en;

   //=======================================================
   //  SRAM declarations
   //=======================================================

   // Instruction and data memory ports

   reg [15:0]  d_raddr;
   reg [15:0]  d_waddr;
   reg [7:0]   d_rdata;
   reg [7:0]   d_wdata;
   reg 	       d_we;

   reg [23:0]  i_raddr;			// Only ever driven by `STATE_FETCH
   reg [15:0]  i_rdata;

   // Debug memory access

   reg [15:0]  dbg_d_raddr;
   reg [15:0]  dbg_d_waddr;
   reg [7:0]   dbg_d_rdata;
   reg [7:0]   dbg_d_wdata;
   reg 	       dbg_d_we;

   reg [23:0]  dbg_i_raddr;
   reg [23:0]  dbg_i_waddr;
   reg [15:0]  dbg_i_rdata;
   reg [15:0]  dbg_i_wdata;
   reg 	       dbg_i_we;

   // Debug control

   wire        dbg_halt_req;		// Request halt
   wire        dbg_halt_ack;		// Indicate we have halted.

   reg [1:0]   clk_phase;
   wire        clk_slow = ~clk_phase[1];

   // Processor state, see above for details

   reg [2:0]   state;

   // Instruction, driven during fetch (which owns the register)

   wire [31:0] instr;

   // Program counter and status register, driven during execute (which owns
   // the registers)

   wire [23:0]  pc;
   wire [7:0] 	status;

   // Progress in modules

   wire 	exec_done;

   // RAM is always accessible

   assign RAM_CS = 1'b1;

   //=====================================
   //      Slow Clock
   //=====================================

   // Slow clock down by a factor of 4
   always @(posedge CLOCK_50 or posedge RESET) begin
      if (RESET == 1'b1) begin
	 clk_phase <= 2'b11;
      end
      else begin
         // Increment the counter
         clk_phase <= clk_phase + 1;
      end
   end

   //=======================================================
   //              Thunderclap Newman
   //=======================================================

   // Instantiate the generic memory. This can read and write one instruction
   // and one data address in each slow clock cycle.

   Memory i_Memory (.clk50        (CLOCK_50),
		    .rst          (RESET),
		    .clk_phase    (clk_phase),
		    .state        (state),
		    .ram_addr     (RAM_A),
		    .ram_data     (RAM_D),
		    .ram_oe       (RAM_OE),
		    .ram_we       (RAM_WE),
		    .d_raddr      (d_raddr),
		    .d_waddr      (d_waddr),
		    .d_rdata      (d_rdata),
		    .d_wdata      (d_wdata),
		    .d_we         (d_we),
		    .i_raddr      (i_raddr),
		    .i_rdata      (i_rdata),
		    .dbg_d_raddr  (dbg_d_raddr),
		    .dbg_d_waddr  (dbg_d_waddr),
		    .dbg_d_rdata  (dbg_d_rdata),
		    .dbg_d_wdata  (dbg_d_wdata),
		    .dbg_d_we     (dbg_d_we),
		    .dbg_i_raddr  (dbg_i_raddr),
		    .dbg_i_waddr  (dbg_i_waddr),
		    .dbg_i_rdata  (dbg_i_rdata),
		    .dbg_i_wdata  (dbg_i_wdata),
		    .dbg_i_we     (dbg_i_we) );

   // Instantiate the RegisterFile. This can read and write three instructions
   // in each slow clock cycle.

   RegisterFile i_RegisterFile (.clk             (clk_slow),
				.rst             (RESET),
				.state           (state),
				.rega_rregnum    (rega_rregnum),
				.rega_wregnum    (rega_wregnum),
				.rega_rdata      (rega_rdata),
				.rega_wdata      (rega_wdata),
				.rega_we         (rega_we),
				.regb_rregnum    (regb_rregnum),
				.regb_wregnum    (regb_wregnum),
				.regb_rdata      (regb_rdata),
				.regb_wdata      (regb_wdata),
				.regb_we         (regb_we),
				.regd_rregnum    (regd_rregnum),
				.regd_wregnum    (regd_wregnum),
				.regd_rdata      (regd_rdata),
				.regd_wdata      (regd_wdata),
				.regd_we         (regd_we),
				.dbg_reg_rregnum (dbg_reg_rregnum),
				.dbg_reg_wregnum (dbg_reg_wregnum),
				.dbg_reg_rdata   (dbg_reg_rdata),
				.dbg_reg_wdata   (dbg_reg_wdata),
				.dbg_reg_we      (dbg_reg_we) );

   // Instantiate the fetch engine

   Fetch i_Fetch (.clk          (clk_slow),
		  .rst          (RESET),
		  .state        (state),
		  .instr        (instr),
		  .pc           (pc),
		  .i_raddr      (i_raddr),
		  .i_rdata      (i_rdata));

   // Instantiate the execute engine

   Execute i_Execute (.clk              (clk_slow),
                      .rst              (RESET),
		      .state            (state),
		      .instr            (instr),
		      .pc               (pc),
		      .status           (status),
		      .exec_done        (exec_done),
		      .rega_rregnum     (rega_rregnum),
		      .rega_wregnum     (rega_wregnum),
		      .rega_rdata       (rega_rdata),
		      .rega_wdata       (rega_wdata),
		      .rega_we          (rega_we),
		      .regb_rregnum     (regb_rregnum),
		      .regb_wregnum     (regb_wregnum),
		      .regb_rdata       (regb_rdata),
		      .regb_wdata       (regb_wdata),
		      .regb_we          (regb_we),
		      .regd_rregnum     (regd_rregnum),
		      .regd_wregnum     (regd_wregnum),
		      .regd_rdata       (regd_rdata),
		      .regd_wdata       (regd_wdata),
		      .regd_we          (regd_we),
		      .d_raddr          (d_raddr),
		      .d_waddr          (d_waddr),
		      .d_rdata          (d_rdata),
		      .d_wdata          (d_wdata),
		      .d_we             (d_we),
		      .dbg_halt_req     (dbg_halt_req),
		      .dbg_halt_ack     (dbg_halt_ack),
		      .dbg_pc_lsw       (dbg_pc_lsw),
		      .dbg_pc_lsw_en	(dbg_pc_lsw_en),
		      .dbg_st_pc_msb	(dbg_st_pc_msb),
		      .dbg_st_pc_msb_en (dbg_st_pc_msb_en));

   //Instantiate the uart

   Uart i_Uart (.clk              (clk_slow),
		.rst              (RESET),
		.uart_tx          (UART_TX),
		.uart_rx          (UART_RX),
		.dbg_halt_req     (dbg_halt_req),
		.dbg_halt_ack     (dbg_halt_ack),
		.dbg_d_raddr      (dbg_d_raddr),
		.dbg_d_waddr      (dbg_d_waddr),
		.dbg_d_rdata      (dbg_d_rdata),
		.dbg_d_wdata      (dbg_d_wdata),
		.dbg_d_we         (dbg_d_we),
		.dbg_i_raddr      (dbg_i_raddr),
		.dbg_i_waddr      (dbg_i_waddr),
		.dbg_i_rdata      (dbg_i_rdata),
		.dbg_i_wdata      (dbg_i_wdata),
		.dbg_i_we         (dbg_i_we),
                .dbg_reg_rregnum  (dbg_reg_rregnum),
                .dbg_reg_wregnum  (dbg_reg_wregnum),
                .dbg_reg_rdata    (dbg_reg_rdata),
                .dbg_reg_wdata    (dbg_reg_wdata),
                .dbg_reg_we       (dbg_reg_we),
		.dbg_pc_lsw       (dbg_pc_lsw),
		.dbg_pc_lsw_en	  (dbg_pc_lsw_en),
		.dbg_st_pc_msb	  (dbg_st_pc_msb),
		.dbg_st_pc_msb_en (dbg_st_pc_msb_en));

   // Update the state machine. Note that there is no state change if debug is
   // active.

   always @(posedge clk_slow or posedge RESET) begin
      if (RESET == 1'b1) begin
	 state <= `STATE_FETCH1;
      end
      else begin
	 case (state)
	   `STATE_FETCH1: begin
	      state <= `STATE_FETCH2;
	   end

	   `STATE_FETCH2: begin

	      if (i_rdata[15] == 1'b1) begin
		 state <= `STATE_FETCH3;
	      end
	      else begin
		 state <= `STATE_EXEC1;
	      end
	   end

	   `STATE_FETCH3: begin

	      state <= `STATE_EXEC1;

	   end

	   `STATE_EXEC1: begin
	      state <= `STATE_EXEC2;
	   end

	   `STATE_EXEC2: begin
	      state <= (exec_done == 1'b1)
		? ((dbg_halt_req == 1'b1) ? `STATE_HALTED : `STATE_FETCH1)
		  : `STATE_EXEC3;
	   end

	   `STATE_EXEC3: begin
	      state <= (dbg_halt_req == 1'b1) ? `STATE_HALTED : `STATE_FETCH1;
	   end

	   `STATE_HALTED: begin
	      state <= (dbg_halt_req == 1'b1) ? `STATE_HALTED : `STATE_FETCH1;
	   end

	   default: begin

	      // Should never happen. Do nothing

	   end
	 endcase // case (state)
      end // else: !if(RESET == 1'b1)
   end // always @ (posedge clk)

endmodule
