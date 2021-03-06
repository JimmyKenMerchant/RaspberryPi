/**
 * fft32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function fft32_fft
 * Fast Fourier Transform (FFT), No Changing Order in Each Array with Reversing Bits, No Coefficient (1/N)
 * This function uses iteration of N=2 discrete Fourier transform (DFT), it's one of Cooley-Turkey algorithm.
 * The iteration uses "offset" as the start point of N=2 DFT, and "stride" to take the second value.
 * "stride" will be decreased through looping, e.g., if the length of Samples is 16, "stride" will be decreased like 8, 4, 2, 1.
 * "offset" is used for calculating all pairs.
 * Iteration of N=4 DFT is a modern method. In case, N=8 DFT may be implemented in a system.
 * However, N=2 DFT is good for understanding of the algorithm, maintenance of codes, and flexible length of samples like 32, 128, 512, 2048, 8192.
 * And RasPi has a CPU to execute codes with branch prediction and memory cache, which increase the performance of this algorithm.
 * This function uses sine/cosine tables to pick values in the loop, these tables reduece the time for calculating sine/cosine values.
 * Cooley-Turkey algorithm reduces the time for calculating DFT.
 * The total number of turns becomes N * log2(N). Normal DFT needs N^2.
 *
 * Parameters
 * r0: Array of Samples to Be Transformed (Real Part)
 * r1: Array of Samples to Be Transformed (Imaginary Part)
 * r2: Logarithm to Base 2 of Length of Samples, Length of Samples Must Be Power of 2
 * r3: 2D Array of Unit Circle Tables of Sine Values, Maximum Length of Units in Table Needs to Be Same as Length of Samples, Minimum Length Needs to Be 2
 * r4: 2D Array of Unit Circle Tables of Cosine Values, Maximum Length of Units in Table Needs to Be Same as Length of Samples, Minimum Length Needs to Be 2
 *
 * Return: r0 (0 as success)
 */
.globl fft32_fft
fft32_fft:
	/* Auto (Local) Variables, but just Aliases */
	arr_sample_real .req r0
	arr_sample_imag .req r1
	log_sample      .req r2
	tables_sin      .req r3
	tables_cos      .req r4
	i               .req r5
	j               .req r6
	k               .req r7
	temp            .req r8
	temp2           .req r9
	stride          .req r10
	limit_j         .req r11

	/* VFP Registers */
	vfp_in1_real    .req s0 @ Real Number
	vfp_in1_imag    .req s1 @ Imaginary Number
	vfp_in2_real    .req s2
	vfp_in2_imag    .req s3
	vfp_cal1_real   .req s4
	vfp_cal1_imag   .req s5
	vfp_cal2_real   .req s6
	vfp_cal2_imag   .req s7
	vfp_one         .req s8
	vfp_zero        .req s9

	push {r4-r11,lr}

	add sp, sp, #36         @ r4-r11 offset 32 bytes
	pop {tables_cos}        @ Get Fifth Arguments
	sub sp, sp, #40         @ Retrieve SP

	vpush {s0-s9}

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	mov temp, #0
	vmov vfp_zero, temp

	mov i, #1
	fft32_fft_loop_i:
		cmp i, log_sample
		bhi fft32_fft_common

		/* Calculate Stride, 2^(log_sample - i), Algorithm Uses N=2 DFT */

		subs temp, log_sample, i
		moveq stride, #1              @ On 2^0
		beq fft32_fft_loop_prej

		mov temp2, #2
		mov stride, #2

		fft32_fft_loop_stride:
			subs temp, temp, #1
			mulhi stride, stride, temp2
			bhi fft32_fft_loop_stride

		fft32_fft_loop_prej:
			mov j, #0

			/* Calculate Limit of j, 2^(i - 1) - 1, Algorithm Uses N=2 DFT */

			subs temp, i, #1
			moveq limit_j, #0         @ On 2^0 - 1
			beq fft32_fft_loop_j

			mov temp2, #2
			mov limit_j, #2

			fft32_fft_loop_prej_loop:
				subs temp, temp, #1
				mulhi limit_j, limit_j, temp2
				bhi fft32_fft_loop_prej_loop

			sub limit_j, limit_j, #1

		fft32_fft_loop_j:
			cmp j, limit_j
			addhi i, i, #1
			bhi fft32_fft_loop_i

			.unreq temp
			.unreq temp2
			pre_offset .req r8
			offset     .req r9

			/* Make Pre-offset */
			mul pre_offset, j, stride
			lsl pre_offset, pre_offset, #1         @ Multiply by 2, Algorithm Uses N=2 DFT

			mov k, #0
			fft32_fft_loop_k:
				cmp k, stride
				addhs j, j, #1                         @ Until Prior to Number of Stride
				bhs fft32_fft_loop_j

				/* Make Offset */
				add offset, pre_offset, k

				/* In of First Value, n=1 for N=2 DCT */
				lsl ip, offset, #2                     @ Multiply by 4
				add ip, arr_sample_real, ip
				vldr vfp_in1_real, [ip]
				lsl ip, offset, #2                     @ Multiply by 4
				add ip, arr_sample_imag, ip
				vldr vfp_in1_imag, [ip]

				/* In of Second Value, n=2 for N=2 DCT */
				add offset, offset, stride
				lsl ip, offset, #2                     @ Multiply by 4
				add ip, arr_sample_real, ip
				vldr vfp_in2_real, [ip]
				lsl ip, offset, #2                     @ Multiply by 4
				add ip, arr_sample_imag, ip
				vldr vfp_in2_imag, [ip]
				sub offset, offset, stride

				/* Just N=2 DFT of First and Second Values to Get Coefficients in This Turn, Inner Product of {(W0/2, W0/2),(W0/2, W1/2)}{In1, In2} */
				vadd.f32 vfp_cal1_real, vfp_in1_real, vfp_in2_real @ Real of c0
				vadd.f32 vfp_cal1_imag, vfp_in1_imag, vfp_in2_imag @ Imaginary of c0
				vsub.f32 vfp_cal2_real, vfp_in1_real, vfp_in2_real @ Real of c1
				vsub.f32 vfp_cal2_imag, vfp_in1_imag, vfp_in2_imag @ Imaginary of c1

				.unreq vfp_in1_real
				.unreq vfp_in1_imag
				.unreq vfp_in2_real
				.unreq vfp_in2_imag
				vfp_sin   .req s0
				vfp_cos   .req s1
				vfp_cal3  .req s2
				vfp_cal4  .req s3

				/**
				 * c * (e^-i*theta), c is a complex number
				 * = c * (cos(theta) - sin(theta)i)
				 * Assign c as a + bi, i is an imaginary unit.
				 * (a + bi) * (cos(theta) - sin(theta)i)
				 * = (a * cos(theta) - b * -sin(theta)) + (a * -sin(theta) + b * cos(theta))i
				 * = (a * cos(theta) + b * sin(theta)) + (b * cos(theta) - a * sin(theta))i
				 * Where e is Euler's number.
				 */

				/* c0 * (e^-i*theta), theta is 0 */

				/* Real Number */
				vmul.f32 vfp_cal3, vfp_cal1_real, vfp_one       @ cos(0)
				vmul.f32 vfp_cal4, vfp_cal1_imag, vfp_zero      @ sin(0)
				vadd.f32 vfp_cal3, vfp_cal3, vfp_cal4
				lsl ip, offset, #2                              @ Multiply by 4
				add ip, arr_sample_real, ip
				vstr vfp_cal3, [ip]                             @ Put Back on Place for First Value

				/* Imaginary Number */
				vmul.f32 vfp_cal3, vfp_cal1_imag, vfp_one       @ cos(0)
				vmul.f32 vfp_cal4, vfp_cal1_real, vfp_zero      @ sin(0)
				vsub.f32 vfp_cal3, vfp_cal3, vfp_cal4
				lsl ip, offset, #2                              @ Multiply by 4
				add ip, arr_sample_imag, ip
				vstr vfp_cal3, [ip]                             @ Put Back on Place for First Value

				/* c1 * (e^-i*theta), theta is (2 * pi * offset)/(stride * 2) */

				push {offset}                                   @ Temporarily Save Value to Stack

				lsl ip, stride, #1                              @ Length of Sin/Cosine Table, Multiply by 2, Algorithm Uses N=2 DFT
				sub ip, ip, #1                                  @ Make Mask from Length of Sine/Cosine Table
				and offset, offset, ip                          @ Mask to Know Modulo, Remainder of Offset by Length of Units in Cosine/Sine Table (stride * 2)
				lsl offset, offset, #2                          @ Multiply by 4

				sub ip, i, #1
				lsl ip, ip, #2                                  @ Multiply by 4
				ldr ip, [tables_cos, ip]                        @ Select One of Cosine Tables

				add ip, ip, offset
				vldr vfp_cos, [ip]                              @ Offset * 1

				sub ip, i, #1
				lsl ip, ip, #2                                  @ Multiply by 4
				ldr ip, [tables_sin, ip]                        @ Select One of Sine Tables
				add ip, ip, offset
				vldr vfp_sin, [ip]                              @ Offset * 1

				pop {offset}                                    @ Retrieve Value from Stack

				add offset, offset, stride

				/* Real Number */
				vmul.f32 vfp_cal3, vfp_cal2_real, vfp_cos
				vmul.f32 vfp_cal4, vfp_cal2_imag, vfp_sin
				vadd.f32 vfp_cal3, vfp_cal3, vfp_cal4
				lsl ip, offset, #2                              @ Multiply by 4
				add ip, arr_sample_real, ip
				vstr vfp_cal3, [ip]                             @ Put Back on Place for Second Value

				/* Imaginary Number */
				vmul.f32 vfp_cal3, vfp_cal2_imag, vfp_cos
				vmul.f32 vfp_cal4, vfp_cal2_real, vfp_sin
				vsub.f32 vfp_cal3, vfp_cal3, vfp_cal4
				lsl ip, offset, #2                              @ Multiply by 4
				add ip, arr_sample_imag, ip
				vstr vfp_cal3, [ip]                             @ Put Back on Place for Second Value

				/**
				 * For example, if N=4 DCT, the third value needs to pick cosine/sine value from ("offset" * 2) of each table.
				 * and the fourth value needs to pick cosine/sine value from ("offset" * 3) of each table.
				 * The length of tables to pick values is ("stride" * 4). Multiple of 4 is used because of N=4 DFT.
				 * I.e., W("offset" * 0)/("stride" * 4), W("offset" * 1)/("stride" * 4), W("offset" * 2)/("stride" * 4), W("offset" * 3)/("stride" * 4).
				 * The value of ("offset" * x) exceeds the value of ("stride" * 4) in several cases,
				 * so we need to calculate ("offset" * x) mod ("stride" * 4).
				 * These processes equal calculations of cosine/sine values of (2 * Pi * "offset" * x) / ("stride" * 4).
				 */

				add k, k, #1
				b fft32_fft_loop_k

	fft32_fft_common:
		mov r0, #0
		vpop {s0-s9}
		pop {r4-r11,pc}

.unreq arr_sample_real
.unreq arr_sample_imag
.unreq log_sample
.unreq tables_sin
.unreq tables_cos
.unreq i
.unreq j
.unreq k
.unreq pre_offset
.unreq offset
.unreq stride
.unreq limit_j
.unreq vfp_sin
.unreq vfp_cos
.unreq vfp_cal3
.unreq vfp_cal4
.unreq vfp_cal1_real
.unreq vfp_cal1_imag
.unreq vfp_cal2_real
.unreq vfp_cal2_imag
.unreq vfp_one
.unreq vfp_zero


/**
 * function fft32_ifft
 * Inverse Fast Fourier Transform (IFFT), No Changing Order in Each Array with Reversing Bits, No Coefficient (1/N)
 * This function uses iteration of N=2 discrete Fourier transform (DFT), it's one of Cooley-Turkey algorithm.
 *
 * Parameters
 * r0: Array of Samples to Be Transformed (Real Part)
 * r1: Array of Samples to Be Transformed (Imaginary Part)
 * r2: Logarithm to Base 2 of Length of Samples, Length of Samples Must Be Power of 2
 * r3: 2D Array of Unit Circle Tables of Sine Values, Maximum Length of Units in Table Needs to Be Same as Length of Samples, Minimum Length Needs to Be 2
 * r4: 2D Array of Unit Circle Tables of Cosine Values, Maximum Length of Units in Table Needs to Be Same as Length of Samples, Minimum Length Needs to Be 2
 *
 * Return: r0 (0 as success)
 */
.globl fft32_ifft
fft32_ifft:
	/* Auto (Local) Variables, but just Aliases */
	arr_sample_real .req r0
	arr_sample_imag .req r1
	log_sample      .req r2
	tables_sin      .req r3
	tables_cos      .req r4
	i               .req r5
	j               .req r6
	k               .req r7
	temp            .req r8
	temp2           .req r9
	stride          .req r10
	limit_j         .req r11

	/* VFP Registers */
	vfp_in1_real    .req s0 @ Real Number
	vfp_in1_imag    .req s1 @ Imaginary Number
	vfp_in2_real    .req s2
	vfp_in2_imag    .req s3
	vfp_cal1_real   .req s4
	vfp_cal1_imag   .req s5
	vfp_cal2_real   .req s6
	vfp_cal2_imag   .req s7
	vfp_one         .req s8
	vfp_zero        .req s9

	push {r4-r11,lr}

	add sp, sp, #36         @ r4-r11 offset 32 bytes
	pop {tables_cos}        @ Get Fifth Arguments
	sub sp, sp, #40         @ Retrieve SP

	vpush {s0-s9}

	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	mov temp, #0
	vmov vfp_zero, temp

	mov i, #1
	fft32_ifft_loop_i:
		cmp i, log_sample
		bhi fft32_ifft_common

		/* Calculate Stride, 2^(log_sample - i), Algorithm Uses N=2 DFT */

		subs temp, log_sample, i
		moveq stride, #1              @ On 2^0
		beq fft32_ifft_loop_prej

		mov temp2, #2
		mov stride, #2

		fft32_ifft_loop_stride:
			subs temp, temp, #1
			mulhi stride, stride, temp2
			bhi fft32_ifft_loop_stride

		fft32_ifft_loop_prej:
			mov j, #0

			/* Calculate Limit of j, 2^(i - 1) - 1, Algorithm Uses N=2 DFT */

			subs temp, i, #1
			moveq limit_j, #0         @ On 2^0 - 1
			beq fft32_ifft_loop_j

			mov temp2, #2
			mov limit_j, #2

			fft32_ifft_loop_prej_loop:
				subs temp, temp, #1
				mulhi limit_j, limit_j, temp2
				bhi fft32_ifft_loop_prej_loop

			sub limit_j, limit_j, #1

		fft32_ifft_loop_j:
			cmp j, limit_j
			addhi i, i, #1
			bhi fft32_ifft_loop_i

			.unreq temp
			.unreq temp2
			pre_offset .req r8
			offset     .req r9

			/* Make Pre-offset */
			mul pre_offset, j, stride
			lsl pre_offset, pre_offset, #1         @ Multiply by 2, Algorithm Uses N=2 DFT

			mov k, #0
			fft32_ifft_loop_k:
				cmp k, stride
				addhs j, j, #1                         @ Until Prior to Number of Stride
				bhs fft32_ifft_loop_j

				/* Make Offset */
				add offset, pre_offset, k

				/* In of First Value, n=1 of N=2 DCT */
				lsl ip, offset, #2                     @ Multiply by 4
				add ip, arr_sample_real, ip
				vldr vfp_in1_real, [ip]
				lsl ip, offset, #2                     @ Multiply by 4
				add ip, arr_sample_imag, ip
				vldr vfp_in1_imag, [ip]

				/* In of Second Value, n=2 of N=2 DCT */
				add offset, offset, stride
				lsl ip, offset, #2                     @ Multiply by 4
				add ip, arr_sample_real, ip
				vldr vfp_in2_real, [ip]
				lsl ip, offset, #2                     @ Multiply by 4
				add ip, arr_sample_imag, ip
				vldr vfp_in2_imag, [ip]
				sub offset, offset, stride

				/* Just N=2 DFT of First and Second Values to Get Coefficients in This Turn, Inner Product of {(W0/2, W0/2),(W0/2, W1/2)}{In1, In2} */
				vadd.f32 vfp_cal1_real, vfp_in1_real, vfp_in2_real @ Real of c0
				vadd.f32 vfp_cal1_imag, vfp_in1_imag, vfp_in2_imag @ Imaginary of c0
				vsub.f32 vfp_cal2_real, vfp_in1_real, vfp_in2_real @ Real of c1
				vsub.f32 vfp_cal2_imag, vfp_in1_imag, vfp_in2_imag @ Imaginary of c1

				.unreq vfp_in1_real
				.unreq vfp_in1_imag
				.unreq vfp_in2_real
				.unreq vfp_in2_imag
				vfp_sin   .req s0
				vfp_cos   .req s1
				vfp_cal3  .req s2
				vfp_cal4  .req s3

				/**
				 * c * (e^i*theta), c is a complex number
				 * = c * (cos(theta) + sin(theta)i)
				 * Assign c as a + bi, i is an imaginary unit.
				 * (a + bi) * (cos(theta) + sin(theta)i)
				 * = (a * cos(theta) - b * sin(theta)) + (a * sin(theta) + b * cos(theta))i
				 * Where e is Euler's number.
				 */

				/* c0 * (e^i*theta), theta is 0 */

				/* Real Number */
				vmul.f32 vfp_cal3, vfp_cal1_real, vfp_one       @ cos(0)
				vmul.f32 vfp_cal4, vfp_cal1_imag, vfp_zero      @ sin(0)
				vsub.f32 vfp_cal3, vfp_cal3, vfp_cal4
				lsl ip, offset, #2                              @ Multiply by 4
				add ip, arr_sample_real, ip
				vstr vfp_cal3, [ip]                             @ Put Back on Place for First Value

				/* Imaginary Number */
				vmul.f32 vfp_cal3, vfp_cal1_imag, vfp_one       @ cos(0)
				vmul.f32 vfp_cal4, vfp_cal1_real, vfp_zero      @ sin(0)
				vadd.f32 vfp_cal3, vfp_cal3, vfp_cal4
				lsl ip, offset, #2                              @ Multiply by 4
				add ip, arr_sample_imag, ip
				vstr vfp_cal3, [ip]                             @ Put Back on Place for First Value

				/* c1 * (e^i*theta), theta is (2 * pi * offset)/(stride * 2) */

				push {offset}                                   @ Temporarily Save Value to Stack

				lsl ip, stride, #1                              @ Length of Sin/Cosine Table, Multiply by 2, Algorithm Uses N=2 DFT
				sub ip, ip, #1                                  @ Make Mask from Length of Sine/Cosine Table
				and offset, offset, ip                          @ Mask to Know Modulo, Remainder of Offset by Length of Units in Cosine/Sine Table (stride * 2)
				lsl offset, offset, #2                          @ Multiply by 4

				sub ip, i, #1
				lsl ip, ip, #2                                  @ Multiply by 4
				ldr ip, [tables_cos, ip]                        @ Select One of Cosine Tables

				add ip, ip, offset
				vldr vfp_cos, [ip]                              @ Offset * 1

				sub ip, i, #1
				lsl ip, ip, #2                                  @ Multiply by 4
				ldr ip, [tables_sin, ip]                        @ Select One of Sine Tables
				add ip, ip, offset
				vldr vfp_sin, [ip]                              @ Offset * 1

				pop {offset}                                    @ Retrieve Value from Stack

				add offset, offset, stride

				/* Real Number */
				vmul.f32 vfp_cal3, vfp_cal2_real, vfp_cos
				vmul.f32 vfp_cal4, vfp_cal2_imag, vfp_sin
				vsub.f32 vfp_cal3, vfp_cal3, vfp_cal4
				lsl ip, offset, #2                              @ Multiply by 4
				add ip, arr_sample_real, ip
				vstr vfp_cal3, [ip]                             @ Put Back on Place for Second Value

				/* Imaginary Number */
				vmul.f32 vfp_cal3, vfp_cal2_imag, vfp_cos
				vmul.f32 vfp_cal4, vfp_cal2_real, vfp_sin
				vadd.f32 vfp_cal3, vfp_cal3, vfp_cal4
				lsl ip, offset, #2                              @ Multiply by 4
				add ip, arr_sample_imag, ip
				vstr vfp_cal3, [ip]                             @ Put Back on Place for Second Value

				add k, k, #1
				b fft32_ifft_loop_k

	fft32_ifft_common:
		mov r0, #0
		vpop {s0-s9}
		pop {r4-r11,pc}

.unreq arr_sample_real
.unreq arr_sample_imag
.unreq log_sample
.unreq tables_sin
.unreq tables_cos
.unreq i
.unreq j
.unreq k
.unreq pre_offset
.unreq offset
.unreq stride
.unreq limit_j
.unreq vfp_sin
.unreq vfp_cos
.unreq vfp_cal3
.unreq vfp_cal4
.unreq vfp_cal1_real
.unreq vfp_cal1_imag
.unreq vfp_cal2_real
.unreq vfp_cal2_imag
.unreq vfp_one
.unreq vfp_zero


/**
 * function fft32_change_order
 * Change Order of Samples with Reversing Bits
 *
 * Parameters
 * r0: Array of Samples (Real/Imaginary Part) to Be Transformed
 * r0: Length of Samples, Must Be Power of 2
 *
 * Return: r0 (0 as success)
 */
.globl fft32_change_order
fft32_change_order:
	/* Auto (Local) Variables, but just Aliases */
	arr_sample  .req r0
	length      .req r1
	i           .req r2
	j           .req r3
	limit_j     .req r4
	mask        .req r5
	num_reverse .req r6
	swap1       .req r7
	swap2       .req r8
	one         .req r9

	push {r4-r9,lr}

	mov i, #30
	clz limit_j, length                   @ Count Leading Zeros to Know Place of Top Bit from MSB
	sub limit_j, i, limit_j               @ Length of Effective Bits

	mov one, #1

	mov i, #1
	fft32_change_order_loop:
		cmp i, length
		bhs fft32_change_order_common

		mov mask, #1
		lsl mask, mask, limit_j

		mov num_reverse, #0
		mov j, #0
		fft32_change_order_loop_reversebits:
			cmp j, limit_j
			bhi fft32_change_order_swap

			tst i, mask
			orrne num_reverse, one, lsl j

			lsr mask, mask, #1
			add j, j, #1
			b fft32_change_order_loop_reversebits

		fft32_change_order_swap:
			cmp i, num_reverse
			addhs i, i, #1
			bhs fft32_change_order_loop

			ldr swap1, [arr_sample, i, lsl #2]           @ Multiply by 4
			ldr swap2, [arr_sample, num_reverse, lsl #2] @ Multiply by 4
			str swap2, [arr_sample, i, lsl #2]           @ Multiply by 4
			str swap1, [arr_sample, num_reverse, lsl #2] @ Multiply by 4
			add i, i, #1
			b fft32_change_order_loop

	fft32_change_order_common:
		mov r0, #0
		pop {r4-r9,pc}

.unreq arr_sample
.unreq length
.unreq i
.unreq j
.unreq limit_j
.unreq mask
.unreq num_reverse
.unreq swap1
.unreq swap2
.unreq one


/**
 * function fft32_coefficient
 * Multiply Coefficient 1/N to Samples
 *
 * Parameters
 * r0: Array of Samples (Real/Imaginary Part) to Be Transformed
 * r1: Length of Samples
 *
 * Return: r0 (0 as success)
 */
.globl fft32_coefficient
fft32_coefficient:
	/* Auto (Local) Variables, but just Aliases */
	arr_sample   .req r0
	length       .req r1
	i            .req r2

	/* VFP Registers */
	vfp_dividend .req s0
	vfp_divisor  .req s1

	push {lr}
	vpush {s0-s1}

	vmov vfp_divisor, length
	vcvt.f32.u32 vfp_divisor, vfp_divisor

	mov i, #0
	fft32_coefficient_loop:
		cmp i, length
		bhs fft32_coefficient_common

		vldr vfp_dividend, [arr_sample]
		vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor
		vstr vfp_dividend, [arr_sample]

		add arr_sample, arr_sample, #4
		add i, i, #1
		b fft32_coefficient_loop

	fft32_coefficient_common:
		mov r0, #0
		vpop {s0-s1}
		pop {pc}

.unreq arr_sample
.unreq length
.unreq i
.unreq vfp_dividend
.unreq vfp_divisor


/**
 * function fft32_powerspectrum
 * Make Power Spectrum from Frequency Spectrum, Returns Result in Array of Samples (Real Part)
 *
 * Parameters
 * r0: Array of Samples (Real Part)
 * r1: Array of Samples (Imaginary Part)
 * r2: Length of Samples
 *
 * Return: r0 (0 as success)
 */
.globl fft32_powerspectrum
fft32_powerspectrum:
	/* Auto (Local) Variables, but just Aliases */
	arr_sample_real .req r0
	arr_sample_imag .req r1
	length          .req r2
	i               .req r3

	/* VFP Registers */
	vfp_value_real  .req s0
	vfp_value_imag  .req s1

	push {lr}
	vpush {s0-s1}

	mov i, #0
	fft32_powerspectrum_loop:
		cmp i, length
		bhs fft32_powerspectrum_common

		/**
		 * Power Spectrum |F(x)|^2 = F(x) * Conjugate of F(x) = a^2 + b^2
		 * F(x) = a + bi (i is the imaginary unit)
		 * Conjugate of F(x) = a - bi
		 * (a + bi)(a - bi) = a^2 - abi + bia - bi^2 = a^2 - (b^2)(i^2) = a^2 - (b^2)(-1) = a^2 - -(b^2) = a^2 + b^2
		 */

		vldr vfp_value_real, [arr_sample_real]
		vmul.f32 vfp_value_real, vfp_value_real, vfp_value_real
		vldr vfp_value_imag, [arr_sample_imag]
		vmul.f32 vfp_value_imag, vfp_value_imag, vfp_value_imag
		vadd.f32 vfp_value_real, vfp_value_real, vfp_value_imag
		vstr vfp_value_real, [arr_sample_real]

		add arr_sample_real, arr_sample_real, #4
		add arr_sample_imag, arr_sample_imag, #4
		add i, i, #1
		b fft32_powerspectrum_loop

	fft32_powerspectrum_common:
		mov r0, #0
		vpop {s0-s1}
		pop {pc}

.unreq arr_sample_real
.unreq arr_sample_imag
.unreq length
.unreq i
.unreq vfp_value_real
.unreq vfp_value_imag


/**
 * function fft32_index_highest
 * Get Index of Highest Value in Samples
 *
 * Parameters
 * r0: Array of Samples (Real/Imaginary Part)
 * r1: Length of Samples
 *
 * Return: r0 (Index of Highest Value, Index is 0 to Length - 1)
 */
.globl fft32_index_highest
fft32_index_highest:
	/* Auto (Local) Variables, but just Aliases */
	arr_sample  .req r0
	length      .req r1
	i           .req r2
	i_highest   .req r3

	/* VFP Registers */
	vfp_value   .req s0
	vfp_highest .req s1

	push {lr}
	vpush {s0-s1}

	mov i_highest, #0
	vmov vfp_highest, i_highest         @ Hard Code of Float 0.0

	mov i, #0
	fft32_index_highest_loop:
		cmp i, length
		bhs fft32_index_highest_common

		vldr vfp_value, [arr_sample]
		vcmp.f32 vfp_value, vfp_highest
		vmrs apsr_nzcv, fpscr               @ Transfer FPSCR Flags to CPSR's NZCV Flags (APSR)
		movgt i_highest, i
		vmovgt vfp_highest, vfp_value

		add arr_sample, arr_sample, #4
		add i, i, #1
		b fft32_index_highest_loop

	fft32_index_highest_common:
		mov r0, i_highest
		vpop {s0-s1}
		pop {pc}

.unreq arr_sample
.unreq length
.unreq i
.unreq i_highest
.unreq vfp_value
.unreq vfp_highest


/**
 * function fft32_window_han
 * Han (Hanning) Window
 *
 * Parameters
 * r0: Array of Samples (Real/Imaginary Part)
 * r1: Length of Samples
 * r2: Unit Circle Table of Cosine Values, Length Is Same as Length of Samples
 *
 * Return: r0 (0 as success)
 */
.globl fft32_window_han
fft32_window_han:
	/* Auto (Local) Variables, but just Aliases */
	arr_sample .req r0
	length     .req r1
	table_cos  .req r2
	i          .req r3

	/* VFP Registers */
	vfp_cos    .req s0
	vfp_value  .req s1
	vfp_half   .req s2

	push {lr}
	vpush {s0-s2}

	/* Hard Code of Single Precision Float 0.5 */
	mov i, #0x3F000000
	vmov vfp_half, i

	mov i, #0
	fft32_window_han_loop:
		cmp i, length
		bhs fft32_window_han_common

		/**
		 * f(n) * (0.5 - (0.5 * (cos(2 * pi * n / N))))
		 * 0 <= n <= N - 1
		 */
		vldr vfp_cos, [table_cos]
		vmul.f32 vfp_cos, vfp_cos, vfp_half
		vsub.f32 vfp_cos, vfp_half, vfp_cos

		vldr vfp_value, [arr_sample]
		vmul.f32 vfp_value, vfp_value, vfp_cos
		vstr vfp_value, [arr_sample]

		add arr_sample, arr_sample, #4
		add table_cos, table_cos, #4
		add i, i, #1
		b fft32_window_han_loop

	fft32_window_han_common:
		mov r0, #0
		vpop {s0-s2}
		pop {pc}

.unreq arr_sample
.unreq length
.unreq table_cos
.unreq i
.unreq vfp_cos
.unreq vfp_value
.unreq vfp_half


/**
 * function fft32_window_hamming
 * Hamming Window
 *
 * Parameters
 * r0: Array of Samples (Real/Imaginary Part)
 * r1: Length of Samples
 * r2: Unit Circle Table of Cosine Values, Length Is Same as Length of Samples
 *
 * Return: r0 (0 as success)
 */
.globl fft32_window_hamming
fft32_window_hamming:
	/* Auto (Local) Variables, but just Aliases */
	arr_sample .req r0
	length     .req r1
	table_cos  .req r2
	i          .req r3

	/* VFP Registers */
	vfp_cos    .req s0
	vfp_value  .req s1
	vfp_a0     .req s2
	vfp_a1     .req s3

	push {lr}
	vpush {s0-s3}

	/* Hard Code of Single Precision Float 0.54 */
	ldr i, fft32_window_hamming_a0
	vmov vfp_a0, i

	/* Hard Code of Single Precision Float 0.46 */
	ldr i, fft32_window_hamming_a1
	vmov vfp_a1, i

	mov i, #0
	fft32_window_hamming_loop:
		cmp i, length
		bhs fft32_window_hamming_common

		/**
		 * f(n) * (0.54 - (0.46 * (cos(2 * pi * n / N))))
		 * 0 <= n <= N - 1
		 */
		vldr vfp_cos, [table_cos]
		vmul.f32 vfp_cos, vfp_cos, vfp_a1
		vsub.f32 vfp_cos, vfp_a0, vfp_cos

		vldr vfp_value, [arr_sample]
		vmul.f32 vfp_value, vfp_value, vfp_cos
		vstr vfp_value, [arr_sample]

		add arr_sample, arr_sample, #4
		add table_cos, table_cos, #4
		add i, i, #1
		b fft32_window_hamming_loop

	fft32_window_hamming_common:
		mov r0, #0
		vpop {s0-s3}
		pop {pc}

.unreq arr_sample
.unreq length
.unreq table_cos
.unreq i
.unreq vfp_cos
.unreq vfp_value
.unreq vfp_a0
.unreq vfp_a1

fft32_window_hamming_a0: .word 0x3F0A3D71 @ Float 0.54
fft32_window_hamming_a1: .word 0x3EEB851F @ Float 0.46


/**
 * function fft32_make_table
 * Make A Unit Circle Table of Sine/Cosine Values
 *
 * Parameters
 * r0: Number of Divisor in Unit Circle Table
 * r1: Length of Units in Unit Circle Table
 * r2: 0 as Sine, 1 as Cosine
 *
 * Return: r0 (Array of Single Precision Float, If Zero Not Allocated Memory)
 */
.globl fft32_make_table
fft32_make_table:
	/* Auto (Local) Variables, but just Aliases */
	num_divisor   .req r0
	length        .req r1
	flag_cos      .req r2
	arr_float     .req r3
	temp          .req r4

	/* VFP Registers */
	vfp_pi_double .req s0
	vfp_divisor   .req s1
	vfp_dividend  .req s2

	push {r4,lr}
	vpush {s0-s2}

	push {r0-r2}
	mov r0, length
	bl heap32_malloc
	mov arr_float, r0
	pop {r0-r2}

	cmp arr_float, #0
	beq fft32_make_table_common

	vmov vfp_divisor, num_divisor
	vcvt.f32.u32 vfp_divisor, vfp_divisor

	.unreq num_divisor
	i .req r0

	ldr i, FFT32_MATH32_PI_DOUBLE
	vldr vfp_pi_double, [i]

	mov i, #0

	fft32_make_table_loop:
		cmp i, length
		bge fft32_make_table_common

		vmov vfp_dividend, i
		vcvt.f32.u32 vfp_dividend, vfp_dividend

		vmul.f32 vfp_dividend, vfp_dividend, vfp_pi_double
		vdiv.f32 vfp_dividend, vfp_dividend, vfp_divisor

		cmp flag_cos, #1
		bhs fft32_make_table_loop_cos

		push {r0-r3}
		vmov r0, vfp_dividend
		bl math32_sin
		mov temp, r0
		pop {r0-r3}

		b fft32_make_table_loop_common

		fft32_make_table_loop_cos:
			push {r0-r3}
			vmov r0, vfp_dividend
			bl math32_cos
			mov temp, r0
			pop {r0-r3}

		fft32_make_table_loop_common:
			str temp, [arr_float, i, lsl #2]                   @ Multiply by 4
			add i, i, #1
			b fft32_make_table_loop

	fft32_make_table_common:
		mov r0, arr_float
		vpop {s0-s2}
		pop {r4,pc}

.unreq i
.unreq length
.unreq flag_cos
.unreq arr_float
.unreq temp
.unreq vfp_pi_double
.unreq vfp_divisor
.unreq vfp_dividend


/**
 * function fft32_make_table2d
 * Make An Two Dimentional Array of Unit Circle Tables of Sine/Cosine Values
 * Length of units in a Table is a power of 2. Minimum length is 2.
 * Tables are in descending order on lengths.
 *
 * Parameters
 * r0: Maximum Length of Units in Unit Circle Table, Must Be Power of 2
 * r1: 0 as Sine, 1 as Cosine
 *
 * Return: r0 (Array of Single Precision Float, If Zero Not Allocated Memory)
 */
.globl fft32_make_table2d
fft32_make_table2d:
	/* Auto (Local) Variables, but just Aliases */
	max_len     .req r0
	i           .req r1
	flag_cos    .req r2
	arr2d_float .req r3
	temp        .req r4
	temp2       .req r5

	push {r4-r5,lr}

	mov flag_cos, i

	mov i, #0
	mov temp, max_len

	fft32_make_table2d_length:
		lsr temp, temp, #1                   @ Divide by 2
		cmp temp, #0
		addhi i, i, #1
		bhi fft32_make_table2d_length

	push {r0-r2}
	mov r0, i
	bl heap32_malloc
	mov arr2d_float, r0
	pop {r0-r2}

	cmp arr2d_float, #0
	beq fft32_make_table2d_common

	mov temp, i
	mov i, #0

	fft32_make_table2d_loop:
		cmp i, temp
		bhs fft32_make_table2d_common

		push {r0-r3}
		mov r1, max_len
		bl fft32_make_table
		mov temp2, r0
		pop {r0-r3}

		str temp2, [arr2d_float, i, lsl #2]  @ Multiply by 4

		add i, i, #1
		lsr max_len, max_len, #1             @ Divide by 2
		b fft32_make_table2d_loop

	fft32_make_table2d_common:
		mov r0, arr2d_float
		pop {r4-r5,pc}

.unreq max_len
.unreq i
.unreq flag_cos
.unreq arr2d_float
.unreq temp
.unreq temp2

FFT32_MATH32_PI_DOUBLE:  .word MATH32_PI_DOUBLE

