/**
 * macro32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * Print String
 * Use r0 for string, r1 for color, r2 for back_color, r3 for font. Otherwise, printed incorrectly.
 */
.macro macro32_print_string string x_coord y_coord color back_color length char_width char_height font
	push {r0-r8,lr}
	mov r0, \string                           @ Pointer of Array of String
	mov r8, \font
	mov r3, \color                            @ Color (16-bit or 32-bit)
	mov r4, \back_color                       @ Background Color (16-bit or 32-bit)
	mov r1, #\x_coord                         @ X Coordinate
	mov r2, #\y_coord                         @ Y Coordinate
	mov r5, #\length                          @ Length of Characters, Need of PUSH/POP
	mov r6, #\char_width
	mov r7, #\char_height
	push {r4-r8}
	bl print32_string
	add sp, sp, #20                           @ Increment SP because of push
	pop {r0-r8,lr}
.endm


/**
 * Print Number (32-bit)
 * Use r0 for number, r1 for color, r2 for back_color, r3 for font. Otherwise, printed incorrectly.
 */
.macro macro32_print_number number x_coord y_coord color back_color digits char_width char_height font
	push {r0-r8,lr}
	mov r0, \number
	mov r8, \font
	mov r3, \color                            @ Color (16-bit or 32-bit)
	mov r4, \back_color                       @ Background Color (16-bit or 32-bit)
	mov r1, #\x_coord                         @ X Coordinate
	mov r2, #\y_coord                         @ Y Coordinate
	mov r5, #\digits                          @ Length of Characters, Need of PUSH/POP
	mov r6, #\char_width
	mov r7, #\char_height
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push
	pop {r0-r8,lr}
.endm


/**
 * Print Number (64-bit)
 * Use r0 for number_lower, r1 for number_upper, r2 for color, r3 for back_color, r4 for font. Otherwise, printed incorrectly.
 */
.macro macro32_print_number_double number_lower number_upper x_coord y_coord color back_color digits char_width char_height font
	push {r0-r9,lr}
	mov r0, \number_lower
	mov r1, \number_upper
	mov r9, \font
	mov r4, \color                            @ Color (16-bit or 32-bit)
	mov r5, \back_color                       @ Background Color (16-bit or 32-bit)
	mov r2, #\x_coord                         @ X Coordinate
	mov r3, #\y_coord                         @ Y Coordinate
	mov r6, #\digits                          @ Length of Characters, Need of PUSH/POP
	mov r7, #\char_width
	mov r8, #\char_height
	push {r4-r9}
	bl print32_number
	add sp, sp, #24                           @ Increment SP because of push
	pop {r0-r9,lr}
.endm


/**
 * Print Value of Register for Debug
 */
.macro macro32_debug reg0 x_coord y_coord
	push {r0-r3,lr}
	mov r0, \reg0
	mov r1, #\x_coord
	mov r2, #\y_coord
	bl print32_debug
	pop {r0-r3,lr}
.endm


/**
 * Data Synchronization Barrier for compatibility between ARMv6 and ARMv7+
 */
.macro macro32_dsb reg0
	/* ARMv7+ */
	/*dsb*/
	/* ARMv6 */
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c10, 4
.endm


/**
 * Data Memory Barrier for compatibility between ARMv6 and ARMv7+
 */
.macro macro32_dmb reg0
	/* ARMv7+ */
	/*dmb*/
	/* ARMv6 */
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c10, 5
.endm


/**
 * Instruction Synchronization Barrier for compatibility between ARMv6 and ARMv7+
 * Using Flush Prefetch Buffer and Flush Entire Branch Target Cache
 */
.macro macro32_isb reg0
	/* ARMv7+ */
	/*isb*/
	/* ARMv6 */
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c5, 4
	mcr p15, 0, \reg0, c7, c5, 6
.endm

