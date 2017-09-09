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


/**
 * system32/system32.s
 */
ADDR32_system32_core_handle:      .word system32_core_handle
ADDR32_SYSTEM32_CORE_HANDLE_0:    .word SYSTEM32_CORE_HANDLE_0
ADDR32_SYSTEM32_CORE_HANDLE_1:    .word SYSTEM32_CORE_HANDLE_1
ADDR32_SYSTEM32_CORE_HANDLE_2:    .word SYSTEM32_CORE_HANDLE_2
ADDR32_SYSTEM32_CORE_HANDLE_3:    .word SYSTEM32_CORE_HANDLE_3
ADDR32_SYSTEM32_HEAP:             .word SYSTEM32_HEAP


/**
 * system32/fb32.s
 */

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


/**
 * system32/math32.s
 */

/**
 * system32/font_mono_12px.s
 */

ADDR32_FONT_MONO_12PX_ASCII:  .word FONT_MONO_12PX_ASCII


/**
 * system32/color.s
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


/**
 * system32/data32.s
 */

ADDR32_DATA_COLOR32_SAMPLE_IMAGE0:      .word DATA_COLOR32_SAMPLE_IMAGE0
ADDR32_DATA_COLOR32_SAMPLE_IMAGE0_SIZE: .word DATA_COLOR32_SAMPLE_IMAGE0_SIZE
ADDR32_DATA_COLOR32_SAMPLE_IMAGE1:      .word DATA_COLOR32_SAMPLE_IMAGE1
ADDR32_DATA_COLOR32_SAMPLE_IMAGE1_SIZE: .word DATA_COLOR32_SAMPLE_IMAGE1_SIZE
