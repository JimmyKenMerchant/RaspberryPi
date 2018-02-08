/**
 * system32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Functions which access memory-mapped peripherals may make missing of cache.
 * Make sure to use cache operations, clean/invalidate. Or `DSB/DMB/ISB`.
 * If you meet missig of cache, even you use cache operations, use cache operations of Set/Way type.
 */

.include "system32/equ32.s"
.include "system32/macro32.s"

/**
 * "vender_system32" is to be used for drivers of vendor-implemented peripherals. These usually don't have any standard,
 * So if you consider of compatibility with other ARM CPUs. Files in this section should be alternated with
 * other ones.
 */
.section	.vendor_system32

.include "system32/vendor/bcm32.s"

/**
 * "arm_system32" is to be used for drivers of ARM system registers, and standard peripherals,
 * USB, I2C, UART, etc. These are usually aiming compatibility with other ARM CPUs,
 * but memory mapping differs among CPUs. Addresses of peripherals in "equ32.s" should be changed. 
 */
.section	.arm_system32

.balign 4
.include "system32/arm/arm32.s"
.balign 4
.include "system32/arm/dma32.s"
.balign 4
.include "system32/arm/uart32.s"
.balign 4
.include "system32/arm/spi32.s"
.balign 4
.include "system32/arm/i2c32.s"
.balign 4
.include "system32/arm/usb2032.s"
.balign 4
.include "system32/arm/gpio32.s"
.balign 4
.include "system32/arm/vfp32.s"
.balign 4

/**
 * Place Label to First Address of Data Memory Section (including .bss)
 */

.section	.data
.globl SYSTEM32_DATAMEMORY_ADDR
.globl SYSTEM32_DATAMEMORY_SIZE
SYSTEM32_DATAMEMORY:                                         @ First of Data Memory
SYSTEM32_DATAMEMORY_ADDR: .word SYSTEM32_DATAMEMORY
SYSTEM32_DATAMEMORY_SIZE: .word SYSTEM32_DATAMEMORY_END - SYSTEM32_DATAMEMORY

.globl SYSTEM32_HEAP_NONCACHE_ADDR
.globl SYSTEM32_HEAP_NONCACHE_SIZE
SYSTEM32_HEAP_NONCACHE_ADDR: .word SYSTEM32_HEAP_NONCACHE
SYSTEM32_HEAP_NONCACHE_SIZE: .word SYSTEM32_HEAP_NONCACHE_END - SYSTEM32_HEAP_NONCACHE

.globl SYSTEM32_NONCACHE_ADDR
.globl SYSTEM32_NONCACHE_SIZE
SYSTEM32_NONCACHE_ADDR: .word SYSTEM32_NONCACHE
SYSTEM32_NONCACHE_SIZE: .word SYSTEM32_NONCACHE_END - SYSTEM32_NONCACHE

/**
 * "library_system32" is to be used for libraries, Drawing, Sound, Color, Font, etc. which have
 * compatibility with other ARM CPUs. 
 */
.section	.library_system32

.balign 4
.include "system32/library/fb32.s"            @ Having Section .data
.balign 4
.include "system32/library/print32.s"
.balign 4
.include "system32/library/str32.s"
.balign 4
.include "system32/library/draw32.s"
.balign 4
.include "system32/library/snd32.s"
.balign 4
.include "system32/library/math32.s"
.balign 4
.include "system32/library/cvt32.s"
.balign 4
.include "system32/library/bcd32.s"
.balign 4
.include "system32/library/heap32.s"
.balign 4
.include "system32/library/hid32.s"
.balign 4
.include "system32/library/font_mono_12px.s"
.balign 4
.include "system32/library/color.s"
.balign 4
.include "system32/library/data.s"            @ Having Section .data
.balign 4

.section	.bss

.balign 16

SYSTEM32_HEAP:
.space 16777216                       @ Filled With Zero in Default, 16M Bytes
SYSTEM32_HEAP_NONCACHE:
.space 1048576                        @ 1M Bytes
SYSTEM32_HEAP_NONCACHE_END:
SYSTEM32_HEAP_END:

/**
 * Initial SVC Mode: 0x4000 (-0x200 Offset by Core ID)
 * Initial Hyp Mode: 0x5000 (-0x200 Offset by Core ID)
 * Initial Mon Mode: 0x6000 (-0x200 Offset by Core ID)
 * OS Undefined Mode: 0x7200
 * OS Supervisor Mode: 0x7400
 * OS Abort Mode: 0x7600
 * OS IRQ Mode: 0x7800
 * OS FIQ Mode: 0x8000
 *
 * OS User/System Mode Uses SYSTEM32_STACKPOINTER
 */
.globl SYSTEM32_STACKPOINTER
SYSTEM32_STACKPOINTER_TOP:         .space 65536
SYSTEM32_STACKPOINTER:

SYSTEM32_DATAMEMORY_END:

.section	.va_system32          @ 16K Bytes Align for Each Descriptor on Reset

SYSTEM32_VADESCRIPTOR:
.space 262144                         @ Filled With Zero in Default, 256K Bytes
SYSTEM32_VADESCRIPTOR_END:

.section	.noncache_system32

SYSTEM32_NONCACHE:
.balign 32                        @ 32 Bytes (8 Words) Aligned
_DMA32_CB:
.space 32 * equ32_dma32_cb_max

SYSTEM32_NONCACHE_END:
