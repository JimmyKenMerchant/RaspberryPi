/**
 * heap32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

HEAP32_ADDR:          .word SYSTEM32_HEAP
HEAP32_MALLOC_SIZE:   .word SYSTEM32_HEAP_NONCACHE - SYSTEM32_HEAP
HEAP32_NONCACHE_ADDR: .word SYSTEM32_HEAP_NONCACHE
HEAP32_NONCACHE_SIZE: .word SYSTEM32_HEAP_NONCACHE_END - SYSTEM32_HEAP_NONCACHE
HEAP32_SIZE:          .word SYSTEM32_HEAP_END - SYSTEM32_HEAP                   @ Size of All

/* Memory Partition for heap32_malloc and heap32_malloc_noncache */
HEAP32_MPARTITION_ADDR:           .word HEAP32_MPARTITION0
HEAP32_MPARTITION0:               .word SYSTEM32_HEAP
HEAP32_MPARTITION0_SIZE:          .word SYSTEM32_HEAP_NONCACHE - SYSTEM32_HEAP
HEAP32_MPARTITION1:               .word 0x00
HEAP32_MPARTITION1_SIZE:          .word 0x00
HEAP32_MPARTITION2:               .word 0x00
HEAP32_MPARTITION2_SIZE:          .word 0x00
HEAP32_MPARTITION3:               .word 0x00
HEAP32_MPARTITION3_SIZE:          .word 0x00
HEAP32_NONCACHE_MPARTITION0:      .word SYSTEM32_HEAP_NONCACHE
HEAP32_NONCACHE_MPARTITION0_SIZE: .word SYSTEM32_HEAP_NONCACHE_END - SYSTEM32_HEAP_NONCACHE
HEAP32_NONCACHE_MPARTITION1:      .word 0x00
HEAP32_NONCACHE_MPARTITION1_SIZE: .word 0x00
HEAP32_NONCACHE_MPARTITION2:      .word 0x00
HEAP32_NONCACHE_MPARTITION2_SIZE: .word 0x00
HEAP32_NONCACHE_MPARTITION3:      .word 0x00
HEAP32_NONCACHE_MPARTITION3_SIZE: .word 0x00


/**
 * function heap32_mpartition
 * Set Memory Partition for heap32_malloc
 *
 * Parameters
 * r0: Memory Size (Bytes) for First Partition, 4 Bytes Align
 * r1: Memory Size (Bytes) for Second Partition, 4 Bytes Align
 * r2: Memory Size (Bytes) for Third Partition, 4 Bytes Align
 * r3: Memory Size (Bytes) for Fourth Partition, 4 Bytes Align
 *
 * Return: r0 (0 as success)
 */
.globl heap32_mpartition
heap32_mpartition:
	/* Auto (Local) Variables, but just Aliases */
	mpartition0_size .req r0
	mpartition1_size .req r1
	mpartition2_size .req r2
	mpartition3_size .req r3
	heap_start       .req r4
	heap_size        .req r5
	mpartition_addr  .req r6

	push {r4-r6,lr}

	ldr mpartition_addr, HEAP32_MPARTITION_ADDR
	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_MALLOC_SIZE

	heap32_mpartition_partition:
		bic mpartition0_size, mpartition0_size, #0b11
		bic mpartition1_size, mpartition1_size, #0b11
		bic mpartition2_size, mpartition2_size, #0b11
		bic mpartition3_size, mpartition3_size, #0b11

		subs heap_size, heap_size, mpartition0_size
		blt heap32_mpartition_success
		add heap_start, heap_start, mpartition0_size
		str mpartition0_size, [mpartition_addr, #4]

		subs heap_size, heap_size, mpartition1_size
		blt heap32_mpartition_success
		str heap_start, [mpartition_addr, #8]
		add heap_start, heap_start, mpartition1_size
		str mpartition1_size, [mpartition_addr, #12]

		subs heap_size, heap_size, mpartition2_size
		blt heap32_mpartition_success
		str heap_start, [mpartition_addr, #16]
		add heap_start, heap_start, mpartition2_size
		str mpartition2_size, [mpartition_addr, #20]

		subs heap_size, heap_size, mpartition3_size
		blt heap32_mpartition_success
		str heap_start, [mpartition_addr, #24]
		str mpartition3_size, [mpartition_addr, #28]

	heap32_mpartition_success:
		mov r0, #0

	heap32_mpartition_common:
		macro32_dsb ip                            @ Ensure Completion of Instructions Before
		pop {r4-r6,pc}

.unreq mpartition0_size
.unreq mpartition1_size
.unreq mpartition2_size
.unreq mpartition3_size
.unreq heap_start
.unreq heap_size
.unreq mpartition_addr


/**
 * function heap32_mpartition_noncache
 * Set Memory Partition for heap32_malloc_noncache
 *
 * Parameters
 * r0: Memory Size (Bytes) for First Partition, 4 Bytes Align
 * r1: Memory Size (Bytes) for Second Partition, 4 Bytes Align
 * r2: Memory Size (Bytes) for Third Partition, 4 Bytes Align
 * r3: Memory Size (Bytes) for Fourth Partition, 4 Bytes Align
 *
 * Return: r0 (0 as success)
 */
.globl heap32_mpartition_noncache
heap32_mpartition_noncache:
	/* Auto (Local) Variables, but just Aliases */
	mpartition0_size .req r0
	mpartition1_size .req r1
	mpartition2_size .req r2
	mpartition3_size .req r3
	heap_start       .req r4
	heap_size        .req r5
	mpartition_addr  .req r6

	push {r4-r6,lr}

	ldr mpartition_addr, HEAP32_MPARTITION_ADDR
	/* Offset for Noncache Partition */
	add mpartition_addr, mpartition_addr, #32
	ldr heap_start, HEAP32_NONCACHE_ADDR
	ldr heap_size, HEAP32_NONCACHE_SIZE

	/**
	 * Hook to Process of heap32_mpartition
	 */
	b heap32_mpartition_partition

.unreq mpartition0_size
.unreq mpartition1_size
.unreq mpartition2_size
.unreq mpartition3_size
.unreq heap_start
.unreq heap_size
.unreq mpartition_addr


/**
 * function heap32_mpush
 * Push Data to Last by FIFO Stack Style
 * Length of Data in FIFO stack is stored on the first word of the memory space.
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 * r1: Data to Be Stored
 * r2: Size Indicator 0 = 1 Byte, 1 = 2 Bytes, 2 = 4 Bytes, Indicating Each Data of Array
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Data Didn't Be Stored Because Size of Memory Space Is Already Full
 */
.globl heap32_mpush
heap32_mpush:
	/* Auto (Local) Variables, but just Aliases */
	block_start    .req r0
	data           .req r1
	size_indicator .req r2
	block_size     .req r3
	next_length    .req r4
	heap_start     .req r5
	heap_size      .req r6
	save_cpsr      .req r7

	push {r4-r7,lr}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	/* For Atomic Procedure, Set FIQ and IRQ Disable to CPSR */
	mrs save_cpsr, cpsr
	orr ip, save_cpsr, #equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, ip

	cmp block_start, #0
	beq heap32_mpush_error

	ldr block_size, [block_start, #-4]          @ Maximam Size of Allocated Space (Bytes)
	add block_size, block_start, block_size
	sub block_size, block_size, #4              @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ In Bytes
	add heap_size, heap_start, heap_size

	cmp block_start, heap_start
	blo heap32_mpush_error                      @ Unsigned Lower Than
	cmp block_size, heap_size
	bhs heap32_mpush_error

	cmp size_indicator, #2
	movhi size_indicator, #2

	ldr next_length, [block_start]              @ The First Word of Buffer

	lsl next_length, next_length, size_indicator
	add next_length, next_length, block_start
	add next_length, next_length, #4            @ Offset for Length of Data
	cmp next_length, block_size
	bhs heap32_mpush_error

	cmp size_indicator, #2
	strhs data, [next_length]
	bhs heap32_mpush_success

	cmp size_indicator, #1
	strhsh data, [next_length]
	bhs heap32_mpush_success

	cmp size_indicator, #0
	strhsb data, [next_length]
	bhs heap32_mpush_success

	heap32_mpush_error:
		mov r0, #1
		b heap32_mpush_common

	heap32_mpush_success:
		sub next_length, next_length, #4
		sub next_length, next_length, block_start
		lsr next_length, next_length, size_indicator
		add next_length, next_length, #1
		str next_length, [block_start]            @ The First Word of Buffer
		mov r0, #0

	heap32_mpush_common:
		/* Return CPSR */
		msr cpsr_c, save_cpsr
		macro32_dsb ip                            @ Ensure Completion of Instructions Before
		pop {r4-r7,pc}

.unreq block_start
.unreq data
.unreq size_indicator
.unreq block_size
.unreq next_length
.unreq heap_start
.unreq heap_size
.unreq save_cpsr


/**
 * function heap32_mpop
 * Pop Data From First by FIFO Stack Style
 * Length of Data in FIFO stack is stored on the first word of the memory space.
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 * r1: Size Indicator 0 = 1 Byte, 1 = 2 Bytes, 2 = 4 Bytes, Indicating Each Data of Array
 *
 * Return: r0 (Data to Be Popped)
 */
.globl heap32_mpop
heap32_mpop:
	/* Auto (Local) Variables, but just Aliases */
	block_start    .req r0
	size_indicator .req r1
	current_length .req r2
	offset         .req r3
	data           .req r4
	save_cpsr      .req r5

	push {r4-r5,lr}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	/* For Atomic Procedure, Set FIQ and IRQ Disable to CPSR */
	mrs save_cpsr, cpsr
	orr ip, save_cpsr, #equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, ip

	cmp size_indicator, #2
	movhi size_indicator, #2

	ldr current_length, [block_start]           @ The First Word of Buffer
	subs current_length, current_length, #1
	blt heap32_mpop_error
	lsl current_length, current_length, size_indicator

	cmp size_indicator, #2
	ldrhs data, [block_start, #4]
	bhs heap32_mpop_copy

	cmp size_indicator, #1
	ldrhsh data, [block_start, #4]
	bhs heap32_mpop_copy

	cmp size_indicator, #0
	ldrhsb data, [block_start, #4]

	heap32_mpop_copy:
		/* Make Offset of Bytes to Be Copied (Source) */
		mov offset, #1
		lsl offset, offset, size_indicator
		add offset, offset, #4

		push {r0-r3}
		mov r1, #4
		push {current_length}                   @ r4: Length of Bytes to Be Copied (Source)
		mov r2, block_start                     @ Pointer of Start Address of Memory Space to Be Copied (Source)
		bl heap32_mcopy
		add sp, sp, #4
		mov offset, r0
		pop {r0-r3}

		cmp offset, #0
		bne heap32_mpop_success

	heap32_mpop_error:
		mov r0, #0
		b heap32_mpop_common

	heap32_mpop_success:
		lsr current_length, current_length, size_indicator
		str current_length, [block_start]           @ The First Word of Buffer
		mov r0, data

	heap32_mpop_common:
		/* Return CPSR */
		msr cpsr_c, save_cpsr
		macro32_dsb ip                              @ Ensure Completion of Instructions Before
		pop {r4-r5,pc}

.unreq block_start
.unreq size_indicator
.unreq current_length
.unreq offset
.unreq data
.unreq save_cpsr


/**
 * function heap32_clear_heap
 * Clear (All Zero) in Heap
 *
 * Usage: r0-r2
 * Return: r0 (0 as Success)
 */
.globl heap32_clear_heap
heap32_clear_heap:
	/* Auto (Local) Variables, but just Aliases */
	heap_start  .req r0
	heap_size   .req r1
	heap_bytes  .req r2
	cache_start .req r3
	cache_size  .req r4

	push {r4,lr}

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ In Bytes

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	/* Loop 1 */
	add heap_size, heap_start, heap_size
	mov heap_bytes, #0

	/* Loop 2 */
	mov cache_start, heap_start
	mov cache_size, heap_size
	bic cache_start, cache_start, #0x1F
	bic cache_size, cache_size, #0x1F

	heap32_clear_heap_loop1:
		cmp heap_start, heap_size
		bhs heap32_clear_heap_loop2         @ If Heap Space Overflow

		str heap_bytes, [heap_start]

		add heap_start, heap_start, #4
		b heap32_clear_heap_loop1           @ If Bytes are not Zero

	heap32_clear_heap_loop2:
		cmp cache_start, cache_size
		bhi heap32_clear_heap_common

		mcr p15, 0, cache_start, c7, c10, 1 @ Clean Data Cache to PoC by MVA

		macro32_dsb ip

		add cache_start, cache_start, #0x20 @ 32 Bytes (4 Words) Align
		b heap32_clear_heap_loop2           @ If Bytes are not Zero

	heap32_clear_heap_common:
		mov r0, #0
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4,pc}

.unreq heap_start
.unreq heap_size
.unreq heap_bytes
.unreq cache_start
.unreq cache_size


/**
 * function heap32_malloc
 * Get Memory Space from Heap (4 Bytes:1 Word Align)
 * Allocated Memory Size is Stored from the Address where Start Address of Memory Minus 4 Bytes
 * Argument, Size Means Number of Words Allocated
 * Caution! There are differences between the standard function in C language and this function.
 *
 * Parameters
 * r0: Number of Words, 1 Word means 4 Bytes
 *
 * Return: r0 (Pointer of Start Address of Memory Space, If Zero, Memory Allocation Fails)
 */
.globl heap32_malloc
heap32_malloc:
	/* Auto (Local) Variables, but just Aliases */
	size            .req r0 @ Parameter, Register for Argument and Result, Scratch Register, Block (4 Bytes) Size
	heap_start      .req r1
	heap_size       .req r2
	heap_bytes      .req r3
	mpartition_addr .req r4
	number_core     .req r5

	push {r4-r5}

	macro32_dsb ip                        @ Ensure Completion of Instructions Before

	lsl size, size, #2                    @ Multiply by 4, Words to Bytes

	ldr mpartition_addr, HEAP32_MPARTITION_ADDR

	heap32_malloc_multicore:
/* Consider of Multi-core on ARMv7/AArch32 */
.ifndef __ARMV6
		mrs ip, cpsr
		tst ip, #0xF                          @ Check User Mode (EL0) or Not

		/* If User Mode (EL0) */
		moveq number_core, #equ32_bcm32_core_os
		beq heap32_malloc_multicore_common

		/* If Other than User Mode (EL0) */
		macro32_multicore_id number_core

		heap32_malloc_multicore_common:
			lsl number_core, number_core, #3      @ Multiply by 8
			add mpartition_addr, mpartition_addr, number_core
.endif

	ldr heap_start, [mpartition_addr]
	ldr heap_size, [mpartition_addr, #4]  @ In Bytes
	add heap_size, heap_start, heap_size

	.unreq mpartition_addr
	.unreq number_core
	check_start .req r4
	check_size  .req r5

	heap32_malloc_loop:
		cmp heap_start, heap_size
		bhs heap32_malloc_error               @ If Heap Space Overflow

		ldr heap_bytes, [heap_start]
		cmp heap_bytes, #0
		beq heap32_malloc_loop_sizecheck      @ If Bytes are Zero

		add heap_start, heap_start, heap_bytes
		b heap32_malloc_loop                  @ If Bytes are not Zero

		/* Whether Check Size is Enough or Not */

		heap32_malloc_loop_sizecheck:
			mov check_start, heap_start
			add check_size, check_start, size

			heap32_malloc_loop_sizecheck_loop:
				cmp check_start, heap_size
				bhs heap32_malloc_error               @ If Heap Space Overflow

				cmp check_start, check_size
				bhi heap32_malloc_success             @ Inclusive Loop Because Memory Needs Its Required Size Plus 4 Bytes

				ldr heap_bytes, [check_start]

				cmp heap_bytes, #0
				addeq check_start, check_start, #4
				beq heap32_malloc_loop_sizecheck_loop @ If Bytes are Zero

				add heap_start, check_start, heap_bytes
				b heap32_malloc_loop                  @ If Bytes are not Zero

	heap32_malloc_error:
		mov r0, #0
		b heap32_malloc_common

	heap32_malloc_success:
		add size, size, #4                      @ Add Space of Size Indicator Itself
		str size, [heap_start]                  @ Store Size (Bytes) on Start Address of Memory Minus 4 Bytes
		mov r0, heap_start
		add r0, r0, #4                          @ Slide for Start Address of Memory

	heap32_malloc_common:
		macro32_dsb ip                          @ Ensure Completion of Instructions Before
		pop {r4-r5}
		mov pc, lr

.unreq size
.unreq heap_start
.unreq heap_size
.unreq heap_bytes
.unreq check_start
.unreq check_size


/**
 * function heap32_malloc_noncache
 * Get Non-cache Memory Space from Heap (4 Bytes:1 Word Align)
 * Allocated Memory Size is Stored from the Address where Start Address of Memory Minus 4 Bytes
 * Argument, Size Means Number of Words Allocated
 * Caution! There are differences between the standard function in C language and this function.
 *
 * Parameters
 * r0: Number of Words, 1 Word means 4 Bytes
 *
 * Return: r0 (Pointer of Start Address of Memory Space, If Zero, Memory Allocation Fails)
 */
.globl heap32_malloc_noncache
heap32_malloc_noncache:
	/* Auto (Local) Variables, but just Aliases */
	size            .req r0 @ Parameter, Register for Argument and Result, Scratch Register, Block (4 Bytes) Size
	heap_start      .req r1
	heap_size       .req r2
	heap_bytes      .req r3
	mpartition_addr .req r4
	number_core     .req r5

	push {r4-r5}

	macro32_dsb ip                        @ Ensure Completion of Instructions Before

	lsl size, size, #2                    @ Multiply by 4, Words to Bytes

	ldr mpartition_addr, HEAP32_MPARTITION_ADDR
	/* Offset for Noncache Partition */
	add mpartition_addr, mpartition_addr, #32

	.unreq mpartition_addr
	.unreq number_core
	check_start .req r4
	check_size  .req r5

	/**
	 * Hook to Process of heap32_malloc
	 */
	b heap32_malloc_multicore

.unreq size
.unreq heap_start
.unreq heap_size
.unreq heap_bytes
.unreq check_start
.unreq check_size


/**
 * function heap32_mfree
 * Free Memory Space in Heap
 * Allocated Memory Size is Stored from the Address where Start Address of Memory Minus 4 Bytes
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 *
 * Usage: r0-r4
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Pointer of Start Address is Null (0) or Not in Heap Area
 */
.globl heap32_mfree
heap32_mfree:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	block_size       .req r1
	heap_start       .req r2
	heap_size        .req r3
	zero             .req r4

	push {r4,lr}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq heap32_mfree_error

	sub block_start, block_start, #4            @ Slide Minus 4 Bytes for Size Indicator of Memory Space
	ldr block_size, [block_start]
	add block_size, block_start, block_size

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ In Bytes
	add heap_size, heap_start, heap_size

	cmp block_size, heap_size                   @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bhi heap32_mfree_error                      @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size

	cmp block_start, heap_start
	blo heap32_mfree_error

	mov zero, #0

	heap32_mfree_loop:
		cmp block_start, block_size
		bhs heap32_mfree_success

		str zero, [block_start]
		add block_start, block_start, #4

		b heap32_mfree_loop

	heap32_mfree_error:
		mov r0, #1
		b heap32_mfree_common

	heap32_mfree_success:
		mov r0, #0

	heap32_mfree_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4,pc}

.unreq block_start
.unreq block_size
.unreq heap_start
.unreq heap_size
.unreq zero


/**
 * function heap32_mcount
 * Return Size of Memory Space by Byte
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 *
 * Return: r0 (Size of Memory Space by Byte, -1 as Error)
 * Error: Pointer of Start Address is Null (0) or Out of Heap Area
 */
.globl heap32_mcount
heap32_mcount:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	block_size       .req r1
	heap_start       .req r2
	heap_size        .req r3

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq heap32_mcount_error

	sub block_start, block_start, #4            @ Slide Minus 4 Bytes for Size Indicator of Memory Space
	ldr block_size, [block_start]
	add block_size, block_start, block_size

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ In Bytes
	add heap_size, heap_start, heap_size

	cmp block_size, heap_size                   @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bhi heap32_mcount_error                     @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size

	cmp block_start, heap_start
	blo heap32_mcount_error

	sub block_size, block_size, block_start
	sub block_start, block_size, #4

	b heap32_mcount_common

	heap32_mcount_error:
		mvn r0, #0

	heap32_mcount_common:
		mov pc, lr

.unreq block_start
.unreq block_size
.unreq heap_start
.unreq heap_size


/**
 * function heap32_mcopy
 * Copy Value in Memory
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to Be Destination
 * r1: Offset of Bytes to Be Copied (Destination)
 * r2: Pointer of Start Address of Memory Space to Be Copied (Source)
 * r3: Offset of Bytes to Be Copied (Source)
 * r4: Length of Bytes to Be Copied (Source)
 *
 * Return: r0 (Pointer of Start Address of Memory Space to Be Destination, If No Enough Space to Copy, Sequence Stops Halfway)
 * Error(0): Wrong Heap for Destination or Source
 */
.globl heap32_mcopy
heap32_mcopy:
	/* Auto (Local) Variables, but just Aliases */
	heap1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	offset1      .req r1 @ Parameter, Register for Argument
	heap2        .req r2 @ Parameter, Register for Argument
	offset2      .req r3 @ Parameter, Register for Argument
	size         .req r4
	heap1_size   .req r5
	heap2_size   .req r6
	byte         .req r7
	heap_start   .req r8
	heap_size    .req r9
	heap1_dup    .req r10

	push {r4-r10}

	add sp, sp, #28                           @ r4-r10 offset 28 bytes
	pop {size}                                @ Get Fifth Arguments
	sub sp, sp, #32                           @ Retrieve SP

	macro32_dsb ip                            @ Ensure Completion of Instructions Before

	cmp heap1, #0
	beq heap32_mcopy_error

	cmp heap2, #0
	beq heap32_mcopy_error

	ldr heap1_size, [heap1, #-4]
	add heap1_size, heap1_size, heap1
	sub heap1_size, heap1_size, #4            @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	ldr heap2_size, [heap2, #-4]
	add heap2_size, heap2_size, heap2
	sub heap2_size, heap2_size, #4            @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                @ In Bytes
	add heap_size, heap_start, heap_size

	cmp heap1, heap_start
	blo heap32_mcopy_error                    @ Unsigned Lower Than
	cmp heap2, heap_start
	blo heap32_mcopy_error
	cmp heap1_size, heap_size
	bhs heap32_mcopy_error                    @ Unsigned Higher Than or Same
	cmp heap2_size, heap_size
	bhs heap32_mcopy_error

	mov heap1_dup, heap1
	add heap1, heap1, offset1                 @ Add Offset for Destination
	add heap2, heap2, offset2                 @ Add Offset for Source

	heap32_mcopy_loop:
		cmp heap1, heap1_size
		bhs heap32_mcopy_success
		cmp heap2, heap2_size
		bhs heap32_mcopy_success

		ldrb byte, [heap2]
		strb byte, [heap1]

		add heap1, heap1, #1
		add heap2, heap2, #1
		sub size, size, #1
		cmp size, #0
		ble heap32_mcopy_success
		b heap32_mcopy_loop               @ If Bytes are not Zero

	heap32_mcopy_error:
		mov r0, #0
		b heap32_mcopy_common

	heap32_mcopy_success:
		mov r0, heap1_dup

	heap32_mcopy_common:
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r10}
		mov pc, lr

.unreq heap1
.unreq offset1
.unreq heap2
.unreq offset2
.unreq size
.unreq heap1_size
.unreq heap2_size
.unreq byte
.unreq heap_start
.unreq heap_size
.unreq heap1_dup


/**
 * function heap32_align_32
 * Align Heap By 32 Bytes (8 Words)
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 *
 * Return: r0 (Aligned Address, 0 as Error)
 * Error: Alignment Is Not Succeeded
 */
.globl heap32_align_32
heap32_align_32:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	block_size       .req r1
	heap_start       .req r2
	heap_size        .req r3

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq heap32_align_32_error

	sub block_start, block_start, #4            @ Slide Minus 4 Bytes for Size Indicator of Memory Space
	ldr block_size, [block_start]
	add block_size, block_start, block_size

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ In Bytes
	add heap_size, heap_start, heap_size

	cmp block_size, heap_size                   @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bhi heap32_align_32_error                   @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size

	cmp block_start, heap_start
	blo heap32_align_32_error

	.unreq heap_start
	block_start_dup .req r2

	add block_start, block_start, #4            @ Retrieve Start Address

	mov block_start_dup, block_start

	heap32_align_32_loop:
		cmp block_start, block_size
		bhs heap32_align_32_error

		/* Must Pass Original Address of Start Point Because of Erasing Size Indicator */
		add block_start, block_start, #4
		tst block_start, #0x1F                  @ Check If 32 Bytes Align or Not

		bne heap32_align_32_loop

		str block_start_dup, [block_start, #-4] @ Store Start Address of HEAP

		b heap32_align_32_common

	heap32_align_32_error:
		mov r0, #0

	heap32_align_32_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq block_start
.unreq block_size
.unreq block_start_dup
.unreq heap_size


/**
 * function heap32_clear_align
 * Clear Alignment
 *
 * Parameters
 * r0: Pointer of Aligned Address of Memory Space by heap32_align_*
 *
 * Return: r0 (Start Address of Memory Space)
 */
.globl heap32_clear_align
heap32_clear_align:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	sub block_start, block_start, #4            @ Slide Minus 4 Bytes for Indicator of Start Address of Heap
	ldr block_start, [block_start]

	heap32_clear_align_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq block_start


/**
 * function heap32_mfill
 * Fill Memory Space by Any Value
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 * r1: Data to be Filled to Memory Space (Word = 4 Byte)
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Pointer of Start Address is Null (0)
 */
.globl heap32_mfill
heap32_mfill:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	data             .req r1
	block_size       .req r2
	heap_start       .req r3
	heap_size        .req r4

	push {r4}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq heap32_mfill_error

	ldr block_size, [block_start, #-4]          @ Maximam Size of Allocated Space (Bytes)
	add block_size, block_start, block_size
	sub block_size, block_size, #4              @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ Maximam Size of Heap Overall (Bytes)
	add heap_size, heap_start, heap_size

	cmp block_size, heap_size                   @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bhi heap32_mfill_error                      @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size
	cmp block_start, heap_start
	blo heap32_mfill_error

	heap32_mfill_loop:
		cmp block_start, block_size
		bhs heap32_mfill_success

		str data, [block_start]
		add block_start, block_start, #4

		b heap32_mfill_loop

	heap32_mfill_error:
		mov r0, #1
		b heap32_mfill_common

	heap32_mfill_success:
		mov r0, #0

	heap32_mfill_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4}
		mov pc, lr

.unreq block_start
.unreq data
.unreq block_size
.unreq heap_start
.unreq heap_size


/**
 * function heap32_mweave
 * Weave Values (32-bit Words) of Two Memory Space into Another Memory Space Alternatively
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Wove
 * r1: Pointer of Start Address of Memory Space to be Odd, Needed to Have the Same Length to Even
 * r2: Pointer of Start Address of Memory Space to be Even, Needed to Have the Same Length to Odd
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 * Error(2): Sizing is Wrong
 */
.globl heap32_mweave
heap32_mweave:
	/* Auto (Local) Variables, but just Aliases */
	block_start_target .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	block_start_odd    .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	block_start_even   .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	temp               .req r3
	block_size_target  .req r4
	block_size_odd     .req r5
	block_size_even    .req r6


	push {r4-r6,lr}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	push {r0-r3}
	bl heap32_mcount
	mov block_size_target, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_mweave_error1

	push {r0-r3}
	mov r0, block_start_odd
	bl heap32_mcount
	mov block_size_odd, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_mweave_error1

	push {r0-r3}
	mov r0, block_start_even
	bl heap32_mcount
	mov block_size_even, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_mweave_error1

	cmp block_size_odd, block_size_even
	bne heap32_mweave_error2

	add temp, block_size_odd, block_size_even
	cmp block_size_target, temp
	blt heap32_mweave_error2

	add block_size_odd, block_start_odd, block_size_odd

	heap32_mweave_loop:
		cmp block_start_odd, block_size_odd
		bhs heap32_mweave_success

		ldr temp, [block_start_odd]
		str temp, [block_start_target]
		add block_start_target, block_start_target, #4
		ldr temp, [block_start_even]
		str temp, [block_start_target]
		add block_start_target, block_start_target, #4

		add block_start_odd, block_start_odd, #4
		add block_start_even, block_start_even, #4

		b heap32_mweave_loop

	heap32_mweave_error1:
		mov r0, #1
		b heap32_mweave_common

	heap32_mweave_error2:
		mov r0, #2
		b heap32_mweave_common

	heap32_mweave_success:
		mov r0, #0

	heap32_mweave_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4-r6,pc}

.unreq block_start_target
.unreq block_start_odd
.unreq block_start_even
.unreq temp
.unreq block_size_target
.unreq block_size_odd
.unreq block_size_even


/**
 * function heap32_mpack
 * Copy Lower 16-bit to Upper 16-bit in One Word
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 * r1: Non-inverted (0) or Inverted (1)
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 */
.globl heap32_mpack
heap32_mpack:
	/* Auto (Local) Variables, but just Aliases */
	block_start .req r0
	flag_invert .req r1
	block_size  .req r2
	temp        .req r3
	shift       .req r4

	push {r4,lr}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	push {r0-r1}
	bl heap32_mcount
	mov block_size, r0
	cmp r0, #-1
	pop {r0-r1}

	beq heap32_mpack_error1

	add block_size, block_start, block_size

	heap32_mpack_loop:
		cmp block_start, block_size
		bge heap32_mpack_success
		ldrh temp, [block_start]
		cmp flag_invert, #0
		mvnne shift, temp
		addne shift, shift, #1
		moveq shift, temp
		lsl shift, shift, #16
		orr temp, temp, shift
		str temp, [block_start]
		add block_start, block_start, #4
		b heap32_mpack_loop

	heap32_mpack_error1:
		mov r0, #1
		b heap32_mpack_common

	heap32_mpack_success:
		mov r0, #0

	heap32_mpack_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4,pc}

.unreq block_start
.unreq flag_invert
.unreq block_size
.unreq temp
.unreq shift


/**
 * function heap32_wave_invert
 * Make Inverted Wave from Another Wave
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space for Inverted Wave
 * r1: Pointer of Start Address of Memory Space for Original Wave
 * r2: Medium of Wave (Signed 32-bit Integer)
 *
 * Return: r0 (0 as Success, 1 or 2 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 * Error(2): Sizing is Wrong
 */
.globl heap32_wave_invert
heap32_wave_invert:
	/* Auto (Local) Variables, but just Aliases */
	block_start_inv    .req r0
	block_start_origin .req r1
	medium             .req r2
	temp               .req r3	
	offset             .req r4	
	block_size_origin  .req r5

	push {r4-r5,lr}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	push {r0-r3}
	bl heap32_mcount
	mov offset, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_wave_invert_error1

	push {r0-r3}
	mov r0, block_start_origin
	bl heap32_mcount
	mov block_size_origin, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_wave_invert_error1

	cmp offset, block_size_origin
	blt heap32_wave_invert_error2

	mov offset, #0

	heap32_wave_invert_loop:
		cmp offset, block_size_origin
		bge heap32_wave_invert_success
		ldr temp, [block_start_origin, offset]
		sub temp, temp, medium
		sub temp, medium, temp
		str temp, [block_start_inv, offset]

		add offset, offset, #4
		b heap32_wave_invert_loop

	heap32_wave_invert_error1:
		mov r0, #1
		b heap32_wave_invert_common

	heap32_wave_invert_error2:
		mov r0, #2
		b heap32_wave_invert_common

	heap32_wave_invert_success:
		mov r0, #0

	heap32_wave_invert_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4-r5,pc}

.unreq block_start_inv
.unreq block_start_origin
.unreq medium
.unreq temp
.unreq offset
.unreq block_size_origin


/**
 * function heap32_wave_square
 * Make Square Wave on Memory Space
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Wave
 * r1: Length of Wave (32-bit Words, Must Be 2 and More)
 * r2: Height of Wave (Signed 32-bit Integer)
 * r3: Medium of Wave (Signed 32-bit Integer)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 * Error(2): Sizing is Wrong | Length is Less Than 2
 */
.globl heap32_wave_square
heap32_wave_square:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	length           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	height           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	medium           .req r3
	block_point      .req r4
	block_size       .req r5
	half             .req r6
	direction        .req r7
	flag_odd         .req r8
	temp             .req r9	

	push {r4-r9,lr}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp length, #2                              @ If Less than 2
	blo heap32_wave_square_error2

	push {r0-r3}
	bl heap32_mcount
	mov block_size, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_wave_square_error1

	lsl temp, length, #2                        @ Substitution of Multiplication by 4
	cmp temp, block_size
	bhi heap32_wave_square_error2               @ If Overflow is Expected

	/* Examine Length to know Odd/Even on Half */

	tst length, #1                              @ If Half is Odd
	movne flag_odd, #1
	addne length, length, #1
	moveq flag_odd, #0

	lsr half, length, #1                        @ Substitution of Division by 2

	lsl length, half, #2                        @ Substitution of Multiplication by 4, Words to Bytes

	/* direction: Plus at First Half(0), Last half (-1) */

	mov direction, #0                           @ Define Direction to Plus at First Half

	add block_point, block_start, length        @ Make First Half

	heap32_wave_square_loop:
		cmp direction, #-1
		blt heap32_wave_square_success
		cmp direction, #0
		addeq temp, medium, height
		subne temp, medium, height
		
		heap32_wave_square_loop_half:
			cmp block_start, block_point
			bhs heap32_wave_square_loop_common

			str temp, [block_start]
			add block_start, block_start, #4

			macro32_dsb ip

			b heap32_wave_square_loop_half

		heap32_wave_square_loop_common:

			add block_point, block_point, length       @ Make Next Half

			tst flag_odd, #1
			subne block_point, block_point, #4         @ If Odd

			sub direction, direction, #1               @ Make New Direction for Next Half

			b heap32_wave_square_loop

	heap32_wave_square_error1:
		mov r0, #1
		b heap32_wave_square_common

	heap32_wave_square_error2:
		mov r0, #2
		b heap32_wave_square_common

	heap32_wave_square_success:
		mov r0, #0

	heap32_wave_square_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4-r9,pc}

.unreq block_start
.unreq length
.unreq height
.unreq medium
.unreq block_point
.unreq block_size
.unreq half
.unreq direction
.unreq flag_odd
.unreq temp


/**
 * function heap32_wave_random
 * Make Random Wave on Memory Space, Type No.1
 * Caution! The Value of Addition of Height and Medium Must Be Within 16-bit (0-65535)
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Wave
 * r1: Length of Wave (32-bit Words, Must Be 2 and More)
 * r2: Height of Wave (Signed 32-bit Integer)
 * r3: Medium of Wave (Signed 32-bit Integer)
 * r4: Resolution 0 to 65535, Affecting Sound Color
 * r5: Stride, Affecting Frequencies
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 * Error(2): Sizing is Wrong | Length is Less Than 2
 */
.globl heap32_wave_random
heap32_wave_random:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0
	length           .req r1
	height           .req r2
	medium           .req r3
	resolution       .req r4
	stride           .req r5
	block_size       .req r6
	temp             .req r7
	lower            .req r8
	upper            .req r9

	/* VFP Registers */
	vfp_random       .req s0
	vfp_resolution   .req s1
	vfp_height       .req s2

	push {r4-r9,lr}

	add sp, sp, #28                             @ r4-r9 and lr offset 28 bytes
	pop {resolution,stride}                     @ Get Fifth and Sixth Arguments
	sub sp, sp, #36

	vpush {s0-s2}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp length, #2                              @ If Less than 2
	blo heap32_wave_random_error2

	cmp stride, #1                              @ If Less than 1
	blo heap32_wave_random_error2

	push {r0-r3}
	bl heap32_mcount
	mov block_size, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_wave_random_error1

	lsl length, length, #2                        @ Substitution of Multiplication by 4
	cmp length, block_size
	bhi heap32_wave_random_error2

	add length, block_start, length

	/**
	 * To avoid over cycles of CPU by randomness, arm32_random have fine numbers for its argument (max. number).
	 * Decimal 255/127/63/31/15/7/3/1 is prefered in 8-bit.
	 * If you want 16-bit random number, take Bit[7:0] one of these prefered, take Bit[15:8] one of these too.
	 */

	cmp resolution, #0x100
	bichs upper, resolution, #0xFF          @ If 16-bit, Clear Bit[7:0]
	subhs lower, resolution, upper          @ If 16-bit, Get Max. Value in Bit[7:0]
	movlo lower, resolution                 @ If 8-bit

	vmov vfp_height, height
	vcvt.f32.u32 vfp_height, vfp_height
	vmov vfp_resolution, resolution
	vcvt.f32.u32 vfp_resolution, vfp_resolution

	.unreq height
	dup_stride .req r2

	heap32_wave_random_loop:
		cmp block_start, length
		bge heap32_wave_random_success

		heap32_wave_random_loop_random:

			push {r0-r3}
			mov r0, lower
			bl arm32_random
			mov temp, r0
			pop {r0-r3}

			cmp resolution, #0x100
			blo heap32_wave_random_loop_common      @ If 8-bit

			/* If 16-bit */

			push {r0-r3}
			lsr r0, upper, #8
			bl arm32_random
			lsl r0, r0, #8
			add temp, temp, r0
			pop {r0-r3}

			cmp temp, resolution                    @ Ensure Range in Intended Value
			bhi heap32_wave_random_loop_random

		heap32_wave_random_loop_common:

			/* Move ARM Regs to VFP Regs and Convert from Unsigned Integer to Float */
			vmov vfp_random, temp
			vcvt.f32.u32 vfp_random, vfp_random

			/* Random Value to Fraction */
			vdiv.f32 vfp_random, vfp_random, vfp_resolution

			/* Multiply Fractional Random Value to Height  */
			vmul.f32 vfp_random, vfp_height, vfp_random

			/* Convert From Float to Unsigned Integer and Move VFP Regs to ARM Regs */
			vcvt.u32.f32 vfp_random, vfp_random
			vmov temp, vfp_random

			/* 0 or 1, Addition or Subtruction */
			push {r0-r3}
			mov r0, #1
			bl arm32_random
			cmp r0, #0
			pop {r0-r3}
			addeq temp, medium, temp
			subne temp, medium, temp

			mov dup_stride, stride
			heap32_wave_random_loop_common_loop:
				subs dup_stride, #1
				blt heap32_wave_random_loop
				cmp block_start, length
				bge heap32_wave_random_success

				str temp, [block_start]
				add block_start, block_start, #4
				b heap32_wave_random_loop_common_loop

	heap32_wave_random_error1:
		mov r0, #1
		b heap32_wave_random_common

	heap32_wave_random_error2:
		mov r0, #2
		b heap32_wave_random_common

	heap32_wave_random_success:
		mov r0, #0

	heap32_wave_random_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		vpop {s0-s2}
		pop {r4-r9,pc}

.unreq block_start
.unreq length
.unreq dup_stride
.unreq medium
.unreq resolution
.unreq stride
.unreq block_size
.unreq temp
.unreq lower
.unreq upper
.unreq vfp_random
.unreq vfp_resolution
.unreq vfp_height


/**
 * function heap32_wave_random2
 * Make Random Wave on Memory Space, Type No.2
 * Caution! The Value of Addition of Height and Medium Must Be Within 16-bit (0-65535)
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Wave
 * r1: Length of Wave (32-bit Words, Must Be 2 and More)
 * r2: Height of Wave (Signed 32-bit Integer)
 * r3: Medium of Wave (Signed 32-bit Integer)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 * Error(2): Sizing is Wrong | Length is Less Than 2
 */
.globl heap32_wave_random2
heap32_wave_random2:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0
	length           .req r1
	height           .req r2
	medium           .req r3
	block_size       .req r4
	temp             .req r5
	lower            .req r6
	upper            .req r7

	push {r4-r7,lr}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp length, #2                              @ If Less than 2
	blo heap32_wave_random2_error2

	push {r0-r3}
	bl heap32_mcount
	mov block_size, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_wave_random2_error1

	lsl length, length, #2                        @ Substitution of Multiplication by 4
	cmp length, block_size
	bhi heap32_wave_random2_error2

	add length, block_start, length

	heap32_wave_random2_loop:
		cmp block_start, length
		bge heap32_wave_random2_success

		heap32_wave_random2_loop_random:

			/**
			 * To avoid over cycles of CPU by randomness, arm32_random have fine numbers for its argument (max. number).
			 * Decimal 255/127/63/31/15/7/3/1 is prefered.
			 * If you want 16-bit random number, take Bit[7:0] one of these prefered, take Bit[15:8] one of these too.
			 */

			cmp height, #0x100
			bichs upper, height, #0xFF              @ If 16-bit, Clear Bit[7:0]
			subhs lower, height, upper              @ If 16-bit, Get Max. Value in Bit[7:0]
			movlo lower, height                     @ If 8-bit

			push {r0-r3}
			mov r0, lower
			bl arm32_random
			mov temp, r0
			pop {r0-r3}

			cmp height, #0x100
			blo heap32_wave_random2_loop_common      @ If 8-bit

			/* If 16-bit */

			push {r0-r3}
			lsr r0, upper, #8
			bl arm32_random
			lsl r0, r0, #8
			add temp, temp, r0
			pop {r0-r3}

			cmp temp, height                       @ Ensure Range in Intended Value
			bhi heap32_wave_random2_loop_random

		heap32_wave_random2_loop_common:
			/* 0 or 1, Addition or Subtruction */
			push {r0-r3}
			mov r0, #1
			bl arm32_random
			cmp r0, #0
			pop {r0-r3}
			addeq temp, medium, temp
			subne temp, medium, temp
			str temp, [block_start]
			add block_start, block_start, #4

			macro32_dsb ip

			b heap32_wave_random2_loop

	heap32_wave_random2_error1:
		mov r0, #1
		b heap32_wave_random2_common

	heap32_wave_random2_error2:
		mov r0, #2
		b heap32_wave_random2_common

	heap32_wave_random2_success:
		mov r0, #0

	heap32_wave_random2_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4-r7,pc}

.unreq block_start
.unreq length
.unreq height
.unreq medium
.unreq block_size
.unreq temp
.unreq lower
.unreq upper


/**
 * function heap32_wave_sawtooth
 * Make Sawtooth Wave on Memory Space
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Wave
 * r1: Length of Wave (32-bit Words, Must Be 4 and More)
 * r2: Height of Wave (Signed 32-bit Integer)
 * r3: Medium of Wave (Signed 32-bit Integer)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 * Error(2): Sizing is Wrong | Length is Less Than 4
 */
.globl heap32_wave_sawtooth
heap32_wave_sawtooth:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	length           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	height           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	medium           .req r3
	block_point      .req r4
	block_size       .req r5
	half             .req r6
	direction        .req r7
	flag_odd         .req r8
	temp             .req r9	

	/* VFP Registers */
	vfp_omega        .req s0 @ d0
	vfp_delta        .req s1
	vfp_half         .req s2 @ d1
	vfp_medium       .req s3
	vfp_height       .req s4
	vfp_base         .req s5
	vfp_value        .req s6
	vfp_one          .req s7
	vfp_zero         .req s8

	push {r4-r9,lr}
	vpush {s0-s8}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp length, #4                              @ If Less than 4
	blo heap32_wave_sawtooth_error2

	push {r0-r3}
	bl heap32_mcount
	mov block_size, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_wave_sawtooth_error1

	lsl temp, length, #2                        @ Substitution of Multiplication by 4
	cmp temp, block_size
	bhi heap32_wave_sawtooth_error2             @ If Overflow is Expected

	/* Examine Length to know Odd/Even on Half */

	tst length, #1                              @ If Half is Odd
	movne flag_odd, #1
	subne length, length, #1
	moveq flag_odd, #0

	lsr half, length, #1                        @ Substitution of Division by 2

	lsl length, half, #2                        @ Substitution of Multiplication by 4, Words to Bytes

	/* direction: Plus at First Half(0), Last half (-1) */

	mov direction, #0                           @ Define Direction to Plus at First Half

	/* Preparation for Usage of VFP Registers */

	mov temp, #0
	vmov vfp_zero, temp
	vcvt.f32.u32 vfp_zero, vfp_zero
	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	vmov vfp_half, half
	vmov vfp_medium, medium
	vmov vfp_height, height

	vcvt.f32.u32 vfp_half, vfp_half
	vcvt.f32.s32 vfp_medium, vfp_medium
	vcvt.f32.s32 vfp_height, vfp_height

	vdiv.f32 vfp_delta, vfp_height, vfp_half

	vmov vfp_base, vfp_medium                   @ Base of First Quarter
	vmov vfp_omega, vfp_zero                    @ Reset Omega

	add block_point, block_start, length        @ Make First Half

	heap32_wave_sawtooth_loop:
		cmp direction, #-1
		blt heap32_wave_sawtooth_success
		cmp direction, #-1
		vsubeq.f32 vfp_base, vfp_medium, vfp_height
		
		heap32_wave_sawtooth_loop_half:
			cmp block_start, block_point
			bhs heap32_wave_sawtooth_loop_common

			vmul.f32 vfp_value, vfp_delta, vfp_omega
			vadd.f32 vfp_value, vfp_base, vfp_value

			vcvtr.s32.f32 vfp_value, vfp_value         @ Signed for Expecting Minus Value
			vstr vfp_value, [block_start]
			add block_start, block_start, #4
			vadd.f32 vfp_omega, vfp_omega, vfp_one

			macro32_dsb ip

			b heap32_wave_sawtooth_loop_half

		heap32_wave_sawtooth_loop_common:
			vmov vfp_omega, vfp_zero                   @ Reset Omega         

			tst flag_odd, #1
			strne medium, [block_start]                @ If Odd
			addne block_start, block_start, #4         @ If Odd
			addne block_point, block_point, #4         @ If Odd
			movne flag_odd, #0                         @ Clear Flag to Prevent Overflow

			add block_point, block_point, length       @ Make Next Half

			sub direction, direction, #1               @ Make New Direction for Next Half

			b heap32_wave_sawtooth_loop

	heap32_wave_sawtooth_error1:
		mov r0, #1
		b heap32_wave_sawtooth_common

	heap32_wave_sawtooth_error2:
		mov r0, #2
		b heap32_wave_sawtooth_common

	heap32_wave_sawtooth_success:
		mov r0, #0

	heap32_wave_sawtooth_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		vpop {s0-s8}
		pop {r4-r9,pc}

.unreq block_start
.unreq length
.unreq height
.unreq medium
.unreq block_point
.unreq block_size
.unreq half
.unreq direction
.unreq flag_odd
.unreq temp
.unreq vfp_omega
.unreq vfp_delta
.unreq vfp_half
.unreq vfp_medium
.unreq vfp_height
.unreq vfp_base
.unreq vfp_value
.unreq vfp_one
.unreq vfp_zero


/**
 * function heap32_wave_triangle
 * Make Triangle Wave on Memory Space
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Wave
 * r1: Length of Wave (32-bit Words, Must Be 5 and More)
 * r2: Height of Wave (Signed 32-bit Integer)
 * r3: Medium of Wave (Signed 32-bit Integer)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 * Error(2): Sizing is Wrong | Length is Less Than 5
 */
.globl heap32_wave_triangle
heap32_wave_triangle:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	length           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	height           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	medium           .req r3
	block_point      .req r4
	block_size       .req r5
	quarter          .req r6
    direction        .req r7
	flag_odd         .req r8
	temp             .req r9	

	/* VFP Registers */
	vfp_omega        .req s0 @ d0
	vfp_delta        .req s1
	vfp_quarter      .req s2 @ d1
	vfp_medium       .req s3
	vfp_height       .req s4
	vfp_base         .req s5
	vfp_value        .req s6
	vfp_one          .req s7
	vfp_zero         .req s8

	push {r4-r9,lr}
	vpush {s0-s8}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp length, #5                              @ If Less than 5
	blo heap32_wave_triangle_error2

	push {r0-r3}
	bl heap32_mcount
	mov block_size, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_wave_triangle_error1

	lsl temp, length, #2                        @ Substitution of Multiplication by 4
	cmp temp, block_size
	bhi heap32_wave_triangle_error2             @ If Overflow is Expected

	/* Examine Length to know Odd/Even on Half and Quarter */

	tst length, #1                              @ If Half is Odd
	movne flag_odd, #1
	addne length, length, #1
	moveq flag_odd, #0

	lsr quarter, length, #1                     @ Substitution of Division by 2

	tst quarter, #1                             @ If Quarter is Odd
	orrne flag_odd, flag_odd, #2
	addne quarter, quarter, #1
	
	lsr quarter, quarter, #1                    @ Substitution of Division by 2

	lsl length, quarter, #2                     @ Substitution of Multiplication by 4, Words to Bytes

	sub quarter, quarter, #1                    @ To Get Delta, Subtract 1

	/* direction: Plus at First Quarter(2), Minus at Second Quarter(1), Minus at Third Quarter(0), Plus at Fourth Quarter(-1) */

	mov direction, #2                           @ Define Direction to Plus at First Quarter

	/* Preparation for Usage of VFP Registers */

	mov temp, #0
	vmov vfp_zero, temp
	vcvt.f32.u32 vfp_zero, vfp_zero
	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	vmov vfp_quarter, quarter
	vmov vfp_medium, medium
	vmov vfp_height, height

	vcvt.f32.u32 vfp_quarter, vfp_quarter
	vcvt.f32.s32 vfp_medium, vfp_medium
	vcvt.f32.s32 vfp_height, vfp_height

	vdiv.f32 vfp_delta, vfp_height, vfp_quarter

	vmov vfp_base, vfp_medium                   @ Base of First Quarter
	vmov vfp_omega, vfp_zero                    @ Reset Omega

	add block_point, block_start, length        @ Make First Quarter

	heap32_wave_triangle_loop:
		cmp direction, #-1
		blt heap32_wave_triangle_success
		
		heap32_wave_triangle_loop_quarter:
			cmp block_start, block_point
			bhs heap32_wave_triangle_loop_common

			vmul.f32 vfp_value, vfp_delta, vfp_omega
			tst direction, #2                          @ Check Bit[1] of direction
			vaddne.f32 vfp_value, vfp_base, vfp_value  @ If High on Bit[1] of direction, Plus
			vsubeq.f32 vfp_value, vfp_base, vfp_value  @ If Low on Bit[1] of direction, Minus

			vcvtr.s32.f32 vfp_value, vfp_value         @ Signed for Expecting Minus Value
			vstr vfp_value, [block_start]
			add block_start, block_start, #4
			vadd.f32 vfp_omega, vfp_omega, vfp_one

			macro32_dsb ip

			b heap32_wave_triangle_loop_quarter

		heap32_wave_triangle_loop_common:
			/* Change Base */
			tst direction, #2                          @ Check Bit[1] of direction
			vaddne.f32 vfp_base, vfp_base, vfp_height  @ If High on Bit[1] of direction, Plus
			vsubeq.f32 vfp_base, vfp_base, vfp_height  @ If Low on Bit[1] of direction, Minus

			vmov vfp_omega, vfp_zero                   @ Reset Omega         

			add block_point, block_point, length       @ Make Next Quarter

			tst direction, #1                          @ Check Bit[0] of direction to Know Whether Half(High) or Quarter(Low) at Each End
			beq heap32_wave_triangle_loop_common_jump
			tstne flag_odd, #1                         @ If Half
			vaddne.f32 vfp_omega, vfp_omega, vfp_one   @ If Odd, Correct Positions
			subne block_point, block_point, #4

			sub direction, direction, #1               @ Make New Direction for Next Quarter
			b heap32_wave_triangle_loop

			heap32_wave_triangle_loop_common_jump:
				tst flag_odd, #2                           @ If Quarter
				vaddne.f32 vfp_omega, vfp_omega, vfp_one   @ If Odd, Correct Positions
				subne block_point, block_point, #4

				sub direction, direction, #1               @ Make New Direction for Next Quarter
				b heap32_wave_triangle_loop

	heap32_wave_triangle_error1:
		mov r0, #1
		b heap32_wave_triangle_common

	heap32_wave_triangle_error2:
		mov r0, #2
		b heap32_wave_triangle_common

	heap32_wave_triangle_success:
		mov r0, #0

	heap32_wave_triangle_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		vpop {s0-s8}
		pop {r4-r9,pc}

.unreq block_start
.unreq length
.unreq height
.unreq medium
.unreq block_point
.unreq block_size
.unreq quarter
.unreq direction 
.unreq flag_odd
.unreq temp
.unreq vfp_omega
.unreq vfp_delta
.unreq vfp_quarter
.unreq vfp_medium
.unreq vfp_height
.unreq vfp_base
.unreq vfp_value
.unreq vfp_one
.unreq vfp_zero


/**
 * function heap32_wave_sin
 * Make Sin Wave on Memory Space
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Wave
 * r1: Length of Wave (32-bit Words, Must Be 5 and More)
 * r2: Height of Wave (Signed 32-bit Integer)
 * r3: Medium of Wave (Signed 32-bit Integer)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0) or Out of Heap Area
 * Error(2): Sizing is Wrong in Memory Space | Length is Less Than 5
 */
.globl heap32_wave_sin
heap32_wave_sin:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	length           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	height           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	medium           .req r3
	block_point      .req r4
	block_size       .req r5
	half             .req r6
	direction        .req r7
	flag_odd         .req r8
	temp             .req r9	

	/* VFP Registers */
	vfp_omega        .req s0 @ d0
	vfp_delta        .req s1
	vfp_half         .req s2 @ d1
	vfp_medium       .req s3
	vfp_height       .req s4
	vfp_value        .req s5
	vfp_one          .req s6
	vfp_zero         .req s7
	vfp_pi           .req s8

	push {r4-r9,lr}
	vpush {s0-s8}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp length, #5                              @ If Less than 5
	blo heap32_wave_sin_error2

	push {r0-r3}
	bl heap32_mcount
	mov block_size, r0
	cmp r0, #-1
	pop {r0-r3}

	beq heap32_wave_sin_error1

	lsl temp, length, #2                        @ Substitution of Multiplication by 4
	cmp temp, block_size
	bhi heap32_wave_sin_error2                  @ If Overflow is Expected

	/* Examine Length to know Odd/Even on Half and Quarter */

	tst length, #1                              @ If Half is Odd
	movne flag_odd, #1
	addne length, length, #1
	moveq flag_odd, #0

	lsr half, length, #1                        @ Substitution of Division by 2

	lsl length, half, #2                        @ Substitution of Multiplication by 4, Words to Bytes

	sub half, half, #1                          @ To Get Delta, Subtract 1

	/* direction: Plus at First Half(1),  Minus at Last Half(0) */

	mov direction, #1                           @ Define Direction to Plus at First Quarter

	/* Preparation for Usage of VFP Registers */

	mov temp, #0
	vmov vfp_zero, temp
	vcvt.f32.u32 vfp_zero, vfp_zero
	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one
	ldr temp, heap32_wave_sin_pi                @ Already Float
	vldr vfp_pi, [temp]

	vmov vfp_half, half
	vmov vfp_medium, medium
	vmov vfp_height, height 

	vcvt.f32.u32 vfp_half, vfp_half
	vcvt.f32.s32 vfp_medium, vfp_medium
	vcvt.f32.s32 vfp_height, vfp_height

	vdiv.f32 vfp_delta, vfp_pi, vfp_half

	vmov vfp_omega, vfp_zero                     @ Reset Omega

	add block_point, block_start, length         @ Make First Quarter

	heap32_wave_sin_loop:
		cmp direction, #-1
		ble heap32_wave_sin_success
		
		heap32_wave_sin_loop_half:
			cmp block_start, block_point
			bhs heap32_wave_sin_loop_common

			vmul.f32 vfp_value, vfp_delta, vfp_omega

			push {r0-r3}
			vmov r0, vfp_value
			bl math32_sin
			vmov vfp_value, r0
			pop {r0-r3}

			tst direction, #1                          @ Check Bit[0] of direction
			vmulne.f32 vfp_value, vfp_height, vfp_value
			vnmuleq.f32 vfp_value, vfp_height, vfp_value

			vadd.f32 vfp_value, vfp_medium, vfp_value

			vcvtr.s32.f32 vfp_value, vfp_value         @ Signed for Expecting Minus Value
			vstr vfp_value, [block_start]
			add block_start, block_start, #4
			vadd.f32 vfp_omega, vfp_omega, vfp_one

			macro32_dsb ip

			b heap32_wave_sin_loop_half

		heap32_wave_sin_loop_common:
			vmov vfp_omega, vfp_zero                   @ Reset Omega         

			add block_point, block_point, length       @ Make Next Quarter

			tst flag_odd, #1
			vaddne.f32 vfp_omega, vfp_omega, vfp_one   @ If Odd, Correct Positions
			subne block_point, block_point, #4

			sub direction, direction, #1               @ Make New Direction for Next Quarter

			b heap32_wave_sin_loop

	heap32_wave_sin_error1:
		mov r0, #1
		b heap32_wave_sin_common

	heap32_wave_sin_error2:
		mov r0, #2
		b heap32_wave_sin_common

	heap32_wave_sin_success:
		mov r0, #0

	heap32_wave_sin_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		vpop {s0-s8}
		pop {r4-r9,pc}

heap32_wave_sin_pi: .word MATH32_PI

.unreq block_start
.unreq length
.unreq height
.unreq medium
.unreq block_point
.unreq block_size
.unreq half
.unreq direction 
.unreq flag_odd
.unreq temp
.unreq vfp_omega
.unreq vfp_delta
.unreq vfp_half
.unreq vfp_medium
.unreq vfp_height
.unreq vfp_value
.unreq vfp_one
.unreq vfp_zero
.unreq vfp_pi
