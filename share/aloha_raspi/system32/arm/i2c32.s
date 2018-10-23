/**
 * i2c32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function i2c32_i2cinit
 * I2C Initialization
 *
 * Parameters
 * r0: Divisor of Clock
 * r1: Delay
 * r2: Clock Stretch Timeout
 *
 * Return: r0 (0 as Success)
 */
.globl i2c32_i2cinit
i2c32_i2cinit:
	/* Auto (Local) Variables, but just Aliases */
	divisor         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	delay           .req r1 @ Parameter, Register for Argument, Scratch Register
	stretch         .req r2 @ Parameter, Register for Argument, Scratch Register
	addr_i2c        .req r3

	mov addr_i2c, #equ32_peripherals_base
	add addr_i2c, addr_i2c, #equ32_i2c1_base_upper
	add addr_i2c, addr_i2c, #equ32_i2c1_base_lower

	str divisor, [addr_i2c, #equ32_i2c_cdiv]
	str delay, [addr_i2c, #equ32_i2c_delay]
	str stretch, [addr_i2c, #equ32_i2c_tout]

	.unreq divisor
	temp .req r0

	ldr temp, [addr_i2c, #equ32_i2c_c]
	orr temp, temp, #equ32_i2c_c_i2cen
	str temp, [addr_i2c, #equ32_i2c_c]

	macro32_dsb ip

	i2c32_i2cinit_common:
		mov r0, #0
		mov pc, lr

.unreq temp
.unreq delay
.unreq stretch
.unreq addr_i2c


/**
 * function i2c32_i2ctx
 * I2C Transmit
 *
 * Parameters
 * r0: Heap for Transmit Data
 * r1: Device Address
 * r2: Transfer Size (Bytes)
 *
 * Return: r0 (0 as success, 1-4 as error)
 * Error(1): Device Address Error
 * Error(2): Clock Stretch Timeout
 * Error(3): Transaction Error on Checking Process
 */
.globl i2c32_i2ctx
i2c32_i2ctx:
	/* Auto (Local) Variables, but just Aliases */
	heap         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	addr_device  .req r1 @ Parameter, Register for Argument, Scratch Register
	size_tx      .req r2 @ Parameter, Register for Argument, Scratch Register
	timeout      .req r3
	byte         .req r4
	temp         .req r5
	addr_i2c     .req r6

	push {r4-r6,lr}

	cmp size_tx, temp
	movgt size_tx, temp                          @ Prevent Overflow

	mov addr_i2c, #equ32_peripherals_base
	add addr_i2c, addr_i2c, #equ32_i2c1_base_upper
	add addr_i2c, addr_i2c, #equ32_i2c1_base_lower

	str addr_device, [addr_i2c, #equ32_i2c_addr]
	str size_tx, [addr_i2c, #equ32_i2c_dlen]

	ldr temp, [addr_i2c, #equ32_i2c_c]
	orr temp, temp, #equ32_i2c_c_st|equ32_i2c_c_clear1
	str temp, [addr_i2c, #equ32_i2c_c]

	mov timeout, #equ32_i2c32_timeout

	i2c32_i2ctx_fifo:
		ldr temp, [addr_i2c, #equ32_i2c_s]

/*
macro32_debug temp, 0, 100
*/

		tst temp, #equ32_i2c_s_err
		bne i2c32_i2ctx_error1

		tst temp, #equ32_i2c_s_clkt
		bne i2c32_i2ctx_error2

		tst temp, #equ32_i2c_s_txd
		ldrneb byte, [heap]                      @ If Having Space on FIFO
		strneb byte, [addr_i2c, #equ32_i2c_fifo]
		addne heap, heap, #1
		subne size_tx, size_tx, #1

		cmp size_tx, #0
		bgt i2c32_i2ctx_fifo

		i2c32_i2ctx_fifo_check:
			cmp timeout, #0
			ble i2c32_i2ctx_error3

			ldr temp, [addr_i2c, #equ32_i2c_s]       @ Reload Status

			tst temp, #equ32_i2c_s_done
			subeq timeout, timeout, #1
			beq i2c32_i2ctx_fifo_check               @ If Not Done Yet

			b i2c32_i2ctx_success

	i2c32_i2ctx_error1:
		mov r0, #1
		b i2c32_i2ctx_common

	i2c32_i2ctx_error2:
		mov r0, #2
		b i2c32_i2ctx_common

	i2c32_i2ctx_error3:
		mov r0, #3
		b i2c32_i2ctx_common

	i2c32_i2ctx_success:
		mov r0, #0

	i2c32_i2ctx_common:
		str temp, [addr_i2c, #equ32_i2c_s]                   @ For Write Clear
		pop {r4-r6,pc}

.unreq heap
.unreq addr_device
.unreq size_tx
.unreq timeout
.unreq byte
.unreq temp
.unreq addr_i2c


/**
 * function i2c32_i2crx
 * I2C Receive
 *
 * Parameters
 * r0: Heap for Receive Data
 * r1: Device Address
 * r2: Transfer Size (Bytes)
 *
 * Return: r0 (0 as success, 1-4 as error)
 * Error(1): Device Address Error
 * Error(2): Clock Stretch Timeout
 * Error(3): Transaction Error on Checking Process
 */
.globl i2c32_i2crx
i2c32_i2crx:
	/* Auto (Local) Variables, but just Aliases */
	heap         .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	addr_device  .req r1 @ Parameter, Register for Argument, Scratch Register
	size_rx      .req r2 @ Parameter, Register for Argument, Scratch Register
	timeout      .req r3
	byte         .req r4
	temp         .req r5
	addr_i2c     .req r6

	push {r4-r6,lr}

	cmp size_rx, temp
	movgt size_rx, temp                          @ Prevent Overflow

	mov addr_i2c, #equ32_peripherals_base
	add addr_i2c, addr_i2c, #equ32_i2c1_base_upper
	add addr_i2c, addr_i2c, #equ32_i2c1_base_lower

	str addr_device, [addr_i2c, #equ32_i2c_addr]
	str size_rx, [addr_i2c, #equ32_i2c_dlen]

	ldr temp, [addr_i2c, #equ32_i2c_c]
	orr temp, temp, #equ32_i2c_c_st|equ32_i2c_c_clear1|equ32_i2c_c_read
	str temp, [addr_i2c, #equ32_i2c_c]

	mov timeout, #equ32_i2c32_timeout

	i2c32_i2crx_fifo:
		ldr temp, [addr_i2c, #equ32_i2c_s]

/*
macro32_debug temp, 0, 112
*/

		tst temp, #equ32_i2c_s_err
		bne i2c32_i2crx_error1

		tst temp, #equ32_i2c_s_clkt
		bne i2c32_i2crx_error2

		tst temp, #equ32_i2c_s_rxd
		ldrneb byte, [addr_i2c, #equ32_i2c_fifo] @ If Having Data on FIFO
		strneb byte, [heap]
		addne heap, heap, #1
		subne size_rx, size_rx, #1

		cmp size_rx, #0
		bgt i2c32_i2crx_fifo

		i2c32_i2crx_fifo_check:

			cmp timeout, #0
			ble i2c32_i2crx_error3

			ldr temp, [addr_i2c, #equ32_i2c_s]       @ Reload Status

			tst temp, #equ32_i2c_s_done
			subeq timeout, timeout, #1
			beq i2c32_i2crx_fifo_check               @ If Not Done Yet

			b i2c32_i2crx_success

	i2c32_i2crx_error1:
		mov r0, #1
		b i2c32_i2crx_common

	i2c32_i2crx_error2:
		mov r0, #2
		b i2c32_i2crx_common

	i2c32_i2crx_error3:
		mov r0, #3
		b i2c32_i2crx_common

	i2c32_i2crx_success:
		mov r0, #0

	i2c32_i2crx_common:
		str temp, [addr_i2c, #equ32_i2c_s]                   @ For Write Clear
		ldr temp, [addr_i2c, #equ32_i2c_c]
		bic temp, temp, #equ32_i2c_c_read
		str temp, [addr_i2c, #equ32_i2c_c]
		pop {r4-r6,pc}

.unreq heap
.unreq addr_device
.unreq size_rx
.unreq timeout
.unreq byte
.unreq temp
.unreq addr_i2c
