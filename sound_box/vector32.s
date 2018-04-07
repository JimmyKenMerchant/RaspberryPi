/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Define Debug Status */
/*.equ __DEBUG, 1 */

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

	/* Get a 96hz Timer Interrupt (120000/1250) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_16|equ32_armtimer_ctl_23bit_counter @ Prescaler 1/16 to 100K
	mov r1, #0x0400                           @ High 1 Byte of decimal 1249 (1250 - 1), 16 bits counter on default
	add r1, r1, #0xE1                         @ Low 1 Byte of decimal 1249, 16 bits counter on default
	mov r2, #0x7C                             @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer

	/**
	 * GPIO
	 */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	/* Clear GPIO0-45 OUTPUT High */
	mvn r1, #0
	str r1, [r0, #equ32_gpio_gpclr0]                               @ GPIO 0-31 OUT Clear
	mov r1, #0xFF
	orr r1, r1, #0x3F00
	str r1, [r0, #equ32_gpio_gpclr1]                               @ GPIO 32-45 OUT Clear

	/* Clear GPIO0-45 Functions (Except Internal Use) */
	mov r1, #0
	str r1, [r0, #equ32_gpio_gpfsel00]                             @ Clear GPIO 0-9
	str r1, [r0, #equ32_gpio_gpfsel10]                             @ Clear GPIO 10-19
	str r1, [r0, #equ32_gpio_gpfsel20]                             @ Clear GPIO 20-29
	str r1, [r0, #equ32_gpio_gpfsel30]                             @ Clear GPIO 30-39
	ldr r1, [r0, #equ32_gpio_gpfsel40]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_0    @ Clear GPIO 40
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1    @ Clear GPIO 41
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2    @ Clear GPIO 42
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_3    @ Clear GPIO 43
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4    @ Clear GPIO 44
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5    @ Clear GPIO 45
	str r1, [r0, #equ32_gpio_gpfsel40]

	macro32_dsb ip

.ifndef __RASPI3B
	/* USB Current Up and ACT Blinker */
	ldr r1, [r0, #equ32_gpio_gpfsel30]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_8    @ Clear GPIO 38
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_8   @ Set GPIO 38 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel30]
	ldr r1, [r0, #equ32_gpio_gpfsel40]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7    @ Clear GPIO 47
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]

	macro32_dsb ip

	/* Set USB Current Up (RasPi3 has already as default) */
	mov r1, #equ32_gpio38
	str r1, [r0, #equ32_gpio_gpset1]                               @ GPIO 38 OUTPUT High
.endif

	/* I/O Settings */
	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 17 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_2    @ Set GPIO 22 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_3    @ Set GPIO 23 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_4    @ Set GPIO 24 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_5    @ Set GPIO 25 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_6    @ Set GPIO 26 INPUT
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_7    @ Set GPIO 27 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	ldr r1, [r0, #equ32_gpio_gphen0]
	orr r1, r1, #equ32_gpio22                                      @ Set GPIO22 High Level Detect
	orr r1, r1, #equ32_gpio23                                      @ Set GPIO23 High Level Detect
	orr r1, r1, #equ32_gpio24                                      @ Set GPIO24 High Level Detect
	orr r1, r1, #equ32_gpio25                                      @ Set GPIO25 High Level Detect
	orr r1, r1, #equ32_gpio26                                      @ Set GPIO26 High Level Detect
	str r1, [r0, #equ32_gpio_gphen0]

	ldr r1, [r0, #equ32_gpio_gpren0]
	orr r1, r1, #equ32_gpio27                                      @ Set GPIO27 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]



	macro32_dsb ip

	/**
	 * Video
	 */

	/* Obtain Framebuffer from VideoCore IV */
	/*bl bcm32_get_framebuffer*/

	/**
	 * Sound
	 */

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

.ifndef __RASPI3B
	mov r0, #47
	mov r1, #2
	bl gpio32_gpiotoggle
	macro32_dsb ip
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
