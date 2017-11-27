/**
 * vfp32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


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
	vvalue1        .req s0
	vvalue2        .req s1

	vpush {s0-s1}

	vmov vvalue1, value1
	vmov vvalue2, value2
	mov value1, #0

	vcmp.f32 vvalue1, vvalue2
	vmrs apsr_nzcv, fpscr                           @ Transfer FPSCR Flags to CPSR's NZCV
	movgt value1, #1

	vfp32_fgt_common:
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vvalue1
.unreq vvalue2


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
	vvalue1        .req s0
	vvalue2        .req s1

	vpush {s0-s1}

	vmov vvalue1, value1
	vmov vvalue2, value2

	vadd.f32 vvalue1, vvalue1, vvalue2

	vfp32_fadd_common:
		vmov value1, vvalue1
		vpop {s0-s1}
		mov pc, lr

.unreq value1
.unreq value2
.unreq vvalue1
.unreq vvalue2
