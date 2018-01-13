/**
 * math32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function math32_round_pi32
 * Return Rounded Radian Between -Pi to Pi with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_round_pi32
math32_round_pi32:
	/* Auto (Local) Variables, but just Aliases */
	radian         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_radian     .req s0
	vfp_pi         .req s1
	vfp_pi_neg     .req s2
	vfp_pi_double  .req s3

	vpush {s0-s3}

	vmov vfp_radian, radian
	vldr vfp_pi, MATH32_PI32
	vneg.f32 vfp_pi_neg, vfp_pi
	vldr vfp_pi_double, MATH32_PI_DOUBLE32

	vcmp.f32 vfp_radian, vfp_pi
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	bgt math32_round_pi32_over

	vcmp.f32 vfp_radian, vfp_pi_neg
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	blt math32_round_pi32_under

	b math32_round_pi32_common

	math32_round_pi32_over:
		vsub.f32 vfp_radian, vfp_radian, vfp_pi_double
		vcmp.f32 vfp_radian, vfp_pi
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		bgt math32_round_pi32_over
		b math32_round_pi32_common

	math32_round_pi32_under:
		vadd.f32 vfp_radian, vfp_radian, vfp_pi_double
		vcmp.f32 vfp_radian, vfp_pi_neg
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		blt math32_round_pi32_under

	math32_round_pi32_common:
		vmov radian, vfp_radian
		vpop {s0-s3}
		mov pc, lr

.unreq radian
.unreq vfp_radian
.unreq vfp_pi
.unreq vfp_pi_neg
.unreq vfp_pi_double


/**
 * function math32_round_degree32
 * Return Rounded Degrees Between 0 to 360 with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Degrees, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_round_degree32
math32_round_degree32:
	/* Auto (Local) Variables, but just Aliases */
	degree         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	full           .req r1

	/* VFP Registers */
	vfp_degree     .req s0
	vfp_full       .req s1

	vpush {s0-s1}

	vmov vfp_degree, degree

	mov full, #360
	vmov vfp_full, full
	vcvt.f32.u32 vfp_full, vfp_full

	vcmp.f32 vfp_degree, vfp_full
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	bgt math32_round_degree32_over

	vcmp.f32 vfp_degree, #0
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	blt math32_round_degree32_under

	b math32_round_degree32_common

	math32_round_degree32_over:
		vsub.f32 vfp_degree, vfp_degree, vfp_full
		vcmp.f32 vfp_degree, vfp_full
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		bgt math32_round_degree32_over
		b math32_round_degree32_common

	math32_round_degree32_under:
		vadd.f32 vfp_degree, vfp_degree, vfp_full
		vcmp.f32 vfp_degree, #0
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		blt math32_round_degree32_under

	math32_round_degree32_common:
		vmov degree, vfp_degree
		vpop {s0-s1}
		mov pc, lr

.unreq degree
.unreq full
.unreq vfp_degree
.unreq vfp_full


.globl MATH32_PI32
MATH32_PI32:             .word 0x40490fdb @ (.float 3.14159265359)
.balign 8

.globl MATH32_PI_DOUBLE32
MATH32_PI_DOUBLE32:      .word 0x40c90fdb @ (.float 6.28318530718)
.balign 8

.globl MATH32_PI_HALF32
MATH32_PI_HALF32:        .word 0x3fc90fdb @ (.float 1.57079632679)
.balign 8

.globl MATH32_PI_PER_DEGREE32
MATH32_PI_PER_DEGREE32:  .word 0x3c8efa35 @ (.float 0.01745329252)
.balign 8


/**
 * function math32_degree_to_radian32
 * Return Radian from Degrees
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Degrees, Must Be Type of Single Precision Float
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_degree_to_radian32
math32_degree_to_radian32:
	/* Auto (Local) Variables, but just Aliases */
	degree         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
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

	math32_degree_to_radian32_common:
		vmov r0, vfp_radian
		vpop {s0-s2}
		mov pc, lr

.unreq degree
.unreq vfp_degree
.unreq vfp_radian
.unreq vfp_pi_per_deg


/**
 * function math32_sin32
 * Return Sine by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 4
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_sin32
math32_sin32:
	/* Auto (Local) Variables, but just Aliases */
	radian        .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_radian    .req s0
	vfp_dividend  .req s1
	vfp_divisor   .req s2
	vfp_temp      .req s3
	vfp_sum       .req s4
	vfp_pi        .req s5
	vfp_pi_half   .req s6

	vpush {s0-s6}

	/* Ensure Radian is Between -Pi to Pi */

	push {lr}
	bl math32_round_pi32
	pop {lr}

	vmov vfp_radian, radian
	vldr vfp_pi, MATH32_PI32
	vldr vfp_pi_half, MATH32_PI_HALF32

	vabs.f32 vfp_temp, vfp_radian
	vcmp.f32 vfp_temp, vfp_pi_half
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	ble math32_sin32_jump

	vsub.f32 vfp_temp, vfp_pi
	vcmp.f32 vfp_radian, #0
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	vneggt.f32 vfp_temp, vfp_temp                   @ If Original Radian is Positive, Make Value Positive
	vmov vfp_radian, vfp_temp
	
	math32_sin32_jump:

		/**
		 * sinx = Sigma[n = 0 to Infinity] (-1)^n X x^(2n+1) Div by (2n+1)!
		 * For All x
		 */

		.unreq radian
		temp .req r0
		vcmp.f32 vfp_radian, #0
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		vmov vfp_sum, vfp_radian                        @ n = 0
		beq math32_sin32_common

		vmov vfp_dividend, vfp_radian                   @ n = 1
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Third Power
		mov temp, #6
		vmov vfp_divisor, temp
		vcvt.f32.s32 vfp_divisor, vfp_divisor
		vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
		vsub.f32 vfp_sum, vfp_sum, vfp_dividend

		vmov vfp_dividend, vfp_radian                   @ n = 2
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Fifth Power
		mov temp, #20
		vmov vfp_temp, temp
		vcvt.f32.s32 vfp_temp, vfp_temp
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
		mov temp, #42
		vmov vfp_temp, temp
		vcvt.f32.s32 vfp_temp, vfp_temp
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
		mov temp, #72
		vmov vfp_temp, temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 362880.0
		vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
		vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	math32_sin32_common:
		vmov r0, vfp_sum
		vpop {s0-s6}
		mov pc, lr

.unreq temp
.unreq vfp_radian
.unreq vfp_dividend
.unreq vfp_divisor
.unreq vfp_temp
.unreq vfp_sum
.unreq vfp_pi
.unreq vfp_pi_half


/**
 * function math32_cos32
 * Return Cosine by Single Precision Float, Using Sine's Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_cos32
math32_cos32:
	/* Auto (Local) Variables, but just Aliases */
	radian        .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_radian    .req s0
	vfp_pi_half   .req s1

	vpush {s0-s1}

	/**
	 * Sin( Theta + Pi/2 ) = Cos( Theta )
	 */
	vmov vfp_radian, radian
	vldr vfp_pi_half, MATH32_PI_HALF32
	vadd.f32 vfp_radian, vfp_radian, vfp_pi_half
	vmov radian, vfp_radian

	push {lr}
	bl math32_sin32
	pop {lr}

	/**
	 * Not Used, But Cosine's Series is Shown as Below 
	 * cosx = Sigma[n = 0 to Infinity] (-1)^n X x^(2n) Div by (2n)!
	 * For All x
	 */

	math32_cos32_common:
		vpop {s0-s1}
		mov pc, lr

.unreq radian
.unreq vfp_radian
.unreq vfp_pi_half


/**
 * function math32_tan32
 * Return Tangent by Single Precision Float, Using Sine's Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_tan32
math32_tan32:
	/* Auto (Local) Variables, but just Aliases */
	radian     .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_sin    .req s0
	vfp_cos    .req s1

	vpush {s0-s1}

	push {r0,lr}
	bl math32_sin32
	vmov vfp_sin, r0
	pop {r0,lr}

	push {r0,lr}
	bl math32_cos32
	vmov vfp_cos, r0
	pop {r0,lr}

	vcmp.f32 vfp_cos, #0
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	moveq r0, #0
	beq math32_tan32_common
	
	vdiv.f32 vfp_sin, vfp_sin, vfp_cos
	vmov r0, vfp_sin

	/**
	 * Not Used, But Tangent's Series is Shown as Below 
	 * tanx = Sigma[n = 1 to Infinity] (B2n X (-4)^n X (1 - 4^n)) X x^(2n - 1) Div by (2n)!
	 * for |x| < pi Div by 2, because Tangent is 180 degrees cycle unlike Sin and Cosin
	 * B is Bernoulli Number
	 */

	math32_tan32_common:
		vpop {s0-s1}
		mov pc, lr

.unreq radian
.unreq vfp_sin
.unreq vfp_cos


/**
 * function math32_mat32_multiply
 * Multiplies Two Matrix with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Matrix1 with Single Precision Float
 * r1: Matrix2 with Single Precision Float
 * r2: Number of Rows and Columns
 *
 * Return: r0 (Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl math32_mat32_multiply
math32_mat32_multiply:
	/* Auto (Local) Variables, but just Aliases */
	matrix1     .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	matrix2     .req r1 @ Parameter, Register for Argument, Scratch Register
	number_mat  .req r2 @ Parameter, Register for Argument, Scratch Register
	temp        .req r3
	temp2       .req r4
	matrix_ret  .req r5
	index       .req r6
	column      .req r7
	row         .req r8
	i           .req r9

	/* VFP Registers */
	vfp_value   .req d0
	vfp_value1  .req s0
	vfp_value2  .req s1
	vfp_sum     .req s2

	push {r4-r9,lr}
	vpush {s0-s2}

	mul temp, number_mat, number_mat

	push {r0-r3}
	mov r0, temp
	bl heap32_malloc
	mov matrix_ret, r0
	pop {r0-r3}

	cmp matrix_ret, #0
	beq math32_mat32_multiply_common

	mov index, #0

	/* for ( uint32 column = 0; column < number_mat; column++ ) { */
	mov column, #0
	math32_mat32_multiply_column:
		cmp column, number_mat
		bge math32_mat32_multiply_common

		/* for ( uint32 row = 0; row < number_mat; row++ ) { */
		mov row, #0
		math32_mat32_multiply_column_row:
			cmp row, number_mat
			bge math32_mat32_multiply_column_row_common

			mov temp, #0
			vmov vfp_sum, temp
			vcvt.f32.s32 vfp_sum, vfp_sum

			/* for ( uint32 i = 0; i < number_mat; i++ ) { */
			mov i, #0
			math32_mat32_multiply_column_row_i:
				cmp i, number_mat
				bge math32_mat32_multiply_column_row_i_common

				mul temp, column, number_mat
				add temp, temp, i
				ldr temp, [matrix1, temp, lsl #2]           @ Substitution of Multiplication by 4
				
				mul temp2, i, number_mat
				add temp2, temp2, row
				ldr temp2, [matrix2, temp2, lsl #2]         @ Substitution of Multiplication by 4

				vmov vfp_value, temp, temp2
				vmla.f32 vfp_sum, vfp_value1, vfp_value2    @ Multiply and Accumulate

				add i, i, #1
				b math32_mat32_multiply_column_row_i
	
			/* } */
				math32_mat32_multiply_column_row_i_common:
					vmov temp, vfp_sum
					str temp, [matrix_ret, index]
					add index, index, #4

					add row, row, #1
					b math32_mat32_multiply_column_row

		/* } */
			math32_mat32_multiply_column_row_common:

				add column, column, #1
				b math32_mat32_multiply_column

	/* } */
	math32_mat32_multiply_common:
		mov r0, matrix_ret
		vpop {s0-s2}
		pop {r4-r9,pc}

.unreq matrix1
.unreq matrix2
.unreq number_mat
.unreq temp
.unreq temp2
.unreq matrix_ret
.unreq index
.unreq column
.unreq row
.unreq i
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2
.unreq vfp_sum


/**
 * function math32_mat32_identity
 * Get Identity of Matrix
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Number of Rows and Columns
 *
 * Return: r0 (Matrix to Have Identity, If Zero Not Allocated Memory)
 */
.globl math32_mat32_identity
math32_mat32_identity:
	/* Auto (Local) Variables, but just Aliases */
	number_mat  .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	one         .req r1
	offset      .req r2
	i           .req r3
	matrix      .req r4

	/* VFP Registers */
	vfp_one     .req s0

	push {r4,lr}
	vpush {s0}

	mul i, number_mat, number_mat

	push {r0-r3}
	mov r0, i
	bl heap32_malloc
	mov matrix, r0
	pop {r0-r3}

	mov one, #1
	vmov vfp_one, one
	vcvt.f32.s32 vfp_one, vfp_one
	vmov one, vfp_one

	mov i, number_mat
	add number_mat, number_mat, #1

	mov offset, #0

	math32_mat32_identity_loop:
		cmp i, #0
		ble math32_mat32_identity_common

		str one, [matrix, offset, lsl #2] @ Substitution of Multiplication by 4

		add offset, offset, number_mat
		sub i, i, #1
		b math32_mat32_identity_loop

	math32_mat32_identity_common:
		mov r0, matrix
		vpop {s0}
		pop {r4,pc}

.unreq number_mat
.unreq one
.unreq offset
.unreq i
.unreq matrix
.unreq vfp_one
