/**
 * equ32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Standard Peripherals
 */

/* BCM2836 and BCM2837 Peripheral Base */
/* If BCM 2835, Peripheral Base is 0x20000000 */
.equ equ32_peripherals_base,   0x3F000000
.equ equ32_systemtimer_base,   0x00003000
.equ equ32_interrupt_base,     0x0000B200
.equ equ32_armtimer_base,      0x0000B400
.equ equ32_gpio_base,          0x00200000
.equ equ32_usb_ehci_base,      0x00980000

.equ equ32_systemtimer_control_status,   0x00
.equ equ32_systemtimer_counter_lower,    0x04 @ Lower 32 Bits
.equ equ32_systemtimer_counter_higher,   0x08 @ Higher 32 Bits
.equ equ32_systemtimer_compare0,         0x0C
.equ equ32_systemtimer_compare1,         0x10
.equ equ32_systemtimer_compare2,         0x14
.equ equ32_systemtimer_compare3,         0x18

.equ equ32_interrupt_irq_basic_pending,    0x00
.equ equ32_interrupt_irq_pending1,         0x04
.equ equ32_interrupt_irq_pending2,         0x08
.equ equ32_interrupt_fiq_control,          0x0C
.equ equ32_interrupt_enable_irqs1,         0x10
.equ equ32_interrupt_enable_irqs2,         0x14
.equ equ32_interrupt_enable_basic_irqs,    0x18
.equ equ32_interrupt_disable_irqs1,        0x1C
.equ equ32_interrupt_disable_irqs2,        0x20
.equ equ32_interrupt_disable_basic_irqs,   0x24

.equ equ32_armtimer_load,         0x00
.equ equ32_armtimer_control,      0x08
.equ equ32_armtimer_clear,        0x0C
.equ equ32_armtimer_predivider,   0x1C

.equ equ32_gpio_gpfsel0,     0x00 @ GPIO 0-9   Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel1,     0x04 @ GPIO 10-19 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel2,     0x08 @ GPIO 20-29 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel3,     0x0C @ GPIO 30-39 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel4,     0x10 @ GPIO 40-49 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel5,     0x14 @ GPIO 50-53 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions

.equ equ32_gpio_gpset0,      0x1C @ GPIO 0-31, Output Set, each 1 bit, 0 no effect, 1 set Pin
.equ equ32_gpio_gpset1,      0x20 @ GPIO 32-53, Output Set, each 1 bit, 0 no effect, 1 set Pin

.equ equ32_gpio_gpclr0,      0x28 @ GPIO 0-31, Output Clear, 0 no effect, 1 clear Pin
.equ equ32_gpio_gpclr1,      0x2C @ GPIO 32-53, Output Clear, 0 no effect, 1 clear Pin

.equ equ32_gpio_gplev0,      0x34 @ GPIO 0-31, Actual Pin Level, 0 law, 1 high
.equ equ32_gpio_gplev1,      0x38 @ GPIO 32-53, Actual Pin Level, 0 law, 1 high

.equ equ32_gpio_gpeds0,      0x40 @ GPIO 0-31, Event Detect Status, 0 not detect, 1 detect, write 1 to clear
.equ equ32_gpio_gpeds1,      0x44 @ GPIO 32-53, Event Detect Status, 0 not detect, 1 detect, write 1 to clear

.equ equ32_gpio_gpren0,      0x4C @ GPIO 0-31, Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gpren1,      0x50 @ GPIO 32-53, Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gpfen0,      0x58 @ GPIO 0-31, Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gpfen1,      0x5C @ GPIO 32-53, Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gphen0,      0x64 @ GPIO 0-31, High Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gphen1,      0x68 @ GPIO 32-53, High Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gplen0,      0x70 @ GPIO 0-31, Low Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gplen1,      0x74 @ GPIO 32-53, Low Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gparen0,     0x7C @ GPIO 0-31, Async Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gparen1,     0x80 @ GPIO 32-53, Async Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gpafen0,     0x88 @ GPIO 0-31, Async Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gpafen1,     0x8C @ GPIO 32-53, Async Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gppud,       0x94 @ Pull-up/down, 0-1 Bit, 00 off, 01 pull-down, 10, pull-up

.equ equ32_gpio_gppudclk0,   0x98 @ GPIO 0-31, Conjection with gppud
.equ equ32_gpio_gppudclk1,   0x9C @ GPIO 32-53, Conjection with gppud

.equ equ32_gpio00,   0b1       @ Bit High
.equ equ32_gpio01,   0b1 << 1  @ Bit High
.equ equ32_gpio02,   0b1 << 2  @ Bit High
.equ equ32_gpio03,   0b1 << 3  @ Bit High
.equ equ32_gpio04,   0b1 << 4  @ Bit High
.equ equ32_gpio05,   0b1 << 5  @ Bit High
.equ equ32_gpio06,   0b1 << 6  @ Bit High
.equ equ32_gpio07,   0b1 << 7  @ Bit High
.equ equ32_gpio08,   0b1 << 8  @ Bit High
.equ equ32_gpio09,   0b1 << 9  @ Bit High
.equ equ32_gpio10,   0b1 << 10 @ Bit High
.equ equ32_gpio11,   0b1 << 11 @ Bit High
.equ equ32_gpio12,   0b1 << 12 @ Bit High
.equ equ32_gpio13,   0b1 << 13 @ Bit High
.equ equ32_gpio14,   0b1 << 14 @ Bit High
.equ equ32_gpio15,   0b1 << 15 @ Bit High
.equ equ32_gpio16,   0b1 << 16 @ Bit High
.equ equ32_gpio17,   0b1 << 17 @ Bit High
.equ equ32_gpio18,   0b1 << 18 @ Bit High
.equ equ32_gpio19,   0b1 << 19 @ Bit High
.equ equ32_gpio20,   0b1 << 20 @ Bit High
.equ equ32_gpio21,   0b1 << 21 @ Bit High
.equ equ32_gpio22,   0b1 << 22 @ Bit High
.equ equ32_gpio23,   0b1 << 23 @ Bit High
.equ equ32_gpio24,   0b1 << 24 @ Bit High
.equ equ32_gpio25,   0b1 << 25 @ Bit High
.equ equ32_gpio26,   0b1 << 26 @ Bit High
.equ equ32_gpio27,   0b1 << 27 @ Bit High
.equ equ32_gpio28,   0b1 << 28 @ Bit High
.equ equ32_gpio29,   0b1 << 29 @ Bit High
.equ equ32_gpio30,   0b1 << 30 @ Bit High
.equ equ32_gpio31,   0b1 << 31 @ Bit High

.equ equ32_gpio32,   0b1       @ Bit High
.equ equ32_gpio33,   0b1 << 1  @ Bit High
.equ equ32_gpio34,   0b1 << 2  @ Bit High
.equ equ32_gpio35,   0b1 << 3  @ Bit High
.equ equ32_gpio36,   0b1 << 4  @ Bit High
.equ equ32_gpio37,   0b1 << 5  @ Bit High
.equ equ32_gpio38,   0b1 << 6  @ Bit High
.equ equ32_gpio39,   0b1 << 7  @ Bit High
.equ equ32_gpio40,   0b1 << 8  @ Bit High
.equ equ32_gpio41,   0b1 << 9  @ Bit High
.equ equ32_gpio42,   0b1 << 10 @ Bit High
.equ equ32_gpio43,   0b1 << 11 @ Bit High
.equ equ32_gpio44,   0b1 << 12 @ Bit High
.equ equ32_gpio45,   0b1 << 13 @ Bit High
.equ equ32_gpio46,   0b1 << 14 @ Bit High
.equ equ32_gpio47,   0b1 << 15 @ Bit High
.equ equ32_gpio48,   0b1 << 16 @ Bit High
.equ equ32_gpio49,   0b1 << 17 @ Bit High
.equ equ32_gpio50,   0b1 << 18 @ Bit High
.equ equ32_gpio51,   0b1 << 19 @ Bit High
.equ equ32_gpio52,   0b1 << 20 @ Bit High
.equ equ32_gpio53,   0b1 << 21 @ Bit High


/**
 * USB2.0
 * Enhanced Host Controller Interface (EHCI2.0) is a USB standard applied to USB2.0.
 * EHCI2.0 is ruling the standard of registers (even names) to control USB2.0,
 * and making its drivers used in wide diversity across CPUs and Intellectual Properties (IPs).
 * But in fact, between IPs, there are differences to define registers.
 * However, these differences are tiny. USB2.0's popularity depends on this strict standard.
 */

/* Core Global Control and Status Registers (CSRs) */
.equ equ32_usb_ehci_gotgctl,      0x00000000 @ OTG Control and Status Register r/w
.equ equ32_usb_ehci_gotgint,      0x00000004 @ OTG Interrupt Register r/w
.equ equ32_usb_ehci_gahbcfg,      0x00000008 @ Core Internal Bus Configuration Register r/w
.equ equ32_usb_ehci_gusbcfg,      0x0000000C @ Core USB Configuration Register r/w
.equ equ32_usb_ehci_grstctl,      0x00000010 @ Core Reset Register r/w
.equ equ32_usb_ehci_gintsts,      0x00000014 @ Core Interrupt Register r/w
.equ equ32_usb_ehci_gintmsk,      0x00000018 @ Core Interrupt Register r/w

/* Host Mode Control and Status Registers (CSRs) */

/* Device Mode Control and Status Registers (CSRs) */


/**
 * ARM System Registers (Coprocessors)
 */

/**
 * For Short Descriptor Translation Table (32-bit), First Level
 * Super Section (16M Bytes), Section (1M Bytes) and Page (64K/4K Bytes)
 * Super Section is implemented for Long Physical Address Extension (LPAE)
 */
.equ equ32_mmu_fault,                     0b00                   @ [1:0], Indexed by Bit[31:20] of Virtual Address
.equ equ32_mmu_page,                      0b01                   @ [1:0], Page Table Base Address Bit[31:10] 2nd Level Descriptor
.equ equ32_mmu_section,                   0b10                   @ [1:0], Section Base Address Bit[31:20]
.equ equ32_mmu_reserve,                   0b11                   @ [1:0]
.equ equ32_mmu_page_pxn,                  0b100                  @ PXN[2]
.equ equ32_mmu_page_nonsecure,            0b1000                 @ NS[3]
.equ equ32_mmu_section_pxn,               0b01                   @ PXN[0], Execute Never in Privilege Mode (EL1), If Implemented
.equ equ32_mmu_section_executenever,      0b10000                @ XN[4]
.equ equ32_mmu_section_stronglyordered,   0b0000                 @ C[3], B[2], Cacheable, Bufferable
.equ equ32_mmu_section_device,            0b0100                 @ C[3], B[2]
.equ equ32_mmu_section_inner_none,        0b0000                 @ C[3], B[2]
.equ equ32_mmu_section_inner_wb_wa,       0b0100                 @ C[3], B[2]
.equ equ32_mmu_section_inner_wt,          0b1000                 @ C[3], B[2]
.equ equ32_mmu_section_inner_wb_nowa,     0b1100                 @ C[3], B[2]
.equ equ32_mmu_section_outer_none,        0b100000000000000      @ TEX[14:12]
.equ equ32_mmu_section_outer_wb_wa,       0b101000000000000      @ TEX[14:12]
.equ equ32_mmu_section_outer_wt,          0b110000000000000      @ TEX[14:12]
.equ equ32_mmu_section_outer_wb_nowa,     0b111000000000000      @ TEX[14:12]
.equ equ32_mmu_section_access_none,       0b0000000000000000     @ APX[15] and AP[11:10]
.equ equ32_mmu_section_access_rw_none,    0b0000010000000000     @ APX[15] and AP[11:10], Privilege Access Only
.equ equ32_mmu_section_access_rw_r,       0b0000100000000000     @ APX[15] and AP[11:10]
.equ equ32_mmu_section_access_rw_rw,      0b0000110000000000     @ APX[15] and AP[11:10]
.equ equ32_mmu_section_access_r_none,     0b1000010000000000     @ APX[15] and AP[11:10], Privilege Access Only
.equ equ32_mmu_section_shareable,         0b10000000000000000    @ S[16], Shareable Memory, Seems Outer (Devices)
.equ equ32_mmu_section_nonglobal,         0b100000000000000000   @ nG[17], Non-global
.equ equ32_mmu_supersection,              0b1000000000000000000  @ [18], Bit[8:5] are PA[39:36], Bit[23:20] are PA[35:32]
.equ equ32_mmu_section_nonsecure,         0b10000000000000000000 @ NS[19]
.equ equ32_mmu_ecc,                       0b1000000000           @ P[9], ECC (Error Check and Correct), If Implemented
.equ equ32_mmu_domain00,                  0b000000000 @ Domain[8:5], Common on section and page (1st Level)
.equ equ32_mmu_domain01,                  0b000100000 @ Domain[8:5]
.equ equ32_mmu_domain02,                  0b001000000 @ Domain[8:5]
.equ equ32_mmu_domain03,                  0b001100000 @ Domain[8:5]
.equ equ32_mmu_domain04,                  0b010000000 @ Domain[8:5]
.equ equ32_mmu_domain05,                  0b010100000 @ Domain[8:5]
.equ equ32_mmu_domain06,                  0b011000000 @ Domain[8:5]
.equ equ32_mmu_domain07,                  0b011100000 @ Domain[8:5]
.equ equ32_mmu_domain08,                  0b100000000 @ Domain[8:5]
.equ equ32_mmu_domain09,                  0b100100000 @ Domain[8:5]
.equ equ32_mmu_domain10,                  0b101000000 @ Domain[8:5]
.equ equ32_mmu_domain11,                  0b101100000 @ Domain[8:5]
.equ equ32_mmu_domain12,                  0b110000000 @ Domain[8:5]
.equ equ32_mmu_domain13,                  0b110100000 @ Domain[8:5]
.equ equ32_mmu_domain14,                  0b111000000 @ Domain[8:5]
.equ equ32_mmu_domain15,                  0b111100000 @ Domain[8:5]

/* Second Level Descriptor of Large Page (64K Bytes) and Small Page (4K Bytes) */

.equ equ32_mmu_second_fault,                 0b00 @ [1:0] 2nd Level Descriptor 
.equ equ32_mmu_second_large,                 0b01 @ [1:0] Indexed by Bit[19:16] of Virtual Address, Bit[31:16] becomes Physical
.equ equ32_mmu_second_small,                 0b10 @ [1:0] Indexed by Bit[19:12] of Virtual Address, Bit[31:12] becomes Physical
.equ equ32_mmu_second_small_xn,              0b1  @ XN[0]
.equ equ32_mmu_second_large_xn,              0b1000000000000000 @ XN[15]
.equ equ32_mmu_second_stronglyordered,       0b0000 @ C[3], B[2], Cacheable, Bufferable, Common on small/large page
.equ equ32_mmu_second_device,                0b0100 @ C[3], B[2]
.equ equ32_mmu_second_inner_none,            0b0000 @ C[3], B[2]
.equ equ32_mmu_second_inner_wb_wa,           0b0100 @ C[3], B[2]
.equ equ32_mmu_second_inner_wt,              0b1000 @ C[3], B[2]
.equ equ32_mmu_second_inner_wb_nowa,         0b1100 @ C[3], B[2]
.equ equ32_mmu_second_small_outer_none,      0b100000000 @ TEX[8:6]
.equ equ32_mmu_second_small_outer_wb_wa,     0b101000000 @ TEX[8:6]
.equ equ32_mmu_second_small_outer_wt,        0b110000000 @ TEX[8:6]
.equ equ32_mmu_second_small_outer_wb_nowa,   0b111000000 @ TEX[8:6]
.equ equ32_mmu_second_large_outer_none,      0b100000000000000 @ TEX[14:12]
.equ equ32_mmu_second_large_outer_wb_wa,     0b101000000000000 @ TEX[14:12]
.equ equ32_mmu_second_large_outer_wt,        0b110000000000000 @ TEX[14:12]
.equ equ32_mmu_second_large_outer_wb_nowa,   0b111000000000000 @ TEX[14:12]
.equ equ32_mmu_second_access_none,           0b0000000000 @ APX[9] and AP[5:4], Common on small/large page
.equ equ32_mmu_second_access_rw_none,        0b0000010000 @ APX[9] and AP[5:4], Privilege Access Only
.equ equ32_mmu_second_access_rw_r,           0b0000100000 @ APX[9] and AP[5:4]
.equ equ32_mmu_second_access_rw_rw,          0b0000110000 @ APX[9] and AP[5:4]
.equ equ32_mmu_second_access_r_none,         0b1000010000 @ APX[9] and AP[5:4], Privilege Access Only
.equ equ32_mmu_second_shareable,             0b10000000000 @ S[10], Shareable Memory, Common on small/large
.equ equ32_mmu_second_nonglobal,             0b100000000000 @ nG[11], Non-global, Common on small/large


/* Translation Table Base Register (TTBR0/TTBR1), Banked by Secure/Non-secure `MRC/MCR p15, 0, <Rt>, c2, c0, 0/1` */
.equ equ32_ttbr_share,                0b10      @ [1] Translation Table Walk To Shared Memory, Otherwise, Non-shared Memory
.equ equ32_ttbr_share_inner,          0b100000  @ NOS[5], Not Outer Shareable
.equ equ32_ttbr_inner_none,           0b0000000 @ IRGN-0[6], IRNG-1[0], For Translation Table Walk
.equ equ32_ttbr_inner_wb_wa,          0b1000000 @ IRGN-0[6], IRNG-1[0], For Translation Table Walk
.equ equ32_ttbr_inner_wt,             0b0000001 @ IRGN-0[6], IRNG-1[0], For Translation Table Walk
.equ equ32_ttbr_inner_wb_nowa,        0b1000001 @ IRGN-0[6], IRNG-1[0], For Translation Table Walk
.equ equ32_ttbr_outer_none,           0b00000   @ RGN[4:3], For Translation Table Walk
.equ equ32_ttbr_outer_wb_wa,          0b01000   @ RGN[4:3], For Translation Table Walk
.equ equ32_ttbr_outer_wt,             0b10000   @ RGN[4:3], For Translation Table Walk
.equ equ32_ttbr_outer_wb_nowa,        0b11000   @ RGN[4:3], For Translation Table Walk

/* Translation Table Base Control Register (TTBCR), Banked by Secure/Non-secure `MRC/MCR p15, 0, <Rt>, c2, c0, 2` */
.equ equ32_ttbcr_n0,   0b000    @ N[2:0], Width of Base Address, Which Determines Usage of TTBR0 and TTBR1, If n0, TTBR0 Only
.equ equ32_ttbcr_n1,   0b001    @ N[2:0], Width of Base Address, Which Determines Usage of TTBR0 and TTBR1, Upper Address Uses TTBR1
.equ equ32_ttbcr_n2,   0b010    @ N[2:0], Width of Base Address, Which Determines Usage of TTBR0 and TTBR1, Upper Address Uses TTBR1
.equ equ32_ttbcr_n3,   0b011    @ N[2:0], Width of Base Address, Which Determines Usage of TTBR0 and TTBR1, Upper Address Uses TTBR1
.equ equ32_ttbcr_n4,   0b100    @ N[2:0], Width of Base Address, Which Determines Usage of TTBR0 and TTBR1, Upper Address Uses TTBR1
.equ equ32_ttbcr_n5,   0b101    @ N[2:0], Width of Base Address, Which Determines Usage of TTBR0 and TTBR1, Upper Address Uses TTBR1
.equ equ32_ttbcr_n6,   0b110    @ N[2:0], Width of Base Address, Which Determines Usage of TTBR0 and TTBR1, Upper Address Uses TTBR1
.equ equ32_ttbcr_n7,   0b111    @ N[2:0], Width of Base Address, Which Determines Usage of TTBR0 and TTBR1, Upper Address Uses TTBR1
.equ equ32_ttbcr_pd0,  0b10000  @ PD0[4], Translation Table Walk Disable, TTBR0
.equ equ32_ttbcr_pdl,  0b100000 @ PD0[5], Translation Table Walk Disable, TTBR1
.equ equ32_ttbcr_eae,  0x80000000 @ EAE[31], Extended Address Enable, Use 64-bit Long Descriptor Translation Table Format, If Zero, 32-bit Short Descriptor Format

/**
 * Hyp Translation Control Register(HTCR) `MRC/MCR p15, 4, <Rt>, c2, c0, 2`
 * In ARMv7/AArch32, Vitrual Address on Hyp Mode is basically treated by TTBR0.
 * Beside, From ARMv7-A, Stage 1/2 Address Translation is Introduced with HTTBR(64-bit)/VTTBR(64-bit)/VTCR (32-bit)
 * The System, HTTBR/VTTBR, Has Two Stage Translation, e.g., Using Intermediate Physical Address (IPA) for
 * Virtualization of Other CPU/OS System. Note that Coretex-A53 Uses TTBR0 for HTCR and VCTR, and does not have HTTBR and VTTBR.
 */
.equ equ32_htcr_size0,           0b000 @ T0SZ[2:0], Size offset of Base Address by TTBR0 (For Long Descriptor Translation Table Format)
.equ equ32_htcr_size1,           0b001 @ T0SZ[2:0], Size offset of Base Address by TTBR0 (For Long Descriptor Translation Table Format)
.equ equ32_htcr_size2,           0b010 @ T0SZ[2:0], Size offset of Base Address by TTBR0 (For Long Descriptor Translation Table Format)
.equ equ32_htcr_size3,           0b011 @ T0SZ[2:0], Size offset of Base Address by TTBR0 (For Long Descriptor Translation Table Format)
.equ equ32_htcr_size4,           0b100 @ T0SZ[2:0], Size offset of Base Address by TTBR0 (For Long Descriptor Translation Table Format)
.equ equ32_htcr_size5,           0b101 @ T0SZ[2:0], Size offset of Base Address by TTBR0 (For Long Descriptor Translation Table Format)
.equ equ32_htcr_size6,           0b110 @ T0SZ[2:0], Size offset of Base Address by TTBR0 (For Long Descriptor Translation Table Format)
.equ equ32_htcr_size7,           0b111 @ T0SZ[2:0], Size offset of Base Address by TTBR0 (For Long Descriptor Translation Table Format)
.equ equ32_htcr_inner_none,      0b0000000000 @ IRGN0[9:8], Inner Cacheability, No Cache
.equ equ32_htcr_inner_wb_wa,     0b0100000000 @ IRGN0[9:8], Inner Cacheability, Write Back, Write Allocate
.equ equ32_htcr_inner_wt,        0b1000000000 @ IRGN0[9:8], Inner Cacheability, Write Throught, No Write Allocate
.equ equ32_htcr_inner_wb_nowa,   0b1100000000 @ IRGN0[9:8], Inner Cacheability, Write Back, No Write Allocate
.equ equ32_htcr_outer_none,      0b000000000000 @ ORGN0[11:10], Outer Cacheability, No Cache
.equ equ32_htcr_outer_wb_wa,     0b010000000000 @ ORGN0[11:10], Outer Cacheability, Write Back, Write Allocate
.equ equ32_htcr_outer_wt,        0b100000000000 @ ORGN0[11:10], Outer Cacheability, Write Throught, No Write Allocate
.equ equ32_htcr_outer_wb_nowa,   0b110000000000 @ ORGN0[11:10], Outer Cacheability, Write Back, No Write Allocate
.equ equ32_htcr_share_none,      0b00000000000000 @ SH0[13:12], Outer Cacheability, Write Back, No Write Allocate
.equ equ32_htcr_share_outer,     0b10000000000000 @ SH0[13:12], Outer Cacheability, Write Back, No Write Allocate
.equ equ32_htcr_share_inner,     0b11000000000000 @ SH0[13:12], Outer Cacheability, Write Back, No Write Allocate

.equ equ32_user_mode,   0x10 @ 0b00010000 User mode (not priviledged)
.equ equ32_fiq_mode,    0x11 @ 0b00010001 Fast Interrupt Request (FIQ) mode
.equ equ32_irq_mode,    0x12 @ 0b00010010 Interrupt Request (IRQ) mode
.equ equ32_svc_mode,    0x13 @ 0b00010011 Supervisor mode
.equ equ32_mon_mode,    0x16 @ 0b00010110 Secure Monitor mode
.equ equ32_abt_mode,    0x17 @ 0b00010111 Abort mode for prefetch and data abort exception
.equ equ32_hyp_mode,    0x1A @ 0b00011010 Hypervisor mode
.equ equ32_und_mode,    0x1B @ 0b00011011 Undefined mode for undefined instruction exception
.equ equ32_sys_mode,    0x1F @ 0b00011111 System mode

.equ equ32_thumb,           0x20  @ 0b00100000
.equ equ32_fiq_disable,     0x40  @ 0b01000000
.equ equ32_irq_disable,     0x80  @ 0b10000000
.equ equ32_abort_disable,   0x100 @ 0b100000000
