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

	/**
	 * Enable GPIO IRQ
	 * INT[0] is for 0-27 Pins
	 * INT[1] is for 28-45 Pins
	 * INT[2] is for 46-53 Pins
	 * INT[3] is for All Pins
	 */
	mov r1, #0b1111<<17                              @ GPIO INT[3:0]
	str r1, [r0, #equ32_interrupt_enable_irqs2]

	mov r1, #0b11000000                              @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	/**
	 * Get a 12hz Timer Interrupt (120000/10000).
	 */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_16|equ32_armtimer_ctl_23bit_counter @ Prescaler 1/16 to 100K
	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	mov r2, #0x7C                             @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
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
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4     @ Set GPIO 4 ALT 0 as GPCLK1
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 15 ALT 0 as RXD0
	str r1, [r0, #equ32_gpio_gpfsel10]

	/* Set Status Detect */
	ldr r1, [r0, #equ32_gpio_gpren0]
	orr r1, r1, #equ32_gpio04                                      @ Set GPIO4 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]

	macro32_dsb ip

	/* DMX512 Receive */
	mov r0, #1                                                     @ Start Code
	add r0, r0, #512                                               @ Channel Data
	bl dmx32_dmx512doublebuffer_init

	/**
	 * Clock Manager for GPCLK0. Make 23244.55Hz (43.02 Micro Seconds)
	 */
	mov r0, #equ32_cm_gp0
	mov r1, #equ32_cm_ctl_mash_1
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc            @ 19.2Mhz
	mov r2, #0x330<<equ32_cm_div_integer                           @ Decimal 826
	orr r2, r2, #0x00A<<equ32_cm_div_integer                       @ Decimal 826
	bl arm32_clockmanager

	/* UART Receive 250000 Baud */
	mov r0, #4                                                     @ Integer Divisor Bit[15:0], 18000000 / 16 * 250000 is 4.5
	mov r1, #0b100000                                              @ Fractional Divisor Bit[5:0], Fixed Point Float 0.5
	mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen|equ32_uart0_lcrh_stp2 @ Line Control
	mov r3, #equ32_uart0_cr_rxe                                    @ Control
	bl uart32_uartinit

	pop {pc}

os_debug:
	push {lr}
	pop {pc}

os_irq:
	push {r0-r12,lr}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base
	ldr r1, [r0, #equ32_interrupt_pending_irqs2]
/*macro32_debug r1, 100, 88*/

	macro32_dsb ip

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base
	ldr r1, [r0, #equ32_gpio_gpeds0]                               @ Clear GPIO Event Detect
	str r1, [r0, #equ32_gpio_gpeds0]                               @ Clear GPIO Event Detect
/*macro32_debug r1, 100, 100*/

	macro32_dsb ip

	bl dmx32_dmx512doublebuffer_rx

	cmp r0, #-1                                                    @ Break

	ldr r1, OS_IRQ_COUNT
	addeq r1, r1, #1
	str r1, OS_IRQ_COUNT
/*macro32_debug r1, 100, 124*/

	cmp r0, #512                                                   @ Reach End of Packet
	moveq r1, #1
	streq r1, OS_IRQ_RECEIVE

	macro32_dsb ip

	pop {r0-r12,pc}

.globl OS_IRQ_COUNT
.globl OS_IRQ_RECEIVE_ADDR
OS_IRQ_COUNT:        .word 0x00
OS_IRQ_RECEIVE_ADDR: .word OS_IRQ_RECEIVE
OS_IRQ_RECEIVE:      .word 0x00

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

	ldr r0, OS_FIQ_COUNT
	add r0, r0, #1
	str r0, OS_FIQ_COUNT
/*macro32_debug r0, 100, 124*/

	macro32_dsb ip

	pop {r0-r7,pc}

.globl OS_FIQ_COUNT
OS_FIQ_COUNT: .word 0x00

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
