/**
 * os.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.section	.os_vector32
.globl _os_start
_os_start:
	ldr pc, _os_reset_addr                    @ 0x00 User/System Mode SP 0x7000
	ldr pc, _os_undefined_instruction_addr    @ 0x04 SP 0x7200
	ldr pc, _os_supervisor_addr               @ 0x08 SP 0x7400
	ldr pc, _os_prefetch_abort_addr           @ 0x0C SP 0x7600
	ldr pc, _os_data_abort_addr               @ 0x10 SP 0x7600
	ldr pc, _os_reserve_addr
	ldr pc, _os_irq_addr                      @ 0x18 SP 0x7800
	ldr pc, _os_fiq_addr                      @ 0x1C SP 0x8000
_os_reset_addr:                 .word _os_reset
_os_undefined_instruction_addr: .word _os_reset
_os_supervisor_addr:            .word _os_reset
_os_prefetch_abort_addr:        .word _os_reset
_os_data_abort_addr:            .word _os_reset
_os_reserve_addr:               .word _os_reset
_os_irq_addr:                   .word _os_irq
_os_fiq_addr:                   .word _os_fiq

_os_reset:
	mov r0, sp                                @ Store Previous Stack Pointer
	mrc p15, 0, r1, c12, c0, 0                @ Last VBAR Address to Retrieve
	mov sp, #0x7400                           @ Stack Pointer to 0x8000
                                                  @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)
	push {r0-r1,lr}

	/* SVC mode FIQ Disable and IRQ Disable, Current Mode */
	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov r0, #equ32_fiq_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov sp, #0x8000

	mov r0, #equ32_irq_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov sp, #0x7800

	mov r0, #equ32_abt_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov sp, #0x7600

	mov r0, #equ32_und_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov sp, #0x7200

	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov r0, #0x8000
	mcr p15, 0, r0, c12, c0, 0                @ Change VBAR, IVT Base Vector Address

	bl os_reset

	mov r0, #equ32_user_mode                  @ Enable FIQ, IRQ, and Abort
	msr cpsr_c, r0

	mov sp, #0x7000

	push {r0-r3}
	bl _user_start
	pop {r0-r3}

	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov fp, #0x7400                          @ Retrieve Previous Stack Pointer (SP), VBAR,and Link Register
	ldr r0, [fp, #-8]                        @ SP
	ldr r1, [fp, #-4]                        @ VBAR
	ldr lr, [fp]                             @ Link Register
	mov sp, r0                               @ Retrieve SP
	mcr p15, 0, r1, c12, c0, 0               @ Retrieve VBAR Address
	mov pc, lr


_os_irq:
	cpsid i                                  @ Disable Aborts (a), FIQ(f), IRQ(i)

	push {r0-r12,lr}                         @ Equals to stmfd (stack pointer full, decrement order)
	mrs r0, spsr
	push {r0}

	bl os_irq

	pop {r0}
	msr spsr, r0
	pop {r0-r12,lr}                          @ Equals to ldmfd (stack pointer full, decrement order)

	cpsie i                                  @ Enable Aborts (a), FIQ(f), IRQ(i)

	subs pc, lr, #4


_os_fiq:
	cpsid f                                  @ Disable Aborts (a), FIQ(f), IRQ(i)

	push {r0-r7,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
	mrs r0, spsr
	push {r0}

	bl os_fiq

	pop {r0}
	msr spsr, r0
	pop {r0-r7,lr}                           @ Equals to ldmfd (stack pointer full, decrement order)

	cpsie f                                  @ Enable Aborts (a), FIQ(f), IRQ(i)

	subs pc, lr, #4
