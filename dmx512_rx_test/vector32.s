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

	/* Enable UART IRQ */
	mov r1, #1<<25                                   @ UART IRQ #57
	str r1, [r0, #equ32_interrupt_enable_irqs2]

	mov r1, #0b11000000                              @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

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

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 15 ALT 0 as RXD0
	str r1, [r0, #equ32_gpio_gpfsel10]

	macro32_dsb ip

	/* DMX512 Receive */
	mov r0, #129                                                   @ Start Code and Channel Data / 4
	bl heap32_malloc
	str r0, OS_IRQ_DMX512RX

	/* UART Receive 250000 Baud */
	mov r0, #4                                                     @ Integer Divisor Bit[15:0], 18000000 / 16 * 250000 is 4.5
	mov r1, #0b100000                                              @ Fractional Divisor Bit[5:0], Fixed Point Float 0.5
	/*mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen|equ32_uart0_lcrh_stp2*/ @ Line Control
	mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen
	mov r3, #equ32_uart0_cr_rxe                                    @ Control
	bl uart32_uartinit

	/* Each FIFO is 16 Words Depth (8-bit on Tx, 12-bit on Rx) */
	mov r0, #0b000<<equ32_uart0_ifls_rxiflsel|0b000<<equ32_uart0_ifls_txiflsel @ Trigger Points of Both FIFOs Levels to 1/4
	mov r1, #equ32_uart0_intr_rt @ When 1 Byte and More Exist on RxFIFO
	bl uart32_uartsetint

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

	ldr r0, OS_IRQ_DMX512RX
	mov r1, #512
	add r1, r1, #1
	bl dmx32_dmx512receiver

	ldr r0, OS_IRQ_COUNT
	add r0, r0, #1
	str r0, OS_IRQ_COUNT
/*macro32_debug r0, 100, 112*/

	macro32_dsb ip

	pop {r0-r12,pc}

.globl OS_IRQ_COUNT
OS_IRQ_COUNT:    .word 0x00

.globl OS_IRQ_DMX512RX
OS_IRQ_DMX512RX: .word 0x00

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
