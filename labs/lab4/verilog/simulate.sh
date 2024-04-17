#!/bin/bash
iverilog -s DMATestBench -o testbench DMA_tb.v ramDmaCi.v dualPortSSRAM.v
./testbench
#gtkwave dma_tb.vcd &
