/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Define Debug Status */
/*.equ __DEBUG, 1*/

/* If You Want External Synchronization Clock */
/*.equ __NOSYNCCLOCK, 1*/

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

.ifndef __NOSYNCCLOCK
	mov r1, #0b11000000                              @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	/**
	 * Timer
	 */

	/* Get a 2000hz Timer Interrupt (240000/120) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x0000                           @ High 1 Byte of decimal 119 (120 - 1), 16 bits counter on default
	orr r1, r1, #0x77                         @ Low 1 Byte of decimal 119, 16 bits counter on default
	mov r2, #0x3E0                            @ Decimal 999 to divide 240Mz by 1000 to 240Khz (Predivider is 10 Bits Wide)
	orr r2, r2, #0x007                        @ Decimal 999 to divide 240Mz by 1000 to 240Khz (Predivider is 10 Bits Wide)
	bl arm32_armtimer
.endif

	/**
	 * GPIO
	 */

	/* GPIO0-45 Reset and Pull Down */
	bl gpio32_gpioreset

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	/* I/O Settings */
	ldr r1, [r0, #equ32_gpio_gpfsel00]
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_2   @ Set GPIO 2 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_3   @ Set GPIO 3 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_4   @ Set GPIO 4 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_5   @ Set GPIO 5 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6   @ Set GPIO 6 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 7 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_8   @ Set GPIO 8 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_9   @ Set GPIO 9 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_0   @ Set GPIO 10 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_1   @ Set GPIO 11 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_2   @ Set GPIO 12 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_3   @ Set GPIO 13 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_4   @ Set GPIO 14 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_5   @ Set GPIO 15 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6   @ Set GPIO 16 OUTPUT
.ifdef __NOSYNCCLOCK
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_7    @ Set GPIO 17 INPUT
.else
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 17 OUTPUT
.endif
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_8   @ Set GPIO 18 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_9   @ Set GPIO 19 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_0   @ Set GPIO 20 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_1   @ Set GPIO 21 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_2    @ Set GPIO 22 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_3    @ Set GPIO 23 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_4    @ Set GPIO 24 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_5    @ Set GPIO 25 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_6    @ Set GPIO 26 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	/* Set Status Detect */
	ldr r1, [r0, #equ32_gpio_gpren0]
	orr r1, r1, #equ32_gpio17                                      @ Set GPIO17 Rising Edge Detect
	orr r1, r1, #equ32_gpio22                                      @ Set GPIO22 Rising Edge Detect
	orr r1, r1, #equ32_gpio23                                      @ Set GPIO23 Rising Edge Detect
	orr r1, r1, #equ32_gpio24                                      @ Set GPIO24 Rising Edge Detect
	orr r1, r1, #equ32_gpio25                                      @ Set GPIO25 Rising Edge Detect
	orr r1, r1, #equ32_gpio26                                      @ Set GPIO26 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]

	macro32_dsb ip
	
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

/* End of Line is Needed */
