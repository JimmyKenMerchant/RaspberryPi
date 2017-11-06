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
		pop {r4-r6}
		mov pc, lr

.unreq block_start
.unreq data
.unreq size
.unreq offset
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
 * Error(1): Pointer of Start Address is Null (0)
 * Error(2): Sizing is Wrong in Any Memory Space
 */
.globl heap32_mweave
heap32_mweave:
	/* Auto (Local) Variables, but just Aliases */
	block_start_target .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	block_start_odd    .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	block_start_even   .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	block_size_target  .req r3
	block_size_odd     .req r4
	block_size_even    .req r5
	heap_start         .req r6
	heap_size          .req r7
	temp               .req r8

	push {r4-r8}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start_target, #0
	beq heap32_mweave_error1
	cmp block_start_odd, #0
	beq heap32_mweave_error1
	cmp block_start_even, #0
	beq heap32_mweave_error1

	ldr block_size_target, [block_start_target, #-4]             @ Maximam Size of Allocated Space (Bytes)
	sub block_size_target, block_size_target, #4                 @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	ldr block_size_odd, [block_start_odd, #-4]
	sub block_size_odd, block_size_odd, #4

	ldr block_size_even, [block_start_even, #-4]
	sub block_size_even, block_size_even, #4

	cmp block_size_odd, block_size_even                          @ Check the Same Memory Spaces of Odd and Even
	bne heap32_mweave_error2

	add temp, block_size_odd, block_size_even
	cmp temp, block_size_target                                  @ Check Overflow of Memory Space to Be Wove
	bhi heap32_mweave_error2

	add block_size_target, block_start_target, block_size_target
	add block_size_odd, block_start_odd, block_size_odd
	add block_size_even, block_start_even, block_size_even

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                                   @ Maximam Size of Heap Overall (Bytes)
	add heap_size, heap_start, heap_size

	cmp block_size_target, heap_size        @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bhi heap32_mweave_error2                @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size

	cmp block_size_odd, heap_size
	bhi heap32_mweave_error2

	cmp block_size_even, heap_size
	bhi heap32_mweave_error2

	cmp block_start_target, heap_start
	blo heap32_mweave_error2

	cmp block_start_odd, heap_start
	blo heap32_mweave_error2

	cmp block_start_even, heap_start
	blo heap32_mweave_error2

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
		pop {r4-r8}
		mov pc, lr

.unreq block_start_target
.unreq block_start_odd
.unreq block_start_even
.unreq block_size_target
.unreq block_size_odd
.unreq block_size_even
.unreq heap_start
.unreq heap_size
.unreq temp


/**
 * function heap32_wave_square
 * Make Square Wave on Memory Space
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Triangle Wave
 * r1: Length of Wave (32-bit Words, Must Be 2 and More)
 * r2: Height of Wave (32-bit)
 * r3: Medium of Wave (32-bit)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0)
 * Error(2): Sizing is Wrong in Memory Space | Length is Less Than 2
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
	heap_start       .req r6
	heap_size        .req r7
	flag_odd         .req r8
	temp             .req r9	

	push {r4-r9}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq heap32_wave_square_error1

	ldr block_size, [block_start, #-4]          @ Maximam Size of Allocated Space (Bytes)
	sub block_size, block_size, #4              @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	lsl temp, length, #2                        @ Substitution of Multiplication by 2
	cmp temp, block_size
	bhi heap32_wave_square_error2               @ If Overflow is Expected

	add block_size, block_start, block_size

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ Maximam Size of Heap Overall (Bytes)
	add heap_size, heap_start, heap_size

	cmp block_size, heap_size                   @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bhi heap32_wave_square_error2               @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size
	cmp block_start, heap_start
	blo heap32_wave_square_error2

	.unreq heap_start
	.unreq heap_size
	half      .req r6
	direction .req r7

	cmp length, #2                              @ If Not 2 and More
	blo heap32_wave_square_error2

	/* Examine Length to know Odd/Even on Half and Quarter */

	tst length, #1                              @ If Half is Odd
	movne flag_odd, #1
	addne length, length, #1
	moveq flag_odd, #0

	lsr half, length, #1                        @ Substitution of Division by 2

	lsl length, half, #2                        @ Substitution of Multiplication by 4, Reassume Length to Be Corrected

	/* direction: Plus at First Half(0), Last half (-1) */

	mov direction, #0                           @ Define Direction to Plus at First Quarter

	add block_point, block_start, length        @ Make First Quarter

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

			b heap32_wave_square_loop_half

		heap32_wave_square_loop_common:

			add block_point, block_point, length       @ Make New Quarter

			tst flag_odd, #1
			subne block_point, block_point, #4         @ If Odd

			sub direction, direction, #1               @ Make New Direction for New Quarter

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
		pop {r4-r9}
		mov pc, lr

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
 * Make Random Wave on Memory Space
 * Caution! The Value of Addition of Height and Medium Must Be Within 16-bit (0-65535)
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Triangle Wave
 * r1: Length of Wave (32-bit Words, Must Be 2 and More)
 * r2: Height of Wave (32-bit)
 * r3: Medium of Wave (32-bit)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0)
 * Error(2): Sizing is Wrong in Memory Space | Length is Less Than 2
 */
.globl heap32_wave_random
heap32_wave_random:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	length           .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	height           .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	medium           .req r3
	block_point      .req r4
	block_size       .req r5
	heap_start       .req r6
	heap_size        .req r7
	flag_odd         .req r8
	temp             .req r9
	temp2            .req r10
	random_digit     .req r11	

	push {r4-r11}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq heap32_wave_random_error1

	ldr block_size, [block_start, #-4]          @ Maximam Size of Allocated Space (Bytes)
	sub block_size, block_size, #4              @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	lsl temp, length, #2                        @ Substitution of Multiplication by 2
	cmp temp, block_size
	bhi heap32_wave_random_error2               @ If Overflow is Expected

	add block_size, block_start, block_size

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ Maximam Size of Heap Overall (Bytes)
	add heap_size, heap_start, heap_size

	cmp block_size, heap_size                   @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bhi heap32_wave_random_error2               @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size
	cmp block_start, heap_start
	blo heap32_wave_random_error2

	.unreq heap_start
	.unreq heap_size
	half      .req r6
	direction .req r7

	cmp length, #2                              @ If Not 2 and More
	blo heap32_wave_random_error2

	/* Examine Length to know Odd/Even on Half and Quarter */

	tst length, #1                              @ If Half is Odd
	movne flag_odd, #1
	addne length, length, #1
	moveq flag_odd, #0

	lsr half, length, #1                        @ Substitution of Division by 2

	lsl length, half, #2                        @ Substitution of Multiplication by 4, Reassume Length to Be Corrected

	/* direction: Plus at First Half(0), Last half (-1) */

	mov direction, #0                           @ Define Direction to Plus at First Quarter

	add block_point, block_start, length        @ Make First Quarter

	heap32_wave_random_loop:
		cmp direction, #-1
		blt heap32_wave_random_success
		cmp direction, #0
		addeq temp, medium, height
		subne temp, medium, height

		cmp temp, #0x100                       @ 8-bit or 16-bit
		movhs random_digit, #1                 @ 16-bit
		movlo random_digit, #0                 @ 8-bit
		
		heap32_wave_random_loop_half:
			cmp block_start, block_point
			bhs heap32_wave_random_loop_common

			cmp random_digit, #1
			movhs temp2, #255
			movlo temp2, temp

			push {r0-r3,lr}
			mov r0, #0
			mov r1, temp2
			bl arm32_random
			mov temp2, r0
			pop {r0-r3,lr}

			cmp random_digit, #1
			blo heap32_wave_random_loop_half_jump

			lsr temp2, temp, #8

			push {r0-r3,lr}
			mov r0, #0
			mov r1, temp2
			bl arm32_random
			lsl r0, r0, #8
			add temp2, temp2, r0
			pop {r0-r3,lr}

			heap32_wave_random_loop_half_jump:
				str temp2, [block_start]
				add block_start, block_start, #4

				b heap32_wave_random_loop_half

		heap32_wave_random_loop_common:

			add block_point, block_point, length       @ Make New Quarter

			tst flag_odd, #1
			subne block_point, block_point, #4         @ If Odd

			sub direction, direction, #1               @ Make New Direction for New Quarter

			b heap32_wave_random_loop

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
		pop {r4-r11}
		mov pc, lr

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
.unreq temp2
.unreq random_digit


/**
 * function heap32_wave_triangle
 * Make Triangle Wave on Memory Space
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Parameters
 * r0: Pointer of Start Address of Memory Space to be Made Triangle Wave
 * r1: Length of Wave (32-bit Words, Must Be 5 and More)
 * r2: Height of Wave (32-bit)
 * r3: Medium of Wave (32-bit)
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Pointer of Start Address is Null (0)
 * Error(2): Sizing is Wrong in Memory Space | Length is Less Than 5
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
	heap_start       .req r6
	heap_size        .req r7
	flag_odd         .req r8
	temp             .req r9	

	vfp_omega        .req s0 @ d0
	vfp_delta        .req s1
	vfp_quarter      .req s2 @ d1
	vfp_medium       .req s3
	vfp_height       .req s4
	vfp_base         .req s5
	vfp_value        .req s6
	vfp_one          .req s7

	push {r4-r9}
	vpush {s0-s7}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq heap32_wave_triangle_error1

	ldr block_size, [block_start, #-4]          @ Maximam Size of Allocated Space (Bytes)
	sub block_size, block_size, #4              @ Slide Minus 4 Bytes for Size Indicator of Memory Space

	lsl temp, length, #2                        @ Substitution of Multiplication by 2
	cmp temp, block_size
	bhi heap32_wave_triangle_error2             @ If Overflow is Expected

	add block_size, block_start, block_size

	ldr heap_start, HEAP32_ADDR
	ldr heap_size, HEAP32_SIZE                  @ Maximam Size of Heap Overall (Bytes)
	add heap_size, heap_start, heap_size

	cmp block_size, heap_size                   @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bhi heap32_wave_triangle_error2             @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size
	cmp block_start, heap_start
	blo heap32_wave_triangle_error2

	.unreq heap_start
	.unreq heap_size
	quarter   .req r5
	direction .req r6

	cmp length, #5                              @ If Not 5 and More
	blo heap32_wave_triangle_error2

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
	lsl length, quarter, #2                     @ Substitution of Multiplication by 4, Reassume Length to Be Corrected

	sub quarter, quarter, #1                    @ To Get Delta, Subtract 1

	/* direction: Plus at First Quarter(2), Minus at Second Quarter(1), Minus at Third Quarter(0), Plus at Fourth Quarter(-1) */

	mov direction, #2                           @ Define Direction to Plus at First Quarter

	/* Preparation for Usage of VFP Registers */

	mov temp, #0
	vmov vfp_omega, temp
	vcvt.f32.u32 vfp_omega, vfp_omega
	mov temp, #1
	vmov vfp_one, temp
	vcvt.f32.u32 vfp_one, vfp_one

	vmov vfp_quarter, quarter
	vmov vfp_medium, medium
	vmov vfp_height, height

	vcvt.f32.u32 vfp_quarter, vfp_quarter
	vcvt.f32.u32 vfp_medium, vfp_medium
	vcvt.f32.u32 vfp_height, vfp_height

	vdiv.f32 vfp_delta, vfp_height, vfp_quarter

	vmov vfp_base, vfp_medium                   @ Base of First Quarter

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

			vcvt.u32.f32 vfp_value, vfp_value
			vmov temp, vfp_value
			str temp, [block_start]
			add block_start, block_start, #4
			vadd.f32 vfp_omega, vfp_omega, vfp_one

			b heap32_wave_triangle_loop_quarter

		heap32_wave_triangle_loop_common:
			/* Change Base */
			tst direction, #2                          @ Check Bit[1] of direction
			vaddne.f32 vfp_base, vfp_base, vfp_height  @ If High on Bit[1] of direction, Plus
			vsubeq.f32 vfp_base, vfp_base, vfp_height  @ If Low on Bit[1] of direction, Minus

			mov temp, #0
			vmov vfp_omega, temp
			vcvt.f32.u32 vfp_omega, vfp_omega          @ Reset Omega

			add block_point, block_point, length       @ Make New Quarter

			tst direction, #1                          @ Check Bit[0] of direction to Know Whether Half(High) or Quarter(Low)
			tstne flag_odd, #1                         @ If Half
			tsteq flag_odd, #2                         @ If Quarter
			subne block_start, block_start, #4         @ If Odd, Correct Positions
			subne block_point, block_point, #4

			sub direction, direction, #1               @ Make New Direction for New Quarter

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
		pop {r4-r9}
		vpop {s0-s7}
		mov pc, lr

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
