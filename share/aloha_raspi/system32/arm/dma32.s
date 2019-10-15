/**
 * dma32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.equ dma32_offset,                0x00000020 @ Offset of Each CB (32 Bytes = 256 Bits)
.equ dma32_ti,                    0x00000000 @ Transfer Information
.equ dma32_source_ad,             0x00000004 @ Source Address
.equ dma32_dest_ad,               0x00000008 @ Destination Address
.equ dma32_txfr_len,              0x0000000C @ Transfer Length
.equ dma32_stride,                0x00000010 @ 2D Stride
.equ dma32_nextconbk,             0x00000014 @ Next CB Addres


/**
 * function dma32_datacopy
 * Copy Data Using DMA
 * The DMA channel is enabled, once this function is executed.
 *
 * Parameters
 * r0: Pointer of Destination in Bus Address
 * r1: Pointer of Source in Bus Address
 * r2: Size (Bytes) Up to 65535 Bytes
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error(1): Channel of DMA or CB Number is Overflow
 */
.globl dma32_datacopy
dma32_datacopy:
	/* Auto (Local) Variables, but just Aliases */
	addr_dst       .req r0
	addr_src       .req r1
	size           .req r2
	semaphore      .req r3
	channel        .req r4
	number_cb      .req r5
	number_core    .req r6
	temp           .req r7
	addr_semaphore .req r8

	push {r4-r8,lr}

	dma32_datacopy_checksemaphore:
		/**
		 * Decrement of Semaphore Value
		 * From ARMv6, ldrex and strex are added for multi-core handling.
		 */
		ldr addr_semaphore, dma32_datacopy_semaphore_addr
		ldrex semaphore, [addr_semaphore]              @ Set Exclusive Flag
		macro32_dsb ip
		cmp semaphore, #0
		beq dma32_datacopy_checksemaphore
		sub semaphore, semaphore, #1
		/**
		 * Clear exclusive flag and store if allowed.
		 * If the flag has already cleared by any other core, storing is not allowed.
		 */
		strex temp, semaphore, [addr_semaphore]
		macro32_dsb ip
		cmp temp, #0                                   @ Check Success on Storing
		bne dma32_datacopy_checksemaphore

	cmp semaphore, #equ32_dma32_cb_dma32_size
	bhs dma32_datacopy_error
	cmp semaphore, #equ32_dma32_channel_dma32_size
	bhs dma32_datacopy_error

	mov channel, #equ32_dma32_channel_dma32
	add channel, channel, semaphore
	cmp channel, #14
	bhi dma32_datacopy_error

	mov number_cb, #equ32_dma32_cb_dma32
	add number_cb, number_cb, semaphore
	cmp number_cb, #equ32_dma32_cb_max
	bhs dma32_datacopy_error

	push {r0-r6}
	mov r3, addr_dst                                        @ Destination Address
	mov r0, number_cb
	mov r4, size                                            @ Transfer Size
	mov r2, addr_src                                        @ Source Address
	mov r1, #0<<equ32_dma_ti_permap                         @ DREQ Map for No DREQ
	bic r1, r1, #equ32_dma_ti_no_wide_bursts
	orr r1, r1, #0<<equ32_dma_ti_waits
	orr r1, r1, #0<<equ32_dma_ti_burst_length
	orr r1, r1, #equ32_dma_ti_src_inc                       @ Transfer Information Source
	orr r1, r1, #equ32_dma_ti_dst_inc                       @ Transfer Information Destination
	orr r1, r1, #equ32_dma_ti_wait_resp
	mov r5, #0                                              @ 2D Stride
	mov r6, #-1                                             @ Next CB Number
	push {r4-r6}
	bl dma32_set_cb
	add sp, sp, #12
	pop {r0-r6}

	push {r0-r3}
	mov r0, channel
	mov r1, number_cb
	bl dma32_set_channel
	pop {r0-r3}

	dma32_datacopy_wait:
		push {r0-r3}
		mov r0, channel
		mov r1, size
		bl dma32_wait_channel
		mov temp, r0
		pop {r0-r3}
		cmp temp, #0
		bne dma32_datacopy_wait

	b dma32_datacopy_success

	dma32_datacopy_error:
		mov r0, #1
		b dma32_datacopy_common

	dma32_datacopy_success:
		mov r0, #0

	dma32_datacopy_common:
		/* Increment of Semaphore Value */
		ldr addr_semaphore, dma32_datacopy_semaphore_addr
		ldrex semaphore, [addr_semaphore]              @ Set Exclusive Flag
		macro32_dsb ip
		add semaphore, semaphore, #1
		strex temp, semaphore, [addr_semaphore]
		macro32_dsb ip
		cmp temp, #0                                   @ Check Success on Storing
		bne dma32_datacopy_common
		pop {r4-r8,pc}

.unreq addr_dst
.unreq addr_src
.unreq size
.unreq semaphore
.unreq channel
.unreq number_cb
.unreq number_core
.unreq temp
.unreq addr_semaphore

/* Two Channels Avaialble (4 and 5 in Default) */
dma32_datacopy_semaphore_addr: .word dma32_datacopy_semaphore
dma32_datacopy_semaphore:      .word 2


/**
 * function dma32_set_channel
 * Set DMA Channel
 *
 * Parameters
 * r0: Channel of DMA
 * r1: Control Block (CB) Number
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Channel of DMA or CB Number is Overflow
 */
.globl dma32_set_channel
dma32_set_channel:
	/* Auto (Local) Variables, but just Aliases */
	channel    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	number_cb  .req r1
	addr_dma   .req r2
	temp       .req r3
	temp2      .req r4
	addr_cb    .req r5

	push {r4-r5}

	cmp channel, #14
	bhi dma32_set_channel_error

	cmp number_cb, #equ32_dma32_cb_max
	bhs dma32_set_channel_error

	ldr addr_cb, DMA32_CB                          @ Base Address of CBs
	mov temp, #32                                  @ 256-bit Align
	mul number_cb, temp, number_cb                 @ Offset of Targeted CB
	add addr_cb, addr_cb, number_cb                @ Address of Targeted CB (ARM Side)
	/* Transform to Bus Address (GPU, DMA, and Peripherals Recognize This Address Space as Point of Coherency with ARM) */
	add addr_cb, addr_cb, #equ32_bus_coherence_base

	mov addr_dma, #equ32_peripherals_base
	add addr_dma, addr_dma, #equ32_dma_base

	mov temp2, #1

	ldr temp, [addr_dma, #equ32_dma_channel_enable]
	tst temp, temp2, lsl channel
	orreq temp, temp, temp2, lsl channel           @ Enable DMA ChannelN
	str temp, [addr_dma, #equ32_dma_channel_enable]

	macro32_dsb ip

	mov temp, #equ32_dma_channel_offset
	mul temp, channel, temp
	add addr_dma, addr_dma, temp

	/* Reset DMA */	

	ldr temp, [addr_dma, #equ32_dma_cs]
	orr temp, temp, #equ32_dma_cs_reset
	str temp, [addr_dma, #equ32_dma_cs]

	macro32_dsb ip

	/* Load CB */
	str addr_cb, [addr_dma, #equ32_dma_conblk_ad]

	macro32_dsb ip

	/* Activate CB */
	ldr temp, [addr_dma, #equ32_dma_cs]
	orr temp, temp, #equ32_dma_cs_active
	orr temp, temp, #equ32_dma_cs_wait_writes
	orr temp, temp, #0<<equ32_dma_cs_panic_priority
	orr temp, temp, #0<<equ32_dma_cs_priority
	str temp, [addr_dma, #equ32_dma_cs]

	b dma32_set_channel_success

	dma32_set_channel_error:
		mov r0, #1
		b dma32_set_channel_common

	dma32_set_channel_success:
		mov r0, #0

	dma32_set_channel_common:
		pop {r4-r5}
		mov pc, lr

.unreq channel
.unreq number_cb
.unreq addr_dma
.unreq temp
.unreq temp2
.unreq addr_cb


/**
 * function dma32_wait_channel
 * Wait for DMA Channel
 *
 * Parameters
 * r0: Channel of DMA
 * r1: Time Out in Turns
 *
 * Return: r0 (0 as Success, 1 and 2 as Error)
 * Error(1): Time Out
 * Error(2): Channel of DMA is Overflow
 */
.globl dma32_wait_channel
dma32_wait_channel:
	/* Auto (Local) Variables, but just Aliases */
	channel    .req r0
	timeout    .req r1
	addr_dma   .req r2
	temp       .req r3

	cmp channel, #14
	bhi dma32_wait_channel_error2

	mov addr_dma, #equ32_peripherals_base
	add addr_dma, addr_dma, #equ32_dma_base

	mov temp, #equ32_dma_channel_offset
	mul temp, channel, temp
	add addr_dma, addr_dma, temp

	macro32_dsb ip

	dma32_wait_channel_loop:
		subs timeout, #1
		blo dma32_wait_channel_error1
		ldr temp, [addr_dma, #equ32_dma_cs]
		tst temp, #equ32_dma_cs_active
		beq dma32_wait_channel_success             @ If Not Active
		macro32_dsb ip
		b dma32_wait_channel_loop

	dma32_wait_channel_error1:
		mov r0, #1
		b dma32_wait_channel_common

	dma32_wait_channel_error2:
		mov r0, #2
		b dma32_wait_channel_common

	dma32_wait_channel_success:
		mov r0, #0

	dma32_wait_channel_common:
		mov pc, lr

.unreq channel
.unreq timeout
.unreq addr_dma
.unreq temp


/**
 * function dma32_clear_channel
 * Clear DMA Channel
 *
 * Parameters
 * r0: Channel of DMA
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Channel of DMA is Overflow
 */
.globl dma32_clear_channel
dma32_clear_channel:
	/* Auto (Local) Variables, but just Aliases */
	channel    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	addr_dma   .req r1
	temp       .req r2
	temp2      .req r3

	cmp channel, #14
	bhi dma32_clear_channel_error

	mov addr_dma, #equ32_peripherals_base
	add addr_dma, addr_dma, #equ32_dma_base

	mov temp2, #1

	ldr temp, [addr_dma, #equ32_dma_channel_enable]
	tst temp, temp2, lsl channel
	orreq temp, temp, temp2, lsl channel            @ Enable DMA ChannelN
	str temp, [addr_dma, #equ32_dma_channel_enable]

	mov temp, #equ32_dma_channel_offset
	mul temp, channel, temp
	add addr_dma, addr_dma, temp

	/* Stop Current Control Block */

	ldr temp, [addr_dma, #equ32_dma_cs]
	tst temp, #equ32_dma_cs_active
	beq dma32_clear_channel_jump                    @ If Not Active
	bic temp, temp, #equ32_dma_cs_active            @ equ32_dma_cs_abort Cuts Wave
	str temp, [addr_dma, #equ32_dma_cs]

	macro32_dsb ip

	mov temp, #0

	str temp, [addr_dma, #equ32_dma_nextconbk]      @ Next CB Address to Zero

	macro32_dsb ip

	ldr temp, [addr_dma, #equ32_dma_cs]
	orr temp, temp, #equ32_dma_cs_active
	str temp, [addr_dma, #equ32_dma_cs]

	dma32_clear_channel_loop1:
		ldr temp, [addr_dma, #equ32_dma_cs]
		tst temp, #equ32_dma_cs_active
		bne dma32_clear_channel_loop1

	dma32_clear_channel_jump:

		orr temp, temp, #equ32_dma_cs_reset
		str temp, [addr_dma, #equ32_dma_cs]

		macro32_dsb ip

		mov addr_dma, #equ32_peripherals_base
		add addr_dma, addr_dma, #equ32_dma_base

		ldr temp, [addr_dma, #equ32_dma_channel_enable]
		bic temp, temp, temp2, lsl channel              @ Disable DMA ChannelN
		str temp, [addr_dma, #equ32_dma_channel_enable]

		b dma32_clear_channel_success

	dma32_clear_channel_error:
		mov r0, #1
		b dma32_clear_channel_common

	dma32_clear_channel_success:
		mov r0, #0

	dma32_clear_channel_common:
		mov pc, lr

.unreq channel
.unreq addr_dma
.unreq temp
.unreq temp2


/**
 * function dma32_change_nextcb
 * Change Next Control Block
 *
 * Parameters
 * r0: Channel of DMA
 * r1: Next Control Blocks (CB) Number
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Channel of DMA or Next CB Number is Overflow
 */
.globl dma32_change_nextcb
dma32_change_nextcb:
	/* Auto (Local) Variables, but just Aliases */
	channel      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	nextconbk    .req r1 @ Parameter, Register for Argument
	addr_dma     .req r2
	addr_nextcb  .req r3
	temp         .req r4

	push {r4}

	cmp channel, #14
	bhi dma32_change_nextcb_error

	cmp nextconbk, #equ32_dma32_cb_max
	bhs dma32_change_nextcb_error

	mov addr_dma, #equ32_peripherals_base
	add addr_dma, addr_dma, #equ32_dma_base
	mov temp, #equ32_dma_channel_offset
	mul temp, channel, temp
	add addr_dma, addr_dma, temp

	ldr addr_nextcb, DMA32_CB                         @ Base Address of CBs
	mov temp, #32                                     @ 256-bit Align
	mul temp, nextconbk, temp                         @ Offset of Next CB
	add addr_nextcb, addr_nextcb, temp                @ Address of Next CB (ARM Side)
	/* Transform to Bus Address (GPU, DMA, and Peripherals Recognize This Address Space as Point of Coherency with ARM) */
	add addr_nextcb, addr_nextcb, #equ32_bus_coherence_base

	/* Stop Current Control Block */

	ldr temp, [addr_dma, #equ32_dma_cs]
	bic temp, temp, #equ32_dma_cs_active              @ equ32_dma_cs_abort Cuts Wave
	str temp, [addr_dma, #equ32_dma_cs]

/*
ldr temp, [addr_dma, #equ32_dma_ti]            @ Transfer Information
macro32_debug temp, 200, 300
ldr temp, [addr_dma, #equ32_dma_source_ad]     @ Source Address
macro32_debug temp, 200, 312
ldr temp, [addr_dma, #equ32_dma_dest_ad]       @ Destination Address
macro32_debug temp, 200, 324
ldr temp, [addr_dma, #equ32_dma_txfr_len]      @ Transfer Length
macro32_debug temp, 200, 336
ldr temp, [addr_dma, #equ32_dma_stride]        @ 2D Stride
macro32_debug temp, 200, 348
ldr temp, [addr_dma, #equ32_dma_nextconbk]     @ Next CB Address
macro32_debug temp, 200, 360
*/

	macro32_dsb ip

	str addr_nextcb, [addr_dma, #equ32_dma_nextconbk]      @ Next CB Address to Zero

	macro32_dsb ip

	/* Activate CB */
	ldr temp, [addr_dma, #equ32_dma_cs]
	orr temp, temp, #equ32_dma_cs_active
	str temp, [addr_dma, #equ32_dma_cs]

	b dma32_change_nextcb_success

	dma32_change_nextcb_error:
		mov r0, #1
		b dma32_change_nextcb_common

	dma32_change_nextcb_success:
		mov r0, #0

	dma32_change_nextcb_common:
		pop {r4}
		mov pc, lr

.unreq channel
.unreq nextconbk
.unreq addr_dma
.unreq addr_nextcb
.unreq temp


/**
 * function dma32_set_cb
 * Set Control Block
 *
 * Parameters
 * r0: Control Blocks (CB) Number
 * r1: Transfer Information
 * r2: Source Address
 * r3: Destination Address
 * r4: Transfer Length
 * r5: 2D Stride
 * r6: Next CB Number, -1 as Nothing of Next CB
 *
 * Return: r0 (Pointer of Control Block, If -1, CB Number is Overflow)
 */
.globl dma32_set_cb
dma32_set_cb:
	/* Auto (Local) Variables, but just Aliases */
	number_cb    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	ti           .req r1 @ Parameter, Register for Argument, Scratch Register
	source_ad    .req r2 @ Parameter, Register for Argument, Scratch Register
	dest_ad      .req r3 @ Parameter, Register for Argument, Scratch Register
	txfr_len     .req r4 @ Parameter, Register for Argument
	stride       .req r5 @ Parameter, Register for Argument
	nextconbk    .req r6 @ Parameter, Register for Argument
	addr_cb      .req r7
	mul_number   .req r8

	push {r4-r8}

	add sp, sp, #20                                @ r4-r8 offset 20 bytes
	pop {r4-r6}                                    @ Get Fifth to Seventh Arguments
	sub sp, sp, #32  

	/* Check Overflow of CB */
	cmp number_cb, #equ32_dma32_cb_max
	bhs dma32_set_cb_error

	/* Check Overflow of Next CB */
	add nextconbk, nextconbk, #1                   @ Convert [-1 to equ32_dma32_cb_max] to [0 to equ32_dma32_cb_max + 1]
	cmp nextconbk, #equ32_dma32_cb_max
	bhi dma32_set_cb_error
	sub nextconbk, nextconbk, #1                   @ Retrieve Next CB Number

	ldr addr_cb, DMA32_CB                          @ Base Address of CBs
	mov mul_number, #32                            @ 256-bit Align

	cmp nextconbk, #-1
	moveq nextconbk, #0
	mulne nextconbk, mul_number, nextconbk         @ Offset of Next CB
	addne nextconbk, addr_cb, nextconbk            @ Address of Next CB (ARM Side)
	/* Transform to Bus Address (GPU, DMA, and Peripherals Recognize This Address Space as Point of Coherency with ARM) */
	addne nextconbk, nextconbk, #equ32_bus_coherence_base

	mul number_cb, mul_number, number_cb           @ Offset of Targeted CB
	add addr_cb, addr_cb, number_cb                @ Address of Targeted CB (ARM Side)
	str ti, [addr_cb, #dma32_ti]                   @ Transfer Information
	str source_ad, [addr_cb, #dma32_source_ad]     @ Source Address
	str dest_ad, [addr_cb, #dma32_dest_ad]         @ Destination Address
	str txfr_len, [addr_cb, #dma32_txfr_len]       @ Transfer Length
	str stride, [addr_cb, #dma32_stride]           @ 2D Stride
	str nextconbk, [addr_cb, #dma32_nextconbk]     @ Next CB Address

	macro32_dsb ip

/*
ldr temp, [addr_cb, #dma32_ti]            @ Transfer Information
macro32_debug temp, 200, 300
ldr temp, [addr_cb, #dma32_source_ad]     @ Source Address
macro32_debug temp, 200, 312
ldr temp, [addr_cb, #dma32_dest_ad]       @ Destination Address
macro32_debug temp, 200, 324
ldr temp, [addr_cb, #dma32_txfr_len]      @ Transfer Length
macro32_debug temp, 200, 336
ldr temp, [addr_cb, #dma32_stride]        @ 2D Stride
macro32_debug temp, 200, 348
ldr temp, [addr_cb, #dma32_nextconbk]     @ Next CB Address
macro32_debug temp, 200, 360
*/

/*
ldr source_ad, [addr_cb, #dma32_source_ad]
macro32_debug source_ad, 100, 150
*/
	macro32_clean_cache addr_cb, ip
	macro32_dsb ip

	b dma32_set_cb_success

	dma32_set_cb_error:
		mvn r0, #0                             @ -1
		b dma32_set_cb_common

	dma32_set_cb_success:
		mov r0, addr_cb

	dma32_set_cb_common:
		pop {r4-r8}
		mov pc, lr

.unreq number_cb
.unreq ti
.unreq source_ad
.unreq dest_ad
.unreq txfr_len
.unreq stride
.unreq nextconbk
.unreq addr_cb
.unreq mul_number


.globl DMA32_CB
DMA32_CB:        .word _DMA32_CB

