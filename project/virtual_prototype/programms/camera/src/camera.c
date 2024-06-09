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
#define THRESHOLD 100

volatile uint8_t grayscaleImage[SIZE];
// volatile uint8_t newImageSobel[SIZE] = {0};
// volatile uint8_t oldImageSobel[SIZE] = {0};

#define SOBEL_SIZE ((WIDTH * HEIGHT) / 32)
volatile uint32_t newImageSobel[SOBEL_SIZE] = {0};
volatile uint32_t oldImageSobel[SOBEL_SIZE] = {0};


uint16_t result[SIZE] = {0};

// ================================================================================
// =====                            Main Function                             =====
// ================================================================================

int main() {

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
    printf("SOBEL_SIZE: %d\n", SOBEL_SIZE);

    volatile uint32_t cycles,stall,idle;
    uint32_t counter = 0;

    while (1) {
        asm volatile ("l.nios_rrr r0,r0,%[in2],0xE"::[in2]"r"(7));
        takeSingleImageBlocking((uint32_t)&grayscaleImage[0]);
        compute_sobel_v1((uint32_t)&grayscaleImage[0], (uint32_t *)newImageSobel, camParams.nrOfPixelsPerLine, camParams.nrOfLinesPerImage, THRESHOLD);
        
        // Profile the compare arrays function 8 bits
        // boosted_compare((uint8_t *)newImageSobel, (uint8_t *)oldImageSobel, (uint8_t *)grayscaleImage, (uint16_t *)result, SIZE);
        // memcpy((void*)oldImageSobel, (void*)newImageSobel, SIZE * sizeof(uint8_t));

        // Compare arrays function 32 bits
        boosted_compare((uint32_t *)newImageSobel, (uint32_t *)oldImageSobel, (uint8_t *)grayscaleImage, (uint16_t *)result, SIZE);
        memcpy((void*)oldImageSobel, (void*)newImageSobel, SOBEL_SIZE * sizeof(uint32_t));
        // for (int i = 0; i < SOBEL_SIZE; i++) {
        //     oldImageSobel[i] = newImageSobel[i];
        // }
        
        asm volatile ("l.nios_rrr %[out1],r0,%[in2],0xE":[out1]"=r"(cycles):[in2]"r"(1<<8|7<<4));
        asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xE":[out1]"=r"(stall):[in1]"r"(1),[in2]"r"(1<<9));
        asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xE":[out1]"=r"(idle):[in1]"r"(2),[in2]"r"(1<<10));
        if (counter % 5 == 0) printf("nrOfCycles (cycles, stall, idle): %d %d %d\n", cycles, stall, idle);
        counter++;
    }

    return 0;
}