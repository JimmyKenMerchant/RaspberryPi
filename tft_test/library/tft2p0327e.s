/**
 * tft2p0327e.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Module Name: TFT2P0327-E
 * Type: TFT LCD MODULE
 * Manufacturer: TRULY
 * Description:
 *  The TFT color 1.77 inches LCD module (128x160).
 *  Its driver is S6D0151.
 *  Its backlights are two LEDs in series.
 */

/**
 * function tft2p0327e_init
 * Activation of TFT2P0327-E
 * This function needs to be placed in "vector32.s".
 *
 * Parameters
 * r0: GPIO Number of Output for RESET Pin
 * r1: Color to Display after Initializing
 *
 * Return: r0 (0 as success)
 */
.globl tft2p0327e_init
tft2p0327e_init:
	/* Auto (Local) Variables, but just Aliases */
	num_gpio .req r0
	color    .req r1

	push {lr}

	macro32_dsb ip

	/**
	 * Power Up Procedure
	 */

	/* Wait 1 millisecond */
	push {r0-r1}
	mov r0, #0x400   @ 1024
	bl arm32_sleep
	pop {r0-r1}

	/* RESET High */
	push {r0-r1}
	mov r1, #1
	bl gpio32_gpiotoggle
	pop {r0-r1}

	macro32_dsb ip

	/* Wait 10 milliseconds */
	push {r0-r1}
	mov r0, #0x2740  @ 10048
	bl arm32_sleep
	pop {r0-r1}

	/* RESET Low */
	push {r0-r1}
	mov r1, #0
	bl gpio32_gpiotoggle
	pop {r0-r1}

	macro32_dsb ip

	/* Wait 1 millisecond */
	push {r0-r1}
	mov r0, #0x400   @ 1024
	bl arm32_sleep
	pop {r0-r1}

	/* RESET High */
	push {r0-r1}
	mov r1, #1
	bl gpio32_gpiotoggle
	pop {r0-r1}

	macro32_dsb ip

	/* Wait 50 milliseconds */
	push {r0-r1}
	mov r0, #0xC400  @ 50176
	bl arm32_sleep
	pop {r0-r1}

	/**
	 * Power Controls
	 */

	push {r0-r1}
	mov r0, #0x07
	mov r1, #0x20
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0xB6
	mov r1, #0x3F
	orr r1, r1, #0x0100
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0xB4
	mov r1, #0x10
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x12
	mov r1, #0xB1
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x13
	mov r1, #0x0E
	orr r1, r1, #0x0800
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x14
	mov r1, #0xCA
	orr r1, r1, #0x5B00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x61
	mov r1, #0x18
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x10
	mov r1, #0x0C
	orr r1, r1, #0x1900
	bl tft32_tftwrite_type1
	pop {r0-r1}

	/* Wait 80 milliseconds */
	push {r0-r1}
	mov r0, #0x13C00 @ 80896
	bl arm32_sleep
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x13
	mov r1, #0x1E
	orr r1, r1, #0x0800
	bl tft32_tftwrite_type1
	pop {r0-r1}

	/* Wait 20 milliseconds */
	push {r0-r1}
	mov r0, #0x4F00  @ 20224
	bl arm32_sleep
	pop {r0-r1}

	/**
	 * Output Controls, Display Size, etc.
	 */

	push {r0-r1}
	mov r0, #0x01
	mov r1, #0x14
	orr r1, r1, #0x0000           @ 0x0314 If Change Top and Bottom
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x02
	mov r1, #0x00
	orr r1, r1, #0x0100
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x03
	mov r1, #0x30
	orr r1, r1, #0x0000
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x08
	mov r1, #0x02
	orr r1, r1, #0x0200
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x0B
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x0C
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x61
	mov r1, #0x18
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x69
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x70
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x71
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x11
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	/**
	 * Gamma Controls
	 */

	push {r0-r1}
	mov r0, #0x30
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x31
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x32
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x33
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x34
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x35
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x36
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x37
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x38
	mov r1, #0x07
	orr r1, r1, #0x0700
	bl tft32_tftwrite_type1
	pop {r0-r1}

	/**
	 * Display Settings, Coordinates, etc.
	 */

	push {r0-r1}
	mov r0, #0x40
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x42
	mov r1, #0x00
	orr r1, r1, #0x9F00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x43
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x44
	mov r1, #0x00
	orr r1, r1, #0x7F00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x45
	mov r1, #0x00
	orr r1, r1, #0x9F00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x69
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x70
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x71
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x73
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0xB3
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0xBD
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0xBE
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	/**
	 * Set GRAM Start Address
	 */

	push {r0-r1}
	mov r0, #0x21                 @ Index 0x21 Start Address
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0-r1}

	/* Clear by One Color before Display On */
	push {r0-r1}
	mov r0, color
	mov r1, #0x5000               @ 138 x 160
	bl tft32_tftfillcolor_type1
	pop {r0-r1}

	/* Wait 20 milliseconds */
	push {r0-r1}
	mov r0, #0x4F00  @ 20224
	bl arm32_sleep
	pop {r0-r1}

	tft2p0327e_init_common:
		mov r0, #0
		pop {pc}

.unreq num_gpio
.unreq color


/**
 * function tft2p0327e_displayon
 * Turn On Dipslay of TFT2P0327-E
 * This function needs to be placed in "vector32.s".
 *
 * Return: r0 (0 as success)
 */
.globl tft2p0327e_displayon
tft2p0327e_displayon:
	push {lr}

	/**
	 * Display ON
	 */

	mov r0, #0x07
	mov r1, #0x20
	bl tft32_tftwrite_type1

	/* Wait 5 milliseconds */
	mov r0, #0x1400  @ 5120
	bl arm32_sleep

	mov r0, #0x07
	mov r1, #0x21
	bl tft32_tftwrite_type1

	mov r0, #0x07
	mov r1, #0x27
	bl tft32_tftwrite_type1

	/* Wait 50 milliseconds, More Than 2 Frames */
	mov r0, #0xC400  @ 50176
	bl arm32_sleep

	mov r0, #0x07
	mov r1, #0x37
	bl tft32_tftwrite_type1

	tft2p0327e_displayon_common:
		mov r0, #0
		pop {pc}


/**
 * function tft2p0327e_displayoff
 * Turn Off Dipslay of TFT2P0327-E
 * This function needs to be placed in "vector32.s".
 *
 * Return: r0 (0 as success)
 */
.globl tft2p0327e_displayoff
tft2p0327e_displayoff:
	push {lr}

	/**
	 * Display Off
	 */

	mov r0, #0x07
	mov r1, #0x36
	bl tft32_tftwrite_type1

	/* Wait 50 milliseconds, More Than 2 Frames */
	mov r0, #0xC400  @ 50176
	bl arm32_sleep

	mov r0, #0x07
	mov r1, #0x26
	bl tft32_tftwrite_type1

	/* Wait 5 milliseconds */
	mov r0, #0x1400  @ 5120
	bl arm32_sleep

	mov r0, #0x07
	mov r1, #0x00
	bl tft32_tftwrite_type1

	tft2p0327e_displayoff_common:
		mov r0, #0
		pop {pc}


/**
 * function tft2p0327e_poweroff
 * Procedure before Power Off of TFT2P0327-E
 * This function needs to be placed in "vector32.s".
 * This function needs to be placed after tft2p0327e_displayoff
 *
 * Parameters
 * r0: GPIO Number of Output for RESET Pin
 *
 * Return: r0 (0 as success)
 */
.globl tft2p0327e_poweroff
tft2p0327e_poweroff:
	/* Auto (Local) Variables, but just Aliases */
	num_gpio .req r0

	push {lr}

	/* Wait 50 milliseconds, More Than 2 Frames */
	push {r0}
	mov r0, #0xC400  @ 50176
	bl arm32_sleep
	pop {r0}

	/**
	 * Power Off
	 */

	push {r0}
	mov r0, #0x10
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0}

	push {r0}
	mov r0, #0x13
	mov r1, #0x00
	bl tft32_tftwrite_type1
	pop {r0}

	/* RESET Low */
	push {r0}
	mov r1, #0
	bl gpio32_gpiotoggle
	pop {r0}

	/* Wait 1 millisecond */
	push {r0}
	mov r0, #0x400   @ 1024
	bl arm32_sleep
	pop {r0}

	tft2p0327e_poweroff_common:
		mov r0, #0
		pop {pc}

.unreq num_gpio
