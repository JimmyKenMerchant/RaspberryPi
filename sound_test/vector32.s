/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

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

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                       @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	/**
	 * Get a 12hz Timer Interrupt (120000/10000).
	 */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_16|equ32_armtimer_ctl_23bit_counter @ Prescaler 1/16 to 100K
	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	mov r2, #0x7C                             @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer

	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldr r1, [r0, #equ32_gpio_gpfsel40]

	/**
	 * Don't use a minijack on Raspberry Pi as a sound output on this project,
	 * The minijack does not assume usage on this project.
	 */
/*
.ifndef __ZERO
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_0    @ Clear GPIO 40
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_0     @ Set GPIO 40 PWM0 (to Minijack)
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5    @ Clear GPIO 45
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 45 PWM1 (to Minijack)
.endif
*/

	/**
	 * Use ACT LED only in debugging to reduce noise.  
	 */

.ifndef __RASPI3B
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7    @ Clear GPIO 47
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 47 OUTPUT
.endif

	str r1, [r0, #equ32_gpio_gpfsel40]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_0    @ Clear GPIO 20
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_0    @ Set GPIO 20 INPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1    @ Clear GPIO 21
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_1    @ Set GPIO 21 INPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2    @ Clear GPIO 22
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_2    @ Set GPIO 22 INPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_3    @ Clear GPIO 23
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_3    @ Set GPIO 23 INPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4    @ Clear GPIO 24
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_4    @ Set GPIO 24 INPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5    @ Clear GPIO 25
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_5    @ Set GPIO 25 INPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_6    @ Clear GPIO 26
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_6    @ Set GPIO 26 INPUT
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7    @ Clear GPIO 27
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_7    @ Set GPIO 27 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	ldr r1, [r0, #equ32_gpio_gpren0]
	orr r1, r1, #equ32_gpio20                                      @ Set GPIO20 Rising Edge Detect
.ifndef __SOUND_PCM
	orr r1, r1, #equ32_gpio21                                      @ Set GPIO21 Rising Edge Detect
.endif
	orr r1, r1, #equ32_gpio22                                      @ Set GPIO22 Rising Edge Detect
	orr r1, r1, #equ32_gpio23                                      @ Set GPIO23 Rising Edge Detect
	orr r1, r1, #equ32_gpio24                                      @ Set GPIO24 Rising Edge Detect
	orr r1, r1, #equ32_gpio25                                      @ Set GPIO25 Rising Edge Detect
	orr r1, r1, #equ32_gpio26                                      @ Set GPIO26 Rising Edge Detect
	orr r1, r1, #equ32_gpio27                                      @ Set GPIO27 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]

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

	push {r0-r3}
.ifdef __SOUND_PCM
	bl snd32_soundinit_pcm
.else
	bl snd32_soundinit_pwm
.endif
	pop {r0-r3}
	
	pop {pc}

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r7}

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
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldrb r1, os_fiq_gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	strb r1, os_fiq_gpio_toggle

	tst r1, #0b00000001
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]

	macro32_dsb ip
.endif

	push {r0-r3,lr}
	bl snd32_soundplay
	pop {r0-r3,lr}

	macro32_dsb ip

	pop {r0-r7}
	mov pc, lr

/**
 * Variables
 */
.balign 4
os_fiq_gpio_toggle: .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\nALOHA! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello

.include "addr32.s" @ If you want binary, use `.incbin`

/* End of Line is Needed */
