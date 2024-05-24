#!/bin/bash
if [ -f "testbench" ]; then
    rm testbench
fi

iverilog -s sobel_tb -o testbench sobel_tb.v edge_detection.v sobel.v
./testbench

gtkwave sobel.vcd &
