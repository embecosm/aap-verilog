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

SRC = MyStorm.v      \
      Memory.v       \
      MemorySmall.v  \
      RegisterFile.v \
      Fetch.v        \
      Execute.v      \
      Debug.v        \
      UartRx.v       \
      UartTx.v

HDR = aap.vh

EXE_SRC = aap-main.cpp

aap.bin: aap.txt
	icepack $^ $@

aap.txt: $(PCF) aap.blif
	arachne-pnr -m 20000 -d 8k -P tq144:4k -p $(PCF) aap.blif -o $@

aap.blif: $(SRC) $(HDR)
	yosys -q -p "synth_ice40 -blif $@" -p "stat" $(SRC)

# Verilator lint

.PHONY: lint
lint: $(SRC) $(HDR)
	verilator -Wall --lint-only $(SRC)

# Verilator model. Turn off WIDTH warning, because Verilator gets this wrong
# (or the standard is wrong) for parameters.

.PHONY: verilator
verilator: $(SRC) $(HDR) $(EXE_SRC)
	verilator -Wno-WIDTH --trace --prefix VMyStorm -cc --exe \
                  --top-module MyStorm $(SRC) $(EXE_SRC)
	cd obj_dir; make -f VMyStorm.mk

.PHONY: clean
clean:
	$(RM) -f aap.blif aap.txt aap.ex aap.bin
	$(RM) -rf obj_dir
