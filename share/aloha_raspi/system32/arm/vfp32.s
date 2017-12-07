/**
 * vfp32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


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
 * Convert From Single Precision Float to Signed Integer
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
	vcvt.s32.f32 vfp_value, vfp_value
	vmov value, vfp_value

	vfp32_f32tos32_common:
		vpop {s0}
		mov pc, lr

.unreq value
.unreq vfp_value


/**
 * function vfp32_f32tou32
 * Convert From Single Precision Float to Unsigned Integer
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
	vcvt.u32.f32 vfp_value, vfp_value
	vmov value, vfp_value

	vfp32_f32tou32_common:
		vpop {s0}
		mov pc, lr

.unreq value
.unreq vfp_value


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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	moveq value1, #1

	vfp32_feq_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movgt value1, #1

	vfp32_fgt_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movlt value1, #1

	vfp32_flt_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movge value1, #1

	vfp32_fge_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2
	mov value1, #0

	vcmp.f32 vfp_value1, vfp_value2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movle value1, #1

	vfp32_fle_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2

	vadd.f32 vfp_value1, vfp_value1, vfp_value2

	vfp32_fadd_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2

	vsub.f32 vfp_value1, vfp_value1, vfp_value2

	vfp32_fsub_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2

	vmul.f32 vfp_value1, vfp_value1, vfp_value2

	vfp32_fmul_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
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
	vfp_value1     .req s0
	vfp_value2     .req s1

	vpush {s0-s1}

	vmov vfp_value1, value1
	vmov vfp_value2, value2

	vdiv.f32 vfp_value1, vfp_value1, vfp_value2

	vfp32_fdiv_common:
		vmov value1, vfp_value1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vfp_value1
.unreq vfp_value2