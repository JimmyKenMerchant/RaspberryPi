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
 * Cyclic Redundancy Check CRC7 (8-bit) by One Byte Big Endian (MSB Order)
 *
 * Parameters
 * r0: Pointer of Data to be Checked
 * r1: Length of Data (Bits)
 * r2: Bits as Divisor (Polynomial)
 * r3: Number of Bits Actually Checked, From 8
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
	number_bit     .req r3
	count_byte     .req r4
	count_bit      .req r5
	dividend       .req r6
	byte           .req r7
	temp           .req r8
	i              .req r9

	push {r4-r9,lr}

	cmp length_data, #0
	mvneq dividend, #0
	beq chk32_crc7_common

	and divisor, divisor, #0xFF
	orr divisor, divisor, #0x80               @ Bit[7] is Always High on CRC7

	mov count_byte, #0
	ldrb dividend, [pointer_data, count_byte]
	mov count_byte, #1
	mov count_bit, #8

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

			ldrb byte, [pointer_data, count_byte]
			mov count_bit, #0
			add count_byte, count_byte, #1

			chk32_crc7_calculate_shift_jump:

				lsl dividend, dividend, #1          @ Logical Shift Left with Previous Value

				/* Whether Targeted Bit is High */
				lsl byte, byte, #1
				tst byte, #0x100
				orrne dividend, dividend, #1

				add i, i, #1
				add count_bit, count_bit, #1
				b chk32_crc7_calculate

	chk32_crc7_common:
		mov r0, dividend
		pop {r4-r9,pc}

.unreq pointer_data
.unreq length_data
.unreq divisor
.unreq number_bit
.unreq count_byte
.unreq count_bit
.unreq dividend
.unreq byte
.unreq temp
.unreq i


/**
 * function chk32_crc16
 * Cyclic Redundancy Check CRC16 (17-bit) by One Byte Big Endian (MSB Order)
 *
 * Parameters
 * r0: Pointer of Data to be Checked
 * r1: Length of Data (Bits)
 * r2: Bits as Divisor (Polynomial), Omit Bit[16] (Always High) to Hide Overflow
 * r3: Number of Bits Actually Checked, From 17
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
	number_bit     .req r3
	count_byte     .req r4
	count_bit      .req r5
	dividend       .req r6
	byte           .req r7
	temp           .req r8
	i              .req r9

	push {r4-r9,lr}

	cmp length_data, #3
	mvnlo dividend, #0
	blo chk32_crc16_common

	/* Omit Bit[16] (Always High on CRC16) to Fit 16-bit */
	mov temp, #0xFF00
	orr temp, temp, #0x00FF
	and divisor, divisor, temp

	mov count_byte, #0
	ldrb temp, [pointer_data, count_byte]
	lsl dividend, temp, #8
	mov count_byte, #1
	ldrb temp, [pointer_data, count_byte]
	orr dividend, dividend, temp
	add count_byte, count_byte, #1
	mov count_bit, #8

	mov i, #16

	chk32_crc16_calculate:
		cmp i, number_bit
		bhs chk32_crc16_common

		cmp count_bit, #8
		blo chk32_crc16_calculate_jump

		cmp count_byte, length_data
		bhs chk32_crc16_common

		ldrb byte, [pointer_data, count_byte]
		mov count_bit, #0
		add count_byte, count_byte, #1

		chk32_crc16_calculate_jump:

			lsl dividend, dividend, #1          @ Logical Shift Left with Previous Value

			/* Whether Targeted Bit is High */
			lsl byte, byte, #1
			tst byte, #0x100
			orrne dividend, dividend, #1

			/* To Omit Bit[17] of Divisor, Calculate After Shift */
			tst dividend, #0x10000
			bicne dividend, dividend, #0x10000
			eorne dividend, dividend, divisor

			add i, i, #1
			add count_bit, count_bit, #1
			b chk32_crc16_calculate

	chk32_crc16_common:
		mov r0, dividend
		pop {r4-r9,pc}

.unreq pointer_data
.unreq length_data
.unreq divisor
.unreq number_bit
.unreq count_byte
.unreq count_bit
.unreq dividend
.unreq byte
.unreq temp
.unreq i
