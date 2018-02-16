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
	ldr pc, _os_reset_addr                    @ 0x00 User/System Mode SP SYSTEM32_STACKPOINTER
	ldr pc, _os_undefined_instruction_addr    @ 0x04 SP 0x7200
	ldr pc, _os_supervisor_addr               @ 0x08 SP 0x7400
	ldr pc, _os_prefetch_abort_addr           @ 0x0C SP 0x7600
	ldr pc, _os_data_abort_addr               @ 0x10 SP 0x7600
	ldr pc, _os_reserve_addr
	ldr pc, _os_irq_addr                      @ 0x18 SP 0x7800
	ldr pc, _os_fiq_addr                      @ 0x1C SP 0x8000
_os_reset_addr:                 .word _os_reset
_os_undefined_instruction_addr: .word _os_undefined_instruction
_os_supervisor_addr:            .word _os_svc
_os_prefetch_abort_addr:        .word _os_prefetch_abort
_os_data_abort_addr:            .word _os_data_abort
_os_reserve_addr:               .word _os_reset
_os_irq_addr:                   .word _os_irq
_os_fiq_addr:                   .word _os_fiq

_os_reset:
	/*
	mov r0, sp                                @ Store Previous Stack Pointer
	mrc p15, 0, r1, c12, c0, 0                @ Last VBAR Address to Retrieve
	mov sp, #0x7400                           @ Stack Pointer to 0x7400 for SVC mode
                                                  @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)
	push {r0-r1,lr}
	*/

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

	push {r0-r3}
	bl os_reset
	pop {r0-r3}

	/**
	 * Set Cache Status for Memory Using as Framebuffer (By Section)
	 * VideoCore seemes to connect with ARM closely, but make sure to add `shareable` attribute just in case.
	 */
	push {r0-r3}
	mov r0, #0
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_shareable
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_FB32_FRAMEBUFFER_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_FB32_FRAMEBUFFER_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	/* Set Cache Status for Whole Area of Data Memory */
	push {r0-r3}
	mov r0, #0
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_shareable
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_DATAMEMORY_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_DATAMEMORY_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	/**
	 * Set Cache Status for HEAP with Non-cache
	 * Non-cache HEAP is used for peripheral blocks.
	 * To ensure that data is stored in physical main memory, add `shareable` attribute.
	 */
	push {r0-r3}
	mov r0, #0
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_shareable
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_HEAP_NONCACHE_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_HEAP_NONCACHE_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	/**
	 * Set Cache Status for Memory with Non-cache
	 * Non-cache memory is used for peripheral blocks.
	 * To ensure that data is stored in physical main memory, add `shareable` attribute.
	 */
	push {r0-r3}
	mov r0, #0
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_shareable
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_NONCACHE_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_NONCACHE_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	/* Set Cache Status for Virtual Address Descriptor */
	push {r0-r3}
	mov r0, #0
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_r
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_ARM32_VADESCRIPTOR_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_ARM32_VADESCRIPTOR_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3}

	macro32_dsb ip
	macro32_invalidate_tlb_all ip
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

	/**
	 * Denormalized (Subnormalized) number on float-point makes Undefined Exception (Recognized on ARMv6).
	 * To hide this in VFP, turn on flush-to-zero mode for output operand (FPSCR FZ Bit[24]),
	 * and turn on IDC Flag for input operand (FPSCR IDC Bit[7]). ID means Input Denormal.
	 * If IDE Bit[15] is set, the exception occurs. 
	 */
	vmrs r0, fpscr                            @ Floating-point Status and Control Register
	orr r0, r0, #0x01000000                   @ Enable flush-to-zero mode (Becomes No IEEE-754 Compatible)
	vmsr fpscr, r0

	/**
	 * Debug by SVC mode
	 */
.ifdef __DEBUG
	push {r0-r3}
	bl os_debug
	pop {r0-r3}
.endif

	mov r0, #equ32_user_mode                  @ Enable FIQ, IRQ, and Abort
	msr cpsr_c, r0

	ldr ip, ADDR32_SYSTEM32_STACKPOINTER
	mov sp, ip

	push {r1-r3}
	bl _user_start
	pop {r1-r3}

	macro32_debug r0, 120, 120
	_os_reset_loop:
		b _os_reset_loop

	/* We are in user mode, so we can't back to SVC mode by setting CPSR */

	/*
	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0
	mov fp, #0x7400                          @ Retrieve Previous Stack Pointer (SP), VBAR,and Link Register
	ldr r0, [fp, #-12]                       @ SP
	ldr r1, [fp, #-8]                        @ VBAR
	ldr lr, [fp, #-4]                        @ Link Register
	mov sp, r0                               @ Retrieve SP
	mcr p15, 0, r1, c12, c0, 0               @ Retrieve VBAR Address
	mov pc, lr
	*/


_os_undefined_instruction:
	macro32_debug lr, 0, 0
	_os_undefined_instruction_loop:
		b _os_undefined_instruction_loop


_os_svc:
	push {lr}                                @ Push fp and lr
	ldr ip, [lr, #-4]                        @ Load SVC Instruction
	bic ip, #0xFF000000                      @ Immediate Bit[23:0]
	cmp ip, #0xF                             @ Prevent Overflow SVC Table
	bhi _os_svc_common
	lsl ip, ip, #3                           @ Substitution of Multiplication by 8
	add pc, pc, ip

	/* PC indicates the current insturction + 8 Bytes (32-bit ARM) */

	_os_svc_offset: .word 0x00

	_os_svc_0:
		mov r0, r0
		b _os_svc_common

	_os_svc_0x1:
		bl fb32_flush_doublebuffer
		b _os_svc_common

	_os_svc_0x2:
		bl fb32_set_doublebuffer
		b _os_svc_common

	_os_svc_0x3:
		bl fb32_attach_buffer
		b _os_svc_common

	_os_svc_0x4:
		bl arm32_stopwatch_start
		b _os_svc_common

	_os_svc_0x5:
		bl arm32_stopwatch_end
		b _os_svc_common

	_os_svc_0x6:
		bl arm32_sleep
		b _os_svc_common

	_os_svc_0x7:
		bl arm32_random
		b _os_svc_common

	_os_svc_0x8:
		bl arm32_store_32
		b _os_svc_common

	_os_svc_0x9:
		bl arm32_load_32
		b _os_svc_common

	_os_svc_0xA:
		bl snd32_sounddecode
		b _os_svc_common

	_os_svc_0xB:
		bl snd32_soundset
		b _os_svc_common

	_os_svc_0xC:
		bl snd32_soundinterrupt
		b _os_svc_common

	_os_svc_0xD:
		bl snd32_soundclear
		b _os_svc_common

	_os_svc_0xE:
		bl gpio32_gpioset
		b _os_svc_common

	_os_svc_0xF:
		bl gpio32_gpioclear
		b _os_svc_common

	_os_svc_common:
		pop {lr}                         @ Pop lr
		movs pc, lr


_os_prefetch_abort:
	macro32_debug lr, 0, 240
	_os_prefetch_abort_loop:
		b _os_prefetch_abort_loop


_os_data_abort:
	macro32_debug lr, 240, 240
	_os_data_abort_loop:
		b _os_data_abort_loop


_os_irq:
	/*cpsid i*/                                  @ Disable IRQ(i) Automatically (IRQ Will be Disabled on Every Exceptions)
	push {lr}

	/*push {r0-r12,lr}*/                         @ Equals to stmfd (stack pointer full, decrement order)

	bl os_irq

	/*pop {r0-r12,lr}*/                          @ Equals to ldmfd (stack pointer full, decrement order)
	pop {lr}
	/*cpsie i*/                                  @ Enable IRQ(i) Automatically by SPSR to CPSR

	subs pc, lr, #4


_os_fiq:
	/*cpsid fi*/                                 @ Disable FIQ(f) and IRQ(i) Automatically
	push {lr}

	/*push {r0-r7,lr}*/                          @ Equals to stmfd (stack pointer full, decrement order)
	/*mrs r0, spsr*/                             @ No Need of Save Status Flags in Interrupts of ARM
	/*push {r0}*/

	bl os_fiq

	/*pop {r0}*/
	/*msr spsr, r0*/                             @ No Need of Load Status Flags in Interrupts of ARM
	/*pop {r0-r7,lr}*/                           @ Equals to ldmfd (stack pointer full, decrement order)

	pop {lr}
	/*cpsie fi*/                                 @ Enable FIQ(f) and IRQ(i) Automatically by SPSR to CPSR

	subs pc, lr, #4
