/**
 * math64.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.globl MATH64_PI
MATH64_PI_ADDR:        .word MATH64_PI
MATH64_PI:             .word 0x54442d18, 0x400921fb @ (.double 3.14159265358979324)
.balign 8

/**
 * function math64_factorial
 * Return Factorial by Double Precision Float
 *
 * Parameters
 * r0: Value, Must Be Type of Unsigned Integer
 *
 * Return: r0 (Lower Half of Double Precison Float), r1 (Upper Half of Double Precision Float)
 */
.globl math64_factorial
math64_factorial:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0
	temp          .req r1

	/* VFP Registers */
	vfp_value     .req d0
	vfp_factorial .req d1
	vfp_temp      .req s4

	vpush {s0-s4}

	/**
	 * Capital letter of Greek pi assigns product.
	 * n! = pi[k = 1 to n] k.
	 * 0! equals 1.
	 */

	cmp value, #1
	movls temp, #1
	vmovls vfp_temp, temp
	vcvtls.f64.u32 vfp_factorial, vfp_temp
	bls math64_factorial_common

	vmov vfp_temp, value
	vcvt.f64.u32 vfp_factorial, vfp_temp

	sub value, value, #1

	math64_factorial_loop:
		vmov vfp_temp, value
		vcvt.f64.u32 vfp_value, vfp_temp
		vmul.f64 vfp_factorial, vfp_factorial, vfp_value
		subs value, value, #1
		bhi math64_factorial_loop

	math64_factorial_common:
		vmov r0, r1, vfp_factorial
		vpop {s0-s4}
		mov pc, lr

.unreq value
.unreq temp
.unreq vfp_value
.unreq vfp_factorial
.unreq vfp_temp


/**
 * function math64_double_factorial
 * Return Double Factorial by Double Precision Float
 *
 * Parameters
 * r0: Value, Must Be Type of Unsigned Integer
 *
 * Return: r0 (Lower Half of Double Precison Float), r1 (Upper Half of Double Precision Float)
 */
.globl math64_double_factorial
math64_double_factorial:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0
	temp          .req r1

	/* VFP Registers */
	vfp_value     .req d0
	vfp_factorial .req d1
	vfp_temp      .req s4

	vpush {s0-s4}

	/**
	 * Capital letter of Greek pi assigns product.
	 * If n is even:
	 * n!! = Pi[k = 1 to n / 2] 2k (e.g, 6!! = 6 X 4 X 2).
	 * If n is odd:
	 * n!! = Pi[k = 1 to (n + 1) / 2] 2k - 1 (e.g, 7!! = 7 X 5 X 3 X 1 [note that last 1 is no need of calculation]).
	 * 0!! equals 1. 1!! equals 1.
	 */

	cmp value, #1
	movls temp, #1
	vmovls vfp_temp, temp
	vcvtls.f64.u32 vfp_factorial, vfp_temp
	bls math64_double_factorial_common

	vmov vfp_temp, value
	vcvt.f64.u32 vfp_factorial, vfp_temp

	sub value, value, #2
	cmp value, #1
	bls math64_double_factorial_common

	math64_double_factorial_loop:
		vmov vfp_temp, value
		vcvt.f64.u32 vfp_value, vfp_temp
		vmul.f64 vfp_factorial, vfp_factorial, vfp_value
		sub value, value, #2
		cmp value, #1
		bhi math64_double_factorial_loop

	math64_double_factorial_common:
		vmov r0, r1, vfp_factorial
		vpop {s0-s4}
		mov pc, lr

.unreq value
.unreq temp
.unreq vfp_value
.unreq vfp_factorial
.unreq vfp_temp


/**
 * function math64_gamma_integer
 * Return Gamma Function (Variable is Positive Integer) by Double Precision Float
 *
 * Parameters
 * r0: Value, Must Be Type of Unsigned Integer
 *
 * Return: r0 (Lower Half of Double Precison Float), r1 (Upper Half of Double Precision Float)
 */
.globl math64_gamma_integer
math64_gamma_integer:
	/* Auto (Local) Variables, but just Aliases */
	value .req r0

	push {lr}

	/**
	 * Capital letter of Greek gamma assigns gamma function.
	 * Gamma(number of unsigned [positive] integer) = (n - 1)!.
	 */

	sub value, value, #1
	bl math64_factorial

	math64_gamma_integer_common:
		pop {pc}

.unreq value


/**
 * function math64_gamma_halfinteger
 * Return Gamma Function (Variable is Positive Half Integer) by Double Precision Float
 *
 * Parameters
 * r0: Value, Must Be Type of Unsigned Integer
 *
 * Return: r0 (Lower Half of Double Precision Float, -1 by Integer as Error), r1 (Upper Half of Double Precision Float, -1 by Integer as Error)
 */
.globl math64_gamma_halfinteger
math64_gamma_halfinteger:
	/* Auto (Local) Variables, but just Aliases */
	value                .req r0
	temp                 .req r1

	/* VFP Registers */
	vfp_double_factorial .req d0
	vfp_power            .req d1
	vfp_gamma            .req d2
	vfp_temp             .req s6

	push {lr}
	vpush {s0-s6}

	/**
	 * Capital letter of Greek gamma assigns gamma function.
	 * Gamma(1 / 2 + n) = (2n - 1)!! / 2^n X square root of pi.
	 * Gamma(N / 2) can translate to the form above. n = (N - 1) / 2.
	 * I.e.,
	 * Gamma(1 / 2 + ((N - 1) / 2)) = ((N - 1) - 1)!! / 2^((N - 1) / 2) X square root of pi.
	 * r0 represents N.
	 */

	cmp value, #0
	mvneq temp, #0
	vmoveq vfp_gamma[0], temp
	vmoveq vfp_gamma[1], temp
	beq math64_gamma_halfinteger_common

	/* Check Even */
	tst value, #1
	bne math64_gamma_halfinteger_odd
	lsr value, #1
	
	push {r0}
	bl math64_gamma_integer
	vmov vfp_gamma, r0, r1
	pop {r0}

	b math64_gamma_halfinteger_common

	math64_gamma_halfinteger_odd:

		cmp value, #1
		moveq temp, #1
		vmoveq vfp_temp, temp
		vcvteq.f64.u32 vfp_double_factorial, vfp_temp
		beq math64_gamma_halfinteger_odd_pi

		sub value, value, #1

		push {r0}
		sub value, value, #1
		bl math64_double_factorial
		vmov vfp_double_factorial, r0, r1
		pop {r0}

		mov temp, #2
		vmov vfp_temp, temp
		vcvt.f64.u32 vfp_power, vfp_temp
		vcvt.f64.u32 vfp_gamma, vfp_temp

		math64_gamma_halfinteger_odd_loop:
			subs value, value, #1
			ble math64_gamma_halfinteger_odd_div
			vmul.f64 vfp_power, vfp_power, vfp_gamma
			b math64_gamma_halfinteger_odd_loop

		math64_gamma_halfinteger_odd_div:
			vsqrt.f64 vfp_power, vfp_power                                   @ Half Power
			vdiv.f64 vfp_double_factorial, vfp_double_factorial, vfp_power

		math64_gamma_halfinteger_odd_pi:
			ldr temp, MATH64_PI_ADDR
			vldmia temp, {vfp_gamma}
			vsqrt.f64 vfp_gamma, vfp_gamma
			vmul.f64 vfp_gamma, vfp_gamma, vfp_double_factorial

	math64_gamma_halfinteger_common:
		vmov r0, r1, vfp_gamma
		vpop {s0-s6}
		pop {pc}

.unreq value
.unreq temp
.unreq vfp_double_factorial
.unreq vfp_power
.unreq vfp_gamma
.unreq vfp_temp


/**
 * function math64_gamma_halfinteger_negative
 * Return Gamma Function (Variable is Negative Half Integer) by Double Precision Float
 *
 * Parameters
 * r0: Value, Must Be Type of Unsigned Integer and Odd
 *
 * Return: r0 (Lower Half of Double Precision Float, -1 by Integer as Error), r1 (Upper Half of Double Precision Float, -1 by Integer as Error)
 */
.globl math64_gamma_halfinteger_negative
math64_gamma_halfinteger_negative:
	/* Auto (Local) Variables, but just Aliases */
	value                .req r0
	temp                 .req r1

	/* VFP Registers */
	vfp_double_factorial .req d0
	vfp_power            .req d1
	vfp_gamma            .req d2
	vfp_temp             .req s6

	push {lr}
	vpush {s0-s6}

	/**
	 * Capital letter of Greek gamma assigns gamma function.
	 * Gamma(1 / 2 - n) = -2^n / (2n - 1)!! X square root of pi.
	 * Gamma(-(N / 2)) can translate to the form above. n = (N + 1) / 2.
	 * I.e.,
	 * Gamma(1 / 2 - ((N + 1) / 2)) = -2^((N + 1) / 2) / ((N + 1) - 1)!! X square root of pi.
	 * r0 represents N.
	 */

	cmp value, #0
	tstne value, #1                              @ Odd/Even Test
	mvneq temp, #0
	vmoveq vfp_gamma[0], temp
	vmoveq vfp_gamma[1], temp
	beq math64_gamma_halfinteger_negative_common

	add value, value, #1

	push {r0}
	sub value, value, #1
	bl math64_double_factorial
	vmov vfp_double_factorial, r0, r1
	pop {r0}

	mov temp, #-2
	vmov vfp_temp, temp
	vcvt.f64.s32 vfp_power, vfp_temp
	vcvt.f64.s32 vfp_gamma, vfp_temp

	lsr value, value, #1                         @ Sustitute of Division by 2 (Half Power)

	math64_gamma_halfinteger_negative_loop:
		subs value, value, #1
		ble math64_gamma_halfinteger_negative_div
		vmul.f64 vfp_power, vfp_power, vfp_gamma
		b math64_gamma_halfinteger_negative_loop

	math64_gamma_halfinteger_negative_div:
		vdiv.f64 vfp_power, vfp_power, vfp_double_factorial

	math64_gamma_halfinteger_negative_pi:
		ldr temp, MATH64_PI_ADDR
		vldmia temp, {vfp_gamma}
		vsqrt.f64 vfp_gamma, vfp_gamma
		vmul.f64 vfp_gamma, vfp_gamma, vfp_power

	math64_gamma_halfinteger_negative_common:
		vmov r0, r1, vfp_gamma
		vpop {s0-s6}
		pop {pc}

.unreq value
.unreq temp
.unreq vfp_double_factorial
.unreq vfp_power
.unreq vfp_gamma
.unreq vfp_temp


/**
 * function math64_hypergeometric_halfinteger
 * Return Gaussian (2F1) Hypergeometric Function (First, Second, and Third Arguments are Half Integers) Using Power Series
 * The precision of this function Will be reduced when the maximum value of a, b, and c is bigger and the absolute value of z is closer to 1.
 * To get more precise value, you can increase the number of power series, but it may cause an error because of the saturation of the gamma function.
 * To hide saturation on the gamma function, this system uses double precision float as the type of value, but it has the limitation.
 * E.g., if a = 1, b = 40, c = 3, and z = -0.1, the number of 80 for the power series can calculate this function, but the number of 94 can't calculate.
 *
 * Parameters
 * r0: First Argument (a), Must Be Type of Unsigned Integer
 * r1: Second Argument (b), Must Be Type of Unsigned Integer
 * r2: Third Argument (c), Must Be Type of Unsigned Integer
 * r3: Fourth Argument (z), Must Be Type of Single Precision Float
 * r4: Number of Power Series, Must Be Type of Unsigned Integer
 *
 * Return: r0 (Lower Half of Double Precision Float, -1 by Integer as Error), r1 (Upper Half of Double Precision Float, -1 by Integer as Error)
 */
.globl math64_hypergeometric_halfinteger
math64_hypergeometric_halfinteger:
	/* Auto (Local) Variables, but just Aliases */
	first       .req r0
	second      .req r1
	third       .req r2
	fourth      .req r3
	number      .req r4
	temp        .req r5
	i           .req r6
	shift       .req r7

	/* VFP Registers */
	vfp_first   .req d0
	vfp_second  .req d1
	vfp_third   .req d2
	vfp_fourth  .req d3
	vfp_hyper   .req d4
	vfp_divisor .req d6
	vfp_temp    .req s12

	push {r4-r7,lr}

	add sp, sp, #20                  @ r4-r6 and lr offset 16 bytes
	pop {number}                     @ Get Fifth Arguments
	sub sp, sp, #24                  @ Retrieve SP

	vpush {s0-s12}

	/**
	 * a^(n) means rising factorial, a X .. (a + n - 1), e.g., 2^(3) = 2 X (2 + 1) X (2 + 2).
	 * Rising factorial can translate to gamma(a + n) / gamma(a).
	 *
	 * 2F1(a,b;c;z) = sigma[n=0 to Infinity] (a^(n) X b^(n) / c^(n)) X (z^n / n!),
	 * where |z| < 1; c is not negative integer.
	 * This function calculates 2F1(a / 2, b / 2; c / 2; z).
	 * Reference: https://en.wikipedia.org/wiki/Hypergeometric_function
	 */

	mov i, #0

	/* n = 0 */
	mov temp, #1
	vmov vfp_temp, temp
	vcvt.f64.u32 vfp_hyper, vfp_temp

	/* Check |z| < 1 */
	vmov vfp_temp, fourth
	vcvt.f64.f32 vfp_fourth, vfp_temp
	vabs.f64 vfp_fourth, vfp_fourth
	vcmp.f64 vfp_fourth, vfp_hyper
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	mvnge temp, #0
	vmovge vfp_hyper[0], temp
	vmovge vfp_hyper[1], temp
	bge math64_hypergeometric_halfinteger_common

	add i, i, #1
	cmp i, number
	bgt math64_hypergeometric_halfinteger_common

	/* n = 1 */
	vmov vfp_temp, first
	vcvt.f64.u32 vfp_first, vfp_temp
	vmov vfp_temp, second 
	vcvt.f64.u32 vfp_second, vfp_temp
	vmov vfp_temp, third
	vcvt.f64.u32 vfp_third, vfp_temp
	vmov vfp_temp, fourth
	vcvt.f64.f32 vfp_fourth, vfp_temp

	mov temp, #2
	vmov vfp_temp, temp
	vcvt.f64.u32 vfp_divisor, vfp_temp

	/* Get a / 2, b / 2, c / 2 */
	vdiv.f64 vfp_first, vfp_first, vfp_divisor
	vdiv.f64 vfp_second, vfp_second, vfp_divisor
	vdiv.f64 vfp_third, vfp_third, vfp_divisor

	/* Calculate One Unit of Series */
	vmul.f64 vfp_first, vfp_first, vfp_second
	vdiv.f64 vfp_first, vfp_first, vfp_third
	vmul.f64 vfp_first, vfp_first, vfp_fourth

	/* Add One Unit to Answer */
	vadd.f64 vfp_hyper, vfp_hyper, vfp_first

	add i, i, #1
	cmp i, number
	bgt math64_hypergeometric_halfinteger_common

	/* n = 2 and over */
	math64_hypergeometric_halfinteger_loop:

		mov shift, #2
		mul shift, i, shift

		/* First Argument, a / 2 */

		push {r0-r3}
		add r0, first, shift
		bl math64_gamma_halfinteger
		cmp r0, #-1
		cmpeq r1, #-1
		mov temp, r0
		vmov vfp_first, r0, r1
		pop {r0-r3}

		vmoveq vfp_hyper[0], temp
		vmoveq vfp_hyper[1], temp
		beq math64_hypergeometric_halfinteger_common

		push {r0-r3}
		bl math64_gamma_halfinteger
		cmp r0, #-1
		cmpeq r1, #-1
		mov temp, r0
		vmov vfp_divisor, r0, r1
		pop {r0-r3}

		vmoveq vfp_hyper[0], temp
		vmoveq vfp_hyper[1], temp
		beq math64_hypergeometric_halfinteger_common

		vdiv.f64 vfp_first, vfp_first, vfp_divisor

		/* Second Argument, b / 2 */

		push {r0-r3}
		add r0, second, shift
		bl math64_gamma_halfinteger
		cmp r0, #-1
		cmpeq r1, #-1
		mov temp, r0
		vmov vfp_second, r0, r1
		pop {r0-r3}

		vmoveq vfp_hyper[0], temp
		vmoveq vfp_hyper[1], temp
		beq math64_hypergeometric_halfinteger_common

		push {r0-r3}
		mov r0, second
		bl math64_gamma_halfinteger
		cmp r0, #-1
		cmpeq r1, #-1
		mov temp, r0
		vmov vfp_divisor, r0, r1
		pop {r0-r3}

		vmoveq vfp_hyper[0], temp
		vmoveq vfp_hyper[1], temp
		beq math64_hypergeometric_halfinteger_common

		vdiv.f64 vfp_second, vfp_second, vfp_divisor

		/* Third Argument, c / 2 */

		push {r0-r3}
		add r0, third, shift
		bl math64_gamma_halfinteger
		cmp r0, #-1
		cmpeq r1, #-1
		mov temp, r0
		vmov vfp_third, r0, r1
		pop {r0-r3}

		vmoveq vfp_hyper[0], temp
		vmoveq vfp_hyper[1], temp
		beq math64_hypergeometric_halfinteger_common

		push {r0-r3}
		mov r0, third
		bl math64_gamma_halfinteger
		cmp r0, #-1
		cmpeq r1, #-1
		mov temp, r0
		vmov vfp_divisor, r0, r1
		pop {r0-r3}

		vmoveq vfp_hyper[0], temp
		vmoveq vfp_hyper[1], temp
		beq math64_hypergeometric_halfinteger_common

		vdiv.f64 vfp_third, vfp_third, vfp_divisor
	
		/* Fourth Argument, z (Single Precision Float) */

		vmov vfp_temp, fourth
		vcvt.f64.f32 vfp_fourth, vfp_temp
		vcvt.f64.f32 vfp_divisor, vfp_temp
		mov temp, i
		math64_hypergeometric_halfinteger_loop_fourth:
			vmul.f64 vfp_fourth, vfp_fourth, vfp_divisor
			sub temp, temp, #1
			cmp temp, #1
			bgt math64_hypergeometric_halfinteger_loop_fourth

		push {r0-r3}
		mov r0, i
		bl math64_factorial
		vmov vfp_divisor, r0, r1
		pop {r0-r3}

		vdiv.f64 vfp_fourth, vfp_fourth, vfp_divisor

		/* Calculate One Unit of Series */
		vmul.f64 vfp_first, vfp_first, vfp_second
		vdiv.f64 vfp_first, vfp_first, vfp_third
		vmul.f64 vfp_first, vfp_first, vfp_fourth

		/* Add One Unit to Answer */
		vadd.f64 vfp_hyper, vfp_hyper, vfp_first

		macro32_dsb ip

		add i, i, #1
		cmp i, number
		ble math64_hypergeometric_halfinteger_loop

	math64_hypergeometric_halfinteger_common:
		vmov r0, r1, vfp_hyper
		vpop {s0-s12}
		pop {r4-r7,pc}

.unreq first
.unreq second
.unreq third
.unreq fourth
.unreq number
.unreq temp
.unreq i
.unreq shift
.unreq vfp_first
.unreq vfp_second
.unreq vfp_third
.unreq vfp_fourth
.unreq vfp_hyper
.unreq vfp_divisor
.unreq vfp_temp
