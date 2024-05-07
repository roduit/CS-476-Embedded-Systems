# CS-476: Embedded Systems Design
## PW6: Streaming interface

### Part 1
The first part can be found under the `part1` folder. The code `part1/virtual_prototype/programms/grayscale/src/grayscale.c` implements a solution for this task. In this file, the variable **\_\_DMA__** allows to use or not the DMA to do the transfer. It can be observed that using the DMA reduces the number of CPU cycles and also the stall and bus idle cycles. Furthermore, the frame transitions seems to be smoother than before.

### Part 2

This part can be found under the `part2` folder. The code `part2/virtual_prototype/modules/camera/verilog/camera.v` implements the solution. For the grayscale conversion, we use the module **rgb565Grayscale**, the same used in PW2. 

### Part 3
This part can be found under the `part3` folder. The code `part3/virtual_prototype/modules/camera/verilog/camera.v` implements the solution.