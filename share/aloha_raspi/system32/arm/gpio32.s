/**
 * gpio32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

GPIO32_SEQUENCE:            .word 0x00 @ Pointer of Sequence, If End, Automatically Cleared
GPIO32_LENGTH:              .word 0x00 @ Length of Music Code, If End, Automatically Cleared
GPIO32_COUNT:               .word 0x00 @ Incremental Count, Once Music Code Reaches Last, This Value will Be Reset
GPIO32_REPEAT:              .word 0x00 @ -1 is Infinite Loop
GPIO32_MASK:                .word equ32_gpio32_gpiomask

/**
 * Usage
 * 1. Place `gpio32_gpioplay` on FIQ/IRQ Handler which will be triggered with any timer.
 * 2. Place `_gpioset` with needed arguments in `user32.c`.
 * 3. GPIO sequence automatically runs with the assigned values.
 * 4. If you want to stop the GPIO sequence, use `_gpioclear`. Constant 1 of its argument will stay current status of GPIO.
 */

/**
 * GPIO sequence is made of 32-bit Blocks. One Block means one beat.
 * Bit[0]: GPIO 0 Output Low(0)/High(1)
 * Bit[1]: GPIO 1 Output Low(0)/High(1)
 * ...
 * Bit[29]: GPIO 29 Output Low(0)/High(1)
 * Bit[30]: Stay Prior Status of GPIO Which Are Assigned as Zero in the Block
 * Bit[31]: Always Need of Set(1)
 * Note that if a beat is all zero, this beat means the end of sequence.  
 */


/**
 * function gpio32_gpioplay
 * Play GPIO Sequence
 *
 * Return: r0 (0 as success, 1 as error)
 * Error: GPIO Sequence is not assigned
 */
.globl gpio32_gpioplay
gpio32_gpioplay:
	/* Auto (Local) Variables, but just Aliases */
	addr_seq      .req r0 @ Register for Result, Scratch Register
	length        .req r1 @ Scratch Register
	count         .req r2 @ Scratch Register
	repeat        .req r3 @ Scratch Register
	mask          .req r4
	sequence      .req r5
	sequence_flip .req r6
	gpio_base     .req r7
	temp          .req r8

	push {r4-r8}

	ldr addr_seq, GPIO32_SEQUENCE
	cmp addr_seq, #0
	beq gpio32_gpioplay_error

	ldr length, GPIO32_LENGTH
	ldr count, GPIO32_COUNT
	ldr repeat, GPIO32_REPEAT
	ldr mask, GPIO32_MASK

	cmp count, length
	blo gpio32_gpioplay_main

	mov count, #0

	cmp repeat, #-1
	beq gpio32_gpioplay_main

	sub repeat, repeat, #1

	cmp repeat, #0
	beq gpio32_gpioplay_free

	gpio32_gpioplay_main:

		mov gpio_base, #equ32_peripherals_base
		add gpio_base, gpio_base, #equ32_gpio_base

		lsl temp, count, #2                        @ Substitution of Multiplication by 4

		ldr sequence, [addr_seq, temp]

		tst sequence, #0x40000000                  @ Check Stay Status Bit[30]
		ldrne temp, [gpio_base, #equ32_gpio_gplev0]
		orrne sequence, sequence, temp

		and sequence, sequence, mask               @ Mask For Available GPIO Bit[29-0]

		mvn sequence_flip, sequence

		str sequence_flip, [gpio_base, #equ32_gpio_gpclr0]

		macro32_dsb ip

		str sequence, [gpio_base, #equ32_gpio_gpset0]

		macro32_dsb ip

		add count, count, #1
		str count, GPIO32_COUNT
		str repeat, GPIO32_REPEAT

		b gpio32_gpioplay_success

	gpio32_gpioplay_free:

		mov addr_seq, #0
		mov length, #0

		str addr_seq, GPIO32_SEQUENCE
		str length, GPIO32_LENGTH
		str count, GPIO32_COUNT               @ count is Already Zero
		str repeat, GPIO32_REPEAT             @ repeat is Already Zero

		b gpio32_gpioplay_success

	gpio32_gpioplay_error:
		mov r0, #1
		b gpio32_gpioplay_common

	gpio32_gpioplay_success:
		mov r0, #0                            @ Return with Success

	gpio32_gpioplay_common:
		pop {r4-r8}
		mov pc, lr

.unreq addr_seq
.unreq length
.unreq count
.unreq repeat
.unreq mask
.unreq sequence
.unreq sequence_flip
.unreq gpio_base
.unreq temp


/**
 * function gpio32_gpioset
 * Set GPIO Sequence
 *
 * Parameters
 * r0: GPIO Sequence
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success)
 */
.globl gpio32_gpioset
gpio32_gpioset:
	/* Auto (Local) Variables, but just Aliases */
	addr_seq    .req r0 @ Register for Result, Scratch Register
	length      .req r1 @ Scratch Register
	count       .req r2 @ Scratch Register
	repeat      .req r3 @ Scratch Register
	temp        .req r4

	push {r4}

	mov temp, #0

	str temp, GPIO32_SEQUENCE     @ Prevent Odd Functions

	macro32_dsb ip

	str length, GPIO32_LENGTH
	str count, GPIO32_COUNT
	str repeat, GPIO32_REPEAT

	macro32_dsb ip

	str addr_seq, GPIO32_SEQUENCE @ Should Set at End for Polling Function, `gpio32_gpioplay`

	gpio32_gpioset_success:
		mov r0, #0                                 @ Return with Success

	gpio32_gpioset_common:
		pop {r4}
		mov pc, lr

.unreq addr_seq
.unreq length
.unreq count
.unreq repeat
.unreq temp


/**
 * function gpio32_gpioclear
 * Clear GPIO Sequence
 *
 * Parameters
 * r0: Clear All (0) / Stay GPIO Current Status (1)
 *
 * Return: r0 (0 as success)
 */
.globl gpio32_gpioclear
gpio32_gpioclear:
	/* Auto (Local) Variables, but just Aliases */
	stay        .req r0
	temp        .req r1
	temp2       .req r2

	mov temp, #0

	str temp, GPIO32_SEQUENCE                  @ Prevent Odd Functions

	macro32_dsb ip

	str temp, GPIO32_LENGTH
	str temp, GPIO32_COUNT
	str temp, GPIO32_REPEAT

	cmp stay, #0
	bhi gpio32_gpioclear_success

	ldr temp2, GPIO32_MASK
	mov temp, #equ32_peripherals_base
	add temp, temp, #equ32_gpio_base
	str temp2, [temp, #equ32_gpio_gpclr0]      @ Clear All

	gpio32_gpioclear_success:
		mov r0, #0                                 @ Return with Success

	gpio32_gpioclear_common:
		mov pc, lr

.unreq stay
.unreq temp
.unreq temp2


/**
 * function gpio32_gpiolen
 * Count 4-Bytes Beats of GPIO Sequence
 *
 * Parameters
 * r0: Pointer of Array of GPIO Sequence
 *
 * Return: r0 (Number of Beats in GPIO Sequence) Maximum of 4,294,967,295 Beats
 */
.globl gpio32_gpiolen
gpio32_gpiolen:
	/* Auto (Local) Variables, but just Aliases */
	sequence_point .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	sequence_word  .req r1
	length         .req r2

	mov length, #0

	gpio32_gpiolen_loop:
		ldr sequence_word, [sequence_point]         @ Load Half Word (16-bit)
		cmp sequence_word, #0                       @ NULL Character (End of String) Checker
		beq gpio32_gpiolen_common                   @ Break Loop if Null Character

		add sequence_point, sequence_point, #4
		add length, length, #1
		b gpio32_gpiolen_loop

	gpio32_gpiolen_common:
		mov r0, length
		mov pc, lr

.unreq sequence_point
.unreq sequence_word
.unreq length
