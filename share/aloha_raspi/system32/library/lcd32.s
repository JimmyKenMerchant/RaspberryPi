/**
 * lcd32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * This library is aiming to be used with any liquid-crystal display (LCD) module,
 * and the driver chip is assumed to be HD44780 LCD controller.
 * This library uses parallel 4-bit operation, and 6 GPIO pins are used.
 * Caution that many LCDs are considered of operation with 5 volts, even though HD44780 can drive with 3.3 volts,
 * so you may need to apply logic level converters to pins for converting from 3.3 volts to 5 volts.
 * The difference of electrical potential makes the status (passing/shuttering light) of a LCD.
 * The low difference, such as 3.3 volts, may not change the status of a LCD to avoid its incorrect indication.
 */

 /**
  * This library uses 6 GPIO pins.
  * GPIO pins will be used sequentially as described below.
  *   First GPIO Pin:  For BD4 in LCD module
  *   Second GPIO Pin: For BD5 in LCD module
  *   Third GPIO Pin:  For BD6 in LCD module
  *   Fourth GPIO Pin: For BD7 in LCD module
  *   Fifth GPIO Pin:  For EN in LCD module
  *   Sixth GPIO Pin:  For RS in LCD module
  *
  * Note:
  *   You can change the first position of the GPIO pin.
  *   R/W in LCD module is needed to connect with GND.
  *   BD0 - BD3 should be open.
  *   GPIO pins to be used are needed to be set as output.
  */

/**
 * function lcd32_lcdput4
 * Put Instruction or Data in 4-bit Operation
 *
 * Parameters
 * r0: Character to Be Set
 * r1: 0 as Instruction, 1 as Data
 * r2: 0 as Half Operation (for 8-bit Operation), 1 as Full Operation
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdput4
lcd32_lcdput4:
	/* Auto (Local) Variables, but just Aliases */
	character      .req r0
	flag_data      .req r1
	flag_full      .req r2
	memorymap_base .req r3
	offset         .req r4
	temp           .req r5

	push {r4-r5,lr}

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_gpio_base
	ldr offset, lcd32_offset
	and character, character, #0xFF            @ Mask Only for Byte

	/* Clear RS, EN, and DB7 - DB4 in Advance */
	mov temp, #0b111111
	lsl temp, temp, offset
	str temp, [memorymap_base, #equ32_gpio_gpclr0]

	macro32_dsb ip

	/* Set RS as Data If Flag Is Set */
	cmp flag_data, #0
	movne temp, #0b100000
	lslne temp, temp, offset
	strne temp, [memorymap_base, #equ32_gpio_gpset0]

	/* Interval for RS and R/W (Fixed at W) */
	push {r0-r3}
	mov r0, #equ32_lcd32_time_clock
	bl arm32_sleep
	pop {r0-r3}

	macro32_dsb ip

	/* Set EN and DB7 - DB4 for MSBs */
	lsr temp, character, #4
	orr temp, temp, #0b010000
	lsl temp, temp, offset
	str temp, [memorymap_base, #equ32_gpio_gpset0]

	/* Interval for Set EN and DB7 - DB4 (MSBs) */
	push {r0-r3}
	mov r0, #equ32_lcd32_time_clock
	bl arm32_sleep
	pop {r0-r3}

	macro32_dsb ip

	/* Clear EN */
	mov temp, #0b010000
	lsl temp, temp, offset
	str temp, [memorymap_base, #equ32_gpio_gpclr0]

	/* Interval for Cleared EN and DB7 - DB4 for MSBs */
	push {r0-r3}
	mov r0, #equ32_lcd32_time_clock
	bl arm32_sleep
	pop {r0-r3}

	macro32_dsb ip

	cmp flag_full, #1
	bne lcd32_lcdput4_common

	/* Clear DB7 - DB4 for MSBs */
	mov temp, #0b001111
	lsl temp, temp, offset
	str temp, [memorymap_base, #equ32_gpio_gpclr0]

	macro32_dsb ip

	/* Set EN and DB7 - DB4 for LSBs */
	and temp, character, #0b1111
	orr temp, temp, #0b010000
	lsl temp, temp, offset
	str temp, [memorymap_base, #equ32_gpio_gpset0]

	/* Interval for Set EN and DB7 - DB4 for LSBs */
	push {r0-r3}
	mov r0, #equ32_lcd32_time_clock
	bl arm32_sleep
	pop {r0-r3}

	macro32_dsb ip

	/* Clear EN */
	mov temp, #0b010000
	lsl temp, temp, offset
	str temp, [memorymap_base, #equ32_gpio_gpclr0]

	/* Interval for Cleared EN and DB7 - DB4 for LSBs */
	push {r0-r3}
	mov r0, #equ32_lcd32_time_clock
	bl arm32_sleep
	pop {r0-r3}

	macro32_dsb ip

	lcd32_lcdput4_common:
		/* Clear RS and DB7 - DB4 */
		mov temp, #0b101111
		lsl temp, temp, offset
		str temp, [memorymap_base, #equ32_gpio_gpclr0]

		macro32_dsb ip

		mov r0, #0
		pop {r4-r5,pc}

.unreq character
.unreq flag_data
.unreq flag_full
.unreq memorymap_base
.unreq offset
.unreq temp

lcd32_offset:            .word 0x00


/**
 * function lcd32_lcdconfig
 * Set First Position of GPIO Pins to Be Used for Driving LCD
 *
 * Parameters
 * r0: Offset of GPIO Pins to Be Used for Driving LCD
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdconfig
lcd32_lcdconfig:
	/* Auto (Local) Variables, but just Aliases */
	offset .req r0

	push {lr}

	str offset, lcd32_offset

	macro32_dsb ip

	lcd32_lcdconfig_common:
		mov r0, #0
		pop {pc}

.unreq offset


/**
 * function lcd32_lcdinit
 * Initialization for Functions in This Library
 *
 * Parameters
 * r0: 0 as 5 * 8 Dots Characters (Possible Two Lines), 1 as 5 * 10 Dots Characters (Unpossible Two Lines)
 * r1: 0 as One Line, 1 as Two Lines in LCD
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdinit
lcd32_lcdinit:
	/* Auto (Local) Variables, but just Aliases */
	flag_10dot    .req r0
	flag_2line    .req r1

	push {lr}

	/* Wait after Rise of VCC in LCD Controller */

	push {r0-r1}
	mov r0, #equ32_lcd32_time_reset1
	bl arm32_sleep
	pop {r0-r1}

	/* First Function Set for Initializing (8-bit Operation) */

	push {r0-r1}
	mov r0, #0b00110000
	mov r1, #0
	mov r2, #0
	bl lcd32_lcdput4
	pop {r0-r1}

	push {r0-r1}
	mov r0, #equ32_lcd32_time_reset2
	bl arm32_sleep
	pop {r0-r1}

	/* Second Function Set for Initializing (8-bit Operation) */

	push {r0-r1}
	mov r0, #0b00110000
	mov r1, #0
	mov r2, #0
	bl lcd32_lcdput4
	pop {r0-r1}

	push {r0-r1}
	mov r0, #equ32_lcd32_time_reset3
	bl arm32_sleep
	pop {r0-r1}

	/* Set 4-Bit Operation (Command is 8-bit Operation) */

	push {r0-r1}
	mov r0, #0b00100000
	mov r1, #0
	mov r2, #0
	bl lcd32_lcdput4
	pop {r0-r1}

	push {r0-r1}
	mov r0, #equ32_lcd32_time_execution1
	bl arm32_sleep
	pop {r0-r1}

	/* Set 4-Bit Operation Again and Number of Line */

	push {r0-r1}
	cmp flag_10dot, #0
	moveq r0, #0b00100000     @ 5 * 8 Dots
	movne r0, #0b00100100     @ 5 * 10 Dots
	cmp flag_2line, #0
	orrne r0, r0, #0b00001000 @ Two Lines
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4
	pop {r0-r1}

	push {r0-r1}
	mov r0, #equ32_lcd32_time_execution1
	bl arm32_sleep
	pop {r0-r1}

	/* Display Off */

	push {r0-r1}
	mov r0, #0b00001000
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4
	pop {r0-r1}

	push {r0-r1}
	mov r0, #equ32_lcd32_time_execution1
	bl arm32_sleep
	pop {r0-r1}

	/* Clear Display (All in DDRAM Become 0x20, Spaces, Address Becomes 0) */

	push {r0-r1}
	mov r0, #0b00000001
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4
	pop {r0-r1}

	push {r0-r1}
	mov r0, #equ32_lcd32_time_execution2
	bl arm32_sleep
	pop {r0-r1}

	lcd32_lcdinit_common:
		mov r0, #0
		pop {pc}

.unreq flag_10dot
.unreq flag_2line


/**
 * function lcd32_lcddisplay
 * Set Display Status
 *
 * Parameters
 * r0: Display Status
 *   r0 Bit[2]: 0 as Display Off, 1 as Display On
 *   r0 Bit[1]: 0 as Cursor Off, 1 as Cursor On
 *   r0 Bit[0]: 0 as Line Cursor, 1 as Blinking Cursor
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcddisplay
lcd32_lcddisplay:
	/* Auto (Local) Variables, but just Aliases */
	status_display .req r0

	push {lr}

	/* Display On/Off and Set Cursor Status */

	and status_display, status_display, #0b111
	orr status_display, status_display, #0b00001000
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4

	mov r0, #equ32_lcd32_time_execution1
	bl arm32_sleep

	lcd32_lcddisplay_common:
		mov r0, #0
		pop {pc}

.unreq status_display


/**
 * function lcd32_lcdentry
 * Initialization for Functions in This Library, Only for Using 5 * 8 Dots Characters
 *
 * Parameters
 * r0: Entry Mode Status
 *   r0 Bit[1]: 0 as Decrement, 1 as Increment
 *   r0 Bit[0]: 0 as No Display Shift, 1 as Display Shift
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdentry
lcd32_lcdentry:
	/* Auto (Local) Variables, but just Aliases */
	status_entry  .req r0

	push {lr}

	/* Set Entry Mode */

	and status_entry, status_entry, #0b11
	orr status_entry, status_entry, #0b00000100
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4

	mov r0, #equ32_lcd32_time_execution1
	bl arm32_sleep

	lcd32_lcdentry_common:
		mov r0, #0
		pop {pc}

.unreq status_entry


/**
 * function lcd32_lcdsearch
 * Search Characters through Shifting Cursor or Display
 *
 * Parameters
 * r0: Search Status
 *   r0 Bit[1]: 0 as Cursor Shift, 1 as Display Shift
 *   r0 Bit[0]: 0 as Shift to Left, 1 as Shift to Right
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdsearch
lcd32_lcdsearch:
	/* Auto (Local) Variables, but just Aliases */
	status_search .req r0

	push {lr}

	/* Set Shift */

	and status_search, status_search, #0b11
	lsl status_search, status_search, #2
	orr status_search, status_search, #0b00010000
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4

	mov r0, #equ32_lcd32_time_execution1
	bl arm32_sleep

	lcd32_lcdsearch_common:
		mov r0, #0
		pop {pc}

.unreq status_search


/**
 * function lcd32_lcdposition
 * Set Display Position
 *
 * Parameters
 * r0: Display Position, i.e., Address for Data Display RAM
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdposition
lcd32_lcdposition:
	/* Auto (Local) Variables, but just Aliases */
	position .req r0

	push {lr}

	/* Set Display Position */

	and position, position, #0b01111111
	orr position, position, #0b10000000
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4

	mov r0, #equ32_lcd32_time_execution1
	bl arm32_sleep

	lcd32_lcdposition_common:
		mov r0, #0
		pop {pc}

.unreq position


/**
 * function lcd32_lcdclear
 * Clear Display, All in DDRAM Become 0x20, Spaces, Address Becomes 0
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdclear
lcd32_lcdclear:
	push {lr}

	/* Clear Display */

	mov r0, #0b00000001
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4

	mov r0, #equ32_lcd32_time_execution2
	bl arm32_sleep

	lcd32_lcdclear_common:
		mov r0, #0
		pop {pc}


/**
 * function lcd32_lcdhome
 * Return to Home Position, Display Data Address Becomes 0
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdhome
lcd32_lcdhome:
	push {lr}

	/* Return Home */

	mov r0, #0b00000010
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4

	mov r0, #equ32_lcd32_time_execution2
	bl arm32_sleep

	lcd32_lcdhome_common:
		mov r0, #0
		pop {pc}


/**
 * function lcd32_lcdstring
 * Display String
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Length of Array of String (Bytes)
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdstring
lcd32_lcdstring:
	/* Auto (Local) Variables, but just Aliases */
	string_point  .req r0
	string_length .req r1
	i             .req r2

	push {lr}

	mov i, #0

	lcd32_lcdstring_loop:
		cmp i, string_length
		bhs lcd32_lcdstring_common

		push {r0-r2}
		ldrb r0, [string_point, i]
		mov r1, #1
		mov r2, #1
		bl lcd32_lcdput4
		pop {r0-r2}

		push {r0-r2}
		mov r0, #equ32_lcd32_time_execution1
		bl arm32_sleep
		pop {r0-r2}

		add i, i, #1

		b lcd32_lcdstring_loop

	lcd32_lcdstring_common:
		mov r0, #0
		pop {pc}

.unreq string_point
.unreq string_length
.unreq i


/**
 * function lcd32_lcdchargenerator
 * Set Address for Character Generator RAM (Switch to Character Generator)
 * If you want to go back for writing display, use lcd32_lcdposition once.
 *
 * Parameters
 * r0: Address for Character Generator RAM
 *
 * Return: r0 (0 as success)
 */
.globl lcd32_lcdchargenerator
lcd32_lcdchargenerator:
	/* Auto (Local) Variables, but just Aliases */
	addr_cgram .req r0

	push {lr}

	/* Set Display addr_cgram */

	and addr_cgram, addr_cgram, #0b00111111
	orr addr_cgram, addr_cgram, #0b01000000
	mov r1, #0
	mov r2, #1
	bl lcd32_lcdput4

	mov r0, #equ32_lcd32_time_execution1
	bl arm32_sleep

	lcd32_lcdchargenerator_common:
		mov r0, #0
		pop {pc}

.unreq addr_cgram

