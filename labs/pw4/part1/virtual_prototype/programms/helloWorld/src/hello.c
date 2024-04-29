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
  
  // Write
  uint32_t value_to_test = 0x123;
  uint32_t address_and_wen = 0x00000208;

  for (int i = 0; i < 5; i++) {
    asm volatile ("l.nios_rrr r0,%[in1],%[in2],0x12"::[in1]"r"(address_and_wen),[in2]"r"(value_to_test));
    printf("Write %d at address %d\n", value_to_test, address_and_wen - 512);
    value_to_test += 1;
    address_and_wen += 1;
  }

  // Read
  address_and_wen = 0x00000008;
  value_to_test = 0x123;
  uint32_t read_value;

  for (int i = 0; i < 5; i++) {
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,0x12":[out1]"=r"(read_value):[in1]"r"(address_and_wen));
    printf("Read value %d at address %d\n", read_value, address_and_wen);
    value_to_test += 1;
    address_and_wen += 1;
  }
}