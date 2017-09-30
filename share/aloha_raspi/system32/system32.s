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

/**
 * function system32_core_call
 * Call 0-3 Cores
 * Need of SMP is on, and Cache is Inner Shareable.
 * Caution! This Function is compatible from ARMv7/AArch32
 *
 * Parameters
 * r0: Pointer of Heap
 * r1: Number of Core
 *
 * Usage: r0-r2
 * Return: r0 (0 as success, 1 as error), 
 * Error: Number of Core does not exist or assigned Core0
 */
.globl system32_core_call
system32_core_call:
	/* Auto (Local) Variables, but just Aliases */
	heap         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	core_number  .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	handle_addr  .req r2

	cmp core_number, #3                      @ 0 <= mailbox_number <= 3
	bgt system32_core_call_error
	cmp core_number, #0
	blt system32_core_call_error

	lsl core_number, core_number, #4         @ Substitution of Multiplication by 16

	ldr handle_addr, SYSTEM32_CORE_HANDLE_BASE
	add handle_addr, handle_addr, core_number

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
.unreq core_number
.unreq handle_addr 


/**
 * function system32_core_handle
 * Execute Function with Arguments in Core
 * Need of SMP is on, and Cache is Inner Shareable.
 * Caution! This Function is compatible from ARMv7/AArch32
 *
 * This Function Uses Heap and Pointer of Heap.
 * First of Heap Array is Pointer of Function.
 * Second of Heap Array is Number of Arguments.
 * Third and Over of Heap Array are Arguments of Function.
 *
 * Return Value Will Be Stored on 4 Bytes and 8 Bytes Offset from Pointer of Heap
 * When Function is Finished, Pointer of Heap Will Be Zero to Indicate of Finishing.
 *
 * Usage: r0-r9
 * Return: r0 (0 as success, 1 as error), 
 * Error: Pointer of Heap is Not Assigned
 */
.globl system32_core_handle
system32_core_handle:
	/* Auto (Local) Variables, but just Aliases */
	core_number  .req r0
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

	mrc p15, 0, core_number, c0, c0, 5       @ Multiprocessor Affinity Register (MPIDR)
	and core_number, core_number, #0b11

	lsl core_number, core_number, #4         @ Substitution of Multiplication by 16

	ldr handle_addr, SYSTEM32_CORE_HANDLE_BASE
	add handle_addr, handle_addr, core_number

	.unreq core_number
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
		str r0, [handle_addr, #4]                            @ Return Value r0 to 2nd of Array
		str r1, [handle_addr, #8]                            @ Return Value r1 to 3rd of Array
		add sp, sp, dup_num_arg                              @ Offset SP
		pop {r0-r3,lr}

		/**
		 * In this point, I initially intended to store return values to heap,
		 * but both heap values show incorrect value, "E59FF018" which seems to be missing of cache.
		 * To hide this issue, I tested one-way communications on ldr/str processes,
		 * i.e., putting return values to other places where only store these values and nothing of any loading. 
		 */

		macro32_dsb ip
		
		mov temp, #0
		str temp, [handle_addr]                              @ Indicate End of Function by Zero to 1st of Array for Polling on Another Core

		b system32_core_handle_success

	system32_core_handle_error:
		mov r0, #1
		b system32_core_handle_common

	system32_core_handle_success:
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


.globl SYSTEM32_CORE_HANDLE_BASE
.globl SYSTEM32_CORE_HANDLE_0
.globl SYSTEM32_CORE_HANDLE_1
.globl SYSTEM32_CORE_HANDLE_2
.globl SYSTEM32_CORE_HANDLE_3
SYSTEM32_CORE_HANDLE_BASE:      .word SYSTEM32_CORE_HANDLE_0
SYSTEM32_CORE_HANDLE_0:         .word 0x00000000
SYSTEM32_CORE_HANDLE_0_RETURN0: .word 0x00000000
SYSTEM32_CORE_HANDLE_0_RETURN1: .word 0x00000000
SYSTEM32_CORE_HANDLE_0_RESERVE: .word 0x00000000
SYSTEM32_CORE_HANDLE_1:         .word 0x00000000
SYSTEM32_CORE_HANDLE_1_RETURN0: .word 0x00000000
SYSTEM32_CORE_HANDLE_1_RETURN1: .word 0x00000000
SYSTEM32_CORE_HANDLE_1_RESERVE: .word 0x00000000
SYSTEM32_CORE_HANDLE_2:         .word 0x00000000
SYSTEM32_CORE_HANDLE_2_RETURN0: .word 0x00000000
SYSTEM32_CORE_HANDLE_2_RETURN1: .word 0x00000000
SYSTEM32_CORE_HANDLE_2_RESERVE: .word 0x00000000
SYSTEM32_CORE_HANDLE_3:         .word 0x00000000
SYSTEM32_CORE_HANDLE_3_RETURN0: .word 0x00000000
SYSTEM32_CORE_HANDLE_3_RETURN1: .word 0x00000000
SYSTEM32_CORE_HANDLE_3_RESERVE: .word 0x00000000


/**
 * function system32_cache_operation_all
 * Cache Operation to All Cache
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
 * In Arm, Data Cache System is Controled with MMU, Virtual Address.
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
 * function system32_cache_operation_heap
 * Invalidate and Clean Cache by Physical Address in an Allocated Heap
 *
 * Parameters
 * r0: Pointer of Heap Block Allocated
 * r1: Cache Level, 1/2
 * r2: Flag, 0(Invalidate)/1(Clean)/2(Clean and Invalidate)
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Pointer of Start Address is Null (0)
 */
.globl system32_cache_operation_heap
system32_cache_operation_heap:
	/* Auto (Local) Variables, but just Aliases */
	block_start .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	level       .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	flag        .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	block_size  .req r3

	cmp block_start, #0
	beq system32_cache_operation_heap_error

	ldr block_size, [block_start, #-4]
	add block_size, block_start, block_size

	system32_cache_operation_heap_loop:
		cmp block_start, block_size
		bge system32_cache_operation_heap_success

		push {r0-r3,lr}
		bl system32_cache_operation
		pop {r0-r3,lr}

		add block_start, block_start, #4
		b system32_cache_operation_heap_loop

	system32_cache_operation_heap_error:
		mov r0, #1
		b system32_cache_operation_heap_common

	system32_cache_operation_heap_success:
		mov r0, #0

	system32_cache_operation_heap_common:
		mov pc, lr

.unreq block_start
.unreq level
.unreq flag
.unreq block_size


/**
 * function system32_cache_info
 * Return Particular Cache Information
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

	mrc p15, 0, number_core, c0, c0, 5              @ Multiprocessor Affinity Register (MPIDR)
	and number_core, number_core, #0b11

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

	mrc p15, 0, number_core, c0, c0, 5              @ Multiprocessor Affinity Register (MPIDR)
	and number_core, number_core, #0b11

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
	macro32_isb ip                                  @ Flush Data in Pipeline to Cache

	/* Invalidate TLB */
	mov temp, #0
	mcr p15, 0, temp, c8, c7, 0

	macro32_dsb ip                                  @ Ensure Completion of Instructions Before
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

	mrc p15, 0, number_core, c0, c0, 5              @ Multiprocessor Affinity Register (MPIDR)
	and number_core, number_core, #0b11

	mov addr, #0x10000
	mul number_core, number_core, addr              @ 0x10000, 65536 Bytes Offset
	ldr base_addr, SYSTEM32_VADESCRIPTOR_ADDR
	add base_addr, base_addr, number_core

	mov size, #0x3F0                                @ Bit[31:20], Max 0xFFF
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
	orr descriptor, descriptor, #equ32_mmu_section_access_rw_rw
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

	mov size, #0x3F0                                @ Bit[31:20], Max 0xFFF
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
	orr descriptor, descriptor, #equ32_mmu_section_access_rw_rw
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

	system32_clear_heap_loop:
		cmp heap_start, heap_size
		bge system32_clear_heap_common      @ If Heap Space Overflow

		str heap_bytes, [heap_start]

		add heap_start, heap_start, #4
		b system32_clear_heap_loop          @ If Bytes are not Zero

	system32_clear_heap_common:
		macro32_dsb ip                          @ Ensure Completion of Instructions Before
		mov r0, #0
		mov pc, lr

.unreq heap_start
.unreq heap_size
.unreq heap_bytes


/**
 * function system32_malloc
 * Get Memory Space from Heap (4 Bytes Align)
 * Allocated Memory Size is Stored from the Address where Start Address of Memory Minus 4 Bytes
 * Argument, Size Means Number of Block which Has 4 Bytes
 *
 * Parameters
 * r0: Number of Block Size of Memory, 1 Block means 4 bytes
 *
 * Usage: r0-r5
 * Return: r0 (Pointer of Start Address of Memory Space, If Zero, Memory Allocation Fails)
 */
.globl system32_malloc
system32_malloc:
	/* Auto (Local) Variables, but just Aliases */
	size        .req r0 @ Parameter, Register for Argument and Result, Scratch Register, Block (4 Bytes) Size
	heap_start  .req r1
	heap_size   .req r2
	heap_bytes  .req r3
	check_start .req r4
	check_size  .req r5

	push {r4,r5}

	lsl size, size, #2                          @ Substitution of Multiplication by 4, Blocks to Bytes

	ldr heap_start, SYSTEM32_HEAP_ADDR
	ldr heap_size, SYSTEM32_HEAP_SIZE           @ In Bytes

	macro32_dsb ip                              @ Ensure Completion of Instructions Beforee

	add heap_size, heap_start, heap_size

	system32_malloc_loop:
		cmp heap_start, heap_size
		bge system32_malloc_error               @ If Heap Space Overflow

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
				bge system32_malloc_error               @ If Heap Space Overflow

				cmp check_start, check_size
				bgt system32_malloc_success             @ Inclusive Loop Because Memory Needs Its Required Size Plus 4 Bytes

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
		pop {r4,r5}
		mov pc, lr

.unreq size
.unreq heap_start
.unreq heap_size
.unreq heap_bytes
.unreq check_start
.unreq check_size


.globl SYSTEM32_HEAP
SYSTEM32_HEAP:        .word SYSTEM32_HEAP_ADDR
SYSTEM32_HEAP_ADDR:   .word _SYSTEM32_HEAP
SYSTEM32_HEAP_SIZE:   .word _SYSTEM32_HEAP_END - _SYSTEM32_HEAP

.globl SYSTEM32_VADESCRIPTOR
SYSTEM32_VADESCRIPTOR: .word SYSTEM32_VADESCRIPTOR_ADDR
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
 * Make sure to complete addresses of variables by `str/ldr Rd, [PC, #Immediate]`,
 * othewise, compiler can't recognaize labels of variables or literal pool.
 * This Immediate can't be over #4095 (0xFFF), i.e. within 4K Bytes.
 * But if you assign ".globl" to the label, then these are mapped when using `ld`, a linker (please check out inter.map).
 * These are useful if you use `extern` in C lang file, or use the label in other assembler lang files.
 */

.include "system32/usb2032.s"
.balign 4

/**
 * "library_system32" is to be used for libraries, Drawing, Sound, Color, Font, etc. which have
 * compatibility with other ARM CPUs. 
 */
.section	.library_system32

/* print32.s uses memory spaces in fb32.s, so this file is needed to close to fb32.s within 4K bytes */
.include "system32/print32.s"
.balign 4
.include "system32/fb32.s"
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

_SYSTEM32_HEAP:
.fill 16777216, 1, 0x00
_SYSTEM32_HEAP_END:

_SYSTEM32_VADESCRIPTOR:
.fill 262144, 1, 0x00
_SYSTEM32_VADESCRIPTOR_END:
