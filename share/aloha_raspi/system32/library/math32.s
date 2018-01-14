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

.globl MATH32_EULERS
MATH32_EULERS:           .word 0x402df854 @ (.float 2.71828182846)
.balign 8

.globl MATH32_LN10
MATH32_LN10:             .word 0x40135d8e @ (.float 2.30258509299)
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
	vfp_pi        .req s1
	vfp_pi_half   .req s2
	vfp_temp      .req s3
	vfp_sum       .req s4

	vpush {s0-s4}

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
		.unreq vfp_pi
		vfp_dividend .req s1
		.unreq vfp_pi_half
		vfp_divisor .req s2

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
		vdiv.f32 vfp_temp, vfp_dividend, vfp_divisor
		vsub.f32 vfp_sum, vfp_sum, vfp_temp

		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ n = 2
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Fifth Power
		mov temp, #20
		vmov vfp_temp, temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 120.0
		vdiv.f32 vfp_temp, vfp_dividend, vfp_divisor
		vadd.f32 vfp_sum, vfp_sum, vfp_temp

		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ n = 3
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Seventh Power
		mov temp, #42
		vmov vfp_temp, temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 5040.0
		vdiv.f32 vfp_temp, vfp_dividend, vfp_divisor
		vsub.f32 vfp_sum, vfp_sum, vfp_temp

		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ n = 4
		vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Nineth Power
		mov temp, #72
		vmov vfp_temp, temp
		vcvt.f32.s32 vfp_temp, vfp_temp
		vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 362880.0
		vdiv.f32 vfp_temp, vfp_dividend, vfp_divisor
		vadd.f32 vfp_sum, vfp_sum, vfp_temp

	math32_sin32_common:
		vmov r0, vfp_sum
		vpop {s0-s4}
		mov pc, lr

.unreq temp
.unreq vfp_radian
.unreq vfp_dividend
.unreq vfp_divisor
.unreq vfp_temp
.unreq vfp_sum


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
 * function math32_ln32
 * Return Natural Logarithm, Using Maclaurin (Taylor) Series, Untill n = 7
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_ln32
math32_ln32:
	/* Auto (Local) Variables, but just Aliases */
	value        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	temp         .req r1
	exponent     .req r2

	/* VFP Registers */
	vfp_value    .req s0
	vfp_eulers   .req s1
	vfp_num      .req s2
	vfp_one      .req s3
	vfp_power    .req s4
	vfp_cal      .req s5
	
	vpush {s0-s5}

	/**
	 * ln(1+x) = Sigma[n = 1 to Infinity] (-1)^n+1 X x^n Div by n
	 * For |x| < 1
	 * 
	 * log(xy) = log(x) + log(y)
	 */

	vmov vfp_value, value
	ldr temp, MATH32_EULERS
	vmov vfp_eulers, temp

	mov temp, #2
	vmov vfp_num, temp
	vcvt.f32.s32 vfp_num, vfp_num

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.s32 vfp_one, vfp_one

	vcmp.f32 vfp_value, vfp_num
	vmrs apsr_nzcv, fpscr                          @ Transfer FPSCR Flags to CPSR's NZCV
	movlt exponent, #0
	blt math32_ln32_series

	mov exponent, #1
	vmov vfp_power, vfp_eulers

	math32_ln32_exponent:
		vdiv.f32 vfp_cal, vfp_value, vfp_power

		vcmp.f32 vfp_cal, vfp_num
		vmrs apsr_nzcv, fpscr                      @ Transfer FPSCR Flags to CPSR's NZCV

		vmovlt vfp_value, vfp_cal
		blt math32_ln32_series

		vmul.f32 vfp_power, vfp_power, vfp_eulers
		add exponent, exponent, #1
		b math32_ln32_exponent

	math32_ln32_series:
		.unreq vfp_eulers
		vfp_inter .req s1
		.unreq vfp_power
		vfp_sum .req s4

		/* n = 1 */
		vsub.f32 vfp_value, vfp_value, vfp_one
		vmov vfp_sum, vfp_value
		
		/* n = 2 */
		vmul.f32 vfp_inter, vfp_value, vfp_value
		vdiv.f32 vfp_cal, vfp_inter, vfp_num
		vsub.f32 vfp_sum, vfp_sum, vfp_cal
		
		/* n = 3 */
		vmul.f32 vfp_inter, vfp_inter, vfp_value
		vadd.f32 vfp_num, vfp_num, vfp_one
		vdiv.f32 vfp_cal, vfp_inter, vfp_num
		vadd.f32 vfp_sum, vfp_sum, vfp_cal

		/* n = 4 */
		vmul.f32 vfp_inter, vfp_inter, vfp_value
		vadd.f32 vfp_num, vfp_num, vfp_one
		vdiv.f32 vfp_cal, vfp_inter, vfp_num
		vsub.f32 vfp_sum, vfp_sum, vfp_cal

		/* n = 5 */
		vmul.f32 vfp_inter, vfp_inter, vfp_value
		vadd.f32 vfp_num, vfp_num, vfp_one
		vdiv.f32 vfp_cal, vfp_inter, vfp_num
		vadd.f32 vfp_sum, vfp_sum, vfp_cal

		/* n = 6 */
		vmul.f32 vfp_inter, vfp_inter, vfp_value
		vadd.f32 vfp_num, vfp_num, vfp_one
		vdiv.f32 vfp_cal, vfp_inter, vfp_num
		vsub.f32 vfp_sum, vfp_sum, vfp_cal

		/* n = 7 */
		vmul.f32 vfp_inter, vfp_inter, vfp_value
		vadd.f32 vfp_num, vfp_num, vfp_one
		vdiv.f32 vfp_cal, vfp_inter, vfp_num
		vadd.f32 vfp_sum, vfp_sum, vfp_cal

		vmov vfp_cal, exponent
		vcvt.f32.s32 vfp_cal, vfp_cal
		vadd.f32 vfp_sum, vfp_sum, vfp_cal

	math32_ln32_common:
		vmov r0, vfp_sum
		vpop {s0-s5}
		mov pc, lr

.unreq value 
.unreq temp
.unreq exponent
.unreq vfp_value
.unreq vfp_inter
.unreq vfp_num
.unreq vfp_one
.unreq vfp_sum
.unreq vfp_cal


/**
 * function math32_log32
 * Return Common Logarithm, Using Natural Logarithm's Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_log32
math32_log32:
	/* Auto (Local) Variables, but just Aliases */
	value        .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value    .req s0
	vfp_ln10     .req s1

	push {lr}
	vpush {s0-s1}

	/**
	 * log(x) = ln(x) Div by ln(10)
	 */

	bl math32_ln32

	vmov vfp_value, value
	ldr value, MATH32_LN10
	vmov vfp_ln10, value
	vdiv.f32 vfp_value, vfp_value, vfp_ln10

	math32_log32_common:
		vmov r0, vfp_value
		vpop {s0-s1}
		pop {pc}

.unreq value 
.unreq vfp_value
.unreq vfp_ln10


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

	cmp matrix, #0
	beq math32_mat32_identity_common

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


/**
 * function math32_mat32_multiply_vec
 * Square Matrix and Column Vector Multiplication
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 *
 * Parameters
 * r0: Matrix
 * r1: Vector
 * r2: Number of Vector Size
 *
 * Return: r0 (Value of Dot Product by Single Precision Float)
 */
.globl math32_mat32_multiply_vec
math32_mat32_multiply_vec:
	/* Auto (Local) Variables, but just Aliases */
	matrix         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	vector         .req r1 @ Parameter, Register for Argument, Scratch Register
	number_vec     .req r2 @ Parameter, Register for Argument, Scratch Register
	value1         .req r3
	value2         .req r4
	temp1          .req r5
	temp2          .req r6
	i              .req r7
	offset         .req r8
	vector_result  .req r9

	/* VFP Registers */
	vfp_value     .req d0
	vfp_value1    .req s0
	vfp_value2    .req s1
	vfp_result    .req s2

	push {r4-r9,lr}
	vpush {s0-s3}

	push {r0-r3}
	mov r0, number_vec
	bl heap32_malloc
	mov vector_result, r0
	pop {r0-r3}

	cmp vector_result, #0
	beq math32_mat32_multiply_vec_common

	mov offset, #0
	mov i, #0

	math32_mat32_multiply_vec_row:
		cmp i, number_vec
		bge math32_mat32_multiply_vec_common

		mov temp1, #0
		vmov vfp_result, temp1
		vcvt.f32.s32 vfp_result, vfp_result

		mov temp1, number_vec
		sub temp1, temp1, #1

		add temp2, offset, temp1

		math32_mat32_multiply_vec_row_column:
			cmp temp1, #0
			blt math32_mat32_multiply_vec_row_common

			ldr value1, [matrix, temp2, lsl #2]         @ Substitution of Multiplication by 4
			ldr value2, [vector, temp1, lsl #2]         @ Substitution of Multiplication by 4
			vmov vfp_value, value1, value2
			vmla.f32 vfp_result, vfp_value1, vfp_value2

			sub temp1, temp1, #1
			sub temp2, temp2, #1
			b math32_mat32_multiply_vec_row_column

		math32_mat32_multiply_vec_row_common:
			vmov value1, vfp_result
			str value1, [vector_result, i, lsl #2]      @ Substitution of Multiplication by 4
			add offset, offset, number_vec
			add i, i, #1

			b math32_mat32_multiply_vec_row

	math32_mat32_multiply_vec_common:
		mov r0, vector_result
		vpop {s0-s3}
		pop {r4-r9,pc}

.unreq matrix
.unreq vector
.unreq number_vec
.unreq value1
.unreq value2
.unreq temp1
.unreq temp2
.unreq i
.unreq offset
.unreq vector_result
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2
.unreq vfp_result


/**
 * function math32_vec32_normalize
 * Normalize Vector
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r1: Vector
 * r0: Number of Vector Size
 *
 * Return: r0 (Vector to Have Been Normalized, If Zero Not Allocated Memory)
 */
.globl math32_vec32_normalize
math32_vec32_normalize:
	/* Auto (Local) Variables, but just Aliases */
	vector        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	number_vec    .req r1 @ Parameter, Register for Argument, Scratch Register
	temp          .req r2
	length        .req r3
	vector_result .req r4
	value         .req r5

	/* VFP Registers */
	vfp_length    .req s0
	vfp_value     .req s1

	push {r4-r5,lr}
	vpush {s0-s1}

	push {r0-r3}
	mov r0, number_vec
	bl heap32_malloc
	mov vector_result, r0
	pop {r0-r3}

	cmp vector_result, #0
	beq math32_vec32_normalize_common

	mov temp, #0
	vmov vfp_length, temp
	vcvt.f32.s32 vfp_length, vfp_length

	mov temp, number_vec
	sub temp, temp, #1

	math32_vec32_normalize_length:
		cmp temp, #0
		blt math32_vec32_normalize_checkzero

		ldr value, [vector, temp, lsl #2]              @ Substitution of Multiplication by 4
		vmov vfp_value, value
		vmla.f32 vfp_length, vfp_value, vfp_value

		sub temp, temp, #1
		b math32_vec32_normalize_length

	math32_vec32_normalize_checkzero:
		vsqrt.f32 vfp_length, vfp_length
		vcmp.f32 vfp_length, #0
		vmrs apsr_nzcv, fpscr                          @ Transfer FPSCR Flags to CPSR's NZCV
		beq math32_vec32_normalize_common

		sub number_vec, number_vec, #1

	math32_vec32_normalize_normal:
		cmp number_vec, #0
		blt math32_vec32_normalize_common

		ldr value, [vector, number_vec, lsl #2]        @ Substitution of Multiplication by 4
		vmov vfp_value, value
		vdiv.f32 vfp_value, vfp_value, vfp_length
		vmov value, vfp_value
		str value, [vector_result, number_vec, lsl #2] @ Substitution of Multiplication by 4

		b math32_vec32_normalize_normal

	math32_vec32_normalize_common:
		mov r0, vector_result
		vpop {s0-s1}
		pop {r4-r5,pc}

.unreq vector
.unreq number_vec
.unreq temp
.unreq length
.unreq vector_result
.unreq value
.unreq vfp_length
.unreq vfp_value


/**
 * function math32_vec32_dotproduct
 * Dot Product
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 *
 * Parameters
 * r0: Vector1
 * r1: Vector2
 * r2: Number of Vector Size
 *
 * Return: r0 (Value of Dot Product by Single Precision Float)
 */
.globl math32_vec32_dotproduct
math32_vec32_dotproduct:
	/* Auto (Local) Variables, but just Aliases */
	vector1    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	vector2    .req r1 @ Parameter, Register for Argument, Scratch Register
	number_vec .req r2 @ Parameter, Register for Argument, Scratch Register
	value      .req r3

	/* VFP Registers */
	vfp_dot    .req s0
	vfp_value1 .req s1
	vfp_value2 .req s2

	vpush {s0-s2}

	mov value, #0
	vmov vfp_dot, value
	vcvt.f32.s32 vfp_dot, vfp_dot

	sub number_vec, number_vec, #1

	math32_vec32_dotproduct_normal:
		cmp number_vec, #0
		blt math32_vec32_dotproduct_common

		ldr value, [vector1, number_vec, lsl #2] @ Substitution of Multiplication by 4
		vmov vfp_value1, value
		ldr value, [vector2, number_vec, lsl #2] @ Substitution of Multiplication by 4
		vmov vfp_value2, value
		vmla.f32 vfp_dot, vfp_value1, vfp_value2

		b math32_vec32_dotproduct_normal

	math32_vec32_dotproduct_common:
		vmov value, vfp_dot
		mov r0, value
		vpop {s0-s2}
		mov pc, lr

.unreq vector1
.unreq vector2
.unreq number_vec
.unreq value
.unreq vfp_dot
.unreq vfp_value1
.unreq vfp_value2


/**
 * function math32_vec32_crossprodut
 * Cross Product
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r1: Vector1, Must Be Three of Vector Size
 * r1: Vector2, Must Be Three of Vector Size
 *
 * Return: r0 (Vector to Be Calculated, If Zero Not Allocated Memory)
 */
.globl math32_vec32_crossprodut
math32_vec32_crossprodut:
	/* Auto (Local) Variables, but just Aliases */
	vector1       .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	vector2       .req r1 @ Parameter, Register for Argument, Scratch Register
	number_vec    .req r2 @ Parameter, Register for Argument, Scratch Register
	value1        .req r3
	value2        .req r4
	vector_result .req r5

	/* VFP Registers */
	vfp_value    .req d0
	vfp_value1   .req s0
	vfp_value2   .req s1
	vfp_inter1   .req s2
	vfp_inter2   .req s3
	vfp_result   .req s4

	push {r4-r5,lr}
	vpush {s0-s4}

	mov number_vec, #3

	push {r0-r3}
	mov r0, number_vec
	bl heap32_malloc
	mov vector_result, r0
	pop {r0-r3}

	/* X */

	ldr value1, [vector1, #4]                   @ Vector1[1], Y
	ldr value2, [vector2, #8]                   @ Vector2[2], Z
	vmov vfp_value, value1, value2
	vmul.f32 vfp_inter1, vfp_value1, vfp_value2

	ldr value1, [vector1, #8]                   @ Vector1[2], Z
	ldr value2, [vector2, #4]                   @ Vector2[1], Y
	vmov vfp_value, value1, value2
	vmul.f32 vfp_inter2, vfp_value1, vfp_value2

	vsub.f32 vfp_result, vfp_inter1, vfp_inter2

	vmov value1, vfp_result
	str value1, [vector_result]                 @ Vector_result[0], X

	/* Y */

	ldr value1, [vector1, #8]                   @ Vector1[2], Z
	ldr value2, [vector2]                       @ Vector2[0], X
	vmov vfp_value, value1, value2
	vmul.f32 vfp_inter1, vfp_value1, vfp_value2

	ldr value1, [vector1]                       @ Vector1[0], X
	ldr value2, [vector2, #8]                   @ Vector2[2], Z
	vmov vfp_value, value1, value2
	vmul.f32 vfp_inter2, vfp_value1, vfp_value2

	vsub.f32 vfp_result, vfp_inter1, vfp_inter2

	vmov value1, vfp_result
	str value1, [vector_result, #4]             @ Vector_result[1], Y

	/* Z */

	ldr value1, [vector1]                       @ Vector1[0], X
	ldr value2, [vector2, #4]                   @ Vector2[1], Y
	vmov vfp_value, value1, value2
	vmul.f32 vfp_inter1, vfp_value1, vfp_value2

	ldr value1, [vector1, #4]                   @ Vector1[1], Y
	ldr value2, [vector2]                       @ Vector2[0], X
	vmov vfp_value, value1, value2
	vmul.f32 vfp_inter2, vfp_value1, vfp_value2

	vsub.f32 vfp_result, vfp_inter1, vfp_inter2

	vmov value1, vfp_result
	str value1, [vector_result, #8]             @ Vector_result[2], Z

	math32_vec32_crossprodut_common:
		mov r0, vector_result
		vpop {s0-s4}
		pop {r4-r5,pc}

.unreq vector1
.unreq vector2
.unreq number_vec
.unreq value1
.unreq value2
.unreq vector_result
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2
.unreq vfp_inter1
.unreq vfp_inter2
.unreq vfp_result

