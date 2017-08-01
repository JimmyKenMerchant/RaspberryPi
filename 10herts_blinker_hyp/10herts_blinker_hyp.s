/**
 * 10herts_blinker_hyp.s
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
_supervisor_addr:            .word _supervisor @ Use for Software Interrupts
_prefetch_abort_addr:        .word _reset
_data_abort_addr:            .word _reset
_hypervisor_addr:            .word _reset
_irq_addr:                   .word _irq
_fiq_addr:                   .word _reset

_reset:
	/**
         * Latest (from 2015, RasPi2 is lunched) start.elf changes the processor mode to Non-secure Hyp mode in advance,
         * and doesn't start with Supervisor mode with Secure state in default.
	 * `kernel_old=1 disable_commandline_tags=1` will stay secure state, but all 4 cores will run simultaneously
         * for the same instructions from address 0x0000_0000!
	 *
	 * HYP mode Only Can Return to Previous Mode by 'ERET'.
	 * Not evidence yet, but if use 'ERET' with the default setting, the core returns to waiting point for
	 * interrupts from Mailbox 3 on Privilege Level (PL) 1
         */

	/**
	 * PC on the instruction is not its real address. in ARM Instruction, PC - 8 is its real address
	 * PC is two instructions forward, so in THUMB Instruction, PC -4 is its real address
	 */

	/**
	 * cpsr's 0-4 bits are Processor Mode 0x10, 0b00000 is User Mode
	 * cpsr's 5-7 bits are Thumb (T), FIQ (F), IRQ (I)
	 * cpsr_c > 0-7 mmmmmtfi, cpsr_f > 24-31 j_qvcsn, cpsr_x 8-15, cpsr_s 16-23, cpsr_cxsf for all
	 */

	/* HYP mode FIQ Disable and IRQ Disable, Current Mode */
	mov r0, #hyp_mode|fiq_disable|irq_disable @ 0xDA
	msr cpsr_c, r0
	mov sp, #0x20000000                       @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)

	/**
	 * In Hyp mode, changing processor modes by cpsr isn't functioned
	 * because of its Privilege (in AArch64, Exception) Level
	 */

	/*mov r0, #0x08000*/
	/*mcr p15, 0, r0, c12, c0, 0*/   @ Change VBAR, IVT Base Address of Non-secure state and not Hyp mode
                                         @ You should not change VBAR because its IVT has already wrote for multi core handling
	mov r0, #0x08000
	mcr p15, 4, r0, c12, c0, 0       @ Change HVBAR, IVT Base Vector Address of Hyp mode on NOW

	/*mov r0, #0x28000*/
	/*mcr p15, 0, r0, c12, c0, 1*/   @ Change MVBAR (Secure Monitor mode IVT)
                                         @ If you call `SMC`, you will jump to offset 0x08 of MVBAR
                                         @ Only Accessible in Privileged and Secure state

	push {r0-r3,r12,lr}              @ Escape General Purpose Registers, SPSR, and ELR of Current Hyp Mode
	mrs r0, elr_hyp                  @ mrs/msr accessible system registers can add postfix of modes
	mrs r1, spsr_hyp
	push {r0, r1}                    @ In push, Registers will be stored in sequencial manner
                                         @ Lowest numberd register (Now on r0) is stored at lowest memory address
                                         @ sp (r13) will be decremented one word (4 bytes) per one push
                                         @ `STR r1, [sp, #-4]!` Pre-index, subtract four to sp forward
                                         @ `STR r0, [sp, #-4]!` BTW, In AArch64, '#-16' (4 words)!

	/* If you use `SVC` in Hype mode, This Call will be treated as `HVC`, then PC jumps to offset 0x08 of HVBAR */
	svc #0
	hvc #0

	pop {r0, r1}                     @ Retrieve General Purpose Registers, SPSR and ELR of Current Hyp Mode
                                         @ `LDR r0, [sp], #4` Post-index, add four to sp afterward
                                         @ `LDR r1, [sp], #4` BTW, In AArch64, '#16' (4 words)!
	msr elr_hyp, r0
	msr spsr_hyp, r1
	pop {r0-r3,r12,lr}               @ In pop, Registers will be stored in sequencial manner
                                         @ Lowest numberd register (Now on r0) will store one word in lowest memory address

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
	mov r1, #1                                @ Set GPIO 47 OUTPUT
	lsl r1, #21
	str r1, [r0, #gpio_gpfsel_4]
	mov r1, #1                                @ Bit High for GPIO 47
	lsl r1, #15

	cpsie i                                   @ cpsie is for enable IRQ (i), FIQ (f) and Abort (a) (all, ifa). cpsid is for disable

	_reset_loop:
		b _reset_loop

_supervisor:
	mrs r0, cpsr                              @ Get cpsr
	and r0, r0, #0x1F                         @ Bit Mask for Processor Mode
	cmp r0, #hyp_mode                         @ Hyp mode 0x1A 0b11010
	_supervisor_loop:
		bne _supervisor_loop              @ If not equal, loop forever
	eret                                      @ NOT same as `subs pc, lr, #0`, difference on Hyp mode because of ELR_hyp is not lr

_irq:
	push {r2,r3,r12,lr}                       @ Equals to stmfd (stack pointer full, decrement order)
	bl irq_handler
	pop {r2,r3,r12,lr}                        @ Equals to ldmfd (stack pointer full, decrement order)
	subs pc, lr, #4                           @ Need of Correction Value #4 add "s" condition to sub opcode
                                                  @ To Back to Regular Mode and Retrieve CPSR from SPSR

irq_handler:
	mrs r2, cpsr                              @ Get cpsr
	and r2, r2, #0x1F                         @ Bit Mask for Processor Mode
	cmp r2, #hyp_mode                         @ Hyp mode 0x1A 0b11010
	irq_handler_loop:
		bne irq_handler_loop              @ If not equal, loop forever

	ldr r2, armtimer_base
	mov r3, #0
	str r3, [r2, #armtimer_clear]             @ any write to clear/ acknowledge

	ldr r2, gpio_toggle
	eor r2, #0b00001100                       @ Exclusive OR to toggle
	str r2, gpio_toggle
	add r2, r0, r2
	str r1, [r2]

	mov pc, lr

/**
 * Aliases: Does Not Affect Memory in Program
 * Left rotated 1 byte (even order) in Immediate Operand of ARM instructions
 */
.equ interrupt_enable_basic,   0x18
.equ armtimer_load,            0x00
.equ armtimer_control,         0x08
.equ armtimer_clear,           0x0C
.equ armtimer_predivider,      0x1C
.equ mailbox_read,             0x00
.equ mailbox_status,           0x18
.equ mailbox_write,            0x20
.equ gpio_gpfsel_4,            0x10
.equ gpio_gpset_1,             0x20         @ 0b00100000
.equ gpio_gpclr_1,             0x2C         @ 0b00101100

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
.balign 4

/* End of Line is Needed */
