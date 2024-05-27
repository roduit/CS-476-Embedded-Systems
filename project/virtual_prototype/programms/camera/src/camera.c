#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>
#include <floyd_steinberg.h>
#include <sobel.h>

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

#define WIDTH 640
#define HEIGHT 480
#define SIZE (WIDTH * HEIGHT)

volatile uint8_t rgb565[SIZE];
volatile uint8_t grayscale[SIZE];
volatile uint8_t floyd[SIZE] = {0};
volatile uint8_t floyd2[SIZE] = {0};
volatile int16_t error_array[642 << 1];

void delay(uint32_t milliseconds) {
    // Assuming 1 cycle takes 1 microsecond
    volatile uint32_t cycles_per_millisecond = 1000; // Adjust this value based on your CPU frequency
    volatile uint32_t total_cycles = milliseconds * cycles_per_millisecond;

    for (volatile uint32_t i = 0; i < total_cycles; i++) {
        // Waste CPU cycles
    }
}

uint16_t grayscaleToRGB565(uint8_t grayscale) {
    // Scale the 8-bit grayscale value to the 5-bit red, 6-bit green, and 5-bit blue components
    uint8_t red = (grayscale >> 3) & 0x1F;      // 5 bits for red
    uint8_t green = (grayscale >> 2) & 0x3F;    // 6 bits for green
    uint8_t blue = (grayscale >> 3) & 0x1F;     // 5 bits for blue

    // Combine the components into a single 16-bit RGB565 value
    uint16_t rgb565 = (red << 11) | (green << 5) | blue;
    

    return rgb565;
}



void compare_arrays(uint8_t *new_image, uint8_t *old_image, uint8_t *grayscale, uint16_t *result, int size) {
    for (int i = 0; i < size; i++) {
        result[i] = swap_u16(grayscaleToRGB565(grayscale[i]));
        if (new_image[i] > old_image[i]) {
            result[i] = swap_u16(RED);
        }
    //   else {
    //     if (new_image[i] == 0) {
    //         result[i] = swap_u16(BLACK);
    //         }
    //         else {
    //         result[i] = swap_u16(WHITE);
            
    //     }
    //   }
    }

}

int main() {
    volatile unsigned int *vga = (unsigned int *)0x50000020;
    int size = SIZE;
    camParameters camParams;
    uint16_t result[SIZE];

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

    while (1) {
        vga[2] = swap_u32(2);
        vga[3] = swap_u32((uint32_t)&rgb565[0]);
        asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(5000000), [in2] "r"(1)); // set 5 seconds
        do {
            takeSingleImageBlocking((uint32_t)&rgb565[0]);
            asm volatile("l.nios_rrr %[out1],r0,%[in2],0x6" : [out1] "=r"(reg_result) : [in2] "r"(3));
        } while (reg_result != 0);

        vga[2] = swap_u32(2);
        vga[3] = swap_u32((uint32_t)&floyd[0]);
        // asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(5000000), [in2] "r"(1)); // set 5 seconds
        // do {
        //     floyd_steinberg(rgb565, camParams.nrOfPixelsPerLine, camParams.nrOfLinesPerImage, floyd, error_array);
        //     asm volatile("l.nios_rrr %[out1],r0,%[in2],0x6" : [out1] "=r"(reg_result) : [in2] "r"(3));
        // } while (reg_result != 0);

        asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(5000000), [in2] "r"(1)); // set 5 seconds
        do {
            edgeDetection(rgb565, floyd, camParams.nrOfPixelsPerLine, camParams.nrOfLinesPerImage, 128);
            asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(5000000), [in2] "r"(1)); // set 5 seconds
        } while (reg_result != 0);

        asm volatile("l.nios_rrr r0,%[in1],%[in2],0x6" ::[in1] "r"(5000000), [in2] "r"(1)); // set 5 seconds
        for (int i = 0; i < size; i++) {
          result[i] = 0;
        }
        vga[2] = swap_u32(1);
        vga[3] = swap_u32((uint32_t)&result[0]);
        do {
            compare_arrays((uint8_t *)floyd, (uint8_t *)floyd2, (uint8_t *) rgb565,  (uint16_t *)result, size);

            for (int i = 0; i < size; i++) {
                floyd2[i] = floyd[i];
            }
            
            printf("here edge comp\n");
            delay(1000);
            break;
          } while (reg_result != 0);
    }

    return 0;
}
