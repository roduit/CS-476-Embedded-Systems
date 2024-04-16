#!/bin/bash
#source /Users/vincentroduit/Documents/document_vincent/epfl/master/ma2/embedded_system/software/oss-cad-suite/environment
iverilog -s DMATestBench -o testbench DMA_tb.v ramDmaCi.v dualPortSSRAM.v
./testbench
#gtkwave dma_tb.vcd &
