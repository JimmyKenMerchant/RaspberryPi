/**
 * system32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.section	.system

.include "system32/equ32.s"

/**
 * Variables
 */
.globl SYSTEM32_SYSTEMTIMER_BASE
.globl SYSTEM32_INTERRUPT_BASE
.globl SYSTEM32_ARMTIMER_BASE
.globl SYSTEM32_MAILBOX_BASE
.globl SYSTEM32_GPIO_BASE
.balign 4
SYSTEM32_SYSTEMTIMER_BASE:   .word 0x00003000
SYSTEM32_INTERRUPT_BASE:     .word 0x0000B200
SYSTEM32_ARMTIMER_BASE:      .word 0x0000B400
SYSTEM32_MAILBOX_BASE:       .word 0x0000B880
SYSTEM32_GPIO_BASE:          .word 0x00200000


/**
 * function system32_call_core
 * Call 1-3 Cores
 * This function is depends on RasPi's original start.elf
 *
 * Parameters
 * r0: Program Address to Start Core
 * r1: Number of Core
 *
 * Usage: r0-r2
 * Return: r0 (0 as sucess, 1 as error), 
 * Error: Number of Core does not exist or assigned Core0
 */
.globl system32_call_core
system32_call_core:
	/* Auto (Local) Variables, but just aliases */
	addr_start   .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	core_number  .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	temp         .req r2

	cmp core_number, #3                      @ 1 <= mailbox_number <= 3
	bgt system32_call_core_error
	cmp core_number, #1
	blt system32_call_core_error

	mov temp, #equ32_cores_mailbox_offset
	mul core_number, temp, core_number       @ Multiply Mailbox Offset to core_number

	add core_number, core_number, #equ32_cores_mailbox3_writeset
	add core_number, core_number, #equ32_cores_base

	str addr_start, [core_number]

	b system32_call_core_success

	system32_call_core_error:
		mov r0, #1
		b system32_call_core_common

	system32_call_core_success:
		mov r0, #0

	system32_call_core_common:
		mov pc, lr

.unreq addr_start
.unreq core_number
.unreq temp


/**
 * function system32_mailbox_read
 * Wait and Read Mail from GPU/ Other Cores
 *
 * Parameters
 * r0: Number of Mailbox, 0-3
 *
 * Usage: r0-r4
 * Return: r0 Reply Content, r1 (0 as sucess, 1 as error), 
 * Error: Number of Mailbox does not exist
 */
.globl system32_mailbox_read
system32_mailbox_read:
	/* Auto (Local) Variables, but just aliases */
	mailbox_number  .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	memorymap_base  .req r1
	temp            .req r2
	status          .req r3
	read            .req r4

	push {r4}

	cmp mailbox_number, #3                   @ 0 <= mailbox_number <= 3
	bgt system32_mailbox_read_error
	cmp mailbox_number, #0
	blt system32_mailbox_read_error

	mov temp, #equ32_mailbox_offset
	mul mailbox_number, temp, mailbox_number @ Multiply Mailbox Offset to mailbox_number

	mov status, mailbox_number
	mov read, mailbox_number

	add status, #equ32_mailbox_status
	add read, #equ32_mailbox_read

	mov memorymap_base, #equ32_peripherals_base
	ldr temp, SYSTEM32_MAILBOX_BASE
	add memorymap_base, memorymap_base, temp

	system32_mailbox_read_waitforread:
		ldr temp, [memorymap_base, status]
		cmp temp, #0x40000000                  @ Wait for Empty Flag is Cleared
		beq system32_mailbox_read_waitforread

	dmb                                      @ `DMB` Data Memory Barrier, completes all memory access before
                                                 @ `DSB` Data Synchronization Barrier, completes all instructions before
                                                 @ `ISB` Instruction Synchronization Barrier, flushes the pipeline before,
                                                 @ to ensure to fetch data from cache/ memory
                                                 @ These are useful in multi-core/ threads usage, etc.

	ldr r0, [memorymap_base, read]

	b system32_mailbox_read_success

	system32_mailbox_read_error:
		mov r0, #0
		mov r1, #1
		b system32_mailbox_read_common

	system32_mailbox_read_success:
		mov r1, #0

	system32_mailbox_read_common:
		pop {r4}
		mov pc, lr

.unreq mailbox_number
.unreq memorymap_base
.unreq temp
.unreq status
.unreq read


/**
 * function system32_mailbox_send
 * Wait and Send Mail to GPU/ Other Cores
 *
 * Parameters
 * r0: Content of Mail to Send
 * r1: Number of Mailbox, 0-3
 *
 * Usage: r0-r5
 * Return: r0 Reply Content, r1 (0 as sucess, 1 as error)
 * Error: Number of Mailbox does not exist
 */
.globl system32_mailbox_send
system32_mailbox_send:
	/* Auto (Local) Variables, but just aliases */
	mail_content    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	mailbox_number  .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	memorymap_base  .req r2
	temp            .req r3
	status          .req r4
	write           .req r5

	push {r4-r5}

	cmp mailbox_number, #3                   @ 0 <= mailbox_number <= 3
	bgt system32_mailbox_send_error
	cmp mailbox_number, #0
	blt system32_mailbox_send_error

	mov temp, #equ32_mailbox_offset
	mul mailbox_number, temp, mailbox_number @ Multiply Mailbox Offset to mailbox_number

	mov status, mailbox_number
	mov write, mailbox_number

	add status, #equ32_mailbox_status
	add write, #equ32_mailbox_write

	mov memorymap_base, #equ32_peripherals_base
	ldr temp, SYSTEM32_MAILBOX_BASE
	add memorymap_base, memorymap_base, temp

	system32_mailbox_send_waitforwrite:
		ldr temp, [memorymap_base, status]
		cmp temp, #0x80000000                  @ Wait for Full Flag is Cleared
		beq system32_mailbox_send_waitforwrite

	dmb                                      @ `DMB` Data Memory Barrier, completes all memory access before

	str mail_content, [memorymap_base, write]

	b system32_mailbox_send_success

	system32_mailbox_send_error:
		mov r0, #0
		mov r1, #1
		b system32_mailbox_send_common

	system32_mailbox_send_success:
		mov r1, #0

	system32_mailbox_send_common:
		pop {r4-r5}
		mov pc, lr

.unreq mail_content
.unreq mailbox_number
.unreq memorymap_base
.unreq temp
.unreq status
.unreq write


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
 * Return: r0 (0 as sucess, 1 as error)
 * Error: Align Bytes is not 2/4
 */
.globl system32_convert_endianness
system32_convert_endianness:
	/* Auto (Local) Variables, but just aliases */
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
	push {r4-r5}
	mov r1, #equ32_peripherals_base
	ldr r2, SYSTEM32_SYSTEMTIMER_BASE
	add r1, r1, r2
	ldr r2, [r1, #equ32_systemtimer_counter_lower]  @ Get Lower 32 Bits
	ldr r3, [r1, #equ32_systemtimer_counter_higher] @ Get Higher 32 Bits
	adds r2, r0                            @ Add with Changing Status Flags
	adc r3, #0                             @ Add with Carry Flag

	system32_sleep_loop:
		ldr r4, [r1, #equ32_systemtimer_counter_lower]
		ldr r5, [r1, #equ32_systemtimer_counter_higher]
		cmp r3, r5                     @ Similar to `SUBS`, Compare Higher 32 Bits
		cmpeq r2, r4                   @ Compare Lower 32 Bits if the Same on Higher 32 Bits
		bgt system32_sleep_loop

	pop {r4-r5}
	mov pc, lr


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
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
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
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
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
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
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
 * function system32_clear_heap
 * Clear (All Zero) in Heap
 *
 * Usage: r0-r2
 * Return: r0 (0 as Success)
 */
.globl system32_clear_heap
system32_clear_heap:
	/* Auto (Local) Variables, but just aliases */
	heap_start  .req r0
	heap_size   .req r1
	heap_bytes  .req r2

	ldr heap_start, SYSTEM32_HEAP_ADDR
	ldr heap_size, SYSTEM32_HEAP_SIZE           @ In Bytes

	add heap_size, heap_start, heap_size

	mov heap_bytes, #0

	system32_clear_heap_loop:
		cmp heap_start, heap_size
		bge system32_clear_heap_common      @ If Heap Space Overflow

		str heap_bytes, [heap_start]

		add heap_start, heap_start, #4
		b system32_clear_heap_loop          @ If Bytes are not Zero

	system32_clear_heap_common:
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
 * r0: Size of Memory
 *
 * Usage: r0-r5
 * Return: r0 (Pointer of Start Address of Memory Space, If Zero, Memory Allocation Fails)
 */
.globl system32_malloc
system32_malloc:
	/* Auto (Local) Variables, but just aliases */
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

/**
 * function system32_mfree
 * Free Memory Space in Heap
 * Allocated Memory Size is Stored from the Address where Start Address of Memory Minus 4 Bytes
 *
 * Parameters
 * r1: Pointer of Start Address of Memory Space
 *
 * Usage: r0-r2
 * Return: r0 (0 as Success, 1 as Error)
 */
.globl system32_mfree
system32_mfree:
	/* Auto (Local) Variables, but just aliases */
	heap_start      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	heap_size       .req r1
	zero            .req r2

	ldr heap_size, [heap_start, #-4]
	add heap_size, heap_start, heap_size
	sub heap_start, heap_start, #4

	mov zero, #0

	system32_mfree_loop:
		cmp heap_start, heap_size
		bge system32_mfree_common

		str zero, [heap_start]
		add heap_start, heap_start, #4

		b system32_mfree_loop

	system32_mfree_common:
		mov r0, #0
		mov pc, lr

.unreq heap_start
.unreq heap_size
.unreq zero


/**
 * These Asm Files includes Enviromental Variables.
 * Make sure to reach Address of Variables by `str/ldr Rd, [PC, #Immediate]`,
 * othewise, Compiler can't recognaize Labels of Variables or these Literal Pool.
 * This Immediate Can't be Over #4095 (0xFFF), i.e. within 4K Bytes.
 * BUT if you assign ".globl" to the label, then these are mapped when linker (check inter.map).
 * These are useful if you use `extern` in C lang file.
 */
.balign 4
.include "system32/fb32.s"
.balign 4
/* print32.s uses memory spaces in fb32.s, so this file is needed to close to fb32.s within 4K bytes */
.include "system32/print32.s"
.balign 4
.include "system32/math32.s"
.balign 4
.include "system32/font_mono_12px.s"
.balign 4
.include "system32/color.s"
.balign 4
.include "system32/data.s"            @ Having Section .data
.balign 4

.section .system

.section .bss

_SYSTEM32_FB32_RENDERBUFFER0:
.fill 16777216, 1, 0x00

_SYSTEM32_FB32_RENDERBUFFER1:
.fill 16777216, 1, 0x00

_SYSTEM32_FB32_RENDERBUFFER2:
.fill 16777216, 1, 0x00

_SYSTEM32_FB32_RENDERBUFFER3:
.fill 16777216, 1, 0x00

_SYSTEM32_HEAP:
.fill 16777216, 1, 0x00
_SYSTEM32_HEAP_END:
