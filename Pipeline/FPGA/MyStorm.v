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

/* -----\/----- EXCLUDED -----\/-----
   reg [17:0] RAM_A;
   reg [15:0] RAM_D;
   reg 	      RAM_OE;
   reg 	      RAM_WE;
 -----/\----- EXCLUDED -----/\----- */

   // Instruction and data memory ports

   reg [23:0] i_raddr;
//   reg [23:0] i_waddr;
   reg [15:0] i_rdata;
//   reg [15:0] i_wdata;
//   reg        i_we;

   reg [15:0] d_raddr;
   reg [15:0] d_waddr;
   reg [7:0]  d_rdata;
   reg [7:0]  d_wdata;
   reg        d_we;

   // Other memory ports

/* -----\/----- EXCLUDED -----\/-----
   wire [31:0] fetchoutput;
   wire [5:0]  operationnumber;
   reg         opcodemem;

   wire [5:0]  source_1;
   wire [5:0]  source_2;

   wire [21:0] signed_1;
   wire [15:0] signed_2;
   wire [9:0]  signed_3;

   wire [5:0]  unsigned_1;
   wire [15:0] unsigned_2;
   wire [8:0]  unsigned_3;
   wire [9:0]  unsigned_4;
   wire [8:0]  unsigned_5;

   wire [5:0]  i_rd1_addr;
   wire [5:0]  i_rd2_addr;
   wire [15:0] i_rd1_out;
   wire [15:0] i_rd2_out;

   wire [8:0]  pcchange;
   wire [5:0]  pclocation;

   wire [2:0]  pcjumpenable;

   reg [15:0]  fetch1;
   reg [15:0]  fetch2;

   wire        uart_reset;
   wire        uart_stop;
   wire        uart_continue;
   wire        uart_step_en;
   wire [5:0]  uart_step_volume;
 -----/\----- EXCLUDED -----/\----- */

   reg         CLOCK_12_5;              // Slower speed clock
   reg [1:0]   clk_phase;

   // Missing declarations

/* -----\/----- EXCLUDED -----\/-----
   wire        nop_stop;
   wire        flush;
   wire        super_duper_a;
   wire        super_duper_b;
 -----/\----- EXCLUDED -----/\----- */

   // Processor state:
   // - two fetch states (decode is combinatorial)
   // - one execute state
   // - one writeback state

   // RAM is always accessible

   assign RAM_CS = 1'b1;

   // Place holders
/* -----\/----- EXCLUDED -----\/-----
   assign LED = {KEY,1'b1};
   assign UART_TX = UART_RX;
 -----/\----- EXCLUDED -----/\----- */

   //=======================================================
   //  Structural coding
   //=======================================================

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
            CLOCK_12_5 <= ~CLOCK_12_5;
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
		    // .i_waddr   (i_waddr),
		    .i_rdata   (i_rdata),
		    // .i_wdata   (i_wdata),
		    // .i_we      (i_we),
		    .d_raddr   (d_raddr),
		    .d_waddr   (d_waddr),
		    .d_rdata   (d_rdata),
		    .d_wdata   (d_wdata),
		    .d_we      (d_we) );

   // Instantiate the RegisterFile. This can read and write three instructions
   // in each slow clock cycle.

   RegisterFile i_RegisterFile (.clk          (CLOCK_12_5),
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

   // Instantiate the execute engine

   Execute i_Execute (.clk          (CLOCK_12_5),
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
		      .regd_we      (regd_we),
		      .i_raddr      (i_raddr),
		      .i_rdata      (i_rdata),
		      .d_raddr      (d_raddr),
		      .d_waddr      (d_waddr),
		      .d_rdata      (d_rdata),
		      .d_wdata      (d_wdata),
		      .d_we         (d_we) );

      //Instantiate the uart
/* -----\/----- EXCLUDED -----\/-----
   uart
     i_uart (.clock                   (CLOCK_12_5),
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
