`include "regfile.v"

module regfile_tb;

reg clock;
reg reset;

reg [1:0]     rd1;            // 2 bits wide, because we have 4 registers
reg [1:0]     wr1;
reg [15:0]    wr1_data;       // 16 bits wide, because that is our data width
reg           wr1_enable;

wire [15:0]  rd1_data;        // 16 bits wide, because that is our data width

// Declare the component, and hook it up to our regs/wires
regfile regfile_impl(
    clock,
    reset,
    rd1,
    wr1,
    wr1_data,
    wr1_enable,
    rd1_data);

initial begin
    clock = 0;
    reset = 0;
    rd1 = 0;
    wr1 = 0;
    wr1_data = 0;
    wr1_enable = 0;
    $dumpvars;

    // Initially reset
#5  reset = 1;
#20 reset = 0;
#20

    // Start some tests //////////////////////////////////////////////////////

    // Write 0x10 to register 0
    wr1_data    = 16'h0010;
    wr1         = 0;
    wr1_enable  = 1;
#20
    // Write 0x20 to register 1
    wr1_data    = 16'h0020;
    wr1         = 1;
    wr1_enable  = 1;
#20
    // Write 0x20 to register 2
    wr1_data    = 16'hABCD;
    wr1         = 2;
    wr1_enable  = 1;
#20
    wr1_enable  = 0;

    // Read out register 1
    rd1         = 1;
#20
    // Read out register 2
    rd1         = 2;

    #10 $finish;
end


always
    #10 clock = ~clock;

endmodule
