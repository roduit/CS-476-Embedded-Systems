#include <stdio.h>
#include <stdint.h>
#include <swap.h>

#define CUSTOM_SOBEL

void edgeDetection( volatile uint8_t *grayscale,
                    volatile uint8_t *sobelResult,
                    int32_t width,
                    int32_t height,
                    int32_t threshold ) {

  int32_t result;
  int32_t valueA, valueB = 0;
  int32_t tmp_sobel_result = 0;
  for (int line = 1; line < height - 1; line++) {
    for (int pixel = 1; pixel < width - 1; pixel++) {
      uint16_t image[9];
      int cnt = 0;
      for (int dx = -1; dx < 2; dx++) {
        for (int dy = -1; dy < 2; dy++) {
          uint32_t index = ((line+dx)*width)+dy+pixel;
          image[cnt] = grayscale[index];
          uint32_t gray = grayscale[index];
          cnt += 1;
        }
      }
      tmp_sobel_result = 0;
      valueA = (image[3] << 24) | (image[2] << 16) | (image[1] << 8) | image[0];
      valueB = 1;
      asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
      valueA = (image[7] << 24) | (image[6] << 16) | (image[5] << 8) | image[4];
      valueB = 2 | (image[8] << 8) | (threshold << 16); 
      asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
      sobelResult[line*width+pixel] = tmp_sobel_result > threshold ? 0xff : 0;
    }
  }
}


