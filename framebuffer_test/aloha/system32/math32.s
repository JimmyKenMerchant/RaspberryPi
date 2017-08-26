/**
 * math32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.globl MATH32_PI32
MATH32_PI32: .float 3.14159265358979
.balign 8

.globl MATH32_PI_PER_DEGREE32
MATH32_PI_PER_DEGREE32: .float 0.0174532925199433
.balign 8


/**
 * function math32_degree_to_radian32
 * Return Radian from Degrees
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Parameters
 * r0: Degrees, Must Be Type of Signed Integer
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_degree_to_radian32
math32_degree_to_radian32:
	/* Auto (Local) Variables, but just aliases */
	degree         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP/NEON Registers */
	vfp_degree     .req s0
	vfp_radian     .req s1
	vfp_pi_per_deg .req s2

	vpush {s0-s2}

	/**
	 * Radian = degrees X (pi Div by 180)
	 */
	vmov vfp_degree, degree
	vldr vfp_pi_per_deg, MATH32_PI_PER_DEGREE32
	vmul.f32 vfp_radian, vfp_degree, vfp_pi_per_deg
	vmov r0, vfp_radian

	math32_degree_to_radian32_common:
		vpop {s0-s2}
		mov pc, lr

.unreq degree
.unreq vfp_degree
.unreq vfp_radian
.unreq vfp_pi_per_deg


/**
 * function math32_sin32
 * Return sin(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 4
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_sin32
math32_sin32:
	/* Auto (Local) Variables, but just aliases */
	radian        .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP/NEON Registers */
	vfp_radian    .req s0
	vfp_dividend  .req s1
	vfp_divisor   .req s2
	vfp_temp      .req s3
	vfp_sum       .req s4

	vpush {s0-s4}

	/**
	 * sinx = Sigma[n = 0 to Infinity] (-1)^n X x^(2n+1) Div by (2n+1)!
	 * For All x
	 */
	vmov vfp_radian, radian                         @ n = 0
	vmov vfp_sum, vfp_radian

	vmov vfp_dividend, vfp_radian                   @ n = 1
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Third Power
	vmov vfp_divisor, #6.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vsub.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 2
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Fifth Power
	vmov vfp_temp, #20.0 
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 120.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 3
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Seventh Power
	vmov vfp_temp, #21.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp
	vmov vfp_temp, #2.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 5040.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vsub.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 4
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Nineth Power
	vmov vfp_temp, #24.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp
	vmov vfp_temp, #3.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 362880.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov r0, vfp_sum

	math32_sin32_common:
		vpop {s0-s4}
		mov pc, lr

.unreq radian
.unreq vfp_radian
.unreq vfp_dividend
.unreq vfp_divisor
.unreq vfp_temp
.unreq vfp_sum


/**
 * function math32_cos32
 * Return cos(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 4
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_cos32
math32_cos32:
	/* Auto (Local) Variables, but just aliases */
	radian        .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP/NEON Registers */
	vfp_radian    .req s0
	vfp_dividend  .req s1
	vfp_divisor   .req s2
	vfp_temp      .req s3
	vfp_sum       .req s4

	vpush {s0-s4}

	/**
	 * cosx = Sigma[n = 0 to Infinity] (-1)^n X x^(2n) Div by (2n)!
	 * For All x
	 */
	vmov vfp_radian, radian                         @ n = 0
	vmov vfp_sum, vfp_radian

	vmov vfp_dividend, vfp_radian                   @ n = 1
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Second Power
	vmov vfp_divisor, #2.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vsub.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 2
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Fourth Power
	vmov vfp_temp, #12.0 
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 24.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 3
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Sixth Power
	vmov vfp_temp, #30.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 720.0 
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vsub.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 4
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Eighth Power
	vmov vfp_temp, #2.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp
	vmov vfp_temp, #28.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 40320.0 
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov r0, vfp_sum

	math32_cos32_common:
		vpop {s0-s4}
		mov pc, lr

.unreq radian
.unreq vfp_radian
.unreq vfp_dividend
.unreq vfp_divisor
.unreq vfp_temp
.unreq vfp_sum


/**
 * function math32_tan32
 * Return tan(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 5 
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float, Must be |Radian| < pi, -pi through pi
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_tan32
math32_tan32:
	/* Auto (Local) Variables, but just aliases */
	radian        .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP/NEON Registers */
	vfp_radian    .req s0
	vfp_dividend  .req s1
	vfp_divisor   .req s2
	vfp_temp      .req s3
	vfp_sum       .req s4

	vpush {s0-s4}

	/**
	 * tanx = Sigma[n = 1 to Infinity] (B2n X (-4)^n X (1 - 4^n)) X x^(2n - 1) Div by (2n)!
	 * for |x| < pi Div by 2, because Tangent is 180 degrees cycle unlike Sin and Cosin
	 * B is Bernoulli Number
	 */
	vmov vfp_radian, radian                         @ n = 1
	vmov vfp_sum, vfp_radian

	vmov vfp_dividend, vfp_radian                   @ n = 2
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Third Power
	vmov vfp_divisor, #3.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 3
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Fifth Power
	vmov vfp_temp, #2.0
	vmul.f32 vfp_dividend, vfp_dividend, vfp_temp   @ Multiplication by 2 
	vmov vfp_temp, #5.0 
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 15.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 4
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Seventh Power
	vmov vfp_temp, #17.0
	vmul.f32 vfp_dividend, vfp_dividend, vfp_temp   @ Multiplication by 17
	vmov vfp_temp, #21.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 315.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 5
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Ninth Power
	vmov vfp_temp, #31.0
	vmul.f32 vfp_dividend, vfp_dividend, vfp_temp
	vmov vfp_temp, #2.0
	vmul.f32 vfp_dividend, vfp_dividend, vfp_temp   @ Multiplication by 62 (31 by 2)
	vmov vfp_temp, #9.0
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 2835.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov r0, vfp_sum

	math32_tan32_common:
		vpop {s0-s4}
		mov pc, lr

.unreq radian
.unreq vfp_radian
.unreq vfp_dividend
.unreq vfp_divisor
.unreq vfp_temp
.unreq vfp_sum


/**
 * function math32_float_to_string32
 * Make String of Single Precision Float Value
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Parameters
 * r0: Float Value, Must Be Type of Single Precision Float
 *
 * Usage: r0
 * Return: r0 (Pointer of String)
 */
.globl math32_float_to_string32
math32_float_to_string32:
	/* Auto (Local) Variables, but just aliases */
	float         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	integer       .req r1
	decimal       .req r2
	heap          .req r3

	/* VFP/NEON Registers */
	vfp_float     .req s0
	vfp_integer   .req s1
	vfp_decimal   .req s2

	vpush {s0-s2}

	vmov vfp_float, float
	vmov vfp_integer, float
	vmov vfp_decimal, float
	vcvt.s32.f32 vfp_integer, vfp_integer           @ Round Down
	vmov integer, vfp_integer
	vcvt.f32.s32 vfp_integer, vfp_integer
	vsub.f32 vfp_decimal, vfp_decimal, vfp_integer  @ Cut Integer Part

	/* Repeat of vfp_decimal X 10^8 and Cut it till catch Zero */

	/* Caution! It's Half Way */

	math32_float_to_string32_common:
		vpop {s0-s2}
		mov pc, lr

.unreq float
.unreq integer
.unreq decimal
.unreq heap
.unreq vfp_float
.unreq vfp_integer
.unreq vfp_decimal


/**
 * function math32_int32_to_string_hexa
 * Make String of Integer Value by Hexadecimal System (Base 16)
 *
 * Parameters
 * r0: Integer Number
 * r1: Maximum Length of Integer from Left Side
 * r2: 0 unsigned, 1 signed
 * r3: 0 Doesn't Show Bases Mark, 1 Shows Bases Mark(`0x`)
 *
 * Usage: r0-r9
 * Return: r0 (Pointer of String, If Zero, Memory Space for String Can't Be Allocated)
 */
.globl math32_int32_to_string_hexa
math32_int32_to_string_hexa:
	/* Auto (Local) Variables, but just aliases */
	integer     .req r0
	max_length  .req r1
	signed      .req r2
	base_mark  .req r3
	temp        .req r4
	mask        .req r5
	heap        .req r6
	heap_origin .req r7
	heap_size   .req r8
	count       .req r9

	push {r4-r9}

	push {r0-r3,lr}
	bl math32_count_zero32
	mov count, r0
	pop {r0-r3,lr}

	cmp signed, #1
	cmpeq count, #0                         @ Whether Top Bit is One or Zero
	movne signed, #0                        @ If Count Is Not Zero, Signed Will Perform The Same as Unsigned
	bne math32_int32_to_string_hexa_jumpunsigned

		/* Process for Minus Signed */
		mvn integer, integer                           @ All Inverter
		add integer, #1                                @ Convert Value from Minus Signed Number to Plus Signed Number
		push {r0-r3,lr}
		bl math32_count_zero32
		mov count, r0
		pop {r0-r3,lr}

	math32_int32_to_string_hexa_jumpunsigned:
		mov temp, count
		mov count, #0

	math32_int32_to_string_hexa_arrangecount:
		subs temp, temp, #4
		addge count, #1
		bge math32_int32_to_string_hexa_arrangecount

	mov temp, #8
	sub count, temp, count
	cmp count, max_length
	movlt count, max_length

	mov heap_size, #1                               @ 1 Size is 4 bytes in Heap
	mov temp, count
	add temp, temp, #1                              @ Add One for Null Character
	cmp signed, #1
	addeq temp, temp, #1                            @ Add One for Minus Character
	cmp base_mark, #1
	addeq temp, temp, #2                            @ Add Two for Bases Mark, `0x`

	math32_int32_to_string_hexa_countsize:
		subs temp, temp, #4
		addgt heap_size, #1
		bgt math32_int32_to_string_hexa_countsize

	push {r0-r3,lr}
	mov r0, heap_size
	bl system32_malloc
	mov heap_origin, r0
	pop {r0-r3,lr}

	cmp heap_origin, #0
	beq math32_int32_to_string_hexa_error
	mov heap, heap_origin

	cmp signed, #1
	bne math32_int32_to_string_hexa_basesmark       @ If Unsigned, Jump to Next
	mov mask, #0x2D
	strb mask, [heap]                               @ Store Minus Sign
	add heap, heap, #1

	math32_int32_to_string_hexa_basesmark:
		cmp base_mark, #1
		bne math32_int32_to_string_hexa_loop
		mov mask, #0x30
		strb mask, [heap]                       @ Store `0`
		add heap, heap, #1
		mov mask, #0x78
		strb mask, [heap]                       @ Store `x`
		add heap, heap, #1
	
	math32_int32_to_string_hexa_loop:
		sub count, count, #1
		cmp count, #0
		blt math32_int32_to_string_hexa_loop_common
		lsl count, #2                               @ Substitution of Multiplication by 4
		mov mask, #0xF
		lsl mask, count
		and mask, integer, mask
		lsr mask, count
		cmp mask, #9
		addle mask, mask, #0x30                     @ Ascii Table Number Offset
		addgt mask, mask, #0x37                     @ Ascii Table Alphabet Offset - 9
		strb mask, [heap]
		add heap, heap, #1
		lsr count, #2                               @ Substitution of Division by 4
		b math32_int32_to_string_hexa_loop

		math32_int32_to_string_hexa_loop_common:
			mov mask, #0
			strb mask, [heap]
			b math32_int32_to_string_hexa_success

	math32_int32_to_string_hexa_error:
		mov r0, #0
		b math32_int32_to_string_hexa_common

	math32_int32_to_string_hexa_success:
		mov r0, heap_origin

	math32_int32_to_string_hexa_common:
		pop {r4-r9}
		mov pc, lr

.unreq integer
.unreq max_length
.unreq signed
.unreq base_mark
.unreq temp
.unreq mask
.unreq heap
.unreq heap_origin
.unreq heap_size
.unreq count


/**
 * function math32_count_zero32
 * Count Leading Zero from Most Siginificant Bit in 32 Bit Register
 *
 * Parameters
 * r0: Register to Count
 *
 * Usage: r0-r3
 * Return: r0 (Count)
 */
.globl math32_count_zero32
math32_count_zero32:
	/* Auto (Local) Variables, but just aliases */
	register      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	mask          .req r1
	base          .req r2
	count         .req r3

	mov mask, #0x80000000              @ Most Siginificant Bit
	mov count, #0

	math32_count_zero32_loop:
		cmp count, #32
		beq math32_count_zero32_common @ If All Zero

		and base, register, mask
		teq base, mask                 @ Similar to EORS (Exclusive OR)
		addne count, count, #1         @ No Zero flag (This Means The Bit is Zero)
		lsrne mask, mask, #1
		bne math32_count_zero32_loop   @ If the Bit is Zero

	math32_count_zero32_common:
		mov r0, count
		mov pc, lr

.unreq register
.unreq mask
.unreq base
.unreq count


/**
 * function math32_hexa_to_deci32
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
.globl math32_hexa_to_deci32
math32_hexa_to_deci32:
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

	math32_hexa_to_deci32_loop:
		mov bitmask, #0xf                         @ 0b1111
		mul shift, i, mul_number
		lsl bitmask, bitmask, shift               @ Make bitmask
		and bitmask, dup_hexa, bitmask
		lsr bitmask, bitmask, shift               @ Make One Digit Number

		cmp i, #0
		ldreq math32_power_lower, math32_power_0                @ 16^0
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #1
		ldreq math32_power_lower, math32_power_1                @ 16^1
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #2
		ldreq math32_power_lower, math32_power_2                @ 16^2
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #3
		ldreq math32_power_lower, math32_power_3                @ 16^3
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #4
		ldreq math32_power_lower, math32_power_4                @ 16^4
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #5
		ldreq math32_power_lower, math32_power_5                @ 16^5
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #6
		ldreq math32_power_lower, math32_power_6                @ 16^6
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #7
		ldreq math32_power_lower, math32_power_7_lower          @ 16^7 Lower Bits
		ldreq math32_power_upper, math32_power_7_upper          @ 16^7 Upper Bits

		math32_hexa_to_deci32_loop_loop:

			cmp bitmask, #0
			ble math32_hexa_to_deci32_loop_common

			push {lr}
			bl math32_decimal_adder64
			pop {lr}

			sub bitmask, bitmask, #1

			b math32_hexa_to_deci32_loop_loop

		math32_hexa_to_deci32_loop_common:

			add i, i, #1
			cmp i, #8
			blt math32_hexa_to_deci32_loop

	math32_hexa_to_deci32_common:
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
 * function math32_decimal_adder64
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
.globl math32_decimal_adder64
math32_decimal_adder64:
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

	math32_decimal_adder64_loop:
		mov bitmask_1, #0xf                            @ 0b1111
		mov bitmask_2, #0xf

		mul shift, i, mul_number

		cmp i, #8
		bge math32_decimal_adder64_loop_uppernumber

		/* Lower Number */
		lsl bitmask_1, bitmask_1, shift
		lsl bitmask_2, bitmask_2, shift

		and bitmask_1, dup_lower_1, bitmask_1
		and bitmask_2, lower_2, bitmask_2

		b math32_decimal_adder64_loop_adder

		/* Upper Number */
		math32_decimal_adder64_loop_uppernumber:

			sub shift, shift, #32

			lsl bitmask_1, bitmask_1, shift
			lsl bitmask_2, bitmask_2, shift

			and bitmask_1, dup_upper_1, bitmask_1
			and bitmask_2, upper_2, bitmask_2

		math32_decimal_adder64_loop_adder:
		
			lsr bitmask_1, bitmask_1, shift
			lsr bitmask_2, bitmask_2, shift

			add bitmask_1, bitmask_1, bitmask_2
			add bitmask_1, bitmask_1, carry_flag

			cmp bitmask_1, #0x10
			bge math32_decimal_adder64_loop_adder_hexacarry

			cmp bitmask_1, #0x0A
			bge math32_decimal_adder64_loop_adder_decicarry

			mov carry_flag, #0                      @ Clear Carry

			b math32_decimal_adder64_loop_common	

			math32_decimal_adder64_loop_adder_hexacarry:

				sub bitmask_1, #0x10
				add bitmask_1, #0x06 
				mov carry_flag, #1              @ Set Carry

				b math32_decimal_adder64_loop_common

			math32_decimal_adder64_loop_adder_decicarry:

				sub bitmask_1, #0x0A
				mov carry_flag, #1              @ Set Carry

		math32_decimal_adder64_loop_common:
			lsl bitmask_1, bitmask_1, shift

			cmp i, #8
			bge math32_decimal_adder64_loop_common_uppernumber

			/* Lower Number */
			add lower_1, lower_1, bitmask_1

			b math32_decimal_adder64_loop_common_common

			/* Upper Number */
			math32_decimal_adder64_loop_common_uppernumber:

				add upper_1, upper_1, bitmask_1

			math32_decimal_adder64_loop_common_common:

				add i, i, #1
				cmp i, #16
				blt math32_decimal_adder64_loop

				cmp carry_flag, #1
				beq math32_decimal_adder64_error

	math32_decimal_adder64_success:
		b math32_decimal_adder64_common

	math32_decimal_adder64_error:
		mov r0, #0                                      @ Return with Error
		mov r1, #0

	math32_decimal_adder64_common:
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
