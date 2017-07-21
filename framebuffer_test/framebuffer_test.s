/**
 * framebuffer_test.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is tested by Raspberry Pi 2 Model B V1.1 whose CPU is BCM2836, Coretex-A7 MPCore (ARMv7-A).
 */

/**
 * Vector Interrupt Tables and These Functions
 */
.section	.vector
.globl _start
_start:
	ldr pc, _reset_addr                    @ 0x00 reset
	ldr pc, _undefined_instruction_addr    @ 0x04 Undifined mode (Hyp mode in Hyp mode)
	ldr pc, _supervisor_addr               @ 0x08 Supervisor mode by `SVC`, If `HVC` from Hyp mode, Hyp mode
	ldr pc, _prefetch_abort_addr           @ 0x0C Abort mode (Hyp mode in Hyp mode)
	ldr pc, _data_abort_addr               @ 0x10 Abort mode (Hyp mode in Hyp mode)
	ldr pc, _hypervisor_addr               @ 0x14 Hyp mode by `HVC` from Non-secure state except Hyp mode
	ldr pc, _irq_addr                      @ 0x18 IRQ mode (Hyp mode in Hyp mode)
	ldr pc, _fiq_addr                      @ 0x1C FIQ mode (Hyp mode in Hyp mode)
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

	ldr r0, interrupt_base
	mov r1, #1                                @ 1 to LSB for IRQ of ARM Timer
	str r1, [r0, #interrupt_enable_basic]

	ldr r0, armtimer_base
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

	ldr r0, gpio_base
	mov r1, #1 << 21                          @ Set GPIO 47 OUTPUT
	str r1, [r0, #gpio_gpfsel_4]

	/* Framebuffer Obtain */

	ldr r0, mailbox_base

	_reset_sendmail_wait:
		ldr r1, [r0, #mailbox0_status]
		cmp r1, #0x80000000
		beq _reset_sendmail_wait

	ldr r1, mail_framebuffer_addr
	add r1, r1, #mailbox_gpuoffset|mailbox_channel8
	str r1, [r0, #mailbox0_write]

	_reset_readmail_wait:
		ldr r1, [r0, #mailbox0_status]
		cmp r1, #0x40000000
		beq _reset_readmail_wait

	ldr r0, mail_framebuffer_addr
	ldr r1, [r0, #mail_confirm]
	cmp r1, #0x80000000
	bne debug

render:
	ldr r0, fb_address
	and r0, r0, #mailbox_armmask
	cmp r0, #0
	beq debug

	ldr r1, color16_palemagenta
	ldr r2, fb_size
	cmp r2, #0
	beq debug

	render_loop1:
		strh r1, [r0]                             @ Store half word
		add r0, #2
		add r2, #-2
		cmp r2, #0
		bgt render_loop1

	push {r0-r2}                              @ Equals to stmfd (stack pointer full, decrement order)
	bl irq_handler
	pop {r0-r2} 

	b render

debug:
	cpsie i                                   @ cpsie is for enable IRQ (i), FIQ (f) and Abort (a) (all, ifa). cpsid is for disable
	_reset_loop:
		b _reset_loop

_irq:
	push {r0-r3,r12,lr}                       @ Equals to stmfd (stack pointer full, decrement order)
	bl irq_handler
	pop {r0-r3,r12,lr}                        @ Equals to ldmfd (stack pointer full, decrement order)
	subs pc, lr, #4                           @ Need of Correction Value #4 add "s" condition to sub opcode
                                                  @ To Back to Regular Mode and Retrieve CPSR from SPSR

irq_handler:
	ldr r0, armtimer_base
	mov r1, #0
	str r1, [r0, #armtimer_clear]             @ any write to clear/ acknowledge

	ldr r0, gpio_base
	ldr r1, gpio_toggle
	eor r1, #0b00001100                       @ Exclusive OR to toggle
	str r1, gpio_toggle

	add r0, r0, r1
	mov r1, #gpio47_bit
	str r1, [r0]

	mov pc, lr

/**
 * Alias: Does Not Affect Memory in Program
 * Left Shifted 1 byte or regular 1 byte
 */
.equ interrupt_enable_basic,   0x18
.equ armtimer_load,            0x00
.equ armtimer_control,         0x08
.equ armtimer_clear,           0x0C
.equ armtimer_predivider,      0x1C

.equ mail_confirm,             0x04
.equ mailbox_gpuoffset,        0x40000000
.equ mailbox_armmask,          0x3FFFFFFF
.equ mailbox_channel8,         0x08
.equ mailbox0_read,            0x00
.equ mailbox0_poll,            0x10
.equ mailbox0_sender,          0x14
.equ mailbox0_status,          0x18         @ MSB has 0 for sender. Next Bit from MSB has 0 for receiver
.equ mailbox0_config,          0x1C
.equ mailbox0_write,           0x20

.equ gpio_gpfsel_4,            0x10
.equ gpio_gpset_1,             0x20         @ 0b00100000
.equ gpio_gpclr_1,             0x2C         @ 0b00101100
.equ gpio47_bit,               0b1 << 15    @ 0x8000 Bit High for GPIO 47

.equ user_mode,                0x10         @ 0b00010000 User mode (not priviledged)
.equ fiq_mode,                 0x11         @ 0b00010001 Fast Interrupt Request (FIQ) mode
.equ irq_mode,                 0x12         @ 0b00010010 Interrupt Request (IRQ) mode
.equ svc_mode,                 0x13         @ 0b00010011 Supervisor mode
.equ mon_mode,                 0x16         @ 0b00010110 Secure Monitor mode
.equ abt_mode,                 0x17         @ 0b00010111 Abort mode for prefetch and data abort exception
.equ hyp_mode,                 0x1A         @ 0b00011010 Hypervisor mode
.equ und_mode,                 0x1B         @ 0b00011011 Undefined mode for undefined instruction exception
.equ sys_mode,                 0x1F         @ 0b00011111 System mode

.equ thumb_bit,                0x20         @ 0b00100000
.equ fiq_disable,              0x40         @ 0b01000000
.equ irq_disable,              0x80         @ 0b10000000
.equ abort_disable,            0x100        @ 0b100000000

/**
 * Variables
 */
.balign 4
peripheral_base:   .word 0x3F000000
interrupt_base:    .word 0x3F00B200
armtimer_base:     .word 0x3F00B400
mailbox_base:      .word 0x3F00B880
gpio_base:         .word 0x3F200000
gpio_toggle:       .byte 0b00100000         @ 0x20 (gpset_1)

.balign 16
mail_framebuffer:
	.word mail_framebuffer_end - mail_framebuffer @ Size of this Mail
	.word 0x00000000      @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
mail_contents:
	.word 0x00048003      @ Tag Identifier, Set Physical Width/Height (Size in Physical Display)
	.word 0x00000008      @ Value Buffer Size in Bytes
	.word 0x00000000      @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 800            @ Value Buffer, Width in Pixels
	.word 600             @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048004      @ Tag Identifier, Set Virtual Width/Height (Actual Buffer Size just like Viewport in OpenGL)
	.word 0x00000008      @ Value Buffer Size in Bytes
	.word 0x00000000      @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 800               @ Value Buffer, Width in Pixels
	.word 600               @ Value Buffer, Height in Pixels
.balign 4
	.word 0x00048005      @ Tag Identifier, Set Depth
	.word 0x00000004      @ Value Buffer Size in Bytes
	.word 0x00000000      @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 16              @ Value Buffer, Bits per Pixel, 32 would be 32 RGBA
.balign 4
	.word 0x00040001      @ Tag Identifier, Allocate Buffer
	.word 0x00000008      @ Value Buffer Size in Bytes
	.word 0x00000000      @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
fb_address:
	.word 0x00000000      @ Value Buffer, Alignment in Bytes (in Response, Frame Buffer Base Address in Bytes)
fb_size:
	.word 0x00000000      @ Value Buffer, Reserved for Response (in Response, Frame Buffer Size in Bytes)
.balign 4
	.word 0x00000000      @ End Tag
mail_framebuffer_end:
.balign 16

mail_blankon:
	.word mail_blankon_end - mail_blankon @ Size of this Mail
	.word 0x00000000      @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002      @ Tag Identifier, Blank Screen
	.word 0x00000004      @ Value Buffer Size in Bytes
	.word 0x00000000      @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000001      @ Value Buffer, State (0 means off, 1 means on)
.balign 4
	.word 0x00000000      @ End Tag
mail_blankon_end:
.balign 16

mail_blankoff:
	.word mail_blankoff_end - mail_blankoff @ Size of this Mail
	.word 0x00000000      @ Request (in Response, 0x80000000 with success, 0x80000001 with error)
	.word 0x00040002      @ Tag Identifier, Blank Screen
	.word 0x00000004      @ Value Buffer Size in Bytes
	.word 0x00000000      @ Request Code(0x00000000) or Response Code (0x80000000|Value_Length_in_Bytes)
	.word 0x00000000      @ Value Buffer, State (0 means off, 1 means on)
.balign 4
	.word 0x00000000      @ End Tag
mail_blankoff_end:
.balign 16

mail_framebuffer_addr:
	.word mail_framebuffer @ Address of mail_framebuffer
mail_blankon_addr:
	.word mail_blankon     @ Address of mail_blankon
mail_blankoff_addr:
	.word mail_blankoff    @ Address of mail_blankoff
color16_palemagenta:
	.hword 0xAAAA
.balign 4

/* End of Line is Needed */
