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

// Each instruction takes multiple cycles, controlled by a state machine. The
// state machine is advanced at the start of each cycle based on the state at
// the end of the previous cycle.  Actions are associated with the transition
// change. i.e. this is a Moore machine.

// Transitions are as follows.

// `STATE_EXECUTE -> `STATE_FETCH

//     Condition: if previous cycle indicated execution was complete.
//     Action: Fetch one word from instruction memory

// `STATE_FETCH -> `STATE_FETCH

//     Condition: if previous cycle indicated another instruction needed to be
//                fetched.
//     Action: Fetch a further word from instruction memory

// `STATE_FETCH -> `STATE_EXECUTE

//     Condition: if previous cycle indicated no more instructions needed to
//                be fetched
//     Action: Execute functional behavior of instruction and prepare any
//             reads/writes.

// `STATE_EXECUTE -> `STATE_EXECUTE

//     Condition: if previous cycle indicated more cycles were needed for
//                evaluation
//     Action: Continue functional behavior of instruction

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
                 input         RESET,    // Posedge reset

                 // User I/O
/* -----\/----- EXCLUDED -----\/-----
                 output [3:0]  LED,      // LED bank
                 input [2:0]   KEY,      // DIP switches
 -----/\----- EXCLUDED -----/\----- */

                 // UART
/* -----\/----- EXCLUDED -----\/-----
                 output        UART_TX,
                 input         UART_RX,
 -----/\----- EXCLUDED -----/\----- */

		 // Memory (static RAM)
		 output        RAM_CS,   // Chip select
		 output        RAM_WE,   // Write enable
		 output        RAM_OE,   // Output enable

		 output [17:0] RAM_A,    // Address
		 inout[15:0]   RAM_D     // Data
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

   //=======================================================
   //  SRAM declarations
   //=======================================================

   // Instruction and data memory ports

   reg [23:0] i_raddr;			// Only ever driven by `STATE_FETCH
   reg [23:0] i_waddr;
   reg [15:0] i_rdata;
   reg [15:0] i_wdata;
   reg        i_we;

   reg [15:0] d_raddr;
   reg [15:0] d_waddr;
   reg [7:0]  d_rdata;
   reg [7:0]  d_wdata;
   reg        d_we;

   reg         clk_slow;		// Slower speed clock
   reg [1:0]   clk_phase;

   // Processor state:
   // - one fetch state
   // - one execute state
   // - one writeback state

   reg [1:0]   state;

   // Instruction, driven during fetch (which owns the register)

   wire [31:0] instr;

   // Program counter, driven during execute (which owns the register)

   wire [23:0]  pc;

   // Progress in modules

   wire 	fetch_done;
   wire 	exec_done;
   wire 	wb_done;

   // RAM is always accessible

   assign RAM_CS = 1'b1;

   //=====================================
   //      Slow Clock
   //=====================================

   // Slow clock down by a factor of 4
   always @(posedge CLOCK_50) begin
      if (RESET == 1'b1) begin
	 clk_phase  <= 2'b00;
      end
      else begin
	 if (clk_phase[0] == 1) begin
            clk_slow <= ~clk_slow;
	 end
	 else begin
            // Otherwise increment the counter
            clk_phase <= clk_phase + 1;
	 end
      end
   end

   //=======================================================
   //              Thunderclap Newman
   //=======================================================

   // Instantiate the generic memory. This can read and write one instruction
   // and one data address in each slow clock cycle.

   Memory i_Memory (.clk50     (CLOCK_50),
		    .clk_phase (clk_phase),
		    .ram_addr  (RAM_A),
		    .ram_data  (RAM_D),
		    .ram_oe    (RAM_OE),
		    .ram_we    (RAM_WE),
		    .i_raddr   (i_raddr),
		    .i_waddr   (i_waddr),
		    .i_rdata   (i_rdata),
		    .i_wdata   (i_wdata),
		    .i_we      (i_we),
		    .d_raddr   (d_raddr),
		    .d_waddr   (d_waddr),
		    .d_rdata   (d_rdata),
		    .d_wdata   (d_wdata),
		    .d_we      (d_we) );

   // Instantiate the RegisterFile. This can read and write three instructions
   // in each slow clock cycle.

   RegisterFile i_RegisterFile (.clk          (clk_slow),
				.rst          (RESET),
				.rega_rregnum (rega_rregnum),
				.rega_wregnum (rega_wregnum),
				.rega_rdata   (rega_rdata),
				.rega_wdata   (rega_wdata),
				.rega_we      (rega_we),
				.regb_rregnum (regb_rregnum),
				.regb_wregnum (regb_wregnum),
				.regb_rdata   (regb_rdata),
				.regb_wdata   (regb_wdata),
				.regb_we      (regb_we),
				.regd_rregnum (regd_rregnum),
				.regd_wregnum (regd_wregnum),
				.regd_rdata   (regd_rdata),
				.regd_wdata   (regd_wdata),
				.regd_we      (regd_we) );

   // Instantiate the fetch engine

   Fetch i_Fetch (.clk        (clk_slow),
		  .rst        (RESET),
		  .state      (state),
		  .instr      (instr),
		  .pc         (pc),
		  .fetch_done (fetch_done),
		  .i_raddr    (i_raddr),
		  .i_rdata    (i_rdata) );

   // Instantiate the execute engine

   Execute i_Execute (.clk          (clk_slow),
                      .rst          (RESET),
		      .state        (state),
		      .instr        (instr),
		      .pc           (pc),
		      .fetch_done   (fetch_done),
		      .exec_done    (exec_done),
		      .rega_rregnum (rega_rregnum),
		      .rega_wregnum (rega_wregnum),
		      .rega_rdata   (rega_rdata),
		      .rega_wdata   (rega_wdata),
		      .rega_we      (rega_we),
		      .regb_rregnum (regb_rregnum),
		      .regb_wregnum (regb_wregnum),
		      .regb_rdata   (regb_rdata),
		      .regb_wdata   (regb_wdata),
		      .regb_we      (regb_we),
		      .regd_rregnum (regd_rregnum),
		      .regd_wregnum (regd_wregnum),
		      .regd_rdata   (regd_rdata),
		      .regd_wdata   (regd_wdata),
		      .regd_we      (regd_we),
		      .d_raddr      (d_raddr),
		      .d_waddr      (d_waddr),
		      .d_rdata      (d_rdata),
		      .d_wdata      (d_wdata),
		      .d_we         (d_we) );

   // Update the state machine

   always @(posedge clk_slow) begin
      if (RESET == 1'b1) begin
	 state <= `STATE_EXECUTE;
      end
      else begin
	 case (state)
	   `STATE_EXECUTE: begin

	      // Only advance if execution has completed

	      if (exec_done == 1'b1) begin
		 state <= `STATE_FETCH;
	      end
	   end // case: `STATE_EXECUTE

	   `STATE_FETCH: begin

	      // Only advance if we have finished fetching

	      if (fetch_done == 1'b1) begin
		 state <= `STATE_EXECUTE;
	      end
	   end

	   default: begin

	      // Should never happen. Do nothing

	   end
	 endcase // case (state)
      end // else: !if(RESET == 1'b1)
   end // always @ (posedge clk)

      //Instantiate the uart
/* -----\/----- EXCLUDED -----\/-----
   uart
     i_uart (.clock                   (clk_slow),
             .superclock              (CLOCK_50),
             .reset                   (RESET),
             .UART_TX                 (UART_TX),
             .UART_RX                 (UART_RX),
             .reg_rd3                 (reg_rd3),
             .reg_rd3_out             (reg_rd3_out),
             .reg_wr3                 (reg_wr3),
             .reg_wr3_data            (reg_wr3_data),
             .reg_wr3_en              (reg_wr3_en),
             .i_rd2_addr                   (i_rd2_addr),
             .i_rd2_out               (i_rd2_out),
             .i_wr2_addr              (i_wr2_addr),
             .i_wr2_data              (i_wr2_data),
             .i_wr2_en                (i_wr2_en),
             .d_rd3                   (d_rd3),
             .d_rd3_out               (d_rd3_out),
             .d_wr3                   (d_wr3),
             .d_wr3_data              (d_wr3_data),
             .d_wr3_en                (d_wr3_en),
             .prev_pc (prev_pc),
             .pc          (pc),
             .uart_stop               (uart_stop),
             .uart_continue           (uart_continue),
             .uart_step_en            (uart_step_en),
             .uart_step_volume        (uart_step_volume),
             .uart_reset              (uart_reset) );
 -----/\----- EXCLUDED -----/\----- */

endmodule
