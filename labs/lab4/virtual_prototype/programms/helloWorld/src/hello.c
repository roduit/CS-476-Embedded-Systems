#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>

int main () {
  vga_clear();
  printf("Hello guys, welcome to my new channel !\n" );
  volatile uint32_t memoryArray[16];

  printf("Initialising memory array!\n" );
  for (int i = 0; i < 16; i++) {
    memoryArray[i] = i;
  }
  printf("Reading from the memory array!\n" );
  for (int i = 0; i < 16; i++) {
    printf("MemoryArray[%d] = %d\n", i, memoryArray[i]);
  }

  printf("Now test it with the DMA controller!\n" );
}
