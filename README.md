# AAP for MyStorm

A Verilog implementation of AAP for the [MyStorm](https://mystorm.uk/ "Mystorm
home page") FPGA board.

## About this implementation.

This is an almost completely rewritten from Dan Gorringe's DE0-Nano
implementation.  It takes advantages of Clifford Wolf's
[Icestorm](http://www.clifford.at/icestorm/ "Icestorm home page") tool flow
for Lattice ICE40 FPGAs, with synthesis by
[Yosys](http://www.clifford.at/yosys/ "Yosys home page") and place-and-route
by [Arachne-pnr](https://github.com/cseed/arachne-pnr "Arachne-pnr home
page").

## Technical details

The Verilog code is within the `src/verilog` directory, where the `Makefile`
can lint the code using Verilator (`make lint`), build a Verilator simulation
model (`make verilator`) or synthesize to a bitfile for iCE40-HX8K as used on
MyStorm (`make`).

All the Icestorm tools and Verilator should be on your `PATH`.

The limitations are present are:
- only 16-bit instruction set;
- only 16 registers;
- if SRAM is not present, only 2kW of imem and 2kB of dmem.

The processor is implemented as a state machine with up to 3 fetch states,
3 execute states and a halted state.

### Debug interface

Debugging is via the UART, clocking at 921600 baud.  The operations supported
are:
- "M" <addr> <val>: Write a byte to data memory
- "m" <addr>: Read a byte from data memory
- "N" <addr> <val>: Write a word to instruction memory
- "n" <addr>: Read a word from instruction memory
- "R" <regnum> <val>: Write a word to register
- "r" <regnum>: Read a word from register
- "h" : Halt the processor
- "c" : Unhalt the processor
- "?" : Return the processor state

Addresses are 24 bits for instruction memory, 16 bits otherwise. Values are
transmitted in network byte order (i.e. big-endian). Register 64 is the LSW of
the PC and register 65 is the status register and MSB of the PC.

Only "h" and "?" packets should be sent when the processor is running. All
other operations should first halt the process (using "h") and verify it is
halted (using "?") before being used.
