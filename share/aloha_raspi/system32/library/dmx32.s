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

	lsr num_data, num_data, #2
	add num_data, num_data, #1

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
.unreq data_point
.unreq sequence
.unreq memorymap_base
.unreq temp

.globl DMX32_BUFFER_FRONT
DMX32_BUFFER_FRONT:  .word 0x00
.globl DMX32_BUFFER_BACK
DMX32_BUFFER_BACK:   .word 0x00
.globl DMX32_BUFFER_LENGTH
DMX32_BUFFER_LENGTH: .word 0x00


/**
 * function dmx32_dmx512doublebuffer
 * DMX512 Double Buffer Transmitter
 *
 * Return: r0 (0 as success)
 */
.globl dmx32_dmx512doublebuffer
dmx32_dmx512doublebuffer:
	/* Auto (Local) Variables, but just Aliases */
	temp  .req r0
	temp2 .req r1

	push {lr}

	ldr r0, DMX32_BUFFER_FRONT
	ldr r1, DMX32_BUFFER_LENGTH
	bl dmx32_dmx512transmitter
	cmp r0, #1
	bne dmx32_dmx512doublebuffer_common

	ldr temp, DMX32_BUFFER_FRONT
	ldr temp2, DMX32_BUFFER_BACK

	str temp2, DMX32_BUFFER_FRONT
	str temp, DMX32_BUFFER_BACK

	macro32_dsb ip

	dmx32_dmx512doublebuffer_common:
		mov r0, #0
		pop {pc}

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
 * Return: r0 (0 as success, 1 as success and end of packet)
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
		cmp sequence, num_data
		bge dmx32_dmx512transmitter_successend

		push {r0-r3}
		ldr r0, [data_point, temp]
		mov r1, #1
		bl uart32_uarttx
		pop {r0-r3}

		b dmx32_dmx512transmitter_success

	dmx32_dmx512transmitter_success:
		add sequence, sequence, #1
		str sequence, dmx32_dmx512transmitter_sequence
		macro32_dsb ip
		mov r0, #0
		b dmx32_dmx512transmitter_common

	dmx32_dmx512transmitter_successend:
		mov sequence, #0
		str sequence, dmx32_dmx512transmitter_sequence
		macro32_dsb ip
		mov r0, #1

	dmx32_dmx512transmitter_common:
		pop {r4,pc}

.unreq data_point
.unreq num_data
.unreq sequence
.unreq memorymap_base
.unreq temp

dmx32_dmx512transmitter_sequence: .word 0x00


/**
 * function dmx32_dmx512receiver
 * DMX512 Receiver
 * This function should be used within an interrupt triggered by receiving data of UART.
 *
 * Parameters
 * r0: Pointer of Array of Start Code and Channel Data
 * r1: Number of Frames, Start Code and Channel Data
 *
 * Return: r0 (0 as success)
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
	movge sequence, #0
	bge dmx32_dmx512receiver_common

	push {r0-r2}
	add r0, data_point, sequence
	mov r1, #1                        @ 1 Bytes
	bl uart32_uartrx
	mov temp, r0                      @ Whether Overrun or Not
	pop {r0-r2}

	tst temp, #0x4                    @ Whether Break or Not
	movne sequence, #0                @ If Break
	bne dmx32_dmx512receiver_common   @ If Break

	tst temp, #0x1B                   @ Whether Overrun, Parity Error, Framing Error, Not Received, or Not
	bne dmx32_dmx512receiver_common   @ If Overrun, Parity Error, Framing Error, Not Received

	add sequence, sequence, #1

	dmx32_dmx512receiver_common:
		str sequence, dmx32_dmx512receiver_sequence
		macro32_dsb ip
		mov r0, sequence
		pop {pc}

.unreq data_point
.unreq num_data
.unreq sequence
.unreq temp

dmx32_dmx512receiver_sequence: .word 0x00
