# CS-476: Embedded Systems Design
## PW4: Built-in Peripheral DMA Controller

### Part 1
The purpose of the first task was to construct a skeleton for the DMA-attached memory. In order to test the functionalities of the module, a testbench was created. The code for this testbench can be found under `part1/virtual_prototype/verilog/ramDmaCi_tb.v`. A .gtkw file is also provided with all the interesting signals nicely ordered. This file can be found under: `part1/virtual_prototype/verilog/part1.gtkw`. This testbench performs write operations initiated by the CPU to a memory. After that, it reads the same memory locations.

![img_tb1](./ressources/tb_part1.png)

This first testbench can be decomposed into three phases. 
- During the first phase, the module is reset, and all signals are set to zero. 
- The second phase consists of multiple write operations. The done signal is set to 1 at the same time as the start signal. Values 36, 129, 9, 99, and 13 are written at addresses from 1 to 5. 
- The third phase consists of reading the same addresses that were written in phase 2. The result gives the corresponding values with a 1-cycle delay. Furthermore, the done signal is raised one cycle after the done signal. The proper function of the module is then demonstrated.

### Part 2
In this second part, the DMA controller is implemented. Writing from the bus to the SRAM should be possible. At first glance, a testbench is implemented to verify the functionality of this module. This testbench can be found under `part2/virtual_prototype/systems/singleCore/verilog/ramDmaCi_tb.v`. First of all, the DMA has to be set (i.e., the block size, the burst size, etc.). When all those registers are set, the write operation can start. Again, code written in C (`labs/pw4/part2/virtual_prototype/programms/helloWorld/src/hello.c`) is provided and shows that the write operation works. This code shows that only values are stored in the first addresses, i.e. when trying reading a value from an address that was not set previously, an undetermined value is returned.

### Part 3
The last part consists of writing from the SRAM to the bus. A testbench (The same as stated in part 2) shows the functionality of this part. Nevertheless, it has shown some difficulties when downloaded on the board. We expect an error on a condition involving the busIn_busy signal. When forcing the system to ignore the busy signal, the program managed to end. But with this busy signal, it enters a deadlock sequence and therefore cannot perform the write operation. This behavior can be observed using the same code as stated in part two and set the control register to 0x02. \
After several days of trying to debug this part, no solution has been found. It can also come from the fact that the testbench that we implemented does not fit perfectly the behavior of the real system and might explain the observed differences. 
