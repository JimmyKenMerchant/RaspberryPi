/**
 * aloha_kernel.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is tested by Raspberry Pi 2 Model B V1.1 whose CPU is BCM2836, Coretex-A7 MPCore (ARMv7-A).
 */

.globl user_start


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

	ldr r0, peripherals_base
	ldr r1, interrupt_base
	add r0, r0, r1

	mov r1, #0xFF000000
	add r1, r1, #0x00FF0000
	add r1, r1, #0x0000FF00
	add r1, r1, #0x000000FF

	str r1, [r0, #interrupt_disable_irqs_1]   @ Make Sure Disable All IRQs
	str r1, [r0, #interrupt_disable_irqs_2]
	str r1, [r0, #interrupt_disable_basic_irqs]

	mov r1, #0b11000000                       @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #interrupt_fiq_control]

	ldr r0, peripherals_base
	ldr r1, armtimer_base
	add r0, r0, r1

	mov r1, #0x63                             @ Decimal 99 to divide 160Mz by 100 to 1.6Mhz
	str r1, [r0, #armtimer_predivider]

	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 10000, 16 bits counter on default
	add r1, r1, #0x10                         @ 0x10 Low 1 Byte of decimal 10000, 16 bits counter on default
	str r1, [r0, #armtimer_load]

	mov r1, #0x3E0000                         @ High 2 Bytes
	add r1, r1, #0b10100100                   @ Low 2 Bytes (00A4), Timer Enable and Timer Interrupt Enable, Prescaler 1/16 to 100K
	                                          @ 1/16 is #0b10100100, 1/256 is #0b10101000
	str r1, [r0, #armtimer_control]

	/* So We can get a 10hz Timer Interrupt (100000/10000) */

	ldr r0, peripherals_base
	ldr r1, gpio_base
	add r0, r0, r1

	mov r1, #1 << 21                          @ Set GPIO 47 OUTPUT
	str r1, [r0, #gpio_gpfsel_4]

	/* Framebuffer Obtain */
	push {r0-r3,lr}
	bl get_framebuffer
	pop {r0-r3,lr}

render:
	push {r0-r7,lr}

	ldr r0, color16_navyblue
	bl clear_color

	ldr r0, string_arm                        @ Pointer of Array of String
	mov r1, #80                               @ X Coordinate
	mov r2, #80                               @ Y Coordinate
	ldr r3, color16_green                     @ Color (16-bit or 32-bit)
	mov r4, #14                               @ Length of Characters, Need of PUSH/POP
	mov r5, #8
	mov r6, #12
	ldr r7, FONT_MONO_12PX_ASCII
	push {r4-r7}
	bl print_string
	add sp, sp, #16                           @ Increment SP because of push {r4-r7}


	ldr r0, string_number                     @ Pointer of Array of String
	mov r1, #80                               @ X Coordinate
	mov r2, #88                               @ Y Coordinate
	ldr r3, color16_red                       @ Color (16-bit or 32-bit)
	mov r4, #10
	mov r5, #8
	mov r6, #12
	ldr r7, FONT_MONO_12PX_ASCII
	push {r4-r7}
	bl print_string
	add sp, sp, #16                           @ Increment SP because of push {r4-r7}

	pop {r0-r7,lr}

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
	push {r0, r1}

	bl fiq_handler

	pop {r0, r1}
	msr elr_hyp, r0
	msr spsr_hyp, r1
	pop {r0-r12,lr}                          @ Equals to ldmfd (stack pointer full, decrement order)


	cpsie f                                  @ Enable Aborts (a), FIQ(f), IRQ(i)
	eret                                     @ Because of HYP mode you need to call `ERET` even iin FIQ or IRQ

fiq_handler:
	ldr r0, peripherals_base
	ldr r1, armtimer_base
	add r0, r0, r1

	mov r1, #0
	str r1, [r0, #armtimer_clear]             @ any write to clear/ acknowledge

	ldr r0, peripherals_base
	ldr r1, gpio_base
	add r0, r0, r1

	ldr r1, gpio_toggle
	eor r1, #0b00001100                       @ Exclusive OR to toggle
	str r1, gpio_toggle

	add r0, r0, r1
	mov r1, #gpio47_bit
	str r1, [r0]


	push {r0-r3,lr}
	mov r0, #10                               @ Length of Blocks, Left to Right
	mov r1, #80                               @ X Coordinate
	mov r2, #392                              @ Y Coordinate
	ldr r3, color16_blue                      @ Color (16-bit or 32-bit)
	mov r4, #8
	mov r5, #12
	push {r4-r5}
	bl clear_color_block
	add sp, sp, #8                           @ Increment SP because of push {r4-r6}
	pop {r0-r3,lr}

	ldr r0, peripherals_base
	ldr r1, systemtimer_base
	add r0, r0, r1

	ldr r0, [r0, #systemtimer_counter_lower_32_bits]

	push {r0-r4,lr}
	mov r1, #80                               @ X Coordinate
	mov r2, #392                              @ Y Coordinate
	ldr r3, color16_yellow                    @ Color (16-bit)
	mov r4, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r5, #8
	mov r6, #12
	ldr r7, FONT_MONO_12PX_NUMBER
	push {r4-r7}
	bl print_number
	add sp, sp, #16                           @ Increment SP because of push {r4-r7}
	pop {r0-r4,lr}

	ldr r0, timer_sub
	ldr r1, timer_main

	add r0, r0, #1
	cmp r0, #16
	addge r1, #1
	movge r0, #0

	str r0, timer_sub
	str r1, timer_main

	push {r0-r3,lr}
	mov r0, #8                                @ Length of Blocks, Left to Right
	mov r1, #80                               @ X Coordinate
	mov r2, #400                              @ Y Coordinate
	ldr r3, color16_blue                      @ Color (16-bit or 32-bit)
	mov r4, #8
	mov r5, #12
	push {r4-r5}
	bl clear_color_block
	add sp, sp, #8
	pop {r0-r3,lr}

	push {r0-r4,lr}
	mov r1, #80                               @ X Coordinate
	mov r2, #400                              @ Y Coordinate
	ldr r3, color16_yellow                    @ Color (16-bit)
	mov r4, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r5, #8
	mov r6, #12
	ldr r7, FONT_MONO_12PX_NUMBER
	push {r4-r7}
	bl print_number
	add sp, sp, #16                           @ Increment SP because of push {r4-r7}
	pop {r0-r4,lr}

	push {r0-r3,lr}
	mov r0, #8                                @ Length of Blocks, Left to Right
	mov r1, #80                               @ X Coordinate
	mov r2, #408                              @ Y Coordinate
	ldr r3, color16_blue                      @ Color (16-bit or 32-bit)
	mov r4, #8
	mov r5, #12
	push {r4-r5}
	bl clear_color_block
	add sp, sp, #8 
	pop {r0-r3,lr}

	push {r0-r4,lr}
	mov r0, r1
	mov r1, #80                               @ X Coordinate
	mov r2, #408                              @ Y Coordinate
	ldr r3, color16_yellow                    @ Color (16-bit)
	mov r4, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	mov r5, #8
	mov r6, #12
	ldr r7, FONT_MONO_12PX_NUMBER
	push {r4-r7}
	bl print_number
	add sp, sp, #16                           @ Increment SP because of push {r4-r7}
	pop {r0-r4,lr}

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
float_example:
	.float 3.3
double_example:
	.double 3.3
timer_main:
	.word 0x00000000
timer_sub:
	.word 0x00000000
.balign 4

.include "system32/system32.s" @ If you want binary, use `.file`
.balign 4

/* End of Line is Needed */
