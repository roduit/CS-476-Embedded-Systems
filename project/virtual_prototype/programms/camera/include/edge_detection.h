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

#endif /* EDGE_DETECTION_H_ */