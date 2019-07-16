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

	/**
	 * Clock Set
	 */

	mov r0, #25                               @ 240Mhz/25, 9.6Mhz
	bl spi32_spiclk

	mov r0, #25                               @ GPIO Number of Output for RESET Pin
	mov r1, #0x0000                           @ Color to Dipslay after Initializing
	bl tft2p0327e_init
	bl tft2p0327e_displayon

	mov r0, #0x200000
	bl arm32_sleep

	bl tft2p0327e_displayoff

	mov r0, #0x200000
	bl arm32_sleep

	bl tft2p0327e_displayon

	pop {pc}

os_debug:
	push {lr}
	pop {pc}

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

/* Additional Libraries Here */
.section	.text
.include "library/tft2p0327e.s"

/* End of Line is Needed */
