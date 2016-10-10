# aap-verilog for DE0-Nano

This branch contains Dan Gorringe's Verilog implementation of AAP for the
DE0-Nano FPGA board.

## About the implementation

This was the first hardware implementation of AAP for FPGA, and is built using
the standard Mentor Graphics and Altera tools supplied by TerasIC.  It was
implemented over the summer of 2015 by Dan Gorringe, at the time a 16-year ld
student.  The completed project was presented at ORCONF '15 at CERN in October
of that year.

## Technical Details

The finished implementation is within 32BitProcessor as it can take the 32 bit
instructions instead of just the 16 bit ones that _16BitProcessor can.

FPGA contains the implementation that can be put onto a DE0_NANO.

Testing contains the files for a testbench to be created with iverilog and
then read with GTKwave.

A detailed guide to how we made this implementation can be found on embecosms
website:

http://www.embecosm.com/2015/12/18/a-student-implementation-of-aap-for-fpga/
