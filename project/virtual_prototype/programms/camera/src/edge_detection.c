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

const uint32_t writeBit = 1<<10;
const uint32_t busStartAddress = 1 << 11;
const uint32_t memoryStartAddress = 2 << 11;
const uint32_t blockSize = 3 << 11;
const uint32_t burstSize = 4 << 11;
const uint32_t statusControl = 5 << 11;
const uint32_t usedCiRamAddress = 0;
const uint32_t usedBlocksize = 480;
const uint32_t usedBurstSize = 25;

// ================================================================================
// =====                           Delay Generator                            =====
// ================================================================================

void delay(uint32_t milliseconds) {
    // Assuming 1 cycle takes 1 microsecond
    volatile uint32_t cycles_per_millisecond = 1000; // Adjust this value based on your CPU frequency
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
            result[i] = swap_u16(LIME);
        }
        if (new_image[i+1] > old_image[i+1]) {
            result[i+1] = swap_u16(LIME);
        }
    }

}

void DMA_setupSize(uint32_t blockSizesas, uint32_t burstSizesas) {
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(blockSize | writeBit),[in2] "r"(blockSizesas));
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(burstSize | writeBit),[in2] "r"(burstSizesas));
}

void DMA_setupAddr(uint32_t busAddr, uint32_t CImemAddr) {
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(busStartAddress | writeBit),[in2] "r"(busAddr));
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(memoryStartAddress | writeBit),[in2] "r"(CImemAddr));
}

void DMA_startTransferBlocking() {
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(1));
    
    uint32_t status;
    while (1) {
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20":[out1]"=r"(status):[in1]"r"(statusControl));
        if (status == 0) break;
    }
}

// ================================================================================
// =====                            Edge Detection                            =====
// ================================================================================

void compute_sobel_v1(uint32_t grayscaleAddr, volatile uint8_t * sobelImage, uint32_t cameraWidth, uint32_t cameraHeight, uint8_t threshold) {
    DMA_setupSize(usedBlocksize, usedBurstSize);
    uint32_t tmp_result;

    for (int i = 0; i < cameraHeight; i++) {
        // DMA transfer
        DMA_setupAddr(grayscaleAddr + (i)*cameraWidth, usedCiRamAddress);
        DMA_startTransferBlocking();
        
        // for (int j = 0; j < cameraWidth; j+=4) {
        for (int memAddr = 0; memAddr < cameraWidth; memAddr++) {
            // Read pixel from memory
            // Each address contains 4 pixels
            // asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(tmp_result):[in1] "r"(memAddr));

            uint32_t image[3];
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(image[0]):[in1] "r"(memAddr));
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(image[1]):[in1] "r"(memAddr + cameraWidth / 4));
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(image[2]):[in1] "r"(memAddr + 2 * cameraWidth / 4));


            // int cnt = 0;
            // for (int dx = -1; dx < 2; dx++) {
            //     for (int dy = -1; dy < 2; dy++) {
            //         uint32_t index = ((i+dx)*cameraWidth)+dy+j;
            //         asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(image[cnt]):[in1] "r"(index));
            //         cnt += 1;
            //     }
            // }
            uint32_t valueA, valueB = 0;
            uint32_t tmp_sobel_result = 0;
            
            uint8_t px0 = image[0]&0xFF;
            uint8_t px1 = (image[0]>>8)&0xFF;
            uint8_t px2 = (image[0]>>16)&0xFF;
            uint8_t px3 = (image[1])&0xFF;
            uint8_t px4 = (image[1]>>8)&0xFF;
            uint8_t px5 = (image[1]>>16)&0xFF;
            uint8_t px6 = (image[2])&0xFF;
            uint8_t px7 = (image[2]>>8)&0xFF;
            uint8_t px8 = (image[2]>>16)&0xFF;              

            valueA = (px3 << 24) | (px2 << 16) | (px1 << 8) | px0;
            valueB = 1;
            asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
            valueA = (px7 << 24) | (px6 << 16) | (px5 << 8) | px4;
            valueB = 2 | (px8 << 8) | (threshold << 16); 
            asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
            
            // Send sobel result to memory
            sobelImage[(i+1)*cameraWidth+(memAddr+1)] = tmp_sobel_result&0xFF;
            if (memAddr == cameraWidth - 2) {
                break;
            }
        }
        if (i == cameraHeight - 2) {
            break;
        }
        
        // write back
    }
}