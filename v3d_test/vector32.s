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
	push {r4-r10,lr}

	push {r0-r3}
	mov r0, #1
	bl v3d32_enable_qpu
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 88

	push {r0-r3}
	mov r0, #1
	bl v3d32_enable_qpul2cache
	pop {r0-r3}

	push {r0-r3}
	mov r0, #0x0000
	bl v3d32_control_qpuinterrupt
	pop {r0-r3}

	push {r0-r3}
	mov r0, #8
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 100

	str r4, handle_mail

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 112

	str r4, addr_mail

	push {r0-r3}
	mov r0, #4
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 124

	str r4, handle_uniform

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 136

	str r4, addr_uniform

	push {r0-r3}
	mov r0, #256
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 148

	str r4, handle_output

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 160

	str r4, addr_output

	push {r0-r3}
	ldr r0, DATA_QASM_SAMPLE1_SIZE
	mov r1, #4096
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 172

	str r4, handle_code

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 184

	str r4, addr_code

	ldr r0, DATA_QASM_SAMPLE1
	ldr r1, DATA_QASM_SAMPLE1_SIZE
	bic r2, r4, #0xC0000000

	os_debug_loop:
		ldr r3, [r0]
		str r3, [r2]
		macro32_clean_cache r2, ip
		add r0, r0, #4
		add r2, r2, #4
		macro32_dsb ip
		subs r1, r1, #4
		bgt os_debug_loop

	bic r2, r4, #0xC0000000

	ldr r0, addr_mail
	bic r0, r0, #0xC0000000
	ldr r1, addr_uniform
	bic r2, r1, #0xC0000000
	ldr r3, addr_output

	str r3, [r2]
	str r1, [r0]
	str r4, [r0, #4]

	macro32_clean_cache r0, ip
	macro32_clean_cache r2, ip

	macro32_dsb ip

	push {r0-r3}
	mov r0, #1
	ldr r1, addr_mail
	mov r2, #1
	mov r3, #0xFF0000
	bl v3d32_execute_qpu
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 208

	bic r3, r3, #0xC0000000

macro32_debug_hexa r3, 0, 220, 256

/*
	push {r0-r3}
	mov r0, r4
	bl bcm32_unlock_memory
	pop {r0-r3}

	push {r0-r3}
	mov r0, r4
	bl bcm32_release_memory
	pop {r0-r3}

	push {r0-r3}
	mov r0, r6
	bl bcm32_unlock_memory
	pop {r0-r3}

	push {r0-r3}
	mov r0, r6
	bl bcm32_release_memory
	pop {r0-r3}
*/

	pop {r4-r10,pc}

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
handle_mail:    .word 0x00
addr_mail:      .word 0x00
handle_uniform: .word 0x00
addr_uniform:   .word 0x00
handle_output:  .word 0x00
addr_output:    .word 0x00
handle_code:    .word 0x00
addr_code:      .word 0x00
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
