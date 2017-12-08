/**
 * el01_armv7.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.section	.el01_vector32
.globl _start
_start:
/* VBAR (EL0 and EL1) */
	ldr pc, _el01_reset_addr                    @ 0x00 reset
	ldr pc, _el01_undefined_instruction_addr    @ 0x04 Undefined mode (Banks SP, LR, SPSR) `MOVS PC, LR`
	ldr pc, _el01_supervisor_addr               @ 0x08 Supervisor mode by `SVC` (SP, LR, SPSR) `MOVS PC, LR`
	ldr pc, _el01_prefetch_abort_addr           @ 0x0C Abort mode (SP, LR, SPSR) `SUBS PC, LR, #4`
	ldr pc, _el01_data_abort_addr               @ 0x10 Abort mode (SP, LR, SPSR) `SUBS PC, LR, #8`
	_el01_reserve0: .word 0x00
	ldr pc, _el01_irq_addr                      @ 0x18 IRQ mode (SP, LR, SPSR) `SUBS PC, LR, #4`
	ldr pc, _el01_fiq_addr                      @ 0x1C FIQ mode (SP, LR, SPSR) `SUBS PC, LR, #4`
_el01_reset_addr:                 .word _el01_reset
_el01_undefined_instruction_addr: .word _el01_undefined_instruction
_el01_supervisor_addr:            .word _el01_svc
_el01_prefetch_abort_addr:        .word _el01_prefetch_abort
_el01_data_abort_addr:            .word _el01_data_abort
_el01_irq_addr:                   .word _el01_irq
_el01_fiq_addr:                   .word _el01_fiq

/* From Secure State SVC mode (EL1 Secure state) */
_el01_reset:
	mov r0, #0x0
	mcr p15, 0, r0, c12, c0, 0                @ VBAR(User Mode, EL0, and Privileged Mode, EL1), IVT Base Vector Address
	mov r0, #0x2000
	mcr p15, 0, r0, c12, c0, 1                @ MVBAR (Secure Monitor mode, EL3), IVT Base Vector Address

	smc #0

	macro32_multicore_id r0

	mov ip, #0x200                            @ Offset 0x200 Bytes (128 Words) per Core
	mul ip, ip, r0
	mov fp, #0x4000
	sub fp, fp, ip
	mov sp, fp

	cmp r0, #0                                @ If Core is Zero
	moveq r1, #0x8000
	blxeq r1

	/**
	 * Caution! Multi-core seems to share memories in privileged mode only.
	 * So, If you use Multi-core, you need to have secure process to treat this.
	 */

	_el01_reset_loop:
		bl arm32_core_handle
		b _el01_reset_loop


_el01_undefined_instruction:
	_el01_undefined_instruction_loop:
		b _el01_undefined_instruction_loop
	movs pc, lr


_el01_svc:
	movs pc, lr


_el01_prefetch_abort:
	_el01_prefetch_abort_loop:
		b _el01_prefetch_abort_loop
	subs pc, lr, #4


_el01_data_abort:
	_el01_data_abort_loop:
		b _el01_data_abort_loop
	subs pc, lr, #8


_el01_irq:
	subs pc, lr, #4


_el01_fiq:
	subs pc, lr, #4
