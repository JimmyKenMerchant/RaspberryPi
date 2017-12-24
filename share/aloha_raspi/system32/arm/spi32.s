/**
 * spi32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function spi32_spiclk
 * Set SPI Clock
 *
 * Parameters
 * r0: Divisor of Clock (Must Be a Multiples of 2/ Even)
 *
 * Return: r0 (0 as Success)
 */
.globl spi32_spiclk
spi32_spiclk:
	/* Auto (Local) Variables, but just Aliases */
	divisor    .req r0
	addr_spi   .req r1

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	str divisor, [addr_spi, #equ32_spi0_clk]
	macro32_dsb ip

	spi32_spiclk_success:
		mov r0, #0

	spi32_spiclk_common:
		mov pc, lr

.unreq divisor 
.unreq addr_spi


/**
 * function spi32_spitx
 * SPI Activate and Transfer
 *
 * Parameters
 * r0: Control and Status
 * r1: Data to Be Send
 *
 * Return: r0 (0 as Success)
 */
.globl spi32_spitx
spi32_spitx:
	/* Auto (Local) Variables, but just Aliases */
	cs         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	data_send  .req r1
	i          .req r2
	addr_spi   .req r3
	byte       .req r4
	temp       .req r5

	push {r4-r5}

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	ldr temp, [addr_spi, #equ32_spi0_cs]
	tst temp, #equ32_spi0_cs_ta
	bne spi32_spitx_txfifo_jump                 @ If TA has Been Already Set

	bic cs, cs, #equ32_spi0_cs_ta
	str cs, [addr_spi, #equ32_spi0_cs]          @ Set Except TA
	macro32_dsb ip

	ldr cs, [addr_spi, #equ32_spi0_cs]
	orr cs, cs, #equ32_spi0_cs_ta
	str cs, [addr_spi, #equ32_spi0_cs]          @ Start of Transfer
	macro32_dsb ip

	spi32_spitx_txfifo_jump:
		mov i, #3

	spi32_spitx_txfifo:
		ldr cs, [addr_spi, #equ32_spi0_cs]
		tst cs, #equ32_spi0_cs_txd              @ If Having Space on TxFIFO
		lslne temp, i, #3                       @ Substitute of Multiplication by 8 (Per Byte)
		lsrne byte, data_send, temp
		andne byte, byte, #0xFF
		strne byte, [addr_spi, #equ32_spi0_fifo]
		subne i, i, #1
		cmp i, #0
		bge spi32_spitx_txfifo

	spi32_spitx_success:
		mov r0, #0

	spi32_spitx_common:
		pop {r4-r5}
		mov pc, lr

.unreq cs
.unreq data_send
.unreq i
.unreq addr_spi
.unreq byte
.unreq temp


/**
 * function spi32_spirx
 * SPI Receive and Deactivate If Done
 *
 * Return: r0 (Data to Be Received)
 */
.globl spi32_spirx
spi32_spirx:
	/* Auto (Local) Variables, but just Aliases */
	cs           .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	data_receive .req r1
	i            .req r2
	addr_spi     .req r3
	byte         .req r4
	temp         .req r5

	push {r4-r5}

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	mov data_receive, #0

	mov i, #3
	spi32_spirx_rxfifo:
		ldr cs, [addr_spi, #equ32_spi0_cs]
		tst cs, #equ32_spi0_cs_rxd
		beq spi32_spirx_deactivate               @ If Having No Data on RxFIFO
		ldrne byte, [addr_spi, #equ32_spi0_fifo] @ If Having Data on RxFIFO
		lslne temp, i, #3                        @ Substitute of Multiplication by 8 (Per Byte)
		lslne byte, byte, temp
		addne data_receive, data_receive, byte
		subne i, i, #1
		cmp i, #0
		bge spi32_spirx_rxfifo

	spi32_spirx_deactivate:
		ldr cs, [addr_spi, #equ32_spi0_cs]
		tst cs, #equ32_spi0_cs_done             @ Check If Done, End of Transer
		beq spi32_spirx_success

		bic cs, cs, #equ32_spi0_cs_ta
		str cs, [addr_spi, #equ32_spi0_cs]
		macro32_dsb ip

		b spi32_spirx_success

	spi32_spirx_success:
		mov r0, data_receive

	spi32_spirx_common:
		pop {r4-r5}
		mov pc, lr

.unreq cs
.unreq data_receive
.unreq i
.unreq addr_spi
.unreq byte
.unreq temp
