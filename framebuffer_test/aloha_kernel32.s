/**
 * aloha_kernel.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is tested by Raspberry Pi 2 Model B V1.1 whose CPU is BCM2836, Coretex-A7 MPCore (ARMv7-A).
 */

/**
 * Vector Interrupt Tables and These Functions
 *
 * Mon mode banks SP, LR, SPSR and its unique IVT, MBAR.
 * Hyp mode banks SP, SPSR, ELR, but LR is shared with User and System mode.
 * BUT REMEBER, in HYP mode, banking registers is INVALID because of no mode change.
 */
.section	.vector
.globl _start
_start:
	ldr pc, _reset_addr                    @ 0x00 reset
	ldr pc, _undefined_instruction_addr    @ 0x04 Undifined mode (Hyp mode in Hyp mode), (Banks SP, LR, SPSR)
	ldr pc, _supervisor_addr               @ 0x08 Supervisor mode by `SVC`, If `HVC` from Hyp mode, Hyp mode, (SP, LR, SPSR)
	ldr pc, _prefetch_abort_addr           @ 0x0C Abort mode (Hyp mode in Hyp mode), (SP, LR, SPSR)
	ldr pc, _data_abort_addr               @ 0x10 Abort mode (Hyp mode in Hyp mode), (SP, LR, SPSR)
	ldr pc, _hypervisor_addr               @ 0x14 Hyp mode by `HVC` from Non-secure state except Hyp mode, (SP, SPSR, ELR)
	ldr pc, _irq_addr                      @ 0x18 IRQ mode (Hyp mode in Hyp mode), (SP, LR, SPSR)
	ldr pc, _fiq_addr                      @ 0x1C FIQ mode (Hyp mode in Hyp mode), (SP, LR, SPSR)
_reset_addr:                 .word _reset
_undefined_instruction_addr: .word _reset
_supervisor_addr:            .word _reset
_prefetch_abort_addr:        .word _reset
_data_abort_addr:            .word _reset
_hypervisor_addr:            .word _reset
_irq_addr:                   .word _reset
_fiq_addr:                   .word _fiq

_reset:
	/*
	 * To Handle HYP mode well, you need to know all interrupts are treated in HYP mode
	 * e.g., if you enter IRQ in HYP mode, it means CALL HYP MODE AGAIN
	 * To remember SP, ELR, SPSR, etc. on the time when start.elf commands HYP with, store these in the stack FIRST. 
	 */
	mov ip, sp                                @ ip is r12
	mov sp, #0x8000                           @ Stack Pointer to 0x8000
                                                  @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)

	push {r0-r12,lr}
	mrs r0, elr_hyp                           @ mrs/msr accessible system registers can add postfix of modes
	mrs r1, spsr_hyp
	push {r0, r1}

	/* HYP mode FIQ Disable and IRQ Disable, Current Mode */
	mov r0, #hyp_mode|fiq_disable|irq_disable @ 0xDA
	msr cpsr_c, r0

	mov r0, #0x8000
	mcr p15, 4, r0, c12, c0, 0                @ Change HVBAR, IVT Base Vector Address of Hyp mode on NOW

	mov r0, #peripherals_base
	ldr r1, ADDR32_SYSTEM32_INTERRUPT_BASE
	ldr r1, [r1]
	add r0, r0, r1

	mov r1, #0x00000000
	mvn r1, r1                                @ Whole Inverter

	str r1, [r0, #interrupt_disable_irqs_1]   @ Make Sure Disable All IRQs
	str r1, [r0, #interrupt_disable_irqs_2]
	str r1, [r0, #interrupt_disable_basic_irqs]

	mov r1, #0b11000000                       @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #interrupt_fiq_control]

	mov r0, #peripherals_base
	ldr r1, ADDR32_SYSTEM32_ARMTIMER_BASE
	ldr r1, [r1]
	add r0, r0, r1

	mov r1, #0x95                             @ Decimal 149 to divide 240Mz by 150 to 1.6Mhz (Predivider is 10 Bits Wide)
	str r1, [r0, #armtimer_predivider]

	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	str r1, [r0, #armtimer_load]

	mov r1, #0x3E0000                         @ High 2 Bytes
	add r1, r1, #0b10100100                   @ Low 2 Bytes (00A4), Timer Enable and Timer Interrupt Enable, Prescaler 1/16 to 100K
	                                          @ 1/16 is #0b10100100, 1/256 is #0b10101000
	str r1, [r0, #armtimer_control]

	/* So We can get a 10hz Timer Interrupt (100000/10000) */

	mov r0, #peripherals_base
	ldr r1, ADDR32_SYSTEM32_GPIO_BASE
	ldr r1, [r1]
	add r0, r0, r1

	mov r1, #1 << 21                          @ Set GPIO 47 OUTPUT
	str r1, [r0, #gpio_gpfsel_4]

	mov r0, #32
	ldr r1, ADDR32_FB32_DEPTH
	str r0, [r1]
	mov r0, #0
	ldr r1, ADDR32_FB32_ALPHAMODE
	str r0, [r1]

	/* Framebuffer Obtain */
	push {r0-r3,lr}
	bl fb32_get
	pop {r0-r3,lr}

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

render:
	push {r0-r8,lr}
	
	ldr r0, ADDR32_COLOR32_NAVYBLUE
	ldr r0, [r0]
	bl fb32_clear_color

	ldr r0, string_arm                        @ Pointer of Array of String
	mov r1, #-4                               @ X Coordinate
	mov r2, #-2                               @ Y Coordinate
	ldr r3, ADDR32_COLOR32_GREEN              @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #14                               @ Length of Characters, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_ASCII
	ldr r8, [r8]
	push {r4-r8}
	bl print32_string
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}


	ldr r0, string_number                     @ Pointer of Array of String
	mov r1, #80                               @ X Coordinate
	mov r2, #88                               @ Y Coordinate
	ldr r3, ADDR32_COLOR32_RED                @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #10
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_ASCII
	ldr r8, [r8]
	push {r4-r8}
	bl print32_string
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}


	ldr r0, string_test                       @ Pointer of Array of String
	mov r1, #80                               @ X Coordinate
	mov r2, #320                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_GREEN              @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_RED                @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #73                               @ Length of Characters, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_ASCII
	ldr r8, [r8]
	push {r4-r8}
	bl print32_string
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}

	ldr r0, float_example1                    @ Pointer of Array of String
	mov r1, #300                              @ X Coordinate
	mov r2, #320                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_NUMBER
	ldr r8, [r8]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}

	ldr r0, float_example2                    @ Pointer of Array of String
	mov r1, #300                              @ X Coordinate
	mov r2, #332                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_NUMBER
	ldr r8, [r8]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}

	ldr r0, float_example3                    @ Pointer of Array of String
	mov r1, #300                              @ X Coordinate
	mov r2, #344                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_NUMBER
	ldr r8, [r8]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}

	pop {r0-r8,lr}

	cpsie f

	push {r0-r3,lr}
	bl user_start
	pop {r0-r3,lr}

debug:
	cpsie f                                  @ cpsie is for enable IRQ (i), FIQ (f) and Abort (a) (all, ifa). cpsid is for disable
	debug_loop1:
		b debug_loop1

_fiq:
	cpsid f                                  @ Disable Aborts (a), FIQ(f), IRQ(i)

	push {r0-r12,lr}                         @ Equals to stmfd (stack pointer full, decrement order)
	mrs r0, elr_hyp                          @ mrs/msr accessible system registers can add postfix of modes
	mrs r1, spsr_hyp
	push {r0-r1}

	bl fiq_handler

	pop {r0-r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1
	pop {r0-r12,lr}                          @ Equals to ldmfd (stack pointer full, decrement order)


	cpsie f                                  @ Enable Aborts (a), FIQ(f), IRQ(i)
	eret                                     @ Because of HYP mode you need to call `ERET` even iin FIQ or IRQ

fiq_handler:
	mov r0, #peripherals_base
	ldr r1, ADDR32_SYSTEM32_ARMTIMER_BASE
	ldr r1, [r1]
	add r0, r0, r1

	mov r1, #0
	str r1, [r0, #armtimer_clear]             @ any write to clear/ acknowledge

	mov r0, #peripherals_base
	ldr r1, ADDR32_SYSTEM32_GPIO_BASE
	ldr r1, [r1]
	add r0, r0, r1

	ldr r1, gpio_toggle
	eor r1, #0b00001100                       @ Exclusive OR to toggle
	str r1, gpio_toggle

	add r0, r0, r1
	mov r1, #gpio47_bit
	str r1, [r0]


	mov r0, #peripherals_base
	ldr r1, ADDR32_SYSTEM32_SYSTEMTIMER_BASE
	ldr r1, [r1]
	add r0, r0, r1

	ldr r0, [r0, #systemtimer_counter_lower_32_bits]
	ldr r1, sys_timer_previous
	sub r2, r0, r1
	str r0, sys_timer_previous

	push {r0-r9,lr}
	mov r0, r2
	bl math32_hexa_to_deci32
	mov r2, #80                               @ X Coordinate
	mov r3, #392                              @ Y Coordinate
	ldr r4, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r4, [r4]
	ldr r5, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r5, [r5]
	mov r6, #16                               @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r7, #8
	mov r8, #12
	ldr r9, ADDR32_FONT_MONO_12PX_NUMBER
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
	ldr r8, ADDR32_FONT_MONO_12PX_NUMBER
	ldr r8, [r8]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}
	pop {r0-r8,lr}

	push {r0-r8,lr}
	mov r0, r1
	mov r1, #80                               @ X Coordinate
	mov r2, #408                              @ Y Coordinate
	ldr r3, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r4, [r4]
	mov r5, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r6, #8
	mov r7, #12
	ldr r8, ADDR32_FONT_MONO_12PX_NUMBER
	ldr r8, [r8]
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push {r4-r7}
	pop {r0-r8,lr}

	mov pc, lr

/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00100000         @ 0x20 (gpset_1)
.balign 4
first_lower:
	.word 0x87654321
first_upper:
	.word 0x00094321
second_lower:
	.word 0x87654321
second_upper:
	.word 0x00094321
_string_arm:
	.ascii "ARMv7/AArch32:" @ Add Null Escape Character on The End
.balign 4
string_arm:
	.word _string_arm
_string_number:
	.ascii "0123456789" @ Add Null Escape Character on The End
.balign 4
string_number:
	.word _string_number
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
.balign 4

.include "addr32.s" @ If you want binary, use `.file`
.balign 4

/* End of Line is Needed */
