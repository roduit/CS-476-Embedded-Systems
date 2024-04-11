#!/bin/bash
iverilog -s ramDmaCiTestbench -o testbench ramDmaCi_tb.v ramDmaCi.v dualPortSSRAM.v
./testbench
gtkwave ramDmaCi.vcd &
