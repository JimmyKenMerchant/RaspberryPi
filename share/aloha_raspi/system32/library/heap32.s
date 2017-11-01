/**
 * heap32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.globl HEAP32_ADDR
.globl HEAP32_SIZE
HEAP32_ADDR:         .word SYSTEM32_HEAP
HEAP32_SIZE:         .word SYSTEM32_HEAP_END - SYSTEM32_HEAP

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

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                @ In Bytes

	macro32_dsb ip                            @ Ensure Completion of Instructions Before

	add heap_size, heap_start, heap_size

	mov heap_bytes, #0

	heap32_clear_heap_loop1:
		cmp heap_start, heap_size
		bhs heap32_clear_heap_common      @ If Heap Space Overflow

		str heap_bytes, [heap_start]

		add heap_start, heap_start, #4
		b heap32_clear_heap_loop1         @ If Bytes are not Zero

	heap32_clear_heap_common:
		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		mov r0, #0
		mov pc, lr

.unreq heap_start
.unreq heap_size
.unreq heap_bytes


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
	size           .req r0 @ Parameter, Register for Argument and Result, Scratch Register, Block (4 Bytes) Size
	heap_start     .req r1
	heap_size      .req r2
	heap_bytes     .req r3
	check_start    .req r4
	check_size     .req r5

	push {r4-r5}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	lsl size, size, #2                          @ Substitution of Multiplication by 4, Words to Bytes

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ In Bytes

	add heap_size, heap_start, heap_size

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
 * function heap32_mfree
 * Free Memory Space in Heap
 * Allocated Memory Size is Stored from the Address where Start Address of Memory Minus 4 Bytes
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 *
 * Usage: r0-r4
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Pointer of Start Address is Null (0)
 */
.globl heap32_mfree
heap32_mfree:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	block_size       .req r1
	heap_start       .req r2
	heap_size        .req r3
	zero             .req r4

	push {r4}

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
		pop {r4}
		mov pc, lr

.unreq block_start
.unreq block_size
.unreq zero
.unreq heap_start
.unreq heap_size


/**
 * function heap32_mcopy
 * Copy Value in Memory
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to Be Destination
 * r1: Pointer of Start Address of Memory Space to Be Copied (Source)
 * r2: Offset of Bytes to Be Copied (Source)
 * r3: Size of Bytes to Be Copied (Source)
 *
 * Return: r0 (Pointer of Start Address of Memory Space to Be Destination, If 0, No Enough Space to Copy to First Argument)
 */
.globl heap32_mcopy
heap32_mcopy:
	/* Auto (Local) Variables, but just Aliases */
	heap1        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	heap2        .req r1 @ Parameter, Register for Argument
	offset       .req r2 @ Parameter, Register for Argument
	size         .req r3 @ Parameter, Register for Argument
	heap1_size   .req r4
	heap2_size   .req r5
	byte         .req r6
	heap_start   .req r7
	heap_size    .req r8
	heap1_dup    .req r9

	push {r4-r9}

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

	add heap2, heap2, offset

	heap32_mcopy_loop:
		cmp heap1, heap1_size
		bhs heap32_mcopy_error
		cmp heap2, heap2_size
		bhs heap32_mcopy_error

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
		pop {r4-r9}
		mov pc, lr

.unreq heap1
.unreq heap2
.unreq offset
.unreq size
.unreq heap1_size
.unreq heap2_size
.unreq byte
.unreq heap_start
.unreq heap_size
.unreq heap1_dup


/**
 * function heap32_mfill
 * Fill Memory Space by Random Value
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space
 * r1: Data to be Filled to Memory Space (Word = 4 Byte)
 * r2: Size to be Filled (Words = 4 Bytes)
 * r3: Offset from Start Address (Words = 4 Bytes)
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Pointer of Start Address is Null (0)
 */
.globl heap32_mfill
heap32_mfill:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	data             .req r1
	size             .req r2
	offset           .req r3
	block_size       .req r4
	heap_start       .req r5
	block_max        .req r6

	push {r4-r6}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq heap32_mfill_error

	ldr block_max, [block_start, #-4]           @ Maximam Size of Allocated Space (Bytes)
	add block_max, block_start, block_max
	sub block_max, block_max, #4                @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	lsl size, size, #2                          @ Substitution of Multiplication by 4, Words to Bytes
	lsl offset, offset, #2                      @ Substitution of Multiplication by 4, Words to Bytes
	add block_start, block_start, offset        @ Ordered Start Address
	add block_size, block_start, size           @ Ordered Size

	cmp block_size, block_max                   @ Compare Ordered Size and Maximam Size of Allocated Space
	bhi heap32_mfill_error

	.unreq block_max
	heap_size .req r6

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
.unreq size
.unreq offset
.unreq block_size
.unreq heap_start
.unreq heap_size
