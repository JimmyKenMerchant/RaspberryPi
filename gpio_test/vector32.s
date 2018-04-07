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

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base

	mvn r1, #0                                       @ Whole Inverter

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                       @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0x7C                             @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
	str r1, [r0, #equ32_armtimer_predivider]

	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	str r1, [r0, #equ32_armtimer_load]

	mov r1, #0x3E0000                         @ High 2 Bytes
	add r1, r1, #0b10100100                   @ Low 2 Bytes (00A4), Timer Enable and Timer Interrupt Enable, Prescaler 1/16 to 120K
	                                          @ 1/16 is #0b10100100, 1/256 is #0b10101000
	str r1, [r0, #equ32_armtimer_control]

	/* So We can get a 12hz Timer Interrupt (120000/10000) */

	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldr r1, [r0, #equ32_gpio_gpfsel00]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2      @ Clear GPIO 2
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_2     @ Set GPIO 2 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_3      @ Clear GPIO 3
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_3     @ Set GPIO 3 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4      @ Clear GPIO 4
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_4     @ Set GPIO 4 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5      @ Clear GPIO 5
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_5     @ Set GPIO 5 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_6      @ Clear GPIO 6
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6     @ Set GPIO 6 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7      @ Clear GPIO 7
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7     @ Set GPIO 7 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_8      @ Clear GPIO 8
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_8     @ Set GPIO 8 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_9      @ Clear GPIO 9
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_9     @ Set GPIO 9 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_0      @ Clear GPIO 10
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_0     @ Set GPIO 10 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1      @ Clear GPIO 11
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_1     @ Set GPIO 11 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2      @ Clear GPIO 12
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_2     @ Set GPIO 12 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_3      @ Clear GPIO 13
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_3     @ Set GPIO 13 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4      @ Clear GPIO 14
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_4     @ Set GPIO 14 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5      @ Clear GPIO 15
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_5     @ Set GPIO 15 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_6      @ Clear GPIO 16
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6     @ Set GPIO 16 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7      @ Clear GPIO 17
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7     @ Set GPIO 17 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_8      @ Clear GPIO 18
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_8     @ Set GPIO 18 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_9      @ Clear GPIO 19
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_9     @ Set GPIO 19 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_0      @ Clear GPIO 20
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_0     @ Set GPIO 20 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1      @ Clear GPIO 21
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_1     @ Set GPIO 21 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2      @ Clear GPIO 22
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_2     @ Set GPIO 22 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_3      @ Clear GPIO 23
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_3     @ Set GPIO 23 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4      @ Clear GPIO 24
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_4     @ Set GPIO 24 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5      @ Clear GPIO 25
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_5     @ Set GPIO 25 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_6      @ Clear GPIO 26
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6     @ Set GPIO 26 OUTPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7      @ Clear GPIO 27
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_7      @ Set GPIO 27 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

.ifndef __RASPI3B
	ldr r1, [r0, #equ32_gpio_gpfsel40]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7      @ Clear GPIO 47
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7     @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]
.endif

	/* Clear All GPIO Status Detect */
	mov r1, #0
	str r1, [r0, #equ32_gpio_gpren0]
	str r1, [r0, #equ32_gpio_gpren1]
	str r1, [r0, #equ32_gpio_gpfen0]
	str r1, [r0, #equ32_gpio_gpfen1]
	str r1, [r0, #equ32_gpio_gphen0]
	str r1, [r0, #equ32_gpio_gphen1]
	str r1, [r0, #equ32_gpio_gplen0]
	str r1, [r0, #equ32_gpio_gplen1]
	str r1, [r0, #equ32_gpio_gparen0]
	str r1, [r0, #equ32_gpio_gparen1]
	str r1, [r0, #equ32_gpio_gpafen0]
	str r1, [r0, #equ32_gpio_gpafen1]

	/* Set Status Detect */
	ldr r1, [r0, #equ32_gpio_gpren0]
	orr r1, r1, #equ32_gpio27                                        @ Set GPIO27 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]

	/* Obtain Framebuffer from VideoCore IV */
	mov r0, #32
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	macro32_clean_cache r1, ip

	push {r0-r3,lr}
	bl bcm32_get_framebuffer
	pop {r0-r3,lr}
	
	mov pc, lr

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r7}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
.endif

	/* Clear Timer Interrupt */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	macro32_dsb ip

.ifndef __RASPI3B
	/* Blinker */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldrb r1, os_fiq_gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	strb r1, os_fiq_gpio_toggle

	tst r1, #0b00000001
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]

	macro32_dsb ip
.endif

	push {r0-r3,lr}
	mov r0, #equ32_gpio32_gpiomask            @ Default
	bic r0, r0, #0x08000000                   @ GPIO27
	bl gpio32_gpioplay
	pop {r0-r3,lr}

	macro32_dsb ip

	pop {r0-r7}
	mov pc, lr

/**
 * Variables
 */
os_fiq_gpio_toggle:       .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\nMAHALO! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello

.include "addr32.s" @ If you want binary, use `.incbin`

/* End of Line is Needed */
