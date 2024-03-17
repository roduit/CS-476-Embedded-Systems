#!/bin/bash
iverilog -s profileCi_tb -o testbench test_profiler.v profiler.v counter.v sr_latch.v
./testbench
#gtkwave profiler.vcd
