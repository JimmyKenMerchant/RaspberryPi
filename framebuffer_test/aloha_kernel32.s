/**
 * aloha_kernel.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is tested by Raspberry Pi 2 Model B V1.1 whose CPU is BCM2836, Coretex-A7 MPCore (ARMv7-A).
 */

.globl _start
.globl user_start

/**
 * Vector Interrupt Tables and These Functions
 */
.code 32 @ `16` for Thumb Instructions, `64` for AArch64
.section	.vector
_start:
	ldr pc, _reset_addr                    @ 0x00 reset
	ldr pc, _undefined_instruction_addr    @ 0x04 Undifined mode (Hyp mode in Hyp mode)
	ldr pc, _supervisor_addr               @ 0x08 Supervisor mode by `SVC`, If `HVC` from Hyp mode, Hyp mode
	ldr pc, _prefetch_abort_addr           @ 0x0C Abort mode (Hyp mode in Hyp mode)
	ldr pc, _data_abort_addr               @ 0x10 Abort mode (Hyp mode in Hyp mode)
	ldr pc, _hypervisor_addr               @ 0x14 Hyp mode by `HVC` from Non-secure state except Hyp mode
	ldr pc, _irq_addr                      @ 0x18 IRQ mode (Hyp mode in Hyp mode)
	ldr pc, _fiq_addr                      @ 0x1C FIQ mode (Hyp mode in Hyp mode), which banks r8-r12 specially
_reset_addr:                 .word _reset
_undefined_instruction_addr: .word _reset
_supervisor_addr:            .word _reset
_prefetch_abort_addr:        .word _reset
_data_abort_addr:            .word _reset
_hypervisor_addr:            .word _reset
_irq_addr:                   .word _irq
_fiq_addr:                   .word _reset

_reset:
	/* HYP mode FIQ Disable and IRQ Disable, Current Mode */
	mov r0, #hyp_mode|fiq_disable|irq_disable @ 0xDA
	msr cpsr_c, r0
	mov sp, #0x20000000                       @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)

	mov r0, #0x08000
	mcr p15, 4, r0, c12, c0, 0                @ Change HVBAR, IVT Base Vector Address of Hyp mode on NOW

	ldr r0, peripherals_base
	ldr r1, interrupt_base
	add r0, r0, r1

	mov r1, #1                                @ 1 to LSB for IRQ of ARM Timer
	str r1, [r0, #interrupt_enable_basic]

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
	push {r0-r3}
	bl get_framebuffer
	pop {r0-r3}

render:
	push {r0-r5}

	ldr r0, color16_navyblue
	bl clear_color


	ldr r0, string_arm                        @ Pointer of Array of String
	mov r1, #80                               @ X Coordinate
	mov r2, #80                               @ Y Coordinate
	ldr r3, color16_green                     @ Color (16-bit)
	mov r4, #14                               @ Length of Characters, Need of PUSH/POP
	push {r4}
	bl print_string_ascii_8by8
	add sp, sp, #4                            @ Increment SP because of push {r4}


	ldr r0, string_number                     @ Pointer of Array of String
	mov r1, #80                               @ X Coordinate
	mov r2, #88                               @ Y Coordinate
	ldr r3, color16_red                       @ Color (16-bit)
	mov r4, #10                               @ Length of Characters, Need of PUSH/POP
	push {r4}
	bl print_string_ascii_8by8
	add sp, sp, #4                            @ Increment SP because of push {r4}


	ldr r0, FB_SIZE                           @ Register to show numbers
	mov r1, #80                               @ X Coordinate
	mov r2, #96                               @ Y Coordinate
	ldr r3, color16_yellow                    @ Color (16-bit)
	mov r4, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	push {r4}
	bl print_number_8by8
	add sp, sp, #4                            @ Increment SP because of push {r4}


	ldr r0, FB_SIZE
	bl hexa_to_deci32

                                                  @ r0 (Lower Half) and r1 (Upper Half) are already stored
	mov r2, #80                               @ X Coordinate
	mov r3, #104                              @ Y Coordinate
	ldr r4, color16_magenta                   @ Color (16-bit)
	mov r5, #10                               @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	push {r4,r5}
	bl double_print_number_8by8
	add sp, sp, #8                            @ Increment SP because of push {r4, r5}


	ldr r0, first_lower                       @ Lower Bits of First Number, needed between 0-9 in all digits
	ldr r1, first_upper                       @ Upper Bits of First Number, needed between 0-9 in all digits
	ldr r2, second_lower                      @ Lower Bits of Second Number, needed between 0-9 in all digits
	ldr r3, second_upper                      @ Upper Bits of Second Number, needed between 0-9 in all digits
	bl decimal_adder64

                                                  @ r0 (Lower Half) and r1 (Upper Half) are already stored
	mov r2, #80                               @ X Coordinate
	mov r3, #112                              @ Y Coordinate
	ldr r4, color16_skyblue                   @ Color (16-bit)
	mov r5, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	push {r4,r5}
	bl double_print_number_8by8
	add sp, sp, #8                            @ Increment SP because of push {r4, r5}


	ldr r0, string_hello                      @ Pointer of Array of String
	mov r1, #80                               @ X Coordinate
	mov r2, #120                              @ Y Coordinate
	ldr r3, color16_white                     @ Color (16-bit)
	mov r4, #23                               @ Length of Characters, Need of PUSH/POP
	push {r4}
	bl print_string_ascii_8by8
	add sp, sp, #4                            @ Increment SP because of push {r4}

	mov r0, r1                                @ Register to show numbers
	mov r1, #80                               @ X Coordinate
	mov r2, #144                              @ Y Coordinate
	ldr r3, color16_yellow                    @ Color (16-bit)
	mov r4, #8                                @ Number of Digits, 8 Digits Maximum, Need of PUSH/POP
	push {r4}
	bl print_number_8by8
	add sp, sp, #4  

	pop {r0-r5}

	bl user_start

debug:
	cpsie i                                   @ cpsie is for enable IRQ (i), FIQ (f) and Abort (a) (all, ifa). cpsid is for disable
	debug_loop1:
		b debug_loop1

_irq:
	push {r0-r12,lr}                          @ Equals to stmfd (stack pointer full, decrement order)
	bl irq_handler
	pop {r0-r12,lr}                           @ Equals to ldmfd (stack pointer full, decrement order)
	subs pc, lr, #4                           @ Need of Correction Value #4 add "s" condition to sub opcode
                                                  @ To Back to Regular Mode and Retrieve CPSR from SPSR

irq_handler:
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

.include "system32/system32.s" @ If you want binary, use `.file`
.balign 4

/* End of Line is Needed */
