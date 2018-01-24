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
	color             .req r3 @ Parameter, Register for Argument, Scratch Register
	color_back        .req r4
	length            .req r5
	char_width        .req r6
	char_height       .req r7
	font              .req r8

	push {r4-r8,lr}
	
	mov length, color

	mvn color, #0
	mov color_back, #0xFF000000
	mov char_width, #8
	mov char_height, #12
	ldr font, print32_debug_hexa_addr_font
	ldr font, [font]
	push {r4-r8}
	bl print32_hexa
	add sp, sp, #20

	pop {r4-r8,pc}

print32_debug_hexa_addr_font: .word FONT_MONO_12PX_ASCII

.unreq pointer
.unreq x_coord
.unreq y_coord
.unreq color
.unreq color_back
.unreq length
.unreq char_width
.unreq char_height
.unreq font


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

	pop {r4-r8,pc}

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
 * function print32_strindex
 * Search Second Key String in First String
 *
 * Parameters
 * r0: Pointer of Array of String to Be Subjected
 * r1: Pointer of Array of String to Be Searched (Key)
 *
 * Return: r0 (Index of First Character in String, if not -1)
 */
.globl print32_strindex
print32_strindex:
	/* Auto (Local) Variables, but just Aliases */
	string_point1      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_point2      .req r1 @ Parameter, Register for Argument, Scratch Register
	char_search        .req r2
	search_length      .req r3
	string_length1     .req r4
	string_length2     .req r5
	string_size2       .req r6
	increment          .req r7

	push {r4-r7,lr}

	push {r0-r3}
	bl print32_strlen
	mov string_length1, r0
	pop {r0-r3}

	push {r0-r3}
	mov r0, string_point2
	bl print32_strlen
	mov string_length2, r0
	pop {r0-r3}

	add string_size2, string_point2, string_length2

	mov increment, #0
	mov search_length, string_length1                 @ For First Character of Key

	print32_strindex_loop:
		cmp string_point2, string_size2
		subhs increment, increment, string_length2     @ string_length2 May Have Zero
		bhs print32_strindex_common

		cmp increment, string_length1
		mvnhs increment, #0
		bhs print32_strindex_common

		ldrb char_search, [string_point2]

		push {r0-r3}
		add r0, string_point1, increment
		mov r1, search_length
		mov r2, char_search
		bl print32_charsearch
		cmp r0, #-1                                    @ 0xFFFFFFF
		addne increment, increment, r0
		pop {r0-r3}
		mvneq increment, #0
		beq print32_strindex_common

		add string_point2, string_point2, #1
		add increment, increment, #1
		mov search_length, #1                          @ After Search and Hit First Character of Key 

		b print32_strindex_loop

	print32_strindex_common:
		mov r0, increment
		pop {r4-r7,pc}

.unreq string_point1
.unreq string_point2
.unreq char_search
.unreq search_length
.unreq string_length1
.unreq string_length2
.unreq string_size2
.unreq increment


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
	char_search       .req r1 @ Parameter, Register for Argument, Scratch Register
	char_string       .req r2
	increment         .req r3
	string_length     .req r4

	push {r4,lr}

	push {r0-r3}
	bl print32_strlen
	mov string_length, r0
	pop {r0-r3}

	mov increment, #0

	print32_charindex_loop:
		cmp increment, string_length
		mvnhs increment, #0
		bhs print32_charindex_common

		ldrb char_string, [string_point, increment]
		cmp char_string, char_search
		beq print32_charindex_common

		add increment, increment, #1
		b print32_charindex_loop

	print32_charindex_common:
		mov r0, increment
		pop {r4,pc}

.unreq string_point
.unreq char_search
.unreq char_string
.unreq increment
.unreq string_length


/**
 * function print32_charsearch
 * Search Byte Character in String within Range
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Length of Array
 * r2: Character to Be Searched (Key)
 *
 * Return: r0 (Index of Character, if not -1)
 */
.globl print32_charsearch
print32_charsearch:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_length     .req r1 @ Parameter, Register for Argument, Scratch Register
	char_search       .req r2 @ Parameter, Register for Argument, Scratch Register
	char_string       .req r3
	increment         .req r4

	push {r4}

	mov increment, #0

	print32_charsearch_loop:
		cmp increment, string_length
		mvnhs increment, #0
		bhs print32_charsearch_common

		ldrb char_string, [string_point, increment]
		cmp char_string, char_search
		beq print32_charsearch_common

		add increment, increment, #1
		b print32_charsearch_loop

	print32_charsearch_common:
		mov r0, increment
		pop {r4}
		mov pc, lr

.unreq string_point
.unreq string_length
.unreq char_search
.unreq char_string
.unreq increment


/**
 * function print32_strsearch
 * Search Second Key String in First String within Range
 *
 * Parameters
 * r0: Pointer of Array of String to Be Subjected
 * r1: Length of String to Be Subjected
 * r2: Pointer of Array of String to Be Searched (Key)
 * r3: Length 0f String to Be Searched (Key)
 *
 * Return: r0 (Index of First Character in String, if not -1)
 */
.globl print32_strsearch
print32_strsearch:
	/* Auto (Local) Variables, but just Aliases */
	string_point1      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_length1     .req r1 @ Parameter, Register for Argument, Scratch Register
	string_point2      .req r2
	string_length2     .req r3
	char_search        .req r4
	search_length      .req r5
	string_size2       .req r6
	increment          .req r7

	push {r4-r7,lr}

	add string_size2, string_point2, string_length2

	mov increment, #0
	mov search_length, string_length1                 @ For First Character of Key

	print32_strsearch_loop:
		cmp string_point2, string_size2
		subhs increment, increment, string_length2     @ string_length2 May Have Zero
		bhs print32_strsearch_common

		cmp increment, string_length1
		mvnhs increment, #0
		bhs print32_strsearch_common

		ldrb char_search, [string_point2]

		push {r0-r3}
		add r0, string_point1, increment
		mov r1, search_length
		mov r2, char_search
		bl print32_charsearch
		cmp r0, #-1                                    @ 0xFFFFFFF
		addne increment, increment, r0
		pop {r0-r3}
		mvneq increment, #0
		beq print32_strsearch_common

		add string_point2, string_point2, #1
		add increment, increment, #1
		mov search_length, #1                          @ After Search and Hit First Character of Key 

		b print32_strsearch_loop

	print32_strsearch_common:
		mov r0, increment
		pop {r4-r7,pc}

.unreq string_point1
.unreq string_length1
.unreq string_point2
.unreq string_length2
.unreq char_search
.unreq search_length
.unreq string_size2
.unreq increment


/**
 * function print32_charcount
 * Count Byte Characters in String
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Length of Array of String
 * r2: Character to Be Searched (Key)
 *
 * Return: r0 (Number of Counts for Character Key)
 */
.globl print32_charcount
print32_charcount:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_length     .req r1 @ Parameter, Register for Argument, Scratch Register
	char_search       .req r2 @ Parameter, Register for Argument, Scratch Register
	char_string       .req r3
	increment         .req r4
	count             .req r5

	push {r4-r5}

	mov increment, #0
	mov count, #0

	print32_charcount_loop:
		cmp increment, string_length
		bge print32_charcount_common

		ldrb char_string, [string_point, increment]
		cmp char_string, char_search
		addeq count, count, #1

		add increment, increment, #1
		b print32_charcount_loop

	print32_charcount_common:
		mov r0, count
		pop {r4-r5}
		mov pc, lr

.unreq string_point
.unreq string_length
.unreq char_search
.unreq char_string
.unreq increment
.unreq count


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
	bl heap32_malloc
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
 * function print32_strlist
 * Make Array of String List from One String
 * Caution! This Function Generates Two-dimensional Array in Heap Area.
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Length of Array of String
 * r2: Character of Separater (Ascii Code)
 *
 * Return: r0 (Pointer of Two-dimensional Array of List, if 0, no enough space for new Pointer of Array)
 */
.globl print32_strlist
print32_strlist:
	/* Auto (Local) Variables, but just Aliases */
	str_origin         .req r0
	length_str_origin .req r1
	separator         .req r2
	temp              .req r3
	size_heap         .req r4
	heap              .req r5
	length_str_sub    .req r6
	str_sub           .req r7
	size_subheap      .req r8
	subheap           .req r9
	offset_str_origin .req r10
	offset_heap       .req r11

	push {r4-r11,lr}

	push {r0-r3}
	bl print32_charcount
	mov size_heap, r0
	pop {r0-r3}

	add size_heap, size_heap, #1

	push {r0-r3}
	mov r0, size_heap
	bl heap32_malloc
	mov heap, r0
	pop {r0-r3}

	cmp heap, #0
	beq print32_strlist_common

	mov offset_str_origin, #0
	mov offset_heap, #0

	print32_strlist_loop:

		cmp size_heap, #0
		ble print32_strlist_common

		/* Set Initial Size of Sub Heap in Advance */
		mov size_subheap, #1

		push {r0-r3}
		add r0, str_origin, offset_str_origin
		sub r1, length_str_origin, offset_str_origin
		bl print32_charsearch
		mov length_str_sub, r0
		pop {r0-r3}

		cmp length_str_sub, #-1
		addne temp, length_str_sub, #1        @ For Null Character
		bne print32_strlist_loop_countsize

		push {r0-r3}
		add r0, str_origin, offset_str_origin
		bl print32_strlen
		mov length_str_sub, r0
		pop {r0-r3}

		add temp, length_str_sub, #1          @ For Null Character

		print32_strlist_loop_countsize:
			subs temp, temp, #4
			addgt size_subheap, #1
			bgt print32_strlist_loop_countsize

		push {r0-r3}
		mov r0, size_subheap
		bl heap32_malloc
		mov subheap, r0
		pop {r0-r3}

		push {r0-r3}
		mov r1, str_origin                    @ Pointer of Start Address of Memory Space to Be Copied (Source)
		mov r0, subheap                       @ Pointer of Start Address of Memory Space to Be Destination
		mov r2, offset_str_origin             @ Offset of Bytes to Be Copied (Source)
		mov r3, length_str_sub                @ Offset of Bytes to Be Copied (Source)
		bl heap32_mcopy
		mov subheap, r0
		pop {r0-r3}

		cmp subheap, #0
		beq print32_strlist_common

		mov temp, #0
		str temp, [subheap, length_str_sub]   @ Store Null Character

		str subheap, [heap, offset_heap]

		add offset_heap, offset_heap, #4
		add offset_str_origin, offset_str_origin, length_str_sub
		add offset_str_origin, offset_str_origin, #1

		sub size_heap, size_heap, #1

		b print32_strlist_loop

	print32_strlist_common:
		mov r0, heap
		pop {r4-r11,pc}

.unreq str_origin
.unreq length_str_origin
.unreq separator
.unreq temp
.unreq size_heap
.unreq heap
.unreq length_str_sub
.unreq str_sub
.unreq size_subheap
.unreq subheap
.unreq offset_str_origin
.unreq offset_heap


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
 * function print32_hexa
 * Print Hexadecimal Values in Heap
 *
 * Parameters
 * r0: Pointer of Array of Bytes (Heap)
 * r1: X Coordinate
 * r2: Y Coordinate
 * r3: Color (16-bit or 32-bit)
 * r4: Background Color (16-bit or 32-bit)
 * r5: Length of Characters, Left to Right, Need of PUSH/POP
 * r6: Character Width in Pixels
 * r7: Character Height in Pixels
 * r8: Font Set Base to Picture Character
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
	color             .req r3 @ Parameter, Register for Argument and Result, Scratch Register
	back_color        .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length            .req r5 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width        .req r6 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height       .req r7 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	font_ascii_base   .req r8 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	byte              .req r9
	length_max        .req r10
	length_hexa       .req r11

	push {r4-r11} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #32                                                @ r4-r11 offset 32 bytes
	pop {back_color,length,char_width,char_height,font_ascii_base} @ Get Fifth to Eighth Arguments
	sub sp, sp, #52                                                @ Retrieve SP

	mov length_max, #equ32_print32_hexa_length_max
	mov length_hexa, #2                          @ 2 Digits

	print32_hexa_loop:
		cmp length, #0                           @ `for (; length > 0; length--)`
		ble print32_hexa_success
		cmp length_max, #0                       @ `for (; length_max > 0; length_max--)`
		ble print32_hexa_success

		ldrb byte, [byte_point]                  @ Load Character Byte
		lsl byte, byte, #24

		/* Picture Hexadecimal Value */

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, byte
		push {char_width,char_height,font_ascii_base}
		push {length_hexa}
		push {back_color}                        @ Most Top on SP
		bl print32_number
		add sp, sp, #20
		push {r1}
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_hexa_error

		ldr x_coord, [sp, #-24]
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
		pop {r4-r11} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

		mov pc, lr

.unreq byte_point
.unreq x_coord
.unreq y_coord
.unreq color
.unreq back_color
.unreq length
.unreq char_width
.unreq char_height
.unreq font_ascii_base
.unreq byte
.unreq length_max
.unreq length_hexa


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
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
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

	ldr width, PRINT32_FB32_WIDTH
	ldr width, [width]

	print32_string_loop:
		cmp length, #0                           @ `for (; length > 0; length--)`
		ble print32_string_success

		ldrb string_byte, [string_point]         @ Load Character Byte
		cmp string_byte, #0                      @ NULL Character (End of String) Checker
		beq print32_string_success               @ Break Loop if Null Character

		cmp string_byte, #0x09
		moveq tab_length, #equ32_print32_string_tab_length
		beq print32_string_loop_tab

		cmp string_byte, #0x0A
		beq print32_string_loop_linefeed

		cmp string_byte, #0x0D
		beq print32_string_loop_carriagereturn

		/* Clear the Block by Color */

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, back_color
		mov r3, char_width
		push {char_height} 
		bl fb32_block_color
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
		bne print32_string_error

		/* Picture String */

		lsl string_byte, string_byte, #2         @ Substitute of Multiplication by #4 (mul)

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [font_ascii_base, string_byte]   @ Character Pointer
		push {char_width,char_height}            @ Push Character Width and Hight
		bl fb32_char
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

		print32_string_loop_carriagereturn:
			mov x_coord, #0
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
	font_ascii_base   .req r9  @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length_lower      .req r10

	push {r4-r10} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

	add sp, sp, #28                                                    @ r4-r10 offset 28 bytes
	pop {color,back_color,length,char_width,char_height,font_ascii_base} @ Get Fifth to Nineth Argument
	sub sp, sp, #52                                                    @ Retrieve SP

	mov length_lower, #0

	print32_number_double_loop:
		cmp length, #8
		subhi length_lower, length, #8
		movhi length, #8

		/* Print Upper Half */

		push {r0-r3,lr}                    @ Equals to stmfd (stack pointer full, decrement order)
		mov r0, number_upper	
		mov r1, x_coord
		mov r2, y_coord
		mov r3, color
		push {back_color,length,char_width,char_height,font_ascii_base}
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

		ldr x_coord, [sp, #-24]
		mov y_coord, x_coord
		lsr x_coord, x_coord, #16
		lsl y_coord, y_coord, #16
		lsr y_coord, y_coord, #16

		mov length, length_lower

		push {r0-r3,lr}                    @ Equals to stmfd (stack pointer full, decrement order)	
		mov r1, x_coord
		mov r2, y_coord
		mov r3, color
		push {back_color,length,char_width,char_height,font_ascii_base}
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
		pop {r4-r10} @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)

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
.unreq font_ascii_base
.unreq length_lower


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
 * Usage: r0-r11
 * Return: r0 (0 as sucess, 1 and more as error), r1 (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
.globl print32_number
print32_number:
	/* Auto (Local) Variables, but just Aliases */
	number          .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	x_coord         .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	y_coord         .req r2 @ Parameter, Register for Argument, Scratch Register
	color           .req r3 @ Parameter, Register for Argument, Scratch Register
	back_color      .req r4 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	length          .req r5 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_width      .req r6 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	char_height     .req r7 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	font_ascii_base .req r8 @ Parameter, have to PUSH/POP in ARM C lang Regulation
	width           .req r9
	i               .req r10
	bitmask         .req r11

	push {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			 @ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	add sp, sp, #32                                              @ r4-r11 offset 32 bytes
	pop {back_color,length,char_width,char_height,font_ascii_base} @ Get Fifth to Eighth Arguments
	sub sp, sp, #52                                              @ Retrieve SP

	ldr width, PRINT32_FB32_WIDTH
	ldr width, [width]

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
		bl fb32_block_color
		add sp, sp, #4
		cmp r0, #0                               @ Compare Return 0
		pop {r0-r3,lr}                           @ Retrieve Registers Before Error Check, POP does not flags-update
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

		push {r0-r3,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
		ldr r0, [font_ascii_base, bitmask]       @ Character Pointer
		push {char_width,char_height}            @ Push Character Width and Hight
		bl fb32_char
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
.unreq font_ascii_base
.unreq width
.unreq i
.unreq bitmask

PRINT32_FB32_WIDTH:  .word FB32_WIDTH
PRINT32_FB32_HEIGHT: .word FB32_HEIGHT
