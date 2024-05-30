#!/bin/bash
if [ -f "testbench" ]; then
    rm testbench
fi

if [ -f "sobel.vcd" ]; then
    rm sobel.vcd
fi

iverilog -s sobel_tb -o testbench sobel_tb.v edge_detection.v sobel.v
./testbench

#gtkwave sobel.vcd
