/**
 * deciex32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function deciex32_string_to_int_array
 * Make Array of Integers From String (Decimal System)
 *
 * This function detects commas as separators between each Integers
 *
 * Parameters
 * r0: Heap of String
 * r1: Length of String
 * r2: Indicaton for Size of Each Block on Array: 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
 *
 * Return: r0 (Heap of Array, 0 as not succeeded)
 */
.globl deciex32_string_to_int_array
deciex32_string_to_int_array:
	/* Auto (Local) Variables, but just Aliases */
	heap_str      .req r0
	length_str    .req r1
	size          .req r2
	temp          .req r3
	temp2         .req r4
	length_substr .req r5
	heap_arr      .req r6
	length_arr    .req r7
	offset        .req r8

	push {r4-r8,lr}

	/* Check Commas */

	push {r0-r3}
	mov r1, length_str
	mov r2, #0x2C                     @ Ascii Code of Comma
	bl print32_charcount
	mov length_arr, r0
	pop {r0-r3}

	add length_arr, length_arr, #1

	cmp size, #2
	bge deciex32_string_to_int_word

	mov temp, length_arr
	mov temp2, size

	deciex32_string_to_int_lessthanword:
		tst temp, #0x1
		addne temp, temp, #0x1
		lsr temp, temp, #0x1
		sub temp2, temp2, #0x1
		cmp temp2, #0x0
		bge deciex32_string_to_int_lessthanword

		b deciex32_string_to_int_malloc

	deciex32_string_to_int_word:
		sub temp, size, #2
		lsl temp, length_arr, temp

	deciex32_string_to_int_malloc:

		push {r0-r3}
		mov r0, temp
		bl heap32_malloc
		mov heap_arr, r0
		pop {r0-r3}

		cmp heap_arr, #0
		beq deciex32_string_to_int_array_common

		.unreq temp
		align .req r3

		/* Convert Size to Bytes Alignment */
		mov temp2, #1
		lsl align, temp2, size

		.unreq temp2
		data .req r4

		mov offset, #0

	deciex32_string_to_int_loop:
		cmp length_arr, #0
		ble deciex32_string_to_int_array_common

		push {r0-r3}
		mov r1, #0x2C                     @ Ascii Code of Comma
		bl print32_charindex
		mov length_substr, r0
		pop {r0-r3}

		push {r0-r3}
		mov r1, length_substr
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

		/* Offset of Heap for Next Block of Array */
		add offset, offset, align

		sub length_arr, length_arr, #1
		b deciex32_string_to_int_loop

	deciex32_string_to_int_array_common:
		mov r0, heap_arr
		pop {r4-r8,pc}

.unreq heap_str
.unreq length_str
.unreq size
.unreq align
.unreq data
.unreq length_substr
.unreq heap_arr
.unreq length_arr
.unreq offset


/**
 * function deciex32_int_array_to_string
 * Make String (Decimal System) From Array of Integers
 *
 * Parameters
 * r0: Heap of Array
 * r1: Indicaton for Size of Each Block on Array: 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
 *
 * Return: r0 (Heap of String, 0 as not succeeded)
 */
.globl deciex32_int_array_to_string
deciex32_int_array_to_string:
	/* Auto (Local) Variables, but just Aliases */
	heap_arr        .req r0
	size            .req r1
	align           .req r2
	heap_arr_length .req r3
	temp            .req r4
	heap_str0       .req r5
	heap_str1       .req r6
	heap_str2       .req r7
	heap_str3       .req r8
	data            .req r9

	push {r4-r9,lr}

	/* Check Commas */

	ldr heap_arr_length, [heap_arr, #-4]

	add heap_arr_length, heap_arr, heap_arr_length
	sub heap_arr_length, heap_arr_length, #4

	/* Convert Size to Bytes Alignment */
	mov temp, #1
	lsl align, temp, size

	mov heap_str0, #0

	deciex32_int_array_to_string_loop:
		cmp heap_arr, heap_arr_length
		bge deciex32_int_array_to_string_common

		cmp size, #0
		ldreqb data, [heap_arr]
		cmp size, #1
		ldreqh data, [heap_arr]
		cmp size, #2
		ldrge data, [heap_arr]

		push {r0-r3}
		mov r0, data
		mov r1, #1
		mov r2, #1
		bl deci32_int32_to_string_deci
		mov heap_str1, r0
		pop {r0-r3}

		cmp heap_str1, #0
		beq deciex32_int_array_to_string_common

		add heap_arr, heap_arr, align
		cmp heap_arr, heap_arr_length
		bge deciex32_int_array_to_string_loop_common

		push {r0-r3}
		mov r0, #1
		bl heap32_malloc
		mov heap_str2, r0
		pop {r0-r3}

		cmp heap_str2, #0
		beq deciex32_int_array_to_string_common

		mov temp, #0x2C                          @ Ascii Code of Comma
		strb temp, [heap_str2]

		mov temp, #0x00                          @ Ascii Code of Null
		strb temp, [heap_str2, #1]

		push {r0-r3}
		mov r0, heap_str1
		mov r1, heap_str2
		bl print32_strcat
		mov heap_str3, r0
		pop {r0-r3}

		cmp heap_str3, #0
		beq deciex32_int_array_to_string_common

		push {r0-r3}
		mov r0, heap_str1
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, heap_str2
		bl heap32_mfree
		pop {r0-r3}

		mov heap_str1, heap_str3

		deciex32_int_array_to_string_loop_common:

			/* If Initial Part of Array */
			cmp heap_str0, #0
			moveq heap_str0, heap_str1
			beq deciex32_int_array_to_string_loop

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

			b deciex32_int_array_to_string_loop

	deciex32_int_array_to_string_common:
		mov r0, heap_str0
		pop {r4-r9,pc}

.unreq heap_arr
.unreq size
.unreq align
.unreq heap_arr_length
.unreq temp
.unreq heap_str0
.unreq heap_str1
.unreq heap_str2
.unreq heap_str3
.unreq data
