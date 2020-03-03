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
	 * Get Approx. 22731.578Hz (43.99 Micro Seconds) Timer Interrupt
	 */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_1|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x1400                           @ High 1 Byte of decimal 5278 (5279 - 1), 16 bits counter on default
	add r1, r1, #0x9E                         @ Low 1 Byte of decimal 5278, 16 bits counter on default
	mov r2, #0x01                             @ Decimal 1 to divide 240Mz by 2 to 120Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer

	/**
	 * GPIO
	 */

	/* GPIO0-45 Reset and Pull Down */
	bl gpio32_gpioreset

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	/* I/O Settings */

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2     @ Set GPIO 12 PWM0
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_3     @ Set GPIO 13 PWM1
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 15 ALT 0 as RXD0
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_9    @ Set GPIO 19 INPUT
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_0    @ Set GPIO 20 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_1    @ Set GPIO 21 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_2    @ Set GPIO 22 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_3    @ Set GPIO 23 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_4    @ Set GPIO 24 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_5    @ Set GPIO 25 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_6    @ Set GPIO 26 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_7    @ Set GPIO 27 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	/* Set Status Detect */

	macro32_dsb ip

	/* Check DMX512 Channel, GPIO19 (Bit[0]) to GPIO27 (Bit[8]) */
	ldr r1, [r0, #equ32_gpio_gplev0]
	lsr r1, r1, #19
	mov r2, #0x0FF
	orr r2, r2, #0x100
	and r1, r1, r2                                                 @ 0-511
	str r1, OS_RESET_DMX512_CHANNEL

	/* DMX512 Receive */
	mov r0, #1                                                     @ Start Code
	add r0, r0, #512                                               @ Channel Length
	bl dmx32_dmx512doublebuffer_init

	/* UART Receive 250000 Baud */
	mov r0, #1                                                     @ Integer Divisor Bit[15:0], 7500000 / (16 * 250000) is 1.875
	mov r1, #0b111000                                              @ Fractional Divisor Bit[5:0], Fixed Point Float 0.875
	mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen|equ32_uart0_lcrh_stp2 @ Line Control
	mov r3, #equ32_uart0_cr_rxe                                    @ Control
	bl uart32_uartinit

	/**
	 * Clock Manager for PWM.
	 */
	mov r0, #equ32_cm_pwm
	mov r1, #equ32_cm_ctl_mash_0
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc            @ 19.2Mhz
	mov r2, #3 << equ32_cm_div_integer                             @ For 6400Khz
	bl arm32_clockmanager

	/**
	 * PWM Initializer, 256 Steps (0 - 255)
	 */
	mov r0, #1                                                     @ Fixed Frequency
	mov r1, #255                                                   @ Range of PWM0 for Approx. 25.1Khz
	mov r2, #255                                                   @ Range of PWM1 for Approx. 25.1Khz
	bl pwm32_pwminit

	macro32_dsb ip

	pop {pc}

.globl OS_RESET_DMX512_CHANNEL
OS_RESET_DMX512_CHANNEL: .word 0x00                                    @ DMX512 Channel

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

	bl dmx32_dmx512doublebuffer_rx

	cmp r0, #-1                                                    @ Break
	ldr r1, OS_FIQ_COUNT
	addeq r1, r1, #1
	str r1, OS_FIQ_COUNT
/*macro32_debug r1, 100, 124*/

	cmp r0, #512                                                   @ Reach End of Packet
	moveq r1, #1
	streq r1, OS_FIQ_RECEIVE

	macro32_dsb ip

	pop {r0-r7,pc}

.globl OS_FIQ_COUNT
.globl OS_FIQ_RECEIVE
OS_FIQ_COUNT:   .word 0x00
OS_FIQ_RECEIVE: .word 0x00

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
