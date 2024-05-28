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