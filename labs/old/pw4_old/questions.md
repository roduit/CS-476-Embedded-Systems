# Questions

* Should we request the bus grant access after each burst (if block size > burst size) ?

* What to do for the read/write to RAM (code 0b000) ? Because the CPU is already reading/writing

* When we want to start the transfer, do we have the bus or we have to request it? (DMA or CPU that request the bus?)

* Is the control register [0] signal set to 0 when the DMA is in Idle?


# TODO
- [ ] Review the switch case in order to make the result a wire and also check for the write enable
- [ ] Implement the DMA module that will handle the bus interface
- [ ] Implement the bus interface
- [ ] Implement the test program in C