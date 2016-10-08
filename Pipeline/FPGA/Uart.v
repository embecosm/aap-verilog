// Verilog for UART debugger

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


// This is the UART debug interface. Commands are a single byte, followed by
// zero or more argument bytes. Addresses and data are sized
// appropriately. A response of up to 2 bytes may be made. Total sizes in and
// address space the MS byte of each is ignoredout are shown below.

//   M <addr> <data>   write byte to data memory   (4 bytes in, 0 bytes out)
//   m <addr>          read byte from data memory  (3 bytes in, 1 byte out)
//   N <addr> <word>   write word to code memory   (6 bytes in, 0 bytes out)
//   n <addr>          read  word from code memory (4 bytes in, 2 bytes out)
//   R <reg> <word>    write word to register      (4 bytes in, 0 bytes out)
//   r <reg>           read word from register     (2 bytes in, 2 bytes out)
//   c                 continue execution          (1 byte in,  0 bytes out)
//   h                 halt execution              (1 byte in,  0 bytes out)
//   ?                 is processor halted         (1 byte in,  1 byte out)

// All values are in network byte order, i.e. big-endian.

module Uart
  #(parameter UART_BAUD = 921600,
              CLK_RATE  = 12500000)
   (input         clk,
    input 	  rst,

    output 	  uart_tx,
    input 	  uart_rx,

    // Debug control

    output 	  dbg_halt_req, // We want to halt
    input 	  dbg_halt_ack, // Entered halted state

    // Debug access to memory

    output [15:0] dbg_d_raddr,
    output [15:0] dbg_d_waddr,
    input [7:0]   dbg_d_rdata,
    output [7:0]  dbg_d_wdata,
    output 	  dbg_d_we,

    output [23:0] dbg_i_raddr,
    output [23:0] dbg_i_waddr,
    input [15:0]  dbg_i_rdata,
    output [15:0] dbg_i_wdata,
    output 	  dbg_i_we,

    // Debug access to registers

    output [5:0]  dbg_reg_rregnum,
    output [5:0]  dbg_reg_wregnum,
    input [15:0]  dbg_reg_rdata,
    output [15:0] dbg_reg_wdata,
    output 	  dbg_reg_we,

    // Debug access to write PC and carry

    output [15:0] dbg_pc_lsw,
    output 	  dbg_pc_lsw_en,
    output [15:0] dbg_st_pc_msb,
    output 	  dbg_st_pc_msb_en);

   // Constants for debug state

   localparam DS_IDLE    = 4'h0;	// Waiting
   localparam DS_CMD     = 4'h1;	// Analyze command
   localparam DS_ARGS    = 4'h2;	// Get args
   localparam DS_EVAL1   = 4'h3;	// First cycle of evaluation
   localparam DS_EVAL2   = 4'h4;	// Second cycle of evaluation

   // Register some outputs

   reg           dbg_halt_req;

   reg           dbg_d_we;
   reg           dbg_i_we;

   reg [15:0] 	 dbg_pc_lsw;
   reg 		 dbg_pc_lsw_en;
   reg [15:0] 	 dbg_st_pc_msb;
   reg 		 dbg_st_pc_msb_en;

   // UART details

   reg [7:0]   tx_data;			// Data to transmit
   wire        tx_en;			// Enable transmit
   wire        tx_ack;			// Data accepted to transmit
   wire        tx_done;			// Byte transmitted

   wire [7:0]  rx_data;			// Data received
   wire        rx_valid;			// Data is now available.

   // Command, data and address for debug

   reg [7:0] 	 dbg_args [5];		// Raw args
   reg [2:0] 	 dbg_arg_idx;           // How many args left to get

   reg [7:0] 	 dbg_cmd;

   // Debugger state

   reg [3:0] 	 dbg_state;


   // Map some outputs to particular argument combinations

   // Instantiate UART receiver

   UartRx #(UART_BAUD, CLK_RATE) i_UartRx
     (.clk           (clk),
      .rst           (rst),
      .uart_rx       (uart_rx),
      .uart_rx_valid (rx_valid),
      .uart_rx_data  (rx_data));

   // Instantiate UART transmitter

   UartTx #(UART_BAUD, CLK_RATE) i_UartTx
     (.clk           (clk),
      .rst           (rst),
      .uart_tx       (uart_tx),
      .uart_tx_data  (tx_data),
      .uart_tx_en    (tx_en),
      .uart_tx_ack   (tx_ack),
      .uart_tx_done  (tx_done));

   // Listen out for data

   always @(posedge clk or posedge rst) begin
      if (rst == 1) begin
	 dbg_halt_req     <= 1'b0;
	 dbg_cmd          <= 8'b0;
	 dbg_state        <= DS_IDLE;
	 dbg_pc_lsw_en    <= 1'b0;
	 dbg_st_pc_msb_en <= 1'b0;
	 dbg_i_we         <= 1'b0;
	 dbg_d_we         <= 1'b0;
      end
      else begin

	 // State machine for handling UART commands

	 case (dbg_state)

	   DS_IDLE: begin

	      if (rx_valid) begin

		 // A new command

		 dbg_cmd   <= rx_data;
		 dbg_state <= DS_CMD;
	      end
	   end

	   DS_CMD: begin

	      // Work out how many arg bytes to get. We have only just had a
	      // valid rx data, so there will be nothing waiting for us in
	      // this state.

	      case (dbg_cmd)

		 "c", "h", "?": begin
		    dbg_state <= DS_EVAL1;
		 end

		"r": begin
		   dbg_arg_idx <= 3'd0;
		end

		"m": begin
		   dbg_arg_idx <= 3'd1;
		   dbg_state <= DS_ARGS;
		end

		"M", "n", "R": begin
		   dbg_arg_idx <= 3'd2;
		   dbg_state <= DS_ARGS;
		end

		"N": begin
		   dbg_arg_idx <= 3'd4;
		   dbg_state <= DS_ARGS;
		end

		default: begin

		   // Should never happen!
		   dbg_state <= DS_IDLE;
		end
	      endcase // case (dbg_cmd)
	   end // case: DS_CMD

	   DS_ARGS: begin

	      // Get an argument when one is available

	      if (rx_valid) begin
		 dbg_args[dbg_arg_idx] <= rx_data;

		 if (dbg_arg_idx == 3'b0) begin

		    // Have all args, now evaluate

		    dbg_state <= DS_EVAL1;
		 end
		 else begin

		    // More arg(s) to get

		    dbg_arg_idx <= dbg_arg_idx - 3'b1;
		 end
	      end // if (rx_valid)
	   end // case: DS_ARGS

	   DS_EVAL1: begin

	      // We have all the arguments. Now execute what has been
	      // requested.

	      case (dbg_cmd)

		"M": begin

		   // Write to data memory. Arg bytes are
		   // 2: addr MS byte
		   // 1: addr LS byte
		   // 0: data byte

		   dbg_d_waddr <= {dbg_args[2], dbg_args[1]};
		   dbg_d_wdata <= dbg_args[0];
		   dbg_d_we    <= 1'b1;

		   dbg_state <= DS_EVAL2;

		end // case: "M"

		"N": begin

		   // Write to code memory. Arg bytes are
		   // 4: addr MS byte
		   // 3: addr middle byte
		   // 2: addr LS byte
		   // 1: data MS byte
		   // 0: data LS byte

		   dbg_i_waddr <= {dbg_args[4], dbg_args[3], dbg_args[2]};
		   dbg_i_wdata <= {dbg_args[1], dbg_args[0]};
		   dbg_i_we    <= 1'b1;

		   dbg_state <= DS_EVAL2;

		end // case: "M"

		"R": begin

		   // Write to a register. Reg 64 is PC LSW and 64 is SR/PC MSW
		   // 2: regnum
		   // 1: data MS byte
		   // 0: data LS byte

		   if (dbg_args[2] < 8'h40) begin

		      // General regs

		      dbg_reg_wregnum <= dbg_args[2][5:0];
		      dbg_reg_wdata   <= {dbg_args[1], dbg_args[0]};
		      dbg_reg_we      <= 1'b1;
		   end
		   else if (dbg_args[2] == 8'h40) begin

		      // PC LSW

		      dbg_pc_lsw    <= {dbg_args[1], dbg_args[0]};
		      dbg_pc_lsw_en <= 1'b1;
		   end
		   else if (dbg_args[2] == 8'h41) begin

		      // ST and PC MSB

		      dbg_st_pc_msb    <= {dbg_args[1], dbg_args[0]};
		      dbg_st_pc_msb_en <= 1'b1;
		   end

		   dbg_state <= DS_EVAL2;

		end // case: "R"

		"c": begin

		   // Continue execution

		   dbg_halt_req <= 1'b0;
		   dbg_state <= DS_IDLE;
		end

		"h": begin

		   // Request halt and wait for the ack.

		   dbg_halt_req <= 1'b1;

		   if (dbg_halt_ack == 1'b1) begin
		      dbg_state    <= DS_IDLE;
		   end

		end

		default: begin

		   // Nothing to do for other commands for now.

		   dbg_state <= DS_IDLE;
		end
	      endcase // case (dbg_cmd)
	   end // case: DS_EVAL1

	   DS_EVAL2: begin

	      // Second cycle of evaluation

	      case (dbg_cmd)

		"M": begin

		   // Data memory write should be complete.

		   dbg_d_we    <= 1'b0;
		   dbg_state   <= DS_IDLE;
		 end

		"N": begin

		   // Code memory write should be complete.

		   dbg_i_we    <= 1'b0;
		   dbg_state   <= DS_IDLE;
		 end

		"R": begin

		   // Register write should be complete.

		   dbg_reg_we       <= 1'b0;
		   dbg_pc_lsw_en    <= 1'b0;
		   dbg_st_pc_msb_en <= 1'b0;
		   dbg_state        <= DS_IDLE;
		 end

		default: begin

		   // Other commands have nothing left to do

		   dbg_state <= DS_IDLE;
		end
	      endcase // case (dbg_cmd)
	   end // case: DS_EVAL2

	   default: begin

	      // Should be impossible.

	      dbg_state <= DS_IDLE;
	   end
	 endcase // case (dbg_state)
      end // else: !if(rst == 1)
   end // always @ (posedge clk or posedge rst)

endmodule
