#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>
#include <floyd_steinberg.h>
#include <sobel.h>

volatile uint8_t rgb565[640*480];
volatile uint8_t grayscale[640*480];
volatile uint8_t floyd[640*480];
volatile int16_t error_array[642<<1];

int main () {
  volatile int result;
  volatile unsigned int *vga = (unsigned int *) 0X50000020;
  int reg;
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
  while(1) {
  
    vga[2] = swap_u32(2);
    vga[3] = swap_u32((uint32_t) &rgb565[0]);
    asm volatile ("l.nios_rrr r0,%[in1],%[in2],0x6"::[in1]"r"(5000000),[in2]"r"(1)); // set 5 seconds
    do {
      takeSingleImageBlocking((uint32_t) &rgb565[0]);
      asm volatile ("l.nios_rrr %[out1],r0,%[in2],0x6":[out1]"=r"(result):[in2]"r"(3));
    } while (result != 0);
    vga[2] = swap_u32(2);
    vga[3] = swap_u32((uint32_t) &floyd[0]);
    asm volatile ("l.nios_rrr r0,%[in1],%[in2],0x6"::[in1]"r"(5000000),[in2]"r"(1)); // set 5 seconds
    do {
      takeSingleImageBlocking((uint32_t) &rgb565[0]);
    
      floyd_steinberg(rgb565, camParams.nrOfPixelsPerLine, camParams.nrOfLinesPerImage, floyd, error_array);
      asm volatile ("l.nios_rrr %[out1],r0,%[in2],0x6":[out1]"=r"(result):[in2]"r"(3));
    } while (result != 0);
    asm volatile ("l.nios_rrr r0,%[in1],%[in2],0x6"::[in1]"r"(5000000),[in2]"r"(1)); // set 5 seconds
    do {
      takeSingleImageBlocking((uint32_t) &rgb565[0]);
      edgeDetection(rgb565,floyd, camParams.nrOfPixelsPerLine, camParams.nrOfLinesPerImage,128);
      asm volatile ("l.nios_rrr %[out1],r0,%[in2],0x6":[out1]"=r"(result):[in2]"r"(3));
    } while (result != 0);
  }
}

