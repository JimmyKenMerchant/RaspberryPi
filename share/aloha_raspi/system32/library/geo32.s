/**
 * geo32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function geo32_shoelace_pre
 * Return Sigma in Shoelace Formula
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Pointer of Series of Vector X and Y by Single Precision Float
 * r1: Number of Sides of Polygon
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl geo32_shoelace_pre
geo32_shoelace_pre:
	/* Auto (Local) Variables, but just Aliases */
	heap           .req r0
	number_polygon .req r1
	i              .req r2
	temp           .req r3

	/* VFP Registers */
	vfp_x1   .req s0
	vfp_y1   .req s1
	vfp_x2   .req s2
	vfp_y2   .req s3
	vfp_x1y2 .req s4
	vfp_x2y1 .req s5
	vfp_sum  .req s6
	
	vpush {s0-s6}

	/**
	 * Shoelace formula
	 * A = 1/2 * |Sigma[k = 1 to n] (Xk * Yk+1 - Xk+1 * Yk)|
	 */

	mov temp, #0
	vmov vfp_sum, temp         @ Zero of Floating Point is All Zero in Hexadecimal Value

	mov i, #0

	geo32_shoelace_pre_sigma:
		cmp i, number_polygon
		bge geo32_shoelace_pre_common

		vldr vfp_x1, [heap]
		add heap, heap, #4
		vldr vfp_y1, [heap]
		add heap, heap, #4
		vldr vfp_x2, [heap]
		add heap, heap, #4
		vldr vfp_y2, [heap]
		sub heap, heap, #4
		
		vmul.f32 vfp_x1y2, vfp_x1, vfp_y2
		vmul.f32 vfp_x2y1, vfp_x2, vfp_y1

		vsub.f32 vfp_x1y2, vfp_x1y2, vfp_x2y1

		vadd.f32 vfp_sum, vfp_sum, vfp_x1y2
		add i, i, #1
		b geo32_shoelace_pre_sigma

	geo32_shoelace_pre_common:
		vmov r0, vfp_sum
		vpop {s0-s6}
		mov pc, lr

.unreq heap
.unreq number_polygon
.unreq i
.unreq temp
.unreq vfp_x1
.unreq vfp_y1
.unreq vfp_x2
.unreq vfp_y2
.unreq vfp_x1y2
.unreq vfp_x2y1
.unreq vfp_sum


/**
 * function geo32_shoelace
 * Return Area by Shoelace Formula
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Pointer of Series of Vector X and Y by Single Precision Float
 * r1: Number of Sides of Polygon
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl geo32_shoelace
geo32_shoelace:
	/* Auto (Local) Variables, but just Aliases */
	heap           .req r0
	number_polygon .req r1

	/* VFP Registers */
	vfp_sigma .req s0
	vfp_two   .req s1
	
	push {lr}
	vpush {s0-s1}

	/**
	 * Shoelace formula
	 * A = 1/2 * |Sigma[k = 1 to n] (Xk * Yk+1 - Xk+1 * Yk)|
	 */

	bl geo32_shoelace_pre

	.unreq heap
	.unreq number_polygon
	sigma .req r0
	two   .req r1

	vmov vfp_sigma, sigma
	vabs.f32 vfp_sigma, vfp_sigma

	mov two, #2
	vmov vfp_two, two
	vcvt.f32.u32 vfp_two, vfp_two

	vdiv.f32 vfp_sigma, vfp_sigma, vfp_two

	geo32_shoelace_common:
		vmov r0, vfp_sigma
		vpop {s0-s1}
		pop {pc}

.unreq sigma
.unreq two
.unreq vfp_sigma
.unreq vfp_two

