#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>
#include <floyd_steinberg.h>
#include <sobel.h>
#include <edge_detection.h>

// ================================================================================
// =====                    Camera Parameters and Signals                     =====
// ================================================================================

#define WIDTH 640
#define HEIGHT 480
#define SIZE (WIDTH * HEIGHT)

volatile uint8_t grayscaleImage[SIZE];
volatile uint8_t newImageSobel[SIZE] = {0};
volatile uint8_t oldImageSobel[SIZE] = {0};

uint16_t result[SIZE];

// ================================================================================
// =====                            Main Function                             =====
// ================================================================================

int main() {

    // ========================================
    // =====     DMA Control Signals      =====
    // ========================================

    const uint32_t writeBit = 1<<10;
    const uint32_t busStartAddress = 1 << 11;
    const uint32_t memoryStartAddress = 2 << 11;
    const uint32_t blockSize = 3 << 11;
    const uint32_t burstSize = 4 << 11;
    const uint32_t statusControl = 5 << 11;
    const uint32_t usedCiRamAddress = 50;
    const uint32_t usedBlocksize = 512;
    const uint32_t usedBurstSize = 25;

    // ========================================
    // =====         Screen Init          =====
    // ========================================

    volatile unsigned int *vga = (unsigned int *)0x50000020;
    camParameters camParams;

    vga_clear();

    printf("Initializing camera (this takes up to 3 seconds)!\n");
    camParams = initOv7670(VGA);
    printf("Done!\n");
    printf("NrOfPixels : %d\n", camParams.nrOfPixelsPerLine);
    int reg_result = (camParams.nrOfPixelsPerLine <= 320) ? camParams.nrOfPixelsPerLine | 0x80000000 : camParams.nrOfPixelsPerLine;
    vga[0] = swap_u32(reg_result);
    printf("NrOfLines  : %d\n", camParams.nrOfLinesPerImage);
    reg_result = (camParams.nrOfLinesPerImage <= 240) ? camParams.nrOfLinesPerImage | 0x80000000 : camParams.nrOfLinesPerImage;
    vga[1] = swap_u32(reg_result);
    printf("PCLK (kHz) : %d\n", camParams.pixelClockInkHz);
    printf("FPS        : %d\n", camParams.framesPerSecond);

    // ========================================
    // =====    Sobel Motion Detection    =====
    // ========================================

    vga[2] = swap_u32(1);
    vga[3] = swap_u32((uint32_t)&result[0]);

    while (1) {
        //vga[3] = swap_u32((uint32_t)&grayscaleImage[0]);
        //vga[2] = swap_u32(2);

        asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(10000000), [in2] "r"(1)); // set 5 seconds
        do {
            takeSingleImageBlocking((uint32_t)&grayscaleImage[0]);
            asm volatile("l.nios_rrr %[out1],r0,%[in2],0x6" : [out1] "=r"(reg_result) : [in2] "r"(3));
        } while (reg_result != 0);

        //vga[3] = swap_u32((uint32_t)&newImageSobel[0]);
        //vga[2] = swap_u32(2);

        //asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(5000000), [in2] "r"(1)); // set 5 seconds
        do {
            edgeDetection(grayscaleImage, newImageSobel, camParams.nrOfPixelsPerLine, camParams.nrOfLinesPerImage, 100);
            asm volatile("l.nios_rrr %[out1],r0,%[in2],0x6" : [out1] "=r"(reg_result) : [in2] "r"(3));
        } while (reg_result != 0);

        // asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(5000000), [in2] "r"(1)); // set 5 seconds
        // for (int i = 0; i < SIZE; i++) {
        //   result[i] = 0;
        // }
        
        // vga[2] = swap_u32(1);
        // vga[3] = swap_u32((uint32_t)&result[0]);
        //delay(1000);
        asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(5000000), [in2] "r"(1)); // set 5 seconds
        compare_arrays((uint8_t *) newImageSobel, (uint8_t *) oldImageSobel, (uint8_t *) grayscaleImage, (uint16_t *)result, SIZE);
        //memcpy(oldImageSobel, newImageSobel, SIZE);

        for (int i = 0; i < SIZE; i++) {
            oldImageSobel[i] = newImageSobel[i];
        }
        
        delay(1000);
    }
    return 0;
}
