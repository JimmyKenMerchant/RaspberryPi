/**
 * color_palettes32_16bit.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is intended to be used in GNU Assembler with AArch32/ ARMv7-A.
 */

color16_red:         .hword 0xF800 @ 0xFF0000
.balign 4 @ Need of 4 bytes alignment to avoid data abort in `ldr`, OR use `ldrh` which can not use PC though...
color16_green:       .hword 0x07E0 @ 0x00FF00
.balign 4
color16_blue:        .hword 0x001F @ 0x0000FF
.balign 4
color16_yellow:      .hword 0xFFE0 @ 0xFFFF00
.balign 4
color16_magenta:     .hword 0xF81F @ 0xFF00FF
.balign 4
color16_cyan:        .hword 0x07FF @ 0x00FFFF
.balign 4
color16_pink:        .hword 0xFE19 @ 0xFFC0CB
.balign 4
color16_lime:        .hword 0xBFE0 @ 0xBFFF00
.balign 4
color16_skyblue:     .hword 0x867D @ 0x87CEEB
.balign 4
color16_lightyellow: .hword 0xFFFC @ 0xFFFFE0
.balign 4
color16_scarlet:     .hword 0xF920 @ 0xFF2400
.balign 4
color16_navyblue:    .hword 0x0010 @ 0x000080
.balign 4
color16_white:       .hword 0xFFFF
.balign 4
color16_lightgray:   .hword 0xD69A @ 0xD3D3D3
.balign 4
color16_gray:        .hword 0x8410 @ 0x808080
.balign 4
color16_black:       .hword 0x0000
.balign 4
