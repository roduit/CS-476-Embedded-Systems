#!/bin/bash
#source /Users/vincentroduit/Documents/document_vincent/epfl/master/ma2/embedded_system/software/oss-cad-suite/environment
iverilog -s ramDmaCiTestbench -o testbench ramDmaCi_tb.v ramDmaCi.v dualPortSSRAM.v
./testbench
#gtkwave ramDmaCi.vcd &
