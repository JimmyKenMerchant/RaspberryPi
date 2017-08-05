/**
 * system.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is intended to be used in GNU Assembler with AArch32/ ARMv7-A.
 */

.balign 4
.include "print_char32.s"
.balign 4
.include "font_bitmap32_8bit.s"
.balign 4
.include "math32.s"
.balign 4
.include "color_palettes32_16bit.s"
.balign 4

.globl no_op
no_op:
	mov r0, r0
	mov pc, lr
