/**
 * addr32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * system32/system32.s
 */
ADDR32_SYSTEM32_STACKPOINTER:        .word SYSTEM32_STACKPOINTER
ADDR32_SYSTEM32_DATAMEMORY_ADDR:     .word SYSTEM32_DATAMEMORY_ADDR
ADDR32_SYSTEM32_DATAMEMORY_SIZE:     .word SYSTEM32_DATAMEMORY_SIZE
ADDR32_SYSTEM32_HEAP_NONCACHE_ADDR:  .word SYSTEM32_HEAP_NONCACHE_ADDR
ADDR32_SYSTEM32_HEAP_NONCACHE_SIZE:  .word SYSTEM32_HEAP_NONCACHE_SIZE
ADDR32_SYSTEM32_NONCACHE_ADDR:       .word SYSTEM32_NONCACHE_ADDR
ADDR32_SYSTEM32_NONCACHE_SIZE:       .word SYSTEM32_NONCACHE_SIZE

/**
 * system32/vendor/bcm32.s
 */

ADDR32_BCM32_DISPLAY_WIDTH:        .word BCM32_DISPLAY_WIDTH
ADDR32_BCM32_DISPLAY_HEIGHT:       .word BCM32_DISPLAY_HEIGHT
ADDR32_BCM32_WIDTH:                .word BCM32_WIDTH
ADDR32_BCM32_HEIGHT:               .word BCM32_HEIGHT
ADDR32_BCM32_DEPTH:                .word BCM32_DEPTH
ADDR32_BCM32_PIXELORDER:           .word BCM32_PIXELORDER
ADDR32_BCM32_ALPHAMODE:            .word BCM32_ALPHAMODE
ADDR32_BCM32_ADDRESS:              .word BCM32_ADDRESS
ADDR32_BCM32_SIZE:                 .word BCM32_SIZE
ADDR32_BCM32_CELCIUS:              .word BCM32_CELCIUS
ADDR32_BCM32_MAXCELCIUS:           .word BCM32_MAXCELCIUS
ADDR32_BCM32_VOLTAGE:              .word BCM32_VOLTAGE
ADDR32_BCM32_CLOCKRATE:            .word BCM32_CLOCKRATE
ADDR32_BCM32_ARMMEMORY_BASE:       .word BCM32_ARMMEMORY_BASE
ADDR32_BCM32_ARMMEMORY_SIZE:       .word BCM32_ARMMEMORY_SIZE
ADDR32_BCM32_VCMEMORY_BASE:        .word BCM32_VCMEMORY_BASE
ADDR32_BCM32_VCMEMORY_SIZE:        .word BCM32_VCMEMORY_SIZE

/**
 * system32/arm/arm32.s
 */

.ifndef __ARMV6

ADDR32_ARM32_CORE_HANDLE_0:       .word ARM32_CORE_HANDLE_0
ADDR32_ARM32_CORE_HANDLE_1:       .word ARM32_CORE_HANDLE_1
ADDR32_ARM32_CORE_HANDLE_2:       .word ARM32_CORE_HANDLE_2
ADDR32_ARM32_CORE_HANDLE_3:       .word ARM32_CORE_HANDLE_3

.endif

ADDR32_ARM32_VADESCRIPTOR_ADDR:   .word ARM32_VADESCRIPTOR_ADDR
ADDR32_ARM32_VADESCRIPTOR_SIZE:   .word ARM32_VADESCRIPTOR_SIZE
ADDR32_ARM32_STOPWATCH_LOW:       .word ARM32_STOPWATCH_LOW
ADDR32_ARM32_STOPWATCH_HIGH:      .word ARM32_STOPWATCH_HIGH


/**
 * system32/arm/dma32.s
 */

ADDR32_DMA32_CB:   .word DMA32_CB


/**
 * system32/library/fb32.s
 */

ADDR32_FB32_FRAMEBUFFER:          .word FB32_FRAMEBUFFER
ADDR32_FB32_FRAMEBUFFER_ADDR:     .word FB32_FRAMEBUFFER_ADDR
ADDR32_FB32_FRAMEBUFFER_WIDTH:    .word FB32_FRAMEBUFFER_WIDTH
ADDR32_FB32_FRAMEBUFFER_HEIGHT:   .word FB32_FRAMEBUFFER_HEIGHT
ADDR32_FB32_FRAMEBUFFER_SIZE:     .word FB32_FRAMEBUFFER_SIZE
ADDR32_FB32_FRAMEBUFFER_DEPTH:    .word FB32_FRAMEBUFFER_DEPTH
ADDR32_FB32_DOUBLEBUFFER_FRONT:   .word FB32_DOUBLEBUFFER_FRONT
ADDR32_FB32_DOUBLEBUFFER_BACK:    .word FB32_DOUBLEBUFFER_BACK

ADDR32_FB32_X_CARET:              .word FB32_X_CARET
ADDR32_FB32_Y_CARET:              .word FB32_Y_CARET
ADDR32_FB32_ADDR:                 .word FB32_ADDR
ADDR32_FB32_WIDTH:                .word FB32_WIDTH
ADDR32_FB32_HEIGHT:               .word FB32_HEIGHT
ADDR32_FB32_SIZE:                 .word FB32_SIZE
ADDR32_FB32_DEPTH:                .word FB32_DEPTH


/**
 * system32/library/print32.s
 */

ADDR32_PRINT32_FONT_BASE:      .word PRINT32_FONT_BASE
ADDR32_PRINT32_FONT_WIDTH:     .word PRINT32_FONT_WIDTH
ADDR32_PRINT32_FONT_HEIGHT:    .word PRINT32_FONT_HEIGHT
ADDR32_PRINT32_FONT_COLOR:     .word PRINT32_FONT_COLOR
ADDR32_PRINT32_FONT_BACKCOLOR: .word PRINT32_FONT_BACKCOLOR


/**
 * system32/library/snd32.s
 */

ADDR32_SND32_STATUS:           .word SND32_STATUS


/**
 * system32/library/hid32.s
 */

ADDR32_HID32_KEYBOARD_GET_ASCII:       .word HID32_KEYBOARD_GET_ASCII
ADDR32_HID32_KEYBOARD_GET_ASCII_SHIFT: .word HID32_KEYBOARD_GET_ASCII
ADDR32_HID32_KEYBOARD_GET_101:         .word HID32_KEYBOARD_GET_101
ADDR32_HID32_KEYBOARD_GET_SHIFT_101:   .word HID32_KEYBOARD_GET_SHIFT_101


/**
 * system32/library/font_mono_12px.s
 */

ADDR32_FONT_MONO_12PX_ASCII:   .word FONT_MONO_12PX_ASCII


/**
 * system32/library/color.s
 */

ADDR32_COLOR16_RED:          .word COLOR16_RED
ADDR32_COLOR16_GREEN:        .word COLOR16_GREEN
ADDR32_COLOR16_BLUE:         .word COLOR16_BLUE
ADDR32_COLOR16_YELLOW:       .word COLOR16_YELLOW
ADDR32_COLOR16_MAGENTA:      .word COLOR16_MAGENTA
ADDR32_COLOR16_CYAN:         .word COLOR16_CYAN
ADDR32_COLOR16_PINK:         .word COLOR16_PINK
ADDR32_COLOR16_LIME:         .word COLOR16_LIME
ADDR32_COLOR16_SKYBLUE:      .word COLOR16_SKYBLUE
ADDR32_COLOR16_LIGHTYELLOW:  .word COLOR16_LIGHTYELLOW
ADDR32_COLOR16_SCARLET:      .word COLOR16_SCARLET
ADDR32_COLOR16_DARKGREEN:    .word COLOR16_DARKGREEN
ADDR32_COLOR16_NAVYBLUE:     .word COLOR16_NAVYBLUE
ADDR32_COLOR16_WHITE:        .word COLOR16_WHITE
ADDR32_COLOR16_LIGHTGRAY:    .word COLOR16_LIGHTGRAY
ADDR32_COLOR16_GRAY:         .word COLOR16_GRAY
ADDR32_COLOR16_BLACK:        .word COLOR16_BLACK
ADDR32_COLOR16_SAMPLE_IMAGE: .word COLOR16_SAMPLE_IMAGE

ADDR32_COLOR32_RED:          .word COLOR32_RED
ADDR32_COLOR32_GREEN:        .word COLOR32_GREEN
ADDR32_COLOR32_BLUE:         .word COLOR32_BLUE
ADDR32_COLOR32_YELLOW:       .word COLOR32_YELLOW
ADDR32_COLOR32_MAGENTA:      .word COLOR32_MAGENTA
ADDR32_COLOR32_CYAN:         .word COLOR32_CYAN
ADDR32_COLOR32_PINK:         .word COLOR32_PINK
ADDR32_COLOR32_LIME:         .word COLOR32_LIME
ADDR32_COLOR32_SKYBLUE:      .word COLOR32_SKYBLUE
ADDR32_COLOR32_LIGHTYELLOW:  .word COLOR32_LIGHTYELLOW
ADDR32_COLOR32_SCARLET:      .word COLOR32_SCARLET
ADDR32_COLOR32_DARKGREEN:    .word COLOR32_DARKGREEN
ADDR32_COLOR32_NAVYBLUE:     .word COLOR32_NAVYBLUE
ADDR32_COLOR32_WHITE:        .word COLOR32_WHITE
ADDR32_COLOR32_LIGHTGRAY:    .word COLOR32_LIGHTGRAY
ADDR32_COLOR32_GRAY:         .word COLOR32_GRAY
ADDR32_COLOR32_BLACK:        .word COLOR32_BLACK

