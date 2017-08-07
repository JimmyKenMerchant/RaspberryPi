/**
 * print_char32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function strlen_ascii
 * Count 1-Byte Words of String
 *
 * Parameters
 * r0: Pointer of Array of String
 *
 * Usage: r0-r2
 * Return: r0 (Number of Words) Maximum of 4,294,967,295 words
 */
.globl strlen_ascii
strlen_ascii:
	/* Auto (Local) Variables, but just aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_byte       .req r1
	length            .req r2

	mov length, #0

	strlen_ascii_loop:
		ldrb string_byte, [string_point]          @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq strlen_ascii_common                   @ Break Loop if Null Character

		add string_point, string_point, #1
		add length, length, #1
		b strlen_ascii_loop

	strlen_ascii_common:
		mov r0, length
		mov pc, lr

.unreq string_point
.unreq string_byte
.unreq length


/**
 * function print_string_ascii_8by8
 * Print String with ASCII Table
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 * r4: Length of Characters, Need of PUSH/POP
 *
 * Usage: r0-r7
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 * Global Enviromental Variable(s): ARRAY_ASCII_FONT_BITMAP8, FB_WIDTH
 */
.globl print_string_ascii_8by8
print_string_ascii_8by8:
	/* Auto (Local) Variables, but just aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	color             .req r3 @ Parameter, Register for Argument and Result, Scratch Register
	length            .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	string_byte       .req r5
	mul_number        .req r6
	ascii_table_base  .req r7
	i                 .req r8
	dup_x_coord       .req r9
	width             .req r10

	push {r4-r10} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #28                                  @ r4-r10 offset 28 bytes
	pop {length}                                     @ Get Fourth Argument
	sub sp, sp, #32                                  @ Retrieve SP

	mov mul_number, #4
	ldr ascii_table_base, ARRAY_ASCII_FONT_BITMAP8

	mov dup_x_coord, x_coord
	ldr width, FB_WIDTH

	mov i, #0
	cmp i, length
	beq print_string_ascii_8by8_success

	print_string_ascii_8by8_loop:
		ldrb string_byte, [string_point]          @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq print_string_ascii_8by8_success       @ Break Loop if Null Character

		cmp string_byte, #0x0A
		beq print_string_ascii_8by8_loop_linefeed

		mul string_byte, string_byte, mul_number

		push {r0-r3,lr}                           @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [ascii_table_base, string_byte]   @ Character Pointer
		bl pict_char_8by8
		push {r1}
		add sp, sp, #4
		cmp r0, #0                                @ Compare Return 0 or 1
		pop {r0-r3,lr}                            @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print_string_ascii_8by8_error

		add x_coord, x_coord, #8
		cmp x_coord, width
		blt print_string_ascii_8by8_loop_common

		mov x_coord, dup_x_coord
		add y_coord, y_coord, #8

		print_string_ascii_8by8_loop_linefeed:
			mov x_coord, dup_x_coord
			add y_coord, y_coord, #8

		print_string_ascii_8by8_loop_common:
			add string_point, string_point, #1
			add i, #1
			cmp i, length
			blt print_string_ascii_8by8_loop

	print_string_ascii_8by8_success:
		mov r0, #0                                 @ Return with Success
		b print_string_ascii_8by8_common

	print_string_ascii_8by8_error:
		mov r0, r0                                 @ Return with Error (NOP to Throw from pict_char_8by8)

	print_string_ascii_8by8_common:
		ldr r1, [sp, #-24]
		pop {r4-r10} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq string_point
.unreq x_coord
.unreq y_coord
.unreq color
.unreq length
.unreq string_byte
.unreq mul_number
.unreq ascii_table_base
.unreq i
.unreq dup_x_coord
.unreq width


/**
 * function double_print_number_8by8
 * Print Hexadecimal Bases Numbers in 64-bit (16 Digits)
 *
 * Parameters
 * r0: Lower Half of the Number
 * r1: Upper Half of the Number
 * r2: X Coordinate
 * r3: Y Coordinate
 * r4: Color (16-bit or 32-bit), Need of PUSH/POP
 * r5: length of Digits, 16 Digits Maximum, Need of PUSH/POP
 *
 * Usage: r0-r7
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
.globl double_print_number_8by8
double_print_number_8by8:
	/* Auto (Local) Variables, but just aliases */
	number_lower      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	number_upper      .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r3 @ Parameter, Register for Argument, Scratch Register
	color             .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length            .req r5 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	width             .req r6
	mul_number        .req r7

	push {r4-r7} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #16                                  @ r4-r10 offset 28 bytes
	pop {color,length}                               @ Get Fourth Argument
	sub sp, sp, #24                                  @ Retrieve SP

	mov mul_number, #8

	double_print_number_8by8_loop:
		cmp length, #8
		ble double_print_number_8by8_loop_lower

			sub length, length, #8

			push {r0-r3,lr}                    @ Equals to stmfd (stack pointer full, decrement order)
			mov r0, number_upper	
			mov r1, x_coord
			mov r2, y_coord
			mov r3, color
			push {length}
			bl print_number_8by8
			add sp, sp, #4
			push {r1}
			add sp, sp, #4
			cmp r0, #0                         @ Compare Return 0 or 1
			pop {r0-r3,lr}                     @ Retrieve Registers Before Error Check, POP does not flags-update
			bne double_print_number_8by8_error

			mul width, length, mul_number
			add x_coord, x_coord, width
			mov length, #8

		double_print_number_8by8_loop_lower:

			push {r0-r3,lr}                    @ Equals to stmfd (stack pointer full, decrement order)	
			mov r1, x_coord
			mov r2, y_coord
			mov r3, color
			push {length}
			bl print_number_8by8
			add sp, sp, #4
			push {r1}
			add sp, sp, #4
			cmp r0, #0                         @ Compare Return 0 or 1
			pop {r0-r3,lr}                     @ Retrieve Registers Before Error Check, POP does not flags-update
			bne double_print_number_8by8_error

	double_print_number_8by8_success:
		mov r0, #0                                 @ Return with Success
		b double_print_number_8by8_common

	double_print_number_8by8_error:
		mov r0, r0                                 @ Return with Error (NOP to Throw from print_number_8by8)

	double_print_number_8by8_common:
		ldr r1, [sp, #-24]
		pop {r4-r9} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq number_lower
.unreq number_upper
.unreq x_coord
.unreq y_coord
.unreq color
.unreq length
.unreq width
.unreq mul_number

/**
 * function print_number_8by8
 * Print Hexadecimal Bases Numbers in 32-bit (8 Digits)
 *
 * Parameters
 * r0: Register to show numbers
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 * r4: length of Digits, 8 Digits Maximum, Need of PUSH/POP
 *
 * Usage: r0-r10
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
.globl print_number_8by8
print_number_8by8:
	/* Auto (Local) Variables, but just aliases */
	number        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord        .req r2 @ Parameter, Register for Argument, Scratch Register
	color          .req r3 @ Parameter, Register for Argument, Scratch Register
	length         .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	width          .req r5
	mul_number     .req r6
	i              .req r7
	bitmask        .req r8
	shift          .req r9
	array_num_base .req r10

	push {r4-r10}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #28                                  @ r4-r10 offset 28 bytes
	pop {length}                                     @ Get Fourth Argument
	sub sp, sp, #32                                  @ Retrieve SP

	sub length, length, #1

	mov mul_number, #8
	mul width, length, mul_number
	add x_coord, x_coord, width

	ldr array_num_base, ARRAY_FONT_BITMAP8

	mov mul_number, #4
	mov i, #0

	print_number_8by8_loop:
		mov bitmask, #0xF                        @ 0b1111
		mul shift, i, mul_number
		lsl bitmask, bitmask, shift              @ Make bitmask
		and bitmask, number, bitmask
		lsr bitmask, bitmask, shift              @ Make One Digit Number
		mul bitmask, bitmask, mul_number

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [array_num_base, bitmask]        @ Character Pointer
		bl pict_char_8by8
		push {r1}
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0 or 1
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print_number_8by8_error

		sub x_coord, #8

		add i, i, #1

		cmp i, length
		bgt print_number_8by8_success

		cmp i, #8
		blt print_number_8by8_loop

	print_number_8by8_success:
		mov r0, #0                               @ Return with Success
		b print_number_8by8_common

	print_number_8by8_error:
		mov r0, r0                               @ Return with Error (NOP to Throw from pict_char_8by8)

	print_number_8by8_common:
		ldr r1, [sp, #-24]
		pop {r4-r10}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		/*pop {r3}*/    @ To Prevent Stack Pointer Increment after Return Because of the 5th Parameter
                                @ BUT, this increment is in charge of CALLER, not CALLEE on ARM C Lang Regulation

		mov pc, lr

.unreq number
.unreq x_coord
.unreq y_coord
.unreq color
.unreq length
.unreq width
.unreq mul_number
.unreq i
.unreq bitmask
.unreq shift
.unreq array_num_base


/**
 * function pict_char_8by8
 * Picture a 8-bit-width-8-bit-height Character
 *
 * Parameters
 * r0: Pointer of Character
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 *
 * Usage: r0-r11
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB_ADDRESS, FB_WIDTH, FB_SIZE, FB_DEPTH
 */
.globl pict_char_8by8
pict_char_8by8:
	/* Auto (Local) Variables, but just aliases */
	char_point .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord    .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord    .req r2 @ Parameter, Register for Argument, Scratch Register
	color      .req r3 @ Parameter, Register for Argument, Scratch Register
	i          .req r4
	f_buffer   .req r5 @ Pointer of Framebuffer
	width      .req r6
	depth      .req r7
	size       .req r8
	char_byte  .req r9
	j          .req r10
	bitmask    .req r11
	length     .req r12

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov i, #0                                         @ Vertical Counter
	mov length, #0                                    @ 16-Bit/ 32-Bit Color

	ldr f_buffer, FB_ADDRESS
	cmp f_buffer, #0
	beq pict_char_8by8_error2

	ldr width, FB_WIDTH
	cmp width, #0
	beq pict_char_8by8_error2

	ldr depth, FB_DEPTH
	cmp depth, #0
	beq pict_char_8by8_error2

	cmp depth, #16
	moveq length, #2                                  @ Length of a Pixel in Framebuffer (Bytes)
	cmp depth, #32
	moveq length, #4                                  @ Length of a Pixel in Framebuffer (Bytes)

	ldr size, FB_SIZE
	cmp size, #0
	beq pict_char_8by8_error2
	add size, f_buffer, size
	sub size, size, length                            @ Maximum of Framebuffer Address (Offset - 2 Bytes)

	/* Set Location to Render the Character */
	mul x_coord, x_coord, length                      @ Horizontal Offset Bytes
	add f_buffer, f_buffer, x_coord

	mul width, width, length                          @ Framebuffer Width (Bytes)
	mul y_coord, y_coord, width                       @ Vertical Offset Bytes
	add f_buffer, f_buffer, y_coord

	pict_char_8by8_loop:
		cmp f_buffer, size                        @ Check Overflow of Framebuffer Memory
		bgt pict_char_8by8_error1

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
			cmp depth, #16
			streqh color, [f_buffer]                  @ Store half word
			cmp depth, #32
			streq color, [f_buffer]                   @ Store word

			pict_char_8by8_loop_horizontal_common:
				add f_buffer, f_buffer, length    @ Framebuffer Address Shift

				cmp f_buffer, size                @ Check Overflow of Framebuffer Memory
				bgt pict_char_8by8_error1

				cmp j, #0
				bgt pict_char_8by8_loop_horizontal

		pict_char_8by8_loop_common:
			add i, i, #1
			cmp i, #8

			movge r0, #0                                    @ Return with Success
			bge pict_char_8by8_common

			add char_point, char_point, #1                  @ Horizontal Sync (Character Pointer)

			cmp depth, #16
			subeq f_buffer, f_buffer, #16                   @ Offset Clear of Framebuffer
			cmp depth, #32
			subeq f_buffer, f_buffer, #32                   @ Offset Clear of Framebuffer

			add f_buffer, f_buffer, width                   @ Horizontal Sync (Framebuffer)

			b pict_char_8by8_loop

	pict_char_8by8_error1:
		mov r0, #1                                        @ Return with Error 1
		b pict_char_8by8_common

	pict_char_8by8_error2:
		mov r0, #2                                        @ Return with Error 2

	pict_char_8by8_common:
		mov r1, f_buffer
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq char_point
.unreq x_coord
.unreq y_coord
.unreq color
.unreq i
.unreq f_buffer
.unreq width
.unreq depth
.unreq size
.unreq char_byte
.unreq j
.unreq bitmask
.unreq length
