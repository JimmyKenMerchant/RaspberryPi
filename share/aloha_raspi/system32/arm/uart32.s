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
		mov r0, #0
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


/**
 * function uart32_uartint
 * UART Interrupt Handler
 *
 * Parameters
 * r0: Number of Maximum Size of Heap (Bytes)
 * r1: Mirror Data to Teletype (1) or Send ACK (0)
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): No Heap, Overrun, or Busy
 */
.globl uart32_uartint
uart32_uartint:
	/* Auto (Local) Variables, but just Aliases */
	max_size    .req r0
	flag_mirror .req r1
	heap        .req r2
	count       .req r3
	temp        .req r4

	push {r4,lr}

	ldr temp, UART32_UARTINT_BUSY
	tst temp, #0x1
	bne uart32_uartint_error         @ If Busy

	/*bl uart32_uartclrint*/         @ Clear All Flags of Interrupt: Don't Use It For Receiving All Data on RxFIFO

	ldr heap, UART32_UARTINT_HEAP
	cmp heap, #0
	beq uart32_uartint_error         @ If No Heap

	ldr count, UART32_UARTINT_COUNT

	push {r0-r3}
	ldr r0, uart32_uartint_buffer
	mov r1, #1                       @ 1 Bytes
	bl uart32_uartrx
	mov temp, r0
	pop {r0-r3}

/*macro32_debug temp, 100, 100*/

	tst temp, #0x8                   @ Whether Overrun or Not
	bne uart32_uartint_error         @ If Overrun

	/* If Succeed to Receive */

	cmp flag_mirror, #0
	beq uart32_uartint_sendack

	/* Mirror Received Data to Teletype */
	push {r0-r3}
	ldr r0, uart32_uartint_buffer
	mov r1, #1                       @ 1 Bytes
	bl uart32_uarttx
	pop {r0-r3}

	b uart32_uartint_verify

	uart32_uartint_sendack:

		/* Send ACK (Acknowledgement) */
		push {r0-r3}
		ldr r0, uart32_uartint_ack
		mov r1, #1
		bl uart32_uarttx
		pop {r0-r3}

	uart32_uartint_verify:

		/* Check Back Space */
		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x08                    @ Ascii Code of Back Space
		bl print32_charsearch
		mov temp, r0
		pop {r0-r3}

		cmp temp, #-1
		bne uart32_uartint_backspace

		/* Check Carriage Return */
		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x0D                    @ Ascii Codes of Carriage Return (By Pressing Enter Key)
		bl print32_charsearch
		mov temp, r0
		pop {r0-r3}

		cmp temp, #-1
		bne uart32_uartint_carriagereturn

		/* Store Data to Actual Memory Space from Buffer */
		ldr temp, uart32_uartint_buffer
		ldrb temp, [temp]
		strb temp, [heap, count]

		/* Slide Offset Count */
		add count, count, #1
		cmp count, max_size
		subge count, count, #1           @ If Exceeds Maximum Size of Heap, Stay Count
		str count, UART32_UARTINT_COUNT

		b uart32_uartint_success

	uart32_uartint_backspace:

		sub count, count, #1
		cmp count, #0
		movlt count, #0
		mov temp, #0
		strb temp, [heap, count]         @ Clear Previous Character
		str count, UART32_UARTINT_COUNT

		/* Send Esc[K (Clear From Cursor Right) */
		push {r0-r3}
		ldr r0, uart32_uartint_e_clrline
		mov r1, #4
		bl uart32_uarttx
		pop {r0-r3}

		b uart32_uartint_success

	uart32_uartint_carriagereturn:

		mov temp, #1
		str temp, UART32_UARTINT_BUSY

		b uart32_uartint_success

	uart32_uartint_error:
		/* If No Heap, Overrun, or Busy to Receive */
		push {r0-r3}
		bl uart32_uartclrrx
		pop {r0-r3}

		/* Send NAK (Negative-acknowledgement) */
		push {r0-r3}
		ldr r0, uart32_uartint_nak
		mov r1, #1
		bl uart32_uarttx
		pop {r0-r3}

		mov r0, #1

		b uart32_uartint_common

	uart32_uartint_success:
		mov r0, #0

	uart32_uartint_common:

macro32_debug_hexa heap, 100, 112, 36

		pop {r4,pc}

.unreq max_size
.unreq flag_mirror
.unreq heap
.unreq count
.unreq temp

.globl UART32_UARTINT_HEAP
.globl UART32_UARTINT_COUNT_ADDR
.globl UART32_UARTINT_BUSY_ADDR
.balign 4
UART32_UARTINT_HEAP:       .word 0x00
UART32_UARTINT_COUNT_ADDR: .word UART32_UARTINT_COUNT
UART32_UARTINT_COUNT:      .word 0x00
UART32_UARTINT_BUSY_ADDR:  .word UART32_UARTINT_BUSY
UART32_UARTINT_BUSY:       .word 0x00
uart32_uartint_nak:        .word _uart32_uartint_nak
_uart32_uartint_nak:       .ascii "\x15\0"
.balign 4
uart32_uartint_ack:        .word _uart32_uartint_ack
_uart32_uartint_ack:       .ascii "\x6\0"
.balign 4
uart32_uartint_e_clrline:  .word _uart32_uartint_e_clrline
_uart32_uartint_e_clrline: .ascii "\x1B[0K\0"          @ Esc(0x1B)[0K: Clear From Cursor to End of Line
.balign 4
uart32_uartint_e_nxtline:  .word _uart32_uartint_e_nxtline
_uart32_uartint_e_nxtline: .ascii "\x1B[1E\0"          @ Esc(0x1B)[1E: Move Cursor to Beginning of Next Line
.balign 4
uart32_uartint_e_clrscr:   .word _uart32_uartint_e_clrscr
_uart32_uartint_e_clrscr:  .ascii "\x1B[2J\0"          @ Esc(0x1B)[2J: Clear All Screen
.balign 4
uart32_uartint_e_homecs:   .word _uart32_uartint_e_homecs
_uart32_uartint_e_homecs:  .ascii "\x1B[0;0H\0"        @ Esc(0x1B)[0;0H: Set Cursor to Upper Left Corner
.balign 4
uart32_uartint_e_up:       .word _uart32_uartint_e_up
_uart32_uartint_e_up:      .ascii "\x1B[1A\0"          @ Esc(0x1B)[1A: Move Cursor Upward
.balign 4
uart32_uartint_e_down:     .word _uart32_uartint_e_down
_uart32_uartint_e_down:    .ascii "\x1B[1B\0"          @ Esc(0x1B)[1B: Move Cursor Downward
.balign 4
uart32_uartint_e_right:    .word _uart32_uartint_e_right
_uart32_uartint_e_right:   .ascii "\x1B[1C\0"          @ Esc(0x1B)[1C: Move Cursor Right
.balign 4
uart32_uartint_e_left:     .word _uart32_uartint_e_left
_uart32_uartint_e_left:    .ascii "\x1B[1D\0"          @ Esc(0x1B)[1D: Move Cursor Left
.balign 4
uart32_uartint_buffer:     .word _uart32_uartint_buffer
_uart32_uartint_buffer:    .space 4                    @ 4 Bytes
.balign 4


/**
 * function uart32_uartmalloc
 * Make Two Dimensional Heap Array and Set for UART Receive Interrupt
 *
 * Parameters
 * r0: Length of Heap Array
 * r1: Size of Each Heap (Words)
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Memory Allocation Is Not Succeeded
 */
.globl uart32_uartmalloc
uart32_uartmalloc:
	/* Auto (Local) Variables, but just Aliases */
	length_array .req r0
	size_heap    .req r1
	rsv          .req r2
	rsv2         .req r3
	array        .req r4
	heap         .req r5

	push {r4-r5,lr}

	push {r0-r3}
	bl heap32_malloc
	mov array, r0
	pop {r0-r3}

	cmp array, #0
	beq uart32_uartmalloc_error

	str array, UART32_UARTMALLOC_ARRAY
	str length_array, UART32_UARTMALLOC_LENGTH

	macro32_dsb ip

	sub length_array, length_array, #1
	
	uart32_uartmalloc_loop:
		cmp length_array, #0
		blt uart32_uartmalloc_success

		push {r0-r3}
		mov r0, size_heap
		bl heap32_malloc
		mov heap, r0
		pop {r0-r3}

		cmp heap, #0
		beq uart32_uartmalloc_error

		str heap, [array, length_array, lsl #2]

		macro32_dsb ip

		sub length_array, length_array, #1

		b uart32_uartmalloc_loop

	uart32_uartmalloc_error:
		mov r0, #1
		b uart32_uartmalloc_common

	uart32_uartmalloc_success:
		str heap, UART32_UARTINT_HEAP            @ Store to First Place of Array
		mov r0, #0

	uart32_uartmalloc_common:
		macro32_dsb ip
		pop {r4-r5,pc}

.unreq length_array
.unreq size_heap
.unreq rsv
.unreq rsv2
.unreq array
.unreq heap

.globl UART32_UARTMALLOC_ARRAY
.globl UART32_UARTMALLOC_LENGTH
.globl UART32_UARTMALLOC_NUMBER
UART32_UARTMALLOC_ARRAY:       .word 0x00
UART32_UARTMALLOC_LENGTH:      .word 0x00
UART32_UARTMALLOC_NUMBER:      .word 0x00


/**
 * function uart32_uartsetheap
 * Set Assigned Heap for UART Receive Interrupt
 *
 * Parameters
 * r0: Number of Heap in Array
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Out of Range
 */
.globl uart32_uartsetheap
uart32_uartsetheap:
	/* Auto (Local) Variables, but just Aliases */
	num_heap     .req r0
	array        .req r1
	heap         .req r2
	length_array .req r3

	ldr length_array, UART32_UARTMALLOC_LENGTH
	cmp num_heap, length_array
	bge uart32_uartsetheap_error

	ldr array, UART32_UARTMALLOC_ARRAY
	ldr heap, [array, num_heap, lsl #2]

	macro32_dsb ip

	str heap, UART32_UARTINT_HEAP
	str num_heap, UART32_UARTMALLOC_NUMBER

	macro32_dsb ip

	b uart32_uartsetheap_success

	uart32_uartsetheap_error:
		mov r0, #1
		b uart32_uartsetheap_common

	uart32_uartsetheap_success:
		mov r0, #0

	uart32_uartsetheap_common:
		mov pc, lr

.unreq num_heap
.unreq array
.unreq heap
.unreq length_array
