# aap-verilog
A Verilog implementation of AAP.

The finished implementation is within 32BitProcessor as it can take the 32 bit instructions instead of just the 16 bit ones
that _16BitProcessor can.

FPGA contains the implementation that can be put onto a DE0_NANO.

Testing contains the files for a testbench to be created with iverilog and then read with GTKwave.

A detailed guide to how we made this implementation can be found on embecosms website: http://www.embecosm.com/2015/12/18/a-student-implementation-of-aap-for-fpga/
