/**
 * el3_armv7.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.section	.el3_vector32
/*MVBAR (EL3) */
	_el3_reserve0: .word 0x00
	_el3_reserve1: .word 0x00
	ldr pc, _el3_monitor_addr                  @ 0x08 Secure Monitor mode by `SMC` (MVBAR)
	ldr pc, _el3_prefetch_abort_addr           @ 0x0C Abort mode (MVBAR), if Set on Secure Configuration Register (SCR)
	ldr pc, _el3_data_abort_addr               @ 0x10 Abort mode (MVBAR), if Set on Secure Configuration Register (SCR)
	_el3_reserve2: .word 0x00
	ldr pc, _el3_irq_addr                      @ 0x18 IRQ mode (MVBAR), if Set on Secure Configuration Register (SCR)
	ldr pc, _el3_fiq_addr                      @ 0x1C FIQ mode (MVBAR), if Set on Secure Configuration Register (SCR)
_el3_monitor_addr:               .word _el3_monitor
_el3_prefetch_abort_addr:        .word _el3_prefetch_abort
_el3_data_abort_addr:            .word _el3_data_abort
_el3_irq_addr:                   .word _el3_irq
_el3_fiq_addr:                   .word _el3_fiq

_el3_monitor:
	macro32_multicore_id r0

	mov ip, #0x200                            @ Offset 0x200 Bytes (128 Words) per Core
	mul ip, ip, r0
	mov fp, #0x6000
	sub fp, fp, ip
	mov sp, fp

	/* SMP Enable, Before Cache and MMU Enable */
.ifdef __ARMV8
	mrrc p15, 1, r0, r1, c15                  @ CPU Extended Control Register (CPUECTLR) 64-bit
	orr r0, r0, #0b01000000                   @ SMPEN Bit[6], SMP Enable
	mcrr p15, 1, r0, r1, c15
	macro32_dsb ip
.endif

	/* Clear Heap to All Zero */
	push {r0-r3,lr}
	bl heap32_clear_heap
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #equ32_mmu_section|equ32_mmu_section_inner_none
	orr r0, r0, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_r
	orr r0, r0, #equ32_mmu_domain00
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_r
	orr r1, r1, #equ32_mmu_section_nonsecure
	orr r1, r1, #equ32_mmu_domain00
	bl arm32_lineup_basic_va
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #0
	mov r1, #equ32_ttbr_inner_none|equ32_ttbr_outer_none
	bl arm32_activate_va
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #1                                @ L1
	mov r1, #0                                @ Invalidate
	bl arm32_cache_operation_all
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #2                                @ L2
	mov r1, #0                                @ Invalidate
	bl arm32_cache_operation_all
	pop {r0-r3,lr}

	/* Invalidate Entire Instruction Cache and Flush Branch Target Cache */
	macro32_invalidate_instruction_all ip

	macro32_dsb ip                            @ Ensure Completion of Instructions Before

	mrc p15, 0, r0, c1, c0, 0                 @ System Control Register (SCTLR)
	orr r0, r0, #0b101                        @ Enable Data Cache Bit[2] and (EL0 and EL1)MMU Bit[0]
	orr r0, r0, #0b0001100000000000           @ Enable Instruction L1 Cache Bit[12] and Branch Prediction Bit[11]
	mcr p15, 0, r0, c1, c0, 0                 @ Banked by Secure/Non-secure

	macro32_dsb ip                            @ Ensure Completion of Instructions Before
	macro32_isb ip                            @ Flush Instructions in Pipelines

.ifndef __ARMV8
	mrc p15, 0, r0, c1, c0, 1                 @ Auxiliary Control Register (ACTLR)
	orr r0, r0, #0b01000000                   @ Enable SMP Bit[6] (Symmetric Multi Processing), Shares Memory on Each Core,
                                                  @ And This Bit is deprecated on Cortex-A53 (ARMv8)
	mcr p15, 0, r0, c1, c0, 1                 @ Common on Secure/Non-secure, Writeable on Secure
	macro32_dsb ip
.endif

	movs pc, lr                               @ Return to SVC Mode


_el3_prefetch_abort:
	_el3_prefetch_abort_loop:
		b _el3_prefetch_abort_loop
	subs pc, lr, #4


_el3_data_abort:
	_el3_data_abort_loop:
		b _el3_data_abort_loop
	subs pc, lr, #8


_el3_irq:
	subs pc, lr, #4


_el3_fiq:
	subs pc, lr, #4
