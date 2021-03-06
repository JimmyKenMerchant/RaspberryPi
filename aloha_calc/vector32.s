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
.equ __SOUND, 1

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

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	macro32_dsb ip

	/* Enable UART IRQ */
	mov r1, #1<<25                                   @ UART IRQ #57
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
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2       @ Set GPIO 2 ALT 0 as SDA1
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_3       @ Set GPIO 3 ALT 0 as SCL1
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4       @ Set GPIO 14 ALT 0 as TXD0
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5       @ Set GPIO 15 ALT 0 as RXD0
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_2      @ Set GPIO 22 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_3     @ Set GPIO 23 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_4     @ Set GPIO 24 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_5     @ Set GPIO 25 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6     @ Set GPIO 26 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7     @ Set GPIO 27 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

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

	/* UART 115385 Baud, Approx. 0.2 Percents Error for 115200 Baud */
	push {r0-r3}
	mov r0, #4                                                @ Integer Divisor Bit[15:0], 7500000 / (16 * 115200) is 4.06901
	mov r1, #0b000100                                         @ Fractional Divisor Bit[5:0], Fixed Point Float 0.0625
	mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe|equ32_uart0_cr_txe            @ Control
	bl uart32_uartinit
	pop {r0-r3}

	/* Each FIFO is 16 Words Depth (8-bit on Tx, 12-bit on Rx) */
	/* The Setting of r1 Below Triggers Tx and Rx Interrupts on Reaching 2 Bytes of RxFIFO (0b000) */
	/* But Now on Only Using Rx Timeout */
	push {r0-r3}
	mov r0, #0b000<<equ32_uart0_ifls_rxiflsel|0b000<<equ32_uart0_ifls_txiflsel @ Trigger Points of Both FIFOs Levels to 1/4
	mov r1, #equ32_uart0_intr_rt @ When 1 Byte and More Exist on RxFIFO
	bl uart32_uartsetint
	pop {r0-r3}

	push {r0-r3}
	mov r0, #1024                                            @ 1024 Lines Minus 1 Line for #0, 1023 Lines Available
	mov r1, #16                                              @ 16 Words, 64 Bytes per Each Row
	bl uart32_uartmalloc
	pop {r0-r3}

	push {r0-r3}
	mov r0, #128                                             @ 128 Words
	bl uart32_uartmalloc_client
	pop {r0-r3}

	push {r0-r3}
	mov r0, #0xF0           @ Divisor of Clock to Decimal 240 for 1MHz
	mov r1, #0x0030         @ Delay
	orr r1, r1, #0x00300000 @ Delay
	mov r2, #0x40           @ Clock Stretch Timeout
	bl i2c32_i2cinit
	pop {r0-r3}

.ifdef __SOUND
	push {r0-r3}
.ifdef __SOUND_I2S
	bl snd32_soundinit_i2s
.endif
.ifdef __SOUND_JACK
	mov r0, #1
	bl snd32_soundinit_pwm
.endif
.ifdef __SOUND_PWM
	mov r0, #0
	bl snd32_soundinit_pwm
.endif
	pop {r0-r3}
.endif

	pop {pc}

os_debug:
	push {lr}
	pop {pc}

os_irq:
	push {r0-r12,lr}

	mov r0, #1
	bl uart32_uartintrouter

	pop {r0-r12,pc}

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

	/* Acknowledge One Frame */
	mov r0, #1
	ldr r1, OS_FIQ_ONEFRAME_ADDR
	strb r0, [r1]

	macro32_dsb ip

.ifndef __RASPI3B
	/* ACT Blinker, GPIO 47 Is Preset as OUT */
	mov r0, #47
	mov r1, #2
	bl gpio32_gpiotoggle
	macro32_dsb ip
.endif

/*
.ifdef __SOUND
	push {r0-r3}
.ifdef __SOUND_I2S
	mov r0, #1
.else
	mov r0, #0
.endif
	bl snd32_soundplay
	pop {r0-r3}

	macro32_dsb ip
.endif

	push {r0-r3}
	mov r0, #0x0F800000                        @ GPIO23-27
	bl gpio32_gpioplay
	pop {r0-r3}
*/

	pop {r0-r7,pc}

/**
 * Variables
 */
.balign 4

string_hello:
	.word _string_hello
OS_FIQ_ONEFRAME_ADDR:  .word OS_FIQ_ONEFRAME

.include "addr32.s" @ If you want binary, use `.incbin`

.section	.data
_string_hello:
	.ascii "\nALOHA! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
.globl OS_FIQ_ONEFRAME
OS_FIQ_ONEFRAME:       .byte 0x00
.balign 4

/* Additional Libraries Here */
.section	.text

/* End of Line is Needed */
