# Makefile for AAP Mystorm

# Copyright Embecosm 2016.

# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# This file documents the AAP design for FPGA.  It describes Open Hardware and
# is licensed under the CERN OHL v. 1.2.

# You may redistribute and modify this documentation under the terms of the
# CERN OHL v.1.2. (http://ohwr.org/cernohl). This documentation is distributed
# WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
# SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the
# CERN OHL v.1.2 for applicable conditions

PCF = aap.pcf

TOP_SRC = MyStorm.v

SRC = Debug.v        \
      Execute.v      \
      Fetch.v        \
      Memory.v       \
      MemorySmall.v  \
      RegisterFile.v \
      UartRx.v       \
      UartTx.v

HDR = aap.vh

# FPGA bitstream

.PHONY: fpga
fpga: aap.bin

aap.bin: aap.txt
	icepack $^ $@

aap.txt: $(PCF) aap.blif
	arachne-pnr -m 20000 -d 8k -P tq144:4k -p $(PCF) aap.blif -o $@

aap.blif: $(TOP_SRC) $(SRC) $(HDR)
	yosys -q -p "synth_ice40 -blif $@" -p "stat" $(TOP_SRC) $(SRC)

# Verilator lint

.PHONY: lint
lint: $(TOP_SRC) $(SRC) $(HDR)
	verilator -Wall --lint-only $(TOP_SRC)


.PHONY: clean
clean:
	$(RM) -f aap.blif aap.txt aap.ex aap.bin
