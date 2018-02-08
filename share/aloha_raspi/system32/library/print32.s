/**
 * print32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * In some cases, I use `lsl Rd, Rm, #1` (Logical Shift Left) as Multiply Rm by Immediate #2,
 * and `lsl Rd, Rm, #2` as Multiply Rm by Immediate #4,
 * and `lsl Rd, Rm, #3` as Multiply Rm by Immediate #8 for the efficiency of CPU
 *
 * If you want to divide the number by a power of 2 (2^n), use lsr (Logical Shift Right)
 *
 */

.section	.data

/**
 * Considering security, in some case, we should not increase CPU's privilege level by SVC,
 * because the level may grant the right to access memory without any restriction. 
 * Functions in this file have possible random accesses to memory area. So, these functions should not be granted any high privilege level.
 */
.globl PRINT32_FONT_BASE
.globl PRINT32_FONT_WIDTH
.globl PRINT32_FONT_HEIGHT
.globl PRINT32_FONT_COLOR
.globl PRINT32_FONT_BACKCOLOR
PRINT32_FONT_BASE:         .word FONT_MONO_12PX_ASCII_NULL
PRINT32_FONT_WIDTH:        .word 8
PRINT32_FONT_HEIGHT:       .word 12
PRINT32_FONT_COLOR:        .word 0xFFFFFFFF
PRINT32_FONT_BACKCOLOR:    .word 0xFF000000
_print32_string_esc_count: .word 0x00

.section	.library_system32

PRINT32_FONT_BASE_ADDR:      .word PRINT32_FONT_BASE
PRINT32_FONT_WIDTH_ADDR:     .word PRINT32_FONT_WIDTH
PRINT32_FONT_HEIGHT_ADDR:    .word PRINT32_FONT_HEIGHT
PRINT32_FONT_COLOR_ADDR:     .word PRINT32_FONT_COLOR
PRINT32_FONT_BACKCOLOR_ADDR: .word PRINT32_FONT_BACKCOLOR

/**
 * function print32_set_caret
 * Set Caret Position from Return Value of `print32_number*` or `print32_string*` functions
 *
 * Parameters
 * r0: Lower of Return
 * r1: Upper of Return 
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): Y Caret Reaches Value of Height
 * Error(2): When Buffer is not Defined
 */
.globl print32_set_caret
print32_set_caret:
	/* Auto (Local) Variables, but just Aliases */
	chars             .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	xy_coord          .req r1 @ Parameter, Register for Argument, Scratch Register
	width             .req r2
	height            .req r3
	x_coord           .req r4
	y_coord           .req r5

	push {r4-r5} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	ldr width, PRINT32_FB32_WIDTH
	ldr width, [width]
	cmp width, #0
	beq print32_set_caret_error2

	ldr height, PRINT32_FB32_HEIGHT
	ldr height, [height]
	cmp height, #0
	beq print32_set_caret_error2

	mov x_coord, xy_coord, lsr #16
	mov y_coord, xy_coord, lsl #16
	lsr y_coord, y_coord, #16

	print32_set_caret_loop:
		cmp x_coord, width
		blt print32_set_caret_height
		sub x_coord, width
		add y_coord, #1 
		b print32_set_caret_loop

	print32_set_caret_height:
		cmp y_coord, height
		movge y_coord, height
		bge print32_set_caret_error1

		b print32_set_caret_success

	print32_set_caret_error1:
		mov r0, #1
		b print32_set_caret_common

	print32_set_caret_error2:
		mov r0, #2
		b print32_set_caret_common

	print32_set_caret_success:
		mov r0, #0

	print32_set_caret_common:
		.unreq width
		temp .req r2
		ldr temp, print32_set_caret_addr_x_caret
		str x_coord, [temp]
		ldr temp, print32_set_caret_addr_y_caret
		str y_coord, [temp]
		pop {r4-r5} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq chars
.unreq xy_coord
.unreq temp
.unreq height
.unreq x_coord
.unreq y_coord

print32_set_caret_addr_x_caret: .word FB32_X_CARET
print32_set_caret_addr_y_caret: .word FB32_Y_CARET


/**
 * function print32_hexa
 * Print Hexadecimal Values in Heap
 *
 * Parameters
 * r0: Pointer of Array of Bytes (Heap)
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Length of Characters, Left to Right, Need of PUSH/POP
 *
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print32_hexa
print32_hexa:
	/* Auto (Local) Variables, but just Aliases */
	byte_point        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	length            .req r3 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	color             .req r4
	back_color        .req r5
	char_width        .req r6
	char_height       .req r7
	font_ascii_base   .req r8
	byte              .req r9
	length_max        .req r10

	push {r4-r10,lr} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	ldr color, PRINT32_FONT_COLOR_ADDR
	ldr color, [color]
	ldr back_color, PRINT32_FONT_BACKCOLOR_ADDR
	ldr back_color, [back_color]
	ldr char_width, PRINT32_FONT_WIDTH_ADDR
	ldr char_width, [char_width]
	ldr char_height, PRINT32_FONT_HEIGHT_ADDR
	ldr char_height, [char_height]
	ldr font_ascii_base, PRINT32_FONT_BASE_ADDR
	ldr font_ascii_base, [font_ascii_base]

	mov length_max, #equ32_print32_hexa_length_max

	print32_hexa_loop:
		cmp length, #0                           @ `for (; length > 0; length--)`
		ble print32_hexa_success
		cmp length_max, #0                       @ `for (; length_max > 0; length_max--)`
		ble print32_hexa_success

		ldrb byte, [byte_point]                  @ Load Character Byte
		lsl byte, byte, #24

		/* Picture Hexadecimal Value */

		push {r0-r3}                             @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, byte
		mov r3, #2                               @ 2 Digits
		bl print32_number
		push {r1}
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3}                              @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_hexa_error

		ldr x_coord, [sp, #-20]
		mov y_coord, x_coord
		lsr x_coord, x_coord, #16
		lsl y_coord, y_coord, #16
		lsr y_coord, y_coord, #16

		add byte_point, byte_point, #1
		sub length, length, #1
		sub length_max, length_max, #1

		b print32_hexa_loop

	print32_hexa_success:
		mov r0, #0                                 @ Return with Success
		b print32_hexa_common

	print32_hexa_error:
		mov r0, length                             @ Return with Number of Characters Which Were Not Drawn

	print32_hexa_common:
		lsl x_coord, x_coord, #16
		add r1, x_coord, y_coord
		pop {r4-r10,pc} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

.unreq byte_point
.unreq x_coord
.unreq y_coord
.unreq length
.unreq color
.unreq back_color
.unreq char_width
.unreq char_height
.unreq font_ascii_base
.unreq byte
.unreq length_max


/**
 * function print32_string
 * Print String with 1 Byte Character
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Length of Characters, Left to Right
 *
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print32_string
print32_string:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	length            .req r3 @ Parameter, Register for Argument and Result, Scratch Register
	color             .req r4
	back_color        .req r5
	char_width        .req r6
	char_height       .req r7
	font_ascii_base   .req r8
	string_byte       .req r9
	width             .req r10
	esc_count         .req r11

	push {r4-r11,lr} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	ldr color, PRINT32_FONT_COLOR_ADDR
	ldr color, [color]
	ldr back_color, PRINT32_FONT_BACKCOLOR_ADDR
	ldr back_color, [back_color]
	ldr char_width, PRINT32_FONT_WIDTH_ADDR
	ldr char_width, [char_width]
	ldr char_height, PRINT32_FONT_HEIGHT_ADDR
	ldr char_height, [char_height]
	ldr font_ascii_base, PRINT32_FONT_BASE_ADDR
	ldr font_ascii_base, [font_ascii_base]

	ldr width, PRINT32_FB32_WIDTH
	ldr width, [width]

	ldr esc_count, print32_string_esc_count
	ldr esc_count, [esc_count]

	print32_string_loop:
		cmp length, #0                           @ `for (; length > 0; length--)`
		ble print32_string_success

		ldrb string_byte, [string_point]         @ Load Character Byte
		cmp string_byte, #0                      @ NULL Character (End of String) Checker
		beq print32_string_success               @ Break Loop if Null Character

		cmp esc_count, #0x0
		bne print32_string_loop_escape

		cmp string_byte, #0x09
		moveq string_byte, #equ32_print32_string_tab_length
		beq print32_string_loop_tab

		cmp string_byte, #0x0A
		beq print32_string_loop_linefeed

		cmp string_byte, #0x0D
		beq print32_string_loop_carriagereturn

		cmp string_byte, #0x1B
		moveq esc_count, #-1                     @ esc_count Decreases in Progress at Minus Signed Number
		beq print32_string_loop_common

		/* Clear the Block by Color */

		push {r0-r3}                             @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, back_color
		mov r3, char_width
		push {char_height} 
		bl fb32_block_color
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3}                              @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_string_error

		/* Picture String */

		lsl string_byte, string_byte, #2         @ Substitute of Multiplication by #4 (mul)

		push {r0-r3}                             @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [font_ascii_base, string_byte]   @ Character Pointer
		mov r3, color
		push {char_width,char_height}            @ Push Character Width and Hight
		bl fb32_char
		add sp, sp, #8
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3}                              @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_string_error

		add x_coord, x_coord, char_width
		cmp x_coord, width
		blt print32_string_loop_common

		print32_string_loop_linefeed:
			mov x_coord, #0
			add y_coord, y_coord, char_height
			b print32_string_loop_common

		print32_string_loop_carriagereturn:
			mov x_coord, #0
			b print32_string_loop_common

		print32_string_loop_tab:
			cmp string_byte, #0                        @ `for ( uint32 string_byte = equ32_print32_string_tab_length; string_byte > 0; string_byte-- )`
			ble print32_string_loop_common

			add x_coord, x_coord, char_width

			cmp x_coord, width
			movge x_coord, #0
			addge y_coord, y_coord, char_height

			sub string_byte, string_byte, #1
			b print32_string_loop_tab

		print32_string_loop_escape:

			/* Check Whether Character is A-Z and a-z */
			cmp string_byte, #0x41                 @ Ascii Code of A (Start of Alphabetical Characters)
			sublt esc_count, esc_count, #1
			blt print32_string_loop_common

			cmp string_byte, #0x5B                 @ Ascii Code of [ (Next of Capital Z)
			blt print32_string_loop_escape_sequence

			cmp string_byte, #0x61                 @ Ascii Code of a (0x5B through 0x60 Are Special Symbols) 
			sublt esc_count, esc_count, #1
			blt print32_string_loop_common

			cmp string_byte, #0x7B                 @ Ascii Code of { (Next of Small z)
			subge esc_count, esc_count, #1
			bge print32_string_loop_common

			print32_string_loop_escape_sequence:
				push {r0-r3}
				mvn r1, esc_count                      @ Length of String, Next of Escape Character through A-Z, a-z
				add esc_count, esc_count, #1
				add r0, string_point, esc_count        @ Next of Escape Character
				bl print32_esc_sequence
				pop {r0-r3}

				mov esc_count, #0

		print32_string_loop_common:
			add string_point, string_point, #1
			sub length, length, #1
			b print32_string_loop

	print32_string_success:
		mov r0, #0                                 @ Return with Success
		b print32_string_common

	print32_string_error:
		mov r0, length                             @ Return with Number of Characters Which Were Not Drawn

	print32_string_common:
		ldr length, print32_string_esc_count
		str esc_count, [length]
		lsl x_coord, x_coord, #16
		add r1, x_coord, y_coord
		pop {r4-r11,pc} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

.unreq string_point
.unreq x_coord
.unreq y_coord
.unreq length
.unreq color
.unreq back_color
.unreq char_width
.unreq char_height
.unreq font_ascii_base
.unreq string_byte
.unreq width
.unreq esc_count

print32_string_esc_count: .word _print32_string_esc_count


/**
 * function print32_esc_sequence
 * Escape Sequence
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Length of String
 *
 * Return: r0 (0 as sucess, 1 as error)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print32_esc_sequence
print32_esc_sequence:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	length            .req r1 @ Parameter, Register for Argument and Result, Scratch Register

	push {lr}

	print32_esc_sequence_success:
		mov r0, #0                                 @ Return with Success
		b print32_esc_sequence_common

	print32_esc_sequence_error:
		mov r0, #1                                 @ Return with Number of Characters Which Were Not Drawn

	print32_esc_sequence_common:
		pop {pc}

.unreq string_point
.unreq length


/**
 * function print32_number_double
 * Print Hexadecimal System (Base 16) Numbers in 64-bit (16 Digits)
 *
 * Parameters
 * r0: Lower Half of the Number
 * r1: Upper Half of the Number
 * r2: X Coordinate
 * r3: Y Coordinate
 * r4: length of Digits, 16 Digits Maximum, Left to Right, Need of PUSH/POP
 *
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print32_number_double
print32_number_double:
	/* Auto (Local) Variables, but just Aliases */
	number_lower      .req r0  @ Parameter, Register for Argument and Result, Scratch Register
	number_upper      .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r2  @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r3  @ Parameter, Register for Argument, Scratch Register
	length            .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length_lower      .req r5

	push {r4-r5,lr} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #12                                                    @ r4-r5,lr offset 12 bytes
	pop {length}    @ Get Fifth Argument
	sub sp, sp, #16                                                    @ Retrieve SP

	mov length_lower, #0

	print32_number_double_loop:
		cmp length, #8
		subhi length_lower, length, #8
		movhi length, #8

		/* Print Upper Half */

		push {r0-r3}                    @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, number_upper	
		mov r1, x_coord
		mov r2, y_coord
		mov r3, length
		bl print32_number
		push {r1}
		add sp, sp, #4
		cmp r0, #0                      @ Compare Return 0
		addne length, r0, length_lower
		pop {r0-r3}                     @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_number_double_error

		cmp length_lower, #0
		ble print32_number_double_success

		/* Print Lower Half */

		ldr x_coord, [sp, #-20]
		mov y_coord, x_coord
		lsr x_coord, x_coord, #16
		lsl y_coord, y_coord, #16
		lsr y_coord, y_coord, #16

		mov length, length_lower

		push {r0-r3}                    @ Equals to stmfd (stack pointer full, decrement order)	
		mov r1, x_coord
		mov r2, y_coord
		mov r3, length
		bl print32_number
		push {r1}
		add sp, sp, #4
		cmp r0, #0                      @ Compare Return 0
		movne length, r0
		pop {r0-r3}                     @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_number_double_error

	print32_number_double_success:
		mov r0, #0                                 @ Return with Success
		b print32_number_double_common

	print32_number_double_error:
		mov r0, length                             @ Return with Number of Characters Which Were Not Drawn

	print32_number_double_common:
		ldr r1, [sp, #-20]
		pop {r4-r5,pc} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

.unreq number_lower
.unreq number_upper
.unreq x_coord
.unreq y_coord
.unreq length
.unreq length_lower


/**
 * function print32_number
 * Print Hexadecimal System (Base 16) Numbers in 32-bit (8 Digits)
 *
 * Parameters
 * r0: Register to show numbers
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: length of Digits, 8 Digits Maximum, Left to Right
 *
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print32_number
print32_number:
	/* Auto (Local) Variables, but just Aliases */
	number          .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord         .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord         .req r2 @ Parameter, Register for Argument, Scratch Register
	length          .req r3 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	color           .req r4
	back_color      .req r5
	char_width      .req r6
	char_height     .req r7
	font_ascii_base .req r8
	width           .req r9
	i               .req r10
	bitmask         .req r11

	push {r4-r11,lr} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                     @ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	ldr color, PRINT32_FONT_COLOR_ADDR
	ldr color, [color]
	ldr back_color, PRINT32_FONT_BACKCOLOR_ADDR
	ldr back_color, [back_color]
	ldr char_width, PRINT32_FONT_WIDTH_ADDR
	ldr char_width, [char_width]
	ldr char_height, PRINT32_FONT_HEIGHT_ADDR
	ldr char_height, [char_height]
	ldr font_ascii_base, PRINT32_FONT_BASE_ADDR
	ldr font_ascii_base, [font_ascii_base]

	ldr width, PRINT32_FB32_WIDTH
	ldr width, [width]

	mov i, #8                                @ `for ( int i = 8; i >= 0; --i )`

	print32_number_loop:
		sub i, i, #1
		cmp i, #0
		blt print32_number_success

		/* Clear the Block by Color */

		push {r0-r3}                             @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, back_color
		mov r3, char_width
		push {char_height} 
		bl fb32_block_color
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3}                              @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_number_error

		/* Picture Number */

		mov bitmask, #0xF                        @ 0b1111
		lsl i, i, #2                             @ Substitute of Multiplication by 4
		lsl bitmask, bitmask, i                  @ Make bitmask
		and bitmask, number, bitmask
		lsr bitmask, bitmask, i                  @ Make One Digit Number
		cmp bitmask, #9
		addls bitmask, bitmask, #0x30            @ Ascii Table Number Offset
		addhi bitmask, bitmask, #0x37            @ Ascii Table Alphabet Offset - 9
		lsl bitmask, bitmask, #2                 @ Substitute of Multiplication by 4
		lsr i, i, #2                             @ Substitute of Division by 4

		push {r0-r3}                             @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [font_ascii_base, bitmask]       @ Character Pointer
		mov r3, color
		push {char_width,char_height}            @ Push Character Width and Hight
		bl fb32_char
		add sp, sp, #8
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3}                              @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_number_error

		add x_coord, char_width 

		cmp x_coord, width
		blt print32_number_loop_common

		mov x_coord, #0
		add y_coord, y_coord, char_height 

		print32_number_loop_common:
			sub length, length, #1
			cmp length, #0
			ble print32_number_success

			b print32_number_loop

	print32_number_success:
		mov r0, #0                               @ Return with Success
		b print32_number_common

	print32_number_error:
		mov r0, length                           @ Return with Number of Characters Which Were Not Drawn

	print32_number_common:
		lsl x_coord, x_coord, #16
		add r1, x_coord, y_coord
		pop {r4-r11,pc} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		/*pop {r3}*/    @ To Prevent Stack Pointer Increment after Return Because of the 5th Parameter
                        @ BUT, this increment is in charge of CALLER, not CALLEE on ARM C Lang Regulation


.unreq number
.unreq x_coord
.unreq y_coord
.unreq length
.unreq color
.unreq back_color
.unreq char_width
.unreq char_height
.unreq font_ascii_base
.unreq width
.unreq i
.unreq bitmask


PRINT32_FB32_WIDTH:  .word FB32_WIDTH
PRINT32_FB32_HEIGHT: .word FB32_HEIGHT


/**
 * function print32_debug_hexa
 * Print Hexadecimal Values in Heap for Debug Use
 *
 * Parameters
 * r0: Address of Heap to Be Shown
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Length
 *
 * Return: r0 (0 as sucess)
 */
.globl print32_debug_hexa
print32_debug_hexa:
	/* Auto (Local) Variables, but just Aliases */
	pointer           .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r1 @ Parameter, Register for Argument, Scratch Register
	y_coord           .req r2 @ Parameter, Register for Argument, Scratch Register
	length            .req r3 @ Parameter, Register for Argument, Scratch Register

	push {lr}
	
	bl print32_hexa

	pop {pc}

.unreq pointer
.unreq x_coord
.unreq y_coord
.unreq length


/**
 * function print32_debug
 * Print Number in Register for Debug Use
 *
 * Parameters
 * r0: Register to Be Shown
 * r1: X Coordinate
 * r2: Y Coordinate
 *
 * Usage: r0-r8
 * Return: r0 (0 as sucess)
 */
.globl print32_debug
print32_debug:
	/* Auto (Local) Variables, but just Aliases */
	register          .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r1 @ Parameter, Register for Argument, Scratch Register
	y_coord           .req r2 @ Parameter, Register for Argument, Scratch Register
	length            .req r3

	mov length, #8

	push {lr}
	
	bl print32_number

	pop {pc}

.unreq register
.unreq x_coord
.unreq y_coord
.unreq length

