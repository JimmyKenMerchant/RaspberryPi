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

.equ __MIDI_BASECHANNEL, 0                               @ Default MIDI Channel (Actual Channel No. Minus One)

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

	/* Enable UART IRQ */
	mov r1, #1<<25                                   @ UART IRQ #57
	str r1, [r0, #equ32_interrupt_enable_irqs2]

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

	ldr r1, [r0, #equ32_gpio_gpfsel00]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_9    @ Set GPIO 9 INPUT, MIDI Channel Select Bit[0]
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_0    @ Set GPIO 10 INPUT, MIDI Channel Select Bit[1]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 15 ALT 0 as RXD0
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_6   @ Set GPIO 16 OUTPUT
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 17 OUTPUT
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
	orr r1, r1, #equ32_gpio22                                      @ Set GPIO22 Rising Edge Detect
	orr r1, r1, #equ32_gpio23                                      @ Set GPIO23 Rising Edge Detect
	orr r1, r1, #equ32_gpio24                                      @ Set GPIO24 Rising Edge Detect
	orr r1, r1, #equ32_gpio25                                      @ Set GPIO25 Rising Edge Detect
	orr r1, r1, #equ32_gpio26                                      @ Set GPIO26 Rising Edge Detect
	orr r1, r1, #equ32_gpio27                                      @ Set GPIO27 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]

	macro32_dsb ip

	/* Check MIDI Channel, GPIO9 (Bit[0]) and GPIO10 (Bit[1]) */
	ldr r1, [r0, #equ32_gpio_gplev0]
	ldr r2, os_irq_midi_channel
	tst r1, #equ32_gpio09
	addne r2, r2, #1
	tst r1, #equ32_gpio10
	addne r2, r2, #2
	str r2, os_irq_midi_channel

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
	mov r0, #36                                              @ Integer Divisor Bit[15:0], 18000000 / (16*31250) is 36
	mov r1, #0b0                                             @ Fractional Divisor Bit[5:0], Fixed Point Float 0.0
	mov r2, #0b11<<equ32_uart0_lcrh_sps|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe|equ32_uart0_cr_txe           @ Coontrol
	bl uart32_uartinit
	pop {r0-r3}
.else
	/* UART 115200 Baud */
	push {r0-r3}
	mov r0, #9                                               @ Integer Divisor Bit[15:0], 18000000 / (16*115200) is 9.765625
	mov r1, #0b110001                                        @ Fractional Divisor Bit[5:0], Fixed Point Float 0.765625
	mov r2, #0b11<<equ32_uart0_lcrh_sps|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe|equ32_uart0_cr_txe           @ Coontrol
	bl uart32_uartinit
	pop {r0-r3}
.endif

	/* Each FIFO is 16 Words Depth (8-bit on Tx, 12-bit on Rx) */
	/* The Setting of r1 Below Triggers Tx and Rx Interrupts on Reaching 2 Bytes of RxFIFO (0b000) */
	/* But Now on Only Using Rx Timeout */
	push {r0-r3}
	mov r0, #0b000<<equ32_uart0_ifls_rxiflsel|0b000<<equ32_uart0_ifls_txiflsel @ Trigger Points of Both FIFOs Levels to 1/4
	mov r1, #equ32_uart0_intr_rt @ When 1 Byte and More Exist on RxFIFO
	bl uart32_uartsetint
	pop {r0-r3}

	push {r0-r3}
	mov r0, #64
	bl snd32_soundmidi_malloc
	pop {r0-r3}
	
	pop {pc}

os_debug:
	push {lr}
	pop {pc}

os_irq:
	push {r0-r12,lr}

	ldr r0, os_irq_midi_channel

.ifdef __SOUND_I2S
	mov r1, #1
	bl snd32_soundmidi
.endif
.ifdef __SOUND_I2S_BALANCED
	mov r1, #1
	bl snd32_soundmidi
.endif
.ifdef __SOUND_PWM
	mov r1, #0
	bl snd32_soundmidi
.endif
.ifdef __SOUND_PWM_BALANCED
	mov r1, #0
	bl snd32_soundmidi
.endif
.ifdef __SOUND_JACK
	mov r1, #0
	bl snd32_soundmidi
.endif
.ifdef __SOUND_JACK_BALANCED
	mov r1, #0
	bl snd32_soundmidi
.endif

	/* High on GPIO20 If MIDI Note On */
	ldr r0, ADDR32_SND32_STATUS
	ldr r0, [r0]
	tst r0, #0x4                                      @ Bit[2] MIDI Note Off(0)/ Note On(1)
	movne r1, #1                                      @ Gate On
	moveq r1, #0                                      @ Gate Off
	mov r0, #20                                       @ GPIO 20
	bl gpio32_gpiotoggle

	pop {r0-r12,pc}

os_irq_midi_channel: .word __MIDI_BASECHANNEL

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
