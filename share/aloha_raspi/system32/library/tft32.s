/**
 * tft32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * These functions are used for communication with TFT LCD drivers through SPI interface.
 * Many TFT LCD drivers can use parallel interfaces, 6800-series CPU bus and 8080-series CPU bus.
 * Several TFT LCD drivers also can use SPI Interface, one of serial interfaces.
 * The serial interface is slower than parallels, however it gives us easy implementation through the SPI controller in your SoC.
 * Several OLED drivers are similar to TFT LCD drivers in view of SPI Interface,
 * so I think these functions are valuable as general purpose ones.
 * In my research, maximum clock speed for SPI interfaces is 10 Mhz to 20 Mhz. However it depends on each driver.
 *
 * TFT LCD drivers have various products. I set these types to make generic functions.
 * LoSSI is Low Speed Serial Interface, a sort of 3-wire SPI. It distinguishes between a command and a data by an additional bit.
 * Type 1 and 3 needs to transmit the start byte to distinguish between a command and a data
 * through an inverted Index Register Set bit.
 * The start byte also includes an inverted Read/Write bit.
 *
 * Type 1: Index, Standard 4-wire SPI, 16-bit Registers, GRAM Write 0x22
 *  Tested: S6D0151
 *  Logically Compatible: ILI9320, ILI9325, ILI9328, S6D0128
 *  Related: HX8347-D [Bidirectional 3-wire SPI, 8-bit Registers]
 *
 * Type 2: Command, LoSSI, Sequential 8-bit Registers (Data/Command Bit is Added to Every 8-bit Register), GRAM Write 0x2C
 *  Tested: Not Yet
 *  Logically Compatible: ILI9341, ILI9341V, ST7735S, SSD1355 (OLED Driver)
 *  Related: SSD1351 (OLED Driver) [GRAM Write 0x5C]
 *
 * These functions use 16-bit 65k color (R:G:B = 5:6:5), so one pixel equals a 16-bit half word.
 */


/**
 * function tft32_tftwrite_type1
 * Write to S6D0151 through SPI Interface
 * Device ID (set by an external pin) assumes as 0 in default. Device ID is the third bit of the start byte, from LSB.
 * CS of SPI assumes as No. 0 in default.
 *
 * Parameters
 * r0: Register Index Number
 * r1: Data (16-bit = 2 Bytes)
 *
 * Return: r0 (0 as success)
 */
.globl tft32_tftwrite_type1
tft32_tftwrite_type1:
	/* Auto (Local) Variables, but just Aliases */
	index .req r0
	data  .req r1
	temp  .req r2

	push {lr}

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear|equ32_tft32_cs<<equ32_spi0_cs_cs
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov temp, #0x70|equ32_tft32_deviceid<<2 @ Device ID[2], Index[1], Write Bit[0]
	lsl temp, temp, #24
	orr r0, temp, index, lsl #8             @ Any Index
/*macro32_debug r0, 100, 72*/
	mov r1, #3
	bl spi32_spitx
	bl spi32_spiwaitdone
/*macro32_debug r0, 100, 84*/
	mov r0, #0b10                           @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	/* CS Goes High */
	push {r0-r1}
	bl spi32_spistop
	pop {r0-r1}

	macro32_dsb ip

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear|equ32_tft32_cs<<equ32_spi0_cs_cs
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov temp, #0x72|equ32_tft32_deviceid<<2 @ Device ID[2], Data[1], Write Bit[0]
	lsl temp, temp, #24
	orr r0, temp, data, lsl #8              @ Data
/*macro32_debug r0, 100, 96*/
	mov r1, #3
	bl spi32_spitx
	bl spi32_spiwaitdone
/*macro32_debug r0, 100, 108*/
	mov r0, #0b10                           @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	/* CS Goes High */
	bl spi32_spistop

	tft32_tftwrite_type1_common:
		mov r0, #0
		pop {pc}

.unreq index
.unreq data
.unreq temp


/**
 * function tft32_tftfillcolor_type1
 * Fill One Color to GRAM
 * Device ID (set by an external pin) assumes as 0 in default. Device ID is the third bit of the start byte, from LSB.
 * CS of SPI assumes as No. 0 in default.
 *
 * Parameters
 * r0: 16-bit Color
 * r1: Size to Be Written (16-bit Half Words)
 *
 * Return: r0 (0 as success)
 */
.globl tft32_tftfillcolor_type1
tft32_tftfillcolor_type1:
	/* Auto (Local) Variables, but just Aliases */
	data  .req r0
	size  .req r1

	push {lr}

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear|equ32_tft32_cs<<equ32_spi0_cs_cs
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x70|equ32_tft32_deviceid<<2   @ Device ID[2], Index[1], Write Bit[0]
	lsl r0, r0, #24
	orr r0, r0, #0x0022<<8                  @ Index 0x22
	mov r1, #3
	bl spi32_spitx
	bl spi32_spiwaitdone
	mov r0, #0b10                           @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	/* CS Goes High */
	push {r0-r1}
	bl spi32_spistop
	pop {r0-r1}

	macro32_dsb ip

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear|equ32_tft32_cs<<equ32_spi0_cs_cs
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x72|equ32_tft32_deviceid<<2   @ Device ID[2], Data[1], Write Bit[0]
	lsl r0, r0, #24
	mov r1, #1
	bl spi32_spitx
	bl spi32_spiwaitdone
	mov r0, #0b10                           @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	tft32_tftfillcolor_type1_loop:
		subs size, size, #1
		blo tft32_tftfillcolor_type1_jump

		push {r0-r1}
		lsl r0, r0, #16
		mov r1, #2
		bl spi32_spitx
		bl spi32_spiwaitdone
		mov r0, #0b10                       @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
		bl spi32_spiclear
		pop {r0-r1}

		macro32_dsb ip

		b tft32_tftfillcolor_type1_loop

	tft32_tftfillcolor_type1_jump:

		/* CS Goes High */
		bl spi32_spistop

	tft32_tftfillcolor_type1_common:
		mov r0, #0
		pop {pc}

.unreq data
.unreq size


/**
 * function tft32_tftimage_type1
 * Image Data to GRAM
 * Device ID (set by an external pin) assumes as 0 in default. Device ID is the third bit of the start byte, from LSB.
 * CS of SPI assumes as No. 0 in default.
 *
 * Parameters
 * r0: Pointer of Image in 16-bit (2 Bytes) Color
 * r1: Size to Be Written (16-bit Half Words)
 *
 * Return: r0 (0 as success)
 */
.globl tft32_tftimage_type1
tft32_tftimage_type1:
	/* Auto (Local) Variables, but just Aliases */
	image_point .req r0
	size        .req r1

	push {lr}

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear|equ32_tft32_cs<<equ32_spi0_cs_cs
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x70|equ32_tft32_deviceid<<2   @ Device ID[2], Index[1], Write Bit[0]
	lsl r0, r0, #24
	orr r0, r0, #0x0022<<8                  @ Index 0x22
	mov r1, #3
	bl spi32_spitx
	bl spi32_spiwaitdone
	mov r0, #0b10                           @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	/* CS Goes High */
	push {r0-r1}
	bl spi32_spistop
	pop {r0-r1}

	macro32_dsb ip

	/* CS Goes Low */
	push {r0-r1}
	mov r0, #0b11<<equ32_spi0_cs_clear|equ32_tft32_cs<<equ32_spi0_cs_cs
	bl spi32_spistart
	pop {r0-r1}

	push {r0-r1}
	mov r0, #0x72|equ32_tft32_deviceid<<2   @ Device ID[2], Data[1], Write Bit[0]
	lsl r0, r0, #24
	mov r1, #1
	bl spi32_spitx
	bl spi32_spiwaitdone
	mov r0, #0b10                           @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
	bl spi32_spiclear
	pop {r0-r1}

	tft32_tftimage_type1_loop:
		subs size, size, #1
		blo tft32_tftimage_type1_jump

		push {r0-r1}
		ldrh r0, [image_point]
		lsl r0, r0, #16
		mov r1, #2
		bl spi32_spitx
		bl spi32_spiwaitdone
		mov r0, #0b10                       @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
		bl spi32_spiclear
		pop {r0-r1}

		add image_point, image_point, #2

		macro32_dsb ip

		b tft32_tftimage_type1_loop

	tft32_tftimage_type1_jump:

		/* CS Goes High */
		bl spi32_spistop

	tft32_tftimage_type1_common:
		mov r0, #0
		pop {pc}

.unreq image_point
.unreq size

