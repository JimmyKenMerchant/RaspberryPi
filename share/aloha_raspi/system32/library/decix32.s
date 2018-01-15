/**
 * decix32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function decix32_string_to_intarray
 * Make Array of Integers From String (Hexadecimal/Decimal System)
 *
 * This function detects commas as separators between each Integers
 *
 * Parameters
 * r0: Heap of String
 * r1: Length of String
 * r2: Indicaton for Size of Each Block on Array: 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
 * r3: 0 Means Hexadecimal System, 1 Means Decimal System
 *
 * Return: r0 (Heap of Array, 0 as not succeeded)
 */
.globl decix32_string_to_intarray
decix32_string_to_intarray:
	/* Auto (Local) Variables, but just Aliases */
	heap_str      .req r0
	length_str    .req r1
	size          .req r2
	system        .req r3
	temp          .req r4
	temp2         .req r5
	length_substr .req r6
	heap_arr      .req r7
	length_arr    .req r8
	offset        .req r9

	push {r4-r9,lr}

	/* Check Commas */

	push {r0-r3}
	mov r2, #0x2C                     @ Ascii Code of Comma
	bl print32_charcount
	mov length_arr, r0
	pop {r0-r3}

	add length_arr, length_arr, #1

	cmp size, #2
	bge decix32_string_to_intarray_word

	mov temp, length_arr
	mov temp2, #0x1

	decix32_string_to_intarray_lessthanword:
		tst temp, #0x1
		addne temp, temp, #0x1
		lsr temp, temp, #0x1
		sub temp2, temp2, #0x1
		cmp temp2, size
		bge decix32_string_to_intarray_lessthanword

		b decix32_string_to_intarray_malloc

	decix32_string_to_intarray_word:
		sub temp, size, #2
		lsl temp, length_arr, temp

	decix32_string_to_intarray_malloc:

		push {r0-r3}
		mov r0, temp
		bl heap32_malloc
		mov heap_arr, r0
		pop {r0-r3}

		cmp heap_arr, #0
		beq decix32_string_to_intarray_common

		.unreq temp
		align .req r4

		/* Convert Size to Bytes Alignment */
		mov temp2, #1
		lsl align, temp2, size

		.unreq temp2
		data .req r5

		mov offset, #0

	decix32_string_to_intarray_loop:
		cmp length_arr, #0
		ble decix32_string_to_intarray_common

		push {r0-r3}
		mov r2, #0x2C                     @ Ascii Code of Comma
		bl print32_charsearch
		mov length_substr, r0
		pop {r0-r3}

		cmp length_substr, #-1
		bne decix32_string_to_intarray_loop_jump

		push {r0-r3}
		bl print32_strlen
		mov length_substr, r0
		pop {r0-r3}

		decix32_string_to_intarray_loop_jump:

			push {r0-r3}
			mov r1, length_substr
			mov r2, system
			bl deci32_string_to_int32
			mov data, r0
			pop {r0-r3}

			cmp size, #0
			streqb data, [heap_arr, offset]
			cmp size, #1
			streqh data, [heap_arr, offset]
			cmp size, #2
			strge data, [heap_arr, offset]

			/* Offset of String for Next Data */
			add heap_str, heap_str, length_substr
			add heap_str, heap_str, #1
			sub length_str, length_str, length_substr
			sub length_str, length_str, #1

			/* Offset of Heap for Next Block of Array */
			add offset, offset, align

			sub length_arr, length_arr, #1
			b decix32_string_to_intarray_loop

	decix32_string_to_intarray_common:
		mov r0, heap_arr
		pop {r4-r9,pc}

.unreq heap_str
.unreq length_str
.unreq size
.unreq system
.unreq align
.unreq data
.unreq length_substr
.unreq heap_arr
.unreq length_arr
.unreq offset


/**
 * function decix32_intarray_to_string_hexa
 * Make String (Hexadecimal System) From Array of Integers
 *
 * Parameters
 * r0: Heap of Array
 * r1: Indicaton for Size of Each Block on Array: 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
 * r2: Minimum Length of Digits from Left Side, Up to 8 Digits
 * r3: 0 unsigned, 1 signed
 * r4: 0 Doesn't Show Bases Mark, 1 Shows Bases Mark(`0x`)
 *
 * Return: r0 (Heap of String, 0 as not succeeded)
 */
.globl decix32_intarray_to_string_hexa
decix32_intarray_to_string_hexa:
	/* Auto (Local) Variables, but just Aliases */
	heap_arr        .req r0
	size            .req r1
	min_length      .req r2
	signed          .req r3
	base_mark       .req r4
	align           .req r5
	heap_arr_length .req r6
	heap_str0       .req r7
	heap_str1       .req r8
	heap_str2       .req r9
	heap_str3       .req r10
	data            .req r11

	push {r4-r11,lr}

	add sp, sp, #36                     @ r4-r11 and lr offset 36 bytes
	pop {base_mark}                     @ Get Fifth and Sixth Arguments
	sub sp, sp, #40                     @ Retrieve SP

	/* Check Size */

	ldr heap_arr_length, [heap_arr, #-4]

	add heap_arr_length, heap_arr, heap_arr_length
	sub heap_arr_length, heap_arr_length, #4

	/* Convert Size to Bytes Alignment */
	mov data, #1
	lsl align, data, size

	mov heap_str0, #0

	decix32_intarray_to_string_hexa_loop:
		cmp heap_arr, heap_arr_length
		bge decix32_intarray_to_string_hexa_common

		cmp size, #0
		ldreqb data, [heap_arr]
		cmp size, #1
		ldreqh data, [heap_arr]
		cmp size, #2
		ldrge data, [heap_arr]

		push {r0-r3}
		mov r0, data
		mov r1, min_length
		mov r2, signed
		mov r3, base_mark
		bl deci32_int32_to_string_hexa
		mov heap_str1, r0
		pop {r0-r3}

		cmp heap_str1, #0
		beq decix32_intarray_to_string_hexa_common

		add heap_arr, heap_arr, align
		cmp heap_arr, heap_arr_length
		bge decix32_intarray_to_string_hexa_loop_common

		push {r0-r3}
		mov r0, #1
		bl heap32_malloc
		mov heap_str2, r0
		pop {r0-r3}

		cmp heap_str2, #0
		beq decix32_intarray_to_string_hexa_common

		mov data, #0x2C                          @ Ascii Code of Comma
		strb data, [heap_str2]

		mov data, #0x00                          @ Ascii Code of Null
		strb data, [heap_str2, #1]

		push {r0-r3}
		mov r0, heap_str1
		mov r1, heap_str2
		bl print32_strcat
		mov heap_str3, r0
		pop {r0-r3}

		cmp heap_str3, #0
		beq decix32_intarray_to_string_hexa_common

		push {r0-r3}
		mov r0, heap_str1
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, heap_str2
		bl heap32_mfree
		pop {r0-r3}

		mov heap_str1, heap_str3

		decix32_intarray_to_string_hexa_loop_common:

			/* If Initial Part of Array */
			cmp heap_str0, #0
			moveq heap_str0, heap_str1
			beq decix32_intarray_to_string_hexa_loop

			/* If Following Parts of Array */
			push {r0-r3}
			mov r0, heap_str0
			mov r1, heap_str1
			bl print32_strcat
			mov heap_str2, r0
			pop {r0-r3}

			push {r0-r3}
			mov r0, heap_str0
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, heap_str1
			bl heap32_mfree
			pop {r0-r3}

			mov heap_str0, heap_str2

			b decix32_intarray_to_string_hexa_loop

	decix32_intarray_to_string_hexa_common:
		mov r0, heap_str0
		pop {r4-r11,pc}

.unreq heap_arr
.unreq size
.unreq min_length
.unreq signed
.unreq base_mark
.unreq align
.unreq heap_arr_length
.unreq heap_str0
.unreq heap_str1
.unreq heap_str2
.unreq heap_str3
.unreq data


/**
 * function decix32_intarray_to_string_deci
 * Make String (Decimal System) From Array of Integers
 *
 * Parameters
 * r0: Heap of Array
 * r1: Indicaton for Size of Each Block on Array: 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
 * r2: Minimum Length of Digits from Left Side, Up to 16 Digits
 * r3: 0 unsigned, 1 signed
 *
 * Return: r0 (Heap of String, 0 as not succeeded)
 */
.globl decix32_intarray_to_string_deci
decix32_intarray_to_string_deci:
	/* Auto (Local) Variables, but just Aliases */
	heap_arr        .req r0
	size            .req r1
	min_length      .req r2
	signed          .req r3
	align           .req r4
	heap_arr_length .req r5
	heap_str0       .req r6
	heap_str1       .req r7
	heap_str2       .req r8
	heap_str3       .req r9
	data            .req r10

	push {r4-r10,lr}

	/* Check Size */

	ldr heap_arr_length, [heap_arr, #-4]

	add heap_arr_length, heap_arr, heap_arr_length
	sub heap_arr_length, heap_arr_length, #4

	/* Convert Size to Bytes Alignment */
	mov data, #1
	lsl align, data, size

	mov heap_str0, #0

	decix32_intarray_to_string_deci_loop:
		cmp heap_arr, heap_arr_length
		bge decix32_intarray_to_string_deci_common

		cmp size, #0
		ldreqb data, [heap_arr]
		cmp size, #1
		ldreqh data, [heap_arr]
		cmp size, #2
		ldrge data, [heap_arr]

		push {r0-r3}
		mov r0, data
		mov r1, min_length
		mov r2, signed
		bl deci32_int32_to_string_deci
		mov heap_str1, r0
		pop {r0-r3}

		cmp heap_str1, #0
		beq decix32_intarray_to_string_deci_common

		add heap_arr, heap_arr, align
		cmp heap_arr, heap_arr_length
		bge decix32_intarray_to_string_deci_loop_common

		push {r0-r3}
		mov r0, #1
		bl heap32_malloc
		mov heap_str2, r0
		pop {r0-r3}

		cmp heap_str2, #0
		beq decix32_intarray_to_string_deci_common

		mov data, #0x2C                          @ Ascii Code of Comma
		strb data, [heap_str2]

		mov data, #0x00                          @ Ascii Code of Null
		strb data, [heap_str2, #1]

		push {r0-r3}
		mov r0, heap_str1
		mov r1, heap_str2
		bl print32_strcat
		mov heap_str3, r0
		pop {r0-r3}

		cmp heap_str3, #0
		beq decix32_intarray_to_string_deci_common

		push {r0-r3}
		mov r0, heap_str1
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, heap_str2
		bl heap32_mfree
		pop {r0-r3}

		mov heap_str1, heap_str3

		decix32_intarray_to_string_deci_loop_common:

			/* If Initial Part of Array */
			cmp heap_str0, #0
			moveq heap_str0, heap_str1
			beq decix32_intarray_to_string_deci_loop

			/* If Following Parts of Array */
			push {r0-r3}
			mov r0, heap_str0
			mov r1, heap_str1
			bl print32_strcat
			mov heap_str2, r0
			pop {r0-r3}

			push {r0-r3}
			mov r0, heap_str0
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, heap_str1
			bl heap32_mfree
			pop {r0-r3}

			mov heap_str0, heap_str2

			b decix32_intarray_to_string_deci_loop

	decix32_intarray_to_string_deci_common:
		mov r0, heap_str0
		pop {r4-r10,pc}

.unreq heap_arr
.unreq size
.unreq min_length
.unreq signed
.unreq align
.unreq heap_arr_length
.unreq heap_str0
.unreq heap_str1
.unreq heap_str2
.unreq heap_str3
.unreq data


/**
 * function decix32_string_to_farray
 * Make Array of Single Precision Floats From String (Decimal System)
 *
 * This function detects commas as separators between each floats
 *
 * Parameters
 * r0: Heap of String
 * r1: Length of String
 *
 * Return: r0 (Heap of Array, 0 as not succeeded)
 */
.globl decix32_string_to_farray
decix32_string_to_farray:
	/* Auto (Local) Variables, but just Aliases */
	heap_str      .req r0
	length_str    .req r1
	temp          .req r2
	offset        .req r3
	length_substr .req r4
	heap_arr      .req r5
	length_arr    .req r6
	data          .req r7

	push {r4-r7,lr}

	/* Check Commas */

	push {r0-r3}
	mov r2, #0x2C                     @ Ascii Code of Comma
	bl print32_charcount
	mov length_arr, r0
	pop {r0-r3}

	add length_arr, length_arr, #1

	decix32_string_to_farray_malloc:

		push {r0-r3}
		mov r0, length_arr
		bl heap32_malloc
		mov heap_arr, r0
		pop {r0-r3}

		cmp heap_arr, #0
		beq decix32_string_to_farray_common

		mov offset, #0

	decix32_string_to_farray_loop:
		cmp length_arr, #0
		ble decix32_string_to_farray_common

		push {r0-r3}
		mov r2, #0x2C                     @ Ascii Code of Comma
		bl print32_charsearch
		mov length_substr, r0
		pop {r0-r3}

		cmp length_substr, #-1
		bne decix32_string_to_farray_loop_jump

		push {r0-r3}
		bl print32_strlen
		mov length_substr, r0
		pop {r0-r3}

		decix32_string_to_farray_loop_jump:

			push {r0-r3}
			mov r1, length_substr
			bl deci32_string_to_float32
			mov data, r0
			pop {r0-r3}

			str data, [heap_arr, offset]

			/* Offset of String for Next Data */
			add heap_str, heap_str, length_substr
			add heap_str, heap_str, #1
			sub length_str, length_str, length_substr
			sub length_str, length_str, #1

			/* Offset of Heap for Next Block of Array */
			add offset, offset, #4

			sub length_arr, length_arr, #1
			b decix32_string_to_farray_loop

	decix32_string_to_farray_common:
		mov r0, heap_arr
		pop {r4-r7,pc}

.unreq heap_str
.unreq length_str
.unreq temp
.unreq offset
.unreq length_substr
.unreq heap_arr
.unreq length_arr
.unreq data


/**
 * function decix32_farray_to_string
 * Make String (Decimal System) From Single Precision Floats
 *
 * Parameters
 * r0: Heap of Array
 * r1: Minimam Length of Digits in Integer Places, 16 Digits Max
 * r2: Maximam Length of Digits in Decimal Places, Default 8 Digits, If Exceeds, Round Down
 * r3: Minimam Length of Digits in Exponent Places, 16 Digits Max
 *
 * Return: r0 (Heap of String, 0 as not succeeded)
 */
.globl decix32_farray_to_string
decix32_farray_to_string:
	/* Auto (Local) Variables, but just Aliases */
	heap_arr        .req r0
	min_integer     .req r1
	max_decimal     .req r2
	min_exponent    .req r3
	heap_arr_length .req r4
	data            .req r5
	heap_str0       .req r6
	heap_str1       .req r7
	heap_str2       .req r8
	heap_str3       .req r9

	push {r4-r9,lr}

	/* Check Size */

	ldr heap_arr_length, [heap_arr, #-4]

	add heap_arr_length, heap_arr, heap_arr_length
	sub heap_arr_length, heap_arr_length, #4

	mov heap_str0, #0

	decix32_farray_to_string_loop:
		cmp heap_arr, heap_arr_length
		bge decix32_farray_to_string_common

		ldr data, [heap_arr]

		push {r0-r3}
		mov r0, data
		bl deci32_float32_to_string
		mov heap_str1, r0
		pop {r0-r3}

		cmp heap_str1, #0
		beq decix32_farray_to_string_common

		add heap_arr, heap_arr, #4
		cmp heap_arr, heap_arr_length
		bge decix32_farray_to_string_loop_common

		push {r0-r3}
		mov r0, #1
		bl heap32_malloc
		mov heap_str2, r0
		pop {r0-r3}

		cmp heap_str2, #0
		beq decix32_farray_to_string_common

		mov data, #0x2C                          @ Ascii Code of Comma
		strb data, [heap_str2]

		mov data, #0x00                          @ Ascii Code of Null
		strb data, [heap_str2, #1]

		push {r0-r3}
		mov r0, heap_str1
		mov r1, heap_str2
		bl print32_strcat
		mov heap_str3, r0
		pop {r0-r3}

		cmp heap_str3, #0
		beq decix32_farray_to_string_common

		push {r0-r3}
		mov r0, heap_str1
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, heap_str2
		bl heap32_mfree
		pop {r0-r3}

		mov heap_str1, heap_str3

		decix32_farray_to_string_loop_common:

			/* If Initial Part of Array */
			cmp heap_str0, #0
			moveq heap_str0, heap_str1
			beq decix32_farray_to_string_loop

			/* If Following Parts of Array */
			push {r0-r3}
			mov r0, heap_str0
			mov r1, heap_str1
			bl print32_strcat
			mov heap_str2, r0
			pop {r0-r3}

			push {r0-r3}
			mov r0, heap_str0
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, heap_str1
			bl heap32_mfree
			pop {r0-r3}

			mov heap_str0, heap_str2

			b decix32_farray_to_string_loop

	decix32_farray_to_string_common:
		mov r0, heap_str0
		pop {r4-r9,pc}

.unreq heap_arr
.unreq min_integer
.unreq max_decimal
.unreq min_exponent
.unreq heap_arr_length
.unreq data
.unreq heap_str0
.unreq heap_str1
.unreq heap_str2
.unreq heap_str3
