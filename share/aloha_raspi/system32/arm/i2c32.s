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
 * r0: Device Address
 * r1: Heap for Transmit Data
 * r2: Transfer Size (Bytes)
 * r3: Clock Counts of Time Out to Wait Completion of Transmission
 *
 * Return: r0 (0 as success, 1 , 2 and 3 as error)
 * Error(1): Device Address Error
 * Error(2): Clock Stretch Timeout
 * Error(3): Transaction Error on Checking Process
 */
.globl i2c32_i2ctx
i2c32_i2ctx:
	/* Auto (Local) Variables, but just Aliases */
	addr_device  .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	heap         .req r1 @ Parameter, Register for Argument, Scratch Register
	size_tx      .req r2 @ Parameter, Register for Argument, Scratch Register
	timeout      .req r3 @ Parameter, Register for Argument, Scratch Register
	byte         .req r4
	temp         .req r5
	addr_i2c     .req r6

	push {r4-r6}

	mov addr_i2c, #equ32_peripherals_base
	add addr_i2c, addr_i2c, #equ32_i2c1_base_upper
	add addr_i2c, addr_i2c, #equ32_i2c1_base_lower

	str size_tx, [addr_i2c, #equ32_i2c_dlen]
	str addr_device, [addr_i2c, #equ32_i2c_addr]

	ldr temp, [addr_i2c, #equ32_i2c_c]
	orr temp, temp, #equ32_i2c_c_intd|equ32_i2c_c_st|equ32_i2c_c_clear1
	str temp, [addr_i2c, #equ32_i2c_c]

	i2c32_i2ctx_fifo:
		ldr temp, [addr_i2c, #equ32_i2c_s]

		tst temp, #equ32_i2c_s_err
		bne i2c32_i2ctx_error1

		tst temp, #equ32_i2c_s_clkt
		bne i2c32_i2ctx_error2

		tst temp, #equ32_i2c_s_txd
		ldrbne byte, [heap]                      @ If Having Space on FIFO
		strbne byte, [addr_i2c, #equ32_i2c_fifo]
		addne heap, heap, #1                     @ Substitute of Multiplication by 8 (Per Byte)
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
		ldr temp, [addr_i2c, #equ32_i2c_c]
		bic temp, temp, #equ32_i2c_c_intd
		str temp, [addr_i2c, #equ32_i2c_c]
		pop {r4-r6}
		mov pc, lr

.unreq addr_device
.unreq heap
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
 * r0: Device Address
 * r1: Heap for Receive Data
 * r2: Transfer Size (Bytes)
 *
 * Return: r0 (0 as success, 1 , 2 and 3 as error)
 * Error(1): Device Address Error
 * Error(2): Clock Stretch Timeout
 * Error(3): Transaction Error on Checking Process
 */
.globl i2c32_i2crx
i2c32_i2crx:
	/* Auto (Local) Variables, but just Aliases */
	addr_device  .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	heap         .req r1 @ Parameter, Register for Argument, Scratch Register
	size_rx      .req r2 @ Parameter, Register for Argument, Scratch Register
	byte         .req r3
	temp         .req r4
	addr_i2c     .req r5

	push {r4-r5}

	mov addr_i2c, #equ32_peripherals_base
	add addr_i2c, addr_i2c, #equ32_i2c1_base_upper
	add addr_i2c, addr_i2c, #equ32_i2c1_base_lower

	str size_rx, [addr_i2c, #equ32_i2c_dlen]
	str addr_device, [addr_i2c, #equ32_i2c_addr]

	ldr temp, [addr_i2c, #equ32_i2c_c]
	orr temp, temp, #equ32_i2c_c_intd|equ32_i2c_c_st|equ32_i2c_c_clear1|equ32_i2c_c_read
	str temp, [addr_i2c, #equ32_i2c_c]

	i2c32_i2crx_fifo:
		ldr temp, [addr_i2c, #equ32_i2c_s]

		tst temp, #equ32_i2c_s_err
		bne i2c32_i2crx_error1

		tst temp, #equ32_i2c_s_clkt
		bne i2c32_i2crx_error2

		tst temp, #equ32_i2c_s_rxd
		ldrbne byte, [addr_i2c, #equ32_i2c_fifo] @ If Having Data on FIFO
		strbne byte, [heap]
		addne heap, heap, #1                     @ Substitute of Multiplication by 8 (Per Byte)
		subne size_rx, size_rx, #1

		cmp size_rx, #0
		bgt i2c32_i2crx_fifo

		i2c32_i2crx_fifo_check:

			tst temp, #equ32_i2c_s_done
			beq i2c32_i2crx_error3                   @ If Not Done Yet

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
		bic temp, temp, #equ32_i2c_c_intd|equ32_i2c_c_read
		str temp, [addr_i2c, #equ32_i2c_c]
		pop {r4-r5}
		mov pc, lr

.unreq addr_device
.unreq heap
.unreq size_rx
.unreq byte
.unreq temp
.unreq addr_i2c
