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
const uint32_t usedBlocksize = 160;
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


    for (line_index; line_index < (cameraHeight); line_index++) {
        // DMA transfer
        DMA_setupAddr(grayscaleAddr + (line_index)*cameraWidth, usedCiRamAddress);
        DMA_startTransferBlocking();

        uint32_t col_index = 0;
        for (col_index; col_index < effectiveWidth - 1; col_index++) {
            uint32_t pixelsRead;
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixelsRead):[in1] "r"(col_index));

            sobelImage[(line_index)*cameraWidth+(4*col_index+1)] = pixelsRead&0xFF;
            sobelImage[(line_index)*cameraWidth+(4*col_index+2)] = (pixelsRead>>8)&0xFF;
            sobelImage[(line_index)*cameraWidth+(4*col_index+3)] = (pixelsRead>>16)&0xFF;
            sobelImage[(line_index)*cameraWidth+(4*col_index+4)] = (pixelsRead>>24)&0xFF;

        }
    }
}

// void compute_sobel_v1(uint32_t grayscaleAddr, volatile uint8_t * sobelImage, uint32_t cameraWidth, uint32_t cameraHeight, uint8_t threshold) {
//     DMA_setupSize(usedBlocksize, usedBurstSize);
//     uint32_t tmp_result;

//     uint32_t images[6];

//     uint32_t pixel0Addr = 700;
//     uint32_t pixelLine;

//     for (int i = 0; i < cameraHeight; i++) {
//         // DMA transfer
//         DMA_setupAddr(grayscaleAddr + (i)*cameraWidth, usedCiRamAddress);
//         DMA_startTransferBlocking();
        
//         // for (int j = 0; j < cameraWidth; j+=4) {
//         for (int memAddr = 0; memAddr < cameraWidth; memAddr++) {
//             // Read pixel from memory
//             // Each address contains 4 pixels
//             // asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(tmp_result):[in1] "r"(memAddr));
//             uint32_t last_val = (memAddr == cameraWidth - 2) ? 1 : 0;

//             for (int k = 0; k < (last_val ? 3 : 6); k++) {
//                 uint32_t index = (k < 3) ? (memAddr + k * (cameraWidth / 4)) : (memAddr + 1 + k * (cameraWidth / 4));
//                 DMA_readCIMem(index, &pixelLine);
//                 DMA_writeCIMem(pixel0Addr + 4*k, pixelLine&0xFF);
//                 DMA_writeCIMem(pixel0Addr + 1 + 4*k, (pixelLine>>8)&0xFF);
//                 DMA_writeCIMem(pixel0Addr + 2 + 4*k, (pixelLine>>16)&0xFF);
//                 DMA_writeCIMem(pixel0Addr + 3 + 4*k, (pixelLine>>24)&0xFF);
//             }
            
//             // // Read 2 images
//             // asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(images[0]):[in1] "r"(memAddr));
//             // asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(images[1]):[in1] "r"(memAddr + cameraWidth / 4));
//             // asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(images[2]):[in1] "r"(memAddr + 2 * cameraWidth / 4));

//             // if (!last_val) {
//             //     asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(images[3]):[in1] "r"(memAddr + 1));
//             //     asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(images[4]):[in1] "r"(memAddr + 1 + cameraWidth / 4));
//             //     asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(images[5]):[in1] "r"(memAddr + 1 + 2* cameraWidth / 4));   
//             // }

//             // for (int k = 0; k < 3; k++) {
//             //     px[0 + k*6] = image_1[k]&0xFF;
//             //     px[1 + k*6] = (image_1[k]>>8)&0xFF;
//             //     px[2 + k*6] = (image_1[k]>>16)&0xFF;
//             //     px[3 + k*6] = (image_1[k]>>24)&0xFF;
//             //     px[4 + k*6] = image_2[k]&0xFF;
//             //     px[5 + k*6] = (image_2[k]>>8)&0xFF;   
//             // }

//             uint32_t valueA, valueB = 0;
//             uint32_t tmp_sobel_result = 0;

//             volatile uint8_t px[24];
            
//             for (int k = 0; k < 23; k++) {
//                 asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(px[k]):[in1] "r"(pixel0Addr)); 
//             }

//             valueA = (px[4] << 24) | (px[2] << 16) | (px[1] << 8) | px[0];
//             valueB = 1;
//             asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
//             valueA = (px[9] << 24) | (px[8] << 16) | (px[6] << 8) | px[5];
//             valueB = 2 | (px[10] << 8) | (threshold << 16);
//             asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
//             sobelImage[(i+1)*cameraWidth+(4*memAddr+1)] = tmp_sobel_result&0xFF;

//             valueA = (px[5] << 24) | (px[3] << 16) | (px[2] << 8) | px[1];
//             valueB = 1;
//             asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
//             valueA = (px[10] << 24) | (px[9] << 16) | (px[7] << 8) | px[6];
//             valueB = 2 | (px[11] << 8) | (threshold << 16);
//             asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
//             sobelImage[(i+1)*cameraWidth+(4*memAddr+2)] = tmp_sobel_result&0xFF;

//             valueA = (px[6] << 24) | (px[12] << 16) | (px[3] << 8) | px[2];
//             valueB = 1;
//             asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
//             valueA = (px[11] << 24) | (px[10] << 16) | (px[16] << 8) | px[7];
//             valueB = 2 | (px[20] << 8) | (threshold << 16);
//             asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
//             sobelImage[(i+1)*cameraWidth+(4*memAddr+3)] = tmp_sobel_result&0xFF;

//             valueA = (px[7] << 24) | (px[13] << 16) | (px[12] << 8) | px[3];
//             valueB = 1;
//             asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
//             valueA = (px[20] << 24) | (px[11] << 16) | (px[7] << 8) | px[16];
//             valueB = 2 | (px[21] << 8) | (threshold << 16);
//             asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
//             sobelImage[(i+1)*cameraWidth+(4*memAddr+4)] = tmp_sobel_result&0xFF;

//             // for (int k = 0; k < (last_val ? 2 : 4); k++) {
//             //     valueA = (image_1[1 + k] << 24) | (((image_1[k]>>16)&0xFF) << 16) | (((image_1[k]>>8)&0xFF) << 8) | image_1[k];
//             //     valueB = 1;
//             //     asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
//             //     valueA = (image_1[13+ k] << 24) | (image_1[2 + k] << 16) | (((image_1[1 + k]>>16)&0xFF) << 8)  | (((image_1[1 + k]>>8)&0xFF));
//             //     valueB = 2 | (image_1[14 + k] << 8) | (threshold << 16); 
//             //     asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
                
//             //     sobelImage[(i+1)*cameraWidth+(4*memAddr+k+1)] = tmp_sobel_result&0xFF;
//             // }

//             //sobelImage[(i+1)*cameraWidth+(memAddr+1)] = tmp_sobel_result&0xFF;

//             // int cnt = 0;
//             // for (int dx = -1; dx < 2; dx++) {
//             //     for (int dy = -1; dy < 2; dy++) {
//             //         uint32_t index = ((i+dx)*cameraWidth)+dy+j;
//             //         asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(image[cnt]):[in1] "r"(index));
//             //         cnt += 1;
//             //     }
//             // }
//             // uint32_t valueA, valueB = 0;
//             // uint32_t tmp_sobel_result = 0;
            
//             // uint8_t px0 = image[0]&0xFF;
//             // uint8_t px1 = (image[0]>>8)&0xFF;
//             // uint8_t px2 = (image[0]>>16)&0xFF;
//             // uint8_t px3 = (image[1])&0xFF;
//             // uint8_t px4 = (image[1]>>8)&0xFF;
//             // uint8_t px5 = (image[1]>>16)&0xFF;
//             // uint8_t px6 = (image[2])&0xFF;
//             // uint8_t px7 = (image[2]>>8)&0xFF;
//             // uint8_t px8 = (image[2]>>16)&0xFF;              

//             // valueA = (px3 << 24) | (px2 << 16) | (px1 << 8) | px0;
//             // valueB = 1;
//             // asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(valueA),[in2]"r"(valueB));
//             // valueA = (px7 << 24) | (px6 << 16) | (px5 << 8) | px4;
//             // valueB = 2 | (px8 << 8) | (threshold << 16); 
//             // asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(valueA),[in2]"r"(valueB));
            
//             // // Send sobel result to memory
//             // sobelImage[(i+1)*cameraWidth+(memAddr+1)] = tmp_sobel_result&0xFF;
//             // if (memAddr == cameraWidth - 2) {
//             //     break;
//             // }
//         }
//     }
// }