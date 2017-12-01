/**
 * el2.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.section	.el2_vector32
/* HVBAR (EL2), It Will Be Changed for Virtual OS */
	_el2_reserve0: .word 0x00
	ldr pc, _el2_undefined_instruction_addr    @ 0x04
	ldr pc, _el2_supervisor_addr               @ 0x08
	ldr pc, _el2_prefetch_abort_addr           @ 0x0C
	ldr pc, _el2_data_abort_addr               @ 0x10
	ldr pc, _el2_hypervisor_addr               @ 0x14
	ldr pc, _el2_irq_addr                      @ 0x18
	ldr pc, _el2_fiq_addr                      @ 0x1C
_el2_undefined_instruction_addr: .word _el2_undefined_instruction
_el2_supervisor_addr:            .word _el2_supervisor
_el2_prefetch_abort_addr:        .word _el2_prefetch_abort
_el2_data_abort_addr:            .word _el2_data_abort
_el2_hypervisor_addr:            .word _el2_hypervisor
_el2_irq_addr:                   .word _el2_irq
_el2_fiq_addr:                   .word _el2_fiq


/**
 * Exceptions from Hyp mode stay Hyp mode.
 * To prevent to overwrite elr_hyp and spsr_hyp, store both to the stack.
 */

_el2_undefined_instruction:
	mrs r0, elr_hyp
	mrs r1, spsr_hyp
	push {r0,r1}

	_el2_undefined_instruction_loop:
		b _el2_undefined_instruction_loop

	pop {r0,r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1

	eret


_el2_supervisor:
	mrs r0, elr_hyp
	mrs r1, spsr_hyp
	push {r0,r1}

	nop

	pop {r0,r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1

	eret


_el2_prefetch_abort:
	mrs r0, elr_hyp
	mrs r1, spsr_hyp
	push {r0,r1}

	_el2_prefetch_abort_loop:
		b _el2_prefetch_abort_loop

	pop {r0,r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1

	eret


_el2_data_abort:
	mrs r0, elr_hyp
	mrs r1, spsr_hyp
	push {r0,r1}

	_el2_data_abort_loop:
		b _el2_data_abort_loop

	pop {r0,r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1

	eret


_el2_hypervisor:
	mrs r0, elr_hyp
	mrs r1, spsr_hyp
	push {r0,r1}

	nop

	pop {r0,r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1

	eret


_el2_irq:
	mrs r0, elr_hyp
	mrs r1, spsr_hyp
	push {r0,r1}

	nop

	pop {r0,r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1

	eret


_el2_fiq:
	mrs r0, elr_hyp
	mrs r1, spsr_hyp
	push {r0,r1}

	nop

	pop {r0,r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1

	eret
