/*
 * sobel.c
 *
 *  Created on: Sep 12, 2015
 *      Author: theo
 */

#include <stdio.h>
#include <stdint.h>

void edgeDetection( volatile uint8_t *grayscale,
                    volatile uint8_t *sobelResult,
                    int32_t width,
                    int32_t height,
                    int32_t threshold ) {
  const int32_t gx_array[3][3] = {{-1,0,1},
                                  {-2,0,2},
                                  {-1,0,1}};
  const int32_t gy_array[3][3] = { {1, 2, 1},
                                   {0, 0, 0},
                                   {-1,-2,-1}};
  // const int32_t gd_array[3][3] = { {0, 1, 2},
  //                                  {-1, 0, 1},
  //                                  {-2,-1,0}};
  // int32_t valueX,valueY, valueD, result;
  uint32_t valueA, valueB = 0;
  uint32_t tmp_sobel_result = 0;
  for (int line = 1; line < height - 1; line++) {
    for (int pixel = 1; pixel < width - 1; pixel++) {
      uint8_t image[9] = {grayscale[(line-1)*width+pixel-1], grayscale[(line-1)*width+pixel], grayscale[(line-1)*width+pixel+1],
                          grayscale[line*width+pixel-1], grayscale[line*width+pixel], grayscale[line*width+pixel+1],
                          grayscale[(line+1)*width+pixel-1], grayscale[(line+1)*width+pixel], grayscale[(line+1)*width+pixel+1]};
      // for (int dx = -1; dx < 2; dx++) {
      //   for (int dy = -1; dy < 2; dy++) {
      //     uint32_t index = ((line+dy)*width)+dx+pixel;
      //     int32_t gray = grayscale[index];
      //     valueX += gray*gx_array[dy+1][dx+1];
      //     valueY += gray*gy_array[dy+1][dx+1];
      //   }
      // }
      // result = (valueX < 0) ? -valueX : valueX;
      // result += (valueY < 0) ? -valueY : valueY;
      // //result = (valueD < 0) ? -valueD : valueD;
      // sobelResult[line*width+pixel] = (result > threshold) ? 0xFF : 0;
      valueA = image[3] << 24 | image[2] << 16 | image[1] << 8 | image[0];
      valueB = 0;
      printf("hello there");
      asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
      valueA = image[7] << 24 | image[6] << 16 | image[5] << 8 | image[4];
      valueB = valueB | 0xFF;
      valueB = valueB | image[8] << 8 | threshold << 16; 
      asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
      sobelResult[line*width+pixel] = tmp_sobel_result;
      printf("hello guys");
    }
  }
}


