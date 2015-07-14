
module regfile (
    // This component stores state, so needs a clock and a reset
    clock,
    reset,

    // The register file has two ports: one read, one write

    // Inputs
    rd1,        // Which register to read for read port 1

    wr1,        // Which register to write for write port 1 (WP1)
    wr1_data,   // What to write to the register for WP1
    wr1_enable, // Whether or not we should write to WP1 this cycle

    // Outputs
    rd1_data    // The data stored in the register specified by rd1
    );

input clock;
input reset;

input [1:0]     rd1;            // 2 bits wide, because we have 4 registers
input [1:0]     wr1;
input [15:0]    wr1_data;       // 16 bits wide, because that is our data width
input           wr1_enable;

output [15:0]  rd1_data;        // 16 bits wide, because that is our data width

//// Internal variables
reg [15:0] registers [0:3];

// This is the sequential bit of the register file. We also use the positive
// edge of the reset signal in the sensitivity list to infer an asynchronous
// reset - we want to reset whenever we see that signal, rather than just on a
// clock edge.
always @(posedge clock or posedge reset) begin
    if (reset) begin
        // reset the registers
        registers[0] = 0;
        registers[1] = 0;
        registers[2] = 0;
        registers[3] = 0;
    end
    else begin
        // This is our sequential part, i.e. we want to copy the data on the
        // write port into the respective register, if write is enabled.
        registers[wr1] = wr1_data;
    end
end

// This is the combinatorial bit of the design - whenever the registers
// change, or the register we want to read changes, we change the output.
assign rd1_data = registers[rd1];

endmodule
