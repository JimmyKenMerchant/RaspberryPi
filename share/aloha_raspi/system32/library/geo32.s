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
 * r1: Number of Vertices on Polygon
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl geo32_shoelace_pre
geo32_shoelace_pre:
	/* Auto (Local) Variables, but just Aliases */
	heap            .req r0
	number_vertices .req r1
	i               .req r2
	temp            .req r3

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
		cmp i, number_vertices
		bhs geo32_shoelace_pre_common

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
.unreq number_vertices
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
 * r1: Number of Vertices on Polygon
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl geo32_shoelace
geo32_shoelace:
	/* Auto (Local) Variables, but just Aliases */
	heap            .req r0
	number_vertices .req r1

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
	.unreq number_vertices
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


/**
 * function geo32_wire3d
 * Draw 3D Wire
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Color
 * r1: Pointer of Series of Vertices; X, Y, and Z by Single Precision Float
 * r2: Number of Vertices on Each Polygon
 * r3: Number of XYZ Units in Pointer of Series of Vertices
 * r4: Pointer of Matrix to Be Used for Transferring
 * r5: Front Rotation, Counter Clockwise(0), Clockwise(1), or Both(2) to Be Drawn
 *
 * Return: r0 (0 as Success, -1 as Warning, 1 and 2 as Error)
 * Warning(-1): Last Polygon is Flip Side Not to Be Drawn
 * Error(1): Memory Allocation Fails
 * Error(2): Buffer Is Not Defined
 */
.globl geo32_wire3d
geo32_wire3d:
	/* Auto (Local) Variables, but just Aliases */
	color           .req r0
	heap_vertices   .req r1
	number_vertices .req r2
	number_units    .req r3
	matrix          .req r4
	rotation        .req r5
	heap_xy         .req r6
	vector_xyzw     .req r7
	result          .req r8
	temp            .req r9
	offset_heap     .req r10
	i               .req r11

	/* VFP Registers */
	vfp_x      .req s0
	vfp_y      .req s1
	vfp_width  .req s2
	vfp_height .req s3
	vfp_one    .req s4
	vfp_two    .req s5
	
	push {r4-r11,lr}

	add sp, sp, #36
	pop {matrix,rotation}
	sub sp, sp, #44

	vpush {s0-s5}

	/* Get Width and Height of Framebuffer and Transfer from Integer to Float */
	ldr temp, geo32_wire3d_FB32_FRAMEBUFFER_WIDTH
	vldr vfp_width, [temp]
	vcvt.f32.u32 vfp_width, vfp_width
	ldr temp, geo32_wire3d_FB32_FRAMEBUFFER_HEIGHT
	vldr vfp_height, [temp]
	vcvt.f32.u32 vfp_height, vfp_height

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one
	vadd.f32 vfp_two, vfp_one, vfp_one

	/* Sanitize for Error, heap32_mfree Will Pass Through 0 with Error */
	mov heap_xy, #0
	mov vector_xyzw, #0

	/* Memory Allocation to Be Needed */

	push {r0-r3}
	lsl r0, number_units, #1      @ Substitute of Multiplication by 2
	bl heap32_malloc
	mov heap_xy, r0
	pop {r0-r3}

	cmp heap_xy, #0
	beq geo32_wire3d_error1

	push {r0-r3}
	mov r0, #4
	bl heap32_malloc
	mov vector_xyzw, r0
	pop {r0-r3}

	cmp heap_xy, #0
	beq geo32_wire3d_error1

	/* W of Vector, Just 1.0 */
	mov temp, #0x3F000000
	orr temp, temp, #0x00800000   @ 1.0 in Hexadecimal of Single Precision Floating Point
	str temp, [vector_xyzw, #12]

	mov offset_heap, #0
	mov i, #0

	geo32_wire3d_transfer:
		cmp i, number_units
		bhs geo32_wire3d_write

		/* X of Vector*/
		ldr temp, [heap_vertices, offset_heap]
		str temp, [vector_xyzw]
		add offset_heap, offset_heap, #4

		/* Y of Vector */
		ldr temp, [heap_vertices, offset_heap]
		str temp, [vector_xyzw, #4]
		add offset_heap, offset_heap, #4

		/* Z of Vector */
		ldr temp, [heap_vertices, offset_heap]
		str temp, [vector_xyzw, #8]
		add offset_heap, offset_heap, #4

		push {r0-r3}
		mov r0, matrix
		mov r1, vector_xyzw
		mov r2, #4
		bl mtx32_multiply_vec
		mov result, r0
		pop {r0-r3}

		cmp result, #0
		beq geo32_wire3d_error1

		lsl i, i, #3                         @ Substitute of Multiplication by 8
		ldr temp, [result]
		str temp, [heap_xy, i]

		add i, i, #4
		ldr temp, [result, #4]
		str temp, [heap_xy, i]

		sub i, i, #4
		lsr i, i, #3                         @ Substitute of Division by 8

		push {r0-r3}
		mov r0, result
		bl heap32_mfree
		pop {r0-r3}

		add i, i, #1
		b geo32_wire3d_transfer

	geo32_wire3d_write:
		mov offset_heap, #0
		mov i, #0

		push {r0-r2}
		mov r0, number_units
		mov r1, number_vertices
		bl arm32_udiv
		mov number_units, r0
		pop {r0-r2}

		geo32_wire3d_write_loop:
			cmp i, number_units
			bhs geo32_wire3d_success

			push {r0-r3}
			add r0, heap_xy, offset_heap
			mov r1, number_vertices
			bl geo32_shoelace_pre
			mov result, r0
			pop {r0-r3}

			vmov vfp_x, result
			vcmp.f32 vfp_x, #0
			vmrs apsr_nzcv, fpscr
			movge result, #0               @ Counter Clockwise
			movlt result, #1               @ Clockwise

			cmp result, rotation
			cmpne rotation, #2

			/* If Flip */

			mvnne result, #0
			bne geo32_wire3d_write_loop_common

			/* If Front */

			mov result, #0

			geo32_wire3d_write_loop_axis:
				cmp result, number_vertices
				bhs geo32_wire3d_write_loop_draw
				lsl temp, result, #3             @ Substitute of Multiplication by 8
				add temp, temp, offset_heap
				add heap_xy, heap_xy, temp       @ Add Offset
				vldmia heap_xy, {vfp_x,vfp_y}

				/* -1.0 to 1.0 coordinate to 0,0 to 1.0, and Flip Y Coordinate  */
				vadd.f32 vfp_x, vfp_one
				vadd.f32 vfp_y, vfp_one
				vdiv.f32 vfp_x, vfp_x, vfp_two
				vdiv.f32 vfp_y, vfp_y, vfp_two
				vsub.f32 vfp_y, vfp_y, vfp_one
				vneg.f32 vfp_y, vfp_y

				/* Multiply 0.0 to 1.0 Coordinates by Actual Width and Height of Framebuffer, Convert Float to Integer */
				vmul.f32 vfp_x, vfp_x, vfp_width
				vmul.f32 vfp_y, vfp_y, vfp_height
				vcvtr.s32.f32 vfp_x, vfp_x
				vcvtr.s32.f32 vfp_y, vfp_y

				vstmia heap_xy, {vfp_x,vfp_y}
				sub heap_xy, heap_xy, temp      @ Subtract Offset

				add result, result, #1
				b geo32_wire3d_write_loop_axis

			geo32_wire3d_write_loop_draw:

				/*  Actual Drawing */
				push {r0-r3}
				add r1, heap_xy, offset_heap
				mov r3, #1
				mov temp, #1
				push {temp}
				bl draw32_polygon
				add sp, sp, #4
				mov result, r0
				pop {r0-r3}

				cmp result, #1
				beq geo32_wire3d_error2

				mov result, #0

			geo32_wire3d_write_loop_common:
				add i, i, #1
				add offset_heap, offset_heap, number_vertices, lsl #3
				b geo32_wire3d_write_loop

	geo32_wire3d_error1:
		mov r0, #1
		b geo32_wire3d_common

	geo32_wire3d_error2:
		mov r0, #2
		b geo32_wire3d_common

	geo32_wire3d_success:
		mov r0, result

	geo32_wire3d_common:
		push {r0}
		mov r0, heap_xy
		bl heap32_mfree
		pop {r0}

		push {r0}
		mov r0, vector_xyzw
		bl heap32_mfree
		pop {r0}

		vpop {s0-s5}
		pop {r4-r11,pc}

.unreq color
.unreq heap_vertices
.unreq number_vertices
.unreq number_units
.unreq matrix
.unreq rotation
.unreq heap_xy
.unreq vector_xyzw
.unreq result
.unreq temp
.unreq offset_heap
.unreq i
.unreq vfp_x
.unreq vfp_y
.unreq vfp_width
.unreq vfp_height
.unreq vfp_one
.unreq vfp_two

geo32_wire3d_FB32_FRAMEBUFFER_WIDTH:  .word FB32_FRAMEBUFFER_WIDTH
geo32_wire3d_FB32_FRAMEBUFFER_HEIGHT: .word FB32_FRAMEBUFFER_HEIGHT

