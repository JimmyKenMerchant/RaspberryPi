/**
 * usb2032.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function usb2032_otg_start
 * Enable USB2.0 OTG
 *
 * Usage: r0-r1
 * Return: r0 (0 as success, 1 as error)
 * Error(1): When Framebuffer is not Defined
 */
.globl usb2032_otg_start
usb2032_otg_start:
	/* Auto (Local) Variables, but just Aliases */
	memorymap_base    .req r0
	temp              .req r1

	/**
	 * Core USB Configuration has each default setting in SoCs,
	 * e.g. in BCM2836 has 0x20402700.
	 * So in this section, we need to make DMA on, make Core Reset and FIFO Flush,
	 * and make host port power on and reset host port.
	 */

	mov memorymap_base, #equ32_peripherals_base
	add memorymap_base, memorymap_base, #equ32_usb20_otg_base
	ldr temp, [memorymap_base ,#equ32_usb20_otg_gahbcfg]      @ Internal Bus Config (GAHBCFG)

	dsb

	/**
	 * Bit[23] may have DMA Incremental(0) or single (1) in case.
	 * Besides, GAHBCFG of BCM2836 has 0x0000000E in Default.
	 * In this function, DMA is enabled, so DMA Burst Becomes Incremental16
	 */
	orr temp, temp, #0x20                                     @ Enable DMA Bit[5]

	str temp, [memorymap_base ,#equ32_usb20_otg_gahbcfg]

	b usb2032_otg_start_common

	usb2032_otg_start_error:
		mov r0, #1                           @ Return with Error

	usb2032_otg_start_common:
		dsb                                  @ Ensure Completion of Instructions Before
		mov pc, lr

.unreq memorymap_base
.unreq temp
