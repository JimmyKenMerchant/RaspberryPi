/**
 * math32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function math32_round_pi
 * Return Rounded Radian Between -Pi to Pi with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_round_pi
math32_round_pi:
	/* Auto (Local) Variables, but just Aliases */
	radian         .req r0

	/* VFP Registers */
	vfp_radian     .req s0
	vfp_pi         .req s1
	vfp_pi_neg     .req s2
	vfp_pi_double  .req s3

	vpush {s0-s3}

	vmov vfp_radian, radian
	vldr vfp_pi, MATH32_PI
	vneg.f32 vfp_pi_neg, vfp_pi
	vldr vfp_pi_double, MATH32_PI_DOUBLE

	vcmp.f32 vfp_radian, vfp_pi
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	bgt math32_round_pi_over

	vcmp.f32 vfp_radian, vfp_pi_neg
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	blt math32_round_pi_under

	b math32_round_pi_common

	math32_round_pi_over:
		vsub.f32 vfp_radian, vfp_radian, vfp_pi_double
		vcmp.f32 vfp_radian, vfp_pi
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		bgt math32_round_pi_over
		b math32_round_pi_common

	math32_round_pi_under:
		vadd.f32 vfp_radian, vfp_radian, vfp_pi_double
		vcmp.f32 vfp_radian, vfp_pi_neg
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		blt math32_round_pi_under

	math32_round_pi_common:
		vmov radian, vfp_radian
		vpop {s0-s3}
		mov pc, lr

.unreq radian
.unreq vfp_radian
.unreq vfp_pi
.unreq vfp_pi_neg
.unreq vfp_pi_double


/**
 * function math32_round_degree
 * Return Rounded Degrees Between 0 to 360 with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Degrees, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_round_degree
math32_round_degree:
	/* Auto (Local) Variables, but just Aliases */
	degree         .req r0
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
	bgt math32_round_degree_over

	vcmp.f32 vfp_degree, #0
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	blt math32_round_degree_under

	b math32_round_degree_common

	math32_round_degree_over:
		vsub.f32 vfp_degree, vfp_degree, vfp_full
		vcmp.f32 vfp_degree, vfp_full
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		bgt math32_round_degree_over
		b math32_round_degree_common

	math32_round_degree_under:
		vadd.f32 vfp_degree, vfp_degree, vfp_full
		vcmp.f32 vfp_degree, #0
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		blt math32_round_degree_under

	math32_round_degree_common:
		vmov degree, vfp_degree
		vpop {s0-s1}
		mov pc, lr

.unreq degree
.unreq full
.unreq vfp_degree
.unreq vfp_full


/**
 * function math32_degree_to_radian
 * Return Radian from Degrees
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Degrees, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_degree_to_radian
math32_degree_to_radian:
	/* Auto (Local) Variables, but just Aliases */
	degree         .req r0

	/* VFP Registers */
	vfp_degree     .req s0
	vfp_radian     .req s1
	vfp_pi_per_deg .req s2

	vpush {s0-s2}

	/**
	 * Radian = degrees X (pi / 180)
	 */
	vmov vfp_degree, degree
	vldr vfp_pi_per_deg, MATH32_PI_PER_DEGREE
	vmul.f32 vfp_radian, vfp_degree, vfp_pi_per_deg

	math32_degree_to_radian_common:
		vmov r0, vfp_radian
		vpop {s0-s2}
		mov pc, lr

.unreq degree
.unreq vfp_degree
.unreq vfp_radian
.unreq vfp_pi_per_deg


/**
 * function math32_radian_to_degree
 * Return Degrees from Radian
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Degrees, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_radian_to_degree
math32_radian_to_degree:
	/* Auto (Local) Variables, but just Aliases */
	radian         .req r0

	/* VFP Registers */
	vfp_degree     .req s0
	vfp_radian     .req s1
	vfp_pi_per_deg .req s2

	vpush {s0-s2}

	/**
	 * Degree = radian / (pi / 180)
	 */
	vmov vfp_radian, radian
	vldr vfp_pi_per_deg, MATH32_PI_PER_DEGREE
	vdiv.f32 vfp_degree, vfp_radian, vfp_pi_per_deg

	math32_radian_to_degree_common:
		vmov r0, vfp_degree
		vpop {s0-s2}
		mov pc, lr

.unreq radian
.unreq vfp_degree
.unreq vfp_radian
.unreq vfp_pi_per_deg


.globl MATH32_NAN
MATH32_NAN:                     .word 0x7FFFFFFF @ (IEEE754 Single Precision, Not a Number)
.balign 8

.globl MATH32_INFINITY_POSITIVE
MATH32_INFINITY_POSITIVE:       .word 0xFF800000 @ (IEEE754 Single Precision, Positive)
.balign 8

.globl MATH32_INFINITY_NEGATIVE
MATH32_INFINITY_NEGATIVE:       .word 0x7F800000 @ (IEEE754 Single Precision, Negative)
.balign 8

.globl MATH32_PI
MATH32_PI:                      .word 0x40490fdb @ (.float 3.14159265359)
.balign 8

.globl MATH32_PI_DOUBLE
MATH32_PI_DOUBLE:               .word 0x40c90fdb @ (.float 6.28318530718)
.balign 8

.globl MATH32_PI_HALF
MATH32_PI_HALF:                 .word 0x3fc90fdb @ (.float 1.57079632679)
.balign 8

.globl MATH32_PI_PER_DEGREE
MATH32_PI_PER_DEGREE:           .word 0x3c8efa35 @ (.float 0.01745329252)
.balign 8


/**
 * Trigonometric Function
 */

/**
 * function math32_sin
 * Return Sine by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_sin
math32_sin:
	/* Auto (Local) Variables, but just Aliases */
	radian        .req r0

	/* VFP Registers */
	vfp_radian    .req s0
	vfp_pi        .req s1
	vfp_pi_half   .req s2
	vfp_temp      .req s3
	vfp_sum       .req s4

	push {lr}
	vpush {s0-s4}

	/* Ensure Radian is Between -Pi to Pi */

	bl math32_round_pi

	vmov vfp_radian, radian
	vldr vfp_pi, MATH32_PI
	vldr vfp_pi_half, MATH32_PI_HALF

	/* Make Sure of Being Symmetrical on Each Half of Pi/-Pi */

	vabs.f32 vfp_temp, vfp_radian
	vcmp.f32 vfp_temp, vfp_pi_half
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	ble math32_sin_jump

	vsub.f32 vfp_temp, vfp_pi
	vcmp.f32 vfp_radian, #0
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	vneggt.f32 vfp_temp, vfp_temp                   @ If Original Radian is Positive, Make Value Positive
	vmov vfp_radian, vfp_temp
	
	math32_sin_jump:
		.unreq vfp_pi
		vfp_dividend .req s1
		.unreq vfp_pi_half
		vfp_divisor .req s2

		/**
		 * sinx = Sigma[n = 0 to Infinity] (-1)^n X x^(2n+1) / (2n+1)!
		 * For All x
		 */

		.unreq radian
		temp .req r0
		vcmp.f32 vfp_radian, #0
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		vmov vfp_sum, vfp_radian                        @ n = 0
		beq math32_sin_common

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

	math32_sin_common:
		vmov r0, vfp_sum
		vpop {s0-s4}
		pop {pc}

.unreq temp
.unreq vfp_radian
.unreq vfp_dividend
.unreq vfp_divisor
.unreq vfp_temp
.unreq vfp_sum


/**
 * function math32_cos
 * Return Cosine by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_cos
math32_cos:
	/* Auto (Local) Variables, but just Aliases */
	radian        .req r0

	/* VFP Registers */
	vfp_radian    .req s0
	vfp_pi_half   .req s1

	vpush {s0-s1}

	/**
	 * Sin( Theta + Pi/2 ) = Cos( Theta )
	 */
	vmov vfp_radian, radian
	vldr vfp_pi_half, MATH32_PI_HALF
	vadd.f32 vfp_radian, vfp_radian, vfp_pi_half
	vmov radian, vfp_radian

	push {lr}
	bl math32_sin
	pop {lr}

	/**
	 * Not Used, But Cosine's Series is Shown as Below 
	 * cosx = Sigma[n = 0 to Infinity] (-1)^n X x^(2n) / (2n)!
	 * For All x
	 */

	math32_cos_common:
		vpop {s0-s1}
		mov pc, lr

.unreq radian
.unreq vfp_radian
.unreq vfp_pi_half


/**
 * function math32_tan
 * Return Tangent by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_tan
math32_tan:
	/* Auto (Local) Variables, but just Aliases */
	radian     .req r0

	/* VFP Registers */
	vfp_sin    .req s0
	vfp_cos    .req s1

	push {lr}
	vpush {s0-s1}

	push {r0}
	bl math32_sin
	vmov vfp_sin, r0
	pop {r0}

	push {r0}
	bl math32_cos
	vmov vfp_cos, r0
	pop {r0}
	
	vdiv.f32 vfp_sin, vfp_sin, vfp_cos
	vmov r0, vfp_sin

	/**
	 * Not Used, But Tangent's Series is Shown as Below 
	 * tanx = Sigma[n = 1 to Infinity] (B2n X (-4)^n X (1 - 4^n)) X x^(2n - 1) / (2n)!
	 * for |x| < pi / 2, because Tangent is 180 degrees cycle unlike Sine and Cosine
	 * B is Bernoulli Number
	 * Units of the series are only positive, having less accuracy on low numbers than units being alternative between positive/negative of other series.
	 */

	math32_tan_common:
		vpop {s0-s1}
		pop {pc}

.unreq radian
.unreq vfp_sin
.unreq vfp_cos


/**
 * function math32_sec
 * Return Secant by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_sec
math32_sec:
	/* Auto (Local) Variables, but just Aliases */
	value      .req r0
	temp       .req r1

	/* VFP Registers */
	vfp_value  .req s0
	vfp_one    .req s1

	push {lr}
	vpush {s0-s1}

	/**
	 * Secant(x) = 1 / Cosine(x)
	 */

	bl math32_cos

	vmov vfp_value, value

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	vdiv.f32 vfp_value, vfp_one, vfp_value

	vmov r0, vfp_value

	math32_sec_common:
		vpop {s0-s1}
		pop {pc}

.unreq value
.unreq temp
.unreq vfp_value
.unreq vfp_one


/**
 * function math32_csc
 * Return Cosecant by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_csc
math32_csc:
	/* Auto (Local) Variables, but just Aliases */
	value      .req r0
	temp       .req r1

	/* VFP Registers */
	vfp_value  .req s0
	vfp_one    .req s1

	push {lr}
	vpush {s0-s1}

	/**
	 * Cosecant(x) = 1 / sine(x)
	 */

	bl math32_sin

	vmov vfp_value, value

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	vdiv.f32 vfp_value, vfp_one, vfp_value

	vmov r0, vfp_value

	math32_csc_common:
		vpop {s0-s1}
		pop {pc}

.unreq value
.unreq temp
.unreq vfp_value
.unreq vfp_one


/**
 * function math32_cot
 * Return Cotangent by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_cot
math32_cot:
	/* Auto (Local) Variables, but just Aliases */
	value      .req r0
	temp       .req r1

	/* VFP Registers */
	vfp_value  .req s0
	vfp_one    .req s1

	push {lr}
	vpush {s0-s1}

	/**
	 * Cotangent(x) = 1 / tangent(x)
	 */

	bl math32_tan

	vmov vfp_value, value

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	vdiv.f32 vfp_value, vfp_one, vfp_value

	vmov r0, vfp_value

	math32_cot_common:
		vpop {s0-s1}
		pop {pc}

.unreq value
.unreq temp
.unreq vfp_value
.unreq vfp_one


/**
 * Inverse Trigonometric Function
 */

/**
 * function math32_arcsin
 * Return Arcsine by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Radian by Single Precision Float)
 */
.globl math32_arcsin
math32_arcsin:
	/* Auto (Local) Variables, but just Aliases */
	value        .req r0
	temp2        .req r1

	/* VFP Registers */
	vfp_value    .req s0
	vfp_one      .req s1
	vfp_divisor  .req s2
	vfp_multiply .req s3

	push {lr}
	vpush {s0-s3}

	/**
	 * Ensure |x| <= 1
	 * arcsinx = 2arctan(x / 1 + (1 - x^2)^1/2)
	 * for |x| <= 1, real number
	 */

	mov temp2, #1
	vmov vfp_one, temp2
	vcvt.f32.s32 vfp_one, vfp_one
	vmov vfp_multiply, vfp_one
	vadd.f32 vfp_multiply, vfp_multiply, vfp_one

	vmov vfp_value, value
	vmul.f32 vfp_divisor, vfp_value, vfp_value
	vsub.f32 vfp_divisor, vfp_one, vfp_divisor
	vsqrt.f32 vfp_divisor, vfp_divisor
	vadd.f32 vfp_divisor, vfp_one, vfp_divisor
	vdiv.f32 vfp_value, vfp_value, vfp_divisor

	vmov value, vfp_value

	bl math32_arctan

	vmov vfp_value, value

	/* Multiplies by 2 */
	vmul.f32 vfp_value, vfp_value, vfp_multiply

	math32_arcsin_common:
		vmov r0, vfp_value
		vpop {s0-s3}
		pop {pc}

.unreq value
.unreq temp2
.unreq vfp_value
.unreq vfp_one
.unreq vfp_divisor
.unreq vfp_multiply


/**
 * function math32_arccos
 * Return Arccosine by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Radian by Single Precision Float)
 */
.globl math32_arccos
math32_arccos:
	/* Auto (Local) Variables, but just Aliases */
	value        .req r0

	/* VFP Registers */
	vfp_value    .req s0
	vfp_pi_half  .req s1

	push {lr}
	vpush {s0-s1}


	/**
	 * arccosx = pi / 2 - arcsinx
	 */

	bl math32_arcsin

	vmov vfp_value, value
	vldr vfp_pi_half, MATH32_PI_HALF

	vsub.f32 vfp_value, vfp_pi_half, vfp_value

	math32_arccos_common:
		vmov r0, vfp_value
		vpop {s0-s1}
		pop {pc}

.unreq value
.unreq vfp_value
.unreq vfp_pi_half


/**
 * function math32_arctan
 * Return Arctangent by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Radian by Single Precision Float)
 */
.globl math32_arctan
math32_arctan:
	/* Auto (Local) Variables, but just Aliases */
	value        .req r0
	temp2        .req r1
	flag_neg     .req r2

	/* VFP Registers */
	vfp_value    .req s0
	vfp_one      .req s1
	vfp_divisor  .req s2
	vfp_temp     .req s3
	vfp_sum      .req s4
	vfp_multiply .req s5
	vfp_two      .req s6

	push {lr}
	vpush {s0-s6}

	vmov vfp_value, value

	/**
	 * Ensure |x| < 0.5 (not <= 1 for accuracy)
	 * arctanx = 2arctan(x / 1 + (1 + x^2)^1/2)
	 * for |x| <= 1, real number
	 */

	mov temp2, #1
	vmov vfp_one, temp2
	vcvt.f32.s32 vfp_one, vfp_one
	vmov vfp_multiply, vfp_one
	vmov vfp_two, vfp_one
	vadd.f32 vfp_two, vfp_two, vfp_one
	vdiv.f32 vfp_temp, vfp_one, vfp_two

	math32_arctan_loop:
		vabs.f32 vfp_sum, vfp_value
		vcmp.f32 vfp_sum, vfp_temp                      @ |x| < 0.5
		vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
		blt math32_arctan_jump

		vmul.f32 vfp_divisor, vfp_value, vfp_value
		vadd.f32 vfp_divisor, vfp_one, vfp_divisor
		vsqrt.f32 vfp_divisor, vfp_divisor
		vadd.f32 vfp_divisor, vfp_one, vfp_divisor
		vdiv.f32 vfp_value, vfp_value, vfp_divisor

		/* Multiplies by 2 */
		vmul.f32 vfp_multiply, vfp_multiply, vfp_two

		b math32_arctan_loop

	math32_arctan_jump:
		.unreq vfp_one
		vfp_dividend .req s1

		/**
		 * arctanx = Sigma[n = 0 to Infinity] (-1)^n X x^(2n+1) / 2n+1
		 * for |x| <= 1, real number
		 */

		.unreq value
		temp .req r0
		vcmp.f32 vfp_value, #0
		vmrs apsr_nzcv, fpscr                          @ Transfer FPSCR Flags to CPSR's NZCV
		vmov vfp_sum, vfp_value                        @ n = 0
		beq math32_arctan_common

		mov temp, #3
		vmov vfp_divisor, temp
		vcvt.f32.s32 vfp_divisor, vfp_divisor

		vmov vfp_dividend, vfp_value
		mov temp, #7                                   @ Untill n = 7
		mov flag_neg, #1

	/* From n = 1 */
	math32_arctan_jump_loop:
		vmul.f32 vfp_dividend, vfp_dividend, vfp_value
		vmul.f32 vfp_dividend, vfp_dividend, vfp_value
		vdiv.f32 vfp_temp, vfp_dividend, vfp_divisor
		cmp flag_neg, #1
		vsubeq.f32 vfp_sum, vfp_sum, vfp_temp
		moveq flag_neg, #0
		vaddne.f32 vfp_sum, vfp_sum, vfp_temp
		movne flag_neg, #1

		subs temp, temp, #1
		vaddgt.f32 vfp_divisor, vfp_divisor, vfp_two
		bgt math32_arctan_jump_loop

		vmul.f32 vfp_sum, vfp_sum, vfp_multiply

	math32_arctan_common:
		vmov r0, vfp_sum
		vpop {s0-s6}
		pop {pc}

.unreq temp
.unreq temp2
.unreq flag_neg
.unreq vfp_value
.unreq vfp_dividend
.unreq vfp_divisor
.unreq vfp_temp
.unreq vfp_sum
.unreq vfp_multiply
.unreq vfp_two


/**
 * function math32_arcsec
 * Return Arcsecant by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_arcsec
math32_arcsec:
	/* Auto (Local) Variables, but just Aliases */
	value      .req r0
	temp       .req r1

	/* VFP Registers */
	vfp_value  .req s0
	vfp_one    .req s1
	vfp_temp   .req s2

	push {lr}
	vpush {s0-s2}

	/**
	 * Arcsecant(x) = arccosine(1 / x)
	 * |x| >= 1
	 */

	vmov vfp_value, value

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	vabs.f32 vfp_temp, vfp_value
	vcmp.f32 vfp_temp, vfp_one
	vmrs apsr_nzcv, fpscr                          @ Transfer FPSCR Flags to CPSR's NZCV
	ldrlt r0, MATH32_NAN
	blt math32_arcsec_common

	vdiv.f32 vfp_value, vfp_one, vfp_value

	vmov value, vfp_value

	bl math32_arccos

	math32_arcsec_common:
		vpop {s0-s2}
		pop {pc}

.unreq value
.unreq temp
.unreq vfp_value
.unreq vfp_one
.unreq vfp_temp


/**
 * function math32_arccsc
 * Return Arccosecant by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_arccsc
math32_arccsc:
	/* Auto (Local) Variables, but just Aliases */
	value      .req r0
	temp       .req r1

	/* VFP Registers */
	vfp_value  .req s0
	vfp_one    .req s1
	vfp_temp   .req s2

	push {lr}
	vpush {s0-s2}

	/**
	 * Arccosecant(x) = arcsine(1 / x)
	 * |x| >= 1
	 */

	vmov vfp_value, value

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	vabs.f32 vfp_temp, vfp_value
	vcmp.f32 vfp_temp, vfp_one
	vmrs apsr_nzcv, fpscr                          @ Transfer FPSCR Flags to CPSR's NZCV
	ldrlt r0, MATH32_NAN
	blt math32_arccsc_common

	vdiv.f32 vfp_value, vfp_one, vfp_value

	vmov value, vfp_value

	bl math32_arcsin

	math32_arccsc_common:
		vpop {s0-s2}
		pop {pc}

.unreq value
.unreq temp
.unreq vfp_value
.unreq vfp_one
.unreq vfp_temp


/**
 * function math32_arccot
 * Return Arccotangent by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_arccot
math32_arccot:
	/* Auto (Local) Variables, but just Aliases */
	value       .req r0

	/* VFP Registers */
	vfp_value   .req s0
	vfp_pi_half .req s1

	push {lr}
	vpush {s0-s1}

	/**
	 * Arccotangent(x) = pi / 2 - arctangent(x)
	 */

	bl math32_arctan

	vmov vfp_value, value
	vldr vfp_pi_half, MATH32_PI_HALF

	vsub.f32 vfp_value, vfp_pi_half, vfp_value

	vmov value, vfp_value

	math32_arccot_common:
		vpop {s0-s1}
		pop {pc}

.unreq value
.unreq vfp_value
.unreq vfp_pi_half


/**
 * Logarithm
 */

.globl MATH32_EULERS
MATH32_EULERS:                 .word 0x402df854 @ (.float 2.71828182846)
.balign 8

.globl MATH32_LN10
MATH32_LN10:                   .word 0x40135d8e @ (.float 2.30258509299)
.balign 8


/**
 * function math32_ln
 * Return Natural Logarithm, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float and Signed Plus)
 */
.globl math32_ln
math32_ln:
	/* Auto (Local) Variables, but just Aliases */
	value        .req r0
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
	 * ln(1+x) = Sigma[n = 1 to Infinity] (-1)^n+1 X x^n / n
	 * For |x| < 1
	 * 
	 * log(xy) = log(x) + log(y)
	 */

	vmov vfp_value, value
	vabs.f32 vfp_value, vfp_value                  @ If Minus Signed, Chagnes to Plus Signed
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
	blt math32_ln_series

	mov exponent, #1
	vmov vfp_power, vfp_eulers

	math32_ln_exponent:
		vdiv.f32 vfp_cal, vfp_value, vfp_power

		vcmp.f32 vfp_cal, vfp_num
		vmrs apsr_nzcv, fpscr                      @ Transfer FPSCR Flags to CPSR's NZCV

		vmovlt vfp_value, vfp_cal
		blt math32_ln_series

		vmul.f32 vfp_power, vfp_power, vfp_eulers
		add exponent, exponent, #1
		b math32_ln_exponent

	math32_ln_series:
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

	math32_ln_common:
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
 * function math32_log
 * Return Common Logarithm, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Value, Must Be Type of Single Precision Float
 *
 * Return: r0 (Value by Single Precision Float and Signed Plus)
 */
.globl math32_log
math32_log:
	/* Auto (Local) Variables, but just Aliases */
	value        .req r0

	/* VFP Registers */
	vfp_value    .req s0
	vfp_ln10     .req s1

	push {lr}
	vpush {s0-s1}

	/**
	 * log(x) = ln(x) / ln(10)
	 */

	bl math32_ln

	vmov vfp_value, value
	ldr value, MATH32_LN10
	vmov vfp_ln10, value
	vdiv.f32 vfp_value, vfp_value, vfp_ln10

	math32_log_common:
		vmov r0, vfp_value
		vpop {s0-s1}
		pop {pc}

.unreq value 
.unreq vfp_value
.unreq vfp_ln10
