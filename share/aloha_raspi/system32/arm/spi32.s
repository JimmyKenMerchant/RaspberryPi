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
 * function spi32_spistart
 * Activate SPI
 *
 * Parameters
 * r0: Control and Status
 *
 * Return: r0 (0 as Success)
 */
.globl spi32_spistart
spi32_spistart:
	/* Auto (Local) Variables, but just Aliases */
	cs         .req r0
	addr_spi   .req r1

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	bic cs, cs, #equ32_spi0_cs_ta
	str cs, [addr_spi, #equ32_spi0_cs]          @ Set Except TA
	macro32_dsb ip

	ldr cs, [addr_spi, #equ32_spi0_cs]
	orr cs, cs, #equ32_spi0_cs_ta
	str cs, [addr_spi, #equ32_spi0_cs]          @ Start of Transfer
	macro32_dsb ip

	spi32_spistart_success:
		mov r0, #0

	spi32_spistart_common:
		mov pc, lr

.unreq cs 
.unreq addr_spi


/**
 * function spi32_spistop
 * Stop SPI
 *
 * Return: r0 (0 as success)
 */
.globl spi32_spistop
spi32_spistop:
	/* Auto (Local) Variables, but just Aliases */
	cs           .req r0
	addr_spi     .req r1

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	ldr cs, [addr_spi, #equ32_spi0_cs]
	bic cs, cs, #equ32_spi0_cs_ta
	str cs, [addr_spi, #equ32_spi0_cs]
	macro32_dsb ip

	spi32_spistop_success:
		mov r0, #0

	spi32_spistop_common:
		mov pc, lr

.unreq cs
.unreq addr_spi


/**
 * function spi32_spidone
 * Check Done or Not
 *
 * Return: r0 (0 as Done, 1 as Not Done)
 */
.globl spi32_spidone
spi32_spidone:
	/* Auto (Local) Variables, but just Aliases */
	cs           .req r0
	addr_spi     .req r1

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	ldr cs, [addr_spi, #equ32_spi0_cs]
	tst cs, #equ32_spi0_cs_done             @ Check If Done, End of Transer
	bne spi32_spidone_success

	spi32_spidone_error:
		mov r0, #1
		b spi32_spidone_common

	spi32_spidone_success:
		mov r0, #0

	spi32_spidone_common:
		mov pc, lr

.unreq cs
.unreq addr_spi


/**
 * function spi32_spitx
 * SPI Transfer with Little Endian (Most Significant Byte is Sent First)
 *
 * Parameters
 * r0: Data to Be Transferred
 * r1: Length of Transferred Data (Bytes, Up to 4)
 *
 * Return: r0 (Number of Data To Be Transferred)
 */
.globl spi32_spitx
spi32_spitx:
	/* Auto (Local) Variables, but just Aliases */
	data_send  .req r0
	length     .req r1
	i          .req r2
	addr_spi   .req r3
	byte       .req r4
	temp       .req r5

	push {r4-r5}

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	rev data_send, data_send                      @ Little Endian to Big Endian
	mov i, #0

	cmp length, #4
	movhi length, #4

	spi32_spitx_txfifo:
		cmp i, length
		bhs spi32_spitx_success

		ldr temp, [addr_spi, #equ32_spi0_cs]
		tst temp, #equ32_spi0_cs_txd              @ If Having Space on TxFIFO

		lslne temp, i, #3                         @ Substitute of Multiplication by 8 (Per Byte)
		lsrne byte, data_send, temp
		strneb byte, [addr_spi, #equ32_spi0_fifo]
		addne i, i, #1

		macro32_dsb ip

		b spi32_spitx_txfifo

	spi32_spitx_success:
		mov r0, i

	spi32_spitx_common:
		pop {r4-r5}
		mov pc, lr

.unreq data_send
.unreq length
.unreq i
.unreq addr_spi
.unreq byte
.unreq temp


/**
 * function spi32_spirx
 * SPI Receive with Little Endian (Most Significant Byte is Stored First in Bit[31:24])
 *
 * Parameters
 * r0: Length of Data to Be Received (Bytes, Up to 4)
 *
 * Return: r0 (Data to Be Received)
 */
.globl spi32_spirx
spi32_spirx:
	/* Auto (Local) Variables, but just Aliases */
	length       .req r0
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
	mov i, #0

	cmp length, #4
	movhi length, #4

	spi32_spirx_rxfifo:
		cmp i, length
		bhs spi32_spirx_success

		ldr temp, [addr_spi, #equ32_spi0_cs]
		tst temp, #equ32_spi0_cs_rxd
		beq spi32_spirx_success                 @ If Having No Data on RxFIFO

		ldrb byte, [addr_spi, #equ32_spi0_fifo] @ If Having Data on RxFIFO
		lsl temp, i, #3                         @ Substitute of Multiplication by 8 (Per Byte)
		lsl byte, byte, temp
		orr data_receive, data_receive, byte
		add i, i, #1

		macro32_dsb ip

		b spi32_spirx_rxfifo

	spi32_spirx_success:
		rev r0, data_receive                    @ Big Endian to Little Endian

	spi32_spirx_common:
		pop {r4-r5}
		mov pc, lr

.unreq length
.unreq data_receive
.unreq i
.unreq addr_spi
.unreq byte
.unreq temp


/**
 * function spi32_spitx_memory
 * SPI Transfer with Memory, Big Endian (Most Significant Byte on Offset Zero is Sent First)
 *
 * Parameters
 * r0: Pointer of Data to Be Transferred
 * r1: Length of Transferred Data (Bytes)
 *
 * Return: r0 (0 as Success, 1 and More as Error)
 * Error: Number of Bytes to Be Transferred
 */
.globl spi32_spitx_memory
spi32_spitx_memory:
	/* Auto (Local) Variables, but just Aliases */
	data_send  .req r0
	length     .req r1
	i          .req r2
	addr_spi   .req r3
	byte       .req r4
	temp       .req r5

	push {r4-r5}

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	mov i, #0

	spi32_spitx_memory_txfifo:
		cmp i, length
		bhs spi32_spitx_memory_common

		ldr temp, [addr_spi, #equ32_spi0_cs]
		tst temp, #equ32_spi0_cs_txd

		ldrneb byte, [data_send, i]
		strneb byte, [addr_spi, #equ32_spi0_fifo]
		addne i, i, #1

		macro32_dsb ip

		b spi32_spitx_memory_txfifo

	spi32_spitx_memory_common:
		mov r0, i
		pop {r4-r5}
		mov pc, lr

.unreq data_send
.unreq length
.unreq i
.unreq addr_spi
.unreq byte
.unreq temp


/**
 * function spi32_spirx_memory
 * SPI Receive with Memory, Big Endian (Most Significant Byte is Stored First in Offset Zero)
 *
 * Parameters
 * r0: Pointer of Data to Be Received
 * r1: Length of Received Data (Bytes)
 *
 * Return: r0 (0 as Success, 1 and More as Error)
 * Error: Number of Bytes to Be Received
 */
.globl spi32_spirx_memory
spi32_spirx_memory:
	/* Auto (Local) Variables, but just Aliases */
	data_receive .req r0
	length       .req r1
	i            .req r2
	addr_spi     .req r3
	byte         .req r4
	temp         .req r5

	push {r4-r5}

	mov addr_spi, #equ32_peripherals_base
	add addr_spi, addr_spi, #equ32_spi0_base_upper
	add addr_spi, addr_spi, #equ32_spi0_base_lower

	mov i, #0

	spi32_spirx_memory_rxfifo:
		cmp i, length
		bhs spi32_spirx_memory_common

		ldr temp, [addr_spi, #equ32_spi0_cs]
		tst temp, #equ32_spi0_cs_rxd
		beq spi32_spirx_memory_common

		ldrb byte, [addr_spi, #equ32_spi0_fifo]
		strb byte, [data_receive, i]
		add i, i, #1

		macro32_dsb ip

		b spi32_spirx_memory_rxfifo

	spi32_spirx_memory_common:
		mov r0, i
		pop {r4-r5}
		mov pc, lr

.unreq data_receive
.unreq length
.unreq i
.unreq addr_spi
.unreq byte
.unreq temp
