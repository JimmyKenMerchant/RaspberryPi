/**
 * print_char.inc
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is intended to be used in GNU Assembler with AArch32/ ARMv7-A.
 */

.globl decimal_adder64

/**
 * function decimal_adder64
 * print raw numbers in a registor
 *
 * Parameters
 * r0 unsigned integer: Lower Bits of First Number
 * r1 unsigned integer: Upper Bits of First Number
 * r2 unsigned integer: Lower Bits of Second Number
 * r3 unsinged integer: Upper Bits of Second Number
 *
 * Usage: r0-r11
 * return: r0 (Lower Bits of Return Number), r1 (Upper Bits of Return Number), if all zero, may be error
 * error: This function could not calculate because of digit-overflow.
 */
decimal_adder64:
	/* Auto (Local) Variables, but just aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	dup_lower_1    .req r4 @ Duplication of lower_1
	dup_upper_1    .req r5 @ Duplication of upper_1
	mul_number     .req r6
	i              .req r7
	shift          .req r8
	mask_1         .req r9
	mask_2         .req r10
	carry_flag     .req r11

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov dup_lower_1, lower_1
	mov dup_upper_1, upper_1
	mov lower_1, #0
	mov upper_1, #0
	mov carry_flag, #0

	mov i, #0
	mov mul_number, #4

	decimal_adder64_loop:
		mov mask_1, #0xf                            @ 0b1111
		mov mask_2, #0xf

		mul shift, i, mul_number

		cmp i, #8
		bge decimal_adder64_loop_uppernumber

		/* Lower Number */
		lsl mask_1, mask_1, shift
		lsl mask_2, mask_2, shift

		and mask_1, dup_lower_1, mask_1
		and mask_2, lower_2, mask_2

		b decimal_adder64_loop_adder

		/* Upper Number */
		decimal_adder64_loop_uppernumber:

			sub shift, shift, #32

			lsl mask_1, mask_1, shift
			lsl mask_2, mask_2, shift

			and mask_1, dup_upper_1, mask_1
			and mask_2, upper_2, mask_2

		decimal_adder64_loop_adder:
		
			lsr mask_1, mask_1, shift
			lsr mask_2, mask_2, shift

			add mask_1, mask_1, mask_2
			add mask_1, mask_1, carry_flag

			cmp mask_1, #0x10
			bge decimal_adder64_loop_adder_hexacarry

			cmp mask_1, #0x0A
			bge decimal_adder64_loop_adder_decicarry

			mov carry_flag, #0                      @ Clear Carry

			b decimal_adder64_loop_common	

			decimal_adder64_loop_adder_hexacarry:

				sub mask_1, #0x10
				add mask_1, #0x06 
				mov carry_flag, #1              @ Set Carry

				b decimal_adder64_loop_common

			decimal_adder64_loop_adder_decicarry:

				sub mask_1, #0x0A
				mov carry_flag, #1              @ Set Carry

		decimal_adder64_loop_common:
			lsl mask_1, mask_1, shift

			cmp i, #8
			bge decimal_adder64_loop_common_uppernumber

			/* Lower Number */
			add lower_1, lower_1, mask_1

			b decimal_adder64_loop_common_common

			/* Upper Number */
			decimal_adder64_loop_common_uppernumber:

				add upper_1, upper_1, mask_1

			decimal_adder64_loop_common_common:

				add i, i, #1
				cmp i, #16
				blt decimal_adder64_loop

				cmp carry_flag, #1
				beq decimal_adder64_error

	decimal_adder64_success:
		b decimal_adder64_common

	decimal_adder64_error:
		mov r0, #0                                        @ Return with Error
		mov r1, #0

	decimal_adder64_common:
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		mov pc, lr

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq dup_lower_1
.unreq dup_upper_1
.unreq mul_number
.unreq i
.unreq shift
.unreq mask_1
.unreq mask_2
.unreq carry_flag


.globl print_number_8by8

/**
 * function print_number_8by8
 * print raw numbers in a registor
 *
 * Parameters
 * r0 unsigned integer: Register to show numbers
 * r1 unsigned integer: X Coordinate
 * r2 unsigned integer: Y Coordinate
 * r3 unsinged integer: Color (16-bit)
 * r4 unsigned integer: Number of Digits, 8 Digits Maximum, Need of PUSH
 *
 * Usage: r0-r10
 * return: 0 as sucess, 1 as error
 * error: When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 */
print_number_8by8:
	/* Auto (Local) Variables, but just aliases */
	numbers        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord        .req r2 @ Parameter, Register for Argument, Scratch Register
	color          .req r3 @ Parameter, Register for Argument, Scratch Register
	digits         .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	width          .req r5
	mul_number     .req r6
	i              .req r7
	mask           .req r8
	shift          .req r9
	array_num_base .req r10

	push {r4-r10}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #28                                  @ r4-r10 offset 28 bytes
	pop {digits}                                     @ Get Fourth Argument
	sub sp, sp, #32                                  @ Retrieve SP

	sub digits, digits, #1

	mov mul_number, #8
	mul width, digits, mul_number
	add x_coord, x_coord, width

	ldr array_num_base, ARRAY_FONT_BITMAP8

	mov i, #0

	print_number_8by8_loop:
		mov mask, #0xf                            @ 0b1111
		mov mul_number, #4
		mul shift, i, mul_number
		lsl mask, mask, shift                     @ Make Mask
		and mask, numbers, mask
		lsr mask, mask, shift                     @ Make One Digit Number
		mul mask, mask, mul_number

		push {r0-r3,lr}                           @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [array_num_base, mask]            @ Character Pointer
		bl pict_char_8by8
		cmp r0, #0                                @ Compare Return 0 or 1
		pop {r0-r3,lr}                            @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print_number_8by8_error

		sub x_coord, #8

		add i, i, #1

		cmp i, digits
		bgt print_number_8by8_success

		cmp i, #8
		blt print_number_8by8_loop

	print_number_8by8_success:
		mov r0, #0                                        @ Return with Success
		b print_number_8by8_common

	print_number_8by8_error:
		mov r0, #1                                        @ Return with Error

	print_number_8by8_common:
		pop {r4-r10}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		/*pop {r3}*/    @ To Prevent Stack Pointer Increment after Return Because of the 5th Parameter
                                @ BUT, this increment is in charge of CALLER, not CALLEE on C Lang Regulation (gcc -O2 option)

		mov pc, lr

.unreq numbers
.unreq x_coord
.unreq y_coord
.unreq color
.unreq digits
.unreq width
.unreq mul_number
.unreq i
.unreq mask
.unreq shift
.unreq array_num_base


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
 * return: 0 as sucess, 1 as error
 * error: When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 */
pict_char_8by8:
	/* Auto (Local) Variables, but just aliases */
	char_point .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord    .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord    .req r2 @ Parameter, Register for Argument, Scratch Register
	color      .req r3 @ Parameter, Register for Argument, Scratch Register
	i          .req r4
	f_buffer   .req r5
	width      .req r6
	size       .req r7
	length     .req r8
	j          .req r9
	bitmask    .req r10

	push {r4-r10}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov i, #0                                         @ Vertical Counter
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

		add i, i, #1
		cmp i, #8
		blt pict_char_8by8_loop

		mov r0, #0                                        @ Return with Success
		b pict_char_8by8_common

	pict_char_8by8_error:
		mov r0, #1                                        @ Return with Error

	pict_char_8by8_common:
		pop {r4-r10}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
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

.include "font_bitmap_8bit.s"
