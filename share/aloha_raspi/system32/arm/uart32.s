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
 * function uart32_uartsettest
 * Test Data On/Off and Transmit/Receive On/Off
 *
 * Parameters
 * r0: Test Data On(1), Off(0)
 * r1: Tx On(1), Off(0)
 * r2: Rx On(1), Off(0)
 *
 * Return: r0 (0 as Success)
 */
.globl uart32_uartsettest
uart32_uartsettest:
	/* Auto (Local) Variables, but just Aliases */
	tdr_on         .req r0
	tx_on          .req r1
	rx_on          .req r2
	addr_uart      .req r3
	temp           .req r4

	push {r4}

	mov addr_uart, #equ32_peripherals_base
	add addr_uart, addr_uart, #equ32_uart0_base_upper
	add addr_uart, addr_uart, #equ32_uart0_base_lower

	ldr temp, [addr_uart, #equ32_uart0_tcr]

	macro32_dsb ip

	tst tdr_on, #1
	orrne temp, temp, #0b11
	biceq temp, temp, #0b11

	str temp, [addr_uart, #equ32_uart0_tcr]

	ldr temp, [addr_uart, #equ32_uart0_cr]

	macro32_dsb ip

	tst tx_on, #1
	orrne temp, temp, #equ32_uart0_cr_txe
	biceq temp, temp, #equ32_uart0_cr_txe

	tst rx_on, #1
	orrne temp, temp, #equ32_uart0_cr_rxe
	biceq temp, temp, #equ32_uart0_cr_rxe

	str temp, [addr_uart, #equ32_uart0_cr]

	macro32_dsb ip

	uart32_uartsettest_common:
		pop {r4}
		mov r0, #0
		mov pc, lr

.unreq tdr_on
.unreq tx_on
.unreq rx_on
.unreq addr_uart
.unreq temp


/**
 * function uart32_uarttestwrite
 * Write Data to RxFIFO from Test Data
 *
 * Parameters
 * r0: Heap for Transmit Data
 * r1: Transfer Size (Bytes)
 *
 * Return: r0 (0 as success)
 */
.globl uart32_uarttestwrite
uart32_uarttestwrite:
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

	cmp size_tx, #0
	ble uart32_uarttestwrite_success

	uart32_uarttestwrite_fifo:
		ldr temp, [addr_uart, #equ32_uart0_fr]


macro32_debug temp, 0, 100


		tst temp, #equ32_uart0_fr_rxff           @ RxFIFO is Full
		ldreqb byte, [heap]                      @ If Having Space on RxFIFO
		streqb byte, [addr_uart, #equ32_uart0_tdr]
		addeq heap, heap, #1
		subeq size_tx, size_tx, #1

		cmp size_tx, #0
		bgt uart32_uarttestwrite_fifo

	uart32_uarttestwrite_success:
		mov r0, #0

	uart32_uarttestwrite_common:
		pop {r4}
		mov pc, lr

.unreq heap
.unreq size_tx
.unreq byte
.unreq temp
.unreq addr_uart


/**
 * function uart32_uarttestread
 * Read TxFIFO from Test Data
 *
 * Parameters
 * r0: Heap for Receive Data
 * r1: Transfer Size (Bytes)
 *
 * Return: r0 (0 as success)
 */
.globl uart32_uarttestread
uart32_uarttestread:
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

	uart32_uarttestread_fifo:
		ldr temp, [addr_uart, #equ32_uart0_fr]

/*
macro32_debug temp, 0, 112
*/

		tst temp, #equ32_uart0_fr_txfe
		bne uart32_uarttestread_fifo                @ If Empty on TxFIFO

		ldr byte, [addr_uart, #equ32_uart0_tdr]     @ If Having Data on TxFIFO (12-bit Word, 8-bit is Data)
		strb byte, [heap]
		add heap, heap, #1
		sub size_rx, size_rx, #1

		cmp size_rx, #0
		bgt uart32_uarttestread_fifo

	uart32_uarttestread_success:
		mov r0, #0

	uart32_uarttestread_common:
		pop {r4}
		mov pc, lr

.unreq heap
.unreq size_rx
.unreq byte
.unreq temp
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

	cmp size_tx, #0
	ble uart32_uarttx_success

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
	max_size      .req r0
	flag_mirror   .req r1
	heap          .req r2
	count         .req r3
	temp          .req r4
	flag_escape   .req r5
	buffer        .req r6

	push {r4-r6,lr}

	ldr temp, UART32_UARTINT_BUSY
	tst temp, #0x1
	bne uart32_uartint_error         @ If Busy

	/*bl uart32_uartclrint*/         @ Clear All Flags of Interrupt: Don't Use It For Receiving All Data on RxFIFO

	ldr heap, UART32_UARTINT_HEAP
	cmp heap, #0
	beq uart32_uartint_error         @ If No Heap

	ldr count, UART32_UARTINT_COUNT

	ldr flag_escape, uart32_flag_escape

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

		cmp flag_escape, #1
		beq uart32_uartint_escseq        @ If in Escape Sequence

		/* Check Escape */
		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x1B                    @ Ascii Code of Escape
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}

		cmp temp, #-1
		movne flag_escape, #1
		bne uart32_uartint_escseq_common @ If Start of Escape Sequence

		/* Check Back Space */
		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x08                    @ Ascii Code of Back Space
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}

		cmp temp, #-1
		bne uart32_uartint_backspace

		/* Check Carriage Return */
		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x0D                    @ Ascii Codes of Carriage Return (By Pressing Enter Key)
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}

		cmp temp, #-1
		bne uart32_uartint_carriagereturn

		cmp count, max_size
		subge count, max_size, #1

		push {r0-r3}
		mov r0, heap
		bl str32_strlen
		mov temp, r0                     @ Most Significant Insert Position
		pop {r0-r3}

		cmp count, temp
		cmplt temp, max_size
		blt uart32_uartint_insert

		/* Store Data to Actual Memory Space from Buffer */
		ldr temp, uart32_uartint_buffer
		ldrb temp, [temp]
		strb temp, [heap, count]

		/* Slide Offset Count */
		add count, count, #1
		cmp count, max_size
		subge count, max_size, #1       @ If Exceeds Maximum Size of Heap, Stay Count
		str count, UART32_UARTINT_COUNT
		blt uart32_uartint_success

		/* Cursor Left If Reaching Maximum Size of Line */
		push {r0-r3}
		ldr r0, uart32_uartint_esc_left
		mov r1, #3
		bl uart32_uarttx
		pop {r0-r3}

		b uart32_uartint_success

	uart32_uartint_escseq:

		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x41                    @ Ascii Codes of A
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}
		cmp temp, #-1
		bne uart32_uartint_escseq_up

		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x42                    @ Ascii Codes of B
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}
		cmp temp, #-1
		bne uart32_uartint_escseq_down

		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x43                    @ Ascii Codes of C
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}
		cmp temp, #-1
		bne uart32_uartint_escseq_right

		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x44                    @ Ascii Codes of D
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}
		cmp temp, #-1
		bne uart32_uartint_escseq_left

		b uart32_uartint_escseq_common

		uart32_uartint_escseq_up:

			/* Send Move Cursor Down Because Of Overshoot */
			push {r0-r3}
			ldr r0, uart32_uartint_esc_down
			mov r1, #3
			bl uart32_uarttx
			pop {r0-r3}

			b uart32_uartint_escseq_clear

		uart32_uartint_escseq_down:

			/* Send Move Cursor Up Because Of Overshoot */
			push {r0-r3}
			ldr r0, uart32_uartint_esc_up
			mov r1, #3
			bl uart32_uarttx
			pop {r0-r3}

			b uart32_uartint_escseq_clear

		uart32_uartint_escseq_right:

			add count, count, #1
			cmp count, max_size
			bge uart32_uartint_escseq_right_over @ If Exceeds Maximum Size of Heap, Stay Count

			push {r0-r3}
			mov r0, heap
			bl str32_strlen
			mov temp, r0
			pop {r0-r3}
			cmp count, temp
			ble uart32_uartint_escseq_clear

			uart32_uartint_escseq_right_over:

				/* Count Overshoots Length of List */
				sub count, count, #1

				/* Send Move Cursor Left Because Of Overshoot */
				push {r0-r3}
				ldr r0, uart32_uartint_esc_left
				mov r1, #3
				bl uart32_uarttx
				pop {r0-r3}

				b uart32_uartint_escseq_clear

		uart32_uartint_escseq_left:
			
			sub count, count, #1
			cmp count, #0
			bge uart32_uartint_escseq_clear

			/* Count Becomes Minus */

			mov count, #0

			/* Send Move Cursor Right Because Of Overshoot */
			push {r0-r3}
			ldr r0, uart32_uartint_esc_right
			mov r1, #3
			bl uart32_uarttx
			pop {r0-r3}

		uart32_uartint_escseq_clear:
			str count, UART32_UARTINT_COUNT
			mov flag_escape, #0

		uart32_uartint_escseq_common:
			str flag_escape, uart32_flag_escape
			b uart32_uartint_success

	uart32_uartint_backspace:

		sub count, count, #1
		cmp count, #0
		bge uart32_uartint_backspace_jmp

		/* Send Move Cursor Right Because of Overshoot */
		push {r0-r3}
		ldr r0, uart32_uartint_esc_right
		mov r1, #3
		bl uart32_uarttx
		pop {r0-r3}

		b uart32_uartint_success

		uart32_uartint_backspace_jmp:

			/* Get Length of Back Half to Be Concatenated */
			push {r0-r3}
			add r0, heap, count
			add r0, r0, #1      @ Over Character to Be Deleted
			bl str32_strlen
			mov temp, r0
			pop {r0-r3}
			add temp, temp, #1  @ Add One For Null Character

			push {r0-r3}
			mov r0, heap
			mov r1, count
			mov r2, heap
			add r3, count, #1   @ Over Character to Be Deleted
			push {temp}
			bl heap32_mcopy
			add sp, sp, #4
			pop {r0-r3}

			sub temp, temp, #1  @ Subtract One For Null Character for Use Later

			/* Send Esc[K (Clear From Cursor Right) */
			push {r0-r3}
			ldr r0, uart32_uartint_esc_clrline
			mov r1, #3
			bl uart32_uarttx
			pop {r0-r3}

			/* Reflect New Characters */
			push {r0-r3}
			add r0, heap, count
			mov r1, temp 
			bl uart32_uarttx
			pop {r0-r3}

			/* Move Cursor Left Because of Renewed Back Half */
			uart32_uartint_backspace_jmp_loop:
				cmp temp, #0
				ble uart32_uartint_backspace_jmp_common

				push {r0-r3}
				ldr r0, uart32_uartint_esc_left
				mov r1, #3
				bl uart32_uarttx
				pop {r0-r3}

				sub temp, temp, #1
				b uart32_uartint_backspace_jmp_loop

			uart32_uartint_backspace_jmp_common:
				str count, UART32_UARTINT_COUNT
				b uart32_uartint_success

	uart32_uartint_carriagereturn:

		mov temp, #1
		str temp, UART32_UARTINT_BUSY

		b uart32_uartint_success

	uart32_uartint_insert:

		/* Get Length of Back Half to Be Concatenated */
		push {r0-r3}
		add r0, heap, count
		bl str32_strlen
		mov temp, r0
		pop {r0-r3}
		add temp, temp, #1  @ Add One For Null Character
		
		/* Calculate Buffer, If Remainder of 4 Exists, Add 4 */
		tst temp, #0b11
		addne buffer, temp, #0b100
		moveq buffer, temp
		lsr buffer, buffer, #2  @ Substitute of Division by 4

		push {r0-r3}
		mov r0, buffer
		bl heap32_malloc
		mov buffer, r0
		pop {r0-r3}

		/* If Memory Allocation Failed */
		cmp buffer, #0
		beq uart32_uartint_insert_common

		push {r0-r3}
		mov r0, buffer 
		mov r1, #0
		mov r2, heap
		mov r3, count
		push {temp}
		bl heap32_mcopy
		add sp, sp, #4
		pop {r0-r3}

		push {r0-r3}
		mov r0, heap
		add r1, count, #1   @ Get Space For New Character
		mov r2, buffer 
		mov r3, #0
		push {temp}
		bl heap32_mcopy
		add sp, sp, #4
		pop {r0-r3}

		push {r0-r3}
		mov r0, buffer
		bl heap32_mfree
		pop {r0-r3}

		sub temp, temp, #1  @ Subtract One For Null Character for Use Later

		ldr buffer, uart32_uartint_buffer
		ldrb buffer, [buffer]
		strb buffer, [heap, count]

		/* Send Esc[K (Clear From Cursor Right) */
		push {r0-r3}
		ldr r0, uart32_uartint_esc_clrline
		mov r1, #3
		bl uart32_uarttx
		pop {r0-r3}

		/* Reflect New Characters */
		push {r0-r3}
		add r0, heap, count
		add r0, r0, #1
		mov r1, temp 
		bl uart32_uarttx
		pop {r0-r3}

		/* Move Cursor Left Because of Renewed Back Half */
		uart32_uartint_insert_loop:
			cmp temp, #0
			ble uart32_uartint_insert_common

			push {r0-r3}
			ldr r0, uart32_uartint_esc_left
			mov r1, #3
			bl uart32_uarttx
			pop {r0-r3}

			sub temp, temp, #1
			b uart32_uartint_insert_loop

		uart32_uartint_insert_common:

			/* Slide Offset Count */
			add count, count, #1
			cmp count, max_size
			subge count, max_size, #1        @ If Exceeds Maximum Size of Heap, Stay Count
			str count, UART32_UARTINT_COUNT
			blt uart32_uartint_success

			/* Cursor Left If Reaching Maximum Size of Line */
			push {r0-r3}
			ldr r0, uart32_uartint_esc_left
			mov r1, #3
			bl uart32_uarttx
			pop {r0-r3}

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

/*macro32_debug_hexa heap, 100, 112, 36*/
/*macro32_debug flag_escape, 100, 124*/

		pop {r4-r6,pc}

.unreq max_size
.unreq flag_mirror
.unreq heap
.unreq count
.unreq temp
.unreq flag_escape
.unreq buffer

.globl UART32_UARTINT_HEAP
.globl UART32_UARTINT_COUNT_ADDR
.globl UART32_UARTINT_BUSY_ADDR
.balign 4
UART32_UARTINT_HEAP:         .word 0x00
UART32_UARTINT_COUNT_ADDR:   .word UART32_UARTINT_COUNT
UART32_UARTINT_COUNT:        .word 0x00
UART32_UARTINT_BUSY_ADDR:    .word UART32_UARTINT_BUSY
UART32_UARTINT_BUSY:         .word 0x00
uart32_flag_escape:          .word 0x00
uart32_uartint_cr:           .word _uart32_uartint_cr
_uart32_uartint_cr:          .ascii "\x0D\0"
.balign 4
uart32_uartint_nak:          .word _uart32_uartint_nak
_uart32_uartint_nak:         .ascii "\x15\0"
.balign 4
uart32_uartint_ack:          .word _uart32_uartint_ack
_uart32_uartint_ack:         .ascii "\x6\0"
.balign 4
uart32_uartint_esc_up:       .word _uart32_uartint_esc_up
_uart32_uartint_esc_up:      .ascii "\x1B[A\0"         @ Esc(0x1B)[A (Esc(0x1B)[1A): Move Cursor Upward
.balign 4
uart32_uartint_esc_down:     .word _uart32_uartint_esc_down
_uart32_uartint_esc_down:    .ascii "\x1B[B\0"         @ Esc(0x1B)[B (Esc(0x1B)[1B): Move Cursor Downward
.balign 4
uart32_uartint_esc_right:    .word _uart32_uartint_esc_right
_uart32_uartint_esc_right:   .ascii "\x1B[C\0"         @ Esc(0x1B)[C (Esc(0x1B)[1C): Move Cursor Right
.balign 4
uart32_uartint_esc_left:     .word _uart32_uartint_esc_left
_uart32_uartint_esc_left:    .ascii "\x1B[D\0"         @ Esc(0x1B)[D (Esc(0x1B)[1D): Move Cursor Left
.balign 4
uart32_uartint_esc_nxtline:  .word _uart32_uartint_esc_nxtline
_uart32_uartint_esc_nxtline: .ascii "\x1B[E\0"         @ Esc(0x1B)[E (Esc(0x1B)[1E): Move Cursor to Beginning of Next Line
.balign 4
uart32_uartint_esc_bckline:  .word _uart32_uartint_esc_bckline
_uart32_uartint_esc_bckline: .ascii "\x1B[F\0"         @ Esc(0x1B)[F (Esc(0x1B)[1F): Move Cursor to Beginning of Previous Line
.balign 4
uart32_uartint_esc_clrscr:   .word _uart32_uartint_esc_clrscr
_uart32_uartint_esc_clrscr:  .ascii "\x1B[2J\0"        @ Esc(0x1B)[2J: Clear All Screen
.balign 4
uart32_uartint_esc_clrline:  .word _uart32_uartint_esc_clrline
_uart32_uartint_esc_clrline: .ascii "\x1B[K\0"         @ Esc(0x1B)[K (Esc(0x1B)[0K): Clear From Cursor to End of Line
.balign 4
uart32_uartint_esc_homecs:   .word _uart32_uartint_esc_homecs
_uart32_uartint_esc_homecs:  .ascii "\x1B[H\0"         @ Esc(0x1B)[H (Esc(0x1B)[1;1H): Set Cursor to Upper Left Corner
.balign 4

uart32_uartint_buffer:       .word _uart32_uartint_buffer
_uart32_uartint_buffer:      .word 0x00 
.balign 4


/**
 * function uart32_uartint_emulate
 * Emulation of UART Interrupt Handler
 * Note that this function makes new memory space to be needed to make the memory free.
 *
 * Parameters
 * r0: Number of Maximum Size of Heap (Bytes)
 * r1: Mirror Data to Teletype (1) or Send ACK (0)
 * r2: Character to Be Virtually Received
 *
 * Return: r0 (Pointer of String to Be Virtually Transmitted by UART, If Zero No Heap or Memory Allocation Fails)
 */
.globl uart32_uartint_emulate
uart32_uartint_emulate:
	/* Auto (Local) Variables, but just Aliases */
	max_size      .req r0
	flag_mirror   .req r1
	heap          .req r2
	count         .req r3
	temp          .req r4
	flag_escape   .req r5
	buffer        .req r6
	character_rx  .req r7
	string_tx     .req r8
	string_tx_dup .req r9

	push {r4-r9,lr}

	mov character_rx, heap
	ldr string_tx, uart32_uartint_emulate_dummy_str

	ldr temp, UART32_UARTINT_BUSY
	tst temp, #0x1
	bne uart32_uartint_emulate_errornak      @ If Busy

	ldr heap, UART32_UARTINT_HEAP
	cmp heap, #0
	beq uart32_uartint_emulate_error         @ If No Heap

	ldr count, UART32_UARTINT_COUNT

	ldr flag_escape, uart32_flag_escape

	/* Virtually Received */
	strb character_rx, _uart32_uartint_buffer

	/* If Succeed to Receive */

	cmp flag_mirror, #0
	beq uart32_uartint_emulate_sendack

	/* Mirror Received Data to Teletype */
	push {r0-r3}
	mov r0, string_tx
	ldr r1, uart32_uartint_buffer
	bl str32_strcat
	mov string_tx, r0
	pop {r0-r3}

	cmp string_tx, #0
	beq uart32_uartint_emulate_error

	b uart32_uartint_emulate_verify

	uart32_uartint_emulate_sendack:

		/* Send ACK (Acknowledgement) */
		push {r0-r3}
		mov r0, string_tx
		ldr r1, uart32_uartint_ack
		bl str32_strcat
		mov string_tx, r0
		pop {r0-r3}

		cmp string_tx, #0
		beq uart32_uartint_emulate_error

	uart32_uartint_emulate_verify:

		cmp flag_escape, #1
		beq uart32_uartint_emulate_escseq        @ If in Escape Sequence

		/* Check Escape */
		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x1B                    @ Ascii Code of Escape
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}

		cmp temp, #-1
		movne flag_escape, #1
		bne uart32_uartint_emulate_escseq_common @ If Start of Escape Sequence

		/* Check Back Space */
		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x08                    @ Ascii Code of Back Space
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}

		cmp temp, #-1
		bne uart32_uartint_emulate_backspace

		/* Check Carriage Return */
		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x0D                    @ Ascii Codes of Carriage Return (By Pressing Enter Key)
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}

		cmp temp, #-1
		bne uart32_uartint_emulate_carriagereturn

		cmp count, max_size
		subge count, max_size, #1

		push {r0-r3}
		mov r0, heap
		bl str32_strlen
		mov temp, r0                     @ Most Significant Insert Position
		pop {r0-r3}

		cmp count, temp
		cmplt temp, max_size
		blt uart32_uartint_emulate_insert

		/* Store Data to Actual Memory Space from Buffer */
		ldr temp, uart32_uartint_buffer
		ldrb temp, [temp]
		strb temp, [heap, count]

		/* Slide Offset Count */
		add count, count, #1
		cmp count, max_size
		subge count, max_size, #1        @ If Exceeds Maximum Size of Heap, Stay Count
		str count, UART32_UARTINT_COUNT
		blt uart32_uartint_emulate_success

		/* Cursor Left If Reaching Maximum Size of Line */
		push {r0-r3}
		mov r0, string_tx
		ldr r1, uart32_uartint_esc_left
		bl str32_strcat
		mov string_tx_dup, r0
		pop {r0-r3}

		cmp string_tx_dup, #0
		beq uart32_uartint_emulate_error

		push {r0-r3}
		mov r0, string_tx
		bl heap32_mfree
		pop {r0-r3}

		mov string_tx, string_tx_dup

		b uart32_uartint_emulate_success

	uart32_uartint_emulate_escseq:

		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x41                    @ Ascii Codes of A
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}
		cmp temp, #-1
		bne uart32_uartint_emulate_escseq_up

		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x42                    @ Ascii Codes of B
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}
		cmp temp, #-1
		bne uart32_uartint_emulate_escseq_down

		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x43                    @ Ascii Codes of C
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}
		cmp temp, #-1
		bne uart32_uartint_emulate_escseq_right

		push {r0-r3}
		ldr r0, uart32_uartint_buffer
		mov r1, #1
		mov r2, #0x44                    @ Ascii Codes of D
		bl str32_charsearch
		mov temp, r0
		pop {r0-r3}
		cmp temp, #-1
		bne uart32_uartint_emulate_escseq_left

		b uart32_uartint_emulate_escseq_common

		uart32_uartint_emulate_escseq_up:

			/* Send Move Cursor Down Because Of Overshoot */
			push {r0-r3}
			mov r0, string_tx
			ldr r1, uart32_uartint_esc_down
			bl str32_strcat
			mov string_tx_dup, r0
			pop {r0-r3}

			cmp string_tx_dup, #0
			beq uart32_uartint_emulate_error

			push {r0-r3}
			mov r0, string_tx
			bl heap32_mfree
			pop {r0-r3}
			
			mov string_tx, string_tx_dup

			b uart32_uartint_emulate_escseq_clear

		uart32_uartint_emulate_escseq_down:

			/* Send Move Cursor Up Because Of Overshoot */
			push {r0-r3}
			mov r0, string_tx
			ldr r1, uart32_uartint_esc_up
			bl str32_strcat
			mov string_tx_dup, r0
			pop {r0-r3}

			cmp string_tx_dup, #0
			beq uart32_uartint_emulate_error

			push {r0-r3}
			mov r0, string_tx
			bl heap32_mfree
			pop {r0-r3}
			
			mov string_tx, string_tx_dup

			b uart32_uartint_emulate_escseq_clear

		uart32_uartint_emulate_escseq_right:

			add count, count, #1
			cmp count, max_size
			bge uart32_uartint_emulate_escseq_right_over @ If Exceeds Maximum Size of Heap, Stay Count

			push {r0-r3}
			mov r0, heap
			bl str32_strlen
			mov temp, r0
			pop {r0-r3}
			cmp count, temp
			ble uart32_uartint_emulate_escseq_clear

			uart32_uartint_emulate_escseq_right_over:

				/* Count Overshoots Length of List */
				sub count, count, #1

				/* Send Move Cursor Left Because Of Overshoot */
				push {r0-r3}
				mov r0, string_tx
				ldr r1, uart32_uartint_esc_left
				bl str32_strcat
				mov string_tx_dup, r0
				pop {r0-r3}

				cmp string_tx_dup, #0
				beq uart32_uartint_emulate_error

				push {r0-r3}
				mov r0, string_tx
				bl heap32_mfree
				pop {r0-r3}
				
				mov string_tx, string_tx_dup

				b uart32_uartint_emulate_escseq_clear

		uart32_uartint_emulate_escseq_left:
			
			sub count, count, #1
			cmp count, #0
			bge uart32_uartint_emulate_escseq_clear

			/* Count Becomes Minus */

			mov count, #0

			/* Send Move Cursor Right Because Of Overshoot */
			push {r0-r3}
			mov r0, string_tx
			ldr r1, uart32_uartint_esc_right
			bl str32_strcat
			mov string_tx_dup, r0
			pop {r0-r3}

			cmp string_tx_dup, #0
			beq uart32_uartint_emulate_error

			push {r0-r3}
			mov r0, string_tx
			bl heap32_mfree
			pop {r0-r3}
			
			mov string_tx, string_tx_dup

		uart32_uartint_emulate_escseq_clear:
			str count, UART32_UARTINT_COUNT
			mov flag_escape, #0

		uart32_uartint_emulate_escseq_common:
			str flag_escape, uart32_flag_escape
			b uart32_uartint_emulate_success

	uart32_uartint_emulate_backspace:

		sub count, count, #1
		cmp count, #0
		bge uart32_uartint_emulate_backspace_jmp

		/* Send Move Cursor Right Because of Overshoot */
		push {r0-r3}
		mov r0, string_tx
		ldr r1, uart32_uartint_esc_right
		bl str32_strcat
		mov string_tx_dup, r0
		pop {r0-r3}

		cmp string_tx_dup, #0
		beq uart32_uartint_emulate_error

		push {r0-r3}
		mov r0, string_tx
		bl heap32_mfree
		pop {r0-r3}
		
		mov string_tx, string_tx_dup

		b uart32_uartint_emulate_success

		uart32_uartint_emulate_backspace_jmp:

			/* Get Length of Back Half to Be Concatenated */
			push {r0-r3}
			add r0, heap, count
			add r0, r0, #1      @ Over Character to Be Deleted
			bl str32_strlen
			mov temp, r0
			pop {r0-r3}
			add temp, temp, #1  @ Add One For Null Character

			push {r0-r3}
			mov r0, heap
			mov r1, count
			mov r2, heap
			add r3, count, #1   @ Over Character to Be Deleted
			push {temp}
			bl heap32_mcopy
			add sp, sp, #4
			pop {r0-r3}

			sub temp, temp, #1  @ Subtract One For Null Character for Use Later

			/* Send Esc[K (Clear From Cursor Right) */
			push {r0-r3}
			mov r0, string_tx
			ldr r1, uart32_uartint_esc_clrline
			bl str32_strcat
			mov string_tx_dup, r0
			pop {r0-r3}

			cmp string_tx_dup, #0
			beq uart32_uartint_emulate_error

			push {r0-r3}
			mov r0, string_tx
			bl heap32_mfree
			pop {r0-r3}
			
			mov string_tx, string_tx_dup

			/* Reflect New Characters */
			push {r0-r3}
			mov r0, string_tx
			add r1, heap, count
			bl str32_strcat
			mov string_tx_dup, r0
			pop {r0-r3}

			cmp string_tx_dup, #0
			beq uart32_uartint_emulate_error

			push {r0-r3}
			mov r0, string_tx
			bl heap32_mfree
			pop {r0-r3}
			
			mov string_tx, string_tx_dup

			/* Move Cursor Left Because of Renewed Back Half */
			uart32_uartint_emulate_backspace_jmp_loop:
				cmp temp, #0
				ble uart32_uartint_emulate_backspace_jmp_common

				push {r0-r3}
				mov r0, string_tx
				ldr r1, uart32_uartint_esc_left
				bl str32_strcat
				mov string_tx_dup, r0
				pop {r0-r3}

				cmp string_tx_dup, #0
				beq uart32_uartint_emulate_error

				push {r0-r3}
				mov r0, string_tx
				bl heap32_mfree
				pop {r0-r3}
				
				mov string_tx, string_tx_dup

				sub temp, temp, #1
				b uart32_uartint_emulate_backspace_jmp_loop

			uart32_uartint_emulate_backspace_jmp_common:
				str count, UART32_UARTINT_COUNT
				b uart32_uartint_emulate_success

	uart32_uartint_emulate_carriagereturn:

		mov temp, #1
		str temp, UART32_UARTINT_BUSY

		b uart32_uartint_emulate_success

	uart32_uartint_emulate_insert:

		/* Get Length of Back Half to Be Concatenated */
		push {r0-r3}
		add r0, heap, count
		bl str32_strlen
		mov temp, r0
		pop {r0-r3}
		add temp, temp, #1  @ Add One For Null Character
		
		/* Calculate Buffer, If Remainder of 4 Exists, Add 4 */
		tst temp, #0b11
		addne buffer, temp, #0b100
		moveq buffer, temp
		lsr buffer, buffer, #2  @ Substitute of Division by 4

		push {r0-r3}
		mov r0, buffer
		bl heap32_malloc
		mov buffer, r0
		pop {r0-r3}

		/* If Memory Allocation Failed */
		cmp buffer, #0
		beq uart32_uartint_emulate_insert_common

		push {r0-r3}
		mov r0, buffer 
		mov r1, #0
		mov r2, heap
		mov r3, count
		push {temp}
		bl heap32_mcopy
		add sp, sp, #4
		pop {r0-r3}

		push {r0-r3}
		mov r0, heap
		add r1, count, #1       @ Get Space For New Character
		mov r2, buffer 
		mov r3, #0
		push {temp}
		bl heap32_mcopy
		add sp, sp, #4
		pop {r0-r3}

		push {r0-r3}
		mov r0, buffer
		bl heap32_mfree
		pop {r0-r3}

		sub temp, temp, #1      @ Subtract One For Null Character for Use Later

		ldr buffer, uart32_uartint_buffer
		ldrb buffer, [buffer]
		strb buffer, [heap, count]

		/* Send Esc[K (Clear From Cursor Right) */
		push {r0-r3}
		mov r0, string_tx
		ldr r1, uart32_uartint_esc_clrline
		bl str32_strcat
		mov string_tx_dup, r0
		pop {r0-r3}

		cmp string_tx_dup, #0
		beq uart32_uartint_emulate_error

		push {r0-r3}
		mov r0, string_tx
		bl heap32_mfree
		pop {r0-r3}
		
		mov string_tx, string_tx_dup

		/* Reflect New Characters */
		push {r0-r3}
		mov r0, string_tx
		add r1, heap, count
		add r1, r1, #1
		bl str32_strcat
		mov string_tx_dup, r0
		pop {r0-r3}

		cmp string_tx_dup, #0
		beq uart32_uartint_emulate_error

		push {r0-r3}
		mov r0, string_tx
		bl heap32_mfree
		pop {r0-r3}
		
		mov string_tx, string_tx_dup

		/* Move Cursor Left Because of Renewed Back Half */
		uart32_uartint_emulate_insert_loop:
			cmp temp, #0
			ble uart32_uartint_emulate_insert_common

			push {r0-r3}
			mov r0, string_tx
			ldr r1, uart32_uartint_esc_left
			bl str32_strcat
			mov string_tx_dup, r0
			pop {r0-r3}

			cmp string_tx_dup, #0
			beq uart32_uartint_emulate_error

			push {r0-r3}
			mov r0, string_tx
			bl heap32_mfree
			pop {r0-r3}
				
			mov string_tx, string_tx_dup

			sub temp, temp, #1
			b uart32_uartint_emulate_insert_loop

		uart32_uartint_emulate_insert_common:

			/* Slide Offset Count */
			add count, count, #1
			cmp count, max_size
			subge count, max_size, #1        @ If Exceeds Maximum Size of Heap, Stay Count
			str count, UART32_UARTINT_COUNT
			blt uart32_uartint_emulate_success

			/* Cursor Left If Reaching Maximum Size of Line */
			push {r0-r3}
			mov r0, string_tx
			ldr r1, uart32_uartint_esc_left
			bl str32_strcat
			mov string_tx_dup, r0
			pop {r0-r3}

			cmp string_tx_dup, #0
			beq uart32_uartint_emulate_error

			push {r0-r3}
			mov r0, string_tx
			bl heap32_mfree
			pop {r0-r3}

			mov string_tx, string_tx_dup

			b uart32_uartint_emulate_success

	uart32_uartint_emulate_errornak:

		/* Send NAK (Negative-acknowledgement) */
		push {r0-r3}
		mov r0, string_tx
		ldr r1, uart32_uartint_nak
		bl str32_strcat
		mov string_tx, r0
		pop {r0-r3}

		b uart32_uartint_emulate_success

	uart32_uartint_emulate_error:

		mov r0, #0

		b uart32_uartint_emulate_common

	uart32_uartint_emulate_success:
		mov r0, string_tx

	uart32_uartint_emulate_common:
/*macro32_debug r0, 100, 112*/
/*macro32_debug_hexa r0, 100, 124, 64*/
		macro32_dsb ip
		pop {r4-r9,pc}

.unreq max_size
.unreq flag_mirror
.unreq heap
.unreq count
.unreq temp
.unreq flag_escape
.unreq buffer
.unreq character_rx
.unreq string_tx
.unreq string_tx_dup

uart32_uartint_emulate_dummy_str: .word _uart32_uartint_emulate_dummy_str
_uart32_uartint_emulate_dummy_str: .word 0x00


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
		lsl size_heap, size_heap, #2            @ Substitution of Multiplication by 4
		sub size_heap, size_heap, #1            @ Subtract 1 Byte for Static Null Character at End
		str size_heap, UART32_UARTMALLOC_MAXROW
		str heap, UART32_UARTINT_HEAP           @ Store to First Place of Array
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
.globl UART32_UARTMALLOC_MAXROW
UART32_UARTMALLOC_ARRAY:       .word 0x00
UART32_UARTMALLOC_LENGTH:      .word 0x00
UART32_UARTMALLOC_NUMBER:      .word 0x00
UART32_UARTMALLOC_MAXROW:      .word 0x00


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
	bhs uart32_uartsetheap_error

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
