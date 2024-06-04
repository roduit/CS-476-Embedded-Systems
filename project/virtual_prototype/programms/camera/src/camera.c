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
volatile uint8_t newImageSobel[SIZE] = {0};
volatile uint8_t oldImageSobel[SIZE] = {0};

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

    vga[2] = swap_u32(2);
    vga[3] = swap_u32((uint32_t)&newImageSobel[0]);

    // while (1) {
    //     takeSingleImageBlocking((uint32_t)&grayscaleImage[0]);
    //     compute_sobel_v1((uint32_t)&grayscaleImage[0], (uint8_t *)newImageSobel, camParams.nrOfPixelsPerLine, camParams.nrOfLinesPerImage, THRESHOLD);
    //     // compare_arrays((uint8_t *)newImageSobel, (uint8_t *)oldImageSobel, (uint8_t *) grayscaleImage,  (uint16_t *)result, SIZE);
    //     // memcpy((void*)oldImageSobel, (void*)newImageSobel, SIZE * sizeof(uint8_t));
    // }

    uint32_t tmplines[3][2];
    uint32_t tmp_sobel_result = 0;
    uint32_t threshold = THRESHOLD;

    tmplines[0][0] = 0x8c652f85;
    tmplines[0][1] = 0x9c6440bb;
    tmplines[1][0] = 0xfa4391b4;
    tmplines[1][1] = 0xd916909e;
    tmplines[2][0] = 0x4285b377;
    tmplines[2][1] = 0x6e848536;

    printf("\n");

    uint32_t valueB = 0;
    for (int nbLines = 0; nbLines < 3; nbLines++) {
        asm volatile ("l.nios_rrr r0,%[in1],%[in2],0xC"::[in1]"r"(tmplines[nbLines][0]),[in2]"r"((valueB)));
        printf("line %0d: %3d, %3d, %3d, %3d\n", nbLines*2 + 1, tmplines[nbLines][0]&0xFF, (tmplines[nbLines][0] >> 8) & 0xFF, (tmplines[nbLines][0] >> 16) & 0xFF, (tmplines[nbLines][0] >> 24) & 0xFF);
        valueB++;

        if (valueB == 5) {
            valueB = 5 | (threshold << 8);
        }
        asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(tmplines[nbLines][1]),[in2]"r"((valueB)));
        printf("line %0d: %3d, %3d, %3d, %3d\n", nbLines*2 + 2, tmplines[nbLines][1]&0xFF, (tmplines[nbLines][1] >> 8) & 0xFF, (tmplines[nbLines][1] >> 16) & 0xFF, (tmplines[nbLines][1] >> 24) & 0xFF);
        valueB++;
    }
    // print the result in hex
    printf("\n");
    printf("tmp_sobel_result conv 1: %3d\n", tmp_sobel_result & 0xFF);
    printf("tmp_sobel_result conv 2: %3d\n", (tmp_sobel_result >> 8) & 0xFF);
    printf("tmp_sobel_result conv 3: %3d\n", (tmp_sobel_result >> 16) & 0xFF);
    printf("tmp_sobel_result conv 4: %3d\n", (tmp_sobel_result >> 24) & 0xFF);

    printf("\n");
    tmplines[0][0] = 0xaa652f85;
    tmplines[0][1] = 0x4285b377;
    tmplines[1][0] = 0xe13dd277;
    tmplines[1][1] = 0xdddaaaff;
    tmplines[2][0] = 0x1313223a;
    tmplines[2][1] = 0x983489ab;

    valueB = 1 << 16;
    for (int nbLines = 0; nbLines < 3; nbLines++) {
        asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(tmplines[nbLines][0]),[in2]"r"((valueB)));
        printf("line %0d: %3d, %3d, %3d, %3d\n", nbLines*2 + 1, tmplines[nbLines][1]&0xFF, (tmplines[nbLines][0] >> 8) & 0xFF, (tmplines[nbLines][1] >> 16) & 0xFF, (tmplines[nbLines][1] >> 24) & 0xFF);
        valueB += 2;
            printf("\n");
    printf("tmp_sobel_result conv 1: %3d\n", tmp_sobel_result & 0xFF);
    printf("tmp_sobel_result conv 2: %3d\n", (tmp_sobel_result >> 8) & 0xFF);
    printf("tmp_sobel_result conv 3: %3d\n", (tmp_sobel_result >> 16) & 0xFF);
    printf("tmp_sobel_result conv 4: %3d\n", (tmp_sobel_result >> 24) & 0xFF);
    }
    // print the result in hex
    // printf("\n");
    // printf("tmp_sobel_result conv 1: %3d\n", tmp_sobel_result & 0xFF);
    // printf("tmp_sobel_result conv 2: %3d\n", (tmp_sobel_result >> 8) & 0xFF);
    // printf("tmp_sobel_result conv 3: %3d\n", (tmp_sobel_result >> 16) & 0xFF);
    // printf("tmp_sobel_result conv 4: %3d\n", (tmp_sobel_result >> 24) & 0xFF);

    valueB = 0;
    for (int nbLines = 0; nbLines < 3; nbLines++) {
        asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(tmp_sobel_result):[in1]"r"(tmplines[nbLines][1]),[in2]"r"((valueB)));
        printf("line %0d: %3d, %3d, %3d, %3d\n", nbLines*2 + 2, tmplines[nbLines][1]&0xFF, (tmplines[nbLines][1] >> 8) & 0xFF, (tmplines[nbLines][1] >> 16) & 0xFF, (tmplines[nbLines][1] >> 24) & 0xFF);
        valueB += 2;
    }
    // print the result in hex
    printf("\n");
    printf("tmp_sobel_result conv 1: %3d\n", tmp_sobel_result & 0xFF);
    printf("tmp_sobel_result conv 2: %3d\n", (tmp_sobel_result >> 8) & 0xFF);
    printf("tmp_sobel_result conv 3: %3d\n", (tmp_sobel_result >> 16) & 0xFF);
    printf("tmp_sobel_result conv 4: %3d\n", (tmp_sobel_result >> 24) & 0xFF);

    return 0;
}