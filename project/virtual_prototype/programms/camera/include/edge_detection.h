/*
*  edge_detection.h
* 
*  Created on: 28 May 2024
*  Authors: Filippo Quadri, Vincent Roduit
*
*/

#ifndef EDGE_DETECTION_H_
#define EDGE_DETECTION_H_

void delay(uint32_t milliseconds);
void compare_arrays(uint8_t *new_image, uint8_t *old_image, uint8_t *grayscale, uint16_t *result, int size);
void boosted_compare(uint8_t *new_image, uint8_t *old_image, uint8_t *grayscale, uint16_t *result, int size);

void DMA_setupSize(uint32_t blockSizesas, uint32_t burstSizesas);
void DMA_setupAddr(uint32_t busAddr, uint32_t CImemAddr);
void DMA_startTransferBlocking(uint32_t rw);
void DMA_writeCIMem(uint32_t memAddress, uint32_t data);
void DMA_readCIMem(uint32_t memAddress, uint32_t *data);

void compute_sobel_v1(uint32_t grayscaleAddr, volatile uint8_t * sobelImage, uint32_t cameraWidth, uint32_t cameraHeight, uint8_t threshold);

#endif /* EDGE_DETECTION_H_ */