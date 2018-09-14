/**
 * bit32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function bit32_count_zero32
 * Count Leading Zero from Most Siginificant Bit in 32 Bit Register
 *
 * Parameters
 * r0: Register to Count
 *
 * Usage: r0-r3
 * Return: r0 (Number of Count of Leading Zero)
 */
.globl bit32_count_zero32
bit32_count_zero32:
	/* Auto (Local) Variables, but just Aliases */
	register      .req r0
	mask          .req r1
	base          .req r2
	count         .req r3

	mov mask, #0x80000000              @ Most Siginificant Bit
	mov count, #0

	bit32_count_zero32_loop:
		cmp count, #32
		beq bit32_count_zero32_common @ If All Zero

		and base, register, mask
		teq base, mask                 @ Similar to EORS (Exclusive OR)
		addne count, count, #1         @ No Zero flag (This Means The Bit is Zero)
		lsrne mask, mask, #1
		bne bit32_count_zero32_loop   @ If the Bit is Zero

	bit32_count_zero32_common:
		mov r0, count
		mov pc, lr

.unreq register
.unreq mask
.unreq base
.unreq count


/**
 * function bit32_convert_endianness
 * Convert Endianness
 *
 * Parameters
 * r0: Pointer of Data to Convert Endianness
 * r1: Size of Data
 * r2: Align Bytes to Be Convert Endianness (2/4)
 *
 * Usage: r0-r7
 * Return: r0 (0 as success, 1 as error)
 * Error: Align Bytes is not 2/4
 */
.globl bit32_convert_endianness
bit32_convert_endianness:
	/* Auto (Local) Variables, but just Aliases */
	data_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	size            .req r1 @ Parameter, Register for Argument, Scratch Register
	align_bytes     .req r2 @ Parameter, Register for Argument, Scratch Register
	swap_1          .req r3 @ Scratch Register
	swap_2          .req r4
	convert_result  .req r5
	i               .req r6
	j               .req r7

	push {r4-r7}

	cmp align_bytes, #4
	cmpne align_bytes, #2
	bne bit32_convert_endianness_error

	add size, size, data_point

	bit32_convert_endianness_loop:
		cmp data_point, size
		bhs bit32_convert_endianness_success

		cmp align_bytes, #4
		ldreq swap_1, [data_point]
		cmp align_bytes, #2
		ldreqh swap_1, [data_point]

		mov convert_result, #0

		mov i, #0
		cmp align_bytes, #4
		moveq j, #24
		cmp align_bytes, #2
		moveq j, #8

		bit32_convert_endianness_loop_byte:
			cmp j, #0
			blt bit32_convert_endianness_loop_byte_common

			lsr swap_2, swap_1, i
			and swap_2, swap_2, #0xFF
			lsl swap_2, swap_2, j
			add convert_result, convert_result, swap_2
			add i, i, #8
			sub j, j, #8

			b bit32_convert_endianness_loop_byte

			bit32_convert_endianness_loop_byte_common:
				cmp align_bytes, #4
				streq convert_result, [data_point]
				addeq data_point, data_point, #4
				cmp align_bytes, #2
				streqh convert_result, [data_point]
				addeq data_point, data_point, #2

				b bit32_convert_endianness_loop

	bit32_convert_endianness_error:
		mov r0, #1
		b bit32_convert_endianness_common

	bit32_convert_endianness_success:
		mov r0, #0

	bit32_convert_endianness_common:
		pop {r4-r7}
		mov pc, lr

.unreq data_point
.unreq size
.unreq align_bytes
.unreq swap_1
.unreq swap_2
.unreq convert_result
.unreq i
.unreq j


/**
 * function bit32_reflect_bit
 * Return Word Bits Are Reflected
 *
 * Parameters
 * r0: Value to Be Reflected
 * r1: Number of Bits to Be Reflected from LSB, 1 to 32
 *
 * Return: r0 (Word Bits Are Reflected)
 */
.globl bit32_reflect_bit
bit32_reflect_bit:
	/* Auto (Local) Variables, but just Aliases */
	value       .req r0
	number_bit  .req r1
	checkbit    .req r2
	orrbit      .req r3
	i           .req r4
	return      .req r5

	push {r4-r5,lr}

	sub number_bit, number_bit, #1
	mov checkbit, #0x00000001
	lsl checkbit, checkbit, number_bit
	mov orrbit, #0x00000001
	mov i, #0
	mov return, #0

	bit32_reflect_bit_loop:
		cmp i, number_bit
		bgt bit32_reflect_bit_common

		tst value, checkbit
		orrne return, return, orrbit

		lsr checkbit, checkbit, #1
		lsl orrbit, orrbit, #1
		add i, i, #1
		b bit32_reflect_bit_loop

	bit32_reflect_bit_common:
		mov r0, return
		pop {r4-r5,pc}

.unreq value
.unreq number_bit
.unreq checkbit
.unreq orrbit
.unreq i
.unreq return
