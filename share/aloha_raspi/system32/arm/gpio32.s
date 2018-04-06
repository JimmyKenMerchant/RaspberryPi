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
 * Bit[31:30]:
 *  0b10: Change All Status of GPIO in Accordance with Block
 *  0b11: Stay Prior Status of GPIO Which Are Assigned as Zero in the Current Block
 *  0b01: Invert High/Low, Stay Prior Status of GPIO Which Are Assigned as Zero in the Current Block
 *  0b00: Ignore Block
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

		tst sequence, #0xC0000000
		beq gpio32_gpioplay_main_common            @ 0b00 on Bit[31:30]

		tst sequence, #0x40000000                  @ Check Stay Status Bit[30]
		beq gpio32_gpioplay_main_jump              @ 0b10 on Bit[31:30]

		/* Get Current Status of GPIO */
		ldr temp, [gpio_base, #equ32_gpio_gplev0]

		macro32_dsb ip

		tst sequence, #0x80000000
		orrne sequence, temp, sequence             @ ob11 on Bit[31:30]
		biceq sequence, temp, sequence             @ 0b01 on Bit[31:30], Invert

		gpio32_gpioplay_main_jump:

			mvn sequence_flip, sequence

			/* Mask For Available GPIO Bit[29-0] */
			and sequence, sequence, mask 
			and sequence_flip, sequence_flip, mask

			str sequence_flip, [gpio_base, #equ32_gpio_gpclr0]

			macro32_dsb ip

			str sequence, [gpio_base, #equ32_gpio_gpset0]

			macro32_dsb ip

		gpio32_gpioplay_main_common:

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


/**
 * function gpio32_gpiotoggle
 * Toggle GPIO High/Low on Output
 *
 * Parameters
 * r0: Number of GPIO to Toggled Output
 * r1: Control, Stable Low (0), Stable High (1), Swap High/Low (2)
 *
 * Return: r0 (0 as success)
 */
.globl gpio32_gpiotoggle
gpio32_gpiotoggle:
	/* Auto (Local) Variables, but just Aliases */
	number         .req r0
	control        .req r1
	memorymap_base .req r2
	temp           .req r3

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base

	/* Mask */
	and number, number, #0b111111                      @ Mask Only for 0-63

	cmp number, #31
	subgt number, number, #32

	mov temp, #1
	lsl number, temp, number

	bgt gpio32_gpiotoggle_upper

	cmp control, #0
	streq number, [memorymap_base, #equ32_gpio_gpclr0]
	beq gpio32_gpiotoggle_common

	cmp control, #1
	streq number, [memorymap_base, #equ32_gpio_gpset0]
	beq gpio32_gpiotoggle_common

	/* Toggle for GPIO 0-31 */
	ldr temp, [memorymap_base, #equ32_gpio_gplev0]
	macro32_dsb ip

	tst number, temp
	streq number, [memorymap_base, #equ32_gpio_gpset0]
	beq gpio32_gpiotoggle_common

	str number, [memorymap_base, #equ32_gpio_gpclr0]
	b gpio32_gpiotoggle_common

	/* Toggle for GPIO 32-63 */
	gpio32_gpiotoggle_upper:
		cmp control, #0
		streq number, [memorymap_base, #equ32_gpio_gpclr1]
		beq gpio32_gpiotoggle_common

		cmp control, #1
		streq number, [memorymap_base, #equ32_gpio_gpset1]
		beq gpio32_gpiotoggle_common

		ldr temp, [memorymap_base, #equ32_gpio_gplev1]
		macro32_dsb ip

		tst number, temp
		streq number, [memorymap_base, #equ32_gpio_gpset1]
		beq gpio32_gpiotoggle_common

		str number, [memorymap_base, #equ32_gpio_gpclr1]

	gpio32_gpiotoggle_common:
		macro32_dsb ip
		mov r0, #0                                          @ Return with Success
		mov pc, lr

.unreq number
.unreq control
.unreq memorymap_base
.unreq temp


/**
 * function gpio32_gpiomode
 * Set GPIO Mode
 *
 * Parameters
 * r0: Number of GPIO to Be Controlled
 * r1: Function Select
 *
 * Return: r0 (0 as success)
 */
.globl gpio32_gpiomode
gpio32_gpiomode:
	/* Auto (Local) Variables, but just Aliases */
	number         .req r0
	control        .req r1
	memorymap_base .req r2
	clear          .req r3

	push {lr}

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base

	/* Mask */
	and control, control, #0b111                       @ Mask Only for 0-7
	and number, number, #0b111111                      @ Mask Only for 0-63

	cmp number, #50
	addge memorymap_base, memorymap_base, #4
	cmp number, #40
	addge memorymap_base, memorymap_base, #4
	cmp number, #30
	addge memorymap_base, memorymap_base, #4
	cmp number, #20
	addge memorymap_base, memorymap_base, #4
	cmp number, #10
	addge memorymap_base, memorymap_base, #4

	push {r1-r3}
	mov r1, #10
	bl arm32_urem
	pop {r1-r3}

	/* GPIO 0-9 */
	mov clear, #3
	mul number, number, clear
	lsl control, control, number
	mov clear, #0b111
	lsl clear, clear, number

	.unreq number
	temp .req r0

	ldr temp, [memorymap_base]                       @ Current Status
	macro32_dsb ip
	bic temp, temp, clear
	orr control, control, temp
	str control, [memorymap_base]

	gpio32_gpiomode_common:
		macro32_dsb ip
		mov r0, #0                                         @ Return with Success
		pop {pc}

.unreq temp
.unreq control
.unreq memorymap_base
.unreq clear


/**
 * function gpio32_gpioevent
 * Set GPIO IN Event
 * This function is only available if GPIO is IN status.
 *
 * Parameters
 * r0: Number of GPIO to Be Controlled
 * r1: Event Select (0: Rising Edge, 1: Falling Edge, 2: High, 3: Low, 4: Asynchronous Rising Edge, 5: Asynchronous Falling Edge)
 * r2: Control (0: Off, 1: On)
 *
 * Return: r0 (0 as success)
 */
.globl gpio32_gpioevent
gpio32_gpioevent:
	/* Auto (Local) Variables, but just Aliases */
	number         .req r0
	event          .req r1
	flag_on        .req r2
	memorymap_base .req r3

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base
	add memorymap_base, memorymap_base, #equ32_gpio_gpren0

	/* Mask */
	and event, event, #0b111                           @ Mask Only for 0-7
	and number, number, #0b111111                      @ Mask Only for 0-63

	cmp event, #5
	addge memorymap_base, memorymap_base, #12
	cmp event, #4
	addge memorymap_base, memorymap_base, #12
	cmp event, #3
	addge memorymap_base, memorymap_base, #12
	cmp event, #2
	addge memorymap_base, memorymap_base, #12
	cmp event, #1
	addge memorymap_base, memorymap_base, #12

	.unreq event
	temp .req r1

	cmp number, #31
	subgt number, number, #32
	addgt memorymap_base, memorymap_base, #4
	mov temp, #1
	lsl number, temp, number

	/* GPIO 0-31 */
	ldr temp, [memorymap_base]
	macro32_dsb ip
	cmp flag_on, #1
	orreq temp, temp, number
	bicne temp, temp, number
	str temp, [memorymap_base]

	gpio32_gpioevent_common:
		macro32_dsb ip
		mov r0, #0                                          @ Return with Success
		mov pc, lr

.unreq number
.unreq temp
.unreq flag_on
.unreq memorymap_base


/**
 * function gpio32_gpiopull
 * Set GPIO Pull Up/Down Status on IN
 * This function is only available if GPIO is IN status.
 *
 * Parameters
 * r0: Number of GPIO to Be Controlled
 * r1: Control Signal (0: Off, 1: Pull Down, 2: Pull Up)
 *
 * Return: r0 (0 as success)
 */
.globl gpio32_gpiopull
gpio32_gpiopull:
	/* Auto (Local) Variables, but just Aliases */
	number         .req r0
	control        .req r1
	memorymap_base .req r2
	temp           .req r3

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base

	/* Mask */
	and control, control, #0b11                        @ Mask Only for 0-3
	and number, number, #0b111111                      @ Mask Only for 0-63

	str control, [memorymap_base, #equ32_gpio_gppud]   @ Set Control Signal

	macro32_dsb ip

	cmp number, #31
	subgt number, number, #32
	movgt control, #1
	movle control, #0

	mov temp, #1
	lsl number, temp, number

	mov temp, #150                                     @ Wait for 150 Clocks to Set Control Signal
	gpio32_gpiopull_wait:
		subs temp, #1
		bge gpio32_gpiopull_wait

	cmp control, #1
	beq gpio32_gpiopull_upper

	/* Signal for GPIO 0-31 */
	str number, [memorymap_base, #equ32_gpio_gppudclk0]

	macro32_dsb ip
	
	b gpio32_gpiopull_close

	/* Signal for GPIO 32-63 */
	gpio32_gpiopull_upper:
		str number, [memorymap_base, #equ32_gpio_gppudclk1]

		macro32_dsb ip

	gpio32_gpiopull_close:

		mov temp, #150                                      @ Wait for 150 Clocks to Set GPIO Pull Up/Down Status
		gpio32_gpiopull_close_wait:
			subs temp, #1
			bge gpio32_gpiopull_close_wait

		mov temp, #0
		str temp, [memorymap_base, #equ32_gpio_gppud]       @ Clear Control Signal
		cmp control, #1
		strne temp, [memorymap_base, #equ32_gpio_gppudclk0] @ Clear Signal for GPIO 0-31
		streq temp, [memorymap_base, #equ32_gpio_gppudclk1] @ Clear Signal for GPIO 32-63

	gpio32_gpiopull_common:
		mov r0, #0                                          @ Return with Success
		mov pc, lr

.unreq number
.unreq control
.unreq memorymap_base
.unreq temp
