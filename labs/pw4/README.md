# CS-476: Embedded Systems Design
## PW4: Build-in peripheral DMA-controller

### Part 1
The purpose of the first task was to construct a first skeleton for the DMA attached memory. In order to test the functionalities of the module, a testbench is created. The code for this testbench can be found under `part1/virtual_prototype/verilog/ramDmaCi_tb.v`. A .gtkw file is also provided with all the interesting signals nicely ordered. This file can be found under: `part1/virtual_prototype/verilog/part1.gtkw`. \
This testbench performs write operations initiated by the CPU to a memory. After what, it reads the same memory locations.

![img_tb1](./ressources/tb_part1.png)

This first testbench can be decomposed in three phases.
* During the first phase, the module is reset and all signals are zero
* The second phase consists of multiples write phases. The done signal is set to 1 at the same time as the start signal. Values 36,129,9,99 and 13 are written at addresses from 1 to 5.
* The third phase consists of reading the same addresses that was written in phase 2. Result gives the corresponding values with 1 cycle delay. Furthermore, the done signal is raised one cylce after the done signal.

### Part 2

### Part 3