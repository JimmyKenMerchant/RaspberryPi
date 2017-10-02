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
.include "vector32/el01_simple.s"
.include "vector32/el3_simple.s"

.section	.os_vector32
.globl _os_start
_os_start:
	ldr pc, _os_reset_addr                    @ 0x00 reset
	ldr pc, _os_undefined_instruction_addr    @ 0x04 (Hyp mode in Hyp mode)
	ldr pc, _os_supervisor_addr               @ 0x08 (Hyp mode in Hyp mode)
	ldr pc, _os_prefetch_abort_addr           @ 0x0C (Hyp mode in Hyp mode)
	ldr pc, _os_data_abort_addr               @ 0x10 (Hyp mode in Hyp mode)
	ldr pc, _os_reserve_addr                  @ If you call `HVC` in Hyp Mode, It translates to `SVC`
	ldr pc, _os_irq_addr                      @ 0x18 (Hyp mode in Hyp mode)
	ldr pc, _os_fiq_addr                      @ 0x1C (Hyp mode in Hyp mode)
_os_reset_addr:                 .word _os_reset
_os_undefined_instruction_addr: .word _os_reset
_os_supervisor_addr:            .word _os_reset
_os_prefetch_abort_addr:        .word _os_reset
_os_data_abort_addr:            .word _os_reset
_os_reserve_addr:               .word _os_reset
_os_irq_addr:                   .word _os_reset
_os_fiq_addr:                   .word _os_fiq

_os_reset:
	mov r0, sp                                @ Store Previous Stack Pointer
	mrc p15, 0, r1, c12, c0, 0                @ Last VBAR Address to Retrieve
	mov sp, #0x8000                           @ Stack Pointer to 0x8000
                                                  @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)
	push {r0-r1,lr}

	/* SVC mode FIQ Disable and IRQ Disable, Current Mode */
	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov r0, #equ32_fiq_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov sp, #0x7000

	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov r0, #0x8000
	mcr p15, 0, r0, c12, c0, 0                @ Change VBAR, IVT Base Vector Address

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

	mov r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_1   @ Set GPIO 21 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel20]


_os_render:
	cpsie f
	_os_render_loop:
		b _os_render_loop

	mov fp, #0x8000                          @ Retrieve Previous Stack Pointer, VBAR,and Link Register
	ldr r0, [fp, #-8]                        @ Stack Pointer
	ldr r1, [fp, #-4]                        @ Stack Pointer
	ldr lr, [fp]                             @ Link Register
	mov sp, r0
	mcr p15, 0, r1, c12, c0, 0               @ Retrieve VBAR Address
	mov pc, lr

_os_debug:
	cpsie f                                  @ cpsie is for enable IRQ (i), FIQ (f) and Abort (a) (all, ifa). cpsid is for disable
	_os_debug_loop1:
		b _os_debug_loop1

_os_fiq:
	cpsid f                                  @ Disable Aborts (a), FIQ(f), IRQ(i)

	push {r0-r12,lr}                         @ Equals to stmfd (stack pointer full, decrement order)
	mrs r0, spsr
	push {r0}

	bl _os_fiq_handler

	pop {r0}
	msr spsr, r0
	pop {r0-r12,lr}                          @ Equals to ldmfd (stack pointer full, decrement order)

	cpsie f                                  @ Enable Aborts (a), FIQ(f), IRQ(i)

	subs pc, lr, #4

_os_fiq_handler:
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldr r1, gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	str r1, gpio_toggle

	cmp r1, #0
	addeq r0, r0, #equ32_gpio_gpclr0
	addne r0, r0, #equ32_gpio_gpset0
	mov r1, #equ32_gpio21
	str r1, [r0]

	_os_fiq_handler_jump:
		mov pc, lr

/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00000000

.balign 4

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
