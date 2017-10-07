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
	x_coord           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	color             .req r3
	color_back        .req r4
	length            .req r5
	char_width        .req r6
	char_height       .req r7
	font              .req r8

	push {r4-r8,lr}
	
	mvn color, #0
	mov color_back, #0xFF000000
	mov length, #8
	mov char_width, #8
	mov char_height, #12
	ldr font, print32_debug_addr_font
	ldr font, [font]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20

	pop {r4-r8,lr}

	mov pc, lr

print32_debug_addr_font: .word FONT_MONO_12PX_ASCII

.unreq register
.unreq x_coord
.unreq y_coord
.unreq color
.unreq color_back
.unreq length
.unreq char_width
.unreq char_height
.unreq font


/**
 * function print32_set_caret
 * Set Caret Position from Return Vlue of `print_number*` or `print_string*` functions
 *
 * Parameters
 * r0: Lower of Return
 * r1: Upper of Return 
 *
 * Usage: r0-r4
 * Return: r0 (Number of Characters Which Were Not Drawn)
 * Global Enviromental Variable(s): FB32_X_CARET, FB32_Y_CARET, FB32_WIDTH
 */
.globl print32_set_caret
print32_set_caret:
	/* Auto (Local) Variables, but just Aliases */
	chars             .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	xy_coord          .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	width             .req r2
	x_coord           .req r3
	y_coord           .req r4

	push {r4} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	ldr width, FB32_WIDTH

	mov x_coord, xy_coord
	lsr x_coord, x_coord, #16
	mov y_coord, xy_coord
	lsl y_coord, y_coord, #16
	lsr y_coord, y_coord, #16

	cmp x_coord, width
	blt print32_set_caret_common

	print32_set_caret_loop:
		sub x_coord, width
		add y_coord, #1 
		cmp x_coord, width
		bge print32_set_caret_loop
		
	print32_set_caret_common:
		str x_coord, FB32_X_CARET
		str y_coord, FB32_Y_CARET
		pop {r4} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq chars
.unreq xy_coord
.unreq width
.unreq x_coord
.unreq y_coord


/**
 * function print32_strindex
 * Search Second Key String in First String
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Pointer of Array of String to Be Searched (Key)
 *
 * Return: r0 (Index of First Character in String, if not -1)
 */
.globl print32_strindex
print32_strindex:
	/* Auto (Local) Variables, but just Aliases */
	string_point1      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_point2      .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	char_search        .req r2
	temp               .req r3
	increment          .req r4
	string_length2     .req r5
	string_size2       .req r6

	push {r4-r6}

	push {r0-r3,lr}
	mov r0, string_point2
	bl print32_strlen
	mov string_length2, r0
	pop {r0-r3,lr}

	add string_size2, string_point2, string_length2

	mov increment, #0

	print32_strindex_loop:
		cmp string_point2, string_size2
		subge increment, increment, string_length2     @ string_length2 May Have Zero
		bge print32_strindex_common

		ldrb char_search, [string_point2]

		add temp, string_point1, increment

		push {r0-r3,lr}
		mov r0, temp
		mov r1, char_search
		bl print32_charindex
		cmp r0, #-1                                    @ 0xFFFFFFF
		addne increment, increment, r0
		moveq increment, r0
		pop {r0-r3,lr}
		beq print32_strindex_common

		add string_point2, string_point2, #1
		add increment, increment, #1

		b print32_strindex_loop

	print32_strindex_common:
		mov r0, increment
		pop {r4-r6}
		mov pc, lr

.unreq string_point1
.unreq string_point2
.unreq char_search
.unreq temp
.unreq increment
.unreq string_length2
.unreq string_size2


/**
 * function print32_charindex
 * Search Byte Character in String
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Character to Be Searched (Key)
 *
 * Return: r0 (Index of Character, if not -1)
 */
.globl print32_charindex
print32_charindex:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	char_search       .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	char_string       .req r2
	increment         .req r3
	string_length     .req r4
	temp              .req r5

	push {r4-r5}

	push {r0-r3,lr}
	bl print32_strlen
	mov string_length, r0
	pop {r0-r3,lr}

	add string_length, string_point, string_length

	mov increment, #0

	print32_charindex_loop:
		add temp, string_point, increment
		cmp temp, string_length
		mvnge increment, #0
		bge print32_charindex_common

		ldrb char_string, [temp]
		cmp char_string, char_search
		beq print32_charindex_common

		add increment, increment, #1
		b print32_charindex_loop

	print32_charindex_common:
		mov r0, increment
		pop {r4-r5}
		mov pc, lr

.unreq string_point
.unreq char_search
.unreq char_string
.unreq increment
.unreq string_length
.unreq temp


/**
 * function print32_strcat
 * Concatenation of Two Strings
 * Caution! On the standard C Langage string.h library, strcat returns Pointer of Array of the first argument with
 * the concatenated string. That needs to have enough spaces of memory on the first one to concatenate.
 * But that makes buffer overflow easily. So in this function, print32_strcat returns new Pointer of Array.
 * Note that this function makes new memory space to be needed to make the memory free.
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Pointer of Array of String
 *
 * Usage: r0-r7
 * Return: r0 (Pointer of Concatenated String, if 0, no enough space for new Pointer of Array)
 */
.globl print32_strcat
print32_strcat:
	/* Auto (Local) Variables, but just Aliases */
	string_point1     .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_point2     .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	string_byte       .req r2
	heap_size         .req r3
	length1           .req r4
	length2           .req r5
	heap_origin       .req r6
	heap              .req r7

	push {r4-r7}

	push {r0-r3,lr}
	mov r0, string_point1
	bl print32_strlen
	mov length1, r0
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, string_point2
	bl print32_strlen
	mov length2, r0
	pop {r0-r3,lr}

	add length1, length1, length2
	add length1, length1, #1                      @ Add One for Null Character
	mov heap_size, #1

	print32_strcat_countsize:
		subs length1, length1, #4
		addgt heap_size, #1
		bgt print32_strcat_countsize

	push {r0-r3,lr}
	mov r0, heap_size
	bl system32_malloc
	mov heap_origin, r0
	pop {r0-r3,lr}

	cmp heap_origin, #0
	beq print32_strcat_common
	mov heap, heap_origin

	print32_strcat_loop1:
		ldrb string_byte, [string_point1]         @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq print32_strcat_loop2                  @ Break Loop if Null Character

		strb string_byte, [heap]                  @ Store Byte to New Pointer

		add string_point1, string_point1, #1
		add heap, heap, #1
		b print32_strcat_loop1

	print32_strcat_loop2:
		ldrb string_byte, [string_point2]         @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq print32_strcat_success                @ Break Loop if Null Character

		strb string_byte, [heap]                  @ Store Byte to New Pointer

		add string_point2, string_point2, #1
		add heap, heap, #1
		b print32_strcat_loop2

	print32_strcat_success:
		mov string_byte, #0
		strb string_byte, [heap]                  @ Make Sure to Add Null Character to the End

	print32_strcat_common:
		mov r0, heap_origin
		pop {r4-r7}
		mov pc, lr

.unreq string_point1
.unreq string_point2
.unreq string_byte
.unreq heap_size
.unreq length1
.unreq length2
.unreq heap_origin
.unreq heap


/**
 * function print32_strlen
 * Count 1-Byte Words of String
 *
 * Parameters
 * r0: Pointer of Array of String
 *
 * Usage: r0-r2
 * Return: r0 (Number of Words) Maximum of 4,294,967,295 words
 */
.globl print32_strlen
print32_strlen:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_byte       .req r1
	length            .req r2

	mov length, #0

	print32_strlen_loop:
		ldrb string_byte, [string_point]          @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq print32_strlen_common                 @ Break Loop if Null Character

		add string_point, string_point, #1
		add length, length, #1
		b print32_strlen_loop

	print32_strlen_common:
		mov r0, length
		mov pc, lr

.unreq string_point
.unreq string_byte
.unreq length


/**
 * function print32_string
 * Print String with 1 Byte Character
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 * r4: Background Color (16-bit or 32-bit)
 * r5: Length of Characters, Left to Right, Need of PUSH/POP
 * r6: Character Width in Pixels
 * r7: Character Height in Pixels
 * r8: Font Set Base to Picture Character
 *
 * Usage: r0-r11
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 * Global Enviromental Variable(s): ARRAY_ASCII_FONT_BITMAP8, FB32_WIDTH
 */
.globl print32_string
print32_string:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	color             .req r3 @ Parameter, Register for Argument and Result, Scratch Register
	back_color        .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length            .req r5 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width        .req r6 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height       .req r7 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	font_ascii_base   .req r8 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	string_byte       .req r9
	width             .req r10
	tab_length        .req r11

	push {r4-r11} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #32                                                @ r4-r11 offset 32 bytes
	pop {back_color,length,char_width,char_height,font_ascii_base} @ Get Fifth to Eighth Arguments
	sub sp, sp, #52                                                @ Retrieve SP

	ldr width, FB32_WIDTH

	print32_string_loop:
		cmp length, #0                           @ `for (; length > 0; length--)`
		ble print32_string_success

		ldrb string_byte, [string_point]         @ Load Character Byte
		cmp string_byte, #0                      @ NULL Character (End of String) Checker
		beq print32_string_success               @ Break Loop if Null Character

		cmp string_byte, #0x09
		moveq tab_length, #equ32_tab_length
		beq print32_string_loop_tab

		cmp string_byte, #0x0A
		beq print32_string_loop_linefeed

		/* Clear the Block by Color */

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, back_color
		mov r3, char_width
		push {char_height} 
		bl fb32_clear_color_block
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_string_error

		/* Picture String */

		lsl string_byte, string_byte, #2         @ Substitute of Multiplication by #4 (mul)

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [font_ascii_base, string_byte]   @ Character Pointer
		push {char_width,char_height}            @ Push Character Width and Hight
		bl print32_char
		add sp, sp, #8
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_string_error

		add x_coord, x_coord, char_width
		cmp x_coord, width
		blt print32_string_loop_common

		print32_string_loop_linefeed:
			mov x_coord, #0
			add y_coord, y_coord, char_height
			b print32_string_loop_common

		print32_string_loop_tab:
			cmp tab_length, #0               @ `for (; tab_length > 0; tab_length--)`
			ble print32_string_loop_common

			add x_coord, x_coord, char_width

			cmp x_coord, width
			movge x_coord, #0
			addge y_coord, y_coord, char_height

			sub tab_length, tab_length, #1
			b print32_string_loop_tab

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
		lsl x_coord, x_coord, #16
		add r1, x_coord, y_coord
		pop {r4-r11} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq string_point
.unreq x_coord
.unreq y_coord
.unreq color
.unreq back_color
.unreq length
.unreq char_width
.unreq char_height
.unreq font_ascii_base
.unreq string_byte
.unreq width
.unreq tab_length


/**
 * function print32_number_double
 * Print Hexadecimal System (Base 16) Numbers in 64-bit (16 Digits)
 *
 * Parameters
 * r0: Lower Half of the Number
 * r1: Upper Half of the Number
 * r2: X Coordinate
 * r3: Y Coordinate
 * r4: Color (16-bit or 32-bit), Need of PUSH/POP
 * r5: Background Color (16-bit or 32-bit)
 * r6: length of Digits, 16 Digits Maximum, Left to Right, Need of PUSH/POP
 * r7: Character Width in Pixels
 * r8: Character Height in Pixels
 * r9: Font Set Base to Picture Numbers
 *
 * Usage: r0-r11
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
	color             .req r4  @ Parameter, have to PUSH/POP in ARM C lang Regulation
	back_color        .req r5  @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length            .req r6  @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width        .req r7  @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height       .req r8  @ Parameter, have to PUSH/POP in ARM C lang Regulation
	font_num_base     .req r9  @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length_lower      .req r10
	xy_coord          .req r11

	push {r4-r11} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #32                                                    @ r4-r11 offset 32 bytes
	pop {color,back_color,length,char_width,char_height,font_num_base} @ Get Fifth to Nineth Argument
	sub sp, sp, #56                                                    @ Retrieve SP

	mov length_lower, #0

	print32_number_double_loop:
		cmp length, #8
		subgt length_lower, length, #8
		movgt length, #8

		/* Print Upper Half */

		push {r0-r3,lr}                    @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, number_upper	
		mov r1, x_coord
		mov r2, y_coord
		mov r3, color
		push {back_color,length,char_width,char_height,font_num_base}
		bl print32_number
		add sp, sp, #20
		push {r1}
		add sp, sp, #4
		cmp r0, #0                         @ Compare Return 0
		addne length, r0, length_lower
		pop {r0-r3,lr}                     @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_number_double_error

		cmp length_lower, #0
		ble print32_number_double_success

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
		push {back_color,length,char_width,char_height,font_num_base}
		bl print32_number
		add sp, sp, #20
		push {r1}
		add sp, sp, #4
		cmp r0, #0                         @ Compare Return 0
		movne length, r0
		pop {r0-r3,lr}                     @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_number_double_error

	print32_number_double_success:
		mov r0, #0                                 @ Return with Success
		b print32_number_double_common

	print32_number_double_error:
		mov r0, length                             @ Return with Number of Characters Which Were Not Drawn

	print32_number_double_common:
		ldr r1, [sp, #-24]
		pop {r4-r11} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq number_lower
.unreq number_upper
.unreq x_coord
.unreq y_coord
.unreq color
.unreq back_color
.unreq length
.unreq char_width
.unreq char_height
.unreq font_num_base
.unreq length_lower
.unreq xy_coord


/**
 * function print32_number
 * Print Hexadecimal System (Base 16) Numbers in 32-bit (8 Digits)
 *
 * Parameters
 * r0: Register to show numbers
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 * r4: Background Color (16-bit or 32-bit)
 * r5: length of Digits, 8 Digits Maximum, Left to Right, Need of PUSH/POP
 * r6: Character Width in Pixels
 * r7: Character Height in Pixels
 * r8: Font Set Base to Picture Numbers
 *
 * Usage: r0-r12
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print32_number
print32_number:
	/* Auto (Local) Variables, but just Aliases */
	number         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord        .req r2 @ Parameter, Register for Argument, Scratch Register
	color          .req r3 @ Parameter, Register for Argument, Scratch Register
	back_color     .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length         .req r5 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width     .req r6 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height    .req r7 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	font_num_base  .req r8 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	width          .req r9
	i              .req r10
	bitmask        .req r11
	shift          .req r12

	push {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			 @ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                              @ r4-r11 offset 32 bytes
	pop {back_color,length,char_width,char_height,font_num_base} @ Get Fifth to Eighth Arguments
	sub sp, sp, #52                                              @ Retrieve SP

	ldr width, FB32_WIDTH

	mov i, #8                                        @ `for ( int i = 8; i >= 0; --i )`

	print32_number_loop:
		sub i, i, #1
		cmp i, #0
		blt print32_number_success

		/* Clear the Block by Color */

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, back_color
		mov r3, char_width
		push {char_height} 
		bl fb32_clear_color_block
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_number_error

		/* Picture Number */

		mov bitmask, #0xF                        @ 0b1111
		lsl shift, i, #2                         @ Substitute of Multiplication by #4 (mul)
		lsl bitmask, bitmask, shift              @ Make bitmask
		and bitmask, number, bitmask
		lsr bitmask, bitmask, shift              @ Make One Digit Number
		cmp bitmask, #9
		addle bitmask, bitmask, #0x30            @ Ascii Table Number Offset
		addgt bitmask, bitmask, #0x37            @ Ascii Table Alphabet Offset - 9
		lsl bitmask, bitmask, #2                 @ Substitute of Multiplication by #4 (mul)

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [font_num_base, bitmask]         @ Character Pointer
		push {char_width,char_height}            @ Push Character Width and Hight
		bl print32_char
		add sp, sp, #8
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
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
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		/*pop {r3}*/    @ To Prevent Stack Pointer Increment after Return Because of the 5th Parameter
                                @ BUT, this increment is in charge of CALLER, not CALLEE on ARM C Lang Regulation

		mov pc, lr

.unreq number
.unreq x_coord
.unreq y_coord
.unreq color
.unreq back_color
.unreq length
.unreq char_width
.unreq char_height
.unreq font_num_base
.unreq width
.unreq i
.unreq bitmask
.unreq shift


/**
 * function print32_char
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
 * Return: r0 (0 as sucess, 1 and 2 as error)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 * Global Enviromental Variable(s): FB32_ADDR, FB32_WIDTH, FB32_SIZE, FB32_DEPTH
 */
.globl print32_char
print32_char:
	/* Auto (Local) Variables, but just Aliases */
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

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                  @ r4-r11 offset 32 bytes
	pop {char_width,char_height}                     @ Get Fifth and Sixth Arguments
	sub sp, sp, #40                                  @ Retrieve SP

	ldr f_buffer, FB32_ADDR
	cmp f_buffer, #0
	beq print32_char_error2

	ldr width, FB32_WIDTH
	cmp width, #0
	beq print32_char_error2

	ldr depth, FB32_DEPTH
	cmp depth, #0
	beq print32_char_error2
	cmp depth, #32
	cmpne depth, #16
	bne print32_char_error2

	ldr size, FB32_SIZE
	cmp size, #0
	beq print32_char_error2
	add size, f_buffer, size

	cmp depth, #16
	lsleq width, width, #1                           @ Vertical Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	lsleq width, width, #2                           @ Vertical Offset Bytes, substitution of Multiplication by 4

	/* Set Location to Render the Character */

	cmp y_coord, #0                                  @ If Value of y_coord is Signed Minus
	addlt char_height, char_height, y_coord          @ Subtract y_coord Value from char_height
	sublt char_point, char_point, y_coord            @ Add y_coord Value to char_point
	mulge y_coord, width, y_coord                    @ Vertical Offset Bytes, Rd should not be Rm in `MUL` from Warning
	addge f_buffer, f_buffer, y_coord
	
	.unreq y_coord
	width_check .req r2                              @ Store the Limitation of Width on this Y Coordinate

	mov width_check, f_buffer
	add width_check, width

	cmp x_coord, #0                                  @ If Value of x_coord is Signed Minus
	addlt char_width, char_width, x_coord            @ Subtract x_coord Value from char_width
	blt print32_char_loop
	
	cmp depth, #16
	lsleq x_coord, x_coord, #1                       @ Horizontal Offset Bytes, substitution of Multiplication by 2
	cmp depth, #32
	lsleq x_coord, x_coord, #2                       @ Horizontal Offset Bytes, substitution of Multiplication by 4
	add f_buffer, f_buffer, x_coord                  @ Horizontal Offset Bytes

	.unreq x_coord
	bitmask .req r1

	print32_char_loop:

		cmp char_height, #0                          @ Vertical Counter `(; char_height > 0; char_height--)`
		ble print32_char_success

		cmp f_buffer, size                           @ Check Overflow of Framebuffer Memory
		bge print32_char_error1

		ldrb char_byte, [char_point]                 @ Load Horizontal Byte
		mov j, char_width                            @ Horizontal Counter `(int j = char_width; j >= 0; --j)`

		print32_char_loop_horizontal:
			sub j, j, #1                             @ For Bit Allocation (Horizontal Character Bit)
			cmp j, #0                                @ Horizontal Counter, Check
			blt print32_char_loop_common

			mov bitmask, #1
			lsl bitmask, bitmask, j                  @ Logical Shift Left to Make Bit Mask for Current Character Bit
			and bitmask, char_byte, bitmask

			cmp bitmask, #0
			beq print32_char_loop_horizontal_common

			/* The Picture Process */
			cmp depth, #16
			streqh color, [f_buffer]                   @ Store half word
			cmp depth, #32
			streq color, [f_buffer]                    @ Store word

			print32_char_loop_horizontal_common:
				cmp depth, #16
				addeq f_buffer, f_buffer, #2       @ Framebuffer Address Shift
				cmp depth, #32
				addeq f_buffer, f_buffer, #4       @ Framebuffer Address Shift

				cmp f_buffer, width_check          @ Check Overflow of Width
				blt print32_char_loop_horizontal

				cmp depth, #16
				lsleq j, j, #1                     @ substitution of Multiplication by 2
				cmp depth, #32
				lsleq j, j, #2                     @ substitution of Multiplication by 4
				add f_buffer, f_buffer, j          @ Framebuffer Offset

		print32_char_loop_common:
			sub char_height, char_height, #1

			add char_point, char_point, #1           @ Horizontal Sync (Character Pointer)

			cmp depth, #16
			lsleq j, char_width, #1                  @ substitution of Multiplication by 2
			cmp depth, #32
			lsleq j, char_width, #2                  @ substitution of Multiplication by 4
			sub f_buffer, f_buffer, j                @ Offset Clear of Framebuffer

			add f_buffer, f_buffer, width            @ Horizontal Sync (Framebuffer)

			add width_check, width_check, width      @ Store the Limitation of Width on the Next Y Coordinate

			b print32_char_loop

	print32_char_error1:
		mov r0, #1                                   @ Return with Error 1
		b print32_char_common

	print32_char_error2:
		mov r0, #2                                   @ Return with Error 2
		b print32_char_common

	print32_char_success:
		mov r0, #0                                   @ Return with Success

	print32_char_common:
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			            @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number
		mov pc, lr

.unreq char_point
.unreq bitmask
.unreq width_check
.unreq color
.unreq char_width
.unreq char_height
.unreq f_buffer
.unreq width
.unreq depth
.unreq size
.unreq char_byte
.unreq j
