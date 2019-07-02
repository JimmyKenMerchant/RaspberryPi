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
	 * Timer
	 */

	/* Get a 48hz Timer Interrupt (120000/2500) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_16|equ32_armtimer_ctl_23bit_counter @ Prescaler 1/16 to 100K
	mov r1, #0x0900                           @ High 1 Byte of decimal 2499 (2500 - 1), 16 bits counter on default
	add r1, r1, #0xC3                         @ Low 1 Byte of decimal 2499, 16 bits counter on default
	mov r2, #0x7C                             @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer

	/**
	 * GPIO
	 */

	/* GPIO0-45 Reset and Pull Down */
	bl gpio32_gpioreset

	/* I/O Settings at user32.c */

	macro32_dsb ip

	/**
	 * Sound
	 */

	mov r0, #0
	bl snd32_soundinit_pwm

	pop {pc}	

os_debug:
	push {lr}
	pop {pc}

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r4,lr}                           @ r5-r7 is used across modes

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	/* Increment of Count to Acknowledge One Frame 12hz */
	ldr r0, os_fiq_count
	add r0, r0, #1
	cmp r0, #4
	movhs r0, #0                              @ Reset If Count Reaches 4
	str r0, os_fiq_count
	movhs r0, #1                              @ Set Flag If Count Reaches 4
	ldrhs r1, OS_FIQ_ONEFRAME_ADDR
	strhsb r0, [r1]

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

	mov r0, #0
	bl snd32_soundplay

	macro32_dsb ip

	pop {r0-r4,pc}

os_fiq_count:          .word 0x00

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
