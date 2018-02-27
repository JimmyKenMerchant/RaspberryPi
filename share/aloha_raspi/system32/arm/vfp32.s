/**
 * vfp32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function vfp32_f32tohexa
 * Convert Float32 to Hexadecimal Raw Binaries (as a Dummy Code for a C Language Function)
 *
 * Parameters
 * r0: Value, Must Be Single Precision Float
 *
 * Return: r0 (Value by Unsigned Integer)
 */
.globl vfp32_f32tohexa
vfp32_f32tohexa:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	vfp32_f32tohexa_common:
		mov pc, lr

.unreq value


/**
 * function vfp32_hexatof32
 * Convert Hexadecimal Raw Binaries to Float32 (as a Dummy Code for a C Language Function)
 *
 * Parameters
 * r0: Value, Must Be Unsigned Integer
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_hexatof32
vfp32_hexatof32:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	vfp32_hexatof32_common:
		mov pc, lr

.unreq value


/**
 * function vfp32_f32tosfix32
 * Convert from Single Precision Float (IEEE754 Format) to Signed Value by Fixed Point
 *
 * Parameters
 * r0: Value, Must Be Single Precision Float
 * r1: Digits of Fractional Places, 0-32
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_f32tosfix32
vfp32_f32tosfix32:
	/* Auto (Local) Variables, but just Aliases */
	value           .req r0
	fraction_digits .req r1
	exponent        .req r2
	value_msw       .req r3 @ Most Significant Words
	value_mlw       .req r4 @ Least Significant Words
	negative        .req r5

	push {r4-r5,lr}

	mov value_msw, #0
	mov value_mlw, #0

	tst value, #0x80000000                         @ Sign Bit[31]
	movne negative, #0x1
	moveq negative, #0x0

	/* Extract Exponent Bit[30:23] */
	mov exponent, #0x7F000000
	orr exponent, exponent, #0x00800000
	and exponent, value, exponent
	lsr exponent, exponent, #23

	sub exponent, exponent, #127

	/* Set Bit[23], Next to Fraction Bit[22:0] to Show Hidden Integer Place, One */
	bic value, value, #0xFF000000
	orr value, value, #0x00800000

	cmp exponent, #0
	bgt vfp32_f32tosfix32_exponentplus
	blt vfp32_f32tosfix32_exponentminus
	b vfp32_f32tosfix32_digits

	vfp32_f32tosfix32_exponentplus:
		lsl value_msw, value_msw, #1
		lsls value, value, #1                      @ Substitute of Multiplication by 2
		addvs value_msw, value_msw, #1             @ If Overflow
		bic value, value, #0x80000000              @ Clear MSB
		subs exponent, exponent, #1
		bgt vfp32_f32tosfix32_exponentplus
		b vfp32_f32tosfix32_digits

	vfp32_f32tosfix32_exponentminus:
		lsr value_mlw, value_mlw, #1
		lsrs value, value, #1                      @ Substitute of Division by 2
		addcs value_mlw, value_mlw, #0x80000000
		subs exponent, exponent, #-1
		blt vfp32_f32tosfix32_exponentminus

	vfp32_f32tosfix32_digits:
		subs fraction_digits, fraction_digits, #23 @ Default 23 Digits of Decimal Places
		bgt vfp32_f32tosfix32_digits_more
		blt vfp32_f32tosfix32_digits_less
		b vfp32_f32tosfix32_sign

		vfp32_f32tosfix32_digits_more:
			lsl value, value, #1                   @ Substitute of Multiplication by 2
			lsls value_mlw, value_mlw, #1
			addcs value, value, #1
			subs fraction_digits, fraction_digits, #1
			bgt vfp32_f32tosfix32_digits_more
			b vfp32_f32tosfix32_sign

		vfp32_f32tosfix32_digits_less:
			lsr value, value, #1                   @ Substitute of Division by 2
			lsrs value_msw, value_msw, #1
			addcs value, value, #0x40000000
			subs fraction_digits, fraction_digits, #-1
			blt vfp32_f32tosfix32_digits_less

	vfp32_f32tosfix32_sign:
		tst negative, #0x1
		beq vfp32_f32tosfix32_common

		mvn value, value
		add value, value, #0x1

	vfp32_f32tosfix32_common:
		pop {r4-r5,pc}

.unreq value
.unreq fraction_digits
.unreq exponent
.unreq value_msw
.unreq value_mlw
.unreq negative


/**
 * function vfp32_f32toufix32
 * Convert from Single Precision Float (IEEE754 Format) to Unsigned (Absolute) Value by Fixed Point
 *
 * Parameters
 * r0: Value, Must Be Single Precision Float
 * r1: Digits of Fractional Places, 0-32
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_f32toufix32
vfp32_f32toufix32:
	/* Auto (Local) Variables, but just Aliases */
	value           .req r0
	fraction_digits .req r1
	exponent        .req r2
	value_msw       .req r3 @ Most Significant Words
	value_mlw       .req r4 @ Least Significant Words

	push {r4,lr}

	mov value_msw, #0
	mov value_mlw, #0

	/* Extract Exponent Bit[30:23] */
	mov exponent, #0x7F000000
	orr exponent, exponent, #0x00800000
	and exponent, value, exponent
	lsr exponent, exponent, #23

	sub exponent, exponent, #127

	/* Set Bit[23], Next to Fraction Bit[22:0] to Show Hidden Integer Place, One */
	bic value, value, #0xFF000000
	orr value, value, #0x00800000

	cmp exponent, #0
	bgt vfp32_f32toufix32_exponentplus
	blt vfp32_f32toufix32_exponentminus
	b vfp32_f32toufix32_digits

	vfp32_f32toufix32_exponentplus:
		lsl value_msw, value_msw, #1
		lsls value, value, #1                    @ Substitute of Multiplication by 2
		addcs value_msw, value_msw, #1
		subs exponent, exponent, #1
		bgt vfp32_f32toufix32_exponentplus
		b vfp32_f32toufix32_digits

	vfp32_f32toufix32_exponentminus:
		lsr value_mlw, value_mlw, #1
		lsrs value, value, #1                    @ Substitute of Division by 2
		addcs value_mlw, value_mlw, #0x80000000
		subs exponent, exponent, #-1
		blt vfp32_f32toufix32_exponentminus

	vfp32_f32toufix32_digits:
		subs fraction_digits, fraction_digits, #23 @ Default 23 Digits of Decimal Places
		bgt vfp32_f32toufix32_digits_more
		blt vfp32_f32toufix32_digits_less
		b vfp32_f32toufix32_common

		vfp32_f32toufix32_digits_more:
			lsl value, value, #1                 @ Substitute of Multiplication by 2
			lsls value_mlw, value_mlw, #1
			addcs value, value, #1
			subs fraction_digits, fraction_digits, #1
			bgt vfp32_f32toufix32_digits_more
			b vfp32_f32toufix32_common

		vfp32_f32toufix32_digits_less:
			lsr value, value, #1                 @ Substitute of Division by 2
			lsrs value_msw, value_msw, #1
			addcs value, value, #0x80000000
			subs fraction_digits, fraction_digits, #-1
			blt vfp32_f32toufix32_digits_less

	vfp32_f32toufix32_common:
		pop {r4,pc}

.unreq value
.unreq fraction_digits
.unreq exponent
.unreq value_msw
.unreq value_mlw


/**
 * function vfp32_s32tof32
 * Convert From Signed Integer to Single Precision Float
 *
 * Parameters
 * r0: Value, Must Be Signed Integer
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_s32tof32
vfp32_s32tof32:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value     .req s0

	vpush {s0}

	vmov vfp_value, value
	vcvt.f32.s32 vfp_value, vfp_value
	vmov value, vfp_value

	vfp32_s32tof32_common:
		vpop {s0}
		mov pc, lr

.unreq value
.unreq vfp_value


/**
 * function vfp32_u32tof32
 * Convert From Unsigned Integer to Single Precision Float
 *
 * Parameters
 * r0: Value, Must Be Unigned Integer
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_u32tof32
vfp32_u32tof32:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value     .req s0

	vpush {s0}

	vmov vfp_value, value
	vcvt.f32.u32 vfp_value, vfp_value
	vmov value, vfp_value

	vfp32_u32tof32_common:
		vpop {s0}
		mov pc, lr

.unreq value
.unreq vfp_value


/**
 * function vfp32_f32tos32
 * Convert From Single Precision Float to Signed Integer, Rounded Off
 *
 * Parameters
 * r0: Value, Must Be Single Precision Float
 *
 * Return: r0 (Value by Signed Integer)
 */
.globl vfp32_f32tos32
vfp32_f32tos32:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value     .req s0

	vpush {s0}

	vmov vfp_value, value
	vcvtr.s32.f32 vfp_value, vfp_value
	vmov value, vfp_value

	vfp32_f32tos32_common:
		vpop {s0}
		mov pc, lr

.unreq value
.unreq vfp_value


/**
 * function vfp32_f32tou32
 * Convert From Single Precision Float to Unsigned Integer, Rounded Off
 *
 * Parameters
 * r0: Value, Must Be Single Precision Float
 *
 * Return: r0 (Value by Unsigned Integer)
 */
.globl vfp32_f32tou32
vfp32_f32tou32:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value     .req s0

	vpush {s0}

	vmov vfp_value, value
	vcvtr.u32.f32 vfp_value, vfp_value
	vmov value, vfp_value

	vfp32_f32tou32_common:
		vpop {s0}
		mov pc, lr

.unreq value
.unreq vfp_value


/**
 * function vfp32_fsqrt
 * Square Root
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_fsqrt
vfp32_fsqrt:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value1     .req s0

	vpush {s0}

	vmov vfp_value1, value1
	vsqrt.f32 vfp_value1, vfp_value1
	vmov value1, vfp_value1

	vfp32_fsqrt_common:
		vpop {s0}
		mov pc, lr

.unreq value1
.unreq vfp_value1


/**
 * function vfp32_fcmp
 * Compare Two Values and Return NZCV ALU Flags (Bit[31:28])
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (NZCV ALU Flags (Bit[31:28]))
 */
.globl vfp32_fcmp
vfp32_fcmp:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	mrs value1, apsr
	and value1, value1, #0xF0000000

	vfp32_fcmp_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_feq
 * Compare Two Values and Return True if Equal
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Integer, 0 as False and 1 as True)
 */
.globl vfp32_feq
vfp32_feq:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	moveq value1, #1

	vfp32_feq_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fgt
 * Compare Two Values and Return True if Greater Than
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Integer, 0 as False and 1 as True)
 */
.globl vfp32_fgt
vfp32_fgt:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movgt value1, #1

	vfp32_fgt_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_flt
 * Compare Two Values and Return True if Less Than
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Integer, 0 as False and 1 as True)
 */
.globl vfp32_flt
vfp32_flt:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movlt value1, #1

	vfp32_flt_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fge
 * Compare Two Values and Return True if Greater Than or Equal
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Integer, 0 as False and 1 as True)
 */
.globl vfp32_fge
vfp32_fge:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movge value1, #1

	vfp32_fge_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fle
 * Compare Two Values and Return True if Less Than or Equal
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Integer, 0 as False and 1 as True)
 */
.globl vfp32_fle
vfp32_fle:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movle value1, #1

	vfp32_fle_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fadd
 * Add Two Values with Single Precision Float
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_fadd
vfp32_fadd:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vadd.f32 vfp_value1, vfp_value1, vfp_value2

	vfp32_fadd_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fsub
 * Subtract Two Values with Single Precision Float
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_fsub
vfp32_fsub:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vsub.f32 vfp_value1, vfp_value1, vfp_value2

	vfp32_fsub_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fmul
 * Multiply Two Values with Single Precision Float
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_fmul
vfp32_fmul:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vmul.f32 vfp_value1, vfp_value1, vfp_value2

	vfp32_fmul_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fdiv
 * Multiply Two Values with Single Precision Float
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_fdiv
vfp32_fdiv:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vdiv.f32 vfp_value1, vfp_value1, vfp_value2

	vfp32_fdiv_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_faddi
 * Add Two Values with Single Precision Float and Convert to 32-bit Unsigned Integer
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_faddi
vfp32_faddi:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vadd.f32 vfp_value1, vfp_value1, vfp_value2
	vcvt.s32.f32 vfp_value1, vfp_value1

	vfp32_faddi_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fsubi
 * Subtract Two Values with Single Precision Float and Convert to 32-bit Unsigned Integer
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_fsubi
vfp32_fsubi:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vsub.f32 vfp_value1, vfp_value1, vfp_value2
	vcvt.s32.f32 vfp_value1, vfp_value1

	vfp32_fsubi_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fmuli
 * Multiply Two Values with Single Precision Float and Convert to 32-bit Unsigned Integer
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_fmuli
vfp32_fmuli:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vmul.f32 vfp_value1, vfp_value1, vfp_value2
	vcvt.s32.f32 vfp_value1, vfp_value1

	vfp32_fmuli_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2


/**
 * function vfp32_fdivi
 * Multiply Two Values with Single Precision Float and Convert to 32-bit Unsigned Integer
 *
 * Parameters
 * r0: Value1, Must Be Type of Float
 * r1: Value2, Must Be Type of Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp32_fdivi
vfp32_fdivi:
	/* Auto (Local) Variables, but just Aliases */
	value1         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	value2         .req r1 @ Parameter, Register for Argument, Scratch Register

	/* VFP Registers */
	vfp_value      .req d0
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value, value1, value2

	vdiv.f32 vfp_value1, vfp_value1, vfp_value2
	vcvt.s32.f32 vfp_value1, vfp_value1

	vfp32_fdivi_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value
.unreq vfp_value1
.unreq vfp_value2
