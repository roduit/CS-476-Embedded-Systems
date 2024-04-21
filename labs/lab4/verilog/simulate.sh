#!/bin/bash
rm testbench
iverilog -s DMATestBench -o testbench DMA_tb.v ramDmaCi.v DMAController.v dualPortSSRAM.v
./testbench
#gtkwave dma_tb.vcd &
