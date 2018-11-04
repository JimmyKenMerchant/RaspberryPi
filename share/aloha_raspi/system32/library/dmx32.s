/**
 * dmx32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function dmx32_dmx512doublebuffer_init
 * Initialize DMX512 Double Buffer Transmitter
 *
 * Parameters
 * r0: Number of Frames, Start Code and Channel Data
 *
 * Return: r0 (0 as success, 1 as error)
 * Error: Memory Allocation Fails
 */
.globl dmx32_dmx512doublebuffer_init
dmx32_dmx512doublebuffer_init:
	/* Auto (Local) Variables, but just Aliases */
	num_data       .req r0
	temp           .req r1

	push {lr}

	str num_data, DMX32_BUFFER_LENGTH

	lsr num_data, num_data, #2              @ Divide by 4
	add num_data, num_data, #1              @ Complement for Remainder

	push {r0}
	bl heap32_malloc
	mov temp, r0
	pop {r0}

	cmp temp, #0
	beq dmx32_dmx512doublebuffer_init_error

	str temp, DMX32_BUFFER_FRONT

	push {r0}
	bl heap32_malloc
	mov temp, r0
	pop {r0}

	cmp temp, #0
	beq dmx32_dmx512doublebuffer_init_error

	str temp, DMX32_BUFFER_BACK

	b dmx32_dmx512doublebuffer_init_success

	dmx32_dmx512doublebuffer_init_error:
		mov r0, #1
		b dmx32_dmx512doublebuffer_init_common

	dmx32_dmx512doublebuffer_init_success:
		mov r0, #0

	dmx32_dmx512doublebuffer_init_common:
		macro32_dsb ip
		pop {pc}

.unreq num_data
.unreq temp

.globl DMX32_BUFFER_FRONT
DMX32_BUFFER_FRONT:  .word 0x00
.globl DMX32_BUFFER_BACK
DMX32_BUFFER_BACK:   .word 0x00
.globl DMX32_BUFFER_LENGTH
DMX32_BUFFER_LENGTH: .word 0x00


/**
 * function dmx32_dmx512doublebuffer_tx
 * DMX512 Double Buffer Transmitter
 *
 * Return: r0 (0 as success, 1 as success and end of packet)
 */
.globl dmx32_dmx512doublebuffer_tx
dmx32_dmx512doublebuffer_tx:
	/* Auto (Local) Variables, but just Aliases */
	result .req r0
	temp   .req r1
	temp2  .req r2

	push {lr}

	ldr r0, DMX32_BUFFER_FRONT
	ldr r1, DMX32_BUFFER_LENGTH
	bl dmx32_dmx512transmitter
	cmp result, #-1
	bne dmx32_dmx512doublebuffer_tx_common

	/* Flip Front/Back If A Packet Reaches End */

	ldr temp, DMX32_BUFFER_FRONT
	ldr temp2, DMX32_BUFFER_BACK

	str temp2, DMX32_BUFFER_FRONT
	str temp, DMX32_BUFFER_BACK

	macro32_dsb ip

	dmx32_dmx512doublebuffer_tx_common:
		pop {pc}

.unreq result
.unreq temp
.unreq temp2


/**
 * function dmx32_dmx512transmitter
 * DMX512 Transmitter
 * This function should be used within a timer of 44 micro seconds and over.
 * If you use this function in a timer of 46 micro seconds;
 * the Break spends 92 micro seconds, the Mark After Break (MAB) spends 46 micro seconds,
 * the Mark Time Between Frames (MTBF) spends 2 micro seconds (46 - 44),
 * and the minimum Mark Time Between Packets (MTBP) spends 2 micro seconds (46 - 44).
 *
 * Parameters
 * r0: Pointer of Array of Start Code and Channel Data
 * r1: Number of Frames, Start Code and Channel Data
 *
 * Return: r0 (current sequence number, -1 as end of packet, -2 as error)
 * Error(-2): Overflow of Pointer of Array, Resets Sequence Number
 */
.globl dmx32_dmx512transmitter
dmx32_dmx512transmitter:
	/* Auto (Local) Variables, but just Aliases */
	data_point     .req r0
	num_data       .req r1
	sequence       .req r2
	memorymap_base .req r3
	temp           .req r4

	push {r4,lr}

	ldr sequence, dmx32_dmx512transmitter_sequence

	cmp sequence, #0
	beq dmx32_dmx512transmitter_break

	cmp sequence, #1
	beq dmx32_dmx512transmitter_success

	cmp sequence, #2
	beq dmx32_dmx512transmitter_mab

	b dmx32_dmx512transmitter_data

	dmx32_dmx512transmitter_break:
		push {r0-r3}
		mov r0, #1
		bl uart32_uartbreak
		pop {r0-r3}

		b dmx32_dmx512transmitter_success

	dmx32_dmx512transmitter_mab:
		push {r0-r3}
		mov r0, #0
		bl uart32_uartbreak
		pop {r0-r3}

		b dmx32_dmx512transmitter_success

	dmx32_dmx512transmitter_data:
		sub temp, sequence, #3
		cmp temp, num_data
		bge dmx32_dmx512transmitter_error

		push {r0-r3}
		add r0, data_point, temp
		mov r1, #1
		bl uart32_uarttx
		pop {r0-r3}

		add temp, temp, #1
		cmp temp, num_data
		bge dmx32_dmx512transmitter_packetend

		b dmx32_dmx512transmitter_success

	dmx32_dmx512transmitter_error:
		mov sequence, #0
		str sequence, dmx32_dmx512transmitter_sequence
		macro32_dsb ip
		mov r0, #-2

		b dmx32_dmx512transmitter_common

	dmx32_dmx512transmitter_packetend:
		mov sequence, #0
		str sequence, dmx32_dmx512transmitter_sequence
		macro32_dsb ip
		mvn r0, #0

		b dmx32_dmx512transmitter_common

	dmx32_dmx512transmitter_success:
		add sequence, sequence, #1
		str sequence, dmx32_dmx512transmitter_sequence
		macro32_dsb ip
		mov r0, #0

	dmx32_dmx512transmitter_common:
		pop {r4,pc}

.unreq data_point
.unreq num_data
.unreq sequence
.unreq memorymap_base
.unreq temp

dmx32_dmx512transmitter_sequence: .word 0x00


/**
 * function dmx32_dmx512doublebuffer_rx
 * DMX512 Double Buffer Receiver
 *
 * Return: r0 (current sequence number, -1 as break signal, -2, -3, and -4 as error)
 * Error(-2): Not Received
 * Error(-3): Overrun, Parity Error, Framing Error, Not Received
 * Error(-4): Overflow of Pointer of Array
 */
.globl dmx32_dmx512doublebuffer_rx
dmx32_dmx512doublebuffer_rx:
	/* Auto (Local) Variables, but just Aliases */
	result .req r0
	temp   .req r1
	temp2  .req r2

	push {lr}

	ldr r0, DMX32_BUFFER_FRONT
	ldr r1, DMX32_BUFFER_LENGTH
	bl dmx32_dmx512receiver
	ldr temp, DMX32_BUFFER_LENGTH
	sub temp, temp, #1
	cmp result, temp
	bne dmx32_dmx512doublebuffer_rx_common

	/* Flip Front/Back If A Packet Reaches End */

	ldr temp, DMX32_BUFFER_FRONT
	ldr temp2, DMX32_BUFFER_BACK

	str temp2, DMX32_BUFFER_FRONT
	str temp, DMX32_BUFFER_BACK

	macro32_dsb ip

	dmx32_dmx512doublebuffer_rx_common:
		pop {pc}

.unreq result
.unreq temp
.unreq temp2


/**
 * function dmx32_dmx512receiver
 * DMX512 Receiver
 * This function should be used within an interrupt triggered by receiving data of UART.
 *
 * Parameters
 * r0: Pointer of Array of Start Code and Channel Data
 * r1: Number of Frames, Start Code and Channel Data
 *
 * Return: r0 (current sequence number, -1 as break signal, -2, -3, and -4 as error)
 * Error(-2): Not Received, Holds Sequence Number
 * Error(-3): Overrun, Parity Error, Framing Error, or Not Received; Holds Sequence Number
 * Error(-4): Overflow of Pointer of Array, Resets Sequence Number
 */
.globl dmx32_dmx512receiver
dmx32_dmx512receiver:
	/* Auto (Local) Variables, but just Aliases */
	data_point     .req r0
	num_data       .req r1
	sequence       .req r2
	temp           .req r3

	push {lr}

	ldr sequence, dmx32_dmx512receiver_sequence

	cmp sequence, num_data
	bge dmx32_dmx512receiver_error3

	push {r0-r2}
	add r0, data_point, sequence
	mov r1, #1                        @ 1 Bytes
	bl uart32_uartrx
	mov temp, r0                      @ Whether Overrun or Not
	pop {r0-r2}

	tst temp, #0x4                    @ Whether Break or Not
	bne dmx32_dmx512receiver_break    @ If Break

	tst temp, #0xB                    @ Whether Overrun, Parity Error, Framing Error, Not Received, or Not
	bne dmx32_dmx512receiver_error2   @ If Overrun, Parity Error, Framing Error, Not Received

	tst temp, #0x10                   @ Whether Not Received or Not
	bne dmx32_dmx512receiver_error1   @ If Not Received

	b dmx32_dmx512receiver_success

	dmx32_dmx512receiver_error1:
		mov r0, #-2
		b dmx32_dmx512receiver_common

	dmx32_dmx512receiver_error2:
		mov r0, #-3
		b dmx32_dmx512receiver_common

	dmx32_dmx512receiver_error3:
		mov sequence, #0
		str sequence, dmx32_dmx512receiver_sequence
		macro32_dsb ip
		mov r0, #-4
		b dmx32_dmx512receiver_common

	dmx32_dmx512receiver_break:
		mov sequence, #0
		str sequence, dmx32_dmx512receiver_sequence
		macro32_dsb ip
		mvn r0, #0
		b dmx32_dmx512receiver_common

	dmx32_dmx512receiver_success:
		/* Increment Sequence Number If Character Is Received */
		add temp, sequence, #1
		str temp, dmx32_dmx512receiver_sequence
		macro32_dsb ip
		mov r0, sequence

	dmx32_dmx512receiver_common:
		pop {pc}

.unreq data_point
.unreq num_data
.unreq sequence
.unreq temp

dmx32_dmx512receiver_sequence: .word 0x00
