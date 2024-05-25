/*
 * sobel.c
 *
 *  Created on: Sep 12, 2015
 *      Author: theo
 */

#include <stdio.h>
#include <stdint.h>
#include <swap.h>

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
  int32_t valueX,valueY, valueD, result;
  int32_t valueA, valueB = 0;
  int32_t tmp_sobel_result = 0;
  for (int line = 1; line < height - 1; line++) {
    for (int pixel = 1; pixel < width - 1; pixel++) {
      // uint8_t image[9] = {grayscale[(line-1)*width+pixel-1], grayscale[(line-1)*width+pixel-1], grayscale[(line-1)*width+pixel-1],
      //                     grayscale[line*width+pixel-1], grayscale[line*width+pixel], grayscale[line*width+pixel+1],
      //                     grayscale[(line+1)*width+pixel-1], grayscale[(line+1)*width+pixel], grayscale[(line+1)*width+pixel+1]};
      uint16_t image[9];
      int cnt = 0;
      valueY = 0;
      valueX = 0;
      for (int dx = -1; dx < 2; dx++) {
        for (int dy = -1; dy < 2; dy++) {
          uint32_t index = ((line+dx)*width)+dy+pixel;
          image[cnt] = grayscale[index];
          uint32_t gray = grayscale[index];
          //printf("pixel%0d = %d;\n", cnt, gray);
          cnt += 1;
          valueX += gray*gx_array[dx+1][dy+1];
          valueY += gray*gy_array[dx+1][dy+1];
        }
      }
      //printf("valueX = %d;\n", valueX);
      //printf("valueY = %d;\n", valueY);
      // printf("valueX: %d, valueY: %d \n", valueX, valueY);
      result = (valueX < 0) ? -valueX : valueX;
      result += (valueY < 0) ? -valueY : valueY;
      //printf("result = %d;\n", result);
      //result = (valueD < 0) ? -valueD : valueD;
      // sobelResult[line*width+pixel] = (result > threshold) ? 0xff : 0;
      // // valueA = 0;
      // // valueB = 0;
      tmp_sobel_result = 0;
      valueA = (image[3] << 24) | (image[2] << 16) | (image[1] << 8) | image[0];
      valueB = 1;
      asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
      valueA = (image[7] << 24) | (image[6] << 16) | (image[5] << 8) | image[4];
      valueB = 2 | (image[8] << 8) | (threshold << 16); 
      //printf("image0 before: %d\n", image[0]);
      asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
      //printf("image0 after: %d\n", tmp_sobel_result);
      //printf("%d\n", tmp_sobel_result); 
      if (result != tmp_sobel_result) {
        printf("Result: %d, Sobel: %d\n\n", result, tmp_sobel_result);
      }
      sobelResult[line*width+pixel] = tmp_sobel_result > threshold ? 0xff : 0;
    }
  }
}


