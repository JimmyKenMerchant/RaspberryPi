/**
 * stat32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function stat32_fmean
 * Return Arithmetic Mean with Single Precision Float
 *
 * Parameters
 * r0: Array of Single Precision Float
 * r1: Length of Array
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl stat32_fmean
stat32_fmean:
	/* Auto (Local) Variables, but just Aliases */
	array          .req r0
	length         .req r1
	sum            .req r2

	/* VFP Registers */
	vfp_sum        .req s0
	vfp_length     .req s1
	vfp_temp       .req s2

	vpush {s0-s2}

	vmov vfp_length, length
	vcvt.f32.u32 vfp_length, vfp_length

	mov sum, #0
	vmov vfp_sum, sum
	vcvt.f32.u32 vfp_sum, vfp_sum

	cmp length, #0
	vmovle sum, vfp_sum
	ble stat32_fmean_common

	sub length, length, #1
	lsl length, length, #2                  @ Substitute of Multiplication by 4

	stat32_fmean_sum:
		vldr vfp_temp, [array, length]
		vadd.f32 vfp_sum, vfp_sum, vfp_temp
		sub length, length, #4
		cmp length, #0
		bge stat32_fmean_sum
	
	vdiv.f32 vfp_sum, vfp_sum, vfp_length
	vmov sum, vfp_sum

	stat32_fmean_common:
		mov r0, sum
		vpop {s0-s2}
		mov pc, lr

.unreq array
.unreq length
.unreq sum
.unreq vfp_sum
.unreq vfp_length
.unreq vfp_temp

