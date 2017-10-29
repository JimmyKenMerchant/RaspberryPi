/**
 * math32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.globl MATH32_PI32
MATH32_PI32: .float 3.14159265359
.balign 8

.globl MATH32_PI_PER_DEGREE32
MATH32_PI_PER_DEGREE32: .float 0.01745329252
.balign 8


/**
 * function math32_degree_to_radian32
 * Return Radian from Degrees
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Degrees, Must Be Type of Signed Integer
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
	vcvt.f32.s32 vfp_degree, vfp_degree
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
 * Return sin(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 4
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

	vpush {s0-s4}

	/**
	 * sinx = Sigma[n = 0 to Infinity] (-1)^n X x^(2n+1) Div by (2n+1)!
	 * For All x
	 */
	vmov vfp_radian, radian
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
 * Return cos(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 4
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
	.unreq radian
	temp .req r0
	mov temp, #1
	vmov vfp_sum, temp
	vcvt.f32.s32 vfp_sum, vfp_sum
	vcmp.f32 vfp_radian, #0
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	beq math32_cos32_common

	vmov vfp_dividend, vfp_radian                   @ n = 1
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Second Power
	mov temp, #2
	vmov vfp_divisor, temp
	vcvt.f32.s32 vfp_divisor, vfp_divisor
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vsub.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 2
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Fourth Power
	mov temp, #12
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 24.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 3
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Sixth Power
	mov temp, #30
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
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
	mov temp, #56
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 40320.0 
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	math32_cos32_common:
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
 * function math32_tan32
 * Return tan(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 5
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Radian, Must Be Type of Single Precision Float, Must be |Radian| < pi Div by 2, -pi Div by 2 through pi Div by 2 exclusively
 *
 * Usage: r0
 * Return: r0 (Value by Single Precision Float)
 */
.globl math32_tan32
math32_tan32:
	/* Auto (Local) Variables, but just Aliases */
	radian        .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
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
	.unreq radian
	temp .req r0
	vcmp.f32 vfp_radian, #0
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	vmov vfp_sum, vfp_radian
	beq math32_tan32_common

	vmov vfp_dividend, vfp_radian                   @ n = 2
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Third Power
	mov temp, #3
	vmov vfp_divisor, temp
	vcvt.f32.s32 vfp_divisor, vfp_divisor
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	vmov vfp_dividend, vfp_radian                   @ n = 3
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian
	vmul.f32 vfp_dividend, vfp_dividend, vfp_radian @ The Fifth Power
	mov temp, #2
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vmul.f32 vfp_dividend, vfp_dividend, vfp_temp   @ Multiplication by 2 
	mov temp, #5
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
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
	mov temp, #17
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vmul.f32 vfp_dividend, vfp_dividend, vfp_temp   @ Multiplication by 17
	mov temp, #21
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
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
	mov temp, #62
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vmul.f32 vfp_dividend, vfp_dividend, vfp_temp   @ Multiplication by 62 (31 by 2)
	mov temp, #9
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vmul.f32 vfp_divisor, vfp_divisor, vfp_temp     @ 2835.0
	vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
	vadd.f32 vfp_sum, vfp_sum, vfp_dividend

	math32_tan32_common:
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
 * function math32_float32_to_string
 * Make String of Single Precision Float Value
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 * If Float Value Exceeds 1,000,000,000.0, String Will Be Shown With Exponent and May Have Loss of Signification.
 * If Float Value is less than 1.0, String Will Be Shown With Exponent.
 *
 * Parameters
 * r0: Float Value, Must Be Type of Single Precision Float
 * r1: Minimam Length of Digits in Integer Places, 16 Digits Max
 * r2: Maximam Length of Digits in Decimal Places, Default 8 Digits
 * r3: Minimam Length of Digits in Exponent Places, 16 Digits Max
 *
 * Usage: r0-r11
 * Return: r0 (Pointer of String)
 */
.globl math32_float32_to_string
math32_float32_to_string:
	/* Auto (Local) Variables, but just Aliases */
	float          .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	min_integer    .req r1
	max_decimal    .req r2
	min_exponent   .req r3
	temp           .req r4
	integer        .req r5
	decimal        .req r6
	string_integer .req r7
	string_decimal .req r8
	string_cmp     .req r9
	exponent       .req r10
	minus          .req r11

	/* VFP Registers */
	vfp_float      .req s0
	vfp_integer    .req s1
	vfp_decimal    .req s2
	vfp_temp       .req s3
	vfp_ten        .req s4

	push {r4-r11}
	vpush {s0-s4}

	/* Sanitize Pointers */
	mov string_integer, #0
	mov string_decimal, #0
	mov string_cmp, #0

	mov exponent, #0

	mov temp, #10
	vmov vfp_ten, temp
	vcvt.f32.s32 vfp_ten, vfp_ten

	/* Know Need of Exponent */

	vmov vfp_float, float
	vcmp.f32 vfp_float, #0
	vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
	movlt minus, #1
	movge minus, #0
	beq math32_float32_to_string_integer

	vabs.f32 vfp_float, vfp_float

	mov temp, #1
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vcmp.f32 vfp_float, vfp_temp
	vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
	blt math32_float32_to_string_exponentminus

	mov temp, #0x3B
	lsl temp, #8
	add temp, #0x9A
	lsl temp, #8
	add temp, #0xCA
	lsl temp, #8                                  @ Making Decimal 1,000,000,000
	vmov vfp_temp, temp
	vcvt.f32.u32 vfp_temp, vfp_temp
	vcmp.f32 vfp_float, vfp_temp
	vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
	bge math32_float32_to_string_exponentplus

	b math32_float32_to_string_integer

	math32_float32_to_string_exponentminus:
		sub exponent, exponent, #1
		vmul.f32 vfp_float, vfp_float, vfp_ten
		vcmp.f32 vfp_float, vfp_temp
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		blt math32_float32_to_string_exponentminus

		b math32_float32_to_string_convertfloat

	math32_float32_to_string_exponentplus:
		add exponent, exponent, #1
		vdiv.f32 vfp_float, vfp_float, vfp_ten
		vcmp.f32 vfp_float, vfp_temp
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		bge math32_float32_to_string_exponentplus

	math32_float32_to_string_convertfloat:
		cmp minus, #1
		vnegeq.f32 vfp_float, vfp_float
		vmov float, vfp_float

	/* Integer Part */

	math32_float32_to_string_integer:

		vmov vfp_integer, float                       @ Signed
		vcvt.s32.f32 vfp_integer, vfp_integer         @ Round Down
		vmov integer, vfp_integer

		push {r0-r3,lr}
		mov r0, integer
		mov r2, #1
		bl math32_int32_to_string_deci
		mov string_integer, r0
		pop {r0-r3,lr}

		.unreq min_integer
		temp2 .req r1

		cmp string_integer, #0
		beq math32_float32_to_string_error

		push {r0-r3,lr}
		mov r0, #1
		bl heap32_malloc
		mov string_decimal, r0
		pop {r0-r3,lr}

		cmp string_decimal, #0
		beq math32_float32_to_string_error

		mov temp, #0x2E
		strb temp, [string_decimal]                   @ Store Period Sign
		mov temp, #0x00
		strb temp, [string_decimal, #1]               @ Store Null Character

		push {r0-r3,lr}
		mov r0, string_integer
		mov r1, string_decimal
		bl print32_strcat
		mov string_cmp, r0
		pop {r0-r3,lr}

		cmp string_cmp, #0
		beq math32_float32_to_string_error

		push {r0-r3,lr}
		mov r0, string_integer 
		bl heap32_mfree
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, string_decimal
		bl heap32_mfree
		pop {r0-r3,lr}

		mov string_integer, string_cmp

		vcvt.f32.s32 vfp_integer, vfp_integer
		vmov vfp_decimal, float
		vabs.f32 vfp_integer, vfp_integer               @ Make Absolute Value
		vabs.f32 vfp_decimal, vfp_decimal               @ Make Absolute Value
		vsub.f32 vfp_decimal, vfp_decimal, vfp_integer  @ Cut Integer Part

	/* Decimal Part */

	math32_float32_to_string_decimal:
		/* Repeat of vfp_decimal X 10^8 and Cut it till catch Zero */
		cmp max_decimal, #0
		ble math32_float32_to_string_exponent
		mov temp, #8

		math32_float32_to_string_decimal_loop:
			cmp temp, #0
			ble math32_float32_to_string_decimal_common
			cmp max_decimal, #0
			ble math32_float32_to_string_decimal_common
			vmul.f32 vfp_decimal, vfp_decimal, vfp_ten
			sub temp, temp, #1
			sub max_decimal, max_decimal, #1
			b math32_float32_to_string_decimal_loop

		math32_float32_to_string_decimal_common:
			mov temp2, #8
			sub temp, temp2, temp

			vmov vfp_temp, vfp_decimal
			cmp max_decimal, #0
			vcvtreq.s32.f32 vfp_temp, vfp_temp       @ Round If Maximam Length Reaches Zero
			vcvtne.s32.f32 vfp_temp, vfp_temp
			vmov decimal, vfp_temp

			push {r0-r3,lr}
			mov r0, decimal
			mov r1, temp
			mov r2, #0
			bl math32_int32_to_string_deci
			mov string_decimal, r0
			pop {r0-r3,lr}
			
			push {r0-r3,lr}
			mov r0, string_integer
			mov r1, string_decimal
			bl print32_strcat
			mov string_cmp, r0
			pop {r0-r3,lr}

			cmp string_cmp, #0
			beq math32_float32_to_string_error

			push {r0-r3,lr}
			mov r0, string_integer 
			bl heap32_mfree
			pop {r0-r3,lr}

			push {r0-r3,lr}
			mov r0, string_decimal
			bl heap32_mfree
			pop {r0-r3,lr}

			mov string_integer, string_cmp

			vcvt.f32.s32 vfp_temp, vfp_temp
			vsub.f32 vfp_decimal, vfp_decimal, vfp_temp

			vcmp.f32 vfp_decimal, #0
			vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
			ble math32_float32_to_string_exponent

			b math32_float32_to_string_decimal

	/* Exponent Part */

	math32_float32_to_string_exponent:
		cmp exponent, #0
		beq math32_float32_to_string_success

		push {r0-r3,lr}
		mov r0, #1
		bl heap32_malloc
		mov string_decimal, r0
		pop {r0-r3,lr}

		mov temp, #0x45
		strb temp, [string_decimal]                      @ Store `E`
		cmp exponent, #0
		movgt temp, #0x2B
		movlt temp, #0x2D
		strb temp, [string_decimal, #1]                  @ Store `+` or `-`
		mov temp, #0x00
		strb temp, [string_decimal, #2]                  @ Store Null Character

		push {r0-r3,lr}
		mov r0, string_integer
		mov r1, string_decimal
		bl print32_strcat
		mov string_cmp, r0
		pop {r0-r3,lr}

		cmp string_cmp, #0
		beq math32_float32_to_string_error

		push {r0-r3,lr}
		mov r0, string_integer 
		bl heap32_mfree
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, string_decimal
		bl heap32_mfree
		pop {r0-r3,lr}

		mov string_integer, string_cmp

		cmp exponent, #0
		mvnlt exponent, exponent              @ If Minus, Make Absolute Value
		addlt exponent, #1

		push {r0-r3,lr}
		mov r0, exponent
		mov r1, min_exponent
		mov r2, #0
		bl math32_int32_to_string_deci
		mov string_decimal, r0
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, string_integer
		mov r1, string_decimal
		bl print32_strcat
		mov string_cmp, r0
		pop {r0-r3,lr}

		cmp string_cmp, #0
		beq math32_float32_to_string_error

		push {r0-r3,lr}
		mov r0, string_integer 
		bl heap32_mfree
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, string_decimal
		bl heap32_mfree
		pop {r0-r3,lr}

		mov string_integer, string_cmp
		b math32_float32_to_string_success

	math32_float32_to_string_error:
		push {r0-r3,lr}
		mov r0, string_integer 
		bl heap32_mfree
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, string_decimal
		bl heap32_mfree
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, string_cmp
		bl heap32_mfree
		pop {r0-r3,lr}

		mov r0, #0
		b math32_float32_to_string_common

	math32_float32_to_string_success:
		mov r0, string_integer

	math32_float32_to_string_common:
		vpop {s0-s4}
		pop {r4-r11}
		mov pc, lr

.unreq float
.unreq temp2
.unreq max_decimal
.unreq min_exponent
.unreq temp
.unreq integer
.unreq decimal
.unreq string_integer
.unreq string_decimal
.unreq string_cmp
.unreq exponent
.unreq minus
.unreq vfp_float
.unreq vfp_integer
.unreq vfp_decimal
.unreq vfp_temp
.unreq vfp_ten


/**
 * function math32_int32_to_string_deci
 * Make String of Integer Value by Decimal System (Base 10)
 *
 * Parameters
 * r0: Integer Number
 * r1: Minimum Length of Digits from Left Side, Up to 16 Digits
 * r2: 0 unsigned, 1 signed
 *
 * Usage: r0-r11
 * Return: r0 (Pointer of String, If Zero, Memory Space for String Can't Be Allocated)
 */
.globl math32_int32_to_string_deci
math32_int32_to_string_deci:
	/* Auto (Local) Variables, but just Aliases */
	integer       .req r0
	min_length    .req r1
	signed        .req r2
	temp          .req r3
	string_lower  .req r4
	string_upper  .req r5
	string_minus  .req r6
	string_cmp    .req r7
	count_lower   .req r8
	count_upper   .req r9
	integer_lower .req r10
	integer_upper .req r11

	push {r4-r11}

	cmp min_length, #16
	movgt min_length, #16

	/* Sanitize Pointers */
	mov string_lower, #0
	mov string_upper, #0
	mov string_minus, #0
	mov string_cmp, #0

	push {r0-r3,lr}
	bl math32_count_zero32
	mov count_lower, r0
	pop {r0-r3,lr}

	cmp signed, #1
	cmpeq count_lower, #0                   @ Whether Top Bit is One or Zero
	movne signed, #0                        @ If Count Is Not Zero, Signed Will Perform The Same as Unsigned
	bne math32_int32_to_string_deci_jumpunsigned

	/* Process for Minus Signed */
	mvn integer, integer                    @ All Inverter
	add integer, #1                         @ Convert Value from Minus Signed Number to Plus Signed Number

	math32_int32_to_string_deci_jumpunsigned:
		push {r0-r3,lr}
		bl math32_hexa_to_deci32
		mov integer_lower, r0
		mov integer_upper, r1
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, integer_lower
		bl math32_count_zero32
		mov count_lower, r0
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, integer_upper
		bl math32_count_zero32
		mov count_upper, r0
		pop {r0-r3,lr}

		mov temp, count_lower
		mov count_lower, #0

	math32_int32_to_string_deci_countlower:
		subs temp, temp, #4
		addge count_lower, #1
		bge math32_int32_to_string_deci_countlower

		mov temp, #8
		sub count_lower, temp, count_lower

		mov temp, count_upper
		mov count_upper, #0

	math32_int32_to_string_deci_countupper:
		subs temp, temp, #4
		addge count_upper, #1
		bge math32_int32_to_string_deci_countupper

		mov temp, #8
		sub count_upper, temp, count_upper

		cmp count_lower, min_length
		movlt count_lower, min_length                    @ Cutting off min_length Exists in math32_int32_to_string_hexa

		cmp count_upper, #0
		beq math32_int32_to_string_deci_lower            @ If Upper String Doesn't Exist

		sub temp, min_length, #8
		cmp count_upper, temp
		movlt count_upper, temp

	math32_int32_to_string_deci_upper:
		push {r0-r3,lr}
		mov r0, integer_upper
		mov r1, count_upper
		mov r2, #0
		mov r3, #0
		bl math32_int32_to_string_hexa
		mov string_upper, r0
		pop {r0-r3,lr}

		cmp string_upper, #0
		beq math32_int32_to_string_deci_error

		mov count_lower, #8

	math32_int32_to_string_deci_lower:
		push {r0-r3,lr}
		mov r0, integer_lower
		mov r1, count_lower
		mov r2, #0
		mov r3, #0
		bl math32_int32_to_string_hexa
		mov string_lower, r0
		pop {r0-r3,lr}

		cmp string_lower, #0
		beq math32_int32_to_string_deci_error

		cmp signed, #1
		bne math32_int32_to_string_deci_cat         @ If Unsigned, Jump to Next

		push {r0-r3,lr}
		mov r0, #1
		bl heap32_malloc
		mov string_minus, r0
		pop {r0-r3,lr}

		cmp string_minus, #0
		beq math32_int32_to_string_deci_error

		mov temp, #0x2D
		strb temp, [string_minus]                   @ Store Minus Sign

		mov temp, #0x00
		strb temp, [string_minus, #1]               @ Store Null Character

	math32_int32_to_string_deci_cat:
		cmp count_upper, #0
		beq math32_int32_to_string_deci_cat_lower

		cmp signed, #1
		bne math32_int32_to_string_deci_cat_jump   @ If Unsigned, Jump to Next

		push {r0-r3,lr}
		mov r0, string_minus 
		mov r1, string_upper
		bl print32_strcat
		mov string_cmp, r0
		pop {r0-r3,lr}

		cmp string_cmp, #0
		beq math32_int32_to_string_deci_error

		push {r0-r3,lr}
		mov r0, string_minus 
		bl heap32_mfree
		pop {r0-r3,lr}

		push {r0-r3,lr}
		mov r0, string_upper
		bl heap32_mfree
		pop {r0-r3,lr}

		mov string_upper, string_cmp

		math32_int32_to_string_deci_cat_jump:
			push {r0-r3,lr}
			mov r0, string_upper
			mov r1, string_lower
			bl print32_strcat
			mov string_cmp, r0
			pop {r0-r3,lr}

			cmp string_cmp, #0
			beq math32_int32_to_string_deci_error

			push {r0-r3,lr}
			mov r0, string_upper 
			bl heap32_mfree
			pop {r0-r3,lr}

			push {r0-r3,lr}
			mov r0, string_lower
			bl heap32_mfree
			pop {r0-r3,lr}

			b math32_int32_to_string_deci_success 

		math32_int32_to_string_deci_cat_lower:
			cmp signed, #1
			movne string_cmp, string_lower
			bne math32_int32_to_string_deci_success         @ If Unsigned, Jump to Next

			push {r0-r3,lr}
			mov r0, string_minus 
			mov r1, string_lower
			bl print32_strcat
			mov string_cmp, r0
			pop {r0-r3,lr}

			cmp string_cmp, #0
			beq math32_int32_to_string_deci_error

			push {r0-r3,lr}
			mov r0, string_minus 
			bl heap32_mfree
			pop {r0-r3,lr}

			push {r0-r3,lr}
			mov r0, string_lower
			bl heap32_mfree
			pop {r0-r3,lr}

			b math32_int32_to_string_deci_success 

	math32_int32_to_string_deci_error:
		push {r0-r3,lr}
		mov r0, string_lower
		bl heap32_mfree
		pop {r0-r3,lr}
		push {r0-r3,lr}
		mov r0, string_upper
		bl heap32_mfree
		pop {r0-r3,lr}
		push {r0-r3,lr}
		mov r0, string_minus 
		bl heap32_mfree
		pop {r0-r3,lr}
		push {r0-r3,lr}
		mov r0, string_cmp 
		bl heap32_mfree
		pop {r0-r3,lr}

		mov r0, #0
		b math32_int32_to_string_deci_common

	math32_int32_to_string_deci_success:
		mov r0, string_cmp

	math32_int32_to_string_deci_common:
		pop {r4-r11}
		mov pc, lr

.unreq integer
.unreq min_length
.unreq signed
.unreq temp
.unreq string_lower
.unreq string_upper
.unreq string_minus
.unreq string_cmp
.unreq count_lower
.unreq count_upper
.unreq integer_lower
.unreq integer_upper


/**
 * function math32_int32_to_string_hexa
 * Make String of Integer Value by Hexadecimal System (Base 16)
 *
 * Parameters
 * r0: Integer Number
 * r1: Minimum Length of Digits from Left Side, Up to 8 Digits
 * r2: 0 unsigned, 1 signed
 * r3: 0 Doesn't Show Bases Mark, 1 Shows Bases Mark(`0x`)
 *
 * Usage: r0-r9
 * Return: r0 (Pointer of String, If Zero, Memory Space for String Can't Be Allocated)
 */
.globl math32_int32_to_string_hexa
math32_int32_to_string_hexa:
	/* Auto (Local) Variables, but just Aliases */
	integer     .req r0
	min_length  .req r1
	signed      .req r2
	base_mark   .req r3
	temp        .req r4
	mask        .req r5
	heap        .req r6
	heap_origin .req r7
	heap_size   .req r8
	count       .req r9

	push {r4-r9}

	cmp min_length, #8
	movgt min_length, #8

	push {r0-r3,lr}
	bl math32_count_zero32
	mov count, r0
	pop {r0-r3,lr}

	cmp signed, #1
	cmpeq count, #0                         @ Whether Top Bit is One or Zero
	movne signed, #0                        @ If Count Is Not Zero, Signed Will Perform The Same as Unsigned
	bne math32_int32_to_string_hexa_jumpunsigned

	/* Process for Minus Signed */
	mvn integer, integer                    @ All Inverter
	add integer, #1                         @ Convert Value from Minus Signed Number to Plus Signed Number
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
		cmp count, min_length
		movlt count, min_length

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
		bl heap32_malloc
		mov heap_origin, r0
		pop {r0-r3,lr}

		cmp heap_origin, #0
		beq math32_int32_to_string_hexa_error
		mov heap, heap_origin

		cmp signed, #1
		bne math32_int32_to_string_hexa_basemark        @ If Unsigned, Jump to Next
		mov mask, #0x2D
		strb mask, [heap]                               @ Store Minus Sign
		add heap, heap, #1

	math32_int32_to_string_hexa_basemark:
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
.unreq min_length
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
	/* Auto (Local) Variables, but just Aliases */
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
 * Usage: r0-r8, r0 reused
 * Return: r0 (Lower Bits of Return Number), r1 (Upper Bits of Return Number), if all zero, may be error
 * Error(r0:0x0, r1:0x0): This function could not calculate because of digit-overflow.
 */
.globl math32_hexa_to_deci32
math32_hexa_to_deci32:
	/* Auto (Local) Variables, but just Aliases */
	hexa        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	deci_upper  .req r1
	power_lower .req r2
	power_upper .req r3
	dup_hexa    .req r4
	mul_number  .req r5
	i           .req r6
	shift       .req r7
	bitmask     .req r8

	push {r4-r8}    @ Callee-saved Registers (r4-r11<fp>), r12 is Intra-procedure Call Scratch Register (ip)
                    @ Similar to `STMDB r13! {r4-r11}` Decrement Before, r13 (SP) Saves Decremented Number

	mov dup_hexa, hexa
	
	.unreq hexa
	deci_lower .req r0

	mov deci_lower, #0
	mov deci_upper, #0
	mov power_upper, #0

	mov i, #0
	mov mul_number, #4

	math32_hexa_to_deci32_loop:
		mov bitmask, #0xf                         @ 0b1111
		mul shift, i, mul_number
		lsl bitmask, bitmask, shift               @ Make bitmask
		and bitmask, dup_hexa, bitmask
		lsr bitmask, bitmask, shift               @ Make One Digit Number

		cmp i, #0
		ldreq power_lower, math32_hexa_to_deci32_0                @ 16^0
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #1
		ldreq power_lower, math32_hexa_to_deci32_1                @ 16^1
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #2
		ldreq power_lower, math32_hexa_to_deci32_2                @ 16^2
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #3
		ldreq power_lower, math32_hexa_to_deci32_3                @ 16^3
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #4
		ldreq power_lower, math32_hexa_to_deci32_4                @ 16^4
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #5
		ldreq power_lower, math32_hexa_to_deci32_5                @ 16^5
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #6
		ldreq power_lower, math32_hexa_to_deci32_6                @ 16^6
		beq math32_hexa_to_deci32_loop_loop

		cmp i, #7
		ldreq power_lower, math32_hexa_to_deci32_7_lower          @ 16^7 Lower Bits
		ldreq power_upper, math32_hexa_to_deci32_7_upper          @ 16^7 Upper Bits

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
math32_hexa_to_deci32_0:       .word 0x00000001 @ 16^0
math32_hexa_to_deci32_1:       .word 0x00000016 @ 16^1
math32_hexa_to_deci32_2:       .word 0x00000256 @ 16^2
math32_hexa_to_deci32_3:       .word 0x00004096 @ 16^3
math32_hexa_to_deci32_4:       .word 0x00065536 @ 16^4
math32_hexa_to_deci32_5:       .word 0x01048576 @ 16^5
math32_hexa_to_deci32_6:       .word 0x16777216 @ 16^6
math32_hexa_to_deci32_7_lower: .word 0x68435456 @ 16^7 Lower Bits
math32_hexa_to_deci32_7_upper: .word 0x00000002 @ 16^7 Upper Bits
.balign 4

.unreq deci_lower
.unreq deci_upper
.unreq power_lower
.unreq power_upper
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
	/* Auto (Local) Variables, but just Aliases */
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
