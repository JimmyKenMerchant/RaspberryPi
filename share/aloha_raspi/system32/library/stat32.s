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
	lsl length, length, #2                  @ Substitute of Multiplication by 4

	stat32_fmean_sum:
		vldr vfp_temp, [array_heap, length]
		vadd.f32 vfp_sum, vfp_sum, vfp_temp
		sub length, length, #4
		cmp length, #0
		bge stat32_fmean_sum
	
		vdiv.f32 vfp_sum, vfp_sum, vfp_length

	stat32_fmean_common:
		vmov r0, vfp_sum
		vpop {s0-s2}
		mov pc, lr

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
	beq stat32_fmedian_even

	vldr vfp_median, [array_heap, length]

	b stat32_fmedian_common

	stat32_fmedian_even:

		vldr vfp_median, [array_heap, length]
		sub length, length, #4
		vldr vfp_temp, [array_heap, length]
		vadd.f32 vfp_median, vfp_median, vfp_temp

		mov temp, #2
		vmov vfp_temp, temp
		vcvt.f32.u32 vfp_temp, vfp_temp

		vdiv.f32 vfp_median, vfp_median, vfp_temp

	stat32_fmedian_common:
		vmov r0, vfp_median
		vpop {s0-s1}
		mov pc, lr

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

	mov i, #0
	lsl temp, i, #2                         @ Substitute of Multiplication by 4
	vldr vfp_previous, [array_heap, temp]
	vmov vfp_mode, vfp_previous 

	add i, i, #1
	cmp i, length
	bge stat32_fmode_common

	mov count_now, #1
	mov count_mode, #0

	stat32_fmode_loop:
		lsl temp, i, #2
		vldr vfp_current, [array_heap, temp]
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

	lsr temp, temp, #2                      @ Substitute of Division by 4

	cmp length, temp
	movgt length, temp                      @ Prevent Overflow

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

	cmp order, #1
	bge stat32_forder_decreasing

	stat32_forder_ascending:
		cmp flag_swapped, #0
		beq stat32_forder_common
		mov flag_swapped, #0
		mov i, #0
		stat32_forder_ascending_loop:
			lsl shift, i, #2                              @ Substitute of Multiplication by 4
			vldr vfp_temp, [array_heap_ordered, shift]
			add shift, shift, #4
			vldr vfp_temp2, [array_heap_ordered, shift]
			vcmp.f32 vfp_temp, vfp_temp2
			vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
			vstrgt vfp_temp, [array_heap_ordered, shift]
			subgt shift, shift, #4
			vstrgt vfp_temp2, [array_heap_ordered, shift]
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
			vldr vfp_temp, [array_heap_ordered, shift]
			add shift, shift, #4
			vldr vfp_temp2, [array_heap_ordered, shift]
			vcmp.f32 vfp_temp, vfp_temp2
			vmrs apsr_nzcv, fpscr                         @ Transfer FPSCR Flags to CPSR's NZCV
			vstrlt vfp_temp, [array_heap_ordered, shift]
			sublt shift, shift, #4
			vstrlt vfp_temp2, [array_heap_ordered, shift]
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

