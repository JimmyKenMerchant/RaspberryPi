/**
 * print_char32.s
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

/**
 * function set_caret
 * Set Caret Position from Return Vlue of `print_*` functions
 *
 * Parameters
 * r0: Lower of Return
 * r1: Upper of Return 
 *
 * Usage: r0-r4
 * Return: r0 (Number of Characters Which Were Not Drawn)
 * Global Enviromental Variable(s): FB_X_CARET, FB_Y_CARET, FB_WIDTH
 */
.globl set_caret
set_caret:
	/* Auto (Local) Variables, but just aliases */
	chars             .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	xy_coord          .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	width             .req r2
	x_coord           .req r3
	y_coord           .req r4

	push {r4} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	ldr width, FB_WIDTH

	mov x_coord, xy_coord
	lsr x_coord, x_coord, #16
	mov y_coord, xy_coord
	lsl y_coord, y_coord, #16
	lsr y_coord, y_coord, #16

	cmp x_coord, width
	blt set_caret_common

	set_caret_loop:
		sub x_coord, width
		add y_coord, #1 
		cmp x_coord, width
		bge set_caret_loop
		
	set_caret_common:
		str x_coord, FB_X_CARET
		str y_coord, FB_Y_CARET
		pop {r4} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq chars
.unreq xy_coord
.unreq width
.unreq x_coord
.unreq y_coord


/**
 * function strlen
 * Count 1-Byte Words of String
 *
 * Parameters
 * r0: Pointer of Array of String
 *
 * Usage: r0-r2
 * Return: r0 (Number of Words) Maximum of 4,294,967,295 words
 */
.globl strlen
strlen:
	/* Auto (Local) Variables, but just aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_byte       .req r1
	length            .req r2

	mov length, #0

	strlen_loop:
		ldrb string_byte, [string_point]          @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq strlen_common                         @ Break Loop if Null Character

		add string_point, string_point, #1
		add length, length, #1
		b strlen_loop

	strlen_common:
		mov r0, length
		mov pc, lr

.unreq string_point
.unreq string_byte
.unreq length


/**
 * function print_string
 * Print String with 1 Byte Character
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 * r4: Length of Characters, Left to Right, Need of PUSH/POP
 * r5: Character Width in Pixels
 * r6: Character Height in Pixels
 * r7: Font Set Base to Picture Character
 *
 * Usage: r0-r10
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 * Global Enviromental Variable(s): ARRAY_ASCII_FONT_BITMAP8, FB_WIDTH
 */
.globl print_string
print_string:
	/* Auto (Local) Variables, but just aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	color             .req r3 @ Parameter, Register for Argument and Result, Scratch Register
	length            .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width        .req r5 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height       .req r6 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	font_ascii_base   .req r7 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	string_byte       .req r8
	width             .req r9
	tab_length        .req r10

	push {r4-r10} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #28                                     @ r4-r10 offset 28 bytes
	pop {length,char_width,char_height,font_ascii_base} @ Get Fifth to Eighth Arguments
	sub sp, sp, #44                                     @ Retrieve SP

	ldr width, FB_WIDTH

	mov tab_length, #4

	print_string_loop:
		ldrb string_byte, [string_point]          @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq print_string_success            @ Break Loop if Null Character

		cmp string_byte, #0x09
		beq print_string_loop_tab

		cmp string_byte, #0x0A
		beq print_string_loop_linefeed

		lsl string_byte, string_byte, #2          @ Substitute of Multiplication by #4 (mul)

		push {r0-r3,lr}                           @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [font_ascii_base, string_byte]    @ Character Pointer
		push {char_width,char_height}             @ Push Character Width and Hight
		bl pict_char
		add sp, sp, #8
		push {r1}
		add sp, sp, #4
		cmp r0, #0                                @ Compare Return 0 or 1
		pop {r0-r3,lr}                            @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print_string_error

		add x_coord, x_coord, char_width
		cmp x_coord, width
		blt print_string_loop_common

		print_string_loop_linefeed:
			mov x_coord, #0
			add y_coord, y_coord, char_height
			b print_string_loop_common

		print_string_loop_tab:
			add x_coord, x_coord, char_width
			cmp x_coord, width
			movge x_coord, #0
			addge y_coord, y_coord, char_height
			sub tab_length, tab_length, #1
			cmp tab_length, #0
			bgt print_string_loop_tab

		print_string_loop_common:
			add string_point, string_point, #1
			sub length, length, #1
			cmp length, #0
			bgt print_string_loop

	print_string_success:
		mov r0, #0                                 @ Return with Success
		b print_string_common

	print_string_error:
		mov r0, length                             @ Return with Number of Characters Which Were Not Drawn

	print_string_common:
		lsl x_coord, x_coord, #16
		add r1, x_coord, y_coord
		pop {r4-r10} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq string_point
.unreq x_coord
.unreq y_coord
.unreq color
.unreq length
.unreq char_width
.unreq char_height
.unreq font_ascii_base
.unreq string_byte
.unreq width
.unreq tab_length


/**
 * function double_print_number
 * Print Hexadecimal Bases Numbers in 64-bit (16 Digits)
 *
 * Parameters
 * r0: Lower Half of the Number
 * r1: Upper Half of the Number
 * r2: X Coordinate
 * r3: Y Coordinate
 * r4: Color (16-bit or 32-bit), Need of PUSH/POP
 * r5: length of Digits, 16 Digits Maximum, Left to Right, Need of PUSH/POP
 * r6: Character Width in Pixels
 * r7: Character Height in Pixels
 * r8: Font Set Base to Picture Numbers
 *
 * Usage: r0-r10
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl double_print_number
double_print_number:
	/* Auto (Local) Variables, but just aliases */
	number_lower      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	number_upper      .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r3 @ Parameter, Register for Argument, Scratch Register
	color             .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length            .req r5 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width        .req r6 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height       .req r7 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	font_num_base     .req r8 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length_lower      .req r9
	xy_coord          .req r10

	push {r4-r10} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #28                                         @ r4-r10 offset 28 bytes
	pop {color,length,char_width,char_height,font_num_base} @ Get Fifth to Nineth Argument
	sub sp, sp, #48                                         @ Retrieve SP

	mov length_lower, #0

	double_print_number_loop:
		cmp length, #8
		subgt length_lower, length, #8
		movgt length, #8

		/* Print Upper Half */

		push {r0-r3,lr}                    @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, number_upper	
		mov r1, x_coord
		mov r2, y_coord
		mov r3, color
		push {length,char_width,char_height,font_num_base}
		bl print_number
		add sp, sp, #16
		push {r1}
		add sp, sp, #4
		cmp r0, #0                         @ Compare Return 0 or 1
		addne length, r0, length_lower
		pop {r0-r3,lr}                     @ Retrieve Registers Before Error Check, POP does not flags-update
		bne double_print_number_error

		cmp length_lower, #0
		ble double_print_number_success

		/* Print Lower Half */

		ldr xy_coord, [sp, #-24]
		mov x_coord, xy_coord
		lsr x_coord, x_coord, #16
		mov y_coord, xy_coord
		lsl y_coord, y_coord, #16
		lsr y_coord, y_coord, #16

		mov length, length_lower

		push {r0-r3,lr}                    @ Equals to stmfd (stack pointer full, decrement order)	
		mov r1, x_coord
		mov r2, y_coord
		mov r3, color
		push {length,char_width,char_height,font_num_base}
		bl print_number
		add sp, sp, #16
		push {r1}
		add sp, sp, #4
		cmp r0, #0                         @ Compare Return 0 or 1
		movne length, r0
		pop {r0-r3,lr}                     @ Retrieve Registers Before Error Check, POP does not flags-update
		bne double_print_number_error

	double_print_number_success:
		mov r0, #0                                 @ Return with Success
		b double_print_number_common

	double_print_number_error:
		mov r0, length                             @ Return with Number of Characters Which Were Not Drawn

	double_print_number_common:
		ldr r1, [sp, #-24]
		pop {r4-r10} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq number_lower
.unreq number_upper
.unreq x_coord
.unreq y_coord
.unreq color
.unreq length
.unreq char_width
.unreq char_height
.unreq font_num_base
.unreq length_lower
.unreq xy_coord


/**
 * function print_number
 * Print Hexadecimal Bases Numbers in 32-bit (8 Digits)
 *
 * Parameters
 * r0: Register to show numbers
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 * r4: length of Digits, 8 Digits Maximum, Left to Right, Need of PUSH/POP
 * r5: Character Width in Pixels
 * r6: Character Height in Pixels
 * r7: Font Set Base to Picture Numbers
 *
 * Usage: r0-r11
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print_number
print_number:
	/* Auto (Local) Variables, but just aliases */
	number         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord        .req r2 @ Parameter, Register for Argument, Scratch Register
	color          .req r3 @ Parameter, Register for Argument, Scratch Register
	length         .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width     .req r5 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height    .req r6 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	font_num_base  .req r7 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	width          .req r8
	i              .req r9
	bitmask        .req r10
	shift          .req r11

	push {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                    @ r4-r11 offset 32 bytes
	pop {length,char_width,char_height,font_num_base}  @ Get Fifth to Eighth Arguments
	sub sp, sp, #48                                    @ Retrieve SP

	ldr width, FB_WIDTH

	mov i, #8

	print_number_loop:
		sub i, i, #1

		mov bitmask, #0xF                        @ 0b1111
		lsl shift, i, #2                         @ Substitute of Multiplication by #4 (mul)
		lsl bitmask, bitmask, shift              @ Make bitmask
		and bitmask, number, bitmask
		lsr bitmask, bitmask, shift              @ Make One Digit Number
		lsl bitmask, bitmask, #2                 @ Substitute of Multiplication by #4 (mul)

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [font_num_base, bitmask]         @ Character Pointer
		push {char_width,char_height}            @ Push Character Width and Hight
		bl pict_char
		add sp, sp, #8
		push {r1}
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0 or 1
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print_number_error

		add x_coord, char_width 

		cmp x_coord, width
		blt print_number_loop_common

		mov x_coord, #0
		add y_coord, y_coord, char_height 

		print_number_loop_common:
			sub length, length, #1
			cmp length, #0
			ble print_number_success

			cmp i, #0
			bgt print_number_loop

	print_number_success:
		mov r0, #0                               @ Return with Success
		b print_number_common

	print_number_error:
		mov r0, length                           @ Return with Number of Characters Which Were Not Drawn

	print_number_common:
		lsl x_coord, x_coord, #16
		add r1, x_coord, y_coord
		pop {r4-r11}     @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		/*pop {r3}*/    @ To Prevent Stack Pointer Increment after Return Because of the 5th Parameter
                                @ BUT, this increment is in charge of CALLER, not CALLEE on ARM C Lang Regulation

		mov pc, lr

.unreq number
.unreq x_coord
.unreq y_coord
.unreq color
.unreq length
.unreq char_width
.unreq char_height
.unreq font_num_base
.unreq width
.unreq i
.unreq bitmask
.unreq shift


/**
 * function pict_char
 * Picture a Character
 *
 * Parameters
 * r0: Pointer of Character
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 * r4: Character Width in Pixels
 * r5: Character Height in Pixels
 *
 * Usage: r0-r12
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB_ADDRESS, FB_WIDTH, FB_SIZE, FB_DEPTH
 */
.globl pict_char
pict_char:
	/* Auto (Local) Variables, but just aliases */
	char_point  .req r0  @ Parameter, Register for Argument and Result, Scratch Register
	x_coord     .req r1  @ Parameter, Register for Argument and Result, Scratch Register
	y_coord     .req r2  @ Parameter, Register for Argument, Scratch Register
	color       .req r3  @ Parameter, Register for Argument, Scratch Register
	char_width  .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Use for Vertical Counter
	char_height .req r5  @ Parameter, have to PUSH/POP in ARM C lang Regulation, Horizontal Counter Reserved Number
	f_buffer    .req r6  @ Pointer of Framebuffer
	width       .req r7
	depth       .req r8
	size        .req r9
	char_byte   .req r10
	j           .req r11 @ Use for Horizontal Counter
	bitmask     .req r12

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {char_width,char_height}                     @ Get Fifth and Sixth Arguments
	sub sp, sp, #40                                  @ Retrieve SP

	ldr f_buffer, FB_ADDRESS
	cmp f_buffer, #0
	beq pict_char_error2

	ldr width, FB_WIDTH
	cmp width, #0
	beq pict_char_error2

	ldr depth, FB_DEPTH
	cmp depth, #0
	beq pict_char_error2
	cmp depth, #32
	cmpne depth, #16
	bne pict_char_error2

	ldr size, FB_SIZE
	cmp size, #0
	beq pict_char_error2
	add size, f_buffer, size

	cmp depth, #16
	subeq size, size, #2                             @ Maximum of Framebuffer Address (Offset - 2 Bytes)
	cmp depth, #32
	subeq size, size, #4                             @ Maximum of Framebuffer Address (Offset - 4 bytes)

	/* Set Location to Render the Character */

	cmp depth, #16
	lsleq x_coord, x_coord, #1                       @ Horizontal Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	lsleq x_coord, x_coord, #2                       @ Horizontal Offset Bytes, substitution of Multiplication by 4
	add f_buffer, f_buffer, x_coord                  @ Horizontal Offset Bytes

	cmp depth, #16
	lsleq width, width, #1                           @ Vertical Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	lsleq width, width, #2                           @ Vertical Offset Bytes, substitution of Multiplication by 4
	mul y_coord, width, y_coord                      @ Vertical Offset Bytes, Rd should not be Rm in `MUL` from Warning
	add f_buffer, f_buffer, y_coord

	pict_char_loop:
		cmp f_buffer, size                           @ Check Overflow of Framebuffer Memory
		bgt pict_char_error1

		ldrb char_byte, [char_point]                 @ Load Horizontal Byte
		mov j, char_width                            @ Horizontal Counter

		pict_char_loop_horizontal:
			sub j, j, #1                             @ For Bit Allocation (Horizontal Character Bit)
			mov bitmask, #1
			lsl bitmask, bitmask, j                  @ Logical Shift Left to Make Bit Mask for Current Character Bit

			and bitmask, char_byte, bitmask
			cmp bitmask, #0
			beq pict_char_loop_horizontal_common

			/* The Picture Process */
			cmp depth, #16
			streqh color, [f_buffer]                 @ Store half word
			cmp depth, #32
			streq color, [f_buffer]                  @ Store word

			pict_char_loop_horizontal_common:
				cmp depth, #16
				addeq f_buffer, f_buffer, #2         @ Framebuffer Address Shift
				cmp depth, #32
				addeq f_buffer, f_buffer, #4         @ Framebuffer Address Shift

				cmp f_buffer, size                   @ Check Overflow of Framebuffer Memory
				bgt pict_char_error1

				cmp j, #0                            @ Horizontal Counter, Check
				bgt pict_char_loop_horizontal

		pict_char_loop_common:
			sub char_height, char_height, #1
			cmp char_height, #0                      @ Vertical Counter, Check

			movle r0, #0                             @ Return with Success
			ble pict_char_common

			add char_point, char_point, #1           @ Horizontal Sync (Character Pointer)

			cmp depth, #16
			subeq f_buffer, f_buffer, #16            @ Offset Clear of Framebuffer
			cmp depth, #32
			subeq f_buffer, f_buffer, #32            @ Offset Clear of Framebuffer

			add f_buffer, f_buffer, width            @ Horizontal Sync (Framebuffer)

			b pict_char_loop

	pict_char_error1:
		mov r0, #1                                   @ Return with Error 1
		b pict_char_common

	pict_char_error2:
		mov r0, #2                                   @ Return with Error 2

	pict_char_common:
		mov r1, f_buffer
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq char_point
.unreq x_coord
.unreq y_coord
.unreq color
.unreq char_width
.unreq char_height
.unreq f_buffer
.unreq width
.unreq depth
.unreq size
.unreq char_byte
.unreq j
.unreq bitmask

