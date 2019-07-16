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

/* Same as Baud Rate for DMX512, Stage Lighting */
/*.equ __DMX512, 1*/

/* Baud Rate 115200 */
/*.equ __HIGHBAUD, 1*/

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

.ifdef __DMX512
	/* Get a 1000000hz (4 * 250000) Timer Interrupt (240000000/240) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x0000                           @ High 1 Byte of decimal 239 (240 - 1), 16 bits counter on default
	orr r1, r1, #0xEF                         @ Low 1 Byte of decimal 239, 16 bits counter on default
	mov r2, #0x000                            @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	orr r2, r2, #0x000                        @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer
.else
.ifdef __HIGHBAUD
	/* Get a 460652.59hz (Nearest to 4 * 115200) Timer Interrupt (240000000/521) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x0200                           @ High 1 Byte of decimal 520 (521 - 1), 16 bits counter on default
	orr r1, r1, #0x08                         @ Low 1 Byte of decimal 520, 16 bits counter on default
	mov r2, #0x000                            @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	orr r2, r2, #0x000                        @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer
.else
	/* Get a 153550.86hz (Nearest to 4 * 38400) Timer Interrupt (240000000/1563) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x0600                           @ High 1 Byte of decimal 1562 (1563 - 1), 16 bits counter on default
	orr r1, r1, #0x1A                         @ Low 1 Byte of decimal 1562, 16 bits counter on default
	mov r2, #0x000                            @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	orr r2, r2, #0x000                        @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer
.endif
.endif

	/**
	 * GPIO
	 */

	/* GPIO0-45 Reset and Pull Down */
	bl gpio32_gpioreset

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	/* I/O Settings */

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_0   @ Set GPIO 20 OUTPUT (Software UART Tx)
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_1    @ Set GPIO 21 INPUT (Software UART Rx)
	str r1, [r0, #equ32_gpio_gpfsel20]

	macro32_dsb ip

	/* FIFO Continers, Allocate and Initialize */

	mov r0, #5
	bl heap32_malloc
	mov r1, #0x04
	strb r1, [r0]
	str r0, OS_FIQ_RXFIFO

	mov r0, #5
	bl heap32_malloc
	mov r1, #0x04
	strb r1, [r0]
	str r0, OS_FIQ_TXFIFO

	/* Pull Up */

	mov r0, #20
	mov r1, #2
	bl gpio32_gpiopull

	mov r0, #21
	mov r1, #2
	bl gpio32_gpiopull

	/* Software UART Output High */
	mov r0, #20
	mov r1, #1
	bl gpio32_gpiotoggle

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

.ifdef __DMX512
	mov r0, #21
	ldr r1, OS_FIQ_RXFIFO
	mov r2, #8                                @ 8 Bits to Receive
	mov r3, #2                                @ 2 Stop Bits
	bl softuart32_softuartreceiver

	ldr r0, OS_FIQ_RXFIFO
	ldrb r0, [r0]

	ldr r1, OS_FIQ_BREAK
	tst r0, #0b1
	addne r1, r1, #1                          @ Increment If Break, Counts Bits from Break
	str r1, OS_FIQ_BREAK

	mov r0, #20
	ldr r1, OS_FIQ_TXFIFO
	mov r2, #8                                @ 8 Bits to Receive
	mov r3, #2                                @ 2 Stop Bits
	bl softuart32_softuarttransmitter
.else
	mov r0, #21
	ldr r1, OS_FIQ_RXFIFO
	mov r2, #8                                @ 8 Bits to Receive
	mov r3, #1                                @ 1 Stop Bit
	bl softuart32_softuartreceiver

	ldr r0, OS_FIQ_RXFIFO
	ldrb r0, [r0]

	ldr r1, OS_FIQ_BREAK
	tst r0, #0b1
	addne r1, r1, #1                          @ Increment If Break, Counts Bits from Break
	str r1, OS_FIQ_BREAK

	mov r0, #20
	ldr r1, OS_FIQ_TXFIFO
	mov r2, #8                                @ 8 Bits to Receive
	mov r3, #1                                @ 1 Stop Bit
	bl softuart32_softuarttransmitter
.endif

	pop {r0-r7,pc}

.globl OS_FIQ_RXFIFO
.globl OS_FIQ_TXFIFO
.globl OS_FIQ_BREAK
OS_FIQ_RXFIFO: .word 0x00
OS_FIQ_TXFIFO: .word 0x00
OS_FIQ_BREAK:  .word 0x00

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
