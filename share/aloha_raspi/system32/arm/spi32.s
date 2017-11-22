/**
 * spi32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function spi32_spitransaction
 * One Word SPI Transaction
 *
 * Parameters
 * r0: Control and Status
 * r1: Data to Be Send
 * r2: Divisor of Clock (Must Be a Multiples of 2)
 *
 * Return: r0 (Data to Be Received)
 */
.globl spi32_spitransaction
spi32_spitransaction:
	/* Auto (Local) Variables, but just Aliases */
	cs         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	data_send  .req r1
	divisor    .req r2
	addr_spi   .req r3
	byte       .req r4
	i          .req r5

	push {r4-r5}

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	str divisor, [addr_spi, #equ32_spi0_clk]
	macro32_dsb ip

	.unreq divisor
	temp .req r2

	bic cs, cs, #equ32_spi0_cs_ta
	str cs, [addr_spi, #equ32_spi0_cs]          @ Set Except TA
	macro32_dsb ip

	ldr cs, [addr_spi, #equ32_spi0_cs]
	orr cs, cs, #equ32_spi0_cs_ta
	str cs, [addr_spi, #equ32_spi0_cs]          @ Start of Transfer
	macro32_dsb ip

	mov i, #3
	spi32_spitransaction_txfifo:
		ldr cs, [addr_spi, #equ32_spi0_cs]
		tst cs, #equ32_spi0_cs_txd              @ If Having Space on TxFIFO
		lslne temp, i, #3                       @ Substitute of Multiplication by 8 (Per Byte)
		lsrne byte, data_send, temp
		andne byte, byte, #0xFF
		strne byte, [addr_spi, #equ32_spi0_fifo]
		subne i, i, #1
		cmp i, #0
		bge spi32_spitransaction_txfifo

	spi32_spitransaction_done:
		ldr cs, [addr_spi, #equ32_spi0_cs]
		tst cs, #equ32_spi0_cs_done             @ Check If Done, End of Transer
		beq spi32_spitransaction_done

	.unreq data_send
	data_receive .req r1
	mov data_receive, #0

	mov i, #3
	spi32_spitransaction_rxfifo:
		ldr cs, [addr_spi, #equ32_spi0_cs]
		tst cs, #equ32_spi0_cs_rxd
		beq spi32_spitransaction_deactivate      @ If Having No Data on RxFIFO
		ldrne byte, [addr_spi, #equ32_spi0_fifo] @ If Having Data on RxFIFO
		lslne temp, i, #3                        @ Substitute of Multiplication by 8 (Per Byte)
		lslne byte, byte, temp
		addne data_receive, data_receive, byte
		subne i, i, #1
		cmp i, #0
		bge spi32_spitransaction_rxfifo

	spi32_spitransaction_deactivate:
		ldr cs, [addr_spi, #equ32_spi0_cs]
		bic cs, cs, #equ32_spi0_cs_ta
		str cs, [addr_spi, #equ32_spi0_cs]
		macro32_dsb ip

		b spi32_spitransaction_success

	spi32_spitransaction_success:
		mov r0, data_receive

	spi32_spitransaction_common:
		pop {r4-r5}
		mov pc, lr

.unreq cs
.unreq data_receive
.unreq temp
.unreq addr_spi
.unreq byte
.unreq i
