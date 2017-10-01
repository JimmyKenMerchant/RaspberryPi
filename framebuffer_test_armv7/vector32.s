/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.include "system32/equ32.s"
.include "system32/macro32.s"

.section	.el01_vector32
.globl _start
_start:
/* VBAR (EL0 and EL1) */
	ldr pc, _el01_reset_addr                    @ 0x00 reset
	ldr pc, _el01_undefined_instruction_addr    @ 0x04 Undefined mode (Banks SP, LR, SPSR) `MOVS PC, LR`
	ldr pc, _el01_supervisor_addr               @ 0x08 Supervisor mode by `SVC` (SP, LR, SPSR) `MOVS PC, LR`
	ldr pc, _el01_prefetch_abort_addr           @ 0x0C Abort mode (SP, LR, SPSR) `SUBS PC, LR, #4`
	ldr pc, _el01_data_abort_addr               @ 0x10 Abort mode (SP, LR, SPSR) `SUBS PC, LR, #8`
	ldr pc, _el01_reserve_addr
	ldr pc, _el01_irq_addr                      @ 0x18 IRQ mode (SP, LR, SPSR) `SUBS PC, LR, #4`
	ldr pc, _el01_fiq_addr                      @ 0x1C FIQ mode (SP, LR, SPSR) `SUBS PC, LR, #4`
_el01_reset_addr:                 .word _el01_reset
_el01_undefined_instruction_addr: .word _el01_reset
_el01_supervisor_addr:            .word _el01_svc
_el01_prefetch_abort_addr:        .word _el01_reset
_el01_data_abort_addr:            .word _el01_reset
_el01_reserve_addr:               .word _el01_reset
_el01_irq_addr:                   .word _el01_reset
_el01_fiq_addr:                   .word _el01_reset

/* From Secure State SVC mode (EL1 Secure state) */
_el01_reset:
	mov r0, #0x0
	mcr p15, 0, r0, c12, c0, 0                @ VBAR(User Mode, EL0, and Privileged Mode, EL1), IVT Base Vector Address
	mov r0, #0x2000
	mcr p15, 0, r0, c12, c0, 1                @ MVBAR (Secure Monitor mode, EL3), IVT Base Vector Address

	smc #0

	macro32_multicore_id r0

	mov ip, #0x200                            @ Offset 0x200 Bytes per Core
	mul ip, ip, r0
	mov fp, #0x4000
	sub fp, fp, ip
	mov sp, fp

	push {r0-r3}
	mov r0, #1
	mov r1, #equ32_ttbr_inner_wb_wa|equ32_ttbr_outer_wb_wa
	bl system32_activate_va
	pop {r0-r3}

	push {r0-r3}
	mov r0, #1                                @ L1
	mov r1, #0
	bl system32_cache_operation_all
	pop {r0-r3}

	push {r0-r3}
	mov r0, #2                                @ L2
	mov r1, #0
	bl system32_cache_operation_all
	pop {r0-r3}

	macro32_dsb ip                            @ Ensure Completion of Instructions Before

	/* Invalidate Entire Instruction Cache and Flush Branch Target Cache */
	macro32_invalidate_instruction ip

	macro32_isb ip                            @ Flush Instructions in Pipelines

	mrc p15, 0, r0, c1, c0, 0                 @ System Control Register (SCTLR)
	orr r0, r0, #0b101                        @ Enable Data Cache[2] and MMU(EL0 and EL1)[0]
	orr r0, r0, #0b0001100000000000           @ Enable Instruction and Branch Target Chache
	mcr p15, 0, r0, c1, c0, 0                 @ Banked by Secure/Non-secure

	macro32_dsb ip

	mrc p15, 0, r0, c1, c0, 1                 @ Auxiliary Control Register (ACTLR)
	orr r0, r0, #0b01000000                   @ Enable [6]SMP (Symmetric Multi Processing), Shares Memory on Each Core
	mcr p15, 0, r0, c1, c0, 1                 @ Writeable on Non-Secure only on [6]SMP, if NS_SMP of NSACR is Set

	macro32_dsb ip

	macro32_multicore_id r0

	cmp r0, #0                                @ If Core is Zero
	moveq r0, #0x8000
	blxeq r0

	_el01_reset_loop:
		bl system32_core_handle
		b _el01_reset_loop


_el01_svc:

	movs pc, lr

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
	macro32_multicore_id r0

	mov ip, #0x800                            @ Offset 0x200 Bytes per Core
	mul ip, ip, r0
	mov fp, #0x6000
	sub fp, fp, ip
	mov sp, fp

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
	mov r1, #equ32_ttbr_inner_none|equ32_ttbr_outer_none
	bl system32_activate_va
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #1                                @ L1
	mov r1, #0
	bl system32_cache_operation_all
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #2                                @ L2
	mov r1, #0
	bl system32_cache_operation_all
	pop {r0-r3,lr}

	macro32_dsb ip                            @ Ensure Completion of Instructions Before

	/* Invalidate Entire Instruction Cache and Flush Branch Target Cache */
	macro32_invalidate_instruction ip

	macro32_isb ip                            @ Flush Instructions in Pipelines

	mrc p15, 0, r0, c1, c0, 0                 @ System Control Register (SCTLR)
	orr r0, r0, #0b101                        @ Enable Data Cache[2] and (EL0 and EL1)MMU[0]
	orr r0, r0, #0b0001100000000000           @ Enable Instruction and Branch Target Chache
	mcr p15, 0, r0, c1, c0, 0                 @ Banked by Secure/Non-secure

	macro32_dsb ip

	mrc p15, 0, r0, c1, c0, 1                 @ Auxiliary Control Register (ACTLR)
	orr r0, r0, #0b01000001                   @ Enable [6]SMP (Symmetric Multi Processing), Shares Memory on Each Core,
                                                  @ And Enable [0]FW, Cache and TLB Maintenance Broadcast (From ARMv8)
	mcr p15, 0, r0, c1, c0, 1                 @ Common on Secure/Non-secure, Writeable on Secure

	macro32_dsb ip

	mov r0, #0x0C00                           @ Enable VFP/NEON Access in Non-secure mode, Bit[10] is CP10, Bit[11] is CP11
	add r0, r0, #0x40000                      @ Enable NS_SMP (Non-secure SMP Enable in ACTLR), Bit[18]
	mcr p15, 0, r0, c1, c1, 2                 @ Non-secure Access Control Register (NSACR)

	macro32_dsb ip

	mov r0, #0x1                              @ NS Bit (Effective on EL0 and EL1)
	add r0, r0, #0x100                        @ HCE Bit (Hypervisor Call Enable)
	mcr p15, 0, r0, c1, c1, 0                 @ Change to Non-secure state, Secure Configuration Register (SCR)

	macro32_dsb ip

	/* Non-secure State Below */

	mov r0, #0x1000
	mcr p15, 4, r0, c12, c0, 0                @ Change HVBAR (Hypervisor Mode, EL2), IVT Base Vector Address

	macro32_dsb ip

	movs pc, lr                               @ Return to SVC Mode


/**
 * Vector Interrupt Tables and These Functions
 *
 * Mon mode banks SP, LR, SPSR and its unique IVT, MBAR.
 * Hyp mode banks SP, SPSR, ELR, but LR is shared with User and System mode.
 * BUT REMEBER, in HYP mode, banking registers is INVALID because of no mode change.
 */
.section	.os_vector32
.globl _os_start
_os_start:
	ldr pc, _os_reset_addr                    @ 0x00 reset
	ldr pc, _os_undefined_instruction_addr    @ 0x04 (Hyp mode in Hyp mode)
	ldr pc, _os_supervisor_addr               @ 0x08 (Hyp mode in Hyp mode)
	ldr pc, _os_prefetch_abort_addr           @ 0x0C (Hyp mode in Hyp mode)
	ldr pc, _os_data_abort_addr               @ 0x10 (Hyp mode in Hyp mode)
	ldr pc, _os_reserve_addr                  @ If you call `HVC` in Hyp Mode, It translates to `SVC`
	ldr pc, _os_irq_addr                      @ 0x18 (Hyp mode in Hyp mode)
	ldr pc, _os_fiq_addr                      @ 0x1C (Hyp mode in Hyp mode)
_os_reset_addr:                 .word _os_reset
_os_undefined_instruction_addr: .word _os_reset
_os_supervisor_addr:            .word _os_reset
_os_prefetch_abort_addr:        .word _os_reset
_os_data_abort_addr:            .word _os_reset
_os_reserve_addr:               .word _os_reset
_os_irq_addr:                   .word _os_reset
_os_fiq_addr:                   .word _os_fiq

_os_reset:
	mov r0, sp                                @ Store Previous Stack Pointer
	mrc p15, 0, r1, c12, c0, 0                @ Last VBAR Address to Retrieve
	mov sp, #0x8000                           @ Stack Pointer to 0x8000
                                                  @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)
	push {r0-r1,lr}

	/* SVC mode FIQ Disable and IRQ Disable, Current Mode */
	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov r0, #equ32_fiq_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov sp, #0x7000

	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov r0, #0x8000
	mcr p15, 0, r0, c12, c0, 0                @ Change VBAR, IVT Base Vector Address

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base

	mvn r1, #0                                       @ Whole Inverter

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                       @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0x95                             @ Decimal 149 to divide 240Mz by 150 to 1.6Mhz (Predivider is 10 Bits Wide)
	str r1, [r0, #equ32_armtimer_predivider]

	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	str r1, [r0, #equ32_armtimer_load]

	mov r1, #0x3E0000                         @ High 2 Bytes
	add r1, r1, #0b10100100                   @ Low 2 Bytes (00A4), Timer Enable and Timer Interrupt Enable, Prescaler 1/16 to 100K
	                                          @ 1/16 is #0b10100100, 1/256 is #0b10101000
	str r1, [r0, #equ32_armtimer_control]

	/* So We can get a 10hz Timer Interrupt (100000/10000) */

	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	mov r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 47 OUTPUT
	add r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4 @ Set GPIO 44 AlT0 (GPCLK1)
	str r1, [r0, #equ32_gpio_gpfsel40]

	/* Obtain Framebuffer from VideoCore IV */
	mov r0, #32
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	push {r0-r3}
	mov r0, r1
	mov r1, #1
	mov r2, #1
	bl system32_cache_operation
	pop {r0-r3}

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	push {r0-r3}
	mov r0, r1
	mov r1, #1
	mov r2, #1
	bl system32_cache_operation
	pop {r0-r3}

	push {r0-r3}
	bl bcm32_get_framebuffer
	pop {r0-r3}

	/* Set Cache Status for Memory Using as Framebuffer (By Section) */
	push {r0-r3}
	mov r0, #1
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_nonsecure
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_FB32_FRAMEBUFFER_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_FB32_FRAMEBUFFER_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3}

	/* Set Cache Status for HEAP */
	push {r0-r3}
	mov r0, #1
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_nonsecure
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_HEAP_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_HEAP_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3}

	/* Set Cache Status for Virtual Address Descriptor */
	push {r0-r3}
	mov r0, #1
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_nonsecure
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_VADESCRIPTOR_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_VADESCRIPTOR_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3}

	macro32_dsb ip
	macro32_invalidate_tlb ip
	macro32_isb ip
	macro32_dsb ip
	macro32_invalidate_instruction ip
	macro32_isb ip

	/* Clear Heap to All Zero */
	push {r0-r3}
	bl system32_clear_heap
	pop {r0-r3}

	/* Coprocessor Access Control Register (CPACR) For Floating Point and NEON (SIMD) */
	
	/**
	 * 20-21 Bits for CP 10, 22-23 Bits for CP 11
	 * Each 0b01 is for Enable in Previlege Mode
	 * Each 0b11 is for Enable in Previlege and User Mode
	 */
	mov r0, #0b0101
	lsl r0, r0, #20

	mcr p15, 0, r0, c1, c0, 2                 @ CPACR

	macro32_dsb ip
	macro32_isb ip                            @ Must Need When You Renew CPACR

	mov r0, #0x40000000                       @ Enable NEON/VFP
	vmsr fpexc, r0

_os_render:
	push {r0-r8}
	
	ldr r0, ADDR32_COLOR32_NAVYBLUE
	ldr r0, [r0]
	bl fb32_clear_color

	/* Core 3 */

	mov r0, #2
	bl system32_malloc                        @ Obtain Memory Space (2 Block Means 8 Bytes)
	ldr r1, core123_handler
	str r1, [r0]                              @ Store Pointer of Function to First of Heap Array
	mov r1, #0
	str r1, [r0, #4]                          @ Store Number of Arguments to Second of Heap Array
	push {r0-r3}
	mov r1, #3                                @ Indicate Number of Core
	bl system32_core_call
	pop {r0-r3}

	_os_render_loop2:
		ldr r1, ADDR32_SYSTEM32_CORE_HANDLE_3
		ldr r1, [r1]
		cmp r1, #0
		bne _os_render_loop2

	bl system32_mfree                         @ Clear Memory Space

	/* Core 3 */

	mov r0, #9
	bl system32_malloc                        @ Obtain Memory Space (2 Block Means 8 Bytes)
	ldr r1, core123_handler2
	str r1, [r0]                              @ Store Pointer of Function to First of Heap Array
	mov r1, #7
	str r1, [r0, #4]                          @ Store Number of Arguments to Second of Heap Array
	mov r1, #0x1
	str r1, [r0, #8]
	mov r1, #0x2
	str r1, [r0, #12]
	mov r1, #0x3
	str r1, [r0, #16]
	mov r1, #0x4
	str r1, [r0, #20]
	mov r1, #0x5
	str r1, [r0, #24]
	mov r1, #0x6
	str r1, [r0, #28]
	mov r1, #0x7
	str r1, [r0, #32]
	push {r0-r3}
	mov r1, #3                                @ Indicate Number of Core
	bl system32_core_call
	pop {r0-r3}

	_os_render_loop3:
		ldr r1, ADDR32_SYSTEM32_CORE_HANDLE_3
		ldr r1, [r1]
		cmp r1, #0
		bne _os_render_loop3

	push {r0-r3}
	mov r1, #1
	mov r2, #0                                @ Invalidate Memory Space Cache to Obtain Return from Other Core
	bl system32_cache_operation
	pop {r0-r3}

	ldr r1, [r0]

macro32_debug r1 500 500

	bl system32_mfree                         @ Clear Memory Space

	ldr r0, string_hello                      @ Pointer of Array of String
	ldr r1, ADDR32_COLOR32_GREEN              @ Color (16-bit or 32-bit)
	ldr r1, [r1]
	ldr r2, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r2, [r2]
	ldr r3, ADDR32_FONT_MONO_12PX_ASCII       @ Font
	ldr r3, [r3]
	macro32_print_string r0 0 0 r1 r2 100 8 12 r3

	ldr r0, string_test                       @ Pointer of Array of String
	macro32_print_string r0 0 100 r1 r2 100 8 12 r3

	push {r1-r3}
	ldrb r0, core0
	ldrb r1, core1
	ldrb r2, core2
	ldrb r3, core3
	add r0, r0, r1
	add r0, r0, r2
	add r0, r0, r3
	pop {r1-r3}

	macro32_print_number r0 0 136 r1 r2 100 8 12 r3

	mov r0, #0x3
	mov r1, #0x1
	bl bcm32_set_powerstate

macro32_debug r0 500 90

	bl usb2032_otg_host_start

macro32_debug r0 500 102

	mov r1, #equ32_peripherals_base
	add r1, r1, #equ32_usb20_otg_base
	ldr r0, [r1, #equ32_usb20_otg_ghwcfg2]

macro32_debug r0 500 114

	mov r0, #2
	bl usb2032_hub_activate

macro32_debug r0 500 126

	mov r1, #equ32_peripherals_base
	add r1, r1, #equ32_cm_base_lower
	add r1, r1, #equ32_cm_base_upper
	ldr r0, [r1, #equ32_cm_pwmctl]

macro32_debug r0 500 150

	ldr r0, [r1, #equ32_cm_pwmdiv]

macro32_debug r0 500 162

	mov r1, #equ32_peripherals_base
	add r1, r1, #equ32_gpio_base
	ldr r0, [r1, #equ32_gpio_gpfsel40]

macro32_debug r0 500 174

	pop {r0-r8}

	cpsie f

	push {r0-r3}
	bl _user_start
	pop {r0-r3}

	mov fp, #0x8000                          @ Retrieve Previous Stack Pointer, VBAR,and Link Register
	ldr r0, [fp, #-8]                        @ Stack Pointer
	ldr r1, [fp, #-4]                        @ Stack Pointer
	ldr lr, [fp]                             @ Link Register
	mov sp, r0
	mcr p15, 0, r1, c12, c0, 0               @ Retrieve VBAR Address
	mov pc, lr

_os_debug:
	cpsie f                                  @ cpsie is for enable IRQ (i), FIQ (f) and Abort (a) (all, ifa). cpsid is for disable
	_os_debug_loop1:
		b _os_debug_loop1

_os_fiq:
	cpsid f                                  @ Disable Aborts (a), FIQ(f), IRQ(i)

	push {r0-r12,lr}                         @ Equals to stmfd (stack pointer full, decrement order)
	mrs r0, spsr
	push {r0}

	bl _os_fiq_handler

	pop {r0}
	msr spsr, r0
	pop {r0-r12,lr}                          @ Equals to ldmfd (stack pointer full, decrement order)

	cpsie f                                  @ Enable Aborts (a), FIQ(f), IRQ(i)

	subs pc, lr, #4

_os_fiq_handler:
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldr r1, gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	str r1, gpio_toggle

	cmp r1, #0
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_systemtimer_base

	ldr r0, [r0, #equ32_systemtimer_counter_lower] @ Get Lower 32 Bits
	ldr r1, sys_timer_previous
	sub r2, r0, r1
	str r0, sys_timer_previous

	push {lr}
	mov r0, r2
	bl math32_hexa_to_deci32
	pop {lr}

	ldr r2, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r2, [r2]
	ldr r3, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_FONT_MONO_12PX_ASCII       @ Font
	ldr r4, [r4]
	macro32_print_number_double r0 r1 80 388 r2 r3 16 8 12 r4

	ldr r0, timer_sub
	ldr r1, timer_main

	add r0, r0, #1
	cmp r0, #10
	addge r1, #1
	movge r0, #0

	str r0, timer_sub
	str r1, timer_main

	macro32_print_number_double r0 r1 80 400 r2 r3 16 8 12 r4

	mov pc, lr

core123_handler: .word _core123_handler

_core123_handler:
	macro32_multicore_id r0
	ldr r1, core_addr
	mul r2, r0, r0
	ldrb r3, [r1,r0]
	add r2, r2, r3
	strb r2, [r1,r0]
	macro32_dsb ip
	macro32_isb ip
	mov pc, lr

core123_handler2: .word _core123_handler2
_core123_handler2:
	push {r4-r11}

	add sp, sp, #32                 @ r4-r11 offset 32 bytes
	pop {r4-r6}                     @ Get Fifth to Seventh Arguments
	sub sp, sp, #44

	add r0, r0, r1
	add r0, r0, r2
	add r0, r0, r3
	add r0, r0, r4
	add r0, r0, r5
	add r0, r0, r6
	macro32_dsb ip
	macro32_isb ip
	pop {r4-r11}
	mov pc, lr

/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\nMAHALO! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello
_string_test:
	.ascii "Sytem Timer Interval\n\t100K? 100K by 10 Equals 1M!\n\tSystem Timer is 1M Hz!\0"
.balign 4
string_test:
	.word _string_test
addr_float: .word float_example1
float_example1:
	.float 4.4
	.word 0x00
float_example2:
	.float 7.8
	.word 0x00
float_example3:
	.float 3.3
	.word 0x00
double_example:
	.double 3.3
timer_main:
	.word 0x00000000
timer_sub:
	.word 0x00000000
sys_timer_previous:
	.word 0x00000000
core_addr:
	.word core0
core0:
	.byte 0x00000000
core1:
	.byte 0x00000000
core2:
	.byte 0x00000000
core3:
	.byte 0x00000000
.balign 4

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
