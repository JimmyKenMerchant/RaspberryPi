/**
 * addr32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.include "system32/equ32.s"

/**
 * include/aloha/system32.h
 */

.globl _user_start


/**
 * system32/system32.s
 */

.globl SYSTEM32_SYSTEMTIMER_BASE
.globl SYSTEM32_INTERRUPT_BASE
.globl SYSTEM32_ARMTIMER_BASE
.globl SYSTEM32_MAILBOX_BASE
.globl SYSTEM32_GPIO_BASE
.globl system32_convert_endianness
.globl system32_sleep
.globl system32_no_op
.globl system32_store_32
.globl system32_store_16
.globl system32_store_8
.globl system32_load_32
.globl system32_load_16
.globl system32_load_8
.globl SYSTEM32_HEAP

ADDR32_SYSTEM32_SYSTEMTIMER_BASE: .word SYSTEM32_SYSTEMTIMER_BASE
ADDR32_SYSTEM32_INTERRUPT_BASE:   .word SYSTEM32_INTERRUPT_BASE
ADDR32_SYSTEM32_ARMTIMER_BASE:    .word SYSTEM32_ARMTIMER_BASE
ADDR32_SYSTEM32_MAILBOX_BASE:     .word SYSTEM32_MAILBOX_BASE
ADDR32_SYSTEM32_GPIO_BASE:        .word SYSTEM32_GPIO_BASE
ADDR32_SYSTEM32_HEAP:             .word SYSTEM32_HEAP


/**
 * system32/fb32.s
 */
.globl FB32_FRAMEBUFFER
.globl FB32_RENDERBUFFER0
.globl FB32_RENDERBUFFER1
.globl FB32_RENDERBUFFER2
.globl FB32_RENDERBUFFER3
.globl fb32_rgba_to_argb
.globl fb32_draw_line
.globl fb32_copy
.globl fb32_draw_image
.globl fb32_clear_color_block
.globl fb32_clear_color
.globl fb32_get
.globl FB32_X_CARET
.globl FB32_Y_CARET
.globl FB32_DISPLAY_WIDTH
.globl FB32_DISPLAY_HEIGHT
.globl FB32_WIDTH
.globl FB32_HEIGHT
.globl FB32_DEPTH
.globl FB32_PIXELORDER
.globl FB32_ALPHAMODE
.globl FB32_ADDRESS
.globl FB32_SIZE

ADDR32_FB32_FRAMEBUFFER:          .word FB32_FRAMEBUFFER
ADDR32_FB32_RENDERBUFFER0:        .word FB32_RENDERBUFFER0
ADDR32_FB32_RENDERBUFFER1:        .word FB32_RENDERBUFFER1
ADDR32_FB32_RENDERBUFFER2:        .word FB32_RENDERBUFFER2
ADDR32_FB32_RENDERBUFFER3:        .word FB32_RENDERBUFFER3

ADDR32_FB32_X_CARET:        .word FB32_X_CARET
ADDR32_FB32_Y_CARET:        .word FB32_Y_CARET
ADDR32_FB32_DISPLAY_WIDTH:  .word FB32_DISPLAY_WIDTH
ADDR32_FB32_DISPLAY_HEIGHT: .word FB32_DISPLAY_HEIGHT
ADDR32_FB32_WIDTH:          .word FB32_WIDTH
ADDR32_FB32_HEIGHT:         .word FB32_HEIGHT
ADDR32_FB32_DEPTH:          .word FB32_DEPTH
ADDR32_FB32_PIXELORDER:     .word FB32_PIXELORDER
ADDR32_FB32_ALPHAMODE:      .word FB32_ALPHAMODE
ADDR32_FB32_ADDRESS:        .word FB32_ADDRESS
ADDR32_FB32_SIZE:           .word FB32_SIZE


/**
 * system32/print32.s
 */

.globl print32_set_caret
.globl print32_strlen
.globl print32_string
.globl print32_number_double
.globl print32_number
.globl print32_char


/**
 * system32/math32.s
 */

.globl math32_hexa_to_deci32
.globl math32_decimal_adder64


/**
 * system32/font_mono_12px.s
 */

.globl FONT_MONO_12PX_ASCII

ADDR32_FONT_MONO_12PX_ASCII:  .word FONT_MONO_12PX_ASCII


/**
 * system32/color.s
 */

.globl COLOR16_RED
.globl COLOR16_GREEN
.globl COLOR16_BLUE
.globl COLOR16_YELLOW
.globl COLOR16_MAGENTA
.globl COLOR16_CYAN
.globl COLOR16_PINK
.globl COLOR16_LIME
.globl COLOR16_SKYBLUE
.globl COLOR16_LIGHTYELLOW
.globl COLOR16_SCARLET
.globl COLOR16_DARKGREEN
.globl COLOR16_NAVYBLUE
.globl COLOR16_WHITE
.globl COLOR16_LIGHTGRAY
.globl COLOR16_GRAY
.globl COLOR16_BLACK
.globl COLOR16_SAMPLE_IMAGE

.globl COLOR32_RED
.globl COLOR32_GREEN
.globl COLOR32_BLUE
.globl COLOR32_YELLOW
.globl COLOR32_MAGENTA
.globl COLOR32_CYAN
.globl COLOR32_PINK
.globl COLOR32_LIME
.globl COLOR32_SKYBLUE
.globl COLOR32_LIGHTYELLOW
.globl COLOR32_SCARLET
.globl COLOR32_DARKGREEN
.globl COLOR32_NAVYBLUE
.globl COLOR32_WHITE
.globl COLOR32_LIGHTGRAY
.globl COLOR32_GRAY
.globl COLOR32_BLACK

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


/**
 * system32/data32.s
 */

.globl DATA_COLOR32_SAMPLE_IMAGE0
.globl DATA_COLOR32_SAMPLE_IMAGE0_SIZE
.globl DATA_COLOR32_SAMPLE_IMAGE1
.globl DATA_COLOR32_SAMPLE_IMAGE1_SIZE

ADDR32_DATA_COLOR32_SAMPLE_IMAGE0:      .word DATA_COLOR32_SAMPLE_IMAGE0
ADDR32_DATA_COLOR32_SAMPLE_IMAGE0_SIZE: .word DATA_COLOR32_SAMPLE_IMAGE0_SIZE
ADDR32_DATA_COLOR32_SAMPLE_IMAGE1:      .word DATA_COLOR32_SAMPLE_IMAGE1
ADDR32_DATA_COLOR32_SAMPLE_IMAGE1_SIZE: .word DATA_COLOR32_SAMPLE_IMAGE1_SIZE
