#!/bin/bash
if [ -f "testbench" ]; then
    rm testbench
fi

iverilog -s DMATestBench -o testbench ramDmaCi_tb.v ramDmaCi.v dualPortSSRAM.v
./testbench

# iverilog -s DMATestBench -o testbench ramDmaCi_tb.v ramDmaCi.v DMAController.v dualPortSSRAM.v
# ./testbench

#gtkwave ramDmaCi.vcd &
