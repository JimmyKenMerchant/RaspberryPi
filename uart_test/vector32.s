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

	mov r1, #0x95                             @ Decimal 149 to divide 240Mz by 150 to 1.6Mhz (Predivider is 10 Bits Wide)
	str r1, [r0, #equ32_armtimer_predivider]

	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	str r1, [r0, #equ32_armtimer_load]

	mov r1, #0x3E0000                         @ High 2 Bytes
	add r1, r1, #0b10100100                   @ Low 2 Bytes (00A4), Timer Enable and Timer Interrupt Enable, Prescaler 1/16 to 100K
	                                          @ 1/16 is #0b10100100, 1/256 is #0b10101000
	str r1, [r0, #equ32_armtimer_control]

	/* So We can get a 10hz Timer Interrupt (100000/10000) */

	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	/* Use ACT LED Only in Debugging to Reduce Noise */
.ifndef __RASPI3B
	ldr r1, [r0, #equ32_gpio_gpfsel40]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7     @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]
.endif

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4      @ Clear GPIO 14
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4       @ Set GPIO 14 ALT 0 as TXD0
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5      @ Clear GPIO 15
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5       @ Set GPIO 15 ALT 0 as RXD0
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

	push {r0-r3,lr}
	bl bcm32_get_framebuffer
	pop {r0-r3,lr}

	/* UART 9600 Baud */
	push {r0-r3,lr}
	mov r0, #32                                              @ Integer Divisor, 4915200 / 16 Multiplies by 9600 Equals 32
	mov r1, #0                                               @ Fractional Divisor
	mov r2, #0b11<<equ32_uart0_lcrh_sps|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe|equ32_uart0_cr_txe           @ Coontrol
	bl uart32_uartinit
	pop {r0-r3,lr}

	mov pc, lr

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

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	macro32_dsb ip


.ifndef __RASPI3B
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldrb r1, os_fiq_gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	strb r1, os_fiq_gpio_toggle

	cmp r1, #0
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]

	macro32_dsb ip
.endif

	pop {r0-r7,pc}

os_debug:
	push {lr}

	push {r1-r3}
	mov heap, #1
	bl heap32_malloc
	pop {r1-r3}

	os_debug_loop:

		b os_debug_loop
	
	pop {pc}


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
