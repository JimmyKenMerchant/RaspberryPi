/**
 * uart32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function uart32_uartinit
 * UART Initialization
 * Baud rate divisor is determined by the formula, "Reference clock/ 16 multiplies by Baud rate".
 * Reference clock is 3Mhz on default settings, but you can change it by a comment on config.txt.
 * e.g., "init_uart_clock=3000000".
 *
 * Parameters
 * r0: Integer Baud Rate Divisor, Bit[15:0]
 * r1: Fractional Baud Rate Divisor, Bit[5:0]
 * r2: Line Control
 * r3: Control
 *
 * Return: r0 (0 as Success)
 */
.globl uart32_uartinit
uart32_uartinit:
	/* Auto (Local) Variables, but just Aliases */
	div_int         .req r0
	div_frac        .req r1
	line_ctl        .req r2
	ctl             .req r3
	addr_uart       .req r4

	push {r4}

	mov addr_uart, #equ32_peripherals_base
	add addr_uart, addr_uart, #equ32_uart0_base_upper
	add addr_uart, addr_uart, #equ32_uart0_base_lower

	bic ctl, ctl, #equ32_uart0_cr_uarten
	str ctl, [addr_uart, #equ32_uart0_cr]

	str line_ctl, [addr_uart, #equ32_uart0_lcrh]

	str div_int, [addr_uart, #equ32_uart0_ibrd]
	str div_frac, [addr_uart, #equ32_uart0_fbrd]

	macro32_dsb ip

	orr ctl, ctl, #equ32_uart0_cr_uarten
	str ctl, [addr_uart, #equ32_uart0_cr]

	uart32_uartinit_common:
		pop {r4}
		mov r0, #0
		mov pc, lr

.unreq div_int
.unreq div_frac
.unreq line_ctl
.unreq ctl
.unreq addr_uart


/**
 * function uart32_uartsetint
 * Set UART Interrupt
 * Each FIFO is 16 Words Depth (8-bit on Tx, 12-bit on Rx)
 *
 * Parameters
 * r0: Interrupt FIFO Level Select
 * r1: Interrupt Mask Set (1)/ Clear(0)
 *
 * Return: r0 (0 as Success)
 */
.globl uart32_uartsetint
uart32_uartsetint:
	/* Auto (Local) Variables, but just Aliases */
	int_fifo        .req r0
	int_mask        .req r1
	addr_uart       .req r2

	mov addr_uart, #equ32_peripherals_base
	add addr_uart, addr_uart, #equ32_uart0_base_upper
	add addr_uart, addr_uart, #equ32_uart0_base_lower

	str int_fifo, [addr_uart, #equ32_uart0_ifls]

	.unreq int_fifo
	temp .req r0
	mov temp, #0

	str temp, [addr_uart, #equ32_uart0_imsc]     @ Clear All Mask

	macro32_dsb ip

	str int_mask, [addr_uart, #equ32_uart0_imsc]

	macro32_dsb ip

	uart32_uartsetint_common:
		mov pc, lr

.unreq temp
.unreq int_mask
.unreq addr_uart


/**
 * function uart32_uartclrint
 * Clear UART Interrupt
 *
 * Return: r0 (Cleared Interrupt Bits)
 */
.globl uart32_uartclrint
uart32_uartclrint:
	/* Auto (Local) Variables, but just Aliases */
	int_mis         .req r0
	addr_uart       .req r1

	mov addr_uart, #equ32_peripherals_base
	add addr_uart, addr_uart, #equ32_uart0_base_upper
	add addr_uart, addr_uart, #equ32_uart0_base_lower

	ldr int_mis, [addr_uart, #equ32_uart0_mis]
	str int_mis, [addr_uart, #equ32_uart0_icr]

	macro32_dsb ip

	uart32_uartclrint_common:
		mov pc, lr

.unreq int_mis
.unreq addr_uart


/**
 * function uart32_uarttx
 * UART Transmit
 *
 * Parameters
 * r0: Heap for Transmit Data
 * r1: Transfer Size (Bytes)
 *
 * Return: r0 (0 as success)
 */
.globl uart32_uarttx
uart32_uarttx:
	/* Auto (Local) Variables, but just Aliases */
	heap         .req r0
	size_tx      .req r1
	byte         .req r2
	temp         .req r3
	addr_uart    .req r4

	push {r4}

	mov addr_uart, #equ32_peripherals_base
	add addr_uart, addr_uart, #equ32_uart0_base_upper
	add addr_uart, addr_uart, #equ32_uart0_base_lower

	uart32_uarttx_fifo:
		ldr temp, [addr_uart, #equ32_uart0_fr]

/*
macro32_debug temp, 0, 100
*/

		tst temp, #equ32_uart0_fr_txfe
		ldrneb byte, [heap]                      @ If Having Space on TxFIFO
		strneb byte, [addr_uart, #equ32_uart0_dr]
		addne heap, heap, #1
		subne size_tx, size_tx, #1

		cmp size_tx, #0
		bgt uart32_uarttx_fifo

	uart32_uarttx_success:
		mov r0, #0

	uart32_uarttx_common:
		pop {r4}
		mov pc, lr

.unreq heap
.unreq size_tx
.unreq byte
.unreq temp
.unreq addr_uart


/**
 * function uart32_uartrx
 * UART Receive and Wait for Reaching Sufficient Size
 *
 * Parameters
 * r0: Heap for Receive Data
 * r1: Transfer Size (Bytes)
 *
 * Return: r0 (0 as success, not 0 as error)
 * Bit[3]: Overrun Error
 * Bit[2]: Break Error
 * Bit[1]: Parity Error
 * Bit[0]: Framing Error
 */
.globl uart32_uartrx
uart32_uartrx:
	/* Auto (Local) Variables, but just Aliases */
	heap         .req r0
	size_rx      .req r1
	byte         .req r2
	temp         .req r3
	addr_uart    .req r4

	push {r4}

	mov addr_uart, #equ32_peripherals_base
	add addr_uart, addr_uart, #equ32_uart0_base_upper
	add addr_uart, addr_uart, #equ32_uart0_base_lower

	uart32_uartrx_fifo:
		ldr temp, [addr_uart, #equ32_uart0_fr]

/*
macro32_debug temp, 0, 112
*/

		tst temp, #equ32_uart0_fr_rxfe
		bne uart32_uartrx_fifo                      @ If Empty on RxFIFO

		ldr byte, [addr_uart, #equ32_uart0_dr]      @ If Having Data on RxFIFO (12-bit Word, 8-bit is Data)
		strb byte, [heap]

		ldrb temp, [addr_uart, #equ32_uart0_rsrecr] @ Get Received Status
		strb temp, [addr_uart, #equ32_uart0_rsrecr] @ Clear by Write Any

		tst temp, #0b1111
		bne uart32_uartrx_error
	
		add heap, heap, #1
		sub size_rx, size_rx, #1

		cmp size_rx, #0
		bgt uart32_uartrx_fifo

		b uart32_uartrx_success

	uart32_uartrx_error:
		and temp, temp, #0b1111
		mov r0, temp
		b uart32_uartrx_common

	uart32_uartrx_success:
		mov r0, #0

	uart32_uartrx_common:
		pop {r4}
		mov pc, lr

.unreq heap
.unreq size_rx
.unreq byte
.unreq temp
.unreq addr_uart


/**
 * function uart32_uartclrrx
 * Clear RxFIFO
 *
 * Return: r0 (0 as success)
 */
.globl uart32_uartclrrx
uart32_uartclrrx:
	/* Auto (Local) Variables, but just Aliases */
	temp         .req r0
	addr_uart    .req r1

	mov addr_uart, #equ32_peripherals_base
	add addr_uart, addr_uart, #equ32_uart0_base_upper
	add addr_uart, addr_uart, #equ32_uart0_base_lower

	uart32_uartclrrx_fifo:
		ldr temp, [addr_uart, #equ32_uart0_fr]

		tst temp, #equ32_uart0_fr_rxfe
		bne uart32_uartclrrx_success                @ If Empty on RxFIFO

		ldr temp, [addr_uart, #equ32_uart0_dr]      @ If Having Data on RxFIFO

		b uart32_uartclrrx_fifo

	uart32_uartclrrx_success:
		mov r0, #0

	uart32_uartclrrx_common:
		mov pc, lr

.unreq temp
.unreq addr_uart
