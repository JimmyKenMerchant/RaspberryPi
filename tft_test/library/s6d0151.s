/**
 * s6d0151.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* These Functions are used for the TFT LCD driver, S6D0151. */


/**
 * function s6d0151_write
 * Write to S6D0151 through SPI Interface
 *
 * Parameters
 * r0: Register Index Number
 * r1: Data (2 Bytes)
 *
 * Return: r0 (0 as success)
 */
.globl s6d0151_write
s6d0151_write:
	/* Auto (Local) Variables, but just Aliases */
	index .req r0
	data  .req r1
	temp  .req r2

	push {lr}

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov temp, #0x70<<24               @ Index[1], Write Bit[0]
	orr r0, temp, index, lsl #8       @ Any Index
/*macro32_debug r0, 100, 72*/
	mov r1, #3
	bl spi32_spitx
	bl spi32_spiwaitdone
/*macro32_debug r0, 100, 84*/
	mov r0, #0b10                     @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	/* CS Goes High */
	push {r0-r1}
	bl spi32_spistop
	pop {r0-r1}

	macro32_dsb ip

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov temp, #0x72<<24               @ Data[1], Write Bit[0]
	orr r0, temp, r1, lsl #8          @ Data
/*macro32_debug r0, 100, 96*/
	mov r1, #3
	bl spi32_spitx
	bl spi32_spiwaitdone
/*macro32_debug r0, 100, 108*/
	mov r0, #0b10                     @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	/* CS Goes High */
	bl spi32_spistop

	s6d0151_write_common:
		mov r0, #0
		pop {pc}

.unreq index
.unreq data
.unreq temp


/**
 * function s6d0151_fillcolor
 * Fill One Color to GRAM
 *
 * Parameters
 * r0: 16-bit Color
 * r1: Size to Be Written (Bytes)
 *
 * Return: r0 (0 as success)
 */
.globl s6d0151_fillcolor
s6d0151_fillcolor:
	/* Auto (Local) Variables, but just Aliases */
	data  .req r0
	size  .req r1
	temp  .req r2

	push {lr}

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x70<<24               @ Index[1], Write Bit[0]
	orr r0, r0, #0x22<<8            @ Index 0x22
	mov r1, #3
	bl spi32_spitx
	bl spi32_spiwaitdone
	mov r0, #0b10                   @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	/* CS Goes High */
	push {r0-r1}
	bl spi32_spistop
	pop {r0-r1}

	macro32_dsb ip

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x72<<24               @ Data[1], Write Bit[0]
	mov r1, #1
	bl spi32_spitx
	bl spi32_spiwaitdone
	mov r0, #0b10                   @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	s6d0151_fillcolor_loop:
		sub size, size, #1
		cmp size, #0
		blt s6d0151_fillcolor_jump

		push {r0-r1}
		lsl r0, r0, #16
		mov r1, #2
		bl spi32_spitx
		bl spi32_spiwaitdone
		mov r0, #0b10                   @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
		bl spi32_spiclear
		pop {r0-r1}

		macro32_dsb ip

		b s6d0151_fillcolor_loop

	s6d0151_fillcolor_jump:

		/* CS Goes High */
		bl spi32_spistop

	s6d0151_fillcolor_common:
		mov r0, #0
		pop {pc}

.unreq data
.unreq size
.unreq temp
