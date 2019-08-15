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

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base

	mvn r1, #0                                       @ Whole Inverter

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                              @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	/**
	 * Get a 10hz Timer Interrupt (120000/12000)
	 */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_16|equ32_armtimer_ctl_23bit_counter @ Prescaler 1/16 to 100K
	mov r1, #0x2E00                                  @ 0x2E00 High 1 Byte of decimal 11999 (12000 - 1), 16 bits counter on default
	add r1, r1, #0xDF                                @ 0xDF Low 1 Byte of decimal 11999, 16 bits counter on default
	mov r2, #0x7C                                    @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer

	/* Obtain Framebuffer from VideoCore IV */
	mov r0, #32
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	macro32_clean_cache r1, ip

	bl bcm32_get_framebuffer

	pop {pc}

os_debug:
	push {r4-r8,lr}

	push {r0-r3}
	mov r0, #4096
	mov r1, #256
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 100

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r5, r0
	pop {r0-r3}

macro32_debug r5, 100, 112

	push {r0-r3}
	mov r0, r4
	bl bcm32_unlock_memory
	mov r6, r0
	pop {r0-r3}

macro32_debug r6, 100, 124

	push {r0-r3}
	mov r0, r4
	bl bcm32_release_memory
	mov r7, r0
	pop {r0-r3}

macro32_debug r7, 100, 136

	push {r0-r3}
	mov r0, #1
	bl v3d32_enableqpu
	mov r8, r0
	pop {r0-r3}

macro32_debug r8, 100, 148

	pop {r4-r8,pc}

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
	/* ACT Blinker, GPIO 47 Is Preset as OUT */
	mov r0, #47
	mov r1, #2
	bl gpio32_gpiotoggle
.endif

	pop {r0-r7,pc}

/**
 * Variables
 */
_string_hello:
	.ascii "\nMAHALO! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4

.include "data.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
