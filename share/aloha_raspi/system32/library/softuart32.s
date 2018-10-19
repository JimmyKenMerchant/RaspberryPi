/**
 * softuart32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * FIFO container is a block of 1-byte character.
 * First Byte: Bit[0] Break (Only RxFIFO)
 *             Bit[1] Overrun (FIFO Has Already Been Full)
 *             Bit[2] FIFO Is Fully Empty
 *             Bit[7:3] Stack Pointer, 0 to 16 (0 is Empty, Size is 16)
 * Second Byte to 17th Byte: Bit[7:0] Character to Receive
 */

/**
 * function softuart32_pop
 * Pop for Software UART
 *
 * Parameters
 * r0: Pointer of FIFO Container
 *
 * Return: r0 (0 as success)
 */
.globl softuart32_pop
softuart32_pop:
	/* Auto (Local) Variables, but just Aliases */
	fifo         .req r0
	byte         .req r1
	temp         .req r2
	sp_uart      .req r3
	i            .req r4
	j            .req r5
	save_cpsr    .req r6
	status       .req r7

	push {r4-r7}

	/* For Atomic Procedure, Set FIQ and IRQ Disable to CPSR */
	mrs save_cpsr, cpsr
	orr ip, save_cpsr, #equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, ip

	macro32_dsb ip

	ldrb status, [fifo]
	lsr sp_uart, status, #3

	ldrb byte, [fifo, sp_uart]
	cmp sp_uart, #0
	beq softuart32_pop_common

	mov i, #2
	mov j, #1
	softuart32_pop_loop:
		ldrb temp, [fifo, i]
		strb temp, [fifo, j]
		add i, i, #1
		add j, j, #1
		cmp i, #17
		blo softuart32_pop_loop

	sub sp_uart, sp_uart, #1
	cmp sp_uart, #0
	orreq status, status, #0b100                  @ Set Fully Empty
	lsl sp_uart, sp_uart, #3
	and status, status, #0b111
	bic status, status, #0b010                    @ Clear Overrun
	orr status, status, sp_uart
	strb status, [fifo]

	/* Return CPSR */
	msr cpsr_c, save_cpsr

	softuart32_pop_common:
		mov r0, byte
		pop {r4-r7}
		mov pc, lr

.unreq fifo
.unreq byte
.unreq temp
.unreq sp_uart
.unreq i
.unreq j
.unreq save_cpsr
.unreq status


/**
 * function softuart32_push
 * Pop for Software UART
 *
 * Parameters
 * r0: Pointer of FIFO Container
 * r1: Byte to Push
 *
 * Return: r0 (0 as success)
 */
.globl softuart32_push
softuart32_push:
	/* Auto (Local) Variables, but just Aliases */
	fifo         .req r0
	byte         .req r1
	temp         .req r2
	sp_uart      .req r3
	i            .req r4
	j            .req r5
	save_cpsr    .req r6
	status       .req r7

	push {r4-r7}

	/* For Atomic Procedure, Set FIQ and IRQ Disable to CPSR */
	mrs save_cpsr, cpsr
	orr ip, save_cpsr, #equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, ip

	macro32_dsb ip

	ldrb status, [fifo]
	lsr sp_uart, status, #3

	tst status, #0b0010                           @ If Overrun
	bne softuart32_push_common

	mov i, #15
	mov j, #16
	softuart32_push_loop:
		ldrb temp, [fifo, i]
		strb temp, [fifo, j]
		sub i, i, #1
		sub j, j, #1
		cmp i, #0
		bhi softuart32_push_loop

	strb byte, [fifo, #1]

	add sp_uart, sp_uart, #1
	cmp sp_uart, #16
	orrhs status, status, #0b010                  @ Set Overrun
	lsl sp_uart, sp_uart, #3
	and status, #0b111
	bic status, status, #0b100                    @ Clear Fully Empty
	orr status, status, sp_uart
	strb status, [fifo]

	/* Return CPSR */
	msr cpsr_c, save_cpsr

	softuart32_push_common:
		mov r0, #0
		pop {r4-r7}
		mov pc, lr

.unreq fifo
.unreq byte
.unreq temp
.unreq sp_uart
.unreq i
.unreq j
.unreq save_cpsr
.unreq status


/**
 * function softuart32_softuartrx
 * Receive from Software UART
 *
 * Parameters
 * r0: Pointer of Receive Buffer
 * r1: Receive Size (Bytes), Up to 16 Is Preferred Because Of RxFIFO Size
 * r2: Pointer of FIFO Container
 *
 * Return: r0 (0 as success, not 0 as error)
 * Bit[31:4]: Size (Bytes) Not Received
 * Bit[2]: FIFO Is Fully Empty
 * Bit[0]: Break
 */
.globl softuart32_softuartrx
softuart32_softuartrx:
	/* Auto (Local) Variables, but just Aliases */
	heap    .req r0
	size_rx .req r1
	fifo    .req r2
	temp    .req r3
	byte    .req r4

	push {r4,lr}

	softuart32_softuartrx_fifo:
		ldrb temp, [fifo]
		tst temp, #0b101                     @ Break or Fully Empty
		bne softuart32_softuartrx_error

		push {r0-r3}
		mov r0, fifo
		bl softuart32_pop
		mov byte, r0
		pop {r0-r3}

		strb byte, [heap]

		add heap, heap, #1
		sub size_rx, size_rx, #1

		cmp size_rx, #0
		bgt softuart32_softuartrx_fifo

		b softuart32_softuartrx_success

	softuart32_softuartrx_error:
		and r0, temp, #0b0111
		orr r0, r0, size_rx, lsl #4
		b softuart32_softuartrx_common

	softuart32_softuartrx_success:
		mov r0, #0

	softuart32_softuartrx_common:
		pop {r4,pc}

.unreq heap
.unreq size_rx
.unreq fifo
.unreq temp
.unreq byte


/**
 * function softuart32_softuarttx
 * Transfer from Software UART
 *
 * Parameters
 * r0: Pointer of Transfer Buffer
 * r1: Transfer Size (Bytes)
 * r2: Pointer of FIFO Container
 *
 * Return: r0 (0 as success)
 */
.globl softuart32_softuarttx
softuart32_softuarttx:
	/* Auto (Local) Variables, but just Aliases */
	heap    .req r0
	size_tx .req r1
	fifo    .req r2
	temp    .req r3
	byte    .req r4

	push {r4,lr}

	softuart32_softuarttx_fifo:
		ldrb temp, [fifo]
		tst temp, #0b010                    @ Overrun (Already Full)
		bne softuart32_softuarttx_fifo

		push {r0-r3}
		ldr r1, [heap]
		mov r0, fifo
		bl softuart32_push
		pop {r0-r3}

		add heap, heap, #1
		sub size_tx, size_tx, #1

		cmp size_tx, #0
		bgt softuart32_softuarttx_fifo

	softuart32_softuarttx_success:
		mov r0, #0

	softuart32_softuarttx_common:
		pop {r4,pc}

.unreq heap
.unreq size_tx
.unreq fifo
.unreq temp
.unreq byte


/**
 * function softuart32_softuartreceiver
 * Receiver from Software UART
 *
 * Parameters
 * r0: GPIO Number
 * r1: Pointer of FIFO Container
 *
 * Return: r0 (0 as success, 1 as Error)
 * Error: Overrun (FIFO Has Already Been Full)
 */
.globl softuart32_softuartreceiver
softuart32_softuartreceiver:
	/* Auto (Local) Variables, but just Aliases */
	num_gpio       .req r0
	fifo           .req r1
	temp           .req r2
	sequence       .req r3
	byte           .req r4
	memorymap_base .req r5

	push {r4-r5,lr}

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base

	ldr sequence, softuart32_softuartreceiver_sequence
	cmp sequence, #9
	bhs softuart32_softuartreceiver_stopbit
	cmp sequence, #0
	beq softuart32_softuartreceiver_startbit

	b softuart32_softuartreceiver_character

	softuart32_softuartreceiver_startbit:
		cmp num_gpio, #31
		subhi num_gpio, num_gpio, #32
		mov temp, #1
		lsl num_gpio, temp, num_gpio

		ldrls temp, [memorymap_base, #equ32_gpio_gplev0]
		ldrhi temp, [memorymap_base, #equ32_gpio_gplev1]

		tst num_gpio, temp
		bne softuart32_softuartreceiver_success

		/* If Low State, Beginning of Receving */

		mov byte, #0
		str byte, softuart32_softuartreceiver_byte
		add sequence, sequence, #1

		b softuart32_softuartreceiver_success

	softuart32_softuartreceiver_character:
		cmp num_gpio, #31
		subhi num_gpio, num_gpio, #32
		mov temp, #1
		lsl num_gpio, temp, num_gpio

		ldrls temp, [memorymap_base, #equ32_gpio_gplev0]
		ldrhi temp, [memorymap_base, #equ32_gpio_gplev1]

		tst num_gpio, temp

		/* If High State, Set Bit */

		subne temp, sequence, #1
		movne num_gpio, #1
		lslne temp, num_gpio, temp
		ldrne byte, softuart32_softuartreceiver_byte
		orrne byte, byte, temp
		strne byte, softuart32_softuartreceiver_byte

		add sequence, sequence, #1

		b softuart32_softuartreceiver_success

	softuart32_softuartreceiver_stopbit:
		cmp num_gpio, #31
		subhi num_gpio, num_gpio, #32
		mov temp, #1
		lsl num_gpio, temp, num_gpio

		ldrls temp, [memorymap_base, #equ32_gpio_gplev0]
		ldrhi temp, [memorymap_base, #equ32_gpio_gplev1]

		/* If Low State, Set Break and Error */

		tst num_gpio, temp
		ldreqb temp, [fifo]
		orreq temp, temp, #0b001                         @ Set Break
		streqb temp, [fifo]
		moveq sequence, #0
		beq softuart32_softuartreceiver_error

		/* If High State, Got Stop Bit Correctly */

		push {r0-r3}
		mov r0, fifo
		ldr r1, softuart32_softuartreceiver_byte
		bl softuart32_push
		pop {r0-r3}

		mov sequence, #0

		b softuart32_softuartreceiver_success

	softuart32_softuartreceiver_error:
		mov r0, #1
		b softuart32_softuartreceiver_common

	softuart32_softuartreceiver_success:
		str sequence, softuart32_softuartreceiver_sequence
		mov r0, #0

	softuart32_softuartreceiver_common:
		macro32_dsb ip
		pop {r4-r5,pc}

.unreq num_gpio
.unreq fifo
.unreq temp
.unreq sequence
.unreq byte
.unreq memorymap_base

softuart32_softuartreceiver_sequence: .word 0x00
softuart32_softuartreceiver_byte:     .word 0x00


/**
 * function softuart32_softuarttransceiver
 * Transceiver from Software UART
 *
 * Parameters
 * r0: GPIO Number
 * r1: Pointer of FIFO Container
 *
 * Return: r0 (0 as success, 1 as Error)
 * Error: FIFO Is Fully Empty
 */
.globl softuart32_softuarttransceiver
softuart32_softuarttransceiver:
	/* Auto (Local) Variables, but just Aliases */
	num_gpio .req r0
	fifo     .req r1
	temp     .req r2
	sequence .req r3
	byte     .req r4

	push {r4,lr}

	ldr sequence, softuart32_softuarttransceiver_sequence
	cmp sequence, #9
	bhs softuart32_softuarttransceiver_stopbit
	cmp sequence, #0
	beq softuart32_softuarttransceiver_startbit

	b softuart32_softuarttransceiver_character

	softuart32_softuarttransceiver_startbit:
		ldr temp, [fifo]
		tst temp, #0b100
		bne softuart32_softuarttransceiver_error

		push {r0-r3}
		mov r1, #0                                @ Low
		bl gpio32_gpiotoggle
		pop {r0-r3}

/*
macro32_debug_hexa fifo, 100, 88, 17
*/

		push {r0-r3}
		mov r0, fifo
		bl softuart32_pop
		mov byte, r0
		pop {r0-r3}

/*
macro32_debug byte, 100, 100
macro32_debug_hexa fifo, 100, 112, 17
*/

		str byte, softuart32_softuarttransceiver_byte
		add sequence, sequence, #1
		b softuart32_softuarttransceiver_success

	softuart32_softuarttransceiver_character:
		ldr byte, softuart32_softuarttransceiver_byte
		sub temp, sequence, #1
		lsr byte, byte, temp

		push {r0-r3}
		tst byte, #1
		moveq r1, #0                               @ Low (0)
		movne r1, #1                               @ High (1)
		bl gpio32_gpiotoggle
		pop {r0-r3}

		add sequence, sequence, #1
		b softuart32_softuarttransceiver_success

	softuart32_softuarttransceiver_stopbit:
		push {r0-r3}
		mov r1, #1                                 @ High
		bl gpio32_gpiotoggle
		pop {r0-r3}

		mov sequence, #0

		b softuart32_softuarttransceiver_success

	softuart32_softuarttransceiver_error:
		mov r0, #1
		b softuart32_softuarttransceiver_common

	softuart32_softuarttransceiver_success:
		str sequence, softuart32_softuarttransceiver_sequence
		mov r0, #0

	softuart32_softuarttransceiver_common:
		macro32_dsb ip
		pop {r4,pc}

.unreq num_gpio
.unreq fifo
.unreq temp
.unreq sequence
.unreq byte

softuart32_softuarttransceiver_sequence: .word 0x00
softuart32_softuarttransceiver_byte:     .word 0x00

