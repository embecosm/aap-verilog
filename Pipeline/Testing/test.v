module foo( clock, reset, enable, out);
input clock;
input enable;
input reset;
output [3:0] out;

// Note all inputs should be wires, output can be wire or reg
wire clock;
wire enable;
wire reset;
reg [3:0] out;

always @ (posedge clock)
begin
  if (reset == 1'b1) begin
    out <= 4'b0000;
  end

  else if (enable == 1'b1) begin
    out <= out + 1;
  end
end

endmodule // foo


////////////////////////////////////
// Testbench
////////////////////////////////////

module testbench();
reg clock, reset, enable;
wire [3:0] out;

//Init
initial begin
  // Log
  $monitor ("%g\t%b\t%b\t%b\t%b", $time, clock, reset, enable, out);
  $dumpfile("test.vcd");
  $dumpvars(clock, reset, enable, out);
  clock = 1;
  reset = 0;
  enable = 0;
  #5 reset = 1;
  #10 reset = 0;
  #10 enable = 1;
  #100 enable = 0;
  #5 $finish;
end

//Clkgen
always begin
  #5 clock = ~clock;
end

// Build foo
foo myFoo (clock, reset, enable, out);

endmodule // testbench
