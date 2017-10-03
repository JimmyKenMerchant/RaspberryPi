/**
 * el3_armv6.s
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
_el3_monitor_addr:               .word _el3_mon
_el3_prefetch_abort_addr:        .word _el01_reset
_el3_data_abort_addr:            .word _el01_reset
_el3_irq_addr:                   .word _el01_reset
_el3_fiq_addr:                   .word _el01_reset

_el3_mon:

	mov sp, #0x6000

	push {r0-r3,lr}
	mov r0, #equ32_mmu_section|equ32_mmu_section_inner_none
	orr r0, r0, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
	orr r0, r0, #equ32_mmu_domain00
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_nonsecure|equ32_mmu_section_shareable
	orr r1, r1, #equ32_mmu_domain00
	bl system32_lineup_basic_va
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #0
	/* On ARMv6, Bit[6] is SBZ and Inner Cache Indicator is Only Bit[0] */
	mov r1, #equ32_ttbr_inner_wt|equ32_ttbr_outer_wb_wa
	bl system32_activate_va
	pop {r0-r3,lr}

	mov r0, #0
	mcr p15, 0, r0, c7, c6, 0                 @ Invalidate Entire Data Cache

	macro32_dsb ip

	mrc p15, 0, r0, c1, c0, 0                 @ System Control Register (SCTLR)
	orr r0, r0, #0b101                        @ Enable Data Cache Bit[2] and (EL0 and EL1)MMU Bit[0]
	orr r0, r0, #0b0001100000000000           @ Enable Instruction L1 Cache Bit[12] and Branch Prediction Bit[11]
	mcr p15, 0, r0, c1, c0, 0                 @ Banked by Secure/Non-secure
	macro32_isb ip                            @ Flush Instructions in Pipelines

	/* Invalidate Entire Instruction Cache and Flush Branch Target Cache */
	macro32_invalidate_instruction ip

	/**
	 * Between ARMV6 and ARMV7+, Diffrences on ACTLR Are There
	 */

	/**
	 * Between ARMV6 and ARMV7+, Diffrences on NSACR Are There
	 * Enable Cache Lockdown Registers in Non-secure state CL[16] in ARMV6
	 * Enable TLB Lockdown Registers in Non-secure state TL[17] in ARMV6
	 * Enable Enable DMA in Non-secure State Bit[18]
	 */

	movs pc, lr                               @ Return to SVC Mode
