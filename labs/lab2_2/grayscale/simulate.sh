#!/bin/bash
iverilog -s rgb565GrayscaleIse_tb -o testbench rgb_tb.v rgb565GrayscaleIse.v
./testbench
#gtkwave grayscale.vcd &