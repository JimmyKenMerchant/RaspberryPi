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
 *
 * Return: r0 (0 as success)
 */
.globl tft2p0327e_init
tft2p0327e_init:

	push {lr}

	/* Power Up Procedure */

	mov r0, #1000
	bl arm32_sleep

	mov r0, #25
	mov r1, #1
	bl gpio32_gpiotoggle

	macro32_dsb ip

	mov r0, #0x2740 @ 10048
	bl arm32_sleep

	mov r0, #25
	mov r1, #0
	bl gpio32_gpiotoggle

	macro32_dsb ip

	mov r0, #1000
	bl arm32_sleep

	mov r0, #25
	mov r1, #1
	bl gpio32_gpiotoggle

	macro32_dsb ip

	mov r0, #0x2740 @ 10048
	bl arm32_sleep

	/**
	 * Power Controls
	 */

	mov r0, #0x07
	mov r1, #0x20
	bl s6d0151_write

	mov r0, #0xB6
	mov r1, #0x3F
	orr r1, r1, #0x0100
	bl s6d0151_write

	mov r0, #0xB4
	mov r1, #0x10
	bl s6d0151_write

	mov r0, #0x12
	mov r1, #0xB1
	bl s6d0151_write

	mov r0, #0x13
	mov r1, #0x0E
	orr r1, r1, #0x0800
	bl s6d0151_write

	mov r0, #0x14
	mov r1, #0xCA
	orr r1, r1, #0x5B00
	bl s6d0151_write

	mov r0, #0x61
	mov r1, #0x18
	bl s6d0151_write

	mov r0, #0x10
	mov r1, #0x0C
	orr r1, r1, #0x1900
	bl s6d0151_write

	/* Wait 80 milliseconds */
	mov r0, #0x13C00 @ 80896
	bl arm32_sleep

	mov r0, #0x13
	mov r1, #0x1E
	orr r1, r1, #0x0800
	bl s6d0151_write

	/* Wait 20 milliseconds */
	mov r0, #0x4F00  @ 20224
	bl arm32_sleep

	/**
	 * Output Controls, Display Size, etc.
	 */

	mov r0, #0x01
	mov r1, #0x14
	orr r1, r1, #0x0000           @ 0x0314 If Change Top and Bottom
	bl s6d0151_write

	mov r0, #0x02
	mov r1, #0x00
	orr r1, r1, #0x0100
	bl s6d0151_write

	mov r0, #0x03
	mov r1, #0x30
	orr r1, r1, #0x0000
	bl s6d0151_write

	mov r0, #0x08
	mov r1, #0x02
	orr r1, r1, #0x0200
	bl s6d0151_write

	mov r0, #0x0B
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x0C
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x61
	mov r1, #0x18
	bl s6d0151_write

	mov r0, #0x69
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x70
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x71
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x11
	mov r1, #0x00
	bl s6d0151_write

	/**
	 * Gamma Controls
	 */

	mov r0, #0x30
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl s6d0151_write

	mov r0, #0x31
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl s6d0151_write

	mov r0, #0x32
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl s6d0151_write

	mov r0, #0x33
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x34
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl s6d0151_write

	mov r0, #0x35
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl s6d0151_write

	mov r0, #0x36
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl s6d0151_write

	mov r0, #0x37
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x38
	mov r1, #0x07
	orr r1, r1, #0x0700
	bl s6d0151_write

	/**
	 * Display Settings, Coordinates, etc.
	 */

	mov r0, #0x40
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x42
	mov r1, #0x00
	orr r1, r1, #0x9F00
	bl s6d0151_write

	mov r0, #0x43
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x44
	mov r1, #0x00
	orr r1, r1, #0x7F00
	bl s6d0151_write

	mov r0, #0x45
	mov r1, #0x00
	orr r1, r1, #0x9F00
	bl s6d0151_write

	mov r0, #0x69
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x70
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x71
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0x73
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0xB3
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0xBD
	mov r1, #0x00
	bl s6d0151_write

	mov r0, #0xBE
	mov r1, #0x00
	bl s6d0151_write

	/**
	 * Set GRAM Start Address
	 */

	mov r0, #0x21                 @ Index 0x21 Start Address
	mov r1, #0x00
	bl s6d0151_write

	/* Clear by One Color before Display On */
	mov r0, #0xE0
	orr r0, r0, #0xFF00
	mov r1, #0x5000
	bl s6d0151_fillcolor

	/* Wait 20 milliseconds */
	mov r0, #0x4F00  @ 20224
	bl arm32_sleep

	/**
	 * Display ON
	 */

	mov r0, #0x07
	mov r1, #0x20
	bl s6d0151_write

	/* Wait 5 milliseconds */
	mov r0, #0x1400  @ 5120
	bl arm32_sleep

	mov r0, #0x07
	mov r1, #0x21
	bl s6d0151_write

	mov r0, #0x07
	mov r1, #0x27
	bl s6d0151_write

	/* Wait 50 milliseconds */
	mov r0, #0xC400  @ 50176
	bl arm32_sleep

	mov r0, #0x07
	mov r1, #0x37
	bl s6d0151_write

	tft2p0327e_init_common:
		mov r0, #0
		pop {pc}
