/**
 * stat32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function stat32_fttest
 * Return Student's t-test with Single Precision Float
 *
 * Parameters
 * r0: Mean of Population
 * r1: Mean of Sample = Observation
 * r2: Standard Deviation of Sample = Observation
 * r3: Length of Array (Size) for Sample = Observation
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl stat32_fttest
stat32_fttest:
	/* Auto (Local) Variables, but just Aliases */
	mean_population     .req r0
	mean_sample         .req r1
	sd_sample           .req r2
	size_sample         .req r3

	/* VFP Registers */
	vfp_mean_population .req s0
	vfp_mean_sample     .req s1
	vfp_se              .req s2

	/**
	 * t-test (t) = Mean of Sample - Mean of Population Divided by Standard Error Where Standard Deviation is Assumed by Sample
	 */
	push {lr}
	vpush {s0-s2}

	push {r0-r1}
	mov r0, sd_sample
	mov r1, size_sample
	bl stat32_fstandard_error
	mov sd_sample, r0
	pop {r0-r1}

	.unreq sd_sample
	se .req r2

	vmov vfp_mean_population, mean_population
	vmov vfp_mean_sample, mean_sample
	vmov vfp_se, se

	vsub.f32 vfp_mean_sample, vfp_mean_sample, vfp_mean_population

	.unreq vfp_mean_sample
	vfp_t .req s1

	vdiv.f32 vfp_t, vfp_t, vfp_se

	stat32_fttest_common:
		vmov r0, vfp_t
		vpop {s0-s2}
		pop {pc}

.unreq mean_population
.unreq mean_sample
.unreq se
.unreq size_sample
.unreq vfp_mean_population
.unreq vfp_t
.unreq vfp_se


/**
 * function stat32_fstandard_error
 * Return Standard Error with Single Precision Float
 *
 * Parameters
 * r0: Standard Deviation
 * r1: Length of Array
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl stat32_fstandard_error
stat32_fstandard_error:
	/* Auto (Local) Variables, but just Aliases */
	sd         .req r0
	length     .req r1

	/* VFP Registers */
	vfp_se     .req s0
	vfp_length .req s1

	/**
	 * Standard Error = Standard Deviation Divided by length(Size of Observation)^1/2
	 */
	push {lr}
	vpush {s0-s1}

	vmov vfp_se, sd
	vmov vfp_length, length
	vsqrt.f32 vfp_length, vfp_length
	vdiv.f32 vfp_se, vfp_se, vfp_length

	stat32_fstandard_error_common:
		vmov r0, vfp_se
		vpop {s0-s1}
		pop {pc}

.unreq sd
.unreq length
.unreq vfp_se
.unreq vfp_length


/**
 * function stat32_fcorrelation_pearson
 * Return Pearson Correlation Coefficient with Single Precision Float
 *
 * Parameters
 * r0: First Standard Deviation
 * r1: Second Standard Deviation
 * r2: Covariance of First and Second
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl stat32_fcorrelation_pearson
stat32_fcorrelation_pearson:
	/* Auto (Local) Variables, but just Aliases */
	sd1            .req r0
	sd2            .req r1
	covariance     .req r2

	/* VFP Registers */
	vfp_sd1        .req s0
	vfp_sd2        .req s1
	vfp_covariance .req s2
	vfp_rho        .req s3

	/**
	 * Correlation Coefficient (r or Greek Small Letter Rho) = Covariance Divided by (s1 * s2)
	 * This Formula uses Bessel's correction if Corrected.
	 */
	push {lr}
	vpush {s0-s3}

	vmov vfp_sd1, sd1
	vmov vfp_sd2, sd2
	vmov vfp_covariance, covariance
	vmul.f32 vfp_sd1, vfp_sd1, vfp_sd2
	vdiv.f32 vfp_rho, vfp_covariance, vfp_sd1

	stat32_fcorrelation_pearson_common:
		vmov r0, vfp_rho
		vpop {s0-s3}
		pop {pc}

.unreq sd1
.unreq sd2
.unreq covariance
.unreq vfp_sd1
.unreq vfp_sd2
.unreq vfp_covariance
.unreq vfp_rho


/**
 * function stat32_fcovariance
 * Return Covariance with Single Precision Float
 *
 * Parameters
 * r0: First Deviation Array of Single Precision Float in Heap
 * r1: Second Deviation Array of Single Precision Float in Heap
 * r2: length
 * r3: Bessel's Correction
 *
 * Return: r0 (Value by Single Precision Float, -1 by Integer as Error)
 */
.globl stat32_fcovariance
stat32_fcovariance:
	/* Auto (Local) Variables, but just Aliases */
	array_deviation1 .req r0
	array_deviation2 .req r1
	length           .req r2
	correction       .req r3
	i                .req r4
	temp             .req r5
	shift            .req r6
	shift2           .req r7

	/* VFP Registers */
	vfp_covariance   .req s0
	vfp_deviation1   .req s1
	vfp_deviation2   .req s2
	vfp_length       .req s3

	/**
	 * Covariance = (Sigma[i = 1 to n] Deviation1n * Deviation2n) Divided by n (Not Corrected) or n - 1 (Corrected)
	 * This Formula uses Bessel's correction if Corrected.
	 */
	push {r4-r7,lr}
	vpush {s0-s3}

	push {r0-r3}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r3}

	cmp temp, #-1
	vmoveq vfp_covariance, temp
	beq stat32_fcovariance_common

	lsr temp, temp, #2                       @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                       @ Prevent Overflow

	push {r0-r3}
	mov r0, array_deviation2
	bl heap32_mcount
	mov temp, r0
	pop {r0-r3}

	cmp temp, #-1
	vmoveq vfp_covariance, temp
	beq stat32_fcovariance_common

	lsr temp, temp, #2                       @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                       @ Prevent Overflow

	mov temp, #0
	vmov vfp_covariance, temp
	vcvt.f32.u32 vfp_covariance, vfp_covariance

	mov i, #0
	stat32_fcovariance_loop:
		lsl temp, i, #2                           @ Substitute of Multiplication by 4
		add shift, array_deviation1, temp         @ vldr/vstr Can't Offset by Value in ARM Register
		add shift2, array_deviation2, temp        @ vldr/vstr Can't Offset by Value in ARM Register
		vldr vfp_deviation1, [shift]
		vldr vfp_deviation2, [shift2]
		vmul.f32 vfp_deviation1, vfp_deviation1, vfp_deviation2
		vadd.f32 vfp_covariance, vfp_covariance, vfp_deviation1
		add i, i, #1
		cmp i, length
		blt stat32_fcovariance_loop

		cmp correction, #0
		subne length, length, #1
		vmov vfp_length, length
		vcvt.f32.u32 vfp_length, vfp_length
		vdiv.f32 vfp_covariance, vfp_covariance, vfp_length

	stat32_fcovariance_common:
		vmov r0, vfp_covariance
		vpop {s0-s3}
		pop {r4-r7,pc}

.unreq array_deviation1
.unreq array_deviation2
.unreq length
.unreq correction
.unreq i
.unreq temp
.unreq shift
.unreq shift2
.unreq vfp_covariance
.unreq vfp_deviation1
.unreq vfp_deviation2
.unreq vfp_length


/**
 * function stat32_fstandard_deviation
 * Return Standard Deviation with Single Precision Float
 *
 * Parameters
 * r0: Array of Single Precision Float in Heap
 * r1: Length of Array
 * r2: Bessel's Correction
 *
 * Return: r0 (Value by Single Precision Float, -1 by Integer as Error)
 */
.globl stat32_fstandard_deviation
stat32_fstandard_deviation:
	/* Auto (Local) Variables, but just Aliases */
	array_heap      .req r0
	length          .req r1
	correction      .req r2

	/* VFP Registers */
	vfp_sd          .req s0

	/**
	 * Standard Deviation (s or Greek Small Letter of Sigma) = Variance^1 Divided by 2 (Square Root of Variance)
	 */
	push {lr}
	vpush {s0}

	bl stat32_fvariance
	.unreq array_heap
	variance .req r0

	vmov vfp_sd, variance
	vsqrt.f32 vfp_sd, vfp_sd

	stat32_fstandard_deviation_common:
		vmov r0, vfp_sd
		vpop {s0}
		pop {pc}

.unreq variance
.unreq length
.unreq correction
.unreq vfp_sd


/**
 * function stat32_fvariance
 * Return Variance with Single Precision Float
 *
 * Parameters
 * r0: Array of Single Precision Float in Heap
 * r1: Length of Array
 * r2: Bessel's Correction
 *
 * Return: r0 (Value by Single Precision Float, -1 by Integer as Error)
 */
.globl stat32_fvariance
stat32_fvariance:
	/* Auto (Local) Variables, but just Aliases */
	array_heap      .req r0
	length          .req r1
	correction      .req r2
	average         .req r3
	i               .req r4
	array_heap_devi .req r5
	temp            .req r6

	/* VFP Registers */
	vfp_variance    .req s0
	vfp_length      .req s1
	vfp_temp        .req s2

	/**
	 * Variance = (Sigma[i = 1 to n] (Xn - Xmean)^2) Divided by n (Not Corrected) or n - 1 (Corrected)
	 * This Formula uses Bessel's correction if Corrected.
	 */
	push {r4-r6,lr}
	vpush {s0-s2}

	push {r0-r2}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r2}

	cmp temp, #-1
	vmoveq vfp_variance, temp
	beq stat32_fvariance_common

	lsr temp, temp, #2                       @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                       @ Prevent Overflow

	push {r0-r2}
	bl stat32_fmean
	mov average, r0
	pop {r0-r2}

	cmp average, #-1
	vmoveq vfp_variance, average 
	beq stat32_fvariance_common

	push {r0-r3}
	mov r2, average
	mov r3, #1
	bl stat32_fdeviation
	mov array_heap_devi, r0
	pop {r0-r3}

	cmp array_heap_devi, #0
	mvneq temp, #0
	vmoveq vfp_variance, temp
	beq stat32_fvariance_common

	mov temp, #0
	vmov vfp_variance, temp
	vcvt.f32.u32 vfp_variance, vfp_variance

	mov i, #0
	stat32_fvariance_loop:
		lsl temp, i, #2                           @ Substitute of Multiplication by 4
		add temp, array_heap_devi, temp           @ vldr/vstr Can't Offset by Value in ARM Register
		vldr vfp_temp, [temp]
		vmul.f32 vfp_temp, vfp_temp, vfp_temp
		vadd.f32 vfp_variance, vfp_variance, vfp_temp
		add i, i, #1
		cmp i, length
		blt stat32_fvariance_loop

		cmp correction, #0
		subne length, length, #1
		vmov vfp_length, length
		vcvt.f32.u32 vfp_length, vfp_length
		vdiv.f32 vfp_variance, vfp_variance, vfp_length

		mov r0, array_heap_devi
		bl heap32_mfree

	stat32_fvariance_common:
		vmov r0, vfp_variance
		vpop {s0-s2}
		pop {r4-r6,pc}

.unreq array_heap
.unreq length
.unreq correction
.unreq average
.unreq i
.unreq array_heap_devi
.unreq temp
.unreq vfp_variance
.unreq vfp_length
.unreq vfp_temp


/**
 * function stat32_fdeviation
 * Return Array of Deviation with Single Precision Float
 * Note that this function makes new memory space to be needed to make the memory free.
 *
 * Parameters
 * r0: Array of Single Precision Float in Heap
 * r1: Length of Array
 * r2: Average Value with Single Precision Float (Calculate Mean/Median/Mode)
 * r3: Unsigned = Absolute (0) or Signed (1)
 *
 * Return: r0 (Pointer of Ordered Array, If Zero Memory Allocation Failed)
 */
.globl stat32_fdeviation
stat32_fdeviation:
	/* Auto (Local) Variables, but just Aliases */
	array_heap      .req r0
	length          .req r1
	average         .req r2
	signed          .req r3
	array_heap_devi .req r4
	i               .req r5
	temp            .req r6
	shift           .req r7
	shift2          .req r8

	/* VFP Registers */
	vfp_temp        .req s0
	vfp_average     .req s1

	push {r4-r8,lr}
	vpush {s0-s1}

	push {r0-r3}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r3}

	cmp temp, #-1
	moveq array_heap_devi, #0
	beq stat32_fdeviation_common

	lsr temp, temp, #2                      @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                      @ Prevent Overflow

	push {r0-r3}
	mov r0, length
	bl heap32_malloc
	mov array_heap_devi, r0
	pop {r0-r3}

	cmp array_heap_devi, #0
	beq stat32_fdeviation_common

	vmov vfp_average, average

	mov i, #0

	stat32_fdeviation_loop:
		lsl temp, i, #2                            @ Substitute of Multiplication by 4
		add shift, array_heap, temp                @ vldr/vstr Can't Offset by Value in ARM Register
		add shift2, array_heap_devi, temp          @ vldr/vstr Can't Offset by Value in ARM Register
		vldr vfp_temp, [shift]
		vsub.f32 vfp_temp, vfp_temp, vfp_average
		cmp signed, #0
		vabseq.f32 vfp_temp, vfp_temp
		vstr vfp_temp, [shift2]

		add i, i, #1
		cmp i, length
		blt stat32_fdeviation_loop

	stat32_fdeviation_common:
		mov r0, array_heap_devi
		vpop {s0-s1}
		pop {r4-r8,pc}

.unreq array_heap
.unreq length
.unreq average
.unreq signed
.unreq array_heap_devi
.unreq i
.unreq temp
.unreq shift
.unreq shift2
.unreq vfp_temp
.unreq vfp_average


/**
 * function stat32_fmax
 * Return Maximum with Single Precision Float
 *
 * Parameters
 * r0: Array of Single Precision Float in Heap
 * r1: Length of Array
 *
 * Return: r0 (Value by Single Precision Float, -1 by Integer as Error)
 * Error(-1): No Heap Area
 */
.globl stat32_fmax
stat32_fmax:
	/* Auto (Local) Variables, but just Aliases */
	array_heap     .req r0
	length         .req r1
	temp           .req r2
	i              .req r3

	/* VFP Registers */
	vfp_max        .req s0
	vfp_temp       .req s1

	push {lr}
	vpush {s0-s1}

	push {r0-r1}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r1}

	cmp temp, #-1
	vmoveq vfp_max, temp
	beq stat32_fmax_common

	lsr temp, temp, #2                      @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                      @ Prevent Overflow

	cmp length, #0
	mvnle temp, #0
	vmovle vfp_max, temp
	ble stat32_fmax_common

	vldr vfp_max, [array_heap]

	mov i, #1
	stat32_fmax_loop:
		lsl temp, i, #2                         @ Substitute of Multiplication by 4
		add temp, array_heap, temp              @ vldr/vstr Can't Offset by Value in ARM Register
		vldr vfp_temp, [temp]
		vcmp.f32 vfp_temp, vfp_max
		vmrs apsr_nzcv, fpscr                   @ Transfer FPSCR Flags to CPSR's NZCV
		vmovgt vfp_max, vfp_temp
		add i, i, #1
		cmp i, length
		blt stat32_fmax_loop

	stat32_fmax_common:
		vmov r0, vfp_max
		vpop {s0-s1}
		pop {pc}

.unreq array_heap
.unreq length
.unreq temp
.unreq i
.unreq vfp_max
.unreq vfp_temp


/**
 * function stat32_fmin
 * Return Minimum with Single Precision Float
 *
 * Parameters
 * r0: Array of Single Precision Float in Heap
 * r1: Length of Array
 *
 * Return: r0 (Value by Single Precision Float, -1 by Integer as Error)
 * Error(-1): No Heap Area
 */
.globl stat32_fmin
stat32_fmin:
	/* Auto (Local) Variables, but just Aliases */
	array_heap     .req r0
	length         .req r1
	temp           .req r2
	i              .req r3

	/* VFP Registers */
	vfp_min        .req s0
	vfp_temp       .req s1

	push {lr}
	vpush {s0-s1}

	push {r0-r1}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r1}

	cmp temp, #-1
	vmoveq vfp_min, temp
	beq stat32_fmin_common

	lsr temp, temp, #2                      @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                      @ Prevent Overflow

	cmp length, #0
	mvnle temp, #0
	vmovle vfp_min, temp
	ble stat32_fmin_common

	vldr vfp_min, [array_heap]

	mov i, #1
	stat32_fmin_loop:
		lsl temp, i, #2                         @ Substitute of Multiplication by 4
		add temp, array_heap, temp              @ vldr/vstr Can't Offset by Value in ARM Register
		vldr vfp_temp, [temp]
		vcmp.f32 vfp_temp, vfp_min
		vmrs apsr_nzcv, fpscr                   @ Transfer FPSCR Flags to CPSR's NZCV
		vmovlt vfp_min, vfp_temp
		add i, i, #1
		cmp i, length
		blt stat32_fmin_loop

	stat32_fmin_common:
		vmov r0, vfp_min
		vpop {s0-s1}
		pop {pc}

.unreq array_heap
.unreq length
.unreq temp
.unreq i
.unreq vfp_min
.unreq vfp_temp


/**
 * function stat32_fmean
 * Return Arithmetic Mean with Single Precision Float
 *
 * Parameters
 * r0: Array of Single Precision Float in Heap
 * r1: Length of Array
 *
 * Return: r0 (Value by Single Precision Float, -1 by Integer as Error)
 * Error(-1): No Heap Area
 */
.globl stat32_fmean
stat32_fmean:
	/* Auto (Local) Variables, but just Aliases */
	array_heap     .req r0
	length         .req r1
	temp           .req r2

	/* VFP Registers */
	vfp_sum        .req s0
	vfp_length     .req s1
	vfp_temp       .req s2

	push {lr}
	vpush {s0-s2}

	push {r0-r1}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r1}

	cmp temp, #-1
	vmoveq vfp_sum, temp
	beq stat32_fmean_common

	lsr temp, temp, #2                      @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                      @ Prevent Overflow

	vmov vfp_length, length
	vcvt.f32.u32 vfp_length, vfp_length

	mov temp, #0
	vmov vfp_sum, temp
	vcvt.f32.u32 vfp_sum, vfp_sum

	cmp length, #0
	ble stat32_fmean_common

	sub length, length, #1

	stat32_fmean_sum:
		lsl temp, length, #2                    @ Substitute of Multiplication by 4
		add temp, array_heap, temp              @ vldr/vstr Can't Offset by Value in ARM Register
		vldr vfp_temp, [temp]
		vadd.f32 vfp_sum, vfp_sum, vfp_temp
		sub length, length, #1
		cmp length, #0
		bge stat32_fmean_sum
	
		vdiv.f32 vfp_sum, vfp_sum, vfp_length

	stat32_fmean_common:
		vmov r0, vfp_sum
		vpop {s0-s2}
		pop {pc}

.unreq array_heap
.unreq length
.unreq temp
.unreq vfp_sum
.unreq vfp_length
.unreq vfp_temp


/**
 * function stat32_fmedian
 * Return Median with Single Precision Float
 *
 * Parameters
 * r0: Array of Single Precision Float in Heap, Must Be Ordered
 * r1: Length of Array
 *
 * Return: r0 (Value by Single Precision Float, -1 by Integer as Error)
 * Error(-1): No Heap Area
 */
.globl stat32_fmedian
stat32_fmedian:
	/* Auto (Local) Variables, but just Aliases */
	array_heap         .req r0
	length             .req r1
	temp               .req r2

	/* VFP Registers */
	vfp_median         .req s0
	vfp_temp           .req s1

	push {lr}
	vpush {s0-s1}

	push {r0-r1}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r1}

	cmp temp, #-1
	vmoveq vfp_median, temp
	beq stat32_fmedian_common

	lsr temp, temp, #2                      @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                      @ Prevent Overflow

	/* Test Even or Odd */
	tst length, #1
	lsr length, length, #1                  @ Substitute of Division by 2
	lsl length, length, #2                  @ Substitute of Multiplication by 4
	beq stat32_fmedian_even

	add length, array_heap, length          @ vldr/vstr Can't Offset by Value in ARM Register
	vldr vfp_median, [length]

	b stat32_fmedian_common

	stat32_fmedian_even:
		add length, array_heap, length          @ vldr/vstr Can't Offset by Value in ARM Register
		vldr vfp_median, [length]
		sub length, length, #4
		vldr vfp_temp, [length]
		vadd.f32 vfp_median, vfp_median, vfp_temp

		mov temp, #2
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp

		vdiv.f32 vfp_median, vfp_median, vfp_temp

	stat32_fmedian_common:
		vmov r0, vfp_median
		vpop {s0-s1}
		pop {pc}

.unreq array_heap
.unreq length
.unreq temp
.unreq vfp_median
.unreq vfp_temp


/**
 * function stat32_fmode
 * Return Mode with Single Precision Float
 *
 * Parameters
 * r0: Array of Single Precision Float in Heap, Must Be Ordered
 * r1: Length of Array
 *
 * Return: r0 (Value by Single Precision Float, -1 by Integer as Error)
 * Error(-1): No Heap Area
 */
.globl stat32_fmode
stat32_fmode:
	/* Auto (Local) Variables, but just Aliases */
	array_heap         .req r0
	length             .req r1
	temp               .req r2
	count_now          .req r3
	count_mode         .req r4
	i                  .req r5

	/* VFP Registers */
	vfp_mode           .req s0
	vfp_current        .req s1
	vfp_previous       .req s2

	push {r4-r5,lr}
	vpush {s0-s2}

	/* If Length is 0 or Minus (Overing Limit) */
	cmp length, #0
	mvnle temp, #0
	vmovle vfp_mode, temp
	ble stat32_fmode_common

	push {r0-r1}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r1}

	cmp temp, #-1
	vmoveq vfp_mode, temp
	beq stat32_fmode_common

	lsr temp, temp, #2                      @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                      @ Prevent Overflow

	vldr vfp_previous, [array_heap]
	vmov vfp_mode, vfp_previous 

	/* If Length is 1 */
	mov i, #1
	cmp i, length
	bge stat32_fmode_common

	mov count_now, #1
	mov count_mode, #0

	stat32_fmode_loop:
		lsl temp, i, #2                               @ Substitute of Multiplication by 4
		add temp, array_heap, temp                    @ vldr/vstr Can't Offset by Value in ARM Register
		vldr vfp_current, [temp]
		vcmp.f32 vfp_previous, vfp_current
		vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
		addeq count_now, count_now, #1
		beq stat32_fmode_loop_common

		/* If Current Value Is Different from Previous One */
		cmp count_now, count_mode
		vmovgt vfp_mode, vfp_previous 
		movgt count_mode, count_now

		/* Reset Count */
		mov count_now, #1

		stat32_fmode_loop_common:
			vmov vfp_previous, vfp_current
			add i, i, #1
			cmp i, length
			blt stat32_fmode_loop

			/* Last Check */
			cmp count_now, count_mode
			vmovgt vfp_mode, vfp_previous 

	stat32_fmode_common:
		vmov r0, vfp_mode
		vpop {s0-s2}
		pop {r4-r5,pc}

.unreq array_heap
.unreq length
.unreq temp
.unreq count_now
.unreq count_mode
.unreq i
.unreq vfp_mode
.unreq vfp_current
.unreq vfp_previous


/**
 * function stat32_forder
 * Return Ordered Array
 * Note that this function makes new memory space to be needed to make the memory free.
 *
 * Parameters
 * r0: Pointer of Array of Single Precision Float
 * r1: Length of Array
 * r2: Ascending Order (0)/ Decreasing Order (1)
 *
 * Return: r0 (Pointer of Ordered Array, If Zero Memory Allocation Failed)
 */
.globl stat32_forder
stat32_forder:
	/* Auto (Local) Variables, but just Aliases */
	array_heap         .req r0
	length             .req r1
	order              .req r2
	temp               .req r3
	i                  .req r4
	shift              .req r5
	array_heap_ordered .req r6

	/* VFP Registers */
	vfp_temp           .req s0
	vfp_temp2          .req s1

	push {r4-r6,lr}
	vpush {s0-s1}

	push {r0-r2}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r2}

	cmp temp, #-1
	moveq array_heap_ordered, #0
	beq stat32_forder_common

	lsr temp, temp, #2                              @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                              @ Prevent Overflow

	push {r0-r3}
	mov r0, length
	bl heap32_malloc
	mov array_heap_ordered, r0
	pop {r0-r3}

	cmp array_heap_ordered, #0
	beq stat32_forder_common

	push {r0-r3}
	mov r2, array_heap
	lsl temp, length, #2
	push {temp}
	mov r0, array_heap_ordered
	mov r1, #0 
	mov r3, #0
	bl heap32_mcopy
	add sp, sp, #4
	pop {r0-r3}

	.unreq temp
	flag_swapped .req r3

	mov flag_swapped, #1
	sub length, length, #1                          @ Prevent Overflow on Procedure Below

	cmp order, #1
	bge stat32_forder_decreasing

	stat32_forder_ascending:
		cmp flag_swapped, #0
		beq stat32_forder_common
		mov flag_swapped, #0
		mov i, #0
		stat32_forder_ascending_loop:
			lsl shift, i, #2                              @ Substitute of Multiplication by 4
			add shift, array_heap_ordered, shift          @ vldr/vstr Can't Offset by Value in ARM Register
			vldr vfp_temp, [shift]
			add shift, shift, #4
			vldr vfp_temp2, [shift]
			vcmp.f32 vfp_temp, vfp_temp2
			vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
			vstrgt vfp_temp, [shift]
			subgt shift, shift, #4
			vstrgt vfp_temp2, [shift]
			movgt flag_swapped, #1
			add i, i, #1
			cmp i, length
			blt stat32_forder_ascending_loop

			b stat32_forder_ascending

	stat32_forder_decreasing:
		cmp flag_swapped, #0
		beq stat32_forder_common
		mov flag_swapped, #0
		mov i, #0
		stat32_forder_decreasing_loop:
			lsl shift, i, #2                              @ Substitute of Multiplication by 4
			add shift, array_heap_ordered, shift          @ vldr/vstr Can't Offset by Value in Register
			vldr vfp_temp, [shift]
			add shift, shift, #4
			vldr vfp_temp2, [shift]
			vcmp.f32 vfp_temp, vfp_temp2
			vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
			vstrlt vfp_temp, [shift]
			sublt shift, shift, #4
			vstrlt vfp_temp2, [shift]
			movlt flag_swapped, #1
			add i, i, #1
			cmp i, length
			blt stat32_forder_decreasing_loop

			b stat32_forder_decreasing

	stat32_forder_common:
		mov r0, array_heap_ordered
		vpop {s0-s1}
		pop {r4-r6,pc}

.unreq array_heap
.unreq length
.unreq order
.unreq flag_swapped
.unreq i
.unreq shift
.unreq array_heap_ordered
.unreq vfp_temp
.unreq vfp_temp2

