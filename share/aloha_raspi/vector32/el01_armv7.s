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

.ifndef __SECURE

	push {r0-r3}
	mov r0, #1
	mov r1, #equ32_ttbr_inner_wb_wa|equ32_ttbr_outer_wb_wa
	bl arm32_activate_va
	pop {r0-r3}

	push {r0-r3}
	mov r0, #2                                @ L2
	mov r1, #0                                @ Invalidate
	bl arm32_cache_operation_all
	pop {r0-r3}

	push {r0-r3}
	mov r0, #1                                @ L1
	mov r1, #0                                @ Invalidate
	bl arm32_cache_operation_all
	pop {r0-r3}

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
	mcr p15, 0, r0, c1, c0, 1                 @ Writeable on Non-Secure only on [6]SMP, if NS_SMP of NSACR is Set
	macro32_dsb ip
.endif

	macro32_multicore_id r0

.endif

	cmp r0, #0                                @ If Core is Zero
	moveq r1, #0x8000
	blxeq r1

	/**
	 * Caution! Multi-core seems to share memories in privileged mode only.
	 * So, If you use Multi-core, you need to have secure process to treat this.
	 */

	/**
	 * CPU Mode, Cache, and NEON/VFP Settings Similar to Process in os.s
	 * SP is not set on each vector except Supervisor mode, which has set sp.
	 */

	/* SVC Mode (Current), FIQ and IRQ Are Disabled, Aborts Are Enabled */
	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0
	mov r0, #equ32_fiq_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0
	mov r0, #equ32_irq_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0
	mov r0, #equ32_abt_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0
	mov r0, #equ32_und_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0
	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	/**
	 * Set Cache Status for Whole Area of Data Memory
	 */
	push {r0-r3}
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
.ifndef __SECURE
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, EL01_SYSTEM32_DATAMEMORY_ADDR
	ldr r2, [r2]
	ldr r3, EL01_SYSTEM32_DATAMEMORY_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	/**
	 * Set Cache Status for HEAP Area with Non-cache
	 * This area is used with peripheral blocks, etc.
	 */
	push {r0-r3}
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
.ifndef __SECURE
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, EL01_SYSTEM32_HEAP_NONCACHE_ADDR
	ldr r2, [r2]
	ldr r3, EL01_SYSTEM32_HEAP_NONCACHE_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	/**
	 * Set Cache Status for Memory with Non-cache
	 * This area is used with peripheral blocks, etc.
	 */
	push {r0-r3}
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
.ifndef __SECURE
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, EL01_SYSTEM32_NONCACHE_ADDR
	ldr r2, [r2]
	ldr r3, EL01_SYSTEM32_NONCACHE_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	/**
	 * Set Cache Status for Virtual Address Descriptor
	 */
	push {r0-r3}
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_r
.ifndef __SECURE
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, EL01_ARM32_VADESCRIPTOR_ADDR
	ldr r2, [r2]
	ldr r3, EL01_ARM32_VADESCRIPTOR_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	macro32_dsb ip
	macro32_invalidate_tlb_all ip
	macro32_dsb ip
	macro32_isb ip
	macro32_dsb ip
	macro32_invalidate_instruction_all ip
	macro32_isb ip

	/* Coprocessor Access Control Register (CPACR) For Floating Point and NEON (SIMD) */

	/**
	 * 20-21 Bits for CP 10, 22-23 Bits for CP 11
	 * Each 0b01 is for Enable in Previlege Mode
	 * Each 0b11 is for Enable in Previlege and User Mode
	 */
	mov r0, #0b1111
	lsl r0, r0, #20

	mcr p15, 0, r0, c1, c0, 2                 @ CPACR

	macro32_dsb ip
	macro32_isb ip                            @ Must Need When You Renew CPACR

	vmrs r0, fpexc                            @ Floating-point Exception Control Register
	orr r0, r0, #0x40000000                   @ Enable NEON/VFP
	vmsr fpexc, r0

	vmrs r0, fpscr                            @ Floating-point Status and Control Register
	orr r0, r0, #0x03000000                   @ Enable flush-to-zero mode (Becomes No IEEE-754 Compatible) and DN
	vmsr fpscr, r0

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


EL01_SYSTEM32_DATAMEMORY_ADDR:    .word SYSTEM32_DATAMEMORY_ADDR
EL01_SYSTEM32_DATAMEMORY_SIZE:    .word SYSTEM32_DATAMEMORY_SIZE
EL01_SYSTEM32_HEAP_NONCACHE_ADDR: .word SYSTEM32_HEAP_NONCACHE_ADDR
EL01_SYSTEM32_HEAP_NONCACHE_SIZE: .word SYSTEM32_HEAP_NONCACHE_SIZE
EL01_SYSTEM32_NONCACHE_ADDR:      .word SYSTEM32_NONCACHE_ADDR
EL01_SYSTEM32_NONCACHE_SIZE:      .word SYSTEM32_NONCACHE_SIZE
EL01_ARM32_VADESCRIPTOR_ADDR:     .word ARM32_VADESCRIPTOR_ADDR
EL01_ARM32_VADESCRIPTOR_SIZE:     .word ARM32_VADESCRIPTOR_SIZE
