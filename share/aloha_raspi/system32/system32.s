/**
 * system32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Functions which access memory-mapped peripherals may make missing of cache.
 * Make sure to use cache operations, clean/invalidate. Or `DSB/DMB/ISB`.
 * If you meet missig of cache, even you use cache operations, use cache operations of Set/Way type.
 */

.include "system32/macro32.s"

/**
 * "vender_system32" is to be used for drivers of vendor-implemented peripherals. These usually don't have any standard,
 * So if you consider of compatibility with other ARM CPUs. Files in this section should be alternated with
 * other ones.
 */
.section	.vendor_system32

.include "system32/bcm32.s"

/**
 * "arm_system32" is to be used for drivers of ARM system registers, and standard peripherals,
 * USB, I2C, UART, etc. These are usually aiming compatibility with other ARM CPUs,
 * but memory mapping differs among CPUs. Addresses of peripherals in "equ32.s" should be changed. 
 */
.section	.arm_system32

.include "system32/equ32.s"


/* Definition Only in ARMv7/AArch32 */
.ifndef __ARMV6

/**
 * function system32_core_call
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
.globl system32_core_call
system32_core_call:
	/* Auto (Local) Variables, but just Aliases */
	heap         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	number_core  .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	handle_addr  .req r2

	and number_core, number_core, #0b11      @ Prevet Memory Overflow

	cmp number_core, #3                      @ 0 <= number_core <= 3
	bgt system32_core_call_error
	cmp number_core, #0
	blt system32_core_call_error

	lsl number_core, number_core, #2         @ Substitution of Multiplication by 4

	ldr handle_addr, SYSTEM32_CORE_HANDLE_BASE
	add handle_addr, handle_addr, number_core

	macro32_dsb ip @ Stronger than `dmb`, `dsb` stops all instructions, including instructions with no memory access

	str heap, [handle_addr]

	macro32_dsb ip

	b system32_core_call_success

	system32_core_call_error:
		mov r0, #1
		b system32_core_call_common

	system32_core_call_success:
		mov r0, #0

	system32_core_call_common:
		mov pc, lr

.unreq heap
.unreq number_core
.unreq handle_addr 


/**
 * function system32_core_handle
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
 * When Function is Finished, SYSTEM32_CORE_HANDLE_n Will Be Zero to Indicate Finishing.
 *
 * Usage: r0-r9
 * Return: r0 (0 as success)
 */
.globl system32_core_handle
system32_core_handle:
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

	ldr handle_addr, SYSTEM32_CORE_HANDLE_BASE
	add handle_addr, handle_addr, number_core

	.unreq number_core
	arg0 .req r0

	macro32_dsb ip @ Stronger than `dmb`, `dsb` stops all instructions, including instructions with no memory access

	system32_core_handle_loop1:
		ldr heap, [handle_addr]
		cmp heap, #0
		beq system32_core_handle_loop1

	ldr addr_start, [heap]
	ldr num_arg, [heap, #4]

	mov dup_num_arg, #0

	push {r0-r3,lr}

	cmp num_arg, #0
	beq system32_core_handle_branch
	cmp num_arg, #1
	ldrge arg0, [heap, #8]
	beq system32_core_handle_branch
	cmp num_arg, #2
	ldrge arg1, [heap, #12]
	beq system32_core_handle_branch
	cmp num_arg, #3
	ldrge arg2, [heap, #16]
	beq system32_core_handle_branch
	cmp num_arg, #4
	ldrge arg3, [heap, #20]
	beq system32_core_handle_branch

	mov dup_num_arg, num_arg
	sub dup_num_arg, dup_num_arg, #4                         @ For Offset of SP Afterward
	lsl dup_num_arg, dup_num_arg, #2                         @ Substitution of Multiplication by 4

	lsl num_arg, num_arg, #2                                 @ Substitution of Multiplication by 4
	add num_arg, num_arg, #4

	system32_core_handle_loop2:
		cmp num_arg, #20
		ble system32_core_handle_branch
		ldr temp, [heap, num_arg]
		push {temp}
		sub num_arg, num_arg, #4
		b system32_core_handle_loop2

	system32_core_handle_branch:
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

	system32_core_handle_common:
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

SYSTEM32_CORE_HANDLE_BASE:      .word SYSTEM32_CORE_HANDLE_0
.globl SYSTEM32_CORE_HANDLE_0
.globl SYSTEM32_CORE_HANDLE_1
.globl SYSTEM32_CORE_HANDLE_2
.globl SYSTEM32_CORE_HANDLE_3
SYSTEM32_CORE_HANDLE_0:         .word 0x00
SYSTEM32_CORE_HANDLE_1:         .word 0x00
SYSTEM32_CORE_HANDLE_2:         .word 0x00
SYSTEM32_CORE_HANDLE_3:         .word 0x00
.balign 64 @ Prevet Memory Overflow to The Next Instruction


/**
 * function system32_cache_operation_all
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
.globl system32_cache_operation_all
system32_cache_operation_all:
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
	bl system32_cache_info
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

	system32_cache_operation_all_loop:
		cmp set_size, #0
		blt system32_cache_operation_all_success
		lsl set_bit, set_size, line_shift        @ Set Set Bit[*:4 + LineSize]
		
		add setlevel, set_bit, level
		mov way_size_dup, way_size

		system32_cache_operation_all_loop_way:
			cmp way_size_dup, #0
			blt system32_cache_operation_all_loop_common
			lsl bit_mask, way_size_dup, temp         @ Set Way Bit[31:*]
			add waysetlevel, setlevel, bit_mask
			cmp flag, #0
			mcreq p15, 0, waysetlevel, c7, c6, 2     @ Invalidate Data (L1) or Unified (L2) Cache
			cmp flag, #1
			mcreq p15, 0, waysetlevel, c7, c10, 2    @ Clean Data (L1) or Unified (L2) Cache 
			cmp flag, #2
			mcreq p15, 0, waysetlevel, c7, c14, 2    @ Clean and Invalidate Data (L1) or Unified (L2) Cache
			sub way_size_dup, way_size_dup, #1
			b system32_cache_operation_all_loop_way

		system32_cache_operation_all_loop_common:
			sub set_size, set_size, #1
			b system32_cache_operation_all_loop

	system32_cache_operation_all_success:
		mov r0, waysetlevel 

	system32_cache_operation_all_common:
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
 * function system32_cache_operation
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
.globl system32_cache_operation
system32_cache_operation:
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
	bl system32_cache_info
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

	system32_cache_operation_loop:
		cmp way_size, #0
		blt system32_cache_operation_success
		lsl bit_mask, way_size, temp             @ Set Way Bit[31:*]
		add waysetlevel, setlevel, bit_mask
		cmp flag, #0
		mcreq p15, 0, waysetlevel, c7, c6, 2     @ Invalidate Data (L1) or Unified (L2) Cache
		cmp flag, #1
		mcreq p15, 0, waysetlevel, c7, c10, 2    @ Clean Data (L1) or Unified (L2) Cache 
		cmp flag, #2
		mcreq p15, 0, waysetlevel, c7, c14, 2    @ Clean and Invalidate Data (L1) or Unified (L2) Cache
		sub way_size, way_size, #1
		b system32_cache_operation_loop

	system32_cache_operation_success:
		mov r0, waysetlevel

	system32_cache_operation_common:
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
 * function system32_cache_info
 * Return Particular Cache Information
 * Caution! This Function is compatible from ARMv7/AArch32
 *
 * Parameters
 * r0: Content of Cache Size Slection Register (CSSELR) for CCSIDR
 *
 * Usage: r0
 * Return: r0 (Value of CCSIDR)
 */
.globl system32_cache_info
system32_cache_info:
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

	system32_cache_info_common:
		mov pc, lr

.unreq ccsidr


/* End of Definition Only in ARMv7/AArch32 */
.endif


/**
 * function system32_cache_operation_heap
 * Invalidate and Clean Cache by MVA Address in an Allocated Heap
 *
 * Parameters
 * r0: Pointer of Heap Block Allocated
 * r1: Flag, 0(Invalidate)/1(Clean)/2(Clean and Invalidate)
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Pointer of Start Address is Null (0)
 */
.globl system32_cache_operation_heap
system32_cache_operation_heap:
	/* Auto (Local) Variables, but just Aliases */
	block_start .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	flag        .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	block_size  .req r2

	cmp block_start, #0
	beq system32_cache_operation_heap_error

	ldr block_size, [block_start, #-4]
	add block_size, block_start, block_size

	bic block_start, block_start, #0x1F
	bic block_size, block_size, #0x1F

	system32_cache_operation_heap_loop:
		cmp block_start, block_size
		bgt system32_cache_operation_heap_success

		cmp flag, #0
		mcreq p15, 0, block_start, c7, c6, 1     @ Invalidate Data Cache
		cmp flag, #1
		mcreq p15, 0, block_start, c7, c10, 1    @ Clean Data Cache
		cmp flag, #2
		mcreq p15, 0, block_start, c7, c14, 1    @ Clean and Invalidate Data Cache

		add block_start, block_start, #0x20      @ 32 Bytes (4 Words) Align
		b system32_cache_operation_heap_loop

	system32_cache_operation_heap_error:
		mov r0, #1
		b system32_cache_operation_heap_common

	system32_cache_operation_heap_success:
		mov r0, #0

	system32_cache_operation_heap_common:
		mov pc, lr

.unreq block_start
.unreq flag
.unreq block_size


/**
 * function system32_convert_endianness
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
.globl system32_convert_endianness
system32_convert_endianness:
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
	bne system32_convert_endianness_error

	add size, size, data_point

	system32_convert_endianness_loop:
		cmp data_point, size
		bge system32_convert_endianness_success

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

		system32_convert_endianness_loop_byte:
			cmp j, #0
			blt system32_convert_endianness_loop_byte_common

			lsr swap_2, swap_1, i
			and swap_2, swap_2, #0xFF
			lsl swap_2, swap_2, j
			add convert_result, convert_result, swap_2
			add i, i, #8
			sub j, j, #8

			b system32_convert_endianness_loop_byte

			system32_convert_endianness_loop_byte_common:
				cmp align_bytes, #4
				streq convert_result, [data_point]
				addeq data_point, data_point, #4
				cmp align_bytes, #2
				streqh convert_result, [data_point]
				addeq data_point, data_point, #2

				b system32_convert_endianness_loop

	system32_convert_endianness_error:
		mov r0, #1
		b system32_convert_endianness_common

	system32_convert_endianness_success:
		mov r0, #0

	system32_convert_endianness_common:
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
 * function system32_sleep
 * Sleep in Micro Seconds
 *
 * Parameters
 * r0: Micro Seconds to Sleep
 *
 * Usage: r0-r5
 */
.globl system32_sleep
system32_sleep:
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

	system32_sleep_loop:
		ldr time_low, [memorymap_base, #equ32_systemtimer_counter_lower] @ In Case of Interrupt, Load Lower Bits First
		ldr time_high, [memorymap_base, #equ32_systemtimer_counter_higher]
		cmp count_high, time_high                                   @ Similar to `SUBS`, Compare Higher 32 Bits
		cmple count_low, time_low                                   @ Compare Lower 32 Bits
		bgt system32_sleep_loop

	system32_sleep_common:
		pop {r4-r5}
		mov pc, lr

.unreq usecond
.unreq memorymap_base
.unreq count_low
.unreq count_high
.unreq time_low
.unreq time_high


/**
 * function system32_random
 * Shuffle and Return Random Value
 * Caution! This function uses a type of pseudorandom generation, Linear-feedback Shift Register (LFSR)
 *
 * Parameters
 * r0: Start of Range (0-255)
 * r1: End of Range (0-255)
 *
 * Return: r0 (Random Value)
 */
.globl system32_random
system32_random:
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

	ldrb byte, system32_random_value

	system32_random_loop:
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

		/* Subtract System Time for Randomness */

		mov memorymap_base, #equ32_peripherals_base
		add memorymap_base, memorymap_base, #equ32_systemtimer_base
		ldrb temp, [memorymap_base, #equ32_systemtimer_counter_lower] @ Get Lower 32 Bits

		sub byte, byte, temp
		and byte, byte, #0xFF

		cmp byte, range_start
		blo system32_random_loop
		cmp byte, range_end
		bhi system32_random_loop

	system32_random_common:
		strb byte, system32_random_value
		mov r0, byte
		pop {r4-r5}
		mov pc, lr

.unreq range_start
.unreq range_end
.unreq byte
.unreq temp
.unreq temp2
.unreq memorymap_base

system32_random_value: .byte 0xFF
.balign 4


/**
 * function system32_no_op
 * Do Nothing
 */
.globl system32_no_op
system32_no_op:
	mov r0, r0
	mov pc, lr


/**
 * function system32_store_32
 * Store 32-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl system32_store_32
system32_store_32:
	str r1, [r0]
	mov pc, lr


/**
 * function system32_store_16
 * Store 16-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl system32_store_16
system32_store_16:
	strh r1, [r0]
	mov pc, lr


/**
 * function system32_store_8
 * Store 8-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl system32_store_8
system32_store_8:
	strb r1, [r0]
	mov pc, lr


/**
 * function system32_load_32
 * Load 32-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl system32_load_32
system32_load_32:
	ldr r0, [r0]
	mov pc, lr


/**
 * function system32_load_16
 * Load 16-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl system32_load_16
system32_load_16:
	ldrh r0, [r0]
	mov pc, lr


/**
 * function system32_load_8
 * Load 8-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl system32_load_8
system32_load_8:
	ldrb r0, [r0]
	mov pc, lr


/**
 * function system32_change_descriptor
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
.globl system32_change_descriptor
system32_change_descriptor:
	/* Auto (Local) Variables, but just Aliases */
	non_secure  .req r0
	addr        .req r1
	desc        .req r2
	number_core .req r3
	mul_number  .req r4
	base_addr   .req r5

	push {r4,r5}

	macro32_multicore_id number_core

	ldr base_addr, SYSTEM32_VADESCRIPTOR_ADDR
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

	system32_change_descriptor_success:
		mov r0, base_addr

	system32_change_descriptor_common:
		pop {r4,r5}
		mov pc, lr

.unreq non_secure
.unreq addr
.unreq desc
.unreq temp
.unreq mul_number
.unreq base_addr


/**
 * function system32_activate_va
 * Activate Virtual Address
 *
 * Parameters
 * r0: 0 is for Secure state, 1 is for Non-secure state, 2 is for Hyp mode (Reserved)
 * r1: Flag of TTBR
 *
 * Usage: r0-r4
 * Return: r0 (Vlue of TTBR0)
 */
.globl system32_activate_va
system32_activate_va:
	/* Auto (Local) Variables, but just Aliases */
	non_secure  .req r0
	ttbr_flag   .req r1
	number_core .req r2
	base_addr   .req r3
	mul_number  .req r4

	push {r4}

	macro32_multicore_id number_core

	ldr base_addr, SYSTEM32_VADESCRIPTOR_ADDR
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

	system32_activate_va_success:
		mov r0, base_addr

	system32_activate_va_common:
		macro32_dsb ip                               @ Ensure Completion of Instructions Before
		pop {r4}
		mov pc, lr

.unreq non_secure
.unreq ttbr_flag
.unreq temp
.unreq base_addr
.unreq mul_number


/**
 * function system32_lineup_basic_va
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
.globl system32_lineup_basic_va
system32_lineup_basic_va:
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
	ldr base_addr, SYSTEM32_VADESCRIPTOR_ADDR
	add base_addr, base_addr, number_core

	mov size, #equ32_peripherals_base
	lsr size, #20                                   @ Bit[31:20], Max 0xFFF
	lsl size, #2                                    @ Substitution of Multiplication by 4

	mov descriptor, secure_flag

	mov offset_addr, #0

	system32_lineup_basic_va_securememory:
		add addr, base_addr, offset_addr
		str descriptor, [addr]
		add descriptor, descriptor, #0x00100000
		add offset_addr, offset_addr, #4
		cmp offset_addr, size
		blt system32_lineup_basic_va_securememory

	mov size, #0x00F
	add size, size, #0xFF0                  @ Make 0xFFF
	lsl size, #2

	mov descriptor, #equ32_mmu_section|equ32_mmu_section_device
	orr descriptor, descriptor, #equ32_mmu_section_access_rw_none
	orr descriptor, descriptor, #equ32_mmu_domain00
	add descriptor, descriptor, #equ32_peripherals_base

	system32_lineup_basic_va_securedevice:
		add addr, base_addr, offset_addr
		str descriptor, [addr]
		add descriptor, descriptor, #0x00100000
		add offset_addr, offset_addr, #4
		cmp offset_addr, size
		ble system32_lineup_basic_va_securedevice

	/* Non-secure */

	add base_addr, base_addr, #0x4000

	mov size, #equ32_peripherals_base
	lsr size, #20                                   @ Bit[31:20], Max 0xFFF
	lsl size, #2                                    @ Substitution of Multiplication by 4

	mov descriptor, nonsecure_flag

	mov offset_addr, #0

	system32_lineup_basic_va_nonsecurememory:
		add addr, base_addr, offset_addr
		str descriptor, [addr]
		add descriptor, descriptor, #0x00100000
		add offset_addr, offset_addr, #4
		cmp offset_addr, size
		blt system32_lineup_basic_va_nonsecurememory

	mov size, #0x00F
	add size, size, #0xFF0                  @ Make 0xFFF
	lsl size, #2

	mov descriptor, #equ32_mmu_section|equ32_mmu_section_device
	orr descriptor, descriptor, #equ32_mmu_section_access_rw_none
	orr descriptor, descriptor, #equ32_mmu_section_nonsecure
	orr descriptor, descriptor, #equ32_mmu_domain00
	add descriptor, descriptor, #equ32_peripherals_base

	system32_lineup_basic_va_nonsecuredevice:
		add addr, base_addr, offset_addr
		str descriptor, [addr]
		add descriptor, descriptor, #0x00100000
		add offset_addr, offset_addr, #4
		cmp offset_addr, size
		ble system32_lineup_basic_va_nonsecuredevice

	/* Hyp mode, offset is 0x8000, Long Description Translation Table May Be Needed */

	system32_lineup_basic_va_success:
		mov r0, addr
		sub r0, r0, #1
		mov r1, descriptor

	system32_lineup_basic_va_common:
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
 * function system32_change_address
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
.globl system32_change_address
system32_change_address:
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

	ldr base_addr, SYSTEM32_VADESCRIPTOR_ADDR
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
	bl system32_change_descriptor
	pop {r0-r3,lr}

	mov r0, #0                              @ Return with Success

	system32_change_address_common:
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
 * function system32_set_cache
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
.globl system32_set_cache
system32_set_cache:
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
	beq system32_set_cache_error

	cmp size, #0
	beq system32_set_cache_error

	add size, size, memorymap_base

	mov temp, #0xFF00000
	add temp, #0xF0000000

	and memorymap_base, memorymap_base, temp     @ Mask Other than Bit[31:20]
	and size, size, temp                         @ Mask Other than Bit[31:20]

	macro32_multicore_id number_core

	ldr base_addr, SYSTEM32_VADESCRIPTOR_ADDR
	mov temp, #0x10000
	mul number_core, number_core, temp           @ 0x10000, 65536 Bytes Offset
	add base_addr, base_addr, number_core
	mov temp, #0x4000
	mul temp, non_secure, temp                   @ 0x4000, 16384 Bytes Offset
	add base_addr, base_addr, temp

	lsr temp, memorymap_base, #20
	lsl temp, temp, #2

	add base_addr, base_addr, temp

	system32_set_cache_loop:
		cmp memorymap_base, size
		bgt system32_set_cache_success               @ Inclusive Loop Because of Cut Off by 0xFFF00000
		ldr temp, [base_addr]
		macro32_dsb ip
		bic temp, temp, #0x000000FF                  @ Clear Except Destination Address
		bic temp, temp, #0x0000FF00
		bic temp, temp, #0x000F0000
		orr temp, temp, desc_flag                    @ Make VA Descriptor
		push {r0-r3,lr}
		mov r1, memorymap_base
		mov r2, temp
		bl system32_change_descriptor
		pop {r0-r3,lr}
		add memorymap_base, memorymap_base, #0x00100000
		add base_addr, base_addr, #4
		b system32_set_cache_loop

	system32_set_cache_error:
		mov r0, #1                           @ Return with Error
		b system32_set_cache_common

	system32_set_cache_success:
		mov r0, #0                           @ Return with Success

	system32_set_cache_common:
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


/**
 * function system32_clear_heap
 * Clear (All Zero) in Heap
 *
 * Usage: r0-r2
 * Return: r0 (0 as Success)
 */
.globl system32_clear_heap
system32_clear_heap:
	/* Auto (Local) Variables, but just Aliases */
	heap_start  .req r0
	heap_size   .req r1
	heap_bytes  .req r2

	ldr heap_start, SYSTEM32_HEAP_ADDR
	ldr heap_size, SYSTEM32_HEAP_SIZE           @ In Bytes

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	add heap_size, heap_start, heap_size

	mov heap_bytes, #0

	system32_clear_heap_loop1:
		cmp heap_start, heap_size
		bhs system32_clear_heap_common      @ If Heap Space Overflow

		str heap_bytes, [heap_start]

		add heap_start, heap_start, #4
		b system32_clear_heap_loop1         @ If Bytes are not Zero

	system32_clear_heap_common:
		macro32_dsb ip                          @ Ensure Completion of Instructions Before
		mov r0, #0
		mov pc, lr

.unreq heap_start
.unreq heap_size
.unreq heap_bytes


/**
 * function system32_malloc
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
.globl system32_malloc
system32_malloc:
	/* Auto (Local) Variables, but just Aliases */
	size           .req r0 @ Parameter, Register for Argument and Result, Scratch Register, Block (4 Bytes) Size
	heap_start     .req r1
	heap_size      .req r2
	heap_bytes     .req r3
	check_start    .req r4
	check_size     .req r5
	heap_start_dup .req r6

	push {r4-r6}

	lsl size, size, #2                          @ Substitution of Multiplication by 4, Words to Bytes

	ldr heap_start, SYSTEM32_HEAP_ADDR
	ldr heap_size, SYSTEM32_HEAP_SIZE           @ In Bytes

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	mov heap_start_dup, heap_start

	add heap_size, heap_start, heap_size

	system32_malloc_loop:
		cmp heap_start, heap_size
		bhs system32_malloc_error               @ If Heap Space Overflow
		cmp heap_start, heap_start_dup
		blo system32_malloc_error               @ If Heap Space Underflow

		ldr heap_bytes, [heap_start]
		cmp heap_bytes, #0
		beq system32_malloc_loop_sizecheck      @ If Bytes are Zero

		add heap_start, heap_start, heap_bytes
		add heap_start, heap_start, #4
		b system32_malloc_loop                  @ If Bytes are not Zero

		/* Whether Check Size is Enough or Not */

		system32_malloc_loop_sizecheck:
			mov check_start, heap_start
			add check_size, check_start, size

			system32_malloc_loop_sizecheck_loop:
				cmp check_start, heap_size
				bhs system32_malloc_error               @ If Heap Space Overflow
				cmp heap_start, heap_start_dup
				blo system32_malloc_error               @ If Heap Space Underflow

				cmp check_start, check_size
				bhi system32_malloc_success             @ Inclusive Loop Because Memory Needs Its Required Size Plus 4 Bytes

				ldr heap_bytes, [check_start]

				cmp heap_bytes, #0
				addeq check_start, check_start, #4
				beq system32_malloc_loop_sizecheck_loop @ If Bytes are Zero

				add heap_start, check_start, heap_bytes
				add heap_start, heap_start, #4
				b system32_malloc_loop                  @ If Bytes are not Zero

	system32_malloc_error:
		mov r0, #0
		b system32_malloc_common

	system32_malloc_success:
		str size, [heap_start]                  @ Store Size (Bytes) on Start Address of Memory Minus 4 Bytes
		mov r0, heap_start
		add r0, r0, #4                          @ Slide for Start Address of Memory

	system32_malloc_common:
		macro32_dsb ip                          @ Ensure Completion of Instructions Before
		pop {r4-r6}
		mov pc, lr

.unreq size
.unreq heap_start
.unreq heap_size
.unreq heap_bytes
.unreq check_start
.unreq check_size
.unreq heap_start_dup


.globl SYSTEM32_HEAP_ADDR
.globl SYSTEM32_HEAP_SIZE
SYSTEM32_HEAP_ADDR:         .word _SYSTEM32_HEAP
SYSTEM32_HEAP_SIZE:         .word _SYSTEM32_HEAP_END - _SYSTEM32_HEAP

.globl SYSTEM32_VADESCRIPTOR_ADDR
.globl SYSTEM32_VADESCRIPTOR_SIZE
SYSTEM32_VADESCRIPTOR_ADDR: .word _SYSTEM32_VADESCRIPTOR
SYSTEM32_VADESCRIPTOR_SIZE: .word _SYSTEM32_VADESCRIPTOR_END - _SYSTEM32_VADESCRIPTOR


/**
 * function system32_mfree
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
.globl system32_mfree
system32_mfree:
	/* Auto (Local) Variables, but just Aliases */
	block_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	block_size       .req r1
	heap_start       .req r2
	heap_size        .req r3
	zero             .req r4

	push {r4}

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp block_start, #0
	beq system32_mfree_error

	ldr block_size, [block_start, #-4]
	add block_size, block_start, block_size
	sub block_start, block_start, #4            @ Slide Minus 4 Bytes for Erase Size Indicator

	ldr heap_start, SYSTEM32_HEAP_ADDR
	ldr heap_size, SYSTEM32_HEAP_SIZE           @ In Bytes
	add heap_size, heap_start, heap_size

	cmp block_size, heap_size                   @ If You Attempt to Free Already Freed Pointer, You May Meet Overflow of HEAP
	bgt system32_mfree_error                    @ Because The Loaded Block_Size Is Invalid, And May It's Potentially So Big Size

	mov zero, #0

	system32_mfree_loop:
		cmp block_start, block_size
		bge system32_mfree_success

		str zero, [block_start]
		add block_start, block_start, #4

		b system32_mfree_loop

	system32_mfree_error:
		mov r0, #1
		b system32_mfree_common

	system32_mfree_success:
		mov r0, #0

	system32_mfree_common:
		macro32_dsb ip                          @ Ensure Completion of Instructions Before
		pop {r4}
		mov pc, lr

.unreq block_start
.unreq block_size
.unreq zero
.unreq heap_start
.unreq heap_size


/**
 * function system32_mcopy
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
.globl system32_mcopy
system32_mcopy:
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

	macro32_dsb ip                              @ Ensure Completion of Instructions Before

	cmp heap1, #0
	beq system32_mcopy_error

	cmp heap2, #0
	beq system32_mcopy_error

	ldr heap1_size, [heap1, #-4]
	add heap1_size, heap1_size, heap1

	ldr heap2_size, [heap2, #-4]
	add heap2_size, heap2_size, heap2

	ldr heap_start, SYSTEM32_HEAP_ADDR
	ldr heap_size, SYSTEM32_HEAP_SIZE           @ In Bytes
	add heap_size, heap_start, heap_size

	cmp heap1, heap_start
	blo system32_mcopy_error                    @ Unsigned Lower Than
	cmp heap2, heap_start
	blo system32_mcopy_error
	cmp heap1_size, heap_size
	bhs system32_mcopy_error                    @ Unsigned Higher Than or Same
	cmp heap2_size, heap_size
	bhs system32_mcopy_error

	mov heap1_dup, heap1

	add heap2, heap2, offset

	system32_mcopy_loop:
		cmp heap1, heap1_size
		bge system32_mcopy_error
		cmp heap2, heap2_size
		bge system32_mcopy_error

		ldrb byte, [heap2]
		strb byte, [heap1]

		add heap1, heap1, #1
		add heap2, heap2, #1
		sub size, size, #1
		cmp size, #0
		ble system32_mcopy_success
		b system32_mcopy_loop                   @ If Bytes are not Zero

	system32_mcopy_error:
		mov r0, #0
		b system32_mcopy_common

	system32_mcopy_success:
		mov r0, heap1_dup

	system32_mcopy_common:
		macro32_dsb ip                          @ Ensure Completion of Instructions Before
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
 * function system32_dsb
 * Data Synchronization Barrier
 *
 */
.globl system32_dsb
system32_dsb:
		macro32_dsb ip
		mov pc, lr


/**
 * function system32_dmb
 * Data Memory Barrier
 *
 */
.globl system32_dmb
system32_dmb:
		macro32_dmb ip
		mov pc, lr


/**
 * function system32_isb
 * Instruction Synchronization Barrier
 *
 */
.globl system32_isb
system32_isb:
		macro32_isb ip
		mov pc, lr


/**
 * Make sure to complete addresses of variables by `str/ldr Rd, [PC, #Immediate]`,
 * othewise, compiler can't recognaize labels of variables or literal pool.
 * This Immediate can't be over #4095 (0xFFF), i.e. within 4K Bytes.
 * But if you assign ".globl" to the label, then these are mapped when using `ld`, a linker (please check out inter.map).
 * These are useful if you use `extern` in C lang file, or use the label in other assembler lang files.
 */

.include "system32/usb2032.s"
.balign 4

/**
 * Place Label to First Address of Data Memory Section (including .bss)
 */

.section	.data
.globl SYSTEM32_DATAMEMORY
SYSTEM32_DATAMEMORY:

/**
 * "library_system32" is to be used for libraries, Drawing, Sound, Color, Font, etc. which have
 * compatibility with other ARM CPUs. 
 */
.section	.library_system32

/* print32.s uses memory spaces in fb32.s, so this file is needed to close to fb32.s within 4K bytes */
.include "system32/print32.s"
.balign 4
.include "system32/fb32.s"            @ Having Section .data
.balign 4
.include "system32/draw32.s"
.balign 4
.include "system32/math32.s"
.balign 4
.include "system32/font_mono_12px.s"
.balign 4
.include "system32/color.s"
.balign 4
.include "system32/data.s"            @ Having Section .data
.balign 4

.section	.bss

.balign 16

_SYSTEM32_HEAP:
.space 16777216                       @ Filled With Zero in Default, 16M Bytes
_SYSTEM32_HEAP_END:

/**
 * Initial SVC Mode: 0x4000 (-0x200 Offset by Core ID)
 * Initial Hyp Mode: 0x5000 (-0x200 Offset by Core ID)
 * Initial Mon Mode: 0x6000 (-0x200 Offset by Core ID)
 * OS Undefined Mode: 0x7200
 * OS Supervisor Mode: 0x7400
 * OS Abort Mode: 0x7600
 * OS IRQ Mode: 0x7800
 * OS FIQ Mode: 0x8000
 *
 * OS User/System Mode Uses SYSTEM32_STACKPOINTER
 */
.globl SYSTEM32_STACKPOINTER
SYSTEM32_STACKPOINTER_TOP:         .space 65536
SYSTEM32_STACKPOINTER:

.section	.va_system32          @ 16K Bytes Align for Each Descriptor on Reset

_SYSTEM32_VADESCRIPTOR:
.space 262144                         @ Filled With Zero in Default, 256K Bytes
_SYSTEM32_VADESCRIPTOR_END:
