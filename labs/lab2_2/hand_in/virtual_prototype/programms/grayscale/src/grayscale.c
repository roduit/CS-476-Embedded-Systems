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

  int custom_en = 0; // Put this variable to 1 to use custom

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
  uint32_t * rgb = (uint32_t *) &rgb565[0];
  uint32_t grayPixels;
  vga[2] = swap_u32(2);
  vga[3] = swap_u32((uint32_t) &grayscale[0]);

  uint32_t control;
  uint32_t counterid;
  
  // reset the counters
  control = 1<<8;
  asm volatile ("l.nios_rrr r0,r0,%[in2],0xB"::[in2]"r"(control));
  control = 1<<9;
  asm volatile ("l.nios_rrr r0,r0,%[in2],0xB"::[in2]"r"(control));
  control = 1<<10;
  asm volatile ("l.nios_rrr r0,r0,%[in2],0xB"::[in2]"r"(control));
  
  while(1) {
    printf("\n\n");
    control = 7;
    asm volatile ("l.nios_rrr r0,r0,%[in2],0xB"::[in2]"r"(control));
    
    uint32_t * gray = (uint32_t *) &grayscale[0];
    takeSingleImageBlocking((uint32_t) &rgb565[0]);
    for (int line = 0; line < camParams.nrOfLinesPerImage; line++) {
      for (int pixel = 0; pixel < camParams.nrOfPixelsPerLine; pixel++) {
        uint32_t gray;
        uint16_t rgb = swap_u16(rgb565[line*camParams.nrOfPixelsPerLine+pixel]);
        if (custom_en) {
          asm volatile ("l.nios_rrr %[out1],%[in1],r0,0x3":[out1]"=r"(gray):[in1]"r"(rgb));
        }
        else{
          uint32_t red1 = ((rgb >> 11) & 0x1F) << 3;
          uint32_t green1 = ((rgb >> 5) & 0x3F) << 2;
          uint32_t blue1 = (rgb & 0x1F) << 3;
          gray = ((red1*54+green1*183+blue1*19) >> 8)&0xFF;
        }
        grayscale[line*camParams.nrOfPixelsPerLine+pixel] = gray;
      }
    }

    control = 7<<4;
    asm volatile ("l.nios_rrr r0,r0,%[in2],0xB"::[in2]"r"(control));

    // reading the number of cycles
    counterid = 0;
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xB":[out1]"=r"(result):[in1]"r"(counterid));
    printf("Cycles CPU:   %d\n", result);

    // reading the number of stalls
    counterid = 1;
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xB":[out1]"=r"(result):[in1]"r"(counterid));
    printf("Cycles Stall: %d\n", result);

    // reading the number of idle cycles
    counterid = 2;
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0xB":[out1]"=r"(result):[in1]"r"(counterid));
    printf("Cycles Idle:  %d\n", result);

    // reset the counters
    control = 1<<8;
    asm volatile ("l.nios_rrr r0,r0,%[in2],0xB"::[in2]"r"(control));
    control = 1<<9;
    asm volatile ("l.nios_rrr r0,r0,%[in2],0xB"::[in2]"r"(control));
    control = 1<<10;
    asm volatile ("l.nios_rrr r0,r0,%[in2],0xB"::[in2]"r"(control));

  }
}