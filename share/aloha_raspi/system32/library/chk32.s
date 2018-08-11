/**
 * chk32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function chk32_crc7
 * Cyclic Redundancy Check CRC7 (8-bit) by One Byte Big Endian (MSB Order), No Reflection of Bits on Input and Result
 *
 * Parameters
 * r0: Pointer of Data to be Checked
 * r1: Length of Data (Bits), From 2
 * r2: Bits as Divisor (Polynomial)
 * r3: Value to XOR on Initial
 * r4: Value to XOR on Final
 * r5: Number of Bits Actually Checked, From 15
 *
 * Return: r0 (Calculated Value, -1 as Error)
 * Error: Length of Bits as Divisor Exceeds Length of Data
 */
.globl chk32_crc7
chk32_crc7:
	/* Auto (Local) Variables, but just Aliases */
	pointer_data   .req r0
	length_data    .req r1
	divisor        .req r2
	xor_initial    .req r3
	xor_final      .req r4
	number_bit     .req r5
	count_byte     .req r6
	count_bit      .req r7
	dividend       .req r8
	byte           .req r9
	temp           .req r10
	i              .req r11

	push {r4-r11,lr}

	add sp, sp, #36                           @ r4-r11 and lr offset 36 bytes
	pop {xor_final,number_bit}                @ Get Fifth and Sixth Arguments
	sub sp, sp, #44                           @ Retrieve SP

	cmp length_data, #2
	mvnlo dividend, #0
	blo chk32_crc7_common

	and divisor, divisor, #0xFF
	orr divisor, divisor, #0x80               @ Bit[7] is Always High on CRC7
	and xor_initial, xor_initial, #0xFF
	and xor_final, xor_final, #0xFF

	mov count_byte, #0
	ldrb dividend, [pointer_data, count_byte]
	eor dividend, dividend, xor_initial
	mov count_byte, #1
	mov count_bit, #0

	mov i, #8

	chk32_crc7_calculate:
		tst dividend, #0x80
		beq chk32_crc7_calculate_shift

		eor dividend, dividend, divisor

		chk32_crc7_calculate_shift:
			cmp i, number_bit
			bhs chk32_crc7_common

			cmp count_bit, #8
			blo chk32_crc7_calculate_shift_jump

			cmp count_byte, length_data
			bhs chk32_crc7_common

			/* You Can Ignore Bits in Next Byte Untill Bits in Current Byte Have Been All Checked */
			ldrb byte, [pointer_data, count_byte]
			eor dividend, dividend, byte            @ Exclusive OR with Dividend Bits in Previous Byte Have Been All Checked
			mov count_bit, #0
			add count_byte, count_byte, #1

			chk32_crc7_calculate_shift_jump:

				lsl dividend, dividend, #1          @ Logical Shift Left with Previous Value

				add i, i, #1
				add count_bit, count_bit, #1
				b chk32_crc7_calculate

	chk32_crc7_common:
		eor r0, dividend, xor_final
		pop {r4-r11,pc}

.unreq pointer_data
.unreq length_data
.unreq divisor
.unreq xor_initial
.unreq xor_final
.unreq number_bit
.unreq count_byte
.unreq count_bit
.unreq dividend
.unreq byte
.unreq temp
.unreq i


/**
 * function chk32_crc8
 * Cyclic Redundancy Check CRC8 (9-bit) by One Byte Big Endian (MSB Order), No Reflection of Bits on Input and Result
 *
 * Parameters
 * r0: Pointer of Data to be Checked
 * r1: Length of Data (Bits), From 2
 * r2: Bits as Divisor (Polynomial), Omit Bit[16] (Always High) to Hide Overflow
 * r3: Value to XOR on Initial
 * r4: Value to XOR on Final
 * r5: Number of Bits Actually Checked, From 16
 *
 * Return: r0 (Calculated Value, -1 as Error)
 * Error: Length of Bits as Divisor Exceeds Length of Data
 */
.globl chk32_crc8
chk32_crc8:
	/* Auto (Local) Variables, but just Aliases */
	pointer_data   .req r0
	length_data    .req r1
	divisor        .req r2
	xor_initial    .req r3
	xor_final      .req r4
	number_bit     .req r5
	count_byte     .req r6
	count_bit      .req r7
	dividend       .req r8
	byte           .req r9
	temp           .req r10
	i              .req r11

	push {r4-r11,lr}

	add sp, sp, #36                           @ r4-r11 and lr offset 36 bytes
	pop {xor_final,number_bit}                @ Get Fifth and Sixth Arguments
	sub sp, sp, #44                           @ Retrieve SP

	cmp length_data, #2
	mvnlo dividend, #0
	blo chk32_crc8_common

	/* Omit Bit[8] (Always High on CRC16) to Fit 8-bit */
	and divisor, divisor, #0xFF
	and xor_initial, xor_initial, #0xFF
	and xor_final, xor_final, #0xFF

	mov count_byte, #0
	ldrb dividend, [pointer_data, count_byte]
	eor dividend, dividend, xor_initial
	mov count_byte, #1
	mov count_bit, #0

	mov i, #8

	chk32_crc8_calculate:
		cmp i, number_bit
		bhs chk32_crc8_common

		cmp count_bit, #8
		blo chk32_crc8_calculate_jump

		cmp count_byte, length_data
		bhs chk32_crc8_common

		/* You Can Ignore Bits in Next Byte Untill Bits in Current Byte Have Been All Checked */
		ldrb byte, [pointer_data, count_byte]
		eor dividend, dividend, byte            @ Exclusive OR with Dividend Bits in Previous Byte Have Been All Checked
		mov count_bit, #0
		add count_byte, count_byte, #1

		chk32_crc8_calculate_jump:

			lsl dividend, dividend, #1          @ Logical Shift Left with Previous Value

			/* To Omit Bit[8] of Divisor, Calculate After Shift */
			tst dividend, #0x100
			bicne dividend, dividend, #0x100
			eorne dividend, dividend, divisor

			add i, i, #1
			add count_bit, count_bit, #1
			b chk32_crc8_calculate

	chk32_crc8_common:
		eor r0, dividend, xor_final
		pop {r4-r11,pc}

.unreq pointer_data
.unreq length_data
.unreq divisor
.unreq xor_initial
.unreq xor_final
.unreq number_bit
.unreq count_byte
.unreq count_bit
.unreq dividend
.unreq byte
.unreq temp
.unreq i


/**
 * function chk32_crc16
 * Cyclic Redundancy Check CRC16 (17-bit) by One Byte Big Endian (MSB Order), No Reflection of Bits on Input and Result
 *
 * Parameters
 * r0: Pointer of Data to be Checked
 * r1: Length of Data (Bits), From 3
 * r2: Bits as Divisor (Polynomial), Omit Bit[16] (Always High) to Hide Overflow
 * r3: Value to XOR on Initial
 * r4: Value to XOR on Final
 * r5: Number of Bits Actually Checked, From 24
 *
 * Return: r0 (Calculated Value, -1 as Error)
 * Error: Length of Bits as Divisor Exceeds Length of Data
 */
.globl chk32_crc16
chk32_crc16:
	/* Auto (Local) Variables, but just Aliases */
	pointer_data   .req r0
	length_data    .req r1
	divisor        .req r2
	xor_initial    .req r3
	xor_final      .req r4
	number_bit     .req r5
	count_byte     .req r6
	count_bit      .req r7
	dividend       .req r8
	byte           .req r9
	temp           .req r10
	i              .req r11

	push {r4-r11,lr}

	add sp, sp, #36                           @ r4-r11 and lr offset 36 bytes
	pop {xor_final,number_bit}                @ Get Fifth and Sixth Arguments
	sub sp, sp, #44                           @ Retrieve SP

	cmp length_data, #3
	mvnlo dividend, #0
	blo chk32_crc16_common

	/* Omit Bit[16] (Always High on CRC16) to Fit 16-bit */
	mov temp, #0xFF00
	orr temp, temp, #0x00FF
	and divisor, divisor, temp
	and xor_initial, xor_initial, temp
	and xor_final, xor_final, temp

	mov count_byte, #0
	ldrb temp, [pointer_data, count_byte]
	lsl dividend, temp, #8
	mov count_byte, #1
	ldrb temp, [pointer_data, count_byte]
	orr dividend, dividend, temp
	eor dividend, dividend, xor_initial
	add count_byte, count_byte, #1
	mov count_bit, #0

	mov i, #16

	chk32_crc16_calculate:
		cmp i, number_bit
		bhs chk32_crc16_common

		cmp count_bit, #8
		blo chk32_crc16_calculate_jump

		cmp count_byte, length_data
		bhs chk32_crc16_common

		/* You Can Ignore Bits in Next Byte Untill Bits in Current Byte Have Been All Checked */
		ldrb byte, [pointer_data, count_byte]
		eor dividend, dividend, byte            @ Exclusive OR with Dividend Bits in Previous Byte Have Been All Checked
		mov count_bit, #0
		add count_byte, count_byte, #1

		chk32_crc16_calculate_jump:

			lsl dividend, dividend, #1          @ Logical Shift Left with Previous Value

			/* To Omit Bit[16] of Divisor, Calculate After Shift */
			tst dividend, #0x10000
			bicne dividend, dividend, #0x10000
			eorne dividend, dividend, divisor

			add i, i, #1
			add count_bit, count_bit, #1
			b chk32_crc16_calculate

	chk32_crc16_common:
		eor r0, dividend, xor_final
		pop {r4-r11,pc}

.unreq pointer_data
.unreq length_data
.unreq divisor
.unreq xor_initial
.unreq xor_final
.unreq number_bit
.unreq count_byte
.unreq count_bit
.unreq dividend
.unreq byte
.unreq temp
.unreq i


/**
 * function chk32_crc32
 * Cyclic Redundancy Check CRC32 (33-bit) by One Byte Big Endian (MSB Order), No Reflection of Bits on Input and Result
 *
 * Parameters
 * r0: Pointer of Data to be Checked
 * r1: Length of Data (Bits), From 5
 * r2: Bits as Divisor (Polynomial), Omit Bit[16] (Always High) to Hide Overflow
 * r3: Value to XOR on Initial
 * r4: Value to XOR on Final
 * r5: Number of Bits Actually Checked, From 40 
 *
 * Return: r0 (Calculated Value, -1 as Error)
 * Error: Length of Bits as Divisor Exceeds Length of Data
 */
.globl chk32_crc32
chk32_crc32:
	/* Auto (Local) Variables, but just Aliases */
	pointer_data   .req r0
	length_data    .req r1
	divisor        .req r2
	xor_initial    .req r3
	xor_final      .req r4
	number_bit     .req r5
	count_byte     .req r6
	count_bit      .req r7
	dividend       .req r8
	byte           .req r9
	temp           .req r10
	i              .req r11

	push {r4-r11,lr}

	add sp, sp, #36                           @ r4-r11 and lr offset 36 bytes
	pop {xor_final,number_bit}                @ Get Fifth and Sixth Arguments
	sub sp, sp, #44                           @ Retrieve SP

	cmp length_data, #5
	mvnlo dividend, #0
	blo chk32_crc32_common

	mov count_byte, #0
	ldrb dividend, [pointer_data, count_byte]
	lsl dividend, dividend, #24
	mov count_byte, #1
	ldrb temp, [pointer_data, count_byte]
	lsl temp, temp, #16
	orr dividend, dividend, temp
	add count_byte, count_byte, #1
	ldrb temp, [pointer_data, count_byte]
	lsl temp, temp, #8
	orr dividend, dividend, temp
	add count_byte, count_byte, #1
	ldrb temp, [pointer_data, count_byte]
	orr dividend, dividend, temp
	add count_byte, count_byte, #1
	eor dividend, dividend, xor_initial
	mov count_bit, #0

	mov i, #32

	chk32_crc32_calculate:
		cmp i, number_bit
		bhs chk32_crc32_common

		cmp count_bit, #8
		blo chk32_crc32_calculate_jump

		cmp count_byte, length_data
		bhs chk32_crc32_common

		/* You Can Ignore Bits in Next Byte Untill Bits in Current Byte Have Been All Checked */
		ldrb byte, [pointer_data, count_byte]
		eor dividend, dividend, byte            @ Exclusive OR with Dividend Bits in Previous Byte Have Been All Checked
		mov count_bit, #0
		add count_byte, count_byte, #1

		chk32_crc32_calculate_jump:

			lsls dividend, dividend, #1         @ Logical Shift Left with Previous Value

			/* To Omit Bit[32] of Divisor, Calculate After Shift */
			eorcs dividend, dividend, divisor

			add i, i, #1
			add count_bit, count_bit, #1
			b chk32_crc32_calculate

	chk32_crc32_common:
		eor r0, dividend, xor_final
		pop {r4-r11,pc}

.unreq pointer_data
.unreq length_data
.unreq divisor
.unreq xor_initial
.unreq xor_final
.unreq number_bit
.unreq count_byte
.unreq count_bit
.unreq dividend
.unreq byte
.unreq temp
.unreq i


/**
 * function chk32_crctable
 * Make Table for Cyclic Redundancy Check
 * This function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Bits as Divisor (Polynomial), Omit MSB
 * r1: CRC8 (0)/ CRC16 (1)/ CRC32 (2)
 *
 * Return: r0 (Pointer of CRC Table, If Zero Memory Allocation Fails)
 */
.globl chk32_crctable
chk32_crctable:
	/* Auto (Local) Variables, but just Aliases */
	divisor       .req r0
	crc_type      .req r1
	i             .req r2
	j             .req r3
	pointer_table .req r4
	shift_bit     .req r5
	dividend      .req r6
	offset        .req r7
	incr_offset   .req r8

	push {r4-r8,lr}

	cmp crc_type, #2
	movhi crc_type, #2

	/* Allocate Memory, 256 bytes for CRC8, 512 bytes for CRC16, 1024 bytes for CRC32 */
	push {r0-r3}
	mov r0, #64                   @ Word (4-byte)
	lsl r0, r0, crc_type
	bl heap32_malloc
	mov pointer_table, r0
	pop {r0-r3}

	/* Make Offset Value on Storing Memory, 1 for CRC8, 2 for CRC16, 4 for CRC32 */
	mov incr_offset, #1
	lsl incr_offset, incr_offset, crc_type

	/* Bit Shift, 0 for CRC8, 8 for CRC16, 24 for CRC32 */
	mov shift_bit, #8
	lsl shift_bit, shift_bit, crc_type
	sub shift_bit, shift_bit, #8

	mov offset, #0
	mov i, #0

	chk32_crctable_loop:
		cmp i, #256
		bhs chk32_crctable_common

		lsl dividend, i, shift_bit
		mov j, #0

		chk32_crctable_loop_calculate:

			cmp crc_type, #0
			beq chk32_crctable_loop_calculate_crc8
			cmp crc_type, #1
			beq chk32_crctable_loop_calculate_crc16
			cmp crc_type, #2
			bhs chk32_crctable_loop_calculate_crc32

			chk32_crctable_loop_calculate_crc8:

				cmp j, #8
				addhs i, i, #1
				strhsb dividend, [pointer_table, offset]
				addhs offset, offset, incr_offset
				bhs chk32_crctable_loop

				lsl dividend, dividend, #1         @ Logical Shift Left with Previous Value
				tst dividend, #0x100
				/* To Omit Bit[8] of Divisor, Calculate After Shift */
				eorne dividend, dividend, divisor

				add j, j, #1

				b chk32_crctable_loop_calculate_crc8

			chk32_crctable_loop_calculate_crc16:

				cmp j, #8
				addhs i, i, #1
				strhsh dividend, [pointer_table, offset]
				addhs offset, offset, incr_offset
				bhs chk32_crctable_loop

				lsl dividend, dividend, #1         @ Logical Shift Left with Previous Value
				tst dividend, #0x10000
				/* To Omit Bit[16] of Divisor, Calculate After Shift */
				eorne dividend, dividend, divisor

				add j, j, #1

				b chk32_crctable_loop_calculate_crc16

			chk32_crctable_loop_calculate_crc32:

				cmp j, #8
				addhs i, i, #1
				strhs dividend, [pointer_table, offset]
				addhs offset, offset, incr_offset
				bhs chk32_crctable_loop

				lsls dividend, dividend, #1         @ Logical Shift Left with Previous Value
				/* To Omit Bit[32] of Divisor, Calculate After Shift */
				eorcs dividend, dividend, divisor

				add j, j, #1

				b chk32_crctable_loop_calculate_crc32

	chk32_crctable_common:
		mov r0, pointer_table
		pop {r4-r8,pc}

.unreq divisor
.unreq crc_type
.unreq i
.unreq j
.unreq pointer_table
.unreq shift_bit
.unreq dividend
.unreq offset
.unreq incr_offset


/**
 * function chk32_crc
 * Cyclic Redundancy Check Using Table
 *
 * Parameters
 * r0: Pointer of Data to be Checked
 * r1: Length of Bytes
 * r2: Value to XOR on Initial
 * r3: Value to XOR on Final
 * r4: Pointer of CRC Table
 * r5: CRC8 (0)/ CRC16 (1)/ CRC32 (2)
 *
 * Return: r0 (Calculated Value)
 */
.globl chk32_crc
chk32_crc:
	/* Auto (Local) Variables, but just Aliases */
	pointer_data  .req r0
	length_data   .req r1
	xor_initial   .req r2
	xor_final     .req r3
	pointer_table .req r4
	crc_type      .req r5
	shift_bit     .req r6
	i             .req r7
	byte          .req r8
	shift         .req r9

	push {r4-r9,lr}

	add sp, sp, #28                           @ r4-r9 and lr offset 28 bytes
	pop {pointer_table,crc_type}              @ Get Fifth and Sixth Arguments
	sub sp, sp, #36                           @ Retrieve SP

	cmp crc_type, #2
	movhi crc_type, #2

	/* Bit Shift, 0 for CRC8, 8 for CRC16, 24 for CRC32 */
	mov shift_bit, #8
	lsl shift_bit, shift_bit, crc_type
	sub shift_bit, shift_bit, #8

	mov i, #0

	chk32_crc_loop:
		cmp i, length_data
		bhs chk32_crc_common

		lsr shift, xor_initial, shift_bit
		and shift, shift, #0xFF
		ldrb byte, [pointer_data, i]
		eor shift, shift, byte

		/* Make Offset to Search Table  */
		lsl shift, shift, crc_type

		cmp crc_type, #0
		beq chk32_crc_loop_crc8
		cmp crc_type, #1
		beq chk32_crc_loop_crc16
		cmp crc_type, #2
		bhs chk32_crc_loop_crc32

		chk32_crc_loop_crc8:
			ldrb xor_initial, [pointer_table, shift]
			b chk32_crc_loop_common

		chk32_crc_loop_crc16:
			ldrh shift, [pointer_table, shift]
			lsl xor_initial, xor_initial, #8          @ Slide 8 Bits of CRC Value
			eor xor_initial, xor_initial, shift
			b chk32_crc_loop_common

		chk32_crc_loop_crc32:
			ldr shift, [pointer_table, shift]
			lsl xor_initial, xor_initial, #8          @ Slide 8 Bits of CRC Value
			eor xor_initial, xor_initial, shift

		chk32_crc_loop_common:
			add i, i, #1
			b chk32_crc_loop

	chk32_crc_common:
		eor r0, xor_initial, xor_final
		pop {r4-r9,pc}

.unreq pointer_data
.unreq length_data
.unreq xor_initial
.unreq xor_final
.unreq pointer_table
.unreq crc_type
.unreq shift_bit
.unreq i
.unreq byte
.unreq shift

