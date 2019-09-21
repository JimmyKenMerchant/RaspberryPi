/**
 * mtx32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function mtx32_multiply
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
.globl mtx32_multiply
mtx32_multiply:
	/* Auto (Local) Variables, but just Aliases */
	matrix1     .req r0
	matrix2     .req r1
	number_mat  .req r2
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
	beq mtx32_multiply_common

	mov index, #0

	/* for ( uint32 column = 0; column < number_mat; column++ ) { */
	mov column, #0
	mtx32_multiply_column:
		cmp column, number_mat
		bge mtx32_multiply_common

		/* for ( uint32 row = 0; row < number_mat; row++ ) { */
		mov row, #0
		mtx32_multiply_column_row:
			cmp row, number_mat
			bge mtx32_multiply_column_row_common

			mov temp, #0
			vmov vfp_sum, temp
			vcvt.f32.s32 vfp_sum, vfp_sum

			/* for ( uint32 i = 0; i < number_mat; i++ ) { */
			mov i, #0
			mtx32_multiply_column_row_i:
				cmp i, number_mat
				bge mtx32_multiply_column_row_i_common

				mul temp, column, number_mat
				add temp, temp, i
				ldr temp, [matrix1, temp, lsl #2]           @ Substitution of Multiplication by 4
				
				mul temp2, i, number_mat
				add temp2, temp2, row
				ldr temp2, [matrix2, temp2, lsl #2]         @ Substitution of Multiplication by 4

				vmov vfp_value, temp, temp2
				vmla.f32 vfp_sum, vfp_value1, vfp_value2    @ Multiply and Accumulate

				add i, i, #1
				b mtx32_multiply_column_row_i
	
			/* } */
				mtx32_multiply_column_row_i_common:
					vmov temp, vfp_sum
					str temp, [matrix_ret, index]
					add index, index, #4

					add row, row, #1
					b mtx32_multiply_column_row

		/* } */
			mtx32_multiply_column_row_common:

				add column, column, #1
				b mtx32_multiply_column

	/* } */
	mtx32_multiply_common:
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
 * function mtx32_identity
 * Get Identity of Matrix
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Number of Rows and Columns
 *
 * Return: r0 (Matrix to Have Identity, If Zero Not Allocated Memory)
 */
.globl mtx32_identity
mtx32_identity:
	/* Auto (Local) Variables, but just Aliases */
	number_mat  .req r0
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
	beq mtx32_identity_common

	mov one, #1
	vmov vfp_one, one
	vcvt.f32.s32 vfp_one, vfp_one
	vmov one, vfp_one

	mov i, number_mat
	add number_mat, number_mat, #1

	mov offset, #0

	mtx32_identity_loop:
		cmp i, #0
		ble mtx32_identity_common

		str one, [matrix, offset, lsl #2] @ Substitution of Multiplication by 4

		add offset, offset, number_mat
		sub i, i, #1
		b mtx32_identity_loop

	mtx32_identity_common:
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
 * function mtx32_multiply_vec
 * Square Matrix and Column Vector Multiplication
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Matrix
 * r1: Vector
 * r2: Number of Vector Size
 *
 * Return: r0 (Vector to Have Been Multiplied, If Zero Not Allocated Memory)
 */
.globl mtx32_multiply_vec
mtx32_multiply_vec:
	/* Auto (Local) Variables, but just Aliases */
	matrix         .req r0
	vector         .req r1
	number_vec     .req r2
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
	beq mtx32_multiply_vec_common

	mov offset, #0
	mov i, #0

	mtx32_multiply_vec_row:
		cmp i, number_vec
		bge mtx32_multiply_vec_common

		mov temp1, #0
		vmov vfp_result, temp1
		vcvt.f32.s32 vfp_result, vfp_result

		mov temp1, number_vec
		sub temp1, temp1, #1

		add temp2, offset, temp1

		mtx32_multiply_vec_row_column:
			cmp temp1, #0
			blt mtx32_multiply_vec_row_common

			ldr value1, [matrix, temp2, lsl #2]         @ Substitution of Multiplication by 4
			ldr value2, [vector, temp1, lsl #2]         @ Substitution of Multiplication by 4
			vmov vfp_value, value1, value2
			vmla.f32 vfp_result, vfp_value1, vfp_value2

			sub temp1, temp1, #1
			sub temp2, temp2, #1
			b mtx32_multiply_vec_row_column

		mtx32_multiply_vec_row_common:
			vmov value1, vfp_result
			str value1, [vector_result, i, lsl #2]      @ Substitution of Multiplication by 4
			add offset, offset, number_vec
			add i, i, #1

			b mtx32_multiply_vec_row

	mtx32_multiply_vec_common:
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
 * function mtx32_normalize
 * Normalize Vector
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Vector
 * r1: Number of Vector Size
 *
 * Return: r0 (Vector to Have Been Normalized, If Zero Not Allocated Memory)
 */
.globl mtx32_normalize
mtx32_normalize:
	/* Auto (Local) Variables, but just Aliases */
	vector        .req r0
	number_vec    .req r1
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
	beq mtx32_normalize_common

	mov temp, #0
	vmov vfp_length, temp
	vcvt.f32.s32 vfp_length, vfp_length

	mov temp, number_vec
	sub temp, temp, #1

	mtx32_normalize_length:
		cmp temp, #0
		blt mtx32_normalize_checkzero

		ldr value, [vector, temp, lsl #2]              @ Substitution of Multiplication by 4
		vmov vfp_value, value
		vmla.f32 vfp_length, vfp_value, vfp_value

		sub temp, temp, #1
		b mtx32_normalize_length

	mtx32_normalize_checkzero:
		vsqrt.f32 vfp_length, vfp_length
		vcmp.f32 vfp_length, #0
		vmrs apsr_nzcv, fpscr                          @ Transfer FPSCR Flags to CPSR's NZCV
		beq mtx32_normalize_common

		sub number_vec, number_vec, #1

	mtx32_normalize_normal:
		cmp number_vec, #0
		blt mtx32_normalize_common

		ldr value, [vector, number_vec, lsl #2]        @ Substitution of Multiplication by 4
		vmov vfp_value, value
		vdiv.f32 vfp_value, vfp_value, vfp_length
		vmov value, vfp_value
		str value, [vector_result, number_vec, lsl #2] @ Substitution of Multiplication by 4

		sub number_vec, number_vec, #1
		b mtx32_normalize_normal

	mtx32_normalize_common:
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
 * function mtx32_dotproduct
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
.globl mtx32_dotproduct
mtx32_dotproduct:
	/* Auto (Local) Variables, but just Aliases */
	vector1    .req r0
	vector2    .req r1
	number_vec .req r2
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

	mtx32_dotproduct_normal:
		cmp number_vec, #0
		blt mtx32_dotproduct_common

		ldr value, [vector1, number_vec, lsl #2] @ Substitution of Multiplication by 4
		vmov vfp_value1, value
		ldr value, [vector2, number_vec, lsl #2] @ Substitution of Multiplication by 4
		vmov vfp_value2, value
		vmla.f32 vfp_dot, vfp_value1, vfp_value2

		sub number_vec, number_vec, #1
		b mtx32_dotproduct_normal

	mtx32_dotproduct_common:
		vmov r0, vfp_dot
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
 * function mtx32_crossproduct
 * Cross Product
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Vector1, Must Be Three of Vector Size
 * r1: Vector2, Must Be Three of Vector Size
 *
 * Return: r0 (Vector to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_crossproduct
mtx32_crossproduct:
	/* Auto (Local) Variables, but just Aliases */
	vector1       .req r0
	vector2       .req r1
	number_vec    .req r2
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

	mtx32_crossproduct_common:
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


/**
 * function mtx32_translate3d
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Translation
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Vector, Must Be Three of Vector Size, X, Y, and Z
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_translate3d
mtx32_translate3d:
	/* Auto (Local) Variables, but just Aliases */
	vector        .req r0
	matrix_result .req r1
	value         .req r2

	push {lr}

	push {r0}
	mov r0, #4
	bl mtx32_identity
	mov matrix_result, r0
	pop {r0}

	cmp matrix_result, #0
	beq mtx32_translate3d_common

	ldr value, [vector]
	str value, [matrix_result, #48] @ Matrix_result[12], X
	ldr value, [vector, #4]
	str value, [matrix_result, #52] @ Matrix_result[13], Y
	ldr value, [vector, #8]
	str value, [matrix_result, #56] @ Matrix_result[14], Z

	mtx32_translate3d_common:
		mov r0, matrix_result
		pop {pc}

.unreq vector
.unreq matrix_result
.unreq value


/**
 * function mtx32_scale3d
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Scale
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Vector, Must Be Three of Vector Size, X, Y, and Z
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_scale3d
mtx32_scale3d:
	/* Auto (Local) Variables, but just Aliases */
	vector        .req r0
	matrix_result .req r1
	value         .req r2

	push {lr}

	push {r0}
	mov r0, #4
	bl mtx32_identity
	mov matrix_result, r0
	pop {r0}

	cmp matrix_result, #0
	beq mtx32_scale3d_common

	ldr value, [vector]
	str value, [matrix_result]      @ Matrix_result[0], X
	ldr value, [vector, #4]
	str value, [matrix_result, #20] @ Matrix_result[5], Y
	ldr value, [vector, #8]
	str value, [matrix_result, #40] @ Matrix_result[10], Z

	mtx32_scale3d_common:
		mov r0, matrix_result
		pop {pc}

.unreq vector
.unreq matrix_result
.unreq value


/**
 * function mtx32_rotatex3d
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Rotate X
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Value of Degrees, Must Be Single Precision Float
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_rotatex3d
mtx32_rotatex3d:
	/* Auto (Local) Variables, but just Aliases */
	degree        .req r0
	matrix_result .req r1
	value         .req r2

	/* VFP Registers */
	vfp_value     .req s0

	push {lr}
	vpush {s0}

	bl math32_degree_to_radian
	.unreq degree
	radian .req r0

	push {r0}
	mov r0, #4
	bl mtx32_identity
	mov matrix_result, r0
	pop {r0}

	cmp matrix_result, #0
	beq mtx32_rotatex3d_common

	push {r0}
	bl math32_cos
	mov value, r0
	pop {r0}

	str value, [matrix_result, #20] @ Matrix_result[5], cos
	str value, [matrix_result, #40] @ Matrix_result[10], cos

	push {r0}
	bl math32_sin
	mov value, r0
	pop {r0}

	str value, [matrix_result, #24] @ Matrix_result[6], sin
	vmov vfp_value, value
	vneg.f32 vfp_value, vfp_value
	vmov value, vfp_value
	str value, [matrix_result, #36] @ Matrix_result[9], -sin

	mtx32_rotatex3d_common:
		mov r0, matrix_result
		vpop {s0}
		pop {pc}

.unreq radian
.unreq matrix_result
.unreq value
.unreq vfp_value


/**
 * function mtx32_rotatey3d
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Rotate Y
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Value of Degrees, Must Be Single Precision Float
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_rotatey3d
mtx32_rotatey3d:
	/* Auto (Local) Variables, but just Aliases */
	degree        .req r0
	matrix_result .req r1
	value         .req r2

	/* VFP Registers */
	vfp_value     .req s0

	push {lr}
	vpush {s0}

	bl math32_degree_to_radian
	.unreq degree
	radian .req r0

	push {r0}
	mov r0, #4
	bl mtx32_identity
	mov matrix_result, r0
	pop {r0}

	cmp matrix_result, #0
	beq mtx32_rotatey3d_common

	push {r0}
	bl math32_cos
	mov value, r0
	pop {r0}

	str value, [matrix_result]      @ Matrix_result[0], cos
	str value, [matrix_result, #40] @ Matrix_result[10], cos

	push {r0}
	bl math32_sin
	mov value, r0
	pop {r0}

	str value, [matrix_result, #32] @ Matrix_result[8], sin
	vmov vfp_value, value
	vneg.f32 vfp_value, vfp_value
	vmov value, vfp_value
	str value, [matrix_result, #8]  @ Matrix_result[2], -sin

	mtx32_rotatey3d_common:
		mov r0, matrix_result
		vpop {s0}
		pop {pc}

.unreq radian
.unreq matrix_result
.unreq value
.unreq vfp_value


/**
 * function mtx32_rotatez3d
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Rotate Z
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Value of Degrees, Must Be Single Precision Float
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_rotatez3d
mtx32_rotatez3d:
	/* Auto (Local) Variables, but just Aliases */
	degree        .req r0
	matrix_result .req r1
	value         .req r2

	/* VFP Registers */
	vfp_value     .req s0

	push {lr}
	vpush {s0}

	bl math32_degree_to_radian
	.unreq degree
	radian .req r0

	push {r0}
	mov r0, #4
	bl mtx32_identity
	mov matrix_result, r0
	pop {r0}

	cmp matrix_result, #0
	beq mtx32_rotatez3d_common

	push {r0}
	bl math32_cos
	mov value, r0
	pop {r0}

	str value, [matrix_result]      @ Matrix_result[0], cos
	str value, [matrix_result, #20] @ Matrix_result[5], cos

	push {r0}
	bl math32_sin
	mov value, r0
	pop {r0}

	str value, [matrix_result, #4]  @ Matrix_result[1], sin
	vmov vfp_value, value
	vneg.f32 vfp_value, vfp_value
	vmov value, vfp_value
	str value, [matrix_result, #16] @ Matrix_result[4], -sin

	mtx32_rotatez3d_common:
		mov r0, matrix_result
		vpop {s0}
		pop {pc}

.unreq radian
.unreq matrix_result
.unreq value
.unreq vfp_value


/**
 * function mtx32_perspective3d
 * Make 4 by 4 Square Matrix (Column Order) with Perspective
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: FovY (Field of View Y: Vertical) by Degrees, Must Be Single Precison Float
 * r1: Aspect, Must Be Single Precision Float
 * r2: Near, Must Be Single Precision Float
 * r3: Far, Must Be Single Precision Float
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_perspective3d
mtx32_perspective3d:
	/* Auto (Local) Variables, but just Aliases */
	fovy_deg      .req r0
	aspect        .req r1
	near          .req r2
	far           .req r3
	matrix_result .req r4
	temp          .req r5

	/* VFP Registers */
	vfp_fovy_rad .req s0
	vfp_aspect   .req s1
	vfp_near     .req s2
	vfp_far      .req s3
	vfp_two      .req s4
	vfp_temp     .req s5
	vfp_temp2    .req s6

	push {r4-r5,lr}
	vpush {s0-s6}

	/* Make All Zero 4-4 Martrix */
	push {r0-r3}
	mov r0, #16 
	bl heap32_malloc
	mov matrix_result, r0
	pop {r0-r3}

	cmp matrix_result, #0
	beq mtx32_perspective3d_common

	/* FovY by Degrees to Radian */

	push {r1-r3}
	bl math32_degree_to_radian
	pop {r1-r3}
	.unreq fovy_deg
	fovy_rad .req r0

	vmov vfp_fovy_rad, fovy_rad
	vmov vfp_aspect, aspect
	vmov vfp_near, near
	vmov vfp_far, far
	mov temp, #2
	vmov vfp_two, temp
	vcvt.f32.s32 vfp_two, vfp_two

	/* Make Range, tan( fovy_rad / 2.0 ) * near */

	vdiv.f32 vfp_fovy_rad, vfp_fovy_rad, vfp_two
	vmov fovy_rad, vfp_fovy_rad

	push {r1-r3}
	bl math32_tan
	pop {r1-r3}

	.unreq fovy_rad
	.unreq vfp_fovy_rad
	range .req r0
	vfp_range .req s0

	vmov vfp_range, range
	vmul.f32 vfp_range, vfp_range, vfp_near

	/* Make Sx, near / range * aspect */
	vmul.f32 vfp_temp2, vfp_range, vfp_aspect
	vdiv.f32 vfp_temp, vfp_near, vfp_temp2
	vstr vfp_temp, [matrix_result]             @ Matrix_result[0]

	/* Make Sy, near / range */
	vdiv.f32 vfp_temp, vfp_near, vfp_range
	vstr vfp_temp, [matrix_result, #20]        @ Matrix_result[5]

	/* Make Sz, -(far + near) / (far - near) */
	vadd.f32 vfp_temp, vfp_far, vfp_near
	vneg.f32 vfp_temp, vfp_temp
	vsub.f32 vfp_temp2, vfp_far, vfp_near
	vdiv.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #40]        @ Matrix_result[10]

	/* -1 */
	mov temp, #-1
	vmov vfp_temp, temp
	vcvt.f32.s32 vfp_temp, vfp_temp
	vstr vfp_temp, [matrix_result, #44]        @ Matrix_result[11]

	/* Make Pz, -(2.0 * far * near) / (far - near) */
	vmul.f32 vfp_temp, vfp_two, vfp_far
	vmul.f32 vfp_temp, vfp_temp, vfp_near
	vneg.f32 vfp_temp, vfp_temp
	vsub.f32 vfp_temp2, vfp_far, vfp_near
	vdiv.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #56]        @ Matrix_result[14]

	mtx32_perspective3d_common:
		mov r0, matrix_result
		vpop {s0-s6}
		pop {r4-r5,pc}

.unreq range
.unreq aspect
.unreq near
.unreq far
.unreq matrix_result
.unreq temp
.unreq vfp_range
.unreq vfp_aspect
.unreq vfp_near
.unreq vfp_far
.unreq vfp_two
.unreq vfp_temp
.unreq vfp_temp2


/**
 * function mtx32_view3d
 * Make 4 by 4 Square Matrix (Column Order) with View
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Vector of Camera Position, Must Be Three of Vector Size, X, Y, and Z
 * r1: Vector of Target Position, Must Be Three of Vector Size, X, Y, and Z
 * r2: Vector of Up (Above Your Head), Must Be Three of Vector Size, X, Y, and Z
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_view3d
mtx32_view3d:
	/* Auto (Local) Variables, but just Aliases */
	vec_cam       .req r0
	vec_trg       .req r1
	vec_up        .req r2
	matrix_orient .req r3
	vec_distance  .req r4
	temp          .req r5
	vec_cam_inv   .req r6

	/* VFP Registers */
	vfp_vec_x     .req s0
	vfp_vec_y     .req s1
	vfp_vec_z     .req s2
	vfp_vec2_x    .req s3
	vfp_vec2_y    .req s4
	vfp_vec2_z    .req s5
	vfp_temp      .req s6

	push {r4-r6,lr}
	vpush {s0-s6}

	vldr vfp_vec_x, [vec_cam]
	vldr vfp_vec_y, [vec_cam, #4]
	vldr vfp_vec_z, [vec_cam, #8]
	vneg.f32 vfp_vec_x, vfp_vec_x @ Invert
	vneg.f32 vfp_vec_y, vfp_vec_y @ Invert
	vneg.f32 vfp_vec_z, vfp_vec_z @ Invert
	vldr vfp_vec2_x, [vec_trg]
	vldr vfp_vec2_y, [vec_trg, #4]
	vldr vfp_vec2_z, [vec_trg, #8]

	/* Make Matrix of Camera Position*/
	push {r0-r3}
	mov r0, #3
	bl heap32_malloc
	mov vec_cam_inv, r0
	pop {r0-r3}

	cmp vec_cam_inv, #0
	beq mtx32_view3d_common

	vstr vfp_vec_x, [vec_cam_inv]
	vstr vfp_vec_y, [vec_cam_inv, #4]
	vstr vfp_vec_z, [vec_cam_inv, #8]

	.unreq vec_cam
	matrix_cam .req r0

	push {r1-r3}
	mov r0, vec_cam_inv
	bl mtx32_translate3d
	pop {r1-r3}

	push {r0-r3}
	mov r0, vec_cam_inv
	bl heap32_mfree
	pop {r0-r3}

	cmp matrix_cam, #0
	beq mtx32_view3d_common

	/* Make Vector of Distance Between Target and Camera Posision */

	push {r0-r3}
	mov r0, #3
	bl heap32_malloc
	mov vec_distance, r0
	pop {r0-r3}

	cmp vec_distance, #0
	bne mtx32_view3d_distance

	push {r0-r3}
	mov r0, matrix_cam
	bl heap32_mfree
	pop {r0-r3}

	mov matrix_cam, #0
	b mtx32_view3d_common

	mtx32_view3d_distance:

		vadd.f32 vfp_temp, vfp_vec2_x, vfp_vec_x @ Camera Position is Inverted
		vstr vfp_temp, [vec_distance]
		vadd.f32 vfp_temp, vfp_vec2_y, vfp_vec_y @ Camera Position is Inverted
		vstr vfp_temp, [vec_distance, #4]
		vadd.f32 vfp_temp, vfp_vec2_z, vfp_vec_z @ Camera Position is Inverted
		vstr vfp_temp, [vec_distance, #8]

		/* Make Forward Vector from Distance, e.g., Index Finger */

		push {r0-r3}
		mov r0, vec_distance
		mov r1, #3
		bl mtx32_normalize
		mov temp, r0
		pop {r0-r3}

		push {r0-r3}
		mov r0, vec_distance
		bl heap32_mfree
		pop {r0-r3}

		.unreq vec_distance
		vec_forward .req r4

		mov vec_forward, temp
		cmp vec_forward, #0
		bne mtx32_view3d_right

		push {r0-r3}
		mov r0, matrix_cam
		bl heap32_mfree
		pop {r0-r3}

		mov matrix_cam, #0
		b mtx32_view3d_common

	mtx32_view3d_right:

		/* Make Right Vector, e.g., Middle Finger */

		push {r0-r1,r3}
		mov r0, vec_forward
		mov r1, vec_up
		bl mtx32_crossproduct
		mov vec_up, r0
		pop {r0-r1,r3}

		cmp vec_up, #0
		bne mtx32_view3d_right_normalize

		push {r0-r3}
		mov r0, matrix_cam
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, vec_forward
		bl heap32_mfree
		pop {r0-r3}

		mov matrix_cam, #0
		b mtx32_view3d_common

		mtx32_view3d_right_normalize:

			push {r0-r3}
			mov r0, vec_up
			mov r1, #3
			bl mtx32_normalize
			mov temp, r0
			pop {r0-r3}

			push {r0-r3}
			mov r0, vec_up
			bl heap32_mfree
			pop {r0-r3}

			.unreq vec_up
			vec_right .req r2

			mov vec_right, temp
			cmp vec_right, #0
			bne mtx32_view3d_realup

			push {r0-r3}
			mov r0, matrix_cam
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, vec_forward
			bl heap32_mfree
			pop {r0-r3}

			mov matrix_cam, #0
			b mtx32_view3d_common

	mtx32_view3d_realup:
		/* Make Real Up Vector, e.g., Thumb */

		push {r0,r2-r3}
		mov r0, vec_right
		mov r1, vec_forward
		bl mtx32_crossproduct
		mov vec_trg, r0
		pop {r0,r2-r3}

		cmp vec_trg, #0
		bne mtx32_view3d_realup_normalize

		push {r0-r3}
		mov r0, matrix_cam
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, vec_forward
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, vec_right
		bl heap32_mfree
		pop {r0-r3}

		mov matrix_cam, #0
		b mtx32_view3d_common

		mtx32_view3d_realup_normalize:

			push {r0-r3}
			mov r0, vec_trg
			mov r1, #3
			bl mtx32_normalize
			mov temp, r0
			pop {r0-r3}

			push {r0-r3}
			mov r0, vec_trg
			bl heap32_mfree
			pop {r0-r3}

			.unreq vec_trg
			vec_realup .req r1

			mov vec_realup, temp
			cmp vec_realup, #0
			bne mtx32_view3d_identify

			push {r0-r3}
			mov r0, matrix_cam
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, vec_forward
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, vec_right
			bl heap32_mfree
			pop {r0-r3}

			mov matrix_cam, #0
			b mtx32_view3d_common

	mtx32_view3d_identify:
		/* Make Identified 4-4 Martrix */

		push {r0-r2}
		mov r0, #4
		bl mtx32_identity
		mov matrix_orient, r0
		pop {r0-r2}

		cmp matrix_orient, #0
		bne mtx32_view3d_identify_main

		push {r0-r3}
		mov r0, matrix_cam
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, vec_forward
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, vec_right
		bl heap32_mfree
		pop {r0-r3}

		push {r0-r3}
		mov r0, vec_realup
		bl heap32_mfree
		pop {r0-r3}

		mov matrix_cam, #0
		b mtx32_view3d_common

		mtx32_view3d_identify_main:

			vldr vfp_vec_x, [vec_forward]
			vldr vfp_vec_y, [vec_forward, #4]
			vldr vfp_vec_z, [vec_forward, #8]
			vneg.f32 vfp_vec_x, vfp_vec_x @ Invert
			vneg.f32 vfp_vec_y, vfp_vec_y @ Invert
			vneg.f32 vfp_vec_z, vfp_vec_z @ Invert

			ldr temp, [vec_right]
			str temp, [matrix_orient]
			ldr temp, [vec_realup]
			str temp, [matrix_orient, #4]
			vstr vfp_vec_x, [matrix_orient, #8]

			ldr temp, [vec_right, #4]
			str temp, [matrix_orient, #16]
			ldr temp, [vec_realup, #4]
			str temp, [matrix_orient, #20]
			vstr vfp_vec_y, [matrix_orient, #24]

			ldr temp, [vec_right, #8]
			str temp, [matrix_orient, #32]
			ldr temp, [vec_realup, #8]
			str temp, [matrix_orient, #36]
			vstr vfp_vec_z, [matrix_orient, #40]

			push {r0-r3}
			mov r1, matrix_orient
			mov r2, #4
			bl mtx32_multiply
			mov temp, r0
			pop {r0-r3}

			push {r0-r3}
			mov r0, matrix_cam
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, vec_forward
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, vec_right
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, vec_realup
			bl heap32_mfree
			pop {r0-r3}

			push {r0-r3}
			mov r0, matrix_orient
			bl heap32_mfree
			pop {r0-r3}

			mov matrix_cam, temp

	mtx32_view3d_common:
		vpop {s0-s6}
		pop {r4-r6,pc}

.unreq matrix_cam
.unreq vec_realup
.unreq vec_right
.unreq matrix_orient
.unreq vec_forward
.unreq temp
.unreq vec_cam_inv
.unreq vfp_vec_x
.unreq vfp_vec_y
.unreq vfp_vec_z
.unreq vfp_vec2_x
.unreq vfp_vec2_y
.unreq vfp_vec2_z
.unreq vfp_temp


/**
 * function mtx32_versor
 * Make Versor
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Value of Angle, Must Be Single Precision Float
 * r1: Vector, Must Be Three of Vector Size, X, Y, and Z
 *
 * Return: r0 (Versor, If Zero Not Allocated Memory)
 */
.globl mtx32_versor
mtx32_versor:
	/* Auto (Local) Variables, but just Aliases */
	angle         .req r0
	vector        .req r1
	versor        .req r2
	temp          .req r3

	/* VFP Registers */
	vfp_sin_angle .req s0
	vfp_temp      .req s1
	vfp_temp2     .req s2

	push {lr}
	vpush {s0-s2}

	/* Allocate Memory Space for Versor  */

	push {r0-r1}
	mov r0, #4
	bl heap32_malloc
	mov versor, r0
	pop {r0-r1}

	cmp versor, #0
	beq mtx32_versor_common

	/* Convert Degree to Radian and Divide by 2 */

	push {r1-r2}
	bl math32_degree_to_radian
	pop {r1-r2}

	vmov vfp_temp, angle
	mov temp, #2
	vmov vfp_temp2, temp
	vcvt.f32.s32 vfp_temp2, vfp_temp2
	vdiv.f32 vfp_temp, vfp_temp, vfp_temp2
	vmov angle, vfp_temp

	/* Normalize Vector */

	push {r0,r2}
	mov r0, vector
	mov r1, #3
	bl mtx32_normalize
	mov vector, r0
	pop {r0,r2}

	cmp vector, #0
	beq mtx32_versor_common

	/* Set W of Versor */

	push {r0-r2}
	mov r0, angle
	bl math32_cos
	str r0, [versor]
	pop {r0-r2}

	/* Calculate Sin */

	push {r0-r2}
	mov r0, angle
	bl math32_sin
	vmov vfp_sin_angle, r0
	pop {r0-r2}

	/* Set X of Versor */

	vldr vfp_temp, [vector]
	vmul.f32 vfp_temp, vfp_sin_angle, vfp_temp
	vstr vfp_temp, [versor, #4]

	/* Set Y of Versor */

	vldr vfp_temp, [vector, #4]
	vmul.f32 vfp_temp, vfp_sin_angle, vfp_temp
	vstr vfp_temp, [versor, #8]

	/* Set Z of Versor */

	vldr vfp_temp, [vector, #8]
	vmul.f32 vfp_temp, vfp_sin_angle, vfp_temp
	vstr vfp_temp, [versor, #12]

	push {r0-r3}
	mov r0, vector
	bl heap32_mfree
	pop {r0-r3}

	mtx32_versor_common:
		mov r0, versor
		vpop {s0-s2}
		pop {pc}

.unreq angle
.unreq vector
.unreq versor
.unreq temp
.unreq vfp_sin_angle
.unreq vfp_temp
.unreq vfp_temp2


/**
 * function mtx32_versortomatrix
 * Make Matrix from Versor
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r0: Versor, Must Be Four of Versor Size, W, X, Y, and Z
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_versortomatrix
mtx32_versortomatrix:
	/* Auto (Local) Variables, but just Aliases */
	versor        .req r0
	matrix_result .req r1
	temp          .req r2

	/* VFP Registers */
	vfp_versor_w .req s0
	vfp_versor_x .req s1
	vfp_versor_y .req s2
	vfp_versor_z .req s3
	vfp_one      .req s4 
	vfp_two      .req s5 
	vfp_temp     .req s6
	vfp_temp2    .req s7

	push {lr}
	vpush {s0-s7}

	/* Allocate Memory Space for Versor  */

	push {r0}
	mov r0, #16
	bl heap32_malloc
	mov matrix_result, r0
	pop {r0}

	cmp matrix_result, #0
	beq mtx32_versortomatrix_common

	vldr vfp_versor_w, [versor]
	vldr vfp_versor_x, [versor, #4]
	vldr vfp_versor_y, [versor, #8]
	vldr vfp_versor_z, [versor, #12]
	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.s32 vfp_one, vfp_one
	mov temp, #2
	vmov vfp_two, temp
	vcvt.f32.s32 vfp_two, vfp_two

	/* Matrix[14,13,12,11,7,3] is Zero, No Need of Store It Because Zero(Binary All 0 means float 0.0) has Already Set */

	/* Matrix[0] 1.0 - 2.0 * y * y - 2.0 * z * z */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_y
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_y
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_z
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_z
	vsub.f32 vfp_temp, vfp_one, vfp_temp
	vsub.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result]

	/* Matrix[1] 2.0 * x * y + 2.0 * w * z */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_x
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_y
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_w
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_z
	vadd.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #4]

	/* Matrix[2] 2.0 * x * z - 2.0 * w * y */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_x
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_z
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_w
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_y
	vsub.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #8]

	/* Matrix[4] 2.0 * x * y - 2.0 * w * z */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_x
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_y
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_w
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_z
	vsub.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #16]

	/* Matrix[5] 1.0 - 2.0 * x * x - 2.0 * z * z */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_x
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_x
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_z
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_z
	vsub.f32 vfp_temp, vfp_one, vfp_temp
	vsub.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #20]

	/* Matrix[6] 2.0 * y * z + 2.0 * w * x */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_y
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_z
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_w
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_x
	vadd.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #24]

	/* Matrix[8] 2.0 * x * z + 2.0 * w * y */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_x
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_z
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_w
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_y
	vadd.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #32]

	/* Matrix[9] 2.0 * y * z - 2.0 * w * x */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_y
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_z
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_w
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_x
	vsub.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #36]

	/* Matrix[10] 1.0 - 2.0 * x * x - 2.0 * y * y */
	vmul.f32 vfp_temp, vfp_two, vfp_versor_x
	vmul.f32 vfp_temp, vfp_temp, vfp_versor_x
	vmul.f32 vfp_temp2, vfp_two, vfp_versor_y
	vmul.f32 vfp_temp2, vfp_temp2, vfp_versor_y
	vsub.f32 vfp_temp, vfp_one, vfp_temp
	vsub.f32 vfp_temp, vfp_temp, vfp_temp2
	vstr vfp_temp, [matrix_result, #40]

	/* Matrix[15] 1.0 */
	vstr vfp_one, [matrix_result, #60]

	mtx32_versortomatrix_common:
		mov r0, matrix_result
		vpop {s0-s7}
		pop {pc}

.unreq versor
.unreq matrix_result
.unreq temp
.unreq vfp_versor_w
.unreq vfp_versor_x
.unreq vfp_versor_y
.unreq vfp_versor_z
.unreq vfp_one
.unreq vfp_two
.unreq vfp_temp
.unreq vfp_temp2

