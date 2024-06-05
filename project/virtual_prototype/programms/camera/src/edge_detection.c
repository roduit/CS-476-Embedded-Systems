#include <stdio.h>
#include <stdint.h>
#include <swap.h>

// ================================================================================
// =====                          Color Definitions                           =====
// ================================================================================

#define BLACK       0x0000
#define WHITE       0xFFFF
#define RED         0xF800
#define LIME        0x07E0
#define BLUE        0x001F
#define YELLOW      0xFFE0
#define CYAN        0x07FF
#define MAGENTA     0xF81F
#define SILVER      0xC618
#define GRAY        0x8410
#define MAROON      0x8000
#define OLIVE       0x8400
#define GREEN       0x0400
#define PURPLE      0x8010
#define TEAL        0x0410
#define NAVY        0x0010
#define ORANGE      0xFD20
#define PINK        0xF81F

// ================================================================================
// =====                         DMA Control Signals                          =====
// ================================================================================

const uint32_t writeBit = 1 << 10;
const uint32_t busStartAddress = 1 << 11;
const uint32_t memoryStartAddress = 2 << 11;
const uint32_t blockSize = 3 << 11;
const uint32_t burstSize = 4 << 11;
const uint32_t statusControl = 5 << 11;
const uint32_t usedCiRamAddress = 0;
const uint32_t usedBlocksize = 480; // = cameraWidth / 4 * nb of lines (here 3)
const uint32_t usedBurstSize = 40;

const uint32_t startSobelBufferAddr = 640;
const uint32_t sobelBufferSize = 160;
const uint32_t reverse = 1 << 16;
const uint32_t startEdgeDetection = 1 << 17;
const uint32_t lineBlockSize = 160;

// ================================================================================
// =====                           Delay Generator                            =====
// ================================================================================

void delay(uint32_t milliseconds) {
    // Assuming 1 cycle takes 1 microsecond
    volatile uint32_t cycles_per_millisecond = 1000;
    volatile uint32_t total_cycles = milliseconds * cycles_per_millisecond;

    for (volatile uint32_t i = 0; i < total_cycles; i++) {
        // Waste CPU cycles
    }
}

// ================================================================================
// =====                          Compare the Arrays                          =====
// ================================================================================

void compare_arrays(uint8_t *new_image, uint8_t *old_image, uint8_t *grayscale, uint16_t *result, int size) {
    uint32_t tmp_result;
    uint32_t valueA, valueB = 0;
    for (int i = 0; i < size; i = i + 2) {
        valueA = (grayscale[i+1] << 8) | grayscale[i];
        asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xD":[out1]"=r"(tmp_result):[in1]"r"(valueA),[in2]"r"(valueB));
        result[i] = swap_u16(tmp_result & 0xFFFF);
        result[i+1] = swap_u16((tmp_result >> 16) & 0xFFFF);
        if (new_image[i] > old_image[i]) {
            result[i] = swap_u16(RED);
        }
        if (new_image[i+1] > old_image[i+1]) {
            result[i+1] = swap_u16(RED);
        }
    }
}

void boosted_compare(uint8_t *new_image, uint8_t *old_image, uint8_t *grayscale, uint16_t *result, int size) {
    uint8_t mask;
    uint32_t tmp_result;
    uint32_t valueA, valueB = 0;
    int idx = 0;
    
    for (int i = 0; i < size; i += 2) {
        if (i % 4 == 0) {
            mask = (new_image[idx] ^ old_image[idx]) & new_image[idx];
            idx += 4;
        }
        valueA = (grayscale[i+1] << 8) | grayscale[i];
        
        // Assembly instruction is architecture-specific and may need to be adjusted
        asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xD" : [out1] "=r" (tmp_result) : [in1] "r" (valueA), [in2] "r" (valueB));
        
        result[i] = swap_u16(tmp_result & 0xFFFF);
        result[i+1] = swap_u16((tmp_result >> 16) & 0xFFFF);
        
        if (mask & (1 << (i % 4))) {
            result[i] = swap_u16(RED);
        }
        if (mask & (1 << ((i + 1) % 4))) {
            result[i+1] = swap_u16(RED);
        }
    }
}

// void boosted_compare(uint32_t *new_image, uint32_t *old_image, uint8_t *grayscale, uint16_t *result, int size) {
//     uint32_t mask;
//     uint32_t tmp_result;
//     uint32_t valueA, valueB = 0;
//     int idx = 0;
//     for (int i = 0; i < size; i = i + 2) {
//         if (i % 32 == 0) {
//             mask = (new_image[idx] ^ old_image[idx]) & new_image[idx];
//             idx++;
//         }
//         valueA = (grayscale[i+1] << 8) | grayscale[i];
//         asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xD":[out1]"=r"(tmp_result):[in1]"r"(valueA),[in2]"r"(valueB));
//         result[i] = swap_u16(tmp_result & 0xFFFF);
//         result[i+1] = swap_u16((tmp_result >> 16) & 0xFFFF);
//         if (mask & (1 << (i % 32))) {
//             result[i] = swap_u16(RED);
//         } 
//         if (mask & (1 << ((i + 1) % 32))) {
//             result[i+1] = swap_u16(RED);
//         }
//     }
// }

// ================================================================================
// =====                            DMA Functions                             =====
// ================================================================================

void DMA_setupSize(uint32_t blockSizesas, uint32_t burstSizesas) {
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(blockSize | writeBit),[in2] "r"(blockSizesas));
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(burstSize | writeBit),[in2] "r"(burstSizesas));
}

void DMA_setupAddr(uint32_t busAddr, uint32_t CImemAddr) {
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(busStartAddress | writeBit),[in2] "r"(busAddr));
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(memoryStartAddress | writeBit),[in2] "r"(CImemAddr));
}

void DMA_startTransferBlocking(uint32_t rw) {
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(rw));
    
    uint32_t status;
    while (1) {
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20":[out1]"=r"(status):[in1]"r"(statusControl));
        if (status == 0) break;
    }
}

void DMA_writeCIMem(uint32_t memAddress, uint32_t data) {
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(memAddress | writeBit), [in2]"r"(data));   
}

void DMA_readCIMem(uint32_t memAddress, uint32_t *data) {
    asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(*data):[in1] "r"(memAddress)); 
}

// ================================================================================
// =====                            Edge Detection                            =====
// ================================================================================

void compute_sobel_v1(uint32_t grayscaleAddr, volatile uint8_t * sobelImage, uint32_t cameraWidth, uint32_t cameraHeight, uint8_t threshold) {
    uint32_t line_index = 0;                        // Start from the second line
    uint32_t effectiveWidth = cameraWidth / 4;      // Each address contains 4 pixels
    uint32_t effectiveHeight = cameraHeight - 2;    // writing 3 lines at a time -> STOP 2 lines before the end
    
    uint32_t valueA, valueB = 0;
    uint32_t tmp_sobel_result = 0;
    uint32_t col_index = 0;
    uint32_t tmp_line = 0;

    uint32_t startLine = 2;
    uint32_t startIdx = 0;

    uint32_t readAddr = 0;
    uint32_t cnt = 0;

    // Set the threshold
    asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"((threshold)),[in2]"r"((6)));



    for (line_index; line_index < effectiveHeight; line_index++) {
        // DMA transfer
        
        if (line_index < cameraHeight - 3) {
            DMA_setupSize(line_index == 0 ? usedBlocksize : lineBlockSize, usedBurstSize);
            readAddr = line_index == 0 ? grayscaleAddr : (grayscaleAddr + (line_index + 2)*cameraWidth);
            DMA_setupAddr(readAddr, line_index == 0 ? 0 : (startLine * effectiveWidth));
            DMA_startTransferBlocking(1);
        }

        for (col_index = 0; col_index < effectiveWidth; col_index++) {

            // First case, we need to charge both images
            if (col_index == 0) {
                valueB = 0;
                for (int nbLines = 0; nbLines < 3; nbLines++) {
                    startIdx = ((line_index + nbLines) % 4) * effectiveWidth;
                    asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(tmp_line):[in1] "r"(col_index + startIdx));
                    asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"((tmp_line)),[in2]"r"((valueB)));
                    valueB++;
                    if (valueB == 5) {
                        valueB = 5 | startEdgeDetection;
                    }

                    asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(tmp_line):[in1] "r"(col_index + 1 + startIdx));
                    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"((tmp_line)),[in2]"r"((valueB)));
                    valueB++;
                }
            }
            // General case
            else {
                valueB = (col_index % 2 == 0) ? 1 : reverse;

                for (int nbLines = 0; nbLines < 3; nbLines++) {
                    startIdx = ((line_index + nbLines) % 4) * effectiveWidth;
                    asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(tmp_line):[in1] "r"(col_index + startIdx));
                    if (nbLines == 2) {
                        valueB += 1 << 17;
                    }
                    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"((tmp_line)),[in2]"r"((valueB)));
                    valueB += 2;
                    //printf("sobel result: %0x\n", tmp_sobel_result);
                }

            }

            // if ((col_index + 1) % 2 == 0) {
            //     DMA_writeCIMem(startSobelBufferAddr + cnt, tmp_sobel_result);
            //     cnt++;
            // }
            DMA_writeCIMem(startSobelBufferAddr + col_index, tmp_sobel_result&0xFF);

        }

        // Update the start line
        startLine = (startLine + 1) % 4;

        // Send sobelStorage to the VGA
        DMA_setupSize(sobelBufferSize, usedBurstSize);
        DMA_setupAddr((uint32_t)& sobelImage[0] + (line_index + 1)*(cameraWidth) + 1, startSobelBufferAddr);
        DMA_startTransferBlocking(2);
    }
    //printf("cnt: %0d\n", cnt);
}