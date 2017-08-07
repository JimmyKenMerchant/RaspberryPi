/**
 * system32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is intended to be used in GNU Assembler with AArch32/ ARMv7-A.
 */

.balign 4
.include "system32/print_char32.s"
.balign 4
.include "system32/font_bitmap32_8bit.s"
.balign 4
.include "system32/math32.s"
.balign 4
.include "system32/color_palettes32_16bit.s"
.balign 4

/**
 * function no_op
 * Do Nothing
 */
.globl no_op
no_op:
	mov r0, r0
	mov pc, lr

/**
 * function store_32
 * Store 32-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl store_32
store_32:
	str r1, [r0]
	mov pc, lr

/**
 * function load_32
 * Load 32-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl load_32
load_32:
	ldr r1, [r0]
	mov r0, r1
	mov pc, lr	
