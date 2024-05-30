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
const uint32_t usedBlocksize = 480; // = cameraWidth / 4 * nb of lines (here 3)
const uint32_t usedBurstSize = 80;

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
            result[i] = swap_u16(RED);
        }
        if (new_image[i+1] > old_image[i+1]) {
            result[i+1] = swap_u16(RED);
        }
    }

}

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

void DMA_startTransferBlocking() {
    asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(1));
    
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
    DMA_setupSize(usedBlocksize, usedBurstSize);

    uint32_t line_index = 0; // Start from the second line
    uint32_t effectiveWidth = cameraWidth / 4; // Each address contains 4 pixels
    uint32_t effectiveHeight = cameraHeight - 2; // writing 3 lines at a time -> STOP 2 lines before the end
    uint8_t pixelStorage[24];
    uint32_t valueA, valueB = 0;
    uint32_t tmp_sobel_result = 0;
    uint32_t col_index = 0;
    uint32_t tmp_line = 0;



    for (line_index; line_index < effectiveHeight; line_index++) {
        // DMA transfer
        DMA_setupAddr(grayscaleAddr + (line_index)*cameraWidth, usedCiRamAddress);
        DMA_startTransferBlocking();

        col_index = 0;
        for (col_index; col_index < effectiveWidth - 1; col_index++) {

            // Read 3 lines and 2 blocks of pixels and store them in pixelStorage
            for (int nbBlocks = 0; nbBlocks < 2; nbBlocks++) {
                asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(tmp_line):[in1] "r"(col_index + nbBlocks));
                pixelStorage[0 + nbBlocks*4] = tmp_line&0xFF;
                pixelStorage[1 + nbBlocks*4] = (tmp_line>>8)&0xFF;
                pixelStorage[2 + nbBlocks*4] = (tmp_line>>16)&0xFF;
                pixelStorage[3 + nbBlocks*4] = (tmp_line>>24)&0xFF;
                asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(tmp_line):[in1] "r"(effectiveWidth + (col_index + nbBlocks)));
                pixelStorage[8 + nbBlocks*4] = tmp_line&0xFF;
                pixelStorage[9 + nbBlocks*4] = (tmp_line>>8)&0xFF;
                pixelStorage[10 + nbBlocks*4] = (tmp_line>>16)&0xFF;
                pixelStorage[11 + nbBlocks*4] = (tmp_line>>24)&0xFF;
                asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(tmp_line):[in1] "r"((2 * effectiveWidth) + (col_index + nbBlocks)));     
                pixelStorage[16 + nbBlocks*4] = tmp_line&0xFF;
                pixelStorage[17 + nbBlocks*4] = (tmp_line>>8)&0xFF;
                pixelStorage[18 + nbBlocks*4] = (tmp_line>>16)&0xFF;
                pixelStorage[19 + nbBlocks*4] = (tmp_line>>24)&0xFF;       
            }

            // Compute the Sobel filter
            for (int numConv = 0; numConv < 4; numConv++) {
                valueA = (pixelStorage[8 + numConv] << 24) | (pixelStorage[2 + numConv] << 16) | (pixelStorage[1 + numConv] << 8) | pixelStorage[0 + numConv];
                valueB = 1;
                asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
                valueA = (pixelStorage[17 + numConv] << 24) | (pixelStorage[16 + numConv] << 16) | (pixelStorage[10 + numConv] << 8) | pixelStorage[9 + numConv];
                valueB = 2 | (pixelStorage[18 + numConv] << 8) | (threshold << 16);
                asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
                sobelImage[(line_index+1)*cameraWidth+(4*col_index+numConv+1)] = tmp_sobel_result > threshold ? 0xFF : 0x00;
            }
        }
    }
}