#!/bin/bash
if [ -f "testbench" ]; then
    rm testbench
fi

if [ -f "grayscale_conv.vcd" ]; then
    rm grayscale_conv.vcd
fi

iverilog -s grayscale_conv_tb -o testbench grayscale_conv_tb.v grayscale_conv.v

./testbench

gtkwave grayscale_conv.vcd &
