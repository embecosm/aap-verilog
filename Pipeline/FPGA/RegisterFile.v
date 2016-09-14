// AAP register file

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


// Read 3 regs and the carry bit and write 3 regs and the carry bit each cycle

module RegisterFile (input         clk,
		     input         rst,

		     input [5:0]   rega_rregnum,
		     input [5:0]   rega_wregnum,
		     output [15:0] rega_rdata,
		     input [15:0]  rega_wdata,
		     input         rega_we,

		     input [5:0]   regb_rregnum,
		     input [5:0]   regb_wregnum,
		     output [15:0] regb_rdata,
		     input [15:0]  regb_wdata,
		     input         regb_we,

		     input [5:0]   regd_rregnum,
		     input [5:0]   regd_wregnum,
		     output [15:0] regd_rdata,
		     input [15:0]  regd_wdata,
		     input         regd_we);

   // Registers //
   reg [15:0]  register [63:0];

   // Read logic
   // This is combinatoral, this happens continuously

   assign rega_rdata = register[rega_rregnum];
   assign regb_rdata = register[regb_rregnum];
   assign regd_rdata = register[regd_rregnum];

   // Write logic //
   // This is sequential, it will only happen on the clock

   always @(posedge clk) begin
      if (rst) begin

 	 // Reset all Registers.  We lay this out by hand (we could use a
	 // generate), since verilator doesn't like non-blocking assignment to
	 // vectors

	 register[0]  <= 16'b0;
	 register[1]  <= 16'b0;
	 register[2]  <= 16'b0;
	 register[3]  <= 16'b0;
	 register[4]  <= 16'b0;
	 register[5]  <= 16'b0;
	 register[6]  <= 16'b0;
	 register[7]  <= 16'b0;
	 register[8]  <= 16'b0;
	 register[9]  <= 16'b0;
	 register[10] <= 16'b0;
	 register[11] <= 16'b0;
	 register[12] <= 16'b0;
	 register[13] <= 16'b0;
	 register[14] <= 16'b0;
	 register[15] <= 16'b0;
	 register[16] <= 16'b0;
	 register[17] <= 16'b0;
	 register[18] <= 16'b0;
	 register[19] <= 16'b0;
	 register[20] <= 16'b0;
	 register[21] <= 16'b0;
	 register[22] <= 16'b0;
	 register[23] <= 16'b0;
	 register[24] <= 16'b0;
	 register[25] <= 16'b0;
	 register[26] <= 16'b0;
	 register[27] <= 16'b0;
	 register[28] <= 16'b0;
	 register[29] <= 16'b0;
	 register[30] <= 16'b0;
	 register[31] <= 16'b0;
	 register[32] <= 16'b0;
	 register[33] <= 16'b0;
	 register[34] <= 16'b0;
	 register[35] <= 16'b0;
	 register[36] <= 16'b0;
	 register[37] <= 16'b0;
	 register[38] <= 16'b0;
	 register[39] <= 16'b0;
	 register[40] <= 16'b0;
	 register[41] <= 16'b0;
	 register[42] <= 16'b0;
	 register[43] <= 16'b0;
	 register[44] <= 16'b0;
	 register[45] <= 16'b0;
	 register[46] <= 16'b0;
	 register[47] <= 16'b0;
	 register[48] <= 16'b0;
	 register[49] <= 16'b0;
	 register[50] <= 16'b0;
	 register[51] <= 16'b0;
	 register[52] <= 16'b0;
	 register[53] <= 16'b0;
	 register[54] <= 16'b0;
	 register[55] <= 16'b0;
	 register[56] <= 16'b0;
	 register[57] <= 16'b0;
	 register[58] <= 16'b0;
	 register[59] <= 16'b0;
	 register[60] <= 16'b0;
	 register[61] <= 16'b0;
	 register[62] <= 16'b0;
	 register[63] <= 16'b0;

      end // if (rst)

      else begin

	 // Write any registers which are enabled

	 if (rega_we == 1) begin
	    register[rega_wregnum] <= rega_wdata;
	 end

	 if (regb_we == 1) begin
	    register[regb_wregnum] <= regb_wdata;
	 end

	 if (regd_we == 1) begin
	    register[regd_wregnum] <= regd_wdata;
	 end
      end // else: !if(rst)

   end // always @ (posedge clk)

endmodule
