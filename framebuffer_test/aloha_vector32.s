/**
 * aloha_kernel.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is tested by Raspberry Pi 2 Model B V1.1 whose CPU is BCM2836, Coretex-A7 MPCore (ARMv7-A).
 */

.section	.el01_vector
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
	mcr p15, 0, r0, c12, c0, 0                    @ VBAR(User Mode, EL0, and Privileged Mode, EL1), IVT Base Vector Address
	mov r0, #0x2000
	mcr p15, 0, r0, c12, c0, 1                    @ MVBAR (Secure Monitor mode, EL3), IVT Base Vector Address
	smc #0
	svc #0

_el01_svc:
	mrc p15, 0, r0, c0, c0, 5                 @ Multiprocessor Affinity Register (MPIDR)
	and r0, r0, #0b11

	mov ip, #0x200                            @ Offset 0x200 Bytes per Core
	mul ip, ip, r0
	mov fp, #0x5000
	sub fp, fp, ip
	mov sp, fp

	cmp r0, #0                                @ If Core is Zero
	moveq r1, #0x8000
	hvceq #0

	ldr r1, _el01_core_addr
	add r1, r1, r0
	strb r0, [r1]

	dsb
	isb

	push {r0-r3,lr}
	mov r0, r1
	mov r1, #1
	bl system32_cache_clean_inv
	push {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, r1
	mov r1, #2
	bl system32_cache_clean_inv
	push {r0-r3,lr}

	_el01_svc_loop:
		bl system32_receive_core
		b _el01_svc_loop

_el01_core_addr:
	.word core0



.section	.el2_vector
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
_el2_hypervisor_addr:            .word _el2_hyp
_el2_irq_addr:                   .word _el01_reset
_el2_fiq_addr:                   .word _el01_reset

_el2_hyp:
	mrc p15, 0, r0, c0, c0, 5                 @ Multiprocessor Affinity Register (MPIDR)
	and r0, r0, #0b11

	mov ip, #0x200                            @ Offset 0x200 Bytes per Core
	mul ip, ip, r0
	mov fp, #0x6000
	sub fp, fp, ip
	mov sp, fp

	push {r0-r3,lr}
	mov r1, #1
	bl system32_activate_va
	pop {r0-r3,lr}

	mov r0, #0x2500                           @ Outer Sharable, External/Internal Both are Write Back/Write Allocate
        mcr p15, 4, r0, c2, c0, 2                 @ Hyp Translation Control Register (HTCR)

	mrc p15, 4, r0, c1, c0, 0                 @ Hyp Systerm Control Registor (HSCTLR)
	orr r0, r0, #0b100                        @ Data and Unified Cache Enable in Hyp mode Bit[2](C), MMU Enable Bit[0](M)
	orr r0, r0, #0b0001000000000000           @ Instruction Cache Enable in Hyp mode Bit[12](I) (EL2)
	mcr p15, 4, r0, c1, c0, 0                 @ Hyp Systerm Control Registor (HSCTLR)

	mrc p15, 0, r0, c1, c0, 1                 @ Auxiliary Control Register (ACTLR)
	orr r0, r0, #0b01000000                   @ Enable [6]SMP (Symmetric Multi Processing), Shares Memory on Each Core
	mcr p15, 0, r0, c1, c0, 1                 @ Writeable on Non-Secure only on [6]SMP, if NS_SMP of NSACR is Set

	push {r0-r12,lr}
	mrs r10, elr_hyp                          @ mrs/msr accessible system registers can add postfix of modes
	mrs r11, spsr_hyp
	push {r10,r11}
	mrc p15, 4, r10, c12, c0, 0
	push {r10}                                @ Push Last HVBAR Address to Retrieve

	blx r1

	pop {r10}                                 @ Return Process from Current Hyp Mode
	mcr p15, 4, r10, c12, c0, 0               @ Retrieve HVBAR Address
	pop {r10,r11}
	msr elr_hyp, r10
	msr spsr_hyp, r11
	pop {r0-r12,lr}

eret

.section	.el3_vector
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
	mrc p15, 0, r0, c0, c0, 5                 @ Multiprocessor Affinity Register (MPIDR)
	and r0, r0, #0b11

	mov ip, #0x200                            @ Offset 0x200 Bytes per Core
	mul ip, ip, r0
	mov fp, #0x5000
	sub fp, fp, ip
	mov sp, fp

	push {r0-r3,lr}
	bl system32_lineup_basic_va
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r1, #0
	bl system32_activate_va
	pop {r0-r3,lr}

	mrc p15, 0, r0, c1, c0, 0                 @ System Control Register (SCTLR)
	orr r0, r0, #0b100                        @ Enable Data Cache[2] and (EL0 and EL1)MMU[0]
	orr r0, r0, #0b0001100000000000           @ Enable Instruction and Branch Target Chache
	mcr p15, 0, r0, c1, c0, 0                 @ Banked by Secure/Non-secure

	mrc p15, 0, r0, c1, c0, 1                 @ Auxiliary Control Register (ACTLR)
	orr r0, r0, #0b01000001                   @ Enable [6]SMP (Symmetric Multi Processing), Shares Memory on Each Core,
                                                  @ And Enable [0]FW, Cache and TLB Maintenance Broadcast (From ARMv8)
	mcr p15, 0, r0, c1, c0, 1                 @ Common on Secure/Non-secure, Writeable on Secure

	mov r0, #0                                @ If You Want Invalidate/ Clean Entire One, Needed Zero (SBZ)
	mcr p15, 0, r0, c7, c5, 0                 @ Invalidate Entire Instruction Cache and Flush Branch Target Cache
	isb
	/*mcr p15, 0, r0, c7, c6, 0*/             @ Invalidate Entire Data Cache (NOT ON ARMv7 Virtualization Extensions)
	/*mcr p15, 0, r0, c7, c10, 0*/            @ Clean Entire Data Cache (NOT ON ARMv7 Virtualization Extensions)
	/*mcr p15, 0, r0, c7, c14, 0*/            @ Clean and Invalidate Entire Data Cache (NOT ON ARMv7 Virtualization Extensions)   
	/*mcr p15, 0, r0, c7, c10, 4*/            @ Data Synchronization Barrier (Deprecated in From ARMv7)
	/*mcr p15, 0, r0, c7, c10, 5*/            @ Data Memory Barrier (Deprecated in From ARMv7)

	mov r0, #0x0C00                           @ Enable VFP/NEON Access in Non-secure mode, Bit[10] is CP10, Bit[11] is CP11
	add r0, r0, #0x40000                      @ Enable NS_SMP (Non-secure SMP Enable in ACTLR), Bit[18]
	mcr p15, 0, r0, c1, c1, 2                 @ Non-secure Access Control Register (NSACR)

	mov r0, #0x1                              @ NS Bit (Effective on EL0 and EL1)
	add r0, r0, #0x100                        @ HCE Bit (Hypervisor Call Enable)
	mcr p15, 0, r0, c1, c1, 0                 @ Change to Non-secure state, Secure Configuration Register (SCR)

	dsb

	/* Non-secure State Below */

	push {r0-r3,lr}
	mov r1, #1
	bl system32_activate_va
	pop {r0-r3,lr}

	mrc p15, 0, r0, c1, c0, 0                 @ System Control Register (SCTLR)
	orr r0, r0, #0b100                        @ Enable Data Cache[2] and MMU(EL0 and EL1)[0]
	orr r0, r0, #0b0001100000000000           @ Enable Instruction and Branch Target Chache
	mcr p15, 0, r0, c1, c0, 0                 @ Banked by Secure/Non-secure

	mrc p15, 0, r0, c1, c0, 1                 @ Auxiliary Control Register (ACTLR)
	orr r0, r0, #0b01000000                   @ Enable [6]SMP (Symmetric Multi Processing), Shares Memory on Each Core
	mcr p15, 0, r0, c1, c0, 1                 @ Writeable on Non-Secure only on [6]SMP, if NS_SMP of NSACR is Set

	mov r0, #0x1000
	mcr p15, 4, r0, c12, c0, 0                @ Change HVBAR (Hypervisor Mode, EL2), IVT Base Vector Address

	movs pc, lr                               @ Return to SVC Mode


/**
 * Vector Interrupt Tables and These Functions
 *
 * Mon mode banks SP, LR, SPSR and its unique IVT, MBAR.
 * Hyp mode banks SP, SPSR, ELR, but LR is shared with User and System mode.
 * BUT REMEBER, in HYP mode, banking registers is INVALID because of no mode change.
 */
.section	.aloha_vector
.globl _aloha_start
_aloha_start:
	ldr pc, _aloha_reset_addr                    @ 0x00 reset
	ldr pc, _aloha_undefined_instruction_addr    @ 0x04 (Hyp mode in Hyp mode)
	ldr pc, _aloha_supervisor_addr               @ 0x08 (Hyp mode in Hyp mode)
	ldr pc, _aloha_prefetch_abort_addr           @ 0x0C (Hyp mode in Hyp mode)
	ldr pc, _aloha_data_abort_addr               @ 0x10 (Hyp mode in Hyp mode)
	ldr pc, _aloha_reserve_addr                  @ If you call `HVC` in Hyp Mode, It translates to `SVC`
	ldr pc, _aloha_irq_addr                      @ 0x18 (Hyp mode in Hyp mode)
	ldr pc, _aloha_fiq_addr                      @ 0x1C (Hyp mode in Hyp mode)
_aloha_reset_addr:                 .word _aloha_reset
_aloha_undefined_instruction_addr: .word _aloha_reset
_aloha_supervisor_addr:            .word _aloha_reset
_aloha_prefetch_abort_addr:        .word _aloha_reset
_aloha_data_abort_addr:            .word _aloha_reset
_aloha_reserve_addr:               .word _aloha_reset
_aloha_irq_addr:                   .word _aloha_reset
_aloha_fiq_addr:                   .word _aloha_fiq

_aloha_reset:
	/*
	 * To Handle HYP mode well, you need to know all interrupts are treated in HYP mode
	 * e.g., if you enter IRQ in HYP mode, it means CALL HYP MODE AGAIN
	 * To remember SP, ELR, SPSR, etc. on the time when start.elf commands HYP with, store these in the stack FIRST. 
	 */
	mov r0, sp                                @ Store Previous Stack Pointer
	mov sp, #0x8000                           @ Stack Pointer to 0x8000
                                                  @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)
	push {r0,lr}

	/* HYP mode FIQ Disable and IRQ Disable, Current Mode */
	mov r0, #equ32_hyp_mode|equ32_fiq_disable|equ32_irq_disable @ 0xDA
	msr cpsr_c, r0

	mov r0, #0x8000
	mcr p15, 4, r0, c12, c0, 0                @ Change HVBAR, IVT Base Vector Address of Hyp mode on NOW

	mov r0, #equ32_peripherals_base
	ldr r1, ADDR32_SYSTEM32_INTERRUPT_BASE
	ldr r1, [r1]
	add r0, r0, r1

	mov r1, #0x00000000
	mvn r1, r1                                @ Whole Inverter

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                       @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	mov r0, #equ32_peripherals_base
	ldr r1, ADDR32_SYSTEM32_ARMTIMER_BASE
	ldr r1, [r1]
	add r0, r0, r1

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

	mov r0, #equ32_peripherals_base
	ldr r1, ADDR32_SYSTEM32_GPIO_BASE
	ldr r1, [r1]
	add r0, r0, r1

	mov r1, #1 << 21                          @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel4]

	mov r0, #32
	ldr r1, ADDR32_FB32_DEPTH
	str r0, [r1]
	mov r0, #0
	ldr r1, ADDR32_FB32_ALPHAMODE
	str r0, [r1]

	/* Framebuffer Obtain */
	push {r0-r3}
	bl fb32_get_framebuffer
	pop {r0-r3}

	/* Clear Heap to All Zero */
	push {r0-r3}
	bl system32_clear_heap
	pop {r0-r3}

	/* Coprocessor Access Control Register (CPACR) For Floating Point and NEON (SIMD) */
	
	/*
         * 20-21 Bits for CP 10, 22-23 Bits for CP 11
         * Each 0b01 is for Enable in Previlege Mode
         * Each 0b11 is for Enable in Previlege and User Mode
         */
	mov r0, #0b0101
	lsl r0, r0, #20

	MCR p15, 0, r0, c1, c0, 2

	isb                                       @ Must Need When You Renew CPACR

	mov r0, #0x40000000                       @ Enable NEON/VFP
	vmsr fpexc, r0

	ldr r0, addr_float
	vld1.32 {d0,d1}, [r0]                     @ Load float_example1 and float_example2 (8 bytes aligned)
	vadd.f32 d2, d0, d1                       @ Add as Single Presicion Floating Point (d0-31 is 64-bit, q0-15 is 1238-bit)
	vcvt.s32.f32 d3, d2                       @ Floating Point to Singed Integer (U32 for Unsigned Integer)
                                                  @ Floating Point to Integer Uses Round Towards Zero in NEON Instructions
                                                  @ Integer to Floating/Fixed Point Uses Round to Nearest in NEON Instructions
	vst1.32 {d2,d3}, [r0]                     @ Store Result to float_example1, float_example2 as Integer

	ldr r0, float_example3
	ldr r1, float_example1
	vmov d0, r0, r1                           @ VFP Instructions (s0-31 is 32 bit), d0 Lower Bits from r0, Upper Bits from r1
	vadd.f32 s0, s0, s1                       @ d0[0] Lower Bits Equals s0, d0[1] Upper Bits Equals s1
	vcvtr.u32.f32 s0, s0                      @ In VFP Instructions, You Can Convert with Rounding Mode
	vmov r0, s0
	str r0, float_example3

	mov r0, #1
	ldr r1, core123_handler
	/*bl system32_call_core*/

	mov r0, #2
	ldr r1, core123_handler
	/*bl system32_call_core*/

	mov r0, #3
	ldr r1, core123_handler
	/*bl system32_call_core*/

_aloha_render:
	push {r0-r8}
	
	ldr r0, ADDR32_COLOR32_NAVYBLUE
	ldr r0, [r0]
	bl fb32_clear_color

	ldr r0, string_hello                      @ Pointer of Array of String
	mov r1, #0                                @ X Coordinate
	mov r2, #0                                @ Y Coordinate
	ldr r3, ADDR32_COLOR32_GREEN              @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #100                              @ Length of Characters, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_ASCII
	ldr r8, [r8]
	push {r4-r8}
	bl print32_string
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}

	ldr r0, string_test                       @ Pointer of Array of String
	mov r1, #0                                @ X Coordinate
	mov r2, #100                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_GREEN              @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #100                              @ Length of Characters, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_ASCII
	ldr r8, [r8]
	push {r4-r8}
	bl print32_string
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}

	ldr r0, core_addr
	mov r1, #1
	bl system32_cache_clean_inv
	ldr r0, core_addr
	mov r1, #2
	bl system32_cache_clean_inv

	ldrb r0, core0
	ldrb r1, core1
	ldrb r2, core2
	ldrb r3, core3
	add r0, r0, r1
	add r0, r0, r2
	add r0, r0, r3

	mov r1, #0                                @ X Coordinate
	mov r2, #136                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_ASCII
	ldr r8, [r8]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}

	pop {r0-r8}

	cpsie f

	push {r0-r3}
	bl _user_start
	pop {r0-r3}

	mov fp, #0x8000                          @ Retrieve Previous Stack Pointer and Link Register
	ldr r0, [fp, #-4]                        @ Post-index, add four to fp afterward, Stack Pointer
	ldr lr, [fp]                             @ Link Register
	mov sp, r0
	mov pc, lr

_aloha_debug:
	cpsie f                                  @ cpsie is for enable IRQ (i), FIQ (f) and Abort (a) (all, ifa). cpsid is for disable
	_aloha_debug_loop1:
		b _aloha_debug_loop1

_aloha_fiq:
	cpsid f                                  @ Disable Aborts (a), FIQ(f), IRQ(i)

	push {r0-r12,lr}                         @ Equals to stmfd (stack pointer full, decrement order)
	mrs r0, elr_hyp                          @ mrs/msr accessible system registers can add postfix of modes
	mrs r1, spsr_hyp
	push {r0,r1}

	bl _aloha_fiq_handler

	pop {r0,r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1
	pop {r0-r12,lr}                          @ Equals to ldmfd (stack pointer full, decrement order)


	cpsie f                                  @ Enable Aborts (a), FIQ(f), IRQ(i)
	eret                                     @ Because of HYP mode you need to call `ERET` even iin FIQ or IRQ

_aloha_fiq_handler:
	mov r0, #equ32_peripherals_base
	ldr r1, ADDR32_SYSTEM32_ARMTIMER_BASE
	ldr r1, [r1]
	add r0, r0, r1

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]             @ any write to clear/ acknowledge

	mov r0, #equ32_peripherals_base
	ldr r1, ADDR32_SYSTEM32_GPIO_BASE
	ldr r1, [r1]
	add r0, r0, r1

	ldr r1, gpio_toggle
	eor r1, #0b00001100                       @ Exclusive OR to toggle
	str r1, gpio_toggle

	add r0, r0, r1
	mov r1, #equ32_gpio47
	str r1, [r0]


	mov r0, #equ32_peripherals_base
	ldr r1, ADDR32_SYSTEM32_SYSTEMTIMER_BASE
	ldr r1, [r1]
	add r0, r0, r1

	ldr r0, [r0, #equ32_systemtimer_counter_lower] @ Get Lower 32 Bits
	ldr r1, sys_timer_previous
	sub r2, r0, r1
	str r0, sys_timer_previous

	push {r0-r9,lr}
	mov r0, r2
	bl math32_hexa_to_deci32
	mov r2, #80                               @ X Coordinate
	mov r3, #388                              @ Y Coordinate
	ldr r4, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r4, [r4]
	ldr r5, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r5, [r5]
	mov r6, #16                               @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r7, #8
	mov r8, #12
	ldr r9, ADDR32_FONT_MONO_12PX_ASCII
	ldr r9, [r9]
	push {r4-r9}
	bl print32_number_double
	add sp, sp, #24                           @ Increment SP because of push {r4-r7}
	pop {r0-r9,lr}

	ldr r0, timer_sub
	ldr r1, timer_main

	add r0, r0, #1
	cmp r0, #10
	addge r1, #1
	movge r0, #0

	str r0, timer_sub
	str r1, timer_main

	push {r0-r8,lr}
	mov r1, #80                               @ X Coordinate
	mov r2, #400                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_ASCII
	ldr r8, [r8]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}
	pop {r0-r8,lr}

	push {r0-r8,lr}
	mov r0, r1
	mov r1, #80                               @ X Coordinate
	mov r2, #412                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_ASCII
	ldr r8, [r8]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}
	pop {r0-r8,lr}

	mov pc, lr

core123_handler: .word _core123_handler

_core123_handler:
	ldr r2, core_addr
	strb r0, [r2, r0]
	dsb
	isb
	dmb
	mov pc, lr

/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00100000         @ 0x20 (gpset_1)
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
