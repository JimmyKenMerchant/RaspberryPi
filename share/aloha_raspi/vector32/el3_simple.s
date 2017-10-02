/**
 * el3_simple.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

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

	mov r0, #0x1                              @ NS Bit (Effective on EL0 and EL1)
	mcr p15, 0, r0, c1, c1, 0                 @ Change to Non-secure state, Secure Configuration Register (SCR)
	macro32_dsb ip

	/* Non-secure State Below */

	movs pc, lr                               @ Return to SVC Mode
