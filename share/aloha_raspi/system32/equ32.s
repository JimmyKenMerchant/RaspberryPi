/**
 * equ32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Constants
 */

.equ equ32_tab_length,   4

/**
 * Standard Peripherals
 */

.ifdef __BCM2835
	.equ equ32_peripherals_base,   0x20000000
.else
	/* BCM2836 and BCM2837 Peripheral Base */
	.equ equ32_peripherals_base,   0x3F000000
.endif
.equ equ32_systemtimer_base,   0x00003000
.equ equ32_interrupt_base,     0x0000B200
.equ equ32_armtimer_base,      0x0000B400
.equ equ32_gpio_base,          0x00200000
.equ equ32_dma0_base,          0x00007000
.equ equ32_usb20_otg_base,     0x00980000

.equ equ32_i2c0_base_upper,    0x00200000
.equ equ32_i2c0_base_lower,    0x00005000
.equ equ32_i2c1_base_upper,    0x00800000
.equ equ32_i2c1_base_lower,    0x00004000
.equ equ32_i2c2_base_upper,    0x00800000
.equ equ32_i2c2_base_lower,    0x00005000
.equ equ32_pwm_base_upper,     0x00200000
.equ equ32_pwm_base_lower,     0x0000C000
.equ equ32_dma15_base_upper,   0x00E00000
.equ equ32_dma15_base_lower,   0x00005000
.equ equ32_cm_base_upper,      0x00100000 @ Clock Manager
.equ equ32_cm_base_lower,      0x00001000 @ Clock Manager

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

.equ equ32_gpio_gpfsel00,     0x00 @ GPIO 0-9   Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel10,     0x04 @ GPIO 10-19 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel20,     0x08 @ GPIO 20-29 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel30,     0x0C @ GPIO 30-39 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel40,     0x10 @ GPIO 40-49 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel50,     0x14 @ GPIO 50-53 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions

.equ equ32_gpio_gpfsel_0,     0  @ LSL
.equ equ32_gpio_gpfsel_1,     3  @ LSL
.equ equ32_gpio_gpfsel_2,     6  @ LSL
.equ equ32_gpio_gpfsel_3,     9  @ LSL
.equ equ32_gpio_gpfsel_4,     12 @ LSL
.equ equ32_gpio_gpfsel_5,     15 @ LSL
.equ equ32_gpio_gpfsel_6,     18 @ LSL
.equ equ32_gpio_gpfsel_7,     21 @ LSL
.equ equ32_gpio_gpfsel_8,     24 @ LSL
.equ equ32_gpio_gpfsel_9,     27 @ LSL

.equ equ32_gpio_gpfsel_input,    0b000
.equ equ32_gpio_gpfsel_output,   0b001
.equ equ32_gpio_gpfsel_alt0,     0b100
.equ equ32_gpio_gpfsel_alt1,     0b101
.equ equ32_gpio_gpfsel_alt2,     0b110
.equ equ32_gpio_gpfsel_alt3,     0b111
.equ equ32_gpio_gpfsel_alt4,     0b011
.equ equ32_gpio_gpfsel_alt5,     0b010
.equ equ32_gpio_gpfsel_clear,    0b111

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

.equ equ32_pwm_ctl,      0x00000000
.equ equ32_pwm_sta,      0x00000004
.equ equ32_pwm_dmac,     0x00000008
.equ equ32_pwm_rng1,     0x00000010
.equ equ32_pwm_dat1,     0x00000014
.equ equ32_pwm_fif1,     0x00000018
.equ equ32_pwm_rng2,     0x00000020
.equ equ32_pwm_dat2,     0x00000024

.equ equ32_pwm_ctl_msen2,   0x00008000 @ Channel2 M/S Enable
.equ equ32_pwm_ctl_usef2,   0x00002000 @ Channel2 M/S Use FIFO
.equ equ32_pwm_ctl_pola2,   0x00001000 @ Channel2 Polarity Invert
.equ equ32_pwm_ctl_sbit2,   0x00000800 @ Channel2 Silence Bit
.equ equ32_pwm_ctl_rptl2,   0x00000400 @ Channel2 Repeat Last Data (When FIFO)
.equ equ32_pwm_ctl_mode2,   0x00000200 @ Channel2 Mode PWM (0) or Serialiser (1)
.equ equ32_pwm_ctl_pwen2,   0x00000100 @ Channel2 Enable
.equ equ32_pwm_ctl_msen1,   0x00000080 @ Channel1 M/S Enable
.equ equ32_pwm_ctl_clrf1,   0x00000040 @ Channel1 Clear FIFO
.equ equ32_pwm_ctl_usef1,   0x00000020 @ Channel1 M/S Use FIFO
.equ equ32_pwm_ctl_pola1,   0x00000010 @ Channel1 Polarity Invert
.equ equ32_pwm_ctl_sbit1,   0x00000008 @ Channel1 Silence Bit
.equ equ32_pwm_ctl_rptl1,   0x00000004 @ Channel1 Repeat Last Data (When FIFO)
.equ equ32_pwm_ctl_mode1,   0x00000002 @ Channel1 Mode PWM (0) or Serialiser (1)
.equ equ32_pwm_ctl_pwen1,   0x00000001 @ Channel1 Enable

.equ equ32_pwm_sta_sta4,     0x00001000 @ Channel4 State
.equ equ32_pwm_sta_sta3,     0x00000800 @ Channel3 State
.equ equ32_pwm_sta_sta2,     0x00000400 @ Channel2 State
.equ equ32_pwm_sta_sta1,     0x00000200 @ Channel1 State
.equ equ32_pwm_sta_berr,     0x00000100 @ Bus Error Flag, Write-clear
.equ equ32_pwm_sta_gapo4,    0x00000080 @ Channel4 State Gap Occurred Flag, Write-clear
.equ equ32_pwm_sta_gapo3,    0x00000040 @ Channel3 State Gap Occurred Flag, Write-clear
.equ equ32_pwm_sta_gapo2,    0x00000020 @ Channel2 State Gap Occurred Flag, Write-clear
.equ equ32_pwm_sta_gapo1,    0x00000010 @ Channel1 State Gap Occurred Flag, Write-clear
.equ equ32_pwm_sta_rerr1,    0x00000008 @ FIFO Read Error Flag, Write-clear
.equ equ32_pwm_sta_werr1,    0x00000004 @ FIFO Write Error Flag, Write-clear
.equ equ32_pwm_sta_empt1,    0x00000002 @ FIFO Empty Flag
.equ equ32_pwm_sta_full1,    0x00000001 @ FIFO Full Flag

.equ equ32_dma0_channel_offset,       0x00000100 @ Channel 0-14
.equ equ32_dma_channel_int_status,    0x00000FE0 @ Channel 0-15 Interrupt Status
.equ equ32_dma_channel_enable,        0x00000FF0 @ Channel 0-15 Global Enable Bits
.equ equ32_dma_cs,                    0x00000000 @ DMA Channel0 Control and Status
.equ equ32_dma_conblk_ad,             0x00000004 @ DMA Channel0 Control Block (CB) Address
.equ equ32_dma_ti,                    0x00000008 @ DMA Channel0 CB Word0 (Transfer Information)
.equ equ32_dma_source_ad,             0x0000000C @ DMA Channel0 CB Word1 (Source Address)
.equ equ32_dma_dest_ad,               0x00000010 @ DMA Channel0 CB Word2 (Destination Address)
.equ equ32_dma_txfr_len,              0x00000014 @ DMA Channel0 CB Word3 (Transfer Length)
.equ equ32_dma_stride,                0x00000018 @ DMA Channel0 CB Word4 (2D Stride)
.equ equ32_dma_nextconbk,             0x0000001C @ DMA Channel0 CB Word5 (Next CB Address)
.equ equ32_dma_debug,                 0x00000020 @ DMA Channel0 Debug

.equ equ32_cm_gp0ctl,          0x00000070 @ Clock Manager General Purpose 0 (GPO) Clock Control
.equ equ32_cm_gp0div,          0x00000074 @ Clock Manager General Purpose 0 (GPO) Clock Divisor
.equ equ32_cm_gp1ctl,          0x00000078 @ Clock Manager General Purpose 1 (GP1) Clock Control
.equ equ32_cm_gp1div,          0x0000007C @ Clock Manager General Purpose 1 (GP1) Clock Divisor
.equ equ32_cm_gp2ctl,          0x00000080 @ Clock Manager General Purpose 2 (GP2) Clock Control
.equ equ32_cm_gp2div,          0x00000084 @ Clock Manager General Purpose 2 (GP2) Clock Divisor
.equ equ32_cm_pwmctl,          0x000000A0 @ Clock Manager PWM Clock Control
.equ equ32_cm_pwmdiv,          0x000000A4 @ Clock Manager PWM Clock Divisor

.equ equ32_cm_passwd,              0x5A000000 @ Password of Clock Manager, To Write, Set This on CTL and DIV Registers

.equ equ32_cm_ctl_mash_0,          0x00000000 @ Integer Division
.equ equ32_cm_ctl_mash_1,          0x00000200 @ 1-stage Mash
.equ equ32_cm_ctl_mash_2,          0x00000400 @ 2-stage Mash
.equ equ32_cm_ctl_mash_3,          0x00000600 @ 3-stage Mash
.equ equ32_cm_ctl_flip,            0x00000100 @ Invert Output
.equ equ32_cm_ctl_busy,            0x00000080 @ Running
.equ equ32_cm_ctl_kill,            0x00000020 @ Kill
.equ equ32_cm_ctl_enab,            0x00000010 @ Enable
.equ equ32_cm_ctl_src_gnd,         0x00000000 @ GND (0 Hz)
.equ equ32_cm_ctl_src_osc,         0x00000001 @ Oscillator (19.2Mhz)
.equ equ32_cm_ctl_src_deb0,        0x00000002 @ Test Debug 0 (0 Hz)
.equ equ32_cm_ctl_src_deb1,        0x00000003 @ Test Debug 1 (0 Hz)
.equ equ32_cm_ctl_src_plla,        0x00000004 @ PLL A (0Hz?)
.equ equ32_cm_ctl_src_pllc,        0x00000005 @ PLL C (1000Mhz but depends on CPU Clock?)
.equ equ32_cm_ctl_src_plld,        0x00000006 @ PLL D (500Mhz)
.equ equ32_cm_ctl_src_hdmi,        0x00000007 @ HDMI Auxiliary (216Mhz?)

.equ equ32_cm_div_integer,     12 @ LSL Bit[23:12]


/**
 * USB2.0 On-the-Go (OTG)
 *
 * USB Implementers Forum (USB-IF) introduced OTG hardware specification for USB2.0 in 2001,
 * which allows to connect each USB device without any personal computer.
 * In contrast of Enhanced Host Controller Interface (EHCI) specification and its families introduced by Intel and USB-IF,
 * Host/Device Interfaces for OTG had not been ruled on the standard of Control and Status Registers (CSRs).
 * On mobile sector, this issue had prevented spreading usage of OTG.
 * But around 2010, CSRs of OTG seemed to be integrated among chip vendors with ARM architecture
 * to spread usage of OTG, and to develop its drivers in OSs for mobile sector.
 * So we can fortunately write a driver of OTG generically.
 */

/* Core Global Control and Status Registers (CSRs) */
.equ equ32_usb20_otg_gotgctl,        0x00000000 @ Global OTG Control (and Status)
.equ equ32_usb20_otg_gotgint,        0x00000004 @ Global OTG Interrupt
.equ equ32_usb20_otg_gahbcfg,        0x00000008 @ Global Advanced High-performance Bus (AHB: Internal Bus) Configuration
.equ equ32_usb20_otg_gusbcfg,        0x0000000C @ Global USB Configuration
.equ equ32_usb20_otg_grstctl,        0x00000010 @ Global Reset Control
.equ equ32_usb20_otg_gintsts,        0x00000014 @ Global Interrupt Status
.equ equ32_usb20_otg_gintmsk,        0x00000018 @ Global Interrupt Mask
.equ equ32_usb20_otg_grxstsr,        0x0000001C @ Global Receive Status Read (Debug)
.equ equ32_usb20_otg_grxstsp,        0x00000020 @ Global Receive Status Pop
.equ equ32_usb20_otg_grxfsiz,        0x00000024 @ Global Receive FIFO Size
.equ equ32_usb20_otg_gnptxfsiz,      0x00000028 @ Global Non-periodic Transmit FIFO Size
.equ equ32_usb20_otg_gnptxsts,       0x0000002C @ Global Non-periodic Transmit (FIFO/Queue) Status
.equ equ32_usb20_otg_gi2cctl,        0x00000030 @ Global I2C Control
.equ equ32_usb20_otg_gpvndctl,       0x00000034 @ Global PHY Vendor Control
.equ equ32_usb20_otg_ggpio,          0x00000038 @ Global General Purpose Input/Output
.equ equ32_usb20_otg_guid,           0x0000003C @ Global User ID
.equ equ32_usb20_otg_grsv,           0x00000040 @ Global Reserved
.equ equ32_usb20_otg_ghwcfg1,        0x00000044 @ Global User HW Config1
.equ equ32_usb20_otg_ghwcfg2,        0x00000048 @ Global User HW Config2
.equ equ32_usb20_otg_ghwcfg3,        0x0000004C @ Global User HW Config3
.equ equ32_usb20_otg_ghwcfg4,        0x00000050 @ Global User HW Config4
.equ equ32_usb20_otg_pcgctl,         0x00000E00 @ Power and Clock Gating Control

/* Vendor-specific Extra Registers (Base is the same as Core Global CSRs) */
.equ equ32_bcm_usb20_mdio_cntl,      0x00000080 @ MDIO Interface Control (BCM2835-2837)
.equ equ32_bcm_usb20_mdio_gen,       0x00000084 @ Data for MDIO Interfaace (BCM2835-2837)
.equ equ32_bcm_usb20_vbus_drv,       0x00000088 @ Vbus and Other Miscellaneous Controls (BCM2835-2837)

.equ equ32_usb20_otg_ptxfsiz_base,   0x00000100 @ Base of Periodic Transmit FIFO Size Registers (+ equ32_usb20_otg_base)
.equ equ32_usb20_otg_hptxfsiz,       0x00000000 @ Host Periodic Transmit FIFO Size
.equ equ32_usb20_otg_dptxfsiz1,      0x00000004 @ Device Periodic Transmit FIFO-1 Size
.equ equ32_usb20_otg_dptxfsiz2,      0x00000008 @ Device Periodic Transmit FIFO-2 Size
.equ equ32_usb20_otg_dptxfsiz3,      0x0000000C @ Device Periodic Transmit FIFO-3 Size
.equ equ32_usb20_otg_dptxfsiz4,      0x00000010 @ Device Periodic Transmit FIFO-4 Size
.equ equ32_usb20_otg_dptxfsiz5,      0x00000014 @ Device Periodic Transmit FIFO-5 Size
.equ equ32_usb20_otg_dptxfsiz6,      0x00000018 @ Device Periodic Transmit FIFO-6 Size
.equ equ32_usb20_otg_dptxfsiz7,      0x0000001C @ Device Periodic Transmit FIFO-7 Size
.equ equ32_usb20_otg_dptxfsiz8,      0x00000020 @ Device Periodic Transmit FIFO-8 Size
.equ equ32_usb20_otg_dptxfsiz9,      0x00000024 @ Device Periodic Transmit FIFO-9 Size
.equ equ32_usb20_otg_dptxfsiz10,     0x00000028 @ Device Periodic Transmit FIFO-10 Size
.equ equ32_usb20_otg_dptxfsiz11,     0x0000002C @ Device Periodic Transmit FIFO-11 Size
.equ equ32_usb20_otg_dptxfsiz12,     0x00000030 @ Device Periodic Transmit FIFO-12 Size
.equ equ32_usb20_otg_dptxfsiz13,     0x00000034 @ Device Periodic Transmit FIFO-13 Size
.equ equ32_usb20_otg_dptxfsiz14,     0x00000038 @ Device Periodic Transmit FIFO-14 Size
.equ equ32_usb20_otg_dptxfsiz15,     0x0000003C @ Device Periodic Transmit FIFO-15 Size

/* Host Mode Control and Status Registers (CSRs) */
.equ equ32_usb20_otg_host_base,            0x00000400 @ Base of Host Global Registers (+ equ32_usb20_otg_base)
.equ equ32_usb20_otg_hcfg,                 0x00000000 @ Host Configuration
.equ equ32_usb20_otg_hfir,                 0x00000004 @ Host Frame Interval
.equ equ32_usb20_otg_hfnum,                0x00000008 @ Host Frame Number (and Frame Time Remaining)
.equ equ32_usb20_otg_hrsv,                 0x0000000C @ Host Reserved
.equ equ32_usb20_otg_hptxsts,              0x00000010 @ Host Periodic Transmit (FIFO/Queue) Status
.equ equ32_usb20_otg_haint,                0x00000014 @ Host All Channels Interrupt
.equ equ32_usb20_otg_haintmsk,             0x00000018 @ Host All Channels Interrupt Mask
.equ equ32_usb20_otg_hprt,                 0x00000040 @ Host Port Control and Status
.equ equ32_usb20_otg_hostchannel_base,     0x00000500 @ Base of Host Channel Registers
.equ equ32_usb20_otg_hostchannel_offset,   0x00000020 @ Offset of Host Channel N Registers N = 0-15
.equ equ32_usb20_otg_hccharn,              0x00000000 @ Host Channel N Characteristics
.equ equ32_usb20_otg_hcspltn,              0x00000004 @ Host Channel N Split Control
.equ equ32_usb20_otg_hcintn,               0x00000008 @ Host Channel N Interrupt
.equ equ32_usb20_otg_hcintmskn,            0x0000000C @ Host Channel N Interrupt Mask
.equ equ32_usb20_otg_hctsizn,              0x00000010 @ Host Channel N Transfer Size
.equ equ32_usb20_otg_hcdman,               0x00000014 @ Host Channel N DMA Address
.equ equ32_usb20_otg_hcrsv1n,              0x00000018 @ Host Channel Reserved1
.equ equ32_usb20_otg_hcrsv2n,              0x0000001C @ Host Channel Reserved2

/* Device Mode Control and Status Registers (CSRs) */

/* Standard Device Request */

/* bmRequestType (1 Byte, Offset 0) */
.equ equ32_usb20_reqt_recipient_device,      0b00000000
.equ equ32_usb20_reqt_recipient_interface,   0b00000001
.equ equ32_usb20_reqt_recipient_endpoint,    0b00000010
.equ equ32_usb20_reqt_recipient_other,       0b00000011
.equ equ32_usb20_reqt_type_standard,         0b00000000
.equ equ32_usb20_reqt_type_class,            0b00100000
.equ equ32_usb20_reqt_type_vendor,           0b01000000
.equ equ32_usb20_reqt_host_to_device,        0b00000000 @ Out
.equ equ32_usb20_reqt_device_to_host,        0b10000000 @ In

/* bRequest (1 Byte, Offset 1, << 8) */
.equ equ32_usb20_req_get_status,             0x00
.equ equ32_usb20_req_clear_feature,          0x01
.equ equ32_usb20_req_set_feature,            0x03
.equ equ32_usb20_req_set_address,            0x05
.equ equ32_usb20_req_get_descriptor,         0x06
.equ equ32_usb20_req_set_descriptor,         0x07
.equ equ32_usb20_req_get_configuration,      0x08
.equ equ32_usb20_req_set_configuration,      0x09
.equ equ32_usb20_req_get_interface,          0x0A
.equ equ32_usb20_req_set_interface,          0x0B
.equ equ32_usb20_req_synch_frame,            0x0C

.equ equ32_usb20_req_hid_get_report,         0x01
.equ equ32_usb20_req_hid_get_idle,           0x02
.equ equ32_usb20_req_hid_get_protocol,       0x03
.equ equ32_usb20_req_hid_set_report,         0x09
.equ equ32_usb20_req_hid_set_idle,           0x0A
.equ equ32_usb20_req_hid_set_protocol,       0x0B

/* wValue (2 Bytes, Offset 2, << 16) */
.equ equ32_usb20_val_get_status,             0x0000

.equ equ32_usb20_val_descriptor_device,                      0x0100 @ Lower 1 Byte is Index of Descriptor
.equ equ32_usb20_val_descriptor_configuration,               0x0200
.equ equ32_usb20_val_descriptor_string,                      0x0300
.equ equ32_usb20_val_descriptor_interface,                   0x0400 @ Recipient is Interface
.equ equ32_usb20_val_descriptor_endpoint,                    0x0500 @ Recipient is Endpoint
.equ equ32_usb20_val_descriptor_device_qualifier,            0x0600
.equ equ32_usb20_val_descriptor_other_speed_configuration,   0x0700
.equ equ32_usb20_val_descriptor_interface_power,             0x0800 @ Recipient is Interface
.equ equ32_usb20_val_descriptor_otg,                         0x0900 @ Session Request Protocol (SRP) and Host Negotiation Protocol
.equ equ32_usb20_val_descriptor_hid,                         0x2100
.equ equ32_usb20_val_descriptor_hidreport,                   0x2200
.equ equ32_usb20_val_descriptor_hidphysical,                 0x2300
.equ equ32_usb20_val_descriptor_hub,                         0x2900 @ Class Number of Ports (Offset 2 Bytes)

.equ equ32_usb20_val_hub_localpower,              0x0000 @ Status of Hub is similar to Value (+0x10 is change status)
.equ equ32_usb20_val_hub_overcurrent,             0x0001
.equ equ32_usb20_val_hubport_connection,          0x0000 @ Status of HubPort is similar to Upper 2 Bytes of Value
.equ equ32_usb20_val_hubport_enable,              0x0001
.equ equ32_usb20_val_hubport_suspend,             0x0002
.equ equ32_usb20_val_hubport_overcurrent,         0x0003
.equ equ32_usb20_val_hubport_reset,               0x0004
.equ equ32_usb20_val_hubport_power,               0x0008
.equ equ32_usb20_val_hubport_lowspeed,            0x0009
.equ equ32_usb20_val_hubport_highspeed,           0x000A
.equ equ32_usb20_val_hubport_connection_change,   0x0010 @ Connection Status is changed
.equ equ32_usb20_val_hubport_enable_change,       0x0011
.equ equ32_usb20_val_hubport_suspend_change,      0x0012
.equ equ32_usb20_val_hubport_overcurrent_change,  0x0013
.equ equ32_usb20_val_hubport_reset_change,        0x0014 @ Indicates Completion of Reset

.equ equ32_usb20_val_hid_report_input,            0x0100 @ Lower 1 Byte is Index of Report
.equ equ32_usb20_val_hid_report_output,           0x0200 @ Lower 1 Byte is Index of Report
.equ equ32_usb20_val_hid_report_feature,          0x0300 @ Lower 1 Byte is Index of Report
 
/* wIndex (2 Bytes, Offset 4, << 32), Indexing Interface, Endpoint, or Language ID*/
.equ equ32_usb20_index_device,            0x0000     @ Except indicating Language ID in descriptor, wIndex is zero in std.

/* wLength (2 Bytes, Offset 6, << 48) */
.equ equ32_usb20_len_get_status,          0x0002
.equ equ32_usb20_len_clear_feature,       0x0000
.equ equ32_usb20_len_set_feature,         0x0000
.equ equ32_usb20_len_set_address,         0x0000
.equ equ32_usb20_len_get_configuration,   0x0001
.equ equ32_usb20_len_get_configuration,   0x0000
.equ equ32_usb20_len_get_interface,       0x0001
.equ equ32_usb20_len_set_interface,       0x0000
.equ equ32_usb20_len_synch_frame,         0x0002


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