#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>

/// Define some global constants
const uint32_t writeBit = 1<<9;
const uint32_t busStartAddress = 1 << 10;
const uint32_t memoryStartAddress = 2 << 10;
const uint32_t blockSize = 3 << 10;
const uint32_t burstSize = 4 << 10;
const uint32_t statusControl = 5 << 10;
const uint32_t usedBlocksize = 256;
const uint32_t usedBurstSize = 8;

const uint32_t firstRamPortionAddress = 0;
const uint32_t secondRamPortionAddress = 256;

// =============================================================================
// ==== DMA functions ==========================================================
// =============================================================================

void DMAsetup (uint32_t busAddress, uint32_t memoryAddress, uint32_t blkSize, uint32_t bstSize) {
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(busStartAddress | writeBit),[in2] "r"(busAddress));
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(memoryStartAddress | writeBit),[in2] "r"(memoryAddress));
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(blockSize | writeBit),[in2] "r"(blkSize));
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(burstSize | writeBit),[in2] "r"(bstSize));
} 

void DMAtransferBlocking () {
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(1));
  
  uint32_t status;
  while (1) {
    asm volatile("l.nios_rrr %[out1],%[in1],r0,20":[out1]"=r"(status):[in1]"r"(statusControl));
    if (status == 0) break;
  }

}

void DMAtransferBlocking2Mem () {
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(2));
  
  uint32_t status;
  while (1) {
    asm volatile("l.nios_rrr %[out1],%[in1],r0,20":[out1]"=r"(status):[in1]"r"(statusControl));
    if (status == 0) break;
  }

}

void DMAtransferNonBlocking () {
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(1));
}

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
  uint32_t grayPixels;
  vga[2] = swap_u32(2);
  vga[3] = swap_u32((uint32_t) &grayscale[0]);

  uint32_t firstBlock = 1;


  while(1) {

    uint32_t * rgb = (uint32_t *) &rgb565[0];
    uint32_t * gray = (uint32_t *) &grayscale[0];

    uint32_t busStartAddressVal = (uint32_t) &rgb565[0];
    takeSingleImageBlocking(busStartAddressVal);
    asm volatile ("l.nios_rrr r0,r0,%[in2],0xC"::[in2]"r"(7));
    
    //* Activating the counter 
    asm volatile ("l.nios_rrr r0,r0,%[in2],0xC"::[in2]"r"(15));

    //* Start the DMA transfer
    DMAsetup(busStartAddressVal, firstBlock ? firstRamPortionAddress : secondRamPortionAddress, usedBlocksize, usedBurstSize);
    DMAtransferBlocking();

    // Change the ping-pong buffer
    firstBlock = !firstBlock;

    for (int i = 0; i < 600; i += 1) {
            
      // Start the transfer from rgbVector to CI-memory
      if (i < 599) {
        busStartAddressVal += 4*usedBlocksize;
        DMAsetup(busStartAddressVal, firstBlock ? firstRamPortionAddress : secondRamPortionAddress, usedBlocksize, usedBurstSize);
        DMAtransferNonBlocking();
      }

      firstBlock = !firstBlock;
      uint32_t CIAddress, pixel1, pixel2, status;

      uint32_t writeAddr = firstBlock ? firstRamPortionAddress : secondRamPortionAddress;

      for (int pixel = 0; pixel < usedBlocksize; pixel += 2) {
        CIAddress = firstBlock ? firstRamPortionAddress + pixel : secondRamPortionAddress + pixel;

        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(CIAddress));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(CIAddress+1));

        asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0x9":[out1]"=r"(grayPixels):[in1]"r"(swap_u32(pixel1)),[in2]"r"(swap_u32(pixel2)));

        asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(writeAddr | writeBit), [in2]"r"(swap_u32(grayPixels)));

        writeAddr += 1;
        //gray[0] = grayPixels;
        //gray++;
      }

      while (1) {
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20":[out1]"=r"(status):[in1]"r"(statusControl));
        if (status == 0) break;
      }

      DMAsetup((uint32_t) &gray[0], firstBlock ? firstRamPortionAddress: secondRamPortionAddress, (usedBlocksize >> 1), usedBurstSize >> 1);
      DMAtransferBlocking2Mem();
      gray += (usedBlocksize >> 1);

    }

    //* Without DMA
    // for (int pixel = 0; pixel < ((camParams.nrOfLinesPerImage*camParams.nrOfPixelsPerLine) >> 1); pixel +=2) {
    //   uint32_t pixel1 = rgb[pixel];
    //   uint32_t pixel2 = rgb[pixel+1];
    //   asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0x9":[out1]"=r"(grayPixels):[in1]"r"(pixel1),[in2]"r"(pixel2));
    //   gray[0] = grayPixels;
    //   gray++;
    // }
    
    asm volatile ("l.nios_rrr %[out1],r0,%[in2],0xC":[out1]"=r"(cycles):[in2]"r"(1<<8|7<<4));
    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(stall):[in1]"r"(1),[in2]"r"(1<<9));
    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(idle):[in1]"r"(2),[in2]"r"(1<<10));
    printf("nrOfCycles: %d %d %d\n", cycles, stall, idle);
  }
}
