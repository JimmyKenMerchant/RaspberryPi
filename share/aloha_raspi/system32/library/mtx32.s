/**
 * matx32.s
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
	matrix1     .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	matrix2     .req r1 @ Parameter, Register for Argument, Scratch Register
	number_mat  .req r2 @ Parameter, Register for Argument, Scratch Register
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
	number_mat  .req r0 @ Parameter, Register for Argument and Result, Scratch Register
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
 *
 * Parameters
 * r0: Matrix
 * r1: Vector
 * r2: Number of Vector Size
 *
 * Return: r0 (Value of Dot Product by Single Precision Float)
 */
.globl mtx32_multiply_vec
mtx32_multiply_vec:
	/* Auto (Local) Variables, but just Aliases */
	matrix         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	vector         .req r1 @ Parameter, Register for Argument, Scratch Register
	number_vec     .req r2 @ Parameter, Register for Argument, Scratch Register
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
 * r1: Vector
 * r0: Number of Vector Size
 *
 * Return: r0 (Vector to Have Been Normalized, If Zero Not Allocated Memory)
 */
.globl mtx32_normalize
mtx32_normalize:
	/* Auto (Local) Variables, but just Aliases */
	vector        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	number_vec    .req r1 @ Parameter, Register for Argument, Scratch Register
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
	vector1    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	vector2    .req r1 @ Parameter, Register for Argument, Scratch Register
	number_vec .req r2 @ Parameter, Register for Argument, Scratch Register
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
 * r1: Vector1, Must Be Three of Vector Size
 * r1: Vector2, Must Be Three of Vector Size
 *
 * Return: r0 (Vector to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_crossproduct
mtx32_crossproduct:
	/* Auto (Local) Variables, but just Aliases */
	vector1       .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	vector2       .req r1 @ Parameter, Register for Argument, Scratch Register
	number_vec    .req r2 @ Parameter, Register for Argument, Scratch Register
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
 * r1: Vector, Must Be Three of Vector Size, X, Y, and Z
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_translate3d
mtx32_translate3d:
	/* Auto (Local) Variables, but just Aliases */
	vector        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
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
 * r1: Vector, Must Be Three of Vector Size, X, Y, and Z
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_scale3d
mtx32_scale3d:
	/* Auto (Local) Variables, but just Aliases */
	vector        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
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
 * r1: Value of Degrees, Must Be Single Precision Float
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_rotatex3d
mtx32_rotatex3d:
	/* Auto (Local) Variables, but just Aliases */
	degree        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
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
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Rotate X
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r1: Value of Degrees, Must Be Single Precision Float
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_rotatey3d
mtx32_rotatey3d:
	/* Auto (Local) Variables, but just Aliases */
	degree        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
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
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Rotate X
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Parameters
 * r1: Value of Degrees, Must Be Single Precision Float
 *
 * Return: r0 (4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory)
 */
.globl mtx32_rotatez3d
mtx32_rotatez3d:
	/* Auto (Local) Variables, but just Aliases */
	degree        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
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

