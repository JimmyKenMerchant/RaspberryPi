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
_el2_undefined_instruction_addr: .word _el01_reset
_el2_supervisor_addr:            .word _el01_reset
_el2_prefetch_abort_addr:        .word _el01_reset
_el2_data_abort_addr:            .word _el01_reset
_el2_hypervisor_addr:            .word _el01_reset
_el2_irq_addr:                   .word _el01_reset
_el2_fiq_addr:                   .word _el01_reset
