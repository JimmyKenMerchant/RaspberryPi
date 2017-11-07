/**
 * dma32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.equ dma32_offset,                0x00000020 @ Offset of Each CB (32 Bytes)
.equ dma32_ti,                    0x00000000 @ Transfer Information
.equ dma32_source_ad,             0x00000004 @ Source Address
.equ dma32_dest_ad,               0x00000008 @ Destination Address
.equ dma32_txfr_len,              0x0000000C @ Transfer Length
.equ dma32_stride,                0x00000010 @ 2D Stride
.equ dma32_nextconbk,             0x00000014 @ Next CB Addres


/**
 * function dma32_set_channel
 * Set DMA Channel
 *
 * Parameters
 * r0: Channel of DMA
 * r1: Pointer of Control Block (CB)
 *
 * Return: r0 (0 as Success, 1 as Error)
 * Error: Channel of DMA is Overflow
 */
.globl dma32_set_channel
dma32_set_channel:
	/* Auto (Local) Variables, but just Aliases */
	channel    .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	addr_cb    .req r1
	addr_dma   .req r2
	temp       .req r3
	temp2      .req r4

	push {r4}

	cmp channel, #14
	bhi dma32_set_channel_error

	mov addr_dma, #equ32_peripherals_base
	add addr_dma, addr_dma, #equ32_dma_base

	mov temp2, #1

	ldr temp, [addr_dma, #equ32_dma_channel_enable]
	orr temp, temp, temp2, lsl channel              @ Enable DMA ChannelN
	str temp, [addr_dma, #equ32_dma_channel_enable]

	mov temp, #equ32_dma_channel_offset
	mul temp, channel, temp
	add addr_dma, addr_dma, temp

	/* Load CB */
	str addr_cb, [addr_dma, #equ32_dma_conblk_ad]

	/* Activate CB */
	ldr temp, [addr_dma, #equ32_dma_cs]
	orr temp, temp, #equ32_dma_cs_active
	str temp, [addr_dma, #equ32_dma_cs]

	macro32_dsb ip

	b dma32_set_channel_success

	dma32_set_channel_error:
		mov r0, #1
		b dma32_set_channel_common

	dma32_set_channel_success:
		mov r0, #0

	dma32_set_channel_common:
		pop {r4}
		mov pc, lr

.unreq channel
.unreq addr_cb
.unreq addr_dma
.unreq temp
.unreq temp2


/**
 * function dma32_clear_channel
 * Set DMA Channel
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
	orr temp, temp, temp2, lsl channel              @ Enable DMA ChannelN
	str temp, [addr_dma, #equ32_dma_channel_enable]

	mov temp, #equ32_dma_channel_offset
	mul temp, channel, temp
	add addr_dma, addr_dma, temp

	/* Deactivate CB */
	ldr temp, [addr_dma, #equ32_dma_cs]
	bic temp, temp, #equ32_dma_cs_active
	str temp, [addr_dma, #equ32_dma_cs]

	/* DMA ChannelN Reset */
	ldr temp, [addr_dma, #equ32_dma_cs]
	orr temp, temp, #equ32_dma_cs_reset
	str temp, [addr_dma, #equ32_dma_cs] 

	mov addr_dma, #equ32_peripherals_base
	add addr_dma, addr_dma, #equ32_dma_base

	ldr temp, [addr_dma, #equ32_dma_channel_enable]
	bic temp, temp, temp2, lsl channel              @ Disable DMA ChannelN
	str temp, [addr_dma, #equ32_dma_channel_enable]

	macro32_dsb ip

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
 * function dma32_set_cb
 * Set Control Block
 *
 * Parameters
 * r0: Number of Control Blocks (CB)
 * r1: Transfer Information
 * r2: Source Address
 * r3: Destination Address
 * r4: Transfer Length
 * r5: 2D Stride
 * r6: Next CB Addres
 *
 * Return: r0 (Pointer of Control Block, If -1, Number of CB is Overflow)
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

	cmp number_cb, #9
	bhi dma32_set_cb_error

	ldr addr_cb, DMA32_CB
	mov mul_number, #32
	mul number_cb, mul_number, number_cb
	add addr_cb, addr_cb, number_cb
	
	/* Channel Block Setting */

	str ti, [addr_cb, #dma32_ti]                   @ Transfer Information
	str source_ad, [addr_cb, #dma32_source_ad]     @ Source Address
	str dest_ad, [addr_cb, #dma32_dest_ad]         @ Destination Address
	str txfr_len, [addr_cb, #dma32_txfr_len]       @ Transfer Length
	str stride, [addr_cb, #dma32_stride]           @ 2D Stride
	str nextconbk, [addr_cb, #dma32_nextconbk]     @ Next CB Address

	macro32_dsb ip

	macro32_clean_cache addr_cb, ip

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
DMA32_CB:        .word DMA32_CB0_TI

.balign 32                        @ 32 Bytes (8 Words) Aligned
DMA32_CB0_TI:
.space 320                        @ 10 Control Blocks
