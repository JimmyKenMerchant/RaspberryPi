/**
 * math32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function hexa_to_deci32
 * Convert Hexadecimal Bases (0-f) to Decimal Bases (0-9) of a Register
 *
 * Parameters
 * r0: Register to Be Converted
 *
 * Usage: r0-r11, r0 reused
 * Return: r0 (Lower Bits of Return Number), r1 (Upper Bits of Return Number), if all zero, may be error
 * Error(r0:0x0, r1:0x0): This function could not calculate because of digit-overflow.
 * External Variable(s): math32_power_0-6, math32_power_7_lower, math32_power_7_upper
 */
.globl hexa_to_deci32
hexa_to_deci32:
	/* Auto (Local) Variables, but just aliases */
	hexa               .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	deci_upper         .req r1
	math32_power_lower .req r2
	math32_power_upper .req r3
	dup_hexa           .req r4
	mul_number         .req r5
	i                  .req r6
	shift              .req r7
	bitmask            .req r8

	push {r4-r8}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov dup_hexa, hexa
	
	.unreq hexa
	deci_lower .req r0

	mov deci_lower, #0
	mov deci_upper, #0
	mov math32_power_upper, #0

	mov i, #0
	mov mul_number, #4

	hexa_to_deci32_loop:
		mov bitmask, #0xf                         @ 0b1111
		mul shift, i, mul_number
		lsl bitmask, bitmask, shift               @ Make bitmask
		and bitmask, dup_hexa, bitmask
		lsr bitmask, bitmask, shift               @ Make One Digit Number

		cmp i, #0
		ldreq math32_power_lower, math32_power_0                @ 16^0
		beq hexa_to_deci32_loop_loop

		cmp i, #1
		ldreq math32_power_lower, math32_power_1                @ 16^1
		beq hexa_to_deci32_loop_loop

		cmp i, #2
		ldreq math32_power_lower, math32_power_2                @ 16^2
		beq hexa_to_deci32_loop_loop

		cmp i, #3
		ldreq math32_power_lower, math32_power_3                @ 16^3
		beq hexa_to_deci32_loop_loop

		cmp i, #4
		ldreq math32_power_lower, math32_power_4                @ 16^4
		beq hexa_to_deci32_loop_loop

		cmp i, #5
		ldreq math32_power_lower, math32_power_5                @ 16^5
		beq hexa_to_deci32_loop_loop

		cmp i, #6
		ldreq math32_power_lower, math32_power_6                @ 16^6
		beq hexa_to_deci32_loop_loop

		cmp i, #7
		ldreq math32_power_lower, math32_power_7_lower          @ 16^7 Lower Bits
		ldreq math32_power_upper, math32_power_7_upper          @ 16^7 Upper Bits

		hexa_to_deci32_loop_loop:

			cmp bitmask, #0
			ble hexa_to_deci32_loop_common

			push {lr}
			bl decimal_adder64
			pop {lr}

			sub bitmask, bitmask, #1

			b hexa_to_deci32_loop_loop

		hexa_to_deci32_loop_common:

			add i, i, #1
			cmp i, #8
			blt hexa_to_deci32_loop

	hexa_to_deci32_common:
		pop {r4-r8}     @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		mov pc, lr

/* Variables */
.balign 4
math32_power_0:       .word 0x00000001 @ 16^0
math32_power_1:       .word 0x00000016 @ 16^1
math32_power_2:       .word 0x00000256 @ 16^2
math32_power_3:       .word 0x00004096 @ 16^3
math32_power_4:       .word 0x00065536 @ 16^4
math32_power_5:       .word 0x01048576 @ 16^5
math32_power_6:       .word 0x16777216 @ 16^6
math32_power_7_lower: .word 0x68435456 @ 16^7 Lower Bits
math32_power_7_upper: .word 0x00000002 @ 16^7 Upper Bits
.balign 4

.unreq deci_lower
.unreq deci_upper
.unreq math32_power_lower
.unreq math32_power_upper
.unreq dup_hexa
.unreq mul_number
.unreq i
.unreq shift
.unreq bitmask


/**
 * function decimal_adder64
 * Addition with Decimal Bases (0-9)
 *
 * Parameters
 * r0: Lower Bits of First Number, needed between 0-9 in all digits
 * r1: Upper Bits of First Number, needed between 0-9 in all digits
 * r2: Lower Bits of Second Number, needed between 0-9 in all digits
 * r3: Upper Bits of Second Number, needed between 0-9 in all digits
 *
 * Usage: r0-r11
 * Return: r0 (Lower Bits of Return Number), r1 (Upper Bits of Return Number), if all zero, may be error
 * Error: This function could not calculate because of digit-overflow.
 */
.globl decimal_adder64
decimal_adder64:
	/* Auto (Local) Variables, but just aliases */
	lower_1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	upper_1        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	lower_2        .req r2 @ Parameter, Register for Argument, Scratch Register
	upper_2        .req r3 @ Parameter, Register for Argument, Scratch Register
	dup_lower_1    .req r4 @ Duplication of lower_1
	dup_upper_1    .req r5 @ Duplication of upper_1
	mul_number     .req r6
	i              .req r7
	shift          .req r8
	bitmask_1      .req r9
	bitmask_2      .req r10
	carry_flag     .req r11

	push {r4-r11}   @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			@ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov dup_lower_1, lower_1
	mov dup_upper_1, upper_1
	mov lower_1, #0
	mov upper_1, #0
	mov carry_flag, #0

	mov i, #0
	mov mul_number, #4

	decimal_adder64_loop:
		mov bitmask_1, #0xf                            @ 0b1111
		mov bitmask_2, #0xf

		mul shift, i, mul_number

		cmp i, #8
		bge decimal_adder64_loop_uppernumber

		/* Lower Number */
		lsl bitmask_1, bitmask_1, shift
		lsl bitmask_2, bitmask_2, shift

		and bitmask_1, dup_lower_1, bitmask_1
		and bitmask_2, lower_2, bitmask_2

		b decimal_adder64_loop_adder

		/* Upper Number */
		decimal_adder64_loop_uppernumber:

			sub shift, shift, #32

			lsl bitmask_1, bitmask_1, shift
			lsl bitmask_2, bitmask_2, shift

			and bitmask_1, dup_upper_1, bitmask_1
			and bitmask_2, upper_2, bitmask_2

		decimal_adder64_loop_adder:
		
			lsr bitmask_1, bitmask_1, shift
			lsr bitmask_2, bitmask_2, shift

			add bitmask_1, bitmask_1, bitmask_2
			add bitmask_1, bitmask_1, carry_flag

			cmp bitmask_1, #0x10
			bge decimal_adder64_loop_adder_hexacarry

			cmp bitmask_1, #0x0A
			bge decimal_adder64_loop_adder_decicarry

			mov carry_flag, #0                      @ Clear Carry

			b decimal_adder64_loop_common	

			decimal_adder64_loop_adder_hexacarry:

				sub bitmask_1, #0x10
				add bitmask_1, #0x06 
				mov carry_flag, #1              @ Set Carry

				b decimal_adder64_loop_common

			decimal_adder64_loop_adder_decicarry:

				sub bitmask_1, #0x0A
				mov carry_flag, #1              @ Set Carry

		decimal_adder64_loop_common:
			lsl bitmask_1, bitmask_1, shift

			cmp i, #8
			bge decimal_adder64_loop_common_uppernumber

			/* Lower Number */
			add lower_1, lower_1, bitmask_1

			b decimal_adder64_loop_common_common

			/* Upper Number */
			decimal_adder64_loop_common_uppernumber:

				add upper_1, upper_1, bitmask_1

			decimal_adder64_loop_common_common:

				add i, i, #1
				cmp i, #16
				blt decimal_adder64_loop

				cmp carry_flag, #1
				beq decimal_adder64_error

	decimal_adder64_success:
		b decimal_adder64_common

	decimal_adder64_error:
		mov r0, #0                                      @ Return with Error
		mov r1, #0

	decimal_adder64_common:
		pop {r4-r11}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
			        @ similar to `LDMIA r13! {r4-r11}` Increment After, r13 (SP) Saves Incremented Number

		mov pc, lr

.unreq lower_1
.unreq upper_1
.unreq lower_2
.unreq upper_2
.unreq dup_lower_1
.unreq dup_upper_1
.unreq mul_number
.unreq i
.unreq shift
.unreq bitmask_1
.unreq bitmask_2
.unreq carry_flag
