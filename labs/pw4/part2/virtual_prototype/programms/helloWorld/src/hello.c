// #include <stdio.h>
// #include <ov7670.h>
// #include <swap.h>
// #include <vga.h>


// int main () {
//   // volatile uint16_t rgb565[640*480];
//   // volatile uint8_t grayscale[640*480];
//   // volatile uint32_t result, cycles,stall,idle;
//   // volatile unsigned int *vga = (unsigned int *) 0X50000020;
//   // camParameters camParams;
//   vga_clear();
  
//   // printf("Initialising camera (this takes up to 3 seconds)!\n" );
//   // camParams = initOv7670(VGA);
//   // printf("Done!\n" );
//   // printf("NrOfPixels : %d\n", camParams.nrOfPixelsPerLine );
//   // result = (camParams.nrOfPixelsPerLine <= 320) ? camParams.nrOfPixelsPerLine | 0x80000000 : camParams.nrOfPixelsPerLine;
//   // vga[0] = swap_u32(result);
//   // printf("NrOfLines  : %d\n", camParams.nrOfLinesPerImage );
//   // result =  (camParams.nrOfLinesPerImage <= 240) ? camParams.nrOfLinesPerImage | 0x80000000 : camParams.nrOfLinesPerImage;
//   // vga[1] = swap_u32(result);
//   // printf("PCLK (kHz) : %d\n", camParams.pixelClockInkHz );
//   // printf("FPS        : %d\n", camParams.framesPerSecond );


//   // =============================================================================
//   // =====           Test the ramDmaCi to read and write to SRAM             =====
//   // =============================================================================

//   // printf("\n===== Writing and reading from CPU to CI memory =====\n\n");
  
//   // // Write
//   // uint32_t value_to_test = 0x123;
//   // uint32_t address_and_wen = 0x00000204;

//   // for (int i = 0; i < 5; i++) {
//   //   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"(address_and_wen),[in2]"r"(value_to_test));
//   //   printf("Write value %d at address 0x%x\n", value_to_test, address_and_wen - 512);
//   //   value_to_test += 1;
//   //   address_and_wen += 1;
//   // }

//   // printf("\n");

//   // // Read
//   // address_and_wen = 0x00000004;
//   // uint32_t read_value;

//   // for (int i = 0; i < 5; i++) {
//   //   asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_value):[in1]"r"(address_and_wen));
//   //   printf("Read value  %d at address 0x%x\n", read_value, address_and_wen);
//   //   value_to_test += 1;
//   //   address_and_wen += 1;
//   // }


//   // printf("\n=====================================================\n\n");


//   // // =============================================================================
//   // // =====                      Test the setup of the DMA                    =====
//   // // =============================================================================

//   printf("\n=====          Test the setup of the DMA        =====\n\n");

//   // Set the bus_start_address and check if the operation was successful
//   uint32_t bus_start_address = 0xff;
//   printf("Bus Start Address\n");
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x3) << 9),[in2]"r"(bus_start_address));
//   printf("- Sent: %d\n", bus_start_address);
//   uint32_t read_bus_start_address;
//   asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_bus_start_address):[in1]"r"((0x2) << 9));
//   printf("- Read: %d\n\n", read_bus_start_address);

//   // Write memory start address, then read it back and compare
//   uint32_t memory_start_address = 0x00000010;
//   printf("Memory Start Address\n");
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x5) << 9),[in2]"r"(memory_start_address));
//   printf("- Sent: %d\n", memory_start_address);
//   uint32_t read_memory_start_address;
//   asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_memory_start_address):[in1]"r"((0x4) << 9));
//   printf("- Read: %d\n\n", read_memory_start_address);

//   // Write block size, then read it back and compare
//   uint32_t block_size = 0x00000005;
//   printf("Block Size\n");
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(block_size));
//   printf("- Sent: %d\n", block_size);
//   uint32_t read_block_size;
//   asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_block_size):[in1]"r"((0x6) << 9));
//   printf("- Read: %d\n\n", read_block_size);

//   // Write burst size, then read it back and compare
//   uint32_t burst_size = 0x00000004;
//   printf("Burst Size\n");
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x9) << 9),[in2]"r"(burst_size));
//   printf("- Sent: %d\n", burst_size);
//   uint32_t read_burst_size;
//   asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_burst_size):[in1]"r"((0x8) << 9));
//   printf("- Read: %d\n\n", read_burst_size);

//   // // Read status register
//   uint32_t read_status_register;
//   // printf("Status Register\n");
//   // asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
//   // printf("- Read: %d\n", read_status_register);

//   printf("\n=====================================================\n\n");


//   // =============================================================================
//   // =====            Test a transfer read from bus to CI-memory             =====
//   // =============================================================================

//   //Create and init the memory array for the transfer
//   uint32_t arraySize = 512;
//   volatile uint32_t memoryArray[512];

//   for (uint32_t i = 0; i < arraySize; i++) {
//     memoryArray[i] = swap_u32(i+1);
//   }

//   printf("\n=====  Test a transfer read from bus to CI-mem  =====\n\n");

//   uint32_t busAddress = (uint32_t) &memoryArray[0];
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x3) << 9),[in2]"r"(busAddress)); 
//   uint32_t memoryAddress = 0x00000002;
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x5) << 9),[in2]"r"(memoryAddress)); 
//   uint32_t blockSize = 0x00000005;
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(blockSize)); 
//   uint32_t burstSize = 0x00000004;
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x9) << 9),[in2]"r"(burstSize)); 

//   printf("1. Single Transfer with BlockSize = BurstSize\n\n");
//   // printf("Config of the transfer\n");
//   // printf("- Memory Start Address: 0x%x\n", memoryAddress);
//   // printf("- Block Size: %d\n", blockSize);
//   // printf("- Burst Size (+1): %d\n", burstSize + 1);
//   // printf("- Nb of transfers: %d\n\n", (uint32_t) (burstSize + blockSize) / (burstSize + 1));

//   printf("Start transfer\n\n");
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0xB) << 9),[in2]"r"(0x00000001));
  
//   // Poll the status register to wait for end of transfer
//   read_status_register = 0x1;
//   while (read_status_register == 1) {
//     asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
//     printf("Read status register %d\n",read_status_register);
//   }
//   printf("\nEnd of transfer!\n");
//   printf("\nCheck the value of the SRAM:\n\n");
  
//   // Read the corresponding values in the CI memory
//   int idx = 0;
//   for (uint32_t reading_memory_address = memoryAddress;reading_memory_address < memoryAddress+blockSize+1;reading_memory_address++) {
//     uint32_t read_value;
//     asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_value):[in1]"r"(reading_memory_address));
//     printf("Value at SRAM memory location 0x%x: 0x%d\n",reading_memory_address,read_value);
//   }

//   printf("\nThe value at 0x%x is provided to show that\nthe transaction ends at the right point\n\n", memoryAddress + blockSize);

//   printf("2. Single Transfer with BlockSize < BurstSize\n\n");
//   memoryAddress = 0x00000010;
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x5) << 9),[in2]"r"(memoryAddress));
//   blockSize = 0x00000003;
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(blockSize));
  
//   printf("Config of the transfer\n");
//   printf("- Memory Start Address: 0x%x\n", memoryAddress);
//   printf("- Block Size: %d\n", blockSize);
//   printf("- Burst Size (+1): %d\n", burstSize + 1);
//   printf("- Nb of transfers: %d\n\n", (uint32_t) (burstSize + blockSize) / (burstSize + 1));

//   printf("Start transfer\n\n");
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0xB) << 9),[in2]"r"(0x00000001));
  
//   // Poll the status register to wait for end of transfer
//   read_status_register = 0x1;
//   while (read_status_register == 1) {
//     asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
//     printf("Read status register %d\n",read_status_register);
//   }
//   printf("\nEnd of transfer!\n");
//   printf("\nCheck the value of the SRAM:\n[Address] Read: [read_value]\n\n");
  
//   // Read the corresponding values in the CI memory
//   for (uint32_t reading_memory_address = memoryAddress;reading_memory_address < memoryAddress+blockSize+1;reading_memory_address++) {
//     uint32_t read_value;
//     asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_value):[in1]"r"(reading_memory_address));
//     printf("Value at SRAM memory location 0x%x: 0x%d\n",reading_memory_address,read_value);
//   }
//   printf("\nThe value at 0x%x is provided to show that\nthe transaction ends at the right point\n\n", memoryAddress + blockSize);

//   printf("3. Multiple Transfers with BlockSize > BurstSize\n\n");
//   memoryAddress = 0x00000020;
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x5) << 9),[in2]"r"(memoryAddress)); // configure memory address
//   blockSize = 0x000000f0;
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(blockSize)); // configure block size
//   // printf("Config of the transfer\n");
//   // printf("- Memory Start Address: 0x%x\n", memoryAddress);
//   // printf("- Block Size: %d\n", blockSize);
//   // printf("- Burst Size (+1): %d\n", burstSize + 1);
//   // printf("- Nb of transfers: %d\n\n", (uint32_t) (burstSize + blockSize) / (burstSize + 1));
//   // // burst size already configured
//   // Start the read transfer (writing value 1 to control register)
//   printf("Start transfer\n\n");
//   asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0xB) << 9),[in2]"r"(0x00000001));
//   // Poll the status register to wait for end of transfer
//   read_status_register = 0x1;
//   while (read_status_register == 0x1) {
//     asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
//     printf("Read status register %d\n",read_status_register);
//   }
//   printf("\nEnd of transfer!\n");
//   printf("\nCheck the value of the SRAM:\n[Address] Expected Value: [expected_value], Read: [read_value]\n\n");
  
//   // Read the corresponding values in the CI memory
//   for (uint32_t reading_memory_address = memoryAddress;reading_memory_address < memoryAddress+blockSize+1;reading_memory_address++) {
//     uint32_t read_value;
//     asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_value):[in1]"r"(reading_memory_address));
//     printf("Value at SRAM memory location 0x%x: 0x%d\n",reading_memory_address,read_value);
//   }
//   printf("\nThe value at 0x%x is provided to show that\nthe transaction ends at the right point\n\n", memoryAddress + blockSize);

//   printf("\n=====================================================\n\n");



//   // =============================================================================
//   // =====            Test a transfer write from CI-memory to Bus            =====
//   // =============================================================================

//   // ===== Single burst with block size = burst size + 1 =====
//   // printf("\n===== Single burst transfer from CI-memory to bus =====\n");
//   // // Configure the transfer (burst size = 4, block size = 5, memory start address = 32, bus start address = element 128 of array)
//   // uint32_t element_to_write_to = 128;
//   // busAddress = (uint32_t) &memoryArray[element_to_write_to];
//   // asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x3) << 9),[in2]"r"(busAddress)); // configure bus address
//   // // memory start address already configured
//   // blockSize = 0x00000005;
//   // asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(blockSize)); // configure block size
//   // // burst size already configured
//   // printf("Status of bus before transfer\n");
//   // for (uint32_t array_element = element_to_write_to;array_element < element_to_write_to+blockSize+1;array_element++) {
//   //   printf("Value at bus location %d: %d\n",array_element,swap_u32(memoryArray[array_element]));
//   // }
//   // // Start the write transfer (writing value 2 to control register)
//   // printf("Start transfer\n");
//   // printf("kjs");
//   // asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0xB) << 9),[in2]"r"(0x00000002));
//   // printf("csk");
//   // // Poll the status register to wait for end of transfer
//   // read_status_register = 0x1;
//   // while (read_status_register == 0x1) {
//   //   asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
//   //   printf("Read status register %d\n",read_status_register);
//   // }
//   // printf("Read status = %d. End of transfer!\n",read_status_register);
//   // printf("Status of bus after transfer\n");
//   // for (uint32_t array_element = element_to_write_to;array_element < element_to_write_to+blockSize+1;array_element++) {
//   //   printf("Value at bus location %d: %d\n",array_element,swap_u32(memoryArray[array_element]));
//   // }

// }



#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>


int main () {
  volatile uint16_t rgb565[640*480];
  volatile uint8_t grayscale[640*480];
  volatile uint32_t result, cycles,stall,idle;
  volatile unsigned int *vga = (unsigned int *) 0X50000020;
  camParameters camParams;
  vga_clear();
  
  printf("Initialising camera (this takes up to 3 seconds)!\n" );
  camParams = initOv7670(VGA);
  printf("Done!\n" );
  printf("NrOfPixels : %d\n", camParams.nrOfPixelsPerLine );
  result = (camParams.nrOfPixelsPerLine <= 320) ? camParams.nrOfPixelsPerLine | 0x80000000 : camParams.nrOfPixelsPerLine;
  vga[0] = swap_u32(result);
  printf("NrOfLines  : %d\n", camParams.nrOfLinesPerImage );
  result =  (camParams.nrOfLinesPerImage <= 240) ? camParams.nrOfLinesPerImage | 0x80000000 : camParams.nrOfLinesPerImage;
  vga[1] = swap_u32(result);
  printf("PCLK (kHz) : %d\n", camParams.pixelClockInkHz );
  printf("FPS        : %d\n", camParams.framesPerSecond );


  // =============================================================================
  // =====           Test the ramDmaCi to read and write to SRAM             =====
  // =============================================================================

  printf("\n===== Writing and reading to CI memory =====\n");
  // First write a value to the SRAM, then read it back and verify it is the same
  uint32_t value_to_test = 0x12345678;
  uint32_t address_and_wen = 0x0000034A;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"(address_and_wen),[in2]"r"(value_to_test));
  address_and_wen = 0x0000014A;
  uint32_t read_value;
  asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_value):[in1]"r"(address_and_wen));
  printf("Sent value %d, read value %d\n",value_to_test,read_value);


  // =============================================================================
  // =====             Test the ramDmaCi to configure the DMA                =====
  // =============================================================================
  
  printf("\n===== Writing and reading DMA configuration =====\n");
  // Write bus start address, then read it back and compare
  uint32_t bus_start_address = 0x11111100;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x3) << 9),[in2]"r"(bus_start_address));
  uint32_t read_bus_start_address;
  asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_bus_start_address):[in1]"r"((0x2) << 9));
  printf("Sent bus start address %d, read bus start address %d\n",bus_start_address,read_bus_start_address);

  // Write memory start address, then read it back and compare
  uint32_t memory_start_address = 0x00000010;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x5) << 9),[in2]"r"(memory_start_address));
  uint32_t read_memory_start_address;
  asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_memory_start_address):[in1]"r"((0x4) << 9));
  printf("Sent memory start address %d, read memory start address %d\n",memory_start_address,read_memory_start_address);

  // Write block size, then read it back and compare
  uint32_t block_size = 0x00000005;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(block_size));
  uint32_t read_block_size;
  asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_block_size):[in1]"r"((0x6) << 9));
  printf("Sent block size %d, read block size %d\n",block_size,read_block_size);

  // Write burst size, then read it back and compare
  uint32_t burst_size = 0x00000004;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x9) << 9),[in2]"r"(burst_size));
  uint32_t read_burst_size;
  asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_burst_size):[in1]"r"((0x8) << 9));
  printf("Sent burst size %d, read burst size %d\n",burst_size,read_burst_size);

  // Read status register
  uint32_t read_status_register;
  asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
  printf("Read status register %d\n",read_status_register);


  // =============================================================================
  // =====             Test a burst read from bus to CI-memory               =====
  // =============================================================================
  
  // Create and initialize the memory array
  uint32_t arraySize = 512;
  volatile uint32_t memoryArray[512];
  for (uint32_t i = 0 ; i < arraySize ; i++) {
    memoryArray[i] = swap_u32(255);
  }

  // ===== Single burst with block size = burst size + 1 =====
  printf("\n===== Single burst transfer from bus to CI-memory =====\n");
  // Configure the transfer (burst size = 4, block size = 5, memory start address = 1, bus start address = first element of array)
  uint32_t busAddress = (uint32_t) &memoryArray[0];
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x3) << 9),[in2]"r"(busAddress)); // configure bus address
  uint32_t memoryAddress = 0x00000001;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x5) << 9),[in2]"r"(memoryAddress)); // configure memory address
  uint32_t blockSize = 0x00000005;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(blockSize)); // configure block size
  uint32_t burstSize = 0x00000004;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x9) << 9),[in2]"r"(burstSize)); // configure burst size
  // Start the read transfer (writing value 1 to control register)
  printf("Start transfer\n");
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0xB) << 9),[in2]"r"(0x00000001));
  // Poll the status register to wait for end of transfer
  read_status_register = 0x1;
  while (read_status_register == 0x1) {
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
    printf("Read status register %d\n",read_status_register);
  }
  printf("Read status = %d. End of transfer!\n",read_status_register);
  // Read the corresponding values in the CI memory
  for (uint32_t reading_memory_address = memoryAddress;reading_memory_address < memoryAddress+blockSize+1;reading_memory_address++) {
    uint32_t read_value;
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_value):[in1]"r"(reading_memory_address));
    printf("Value at SRAM memory location 0x%3x: 0x%8x\n",reading_memory_address,read_value);
  }

  // ===== Single burst with block size (=3) < burst size + 1 (=5) =====
  printf("\n===== Single burst transfer from bus to CI-memory with blocksize < (burstsize + 1) =====\n");
  // Configure the transfer (burst size = 4, block size = 3, memory start address = 16, bus start address = first element of array)
  // bus start address already configured
  memoryAddress = 0x00000010;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x5) << 9),[in2]"r"(memoryAddress)); // configure memory address
  blockSize = 0x00000003;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(blockSize)); // configure block size
  // burst size already configured
  // Start the read transfer (writing value 1 to control register)
  printf("Start transfer\n");
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0xB) << 9),[in2]"r"(0x00000001));
  // Poll the status register to wait for end of transfer
  read_status_register = 0x1;
  while (read_status_register == 0x1) {
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
    printf("Read status register %d\n",read_status_register);
  }
  printf("Read status = %d. End of transfer!\n",read_status_register);
  // Read the corresponding values in the CI memory
  for (uint32_t reading_memory_address = memoryAddress;reading_memory_address < memoryAddress+blockSize+1;reading_memory_address++) {
    uint32_t read_value;
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_value):[in1]"r"(reading_memory_address));
    printf("Value at SRAM memory location 0x%3x: 0x%8x\n",reading_memory_address,read_value);
  }

  // ===== Multiple bursts with block size (=7) > burst size + 1 (=5) =====
  printf("\n===== Multiple burst transfer from bus to CI-memory =====\n");
  // Configure the transfer (burst size = 4, block size = 7, memory start address = 32, bus start address = first element of array)
  // bus start address already configured
  busAddress += 16;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x3) << 9),[in2]"r"(busAddress)); // configure bus address
  memoryAddress = 0x00000020;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x5) << 9),[in2]"r"(memoryAddress)); // configure memory address
  blockSize = 0x00000007;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(blockSize)); // configure block size
  // burst size already configured
  // Start the read transfer (writing value 1 to control register)
  printf("Start transfer\n");
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0xB) << 9),[in2]"r"(0x00000001));
  // Poll the status register to wait for end of transfer
  read_status_register = 0x1;
  while (read_status_register == 0x1) {
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
    printf("Read status register %d\n",read_status_register);
  }
  printf("Read status = %d. End of transfer!\n",read_status_register);
  // Read the corresponding values in the CI memory
  for (uint32_t reading_memory_address = memoryAddress;reading_memory_address < memoryAddress+blockSize+1;reading_memory_address++) {
    uint32_t read_value;
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_value):[in1]"r"(reading_memory_address));
    printf("Value at SRAM memory location 0x%3x: 0x%8x\n",reading_memory_address,read_value);
  }
  asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_memory_start_address):[in1]"r"((0x4) << 9));
  printf("read memory address: %d", read_memory_start_address);


  // =============================================================================
  // =====             Test a burst write from CI-memory to bus              =====
  // =============================================================================
  
  // ===== Single burst with block size = burst size + 1 =====
  printf("\n===== Single burst transfer from CI-memory to bus =====\n");
  // Configure the transfer (burst size = 4, block size = 5, memory start address = 32, bus start address = element 128 of array)
  uint32_t element_to_write_to = 128;
  busAddress = (uint32_t) &memoryArray[element_to_write_to];
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x3) << 9),[in2]"r"(busAddress)); // configure bus address
  // memory start address already configured
  blockSize = 0x00000005;
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0x7) << 9),[in2]"r"(blockSize)); // configure block size
  // burst size already configured
  printf("Status of bus before transfer\n");
  printf("issi\n");
  // for (uint32_t array_element = element_to_write_to;array_element < element_to_write_to+blockSize+1;array_element++) {
  //   printf("Value at bus location %d: %d\n",array_element,swap_u32(memoryArray[array_element]));
  // }
  // Start the write transfer (writing value 2 to control register)
  printf("Start transfer\n");
  asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xD"::[in1]"r"((0xB) << 9),[in2]"r"(0x00000001));
  printf("Start ok!\n");
  // Poll the status register to wait for end of transfer
  read_status_register = 0x1;
  while (read_status_register == 0x1) {
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xD":[out1]"=r"(read_status_register):[in1]"r"((0x0A) << 9));
    printf("Read status register %d\n",read_status_register);
  }
  printf("Read status = %d. End of transfer!\n",read_status_register);
  printf("Status of bus after transfer\n");
  for (uint32_t array_element = element_to_write_to;array_element < element_to_write_to+blockSize+1;array_element++) {
    printf("Value at bus location %d: %d\n",array_element,swap_u32(memoryArray[array_element]));
  }
}
