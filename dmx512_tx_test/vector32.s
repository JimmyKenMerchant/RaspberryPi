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
	 * Get Approx. 21695.9Hz (46.09 Micro Seconds) Timer Interrupt
	 */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_1|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x1500                           @ High 1 Byte of decimal 5530 (5531 - 1), 16 bits counter on default
	add r1, r1, #0x9A                         @ Low 1 Byte of decimal 5530, 16 bits counter on default
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
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4     @ Set GPIO 14 ALT 0 as TXD0
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_5   @ Set GPIO 15 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6   @ Set GPIO 16 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_2    @ Set GPIO 22 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_3    @ Set GPIO 23 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_4    @ Set GPIO 24 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_5    @ Set GPIO 25 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_6    @ Set GPIO 26 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_7    @ Set GPIO 27 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	/* Set Status Detect */

	ldr r1, [r0, #equ32_gpio_gpfen0]
	orr r1, r1, #equ32_gpio27                                      @ Set GPIO27 Falling Edge Detect
	str r1, [r0, #equ32_gpio_gpfen0]

	macro32_dsb ip

	/* DMX512 Transmission */
	mov r0, #1                                                     @ Start Code
	add r0, r0, #512                                               @ Channel Length
	bl dmx32_dmx512doublebuffer_init

	/* UART Transmission 250000 Baud */
	mov r0, #1                                                     @ Integer Divisor Bit[15:0], 7500000 / (16 * 250000) is 1.875
	mov r1, #0b111000                                              @ Fractional Divisor Bit[5:0], Fixed Point Float 0.875
	mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen|equ32_uart0_lcrh_stp2 @ Line Control
	mov r3, #equ32_uart0_cr_txe                                    @ Control
	bl uart32_uartinit

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

	ldr r0, OS_FIQ_COUNT
	add r0, r0, #1
	str r0, OS_FIQ_COUNT
/*macro32_debug r0, 100, 124*/

	macro32_dsb ip

	ldr r0, OS_FIQ_START
	cmp r0, #0                                @ Check If Start Flagged
	beq os_fiq_common

	ldr r0, OS_FIQ_SWAP
	bl dmx32_dmx512doublebuffer_tx
	cmp r0, #-1                               @ Check If End of Packet
	bne os_fiq_common

	mov r0, #1
	str r0, OS_FIQ_TRANSMIT
	ldr r0, OS_FIQ_REPEAT
	cmp r0, #0                                @ Check If REPEAT Flagged
	moveq r0, #0
	streq r0, OS_FIQ_START                    @ Stop If No REPEAT Flagged

	os_fiq_common:
		pop {r0-r7,pc}

.globl OS_FIQ_COUNT
.globl OS_FIQ_TRANSMIT
.globl OS_FIQ_SWAP
.globl OS_FIQ_START
.globl OS_FIQ_REPEAT
OS_FIQ_COUNT:    .word 0x00
OS_FIQ_TRANSMIT: .word 0x00
OS_FIQ_SWAP:     .word 0x00
OS_FIQ_START:    .word 0x00
OS_FIQ_REPEAT:   .word 0x00

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
