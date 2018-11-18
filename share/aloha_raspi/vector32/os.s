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

	/* SVC Mode (Current), FIQ and IRQ Are Disabled, Aborts Are Enabled */
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

	/* Get ARM Memory Informations */
	push {r0-r3}
	bl bcm32_get_armmemory
	pop {r0-r3}

	/* Get VideoCore Memory Informations */
	push {r0-r3}
	bl bcm32_get_vcmemory
	pop {r0-r3}

	push {r0-r3}
	bl os_reset
	pop {r0-r3}

	/* Set Cache Status for Whole Area of Data Memory */
	push {r0-r3}
.ifndef __ARMV6
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
.ifndef __ARMV6
.ifndef __SECURE
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
.endif
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
.ifndef __ARMV6
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
.ifndef __ARMV6
.ifndef __SECURE
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
.endif
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
.ifndef __ARMV6
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
.ifndef __ARMV6
.ifndef __SECURE
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
.endif
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
.ifndef __ARMV6
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_r
.ifndef __ARMV6
.ifndef __SECURE
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
.endif
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_ARM32_VADESCRIPTOR_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_ARM32_VADESCRIPTOR_SIZE
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

	/**
	 * Denormalized (Subnormalized) number on float-point makes Undefined Exception (Recognized on ARMv6).
	 * To hide this in VFP (Non-NEON for ARMv6), turn on flush-to-zero mode for output operand (FPSCR FZ Bit[24]),
	 * plus turn on default NaN enable (FPSCR DN Bit[25]).
	 * and turn on IDC Flag for input operand (FPSCR IDC Bit[7]). ID means Input Denormal.
	 * If IDE Bit[15] is set, the exception occurs.
	 * Note that if you use flush-to-zero mode, underflow exception (UF) will not occur and minus zero will not be set,
	 * and no IEEE-754 compatible. NEON (from ARMv7) turns on flush-to-zero and default NaN enable forcefully.
	 */
	vmrs r0, fpscr                            @ Floating-point Status and Control Register
	orr r0, r0, #0x03000000                   @ Enable flush-to-zero mode (Becomes No IEEE-754 Compatible) and DN
	vmsr fpscr, r0

	/**
	 * Debug by SVC mode
	 */
.ifdef __DEBUG
	push {r0-r3}
	bl os_debug
	pop {r0-r3}
.endif

	mov r0, #equ32_user_mode                  @ Switch from SVC Mode to User Mode; Enable FIQ, IRQ, and Aborts
	msr cpsr_c, r0

	ldr ip, ADDR32_SYSTEM32_STACKPOINTER
	mov sp, ip

	push {r1-r3}
	bl _user_start
	pop {r1-r3}

	ldr r1, _os_reset_remark_addr
	macro32_print_string r1 0 0 22
	macro32_debug r0, 0, 12
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

_os_reset_remark_addr: .word _os_reset_remark
_os_reset_remark:     .ascii "\x1B[0mOS End With Value:\0"
.balign 4


_os_undefined_instruction:
	ldr r0, _os_undefined_instruction_remark_addr
	macro32_print_string r0 0 0 29
	macro32_debug lr, 0, 12
	_os_undefined_instruction_loop:
		b _os_undefined_instruction_loop

_os_undefined_instruction_remark_addr: .word _os_undefined_instruction_remark
_os_undefined_instruction_remark:      .ascii "\x1B[0mUndefined Instruction At:\0"
.balign 4


_os_svc:
	cpsie ai                                 @ Enable IRQ and Aborts, FIQ Is Automatically Enabled (Effective Only for One Time)
	push {lr}                                @ Push fp and lr
	ldr ip, [lr, #-4]                        @ Load SVC Instruction
	bic ip, #0xFF000000                      @ Immediate Bit[23:0]
	cmp ip, #0x47                            @ Prevent Overflow SVC Table
	bhi _os_svc_common
	lsl ip, ip, #3                           @ Substitution of Multiplication by 8
	add pc, pc, ip

	/* PC indicates the current insturction + 8 Bytes (32-bit ARM) */

	_os_svc_offset: .word 0x00

	_os_svc_0:
		mov r0, r0
		b _os_svc_common

	_os_svc_0x01:
		mov r0, r0
		b _os_svc_common

	_os_svc_0x02:
		bl bcm32_display_off
		b _os_svc_common

	_os_svc_0x03:
		bl fb32_flush_doublebuffer
		b _os_svc_common

	_os_svc_0x04:
		bl fb32_set_doublebuffer
		b _os_svc_common

	_os_svc_0x05:
		bl fb32_attach_buffer
		b _os_svc_common

	_os_svc_0x06:
		bl arm32_stopwatch_start
		b _os_svc_common

	_os_svc_0x07:
		bl arm32_stopwatch_end
		b _os_svc_common

	_os_svc_0x08:
		bl arm32_sleep
		b _os_svc_common

	_os_svc_0x09:
		bl arm32_random
		b _os_svc_common

	_os_svc_0x0A:
		bl arm32_store_8
		b _os_svc_common

	_os_svc_0x0B:
		bl arm32_load_8
		b _os_svc_common

	_os_svc_0x0C:
		bl arm32_store_16
		b _os_svc_common

	_os_svc_0x0D:
		bl arm32_load_16
		b _os_svc_common

	_os_svc_0x0E:
		bl arm32_store_32
		b _os_svc_common

	_os_svc_0x0F:
		bl arm32_load_32
		b _os_svc_common

	_os_svc_0x10:
		bl arm32_timestamp
		b _os_svc_common

	_os_svc_0x11:
		bl arm32_armtimer
		b _os_svc_common

	_os_svc_0x12:
		bl arm32_armtimer_reload
		b _os_svc_common

	_os_svc_0x13:
		bl arm32_armtimer_load
		b _os_svc_common

	_os_svc_0x14:
		bl arm32_clockmanager
		b _os_svc_common

	_os_svc_0x15:
		bl arm32_clockmanager_divisor
		b _os_svc_common

	_os_svc_0x16:
		bl clk32_calender_init
		b _os_svc_common

	_os_svc_0x17:
		bl clk32_clock_init
		b _os_svc_common

	_os_svc_0x18:
		bl clk32_correct_utc
		b _os_svc_common

	_os_svc_0x19:
		bl clk32_get_time
		b _os_svc_common

	_os_svc_0x1A:
		bl clk32_set_time
		b _os_svc_common

	_os_svc_0x1B:
		bl snd32_sounddecode
		b _os_svc_common

	_os_svc_0x1C:
		bl snd32_soundset
		b _os_svc_common

	_os_svc_0x1D:
		bl snd32_soundplay
		b _os_svc_common

	_os_svc_0x1E:
		bl snd32_soundinterrupt
		b _os_svc_common

	_os_svc_0x1F:
		bl snd32_soundclear
		b _os_svc_common

	_os_svc_0x20:
		bl sts32_synthewave_pwm
		b _os_svc_common

	_os_svc_0x21:
		bl sts32_synthewave_i2s
		b _os_svc_common

	_os_svc_0x22:
		bl sts32_syntheset
		b _os_svc_common

	_os_svc_0x23:
		bl sts32_syntheplay
		b _os_svc_common

	_os_svc_0x24:
		bl sts32_syntheclear
		b _os_svc_common

	_os_svc_0x25:
		bl sts32_synthemidi
		b _os_svc_common

	_os_svc_0x26:
		bl sts32_synthemidi_envelope
		b _os_svc_common

	_os_svc_0x27:
		bl gpio32_gpioplay
		b _os_svc_common

	_os_svc_0x28:
		bl gpio32_gpioset
		b _os_svc_common

	_os_svc_0x29:
		bl gpio32_gpioclear
		b _os_svc_common

	_os_svc_0x2A:
		bl gpio32_gpiotoggle
		b _os_svc_common

	_os_svc_0x2B:
		bl gpio32_gpiomode
		b _os_svc_common

	_os_svc_0x2C:
		bl gpio32_gpioevent
		b _os_svc_common

	_os_svc_0x2D:
		bl gpio32_gpiopull
		b _os_svc_common

	_os_svc_0x2E:
		bl pwm32_pwmplay
		b _os_svc_common

	_os_svc_0x2F:
		bl pwm32_pwmset
		b _os_svc_common

	_os_svc_0x30:
		bl pwm32_pwmclear
		b _os_svc_common

	_os_svc_0x31:
		bl pwm32_pwmselect
		b _os_svc_common

	_os_svc_0x32:
		bl uart32_uartinit
		b _os_svc_common

	_os_svc_0x33:
		bl uart32_uartsettest
		b _os_svc_common

	_os_svc_0x34:
		bl uart32_uarttestwrite
		b _os_svc_common

	_os_svc_0x35:
		bl uart32_uarttestread
		b _os_svc_common

	_os_svc_0x36:
		bl uart32_uartsetint
		b _os_svc_common

	_os_svc_0x37:
		bl uart32_uartint
		b _os_svc_common

	_os_svc_0x38:
		bl uart32_uartclrint
		b _os_svc_common

	_os_svc_0x39:
		bl uart32_uarttx
		b _os_svc_common

	_os_svc_0x3A:
		bl uart32_uartrx
		b _os_svc_common

	_os_svc_0x3B:
		bl uart32_uartclrrx
		b _os_svc_common

	_os_svc_0x3C:
		bl uart32_uartsetheap
		b _os_svc_common

	_os_svc_0x3D:
		bl uart32_uartclient
		b _os_svc_common

	_os_svc_0x3E:
		bl usb2032_otg_host_reset_bcm
		b _os_svc_common

	_os_svc_0x3F:
		bl usb2032_hub_activate
		b _os_svc_common

	_os_svc_0x40:
		bl usb2032_hub_search_device
		b _os_svc_common

	_os_svc_0x41:
		bl hid32_hid_activate
		b _os_svc_common

	_os_svc_0x42:
		bl hid32_hid_setidle
		b _os_svc_common

	_os_svc_0x43:
		bl hid32_keyboard_get
		b _os_svc_common

	_os_svc_0x44:
		bl rom32_romread_i2c
		b _os_svc_common

	_os_svc_0x45:
		bl rom32_romwrite_i2c
		b _os_svc_common

	_os_svc_0x46:
		bl softuart32_softuartrx
		b _os_svc_common

	_os_svc_0x47:
		bl softuart32_softuarttx
		b _os_svc_common

	_os_svc_common:
		pop {lr}                         @ Pop lr
		movs pc, lr


_os_prefetch_abort:
	ldr r0, _os_prefetch_abort_remark_addr
	macro32_print_string r0 0 0 22
	sub lr, lr, #4                           @ lr is Incremented by 4
	macro32_debug lr, 0, 12
	_os_prefetch_abort_loop:
		b _os_prefetch_abort_loop

_os_prefetch_abort_remark_addr: .word _os_prefetch_abort_remark
_os_prefetch_abort_remark:      .ascii "\x1B[0mPrefetch Abort At:\0"
.balign 4


_os_data_abort:
	ldr r0, _os_data_abort_remark_addr
	macro32_print_string r0 0 0 18
	sub lr, lr, #8                           @ lr is Incremented by 8
	macro32_debug lr, 0, 12
	_os_data_abort_loop:
		b _os_data_abort_loop

_os_data_abort_remark_addr: .word _os_data_abort_remark
_os_data_abort_remark:      .ascii "\x1B[0mData Abort At:\0"
.balign 4


_os_irq:
	/*cpsid i*/                                  @ Disable IRQ(i) Automatically (IRQ Will be Disabled on Every Exceptions)
	cpsie a                                      @ Enable Aborts (Effective Only for One Time)
	push {lr}

	/*push {r0-r12,lr}*/                         @ Equals to stmfd (stack pointer full, decrement order)

	bl os_irq

	/*pop {r0-r12,lr}*/                          @ Equals to ldmfd (stack pointer full, decrement order)

	pop {lr}
	subs pc, lr, #4


_os_fiq:
	/*cpsid fi*/                                 @ Disable FIQ(f) and IRQ(i) Automatically
	cpsie a                                      @ Enable Aborts (Effective Only for One Time)
	push {lr}

	/*push {r0-r7,lr}*/                          @ Equals to stmfd (stack pointer full, decrement order)
	/*mrs r0, spsr*/                             @ No Need of Save Status Flags in Interrupts of ARM
	/*push {r0}*/

	bl os_fiq

	/*pop {r0}*/
	/*msr spsr, r0*/                             @ No Need of Load Status Flags in Interrupts of ARM
	/*pop {r0-r7,lr}*/                           @ Equals to ldmfd (stack pointer full, decrement order)

	pop {lr}
	subs pc, lr, #4
