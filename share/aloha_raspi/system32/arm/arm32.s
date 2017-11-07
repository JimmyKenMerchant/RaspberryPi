/**
 * arm32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Definition Only in ARMv7/AArch32 */
.ifndef __ARMV6

/**
 * function arm32_core_call
 * Call Cores
 * Need of SMP is on, and Cache is Inner Shareable.
 * Caution! This Function is compatible from ARMv7/AArch32
 *
 * Parameters
 * r0: Pointer of Heap
 * r1: Number of Core
 *
 * Usage: r0-r2
 * Return: r0 (0 as success, 1 as error), 
 * Error: Number of Core is Not Valid
 */
.globl arm32_core_call
arm32_core_call:
	/* Auto (Local) Variables, but just Aliases */
	heap         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	number_core  .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	handle_addr  .req r2

	and number_core, number_core, #0b11      @ Prevet Memory Overflow

	cmp number_core, #3                      @ 0 <= number_core <= 3
	bgt arm32_core_call_error
	cmp number_core, #0
	blt arm32_core_call_error

	lsl number_core, number_core, #2         @ Substitution of Multiplication by 4

	ldr handle_addr, ARM32_CORE_HANDLE_BASE
	add handle_addr, handle_addr, number_core

	macro32_dsb ip @ Stronger than `dmb`, `dsb` stops all instructions, including instructions with no memory access

	str heap, [handle_addr]

	macro32_dsb ip

	b arm32_core_call_success

	arm32_core_call_error:
		mov r0, #1
		b arm32_core_call_common

	arm32_core_call_success:
		mov r0, #0

	arm32_core_call_common:
		mov pc, lr

.unreq heap
.unreq number_core
.unreq handle_addr 


/**
 * function arm32_core_handle
 * Execute Function with Arguments in Core
 * Need of SMP is on, and Cache is Inner Shareable.
 * Caution! This Function is compatible from ARMv7/AArch32
 *
 * This Function Uses Heap.
 * First of Heap Array is Pointer of Function.
 * Second of Heap Array is Number of Arguments.
 * Third and More of Heap Array are Arguments of Function.
 *
 * Return Value Will Be Stored to Heap.
 *
 * When Function is Finished, ARM32_CORE_HANDLE_n Will Be Zero to Indicate Finishing.
 *
 * Usage: r0-r9
 * Return: r0 (0 as success)
 */
.globl arm32_core_handle
arm32_core_handle:
	/* Auto (Local) Variables, but just Aliases */
	number_core  .req r0
	arg1         .req r1
	arg2         .req r2
	arg3         .req r3
	handle_addr  .req r4
	heap         .req r5
	addr_start   .req r6
	num_arg      .req r7
	dup_num_arg  .req r8
	temp         .req r9

	push {r4-r9}

	macro32_multicore_id number_core

	lsl number_core, number_core, #2         @ Substitution of Multiplication by 4

	ldr handle_addr, ARM32_CORE_HANDLE_BASE
	add handle_addr, handle_addr, number_core

	.unreq number_core
	arg0 .req r0

	macro32_dsb ip @ Stronger than `dmb`, `dsb` stops all instructions, including instructions with no memory access

	arm32_core_handle_loop1:
		ldr heap, [handle_addr]
		cmp heap, #0
		beq arm32_core_handle_loop1

	ldr addr_start, [heap]
	ldr num_arg, [heap, #4]

	mov dup_num_arg, #0

	push {r0-r3,lr}

	cmp num_arg, #0
	beq arm32_core_handle_branch
	cmp num_arg, #1
	ldrge arg0, [heap, #8]
	beq arm32_core_handle_branch
	cmp num_arg, #2
	ldrge arg1, [heap, #12]
	beq arm32_core_handle_branch
	cmp num_arg, #3
	ldrge arg2, [heap, #16]
	beq arm32_core_handle_branch
	cmp num_arg, #4
	ldrge arg3, [heap, #20]
	beq arm32_core_handle_branch

	mov dup_num_arg, num_arg
	sub dup_num_arg, dup_num_arg, #4                         @ For Offset of SP Afterward
	lsl dup_num_arg, dup_num_arg, #2                         @ Substitution of Multiplication by 4

	lsl num_arg, num_arg, #2                                 @ Substitution of Multiplication by 4
	add num_arg, num_arg, #4

	arm32_core_handle_loop2:
		cmp num_arg, #20
		ble arm32_core_handle_branch
		ldr temp, [heap, num_arg]
		push {temp}
		sub num_arg, num_arg, #4
		b arm32_core_handle_loop2

	arm32_core_handle_branch:
		macro32_dsb ip
		blx addr_start
		macro32_dsb ip
		str r0, [heap]                                @ Return Value r0
		str r1, [heap, #4]                            @ Return Value r1
		add sp, sp, dup_num_arg                       @ Offset SP
		pop {r0-r3,lr}
		
		mov temp, #0
		str temp, [handle_addr]                       @ Indicate End of Function by Zero to 1st of Array for Polling on Another Core

		mov r0, #0

	arm32_core_handle_common:
		macro32_dsb ip
		pop {r4-r9}
		mov pc, lr

.unreq arg0
.unreq arg1
.unreq arg2
.unreq arg3
.unreq handle_addr
.unreq heap
.unreq addr_start
.unreq num_arg
.unreq dup_num_arg
.unreq temp

ARM32_CORE_HANDLE_BASE:      .word ARM32_CORE_HANDLE_0
.globl ARM32_CORE_HANDLE_0
.globl ARM32_CORE_HANDLE_1
.globl ARM32_CORE_HANDLE_2
.globl ARM32_CORE_HANDLE_3
ARM32_CORE_HANDLE_0:         .word 0x00
ARM32_CORE_HANDLE_1:         .word 0x00
ARM32_CORE_HANDLE_2:         .word 0x00
ARM32_CORE_HANDLE_3:         .word 0x00


/**
 * function arm32_cache_operation_all
 * Cache Operation to All Cache
 * Caution! This Function is compatible from ARMv7/AArch32
 *
 * Parameters
 * r0: Cache Level, 1/2
 * r1: Flag, 0(Invalidate)/1(Clean)/2(Clean and Invalidate)
 *
 * Usage: r4-r11
 * Return: r0 (Last Value of Set/Way Format)
 */
.globl arm32_cache_operation_all
arm32_cache_operation_all:
	/* Auto (Local) Variables, but just Aliases */
	level        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	flag         .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	set_bit      .req r2
	temp         .req r3
	bit_mask     .req r4
	line_shift   .req r5
	way_size     .req r6
	way_size_dup .req r7
	set_size     .req r8
	cache_info   .req r9
	setlevel     .req r10
	waysetlevel  .req r11

	push {r4-r11}

	sub level, level, #1
	lsl level, level, #1                     @ Set Level Bit [3:1], 0b0 is Level 1

	push {r0-r3,lr}
	mov r0, level
	bl arm32_cache_info
	mov cache_info, r0
	pop {r0-r3,lr}

	mov line_shift, cache_info
	and line_shift, line_shift, #0b111       @ Mask for Line Size Bit[2:0]
	add line_shift, line_shift, #4           @ Get Index Mask Shift (Offset #4)
	
	mov bit_mask, #0xFF
	add bit_mask, bit_mask, #0x300
	lsl bit_mask, bit_mask, #3
	and bit_mask, cache_info, bit_mask
	lsr way_size, bit_mask, #3               @ Get Way Size - 1 Bit[12:3]

	mov bit_mask, #0xFF
	add bit_mask, bit_mask, #0x7F00
	lsl bit_mask, bit_mask, #13
	and bit_mask, cache_info, bit_mask
	lsr set_size, bit_mask, #13              @ Get Set Size - 1 Bit[27:13]

	clz temp, way_size                       @ Determine Start Bit of Way, Changed by Leading Zeros

	arm32_cache_operation_all_loop:
		cmp set_size, #0
		blt arm32_cache_operation_all_success
		lsl set_bit, set_size, line_shift        @ Set Set Bit[*:4 + LineSize]
		
		add setlevel, set_bit, level
		mov way_size_dup, way_size

		arm32_cache_operation_all_loop_way:
			cmp way_size_dup, #0
			blt arm32_cache_operation_all_loop_common
			lsl bit_mask, way_size_dup, temp         @ Set Way Bit[31:*]
			add waysetlevel, setlevel, bit_mask
			cmp flag, #0
			mcreq p15, 0, waysetlevel, c7, c6, 2     @ Invalidate Data (L1) or Unified (L2) Cache
			cmp flag, #1
			mcreq p15, 0, waysetlevel, c7, c10, 2    @ Clean Data (L1) or Unified (L2) Cache 
			cmp flag, #2
			mcreq p15, 0, waysetlevel, c7, c14, 2    @ Clean and Invalidate Data (L1) or Unified (L2) Cache
			sub way_size_dup, way_size_dup, #1
			b arm32_cache_operation_all_loop_way

		arm32_cache_operation_all_loop_common:
			sub set_size, set_size, #1
			b arm32_cache_operation_all_loop

	arm32_cache_operation_all_success:
		mov r0, waysetlevel 

	arm32_cache_operation_all_common:
		macro32_dsb ip
		pop {r4-r11}
		mov pc, lr

.unreq level
.unreq flag
.unreq set_bit
.unreq temp
.unreq bit_mask
.unreq line_shift
.unreq way_size
.unreq way_size_dup
.unreq set_size
.unreq cache_info
.unreq setlevel
.unreq waysetlevel


/**
 * function arm32_cache_operation
 * Invalidate and Clean Cache by Physical Address
 * Caution! This Function is compatible from ARMv7/AArch32
 *
 * In ARM, Data Cache System is Controled with MMU, Virtual Address.
 * Besides, Indexing Line Set by Address is Using Common Part Between Physical/Vitual.
 * This Idea seems to Be Good, But, Bits of Line Set May Overflow to Part of Virtual Address,
 * If Number of Sets is Large, or LineSize is Large.
 * But in Official Document, Data Cache is described as "Physically Indexed, Physically Tagged". 
 *
 * Parameters
 * r0: Physical Address to Be Cleand and Invalidated
 * r1: Cache Level, 1/2
 * r2: Flag, 0(Invalidate)/1(Clean)/2(Clean and Invalidate)
 *
 * Usage: r4-r9
 * Return: r0 (Last Value of Set/Way Format)
 */
.globl arm32_cache_operation
arm32_cache_operation:
	/* Auto (Local) Variables, but just Aliases */
	p_address   .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	level       .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	flag        .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	temp        .req r3
	bit_mask    .req r4
	line_shift  .req r5
	way_size    .req r6
	set_size    .req r7
	cache_info  .req r8
	setlevel    .req r9
	waysetlevel .req r10

	push {r4-r10}

	sub level, level, #1
	lsl level, level, #1                     @ Set Level Bit [3:1], 0b0 is Level 1

	push {r0-r3,lr}
	mov r0, level
	bl arm32_cache_info
	mov cache_info, r0
	pop {r0-r3,lr}

	mov line_shift, cache_info
	and line_shift, line_shift, #0b111       @ Mask for Line Size Bit[2:0]
	add line_shift, line_shift, #4           @ Get Index Mask Shift (Offset #4)
	
	mov bit_mask, #0xFF
	add bit_mask, bit_mask, #0x300
	lsl bit_mask, bit_mask, #3
	and bit_mask, cache_info, bit_mask
	lsr way_size, bit_mask, #3               @ Get Way Size - 1 Bit[12:3]

	mov bit_mask, #0xFF
	add bit_mask, bit_mask, #0x7F00
	lsl bit_mask, bit_mask, #13
	and bit_mask, cache_info, bit_mask
	lsr set_size, bit_mask, #13              @ Get Set Size - 1 Bit[27:13]

	mov bit_mask, set_size
	lsl bit_mask, bit_mask, line_shift
	and p_address, p_address, bit_mask       @ Set Set Bit[*:4 + LineSize]
	.unreq p_address
	set_bit .req r0
	
	add setlevel, set_bit, level

	clz temp, way_size                       @ Determine Start Bit of Way, Changed by Leading Zeros

	arm32_cache_operation_loop:
		cmp way_size, #0
		blt arm32_cache_operation_success
		lsl bit_mask, way_size, temp             @ Set Way Bit[31:*]
		add waysetlevel, setlevel, bit_mask
		cmp flag, #0
		mcreq p15, 0, waysetlevel, c7, c6, 2     @ Invalidate Data (L1) or Unified (L2) Cache
		cmp flag, #1
		mcreq p15, 0, waysetlevel, c7, c10, 2    @ Clean Data (L1) or Unified (L2) Cache 
		cmp flag, #2
		mcreq p15, 0, waysetlevel, c7, c14, 2    @ Clean and Invalidate Data (L1) or Unified (L2) Cache
		sub way_size, way_size, #1
		b arm32_cache_operation_loop

	arm32_cache_operation_success:
		mov r0, waysetlevel

	arm32_cache_operation_common:
		macro32_dsb ip
		pop {r4-r10}
		mov pc, lr

.unreq set_bit
.unreq level
.unreq flag
.unreq temp
.unreq bit_mask
.unreq line_shift
.unreq way_size
.unreq set_size
.unreq cache_info
.unreq setlevel
.unreq waysetlevel


/**
 * function arm32_cache_info
 * Return Particular Cache Information
 * Caution! This Function is compatible from ARMv7/AArch32
 *
 * Parameters
 * r0: Content of Cache Size Slection Register (CSSELR) for CCSIDR
 *
 * Usage: r0
 * Return: r0 (Value of CCSIDR)
 */
.globl arm32_cache_info
arm32_cache_info:
	/* Auto (Local) Variables, but just Aliases */
	ccselr       .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/**
	 * Cache Size Slection Register (CSSELR) for CCSIDR
	 * Bit[0] is 0 (Data or Unified Cache)/ 1 (Instruction Cache)
	 * Bit[3:1] is 0b000 (Level1)/ 0b001(Level2), Other Bits are Reserved
	 */
	mcr p15, 2, ccselr, c0, c0, 0

	.unreq ccselr
	ccsidr .req r0

	/**
	 * Cache Size Identification Register (CCSIDR)
	 * Bit[2:0] LineSize, (log2(Number of Words)) - 2, e.g., 0b001 is 8 words per line, 0b010 is 16 words per line
	 * Bit[12:3] Associativity, Way - 1, e.g., 0b0000000001 is 2-ways, 0b0000000011 is 4-ways
	 * Bit[27:13] Number of Sets -1, e.g., 0 is 1 set (Line per Way)
	 * Bit[28] Write-Allocation(WA)
	 * Bit[29] Read-Allocation(RA)
	 * Bit[30] Write-Back
	 * Bit[31] Write-Through
	 *
	 * Index of the set will be Determined by Bit[*:4 + LineSize] of the Address, the length is Number of Sets
	 */
	mrc p15, 1, ccsidr, c0, c0, 0

	arm32_cache_info_common:
		mov pc, lr

.unreq ccsidr


/* End of Definition Only in ARMv7/AArch32 */
.endif


/**
 * function arm32_cache_operation_heap
 * Invalidate and Clean Cache by MVA Address in an Allocated Heap
 * Caution! This function is relevant to library/heap32.s
 *
 * Parameters
 * r0: Pointer of Heap Block Allocated
 * r1: Flag, 0(Invalidate)/1(Clean)/2(Clean and Invalidate)
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Pointer of Start Address is Null (0)
 */
.globl arm32_cache_operation_heap
arm32_cache_operation_heap:
	/* Auto (Local) Variables, but just Aliases */
	block_start .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	flag        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	block_size  .req r2

	cmp block_start, #0
	beq arm32_cache_operation_heap_error

	ldr block_size, [block_start, #-4]
	add block_size, block_start, block_size

	bic block_start, block_start, #0x1F
	bic block_size, block_size, #0x1F

	arm32_cache_operation_heap_loop:
		cmp block_start, block_size
		bgt arm32_cache_operation_heap_success

		cmp flag, #0
		mcreq p15, 0, block_start, c7, c6, 1     @ Invalidate Data Cache
		cmp flag, #1
		mcreq p15, 0, block_start, c7, c10, 1    @ Clean Data Cache
		cmp flag, #2
		mcreq p15, 0, block_start, c7, c14, 1    @ Clean and Invalidate Data Cache

		add block_start, block_start, #0x20      @ 32 Bytes (4 Words) Align
		b arm32_cache_operation_heap_loop

	arm32_cache_operation_heap_error:
		mov r0, #1
		b arm32_cache_operation_heap_common

	arm32_cache_operation_heap_success:
		mov r0, #0

	arm32_cache_operation_heap_common:
		mov pc, lr

.unreq block_start
.unreq flag
.unreq block_size


/**
 * function arm32_convert_endianness
 * Convert Endianness
 *
 * Parameters
 * r0: Pointer of Data to Convert Endianness
 * r1: Size of Data
 * r2: Align Bytes to Be Convert Endianness (2/4) 
 *
 * Usage: r0-r7
 * Return: r0 (0 as success, 1 as error)
 * Error: Align Bytes is not 2/4
 */
.globl arm32_convert_endianness
arm32_convert_endianness:
	/* Auto (Local) Variables, but just Aliases */
	data_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	size            .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	align_bytes     .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	swap_1          .req r3
	swap_2          .req r4
	convert_result  .req r5
	i               .req r6
	j               .req r7

	push {r4-r7}

	cmp align_bytes, #4
	cmpne align_bytes, #2
	bne arm32_convert_endianness_error

	add size, size, data_point

	arm32_convert_endianness_loop:
		cmp data_point, size
		bge arm32_convert_endianness_success

		cmp align_bytes, #4
		ldreq swap_1, [data_point]
		cmp align_bytes, #2
		ldreqh swap_1, [data_point]

		mov convert_result, #0

		mov i, #0
		cmp align_bytes, #4
		moveq j, #24
		cmp align_bytes, #2
		moveq j, #8

		arm32_convert_endianness_loop_byte:
			cmp j, #0
			blt arm32_convert_endianness_loop_byte_common

			lsr swap_2, swap_1, i
			and swap_2, swap_2, #0xFF
			lsl swap_2, swap_2, j
			add convert_result, convert_result, swap_2
			add i, i, #8
			sub j, j, #8

			b arm32_convert_endianness_loop_byte

			arm32_convert_endianness_loop_byte_common:
				cmp align_bytes, #4
				streq convert_result, [data_point]
				addeq data_point, data_point, #4
				cmp align_bytes, #2
				streqh convert_result, [data_point]
				addeq data_point, data_point, #2

				b arm32_convert_endianness_loop

	arm32_convert_endianness_error:
		mov r0, #1
		b arm32_convert_endianness_common

	arm32_convert_endianness_success:
		mov r0, #0

	arm32_convert_endianness_common:
		pop {r4-r7}
		mov pc, lr

.unreq data_point
.unreq size
.unreq align_bytes
.unreq swap_1
.unreq swap_2
.unreq convert_result
.unreq i
.unreq j


/**
 * function arm32_sleep
 * Sleep in Micro Seconds
 *
 * Parameters
 * r0: Micro Seconds to Sleep
 *
 * Usage: r0-r5
 */
.globl arm32_sleep
arm32_sleep:
	/* Auto (Local) Variables, but just Aliases */
	usecond        .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	memorymap_base .req r1
	count_low      .req r2
	count_high     .req r3
	time_low       .req r4
	time_high      .req r5

	push {r4-r5}
	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_systemtimer_base
	ldr count_low, [memorymap_base, #equ32_systemtimer_counter_lower]   @ Get Lower 32 Bits
	ldr count_high, [memorymap_base, #equ32_systemtimer_counter_higher] @ Get Higher 32 Bits
	adds count_low, usecond                                             @ Add with Changing Status Flags
	adc count_high, #0                                                  @ Add with Carry Flag

	arm32_sleep_loop:
		ldr time_low, [memorymap_base, #equ32_systemtimer_counter_lower] @ In Case of Interrupt, Load Lower Bits First
		ldr time_high, [memorymap_base, #equ32_systemtimer_counter_higher]
		cmp count_high, time_high                                   @ Similar to `SUBS`, Compare Higher 32 Bits
		cmple count_low, time_low                                   @ Compare Lower 32 Bits
		bgt arm32_sleep_loop

	arm32_sleep_common:
		pop {r4-r5}
		mov pc, lr

.unreq usecond
.unreq memorymap_base
.unreq count_low
.unreq count_high
.unreq time_low
.unreq time_high


/**
 * function arm32_no_op
 * Do Nothing
 */
.globl arm32_no_op
arm32_no_op:
	mov r0, r0
	mov pc, lr


/**
 * function arm32_store_32
 * Store 32-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl arm32_store_32
arm32_store_32:
	str r1, [r0]
	mov pc, lr


/**
 * function arm32_store_16
 * Store 16-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl arm32_store_16
arm32_store_16:
	strh r1, [r0]
	mov pc, lr


/**
 * function arm32_store_8
 * Store 8-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl arm32_store_8
arm32_store_8:
	strb r1, [r0]
	mov pc, lr


/**
 * function arm32_load_32
 * Load 32-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl arm32_load_32
arm32_load_32:
	ldr r0, [r0]
	mov pc, lr


/**
 * function arm32_load_16
 * Load 16-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl arm32_load_16
arm32_load_16:
	ldrh r0, [r0]
	mov pc, lr


/**
 * function arm32_load_8
 * Load 8-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl arm32_load_8
arm32_load_8:
	ldrb r0, [r0]
	mov pc, lr


/**
 * function arm32_change_descriptor
 * Activate Virtual Address
 *
 * Parameters
 * r0: 0 is for Secure state, 1 is for Non-secure state, 2 is for Hyp mode (Reserved)
 * r1: Address, 1M Offset
 * r2: Descriptor
 *
 * Usage: r0-r5
 * Return: r0 (0 as success, 1 as error)
 */
.globl arm32_change_descriptor
arm32_change_descriptor:
	/* Auto (Local) Variables, but just Aliases */
	non_secure  .req r0
	addr        .req r1
	desc        .req r2
	number_core .req r3
	mul_number  .req r4
	base_addr   .req r5

	push {r4,r5}

	macro32_multicore_id number_core

	ldr base_addr, ARM32_VADESCRIPTOR_ADDR
	mov mul_number, #0x10000
	mul number_core, number_core, mul_number        @ 0x10000, 65536 Bytes Offset
	add base_addr, base_addr, number_core
	mov mul_number, #0x4000
	mul non_secure, non_secure, mul_number          @ 0x4000, 16384 Bytes Offset
	add base_addr, base_addr, non_secure

	.unreq number_core
	temp .req r3

	lsr addr, #20                                   @ Virtual to Physical Part in Level 1 Translation, Bit[31:20]
	lsl addr, #2                                    @ Substitution of Multiplication by 4

	add base_addr, base_addr, addr

	str desc, [base_addr]

	macro32_dsb ip                                  @ Ensure Completion of Instructions Before

	/* Cache Cleaning by MVA to Point of Coherency (PoC) L1, Not Point of Unification (PoU) L2 */
	bic temp, base_addr, #0x1F                      @ If You Want Cache Operation by Modifier Virtual Address (MVA),
	mcr p15, 0, temp, c7, c10, 1                    @ Bit[5:0] Should Be Zeros

	macro32_dsb ip                                  @ Ensure Completion of Instructions Before
	macro32_isb ip                                  @ Flush Data in Pipeline to Cache

	arm32_change_descriptor_success:
		mov r0, base_addr

	arm32_change_descriptor_common:
		pop {r4,r5}
		mov pc, lr

.unreq non_secure
.unreq addr
.unreq desc
.unreq temp
.unreq mul_number
.unreq base_addr


/**
 * function arm32_activate_va
 * Activate Virtual Address
 *
 * Parameters
 * r0: 0 is for Secure state, 1 is for Non-secure state, 2 is for Hyp mode (Reserved)
 * r1: Flag of TTBR
 *
 * Usage: r0-r4
 * Return: r0 (Vlue of TTBR0)
 */
.globl arm32_activate_va
arm32_activate_va:
	/* Auto (Local) Variables, but just Aliases */
	non_secure  .req r0
	ttbr_flag   .req r1
	number_core .req r2
	base_addr   .req r3
	mul_number  .req r4

	push {r4}

	macro32_multicore_id number_core

	ldr base_addr, ARM32_VADESCRIPTOR_ADDR
	mov mul_number, #0x10000
	mul number_core, number_core, mul_number        @ 0x10000, 65536 Bytes Offset
	add base_addr, base_addr, number_core
	mov mul_number, #0x4000
	mul non_secure, non_secure, mul_number          @ 0x4000, 16384 Bytes Offset
	add base_addr, base_addr, non_secure

	.unreq number_core
	temp .req r1

	macro32_dsb ip                                  @ Ensure Completion of Instructions Before

	/* Invalidate All Unlocked TLB */
	macro32_invalidate_tlb_all ip

	macro32_isb ip                                  @ Flush Data in Pipeline to Cache

	/* Translation Table Base Control Register (TTBCR) */
	mov temp, #equ32_ttbcr_n0                       @ Set N Bit for Translation Table Base Addeess Bit[31:14], 0xFFFC000
	mcr p15, 0, temp, c2, c0, 2

	/* Translation Table Base Register 0 (TTBR0) */
	orr base_addr, base_addr, ttbr_flag
	mcr p15, 0, base_addr, c2, c0, 0
	
	/* Domain Access Control Register */
	mov temp, #0b01
	mcr p15, 0, temp, c3, c0, 0                     @ Only Domain 0 is Client

	arm32_activate_va_success:
		mov r0, base_addr

	arm32_activate_va_common:
		macro32_dsb ip                               @ Ensure Completion of Instructions Before
		pop {r4}
		mov pc, lr

.unreq non_secure
.unreq ttbr_flag
.unreq temp
.unreq base_addr
.unreq mul_number


/**
 * function arm32_lineup_basic_va
 * Line Up Basic The First Level Descriptor of Virtual Address, Secure/Non-Secure
 * By Using This function, Destination Address Becomes The Same as Virtual Address.
 *
 * Parameters
 * r0: Descriptor Flag on Secure state
 * r1: Descriptor Flag on Non-secure state
 *
 * Usage: r0-r7
 * Return: r0 (Last Address of Descriptor), r1 (Last Descriptor)
 */
.globl arm32_lineup_basic_va
arm32_lineup_basic_va:
	/* Auto (Local) Variables, but just Aliases */
	secure_flag    .req r0
	nonsecure_flag .req r1
	number_core    .req r2
	base_addr      .req r3
	size           .req r4
	offset_addr    .req r5
	descriptor     .req r6
	addr           .req r7

	push {r4-r7}

	macro32_multicore_id number_core

	mov addr, #0x10000
	mul number_core, number_core, addr              @ 0x10000, 65536 Bytes Offset
	ldr base_addr, ARM32_VADESCRIPTOR_ADDR
	add base_addr, base_addr, number_core

	mov size, #equ32_peripherals_base
	lsr size, #20                                   @ Bit[31:20], Max 0xFFF
	lsl size, #2                                    @ Substitution of Multiplication by 4

	mov descriptor, secure_flag

	mov offset_addr, #0

	arm32_lineup_basic_va_securememory:
		add addr, base_addr, offset_addr
		str descriptor, [addr]
		add descriptor, descriptor, #0x00100000
		add offset_addr, offset_addr, #4
		cmp offset_addr, size
		blt arm32_lineup_basic_va_securememory

	mov size, #0x00F
	add size, size, #0xFF0                  @ Make 0xFFF
	lsl size, #2

	mov descriptor, #equ32_mmu_section|equ32_mmu_section_device
	orr descriptor, descriptor, #equ32_mmu_section_access_rw_none
	orr descriptor, descriptor, #equ32_mmu_domain00
	add descriptor, descriptor, #equ32_peripherals_base

	arm32_lineup_basic_va_securedevice:
		add addr, base_addr, offset_addr
		str descriptor, [addr]
		add descriptor, descriptor, #0x00100000
		add offset_addr, offset_addr, #4
		cmp offset_addr, size
		ble arm32_lineup_basic_va_securedevice

	/* Non-secure */

	add base_addr, base_addr, #0x4000

	mov size, #equ32_peripherals_base
	lsr size, #20                                   @ Bit[31:20], Max 0xFFF
	lsl size, #2                                    @ Substitution of Multiplication by 4

	mov descriptor, nonsecure_flag

	mov offset_addr, #0

	arm32_lineup_basic_va_nonsecurememory:
		add addr, base_addr, offset_addr
		str descriptor, [addr]
		add descriptor, descriptor, #0x00100000
		add offset_addr, offset_addr, #4
		cmp offset_addr, size
		blt arm32_lineup_basic_va_nonsecurememory

	mov size, #0x00F
	add size, size, #0xFF0                  @ Make 0xFFF
	lsl size, #2

	mov descriptor, #equ32_mmu_section|equ32_mmu_section_device
	orr descriptor, descriptor, #equ32_mmu_section_access_rw_none
	orr descriptor, descriptor, #equ32_mmu_section_nonsecure
	orr descriptor, descriptor, #equ32_mmu_domain00
	add descriptor, descriptor, #equ32_peripherals_base

	arm32_lineup_basic_va_nonsecuredevice:
		add addr, base_addr, offset_addr
		str descriptor, [addr]
		add descriptor, descriptor, #0x00100000
		add offset_addr, offset_addr, #4
		cmp offset_addr, size
		ble arm32_lineup_basic_va_nonsecuredevice

	/* Hyp mode, offset is 0x8000, Long Description Translation Table May Be Needed */

	arm32_lineup_basic_va_success:
		mov r0, addr
		sub r0, r0, #1
		mov r1, descriptor

	arm32_lineup_basic_va_common:
		macro32_dsb ip                      @ Ensure Completion of Instructions Before
		pop {r4-r7}
		mov pc, lr

.unreq secure_flag
.unreq nonsecure_flag
.unreq number_core
.unreq base_addr
.unreq size
.unreq offset_addr
.unreq descriptor
.unreq addr


/**
 * function arm32_change_address
 * Change Translated Destination of Virtual Address
 *
 * Parameters
 * r0: Secure state (0) or Non-secure state (1), Use in Inner Function
 * r1: Address of Virtual Address
 * r2: Address of Destination
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When Virtual Address is not Defined
 */
.globl arm32_change_address
arm32_change_address:
	non_secure     .req r0
	addr_va        .req r1
	addr_dest      .req r2
	base_addr      .req r3
	temp           .req r4
	number_core    .req r5

	push {r4-r5}

	macro32_dsb ip

	mov temp, #0xFF00000
	add temp, #0xF0000000

	and addr_va, addr_va, temp                @ Mask Other than Bit[31:20]
	and addr_dest, addr_dest, temp            @ Mask Other than Bit[31:20]

	macro32_multicore_id number_core

	ldr base_addr, ARM32_VADESCRIPTOR_ADDR
	mov temp, #0x10000
	mul number_core, number_core, temp        @ 0x10000, 65536 Bytes Offset
	add base_addr, base_addr, number_core
	mov temp, #0x4000
	mul temp, non_secure, temp                @ 0x4000, 16384 Bytes Offset
	add base_addr, base_addr, temp

	lsr temp, addr_va, #20                    @ Virtual to Physical Part in Level 1 Translation, Bit[31:20]
	lsl temp, temp, #2                        @ Substitution of Multiplication by 4

	add base_addr, base_addr, temp
	ldr temp, [base_addr]

	macro32_dsb ip

	bic temp, temp, #0xFF00000
	bic temp, temp, #0xF0000000

	orr addr_dest, addr_dest, temp          @ Make VA Descriptor

	push {r0-r3,lr}
	mov r1, addr_va
	mov r2, addr_dest
	bl arm32_change_descriptor
	pop {r0-r3,lr}

	mov r0, #0                              @ Return with Success

	arm32_change_address_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {r4-r5}
		mov pc, lr

.unreq non_secure
.unreq addr_va
.unreq addr_dest
.unreq base_addr
.unreq temp
.unreq number_core


/**
 * function arm32_set_cache
 * Change Cache Status for HEAP
 *
 * Parameters
 * r0: Secure state (0) or Non-secure state (1), Use in Inner Function
 * r1: Flag of Descriptor
 * r2: Start Address of Virtual Memory to Set Cache
 * r3: Size of Memory to Set Cache 
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When Virtual Address is not Defined
 */
.globl arm32_set_cache
arm32_set_cache:
	non_secure     .req r0
	desc_flag      .req r1
	memorymap_base .req r2
	size           .req r3
	temp           .req r4
	base_addr      .req r5
	number_core    .req r6

	push {r4-r6}

	macro32_dsb ip

	cmp memorymap_base, #0
	beq arm32_set_cache_error

	cmp size, #0
	beq arm32_set_cache_error

	add size, size, memorymap_base

	mov temp, #0xFF00000
	add temp, #0xF0000000

	and memorymap_base, memorymap_base, temp     @ Mask Other than Bit[31:20]
	and size, size, temp                         @ Mask Other than Bit[31:20]

	macro32_multicore_id number_core

	ldr base_addr, ARM32_VADESCRIPTOR_ADDR
	mov temp, #0x10000
	mul number_core, number_core, temp           @ 0x10000, 65536 Bytes Offset
	add base_addr, base_addr, number_core
	mov temp, #0x4000
	mul temp, non_secure, temp                   @ 0x4000, 16384 Bytes Offset
	add base_addr, base_addr, temp

	lsr temp, memorymap_base, #20
	lsl temp, temp, #2

	add base_addr, base_addr, temp

	arm32_set_cache_loop:
		cmp memorymap_base, size
		bgt arm32_set_cache_success               @ Inclusive Loop Because of Cut Off by 0xFFF00000
		ldr temp, [base_addr]
		macro32_dsb ip
		bic temp, temp, #0x000000FF                  @ Clear Except Destination Address
		bic temp, temp, #0x0000FF00
		bic temp, temp, #0x000F0000
		orr temp, temp, desc_flag                    @ Make VA Descriptor
		push {r0-r3,lr}
		mov r1, memorymap_base
		mov r2, temp
		bl arm32_change_descriptor
		pop {r0-r3,lr}
		add memorymap_base, memorymap_base, #0x00100000
		add base_addr, base_addr, #4
		b arm32_set_cache_loop

	arm32_set_cache_error:
		mov r0, #1                           @ Return with Error
		b arm32_set_cache_common

	arm32_set_cache_success:
		mov r0, #0                           @ Return with Success

	arm32_set_cache_common:
		macro32_dsb ip                       @ Ensure Completion of Instructions Before
		pop {r4-r6}
		mov pc, lr

.unreq non_secure
.unreq desc_flag
.unreq memorymap_base
.unreq size
.unreq temp
.unreq base_addr
.unreq number_core


.globl ARM32_VADESCRIPTOR_ADDR
.globl ARM32_VADESCRIPTOR_SIZE
ARM32_VADESCRIPTOR_ADDR: .word SYSTEM32_VADESCRIPTOR
ARM32_VADESCRIPTOR_SIZE: .word SYSTEM32_VADESCRIPTOR_END - SYSTEM32_VADESCRIPTOR


/**
 * function arm32_dsb
 * Data Synchronization Barrier
 *
 */
.globl arm32_dsb
arm32_dsb:
		macro32_dsb ip
		mov pc, lr


/**
 * function arm32_dmb
 * Data Memory Barrier
 *
 */
.globl arm32_dmb
arm32_dmb:
		macro32_dmb ip
		mov pc, lr


/**
 * function arm32_isb
 * Instruction Synchronization Barrier
 *
 */
.globl arm32_isb
arm32_isb:
		macro32_isb ip
		mov pc, lr


/**
 * function arm32_random
 * Shuffle and Return Random Value
 * This function uses a type of pseudorandom generation, Linear-feedback Shift Register (LFSR)
 *
 * Parameters
 * r0: Start of Range (0-255)
 * r1: End of Range (0-255)
 *
 * Return: r0 (Random Value)
 */
.globl arm32_random
arm32_random:
	/* Auto (Local) Variables, but just Aliases */
	range_start     .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	range_end       .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	byte            .req r2
	temp            .req r3
	temp2           .req r4
	memorymap_base  .req r5

	push {r4-r5}

	/**
	 * Fibonacci LFSRs
	 */

	ldrb byte, arm32_random_value

	arm32_random_loop:

		and temp, byte, #0x1             @ X^8

		and temp2, byte, #0x4            @ X^6
		lsr temp2, temp2, #2
		eor temp, temp, temp2

		and temp2, byte, #0x8            @ X^5
		lsr temp2, temp2, #3
		eor temp, temp, temp2

		and temp2, byte, #0x10           @ X^4
		lsr temp2, temp2, #4
		eor temp, temp, temp2

		lsl temp, #7                     @ MSB
		lsr byte, #1
		orr byte, byte, temp

		/* Subtract Value of System Timer (Lowest 1 Byte, Max. 0xFF micro seconds) for Randomness */

		mov memorymap_base, #equ32_peripherals_base
		add memorymap_base, memorymap_base, #equ32_systemtimer_base
		ldrb temp, [memorymap_base, #equ32_systemtimer_counter_lower] @ Get Lower 32 Bits

		sub byte, byte, temp
		and byte, byte, #0xFF

		cmp byte, range_start
		blo arm32_random_loop
		cmp byte, range_end
		bhi arm32_random_loop

	arm32_random_common:
		strb byte, arm32_random_value
		mov r0, byte
		pop {r4-r5}
		mov pc, lr

.unreq range_start
.unreq range_end
.unreq byte
.unreq temp
.unreq temp2
.unreq memorymap_base

arm32_random_value: .byte equ32_arm32_random_value
.balign 4


/**
 * function arm32_fill_random
 * Fill Memory Space by Random Value
 *
 * Parameters
 * r0: Start of Range (0-255)
 * r1: End of Range (0-255)
 * r2: Start of Memory
 * r3: Size of Memory
 *
 * Return: r0 (0 as Success)
 */
.globl arm32_fill_random
arm32_fill_random:
	/* Auto (Local) Variables, but just Aliases */
	range_start     .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	range_end       .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	memory_start    .req r2
	memory_size     .req r3
	random          .req r4

	push {r4}

	add memory_size, memory_start, memory_size

	arm32_fill_random_loop:
		cmp memory_start, memory_size
		bhs arm32_fill_random_common

		push {r0-r3,lr}
		bl arm32_random
		mov random, r0
		pop {r0-r3,lr}

		strb random, [memory_start]
		add memory_start, memory_start, #1
		b arm32_fill_random_loop

	arm32_fill_random_common:
		mov r0, #0
		pop {r4}
		mov pc, lr

.unreq range_start
.unreq range_end
.unreq memory_start
.unreq memory_size
.unreq random


/**
 * Make sure to complete addresses of variables by `str/ldr Rd, [PC, #Immediate]`,
 * othewise, compiler can't recognaize labels of variables or literal pool.
 * This Immediate can't be over #4095 (0xFFF), i.e. within 4K Bytes.
 * But if you assign ".globl" to the label, then these are mapped when using `ld`, a linker (please check out inter.map).
 * These are useful if you use `extern` in C lang file, or use the label in other assembler lang files.
 */
