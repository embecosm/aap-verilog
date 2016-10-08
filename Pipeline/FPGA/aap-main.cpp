// Main program for verilator model

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


#include <verilated.h>
# include <verilated_vcd_c.h>
#include "VMyStorm.h"


#define UART_BAUD 921600


// Emulate a UART

// Return a value to drive on the UART RX pin of the MyStorm.  Idle value is
// 1.

static int
uart_rx (bool        is_reset,
	 vluint64_t  main_time)
{
  static int uart_cycle_cnt = 0;
  static int next_bit = 0;
  static const int DATALEN = 22;
  static const char data [DATALEN] = {
    'h',
    'N', 0x00, 0x00, 0x00, 0x14, 0x01,		// ADD   R0,#1
    'N', 0x00, 0x00, 0x01, 0x41, 0xff,		// BRA.s -1
    'R', 0x40, 0x00, 0x00,			// PC LSW
    'R', 0x41, 0x00, 0x00,                      // {SR, PC MSB}
    'c'
  };

  if (is_reset)
    {
      uart_cycle_cnt = 0;
      next_bit = 0;
      return 1;
    }

  int  this_uart_cycle = main_time * UART_BAUD / 1000000000;

  if (this_uart_cycle > uart_cycle_cnt)
    {
      // New UART cycle
      next_bit++;
      uart_cycle_cnt = this_uart_cycle;
    }

  int idx = (next_bit / 10);

  if (idx > (DATALEN - 1))
    idx = DATALEN - 1;

  int state = next_bit % 10;
  char byte = data[idx];

  int  res;
  switch (state)
    {
    case 0:

      // Were in idle - drive to get to start bit

      return 0;

    case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:

      // Send the bit of the char

      return (byte >> (state - 1)) & 0x1;

    case 9:

      // Stop bit - drive 1 to idle

      return 1;

    default:

      // Should be impossible!

      return 1;
    }
}


int
main (int   argc,
      char *argv[])
{
  VMyStorm *top = new VMyStorm;		// Instantiate
  int       resetCycles = 5;		// 5 clock cyles of reset
  vluint64_t main_time = 0;		// Current simulation time
  vluint16_t memory[0x40000];		// RAM

  // Set up VCD tracing

  Verilated::traceEverOn(true);		// Compute traced signals
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace (tfp, 99);			// Trace 99 levels of hierarchy
  tfp->open ("MyStorm_dump.vcd");	// Open the dump file

  while ((main_time < 1000000) && !Verilated::gotFinish ())
    {
      // Drive reset for some cycles

      if (resetCycles == 0)
	{
	  top->RESET = 0;
	}
      else
	{
	  top->RESET = 1;
	  resetCycles--;
	}

      // Full clock cycle

      top->CLOCK_50 = 1;
      top->UART_RX = uart_rx (resetCycles != 0, main_time);
      top->eval ();
      tfp->dump (main_time);
      main_time += 10;

      top->CLOCK_50 = 0;
      top->UART_RX = uart_rx (resetCycles != 0, main_time);
      top->eval ();
      tfp->dump (main_time);
      main_time += 10;

      // Memory handling

      if (top->RAM_CS)
	{
	  int tmp_data = top->RAM_D;

	  if (top->RAM_OE)
	    top->RAM_D = memory[top->RAM_A];

	  if (top->RAM_WE)
	    memory[top->RAM_A] = tmp_data;
	}
    }

  tfp->close ();
  top->final ();
}
