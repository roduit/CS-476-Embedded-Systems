#!/bin/bash
iverilog -s fifoTestbench -o testbench fifo_tb.v fifo.v counter.v ssram.v
./testbench
gtkwave fifoSignals.vcd &

