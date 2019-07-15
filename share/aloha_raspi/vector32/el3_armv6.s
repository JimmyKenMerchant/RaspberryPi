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
_el3_monitor_addr:               .word _el3_monitor
_el3_prefetch_abort_addr:        .word _el3_prefetch_abort
_el3_data_abort_addr:            .word _el3_data_abort
_el3_irq_addr:                   .word _el3_irq
_el3_fiq_addr:                   .word _el3_fiq

_el3_monitor:

	mov sp, #0x6000

	/* Clear Heap to All Zero */
	push {r0-r3,lr}
	bl heap32_clear_heap
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa
	orr r0, r0, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_r
	orr r0, r0, #equ32_mmu_domain00
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_r
	orr r1, r1, #equ32_mmu_section_nonsecure
	orr r1, r1, #equ32_mmu_domain00
	bl arm32_lineup_basic_va
	pop {r0-r3,lr}

	/**
	 * Set Cache Status for VideoCore Memory for Framebuffer (By Section)
	 * VideoCore seems to connect with ARM closely, `shareable` attribute is not needed, so far.
	 * In RasPi 2 and Later, descriptors on the range of Framebuffer should not be changed after calling a framebuffer
	 * if you set fixup.dat to make a partition on SDRAM between CPU and GPU.
	 * Otherwise, malfunctions on accessing memory occur.
	 */
	push {r0-r3,lr}
	mov r0, #0
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_domain00
	mov r2, #equ32_vcmemory_base
	mov r3, #equ32_vcmemory_size
	bl arm32_set_cache
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #0
	/* On ARMv6, Bit[6] is SBZ and Inner Cache Indicator is Only Bit[0] */
	mov r1, #equ32_ttbr_inner_wt|equ32_ttbr_outer_wb_wa
	bl arm32_activate_va
	pop {r0-r3,lr}

	/* Invalidate Entire Data Cache, Instruction Cache, and Flush Branch Target Cache */
	macro32_invalidate_both_all ip            @ Invalidate Entire 

	macro32_dsb ip                            @ Ensure Completion of Instructions Before

	mrc p15, 0, r0, c1, c0, 0                 @ System Control Register (SCTLR)
	orr r0, r0, #0b101                        @ Enable Data Cache Bit[2] and (EL0 and EL1)MMU Bit[0]
	orr r0, r0, #0b0001100000000000           @ Enable Instruction L1 Cache Bit[12] and Branch Prediction Bit[11]
	orr r0, r0, #0x00800000                   @ Enable XP Bit[23], Extended Page Tables for Execute Never (XN) Bit, etc.
	mcr p15, 0, r0, c1, c0, 0                 @ Banked by Secure/Non-secure

	macro32_dsb ip                            @ Ensure Completion of Instructions Before
	macro32_isb ip                            @ Flush Instructions in Pipelines

	/**
	 * On ARMv6 (1176jzf-s), Secure-state stays afterward,
	 * Because on ARMv6, Non-secure state has not yet gotten popularity.
	 * Between Secure and Non-secure, it seems to have several differences, such as operations to entire cache.
	 *
	 * Each ACTLR (Auxiliary Control Register) on ARMv6, ARMv7, and ARMv8 have many differences on bits.
	 * Even between architectures in the same genaration, ACTLR may have differences on bits.
	 */

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
