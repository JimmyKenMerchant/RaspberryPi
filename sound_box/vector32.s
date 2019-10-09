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

/* Define 31250 Baud Rate on UART for Actual MIDI In */
/*.equ __MIDIIN, 1*/

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

	/* Get a 960hz Timer Interrupt (480000/500) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x100                            @ High 1 Byte of decimal 499 (500 - 1), 16 bits counter on default
	orr r1, r1, #0x0F3                        @ Low 1 Byte of decimal 499, 16 bits counter on default
	mov r2, #0x1F0                            @ Decimal 499 to divide 240Mz by 500 to 480Khz (Predivider is 10 Bits Wide)
	orr r2, r2, #0x003                        @ Decimal 499 to divide 240Mz by 500 to 480Khz (Predivider is 10 Bits Wide)
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
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_8    @ Set GPIO 8 INPUT, MIDI Channel Select Bit[0]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_9    @ Set GPIO 9 INPUT, MIDI Channel Select Bit[1]
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_0    @ Set GPIO 10 INPUT, MIDI Channel Select Bit[2]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_1    @ Set GPIO 11 INPUT, MIDI Channel Select Bit[3]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 15 ALT 0 as RXD0
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6   @ Set GPIO 16 OUTPUT
.ifdef __NOSYNCCLOCK
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_7    @ Set GPIO 17 INPUT
.else
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 17 OUTPUT
.endif
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_0   @ Set GPIO 20 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_2    @ Set GPIO 22 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_3    @ Set GPIO 23 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_4    @ Set GPIO 24 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_5    @ Set GPIO 25 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_6    @ Set GPIO 26 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_7    @ Set GPIO 27 INPUT
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

	ldr r1, [r0, #equ32_gpio_gpfen0]
	orr r1, r1, #equ32_gpio27                                      @ Set GPIO27 Falling Edge Detect
	str r1, [r0, #equ32_gpio_gpfen0]

	macro32_dsb ip

	/* Check MIDI Channel, GPIO8 (Bit[0]), GPIO9 (Bit[1]), GPIO10 (Bit[2]), and GPIO11 (Bit[3]) */
	ldr r1, [r0, #equ32_gpio_gplev0]
	lsr r1, r1, #8
	and r1, r1, #0b1111
	str r1, OS_RESET_MIDI_CHANNEL

	/**
	 * Sound
	 */

.ifdef __SOUND_I2S
	bl snd32_soundinit_i2s
.endif
.ifdef __SOUND_I2S_BALANCED
	bl snd32_soundinit_i2s
.endif
.ifdef __SOUND_PWM
	mov r0, #0
	bl snd32_soundinit_pwm
.endif
.ifdef __SOUND_PWM_BALANCED
	mov r0, #0
	bl snd32_soundinit_pwm
.endif
.ifdef __SOUND_JACK
	mov r0, #1
	bl snd32_soundinit_pwm
.endif
.ifdef __SOUND_JACK_BALANCED
	mov r0, #1
	bl snd32_soundinit_pwm
.endif

	/**
	 * UART and MIDI
	 */

.ifdef __MIDIIN
	/* UART 31250 Baud */
	push {r0-r3}
	mov r0, #15                                               @ Integer Divisor Bit[15:0], 7500000 / (16 * 31250) is 15
	mov r1, #0b000000                                         @ Fractional Divisor Bit[5:0], Fixed Point Float 0.0
	mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe                               @ Control
	bl uart32_uartinit
	pop {r0-r3}
.else
	/* UART 115385 Baud, Approx. 0.2 Percents Error for 115200 Baud */
	push {r0-r3}
	mov r0, #4                                                @ Integer Divisor Bit[15:0], 7500000 / (16 * 115200) is 4.06901
	mov r1, #0b000100                                         @ Fractional Divisor Bit[5:0], Fixed Point Float 0.0625
	mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe                               @ Control
	bl uart32_uartinit
	pop {r0-r3}
.endif

	push {r0-r3}
	mov r0, #64
	bl snd32_soundmidi_malloc
	pop {r0-r3}
	
	pop {pc}

.globl OS_RESET_MIDI_CHANNEL
OS_RESET_MIDI_CHANNEL:   .word 0x00               @ MIDI Channel (Actual Channel No. - 1)

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
