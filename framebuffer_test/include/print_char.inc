/**
 * print_char.inc
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is intended to be used in GNU Assembler with AArch32/ ARMv7-A.
 */

.globl pict_char_8by8
/**
 * function pict_char_8by8
 * picture a 8-bit-width-8-bit-height Character
 *
 * Parameters
 * r0 unsigned integer: Character Pointer
 * r1 unsigned integer: X Coordinate
 * r2 unsigned integer: Y Coordinate
 * r3 unsinged integer: Color (16-bit)
 *
 * Usage: r0-r10, r8 reused
 */
pict_char_8by8:
	/* Auto (Local) Variables, but just aliases */
	char_point .req r0 @ Parameter
	x_coord    .req r1 @ Parameter
	y_coord    .req r2 @ Parameter
	color      .req r3 @ Parameter
	i          .req r4
	f_buffer   .req r5
	width      .req r6
	size       .req r7
	length     .req r8
	j          .req r9
	bitmask    .req r10

	mov i, #8                                         @ Vertical Counter
	ldr f_buffer, fb_address
	and f_buffer, f_buffer, #mailbox_armmask
	ldr width, fb_width

	ldr size, fb_size
	add size, f_buffer, size
	sub size, size, #2                                @ Maximum of Framebuffer Address (Offset - 2 Bytes)

	mov length, #2                                    @ Length of a Pixel in Framebuffer (Bytes)

	/* Set Location to Render the Character */
	mul x_coord, x_coord, length                      @ Horizontal Offset Bytes
	add f_buffer, f_buffer, x_coord

	mul width, width, length                          @ Framebuffer Width (Bytes)
	mul y_coord, y_coord, width                       @ Vertical Offset Bytes
	add f_buffer, f_buffer, y_coord

	cmp f_buffer, size                                @ Check Overflow of Framebuffer Memory
	bgt pict_char_8by8_error

	.unreq length
	char_byte .req r8                                 @ Naming Change

	pict_char_8by8_loop:
		ldrb char_byte, [char_point]              @ Load Horizontal Byte
		mov j, #8                                 @ Horizontal Counter

		pict_char_8by8_loop_horizontal:
			sub j, j, #1                      @ For Bit Allocation (Horizontal Character Bit)
			mov bitmask, #1
			lsl bitmask, bitmask, j           @ Logical Shift Left to Make Bit Mask for Current Character Bit

			and bitmask, char_byte, bitmask
			cmp bitmask, #0
			beq pict_char_8by8_loop_horizontal_common

			/* The Picture Process */
			strh color, [f_buffer]                    @ Store half word

			pict_char_8by8_loop_horizontal_common:
				add f_buffer, f_buffer, #2        @ Framebuffer Address Shift

				cmp f_buffer, size                @ Check Overflow of Framebuffer Memory
				bgt pict_char_8by8_error

				cmp j, #0
				bgt pict_char_8by8_loop_horizontal

		add char_point, char_point, #1                    @ Horizontal Sync (Character Pointer)

		sub f_buffer, f_buffer, #16                       @ Offset Clear of Framebuffer
		add f_buffer, f_buffer, width                     @ Horizontal Sync (Framebuffer)

		cmp f_buffer, size                                @ Check Overflow of Framebuffer Memory
		bgt pict_char_8by8_error

		sub i, i, #1
		cmp i, #0
		bgt pict_char_8by8_loop

		mov r0, #0                                        @ Return with Success
		b pict_char_8by8_common

	pict_char_8by8_error:
		mov r0, #1                                        @ Return with Error

	pict_char_8by8_common:
		mov pc, lr

.unreq char_point
.unreq x_coord
.unreq y_coord
.unreq color
.unreq i
.unreq f_buffer
.unreq width
.unreq size
.unreq char_byte
.unreq j
.unreq bitmask

.include "font_bitmap_8bit.inc"
