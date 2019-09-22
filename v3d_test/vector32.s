/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Define Debug Status */
/*.equ __DEBUG, 1*/

.include "system32/equ32.s"
.include "system32/macro32.s"

.ifdef __ARMV6
	.include "vector32/el01_armv6.s"
	.include "vector32/el3_armv6.s"
.else
	.include "vector32/el01_armv7.s"
	.include "vector32/el2_armv7.s"
	.include "vector32/el3_armv7.s"
.endif

.include "vector32/os.s"

os_reset:
	push {lr}

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base

	mvn r1, #0                                       @ Whole Inverter

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                              @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	/**
	 * Get a 10hz Timer Interrupt (120000/12000)
	 */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_16|equ32_armtimer_ctl_23bit_counter @ Prescaler 1/16 to 100K
	mov r1, #0x2E00                                  @ 0x2E00 High 1 Byte of decimal 11999 (12000 - 1), 16 bits counter on default
	add r1, r1, #0xDF                                @ 0xDF Low 1 Byte of decimal 11999, 16 bits counter on default
	mov r2, #0x7C                                    @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer

	/* Obtain Framebuffer from VideoCore IV */
	mov r0, #32
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	macro32_clean_cache r1, ip

	bl bcm32_get_framebuffer

	/* Enable QPU */

	mov r0, #1
	bl v3d32_enable_qpu

	/* Enable L2 Cache */

	mov r0, #0b001
	bl v3d32_control_qpul2cache

	pop {pc}

os_debug:
	push {r4-r10,lr}

	/* Disable QPU Interrupt, Already Disabled in Default Though */

	push {r0-r3}
	mov r0, #0x0000
	bl v3d32_control_qpuinterrupt
	pop {r0-r3}

	/**
	 * Allocate and Lock GPU Memory
	 */

	/* For Array of Jobs to Execute User Program */

	push {r0-r3}
	mov r0, #16
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 100

	str r4, handle_mail

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 112

	str r4, addr_mail

	/* For Array of Uniforms */

	push {r0-r3}
	mov r0, #8
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 124

	str r4, handle_uniform

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 136

	str r4, addr_uniform

	/* For Output */

	push {r0-r3}
	mov r0, #512
	mov r1, #16
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 148

	str r4, handle_output

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 160

	str r4, addr_output

	/* For Codes */

	push {r0-r3}
	ldr r0, DATA_V3D_SAMPLE1_SIZE
	mov r1, #4096
	mov r2, #0xC
	bl bcm32_allocate_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 172

	str r4, handle_code

	push {r0-r3}
	mov r0, r4
	bl bcm32_lock_memory
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 184

	str r4, addr_code

	/* Copy Codes to Locked GPU Memory */

	push {r0-r3}
	mov r0, r4
	ldr r1, DATA_V3D_SAMPLE1
	orr r1, r1, #equ32_bus_coherence_base @ Convert to Bus Address
	ldr r2, DATA_V3D_SAMPLE1_SIZE
	mov r3, #1
	bl dma32_datacopy
	pop {r0-r3}

	bic r2, r4, #0xC0000000

macro32_debug_hexa r2, 0, 196, 256

	/* Address of Output to First Item of Uniforms, and Set Array of Jobs */

	ldr r0, addr_mail
	bic r0, r0, #0xC0000000              @ Convert to ARM Address
	ldr r1, addr_uniform
	bic r2, r1, #0xC0000000              @ Convert to ARM Address
	ldr r3, addr_output

	str r3, [r2]                         @ Address of Output to First Item of Uniforms
	ldr r3, DATA_V3D_INPUT1
	orr r3, r3, #equ32_bus_coherence_base @ Convert to Bus Address
	str r3, [r2, #4]                     @ Address of Input to Second Item of Uniforms
	str r1, [r0]                         @ Jobs (1) Address of Uniforms
	str r4, [r0, #4]                     @ Jobs (2) Address of Codes
	str r1, [r0, #8]                     @ Jobs (3) Address of Uniforms
	str r4, [r0, #12]                    @ Jobs (4) Address of Codes

	macro32_dsb ip

	/* Execute User Program */

	push {r0-r3}
	mov r0, #2                           @ Two QPUs
	ldr r1, addr_mail
	bic r1, r1, #0xC0000000              @ Convert to ARM Address
	mov r2, #0
	mov r3, #0xFF0000
	bl v3d32_execute_qpu                 @ Direct Execution of User Program from ARM
	mov r4, r0
	pop {r0-r3}

macro32_debug r4, 100, 296

	ldr r3, addr_output
	bic r3, r3, #0xC0000000

macro32_debug_hexa r3, 0, 308, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 320, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 332, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 344, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 356, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 368, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 380, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 392, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 404, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 416, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 428, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 440, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 452, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 464, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 476, 32
add r3, r3, #32
macro32_debug_hexa r3, 0, 488, 32

	/* Unlock and Release GPU Memory */

	push {r0-r3}
	ldr r0, handle_mail
	bl bcm32_unlock_memory
	pop {r0-r3}

	push {r0-r3}
	ldr r0, handle_mail
	bl bcm32_release_memory
	pop {r0-r3}

	push {r0-r3}
	ldr r0, handle_uniform
	bl bcm32_unlock_memory
	pop {r0-r3}

	push {r0-r3}
	ldr r0, handle_uniform
	bl bcm32_release_memory
	pop {r0-r3}

	push {r0-r3}
	ldr r0, handle_output
	bl bcm32_unlock_memory
	pop {r0-r3}

	push {r0-r3}
	ldr r0, handle_output
	bl bcm32_release_memory
	pop {r0-r3}

	push {r0-r3}
	ldr r0, handle_code
	bl bcm32_unlock_memory
	pop {r0-r3}

	push {r0-r3}
	ldr r0, handle_code
	bl bcm32_release_memory
	pop {r0-r3}

	os_debug_loop:
		b os_debug_loop

	pop {r4-r10,pc}

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r7,lr}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	macro32_dsb ip

.ifndef __RASPI3B
	/* ACT Blinker, GPIO 47 Is Preset as OUT */
	mov r0, #47
	mov r1, #2
	bl gpio32_gpiotoggle
.endif

	pop {r0-r7,pc}

/**
 * Variables
 */
handle_mail:    .word 0x00
addr_mail:      .word 0x00
handle_uniform: .word 0x00
addr_uniform:   .word 0x00
handle_output:  .word 0x00
addr_output:    .word 0x00
handle_code:    .word 0x00
addr_code:      .word 0x00
_string_hello:
	.ascii "\nMAHALO! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4

.include "data.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
