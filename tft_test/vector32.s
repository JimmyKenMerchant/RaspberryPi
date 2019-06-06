/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Define Debug Status */
.equ __DEBUG, 1

.include "system32/equ32.s"
.include "system32/macro32.s"

.ifdef __ARMV6
	.include "vector32/el01_armv6.s"
	.include "vector32/el3_armv6.s"
.else
	.include "vector32/el01_armv7.s"
	.include "vector32/el2_armv7.s"
	.include "vector32/el3_armv7.s"
.endif

.include "vector32/os.s"

os_reset:
	push {lr}

	/**
	 * Video
	 */

.ifdef __DEBUG
	/* Obtain Framebuffer from VideoCore IV */
	bl bcm32_get_framebuffer
.else
	mov r0, #1
	bl bcm32_display_off
.endif

	/**
	 * Interrupt
	 */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base

	mvn r1, #0                                       @ Whole Inverter
	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                              @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	/**
	 * Timer
	 */

	/* Get a 50hz Timer Interrupt (240000/4800) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x1200                           @ High 1 Byte of decimal 4799 (4800 - 1), 16 bits counter on default
	orr r1, r1, #0xBF                         @ Low 1 Byte of decimal 4799, 16 bits counter on default
	mov r2, #0x3E0                            @ Decimal 999 to divide 240Mz by 1000 to 240Khz (Predivider is 10 Bits Wide)
	orr r2, r2, #0x007                        @ Decimal 999 to divide 240Mz by 1000 to 240Khz (Predivider is 10 Bits Wide)
	bl arm32_armtimer

	/**
	 * GPIO
	 */

	/* GPIO0-45 Reset and Pull Down */
	bl gpio32_gpioreset

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

.ifndef __RASPI3B
	/* USB Current Up */
	ldr r1, [r0, #equ32_gpio_gpfsel30]
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_8   @ Set GPIO 38 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel30]

	macro32_dsb ip

	/* Set USB Current Up (RasPi3 has already as default) */
	mov r1, #equ32_gpio38
	str r1, [r0, #equ32_gpio_gpset1]                               @ GPIO 38 OUTPUT High
.endif

	/* I/O Settings */
	ldr r1, [r0, #equ32_gpio_gpfsel00]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_7       @ Set GPIO 7 ALT 0
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_8       @ Set GPIO 8 ALT 0
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_9       @ Set GPIO 9 ALT 0
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_0       @ Set GPIO 10 ALT 0
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_1       @ Set GPIO 11 ALT 0
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_5     @ Set GPIO 25 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	macro32_dsb ip

	mov r0, #25                       @ 240Mhz/25, 9.6Mhz
	bl spi32_spiclk

	macro32_dsb ip

	pop {pc}

os_debug:
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
	bl os_debug_write

	mov r0, #0xB6
	mov r1, #0x3F
	orr r1, r1, #0x0100
	bl os_debug_write

	mov r0, #0xB4
	mov r1, #0x10
	bl os_debug_write

	mov r0, #0x12
	mov r1, #0xB1
	bl os_debug_write

	mov r0, #0x13
	mov r1, #0x0E
	orr r1, r1, #0x0800
	bl os_debug_write

	mov r0, #0x14
	mov r1, #0xCA
	orr r1, r1, #0x5B00
	bl os_debug_write

	mov r0, #0x61
	mov r1, #0x18
	bl os_debug_write

	mov r0, #0x10
	mov r1, #0x0C
	orr r1, r1, #0x1900
	bl os_debug_write

	/* Wait 80 milliseconds */
	mov r0, #0x13C00 @ 80896
	bl arm32_sleep

	mov r0, #0x13
	mov r1, #0x1E
	orr r1, r1, #0x0800
	bl os_debug_write

	/* Wait 20 milliseconds */
	mov r0, #0x4F00  @ 20224
	bl arm32_sleep

	/**
	 * Output Controls, Display Size, etc.
	 */

	mov r0, #0x01
	mov r1, #0x14
	orr r1, r1, #0x0000           @ 0x0314 If Change Top and Bottom
	bl os_debug_write

	mov r0, #0x02
	mov r1, #0x00
	orr r1, r1, #0x0100
	bl os_debug_write

	mov r0, #0x03
	mov r1, #0x30
	orr r1, r1, #0x0000
	bl os_debug_write

	mov r0, #0x08
	mov r1, #0x02
	orr r1, r1, #0x0200
	bl os_debug_write

	mov r0, #0x0B
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x0C
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x61
	mov r1, #0x18
	bl os_debug_write

	mov r0, #0x69
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x70
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x71
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x11
	mov r1, #0x00
	bl os_debug_write

	/**
	 * Gamma Controls
	 */

	mov r0, #0x30
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl os_debug_write

	mov r0, #0x31
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl os_debug_write

	mov r0, #0x32
	mov r1, #0x03
	orr r1, r1, #0x0300
	bl os_debug_write

	mov r0, #0x33
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x34
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl os_debug_write

	mov r0, #0x35
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl os_debug_write

	mov r0, #0x36
	mov r1, #0x04
	orr r1, r1, #0x0400
	bl os_debug_write

	mov r0, #0x37
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x38
	mov r1, #0x07
	orr r1, r1, #0x0700
	bl os_debug_write

	/**
	 * Display Settings, Coordinates, etc.
	 */

	mov r0, #0x40
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x42
	mov r1, #0x00
	orr r1, r1, #0x9F00
	bl os_debug_write

	mov r0, #0x43
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x44
	mov r1, #0x00
	orr r1, r1, #0x7F00
	bl os_debug_write

	mov r0, #0x45
	mov r1, #0x00
	orr r1, r1, #0x9F00
	bl os_debug_write

	mov r0, #0x69
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x70
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x71
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0x73
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0xB3
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0xBD
	mov r1, #0x00
	bl os_debug_write

	mov r0, #0xBE
	mov r1, #0x00
	bl os_debug_write

	/**
	 * Set GRAM Start Address
	 */

	mov r0, #0x21                 @ Index 0x21 Start Address
	mov r1, #0x00
	bl os_debug_write

	/* Clear by One Color before Display On */

	/* Wait 20 milliseconds */
	mov r0, #0x4F00  @ 20224
	bl arm32_sleep

	/**
	 * Display ON
	 */

	mov r0, #0x07
	mov r1, #0x20
	bl os_debug_write

	/* Wait 5 milliseconds */
	mov r0, #0x1400  @ 5120
	bl arm32_sleep

	mov r0, #0x07
	mov r1, #0x21
	bl os_debug_write

	mov r0, #0x07
	mov r1, #0x27
	bl os_debug_write

	/* Wait 50 milliseconds */
	mov r0, #0xC400  @ 50176
	bl arm32_sleep

	mov r0, #0x07
	mov r1, #0x37
	bl os_debug_write

	mov r0, #0xE0
	orr r0, r0, #0xFF00
	mov r1, #0x5000
	bl os_debug_gram

	pop {pc}

os_debug_write:
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

	os_debug_write_common:
		mov r0, #0
		pop {pc}

.unreq index
.unreq data
.unreq temp


os_debug_gram:
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

	os_debug_gram_loop:
		sub size, size, #1
		cmp size, #0
		blt os_debug_gram_jump

		push {r0-r1}
		lsl r0, r0, #16
		mov r1, #2
		bl spi32_spitx
		bl spi32_spiwaitdone
		mov r0, #0b10                   @ Clear RxFIFO, Dummy Bytes Are Stacked through Transmission
		bl spi32_spiclear
		pop {r0-r1}

		macro32_dsb ip

		b os_debug_gram_loop

	os_debug_gram_jump:

		/* CS Goes High */
		bl spi32_spistop

	os_debug_gram_common:
		mov r0, #0
		pop {pc}

.unreq data
.unreq size
.unreq temp

os_irq:
	push {r0-r12,lr}
	pop {r0-r12,pc}

os_fiq:
	push {r0-r7,lr}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	/* Clear Timer Interrupt */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base
	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge
	macro32_dsb ip

.ifdef __DEBUG
.ifndef __RASPI3B
	/* ACT Blinker */
	mov r0, #47
	mov r1, #2
	bl gpio32_gpiotoggle
	macro32_dsb ip
.endif
.endif

	mov r0, #17
	mov r1, #2
	bl gpio32_gpiotoggle
	macro32_dsb ip

	pop {r0-r7,pc}

/**
 * Variables
 */
.balign 4
_string_hello:
	.ascii "\nALOHA! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello

.include "addr32.s" @ If you want binary, use `.incbin`

/* End of Line is Needed */
