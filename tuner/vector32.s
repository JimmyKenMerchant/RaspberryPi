/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

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

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base

	mvn r1, #0                                       @ Whole Inverter

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                       @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	/**
	 * Get a 25Khz Timer Interrupt (100000/4).
	 */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_16 @ Prescaler 1/16 to 100K
	mov r1, #0x0000                           @ High 1 Byte of decimal 3 (4 - 1), 16 bits counter on default
	add r1, r1, #0x03                         @ Low 1 Byte of decimal 3, 16 bits counter on default
	mov r2, #0x95                             @ Decimal 149 to divide 240Mz by 150 to 1.6Mhz (Predivider is 10 Bits Wide)
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

	/* Obtain Framebuffer from VideoCore IV */

	mov r0, #32
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	macro32_clean_cache r1, ip

	push {r0-r3}
	bl bcm32_get_framebuffer
	pop {r0-r3}

	push {r0-r3}
	mov r0, #100                      @ 240Mhz/100, 2.4Mhz
	bl spi32_spiclk
	pop {r0-r3}

	pop {pc}

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

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

.ifndef __RASPI3B
	/* ACT Blinker */
	mov r0, #47
	mov r1, #2
	bl gpio32_gpiotoggle
	macro32_dsb ip
.endif

	bl tuner_fiqhandler

	macro32_dsb ip

	pop {r0-r7,pc}

/**
 * Handler to Use in FIQ
 */
tuner_fiqhandler:
	current         .req r4
	count           .req r6

	push {r4-r6,lr}

	/**
	 * Get Data from MCP3002 AD Converter
	 * if you don't know completion of transfeering, use spi32_spidone.
	 * In this case, there is fixed delayed time between spitx and spirx, thus you don't need spi32_spidone.
	 */
	mov r0, #4
	bl spi32_spirx                        @ Return Data to r0
	mov current, r0

	/* CS Goes High */
	bl spi32_spistop

	lsr current, current, #16             @ Get Only Higher 16-bit
	
	ldr count, tuner_fiqhandler_count

	macro32_dsb ip

	add count, count, #1
	cmp count, #2
	blo tuner_fiqhandler_common @ If Not Reaches Value of X Division, Jump to Common

	mov count, #0

macro32_debug current, 200, 200

	tuner_fiqhandler_common:
		str count, tuner_fiqhandler_count

		/* CS Goes Low */
		mov r0, #0b11<<equ32_spi0_cs_clear
		bl spi32_spistart

		/* Command to MCP3002 AD Converter */
		mov r0, #0b01100000<<24       @ Significant 4 Bits Are for Command, Least 4 Bits are for Dummy To Receive
		mov r1, #2                    @ Dummy Byte Seems to Be Needed (1 Byte after Comannd, Total 12 Bits are Dummy)
		bl spi32_spitx

		pop {r4-r6,pc}

.unreq current
.unreq count

tuner_fiqhandler_count: .word 0x00


/**
 * Variables
 */
.balign 4
_string_hello:
	.ascii "\nAloha! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello
os_fiq_gpio_toggle: .byte 0b00000000
.balign 4

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
