/**
 * dma32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.equ dma32_offset,                0x00000020 @ Offset of Each CB (32 Bytes)
.equ dma32_ti,                    0x00000000 @ Transfer Information
.equ dma32_source_ad,             0x00000004 @ Source Address
.equ dma32_dest_ad,               0x00000008 @ Destination Address
.equ dma32_txfr_len,              0x0000000C @ Transfer Length
.equ dma32_stride,                0x00000010 @ 2D Stride
.equ dma32_nextconbk,             0x00000014 @ Next CB Addres

.globl DMA32_CB
DMA32_CB:        .word DMA32_CB0_TI

.balign 32                        @ 32 Bytes (8 Words) Aligned
DMA32_CB0_TI:          .word 0x00
DMA32_CB0_SOURCE_AD:   .word 0x00
DMA32_CB0_DEST_AD:     .word 0x00
DMA32_CB0_TXFR_LEN:    .word 0x00
DMA32_CB0_STRIDE:      .word 0x00
DMA32_CB0_NEXTCONBK:   .word 0x00
.balign 32
DMA32_CB1_TI:          .word 0x00
DMA32_CB1_SOURCE_AD:   .word 0x00
DMA32_CB1_DEST_AD:     .word 0x00
DMA32_CB1_TXFR_LEN:    .word 0x00
DMA32_CB1_STRIDE:      .word 0x00
DMA32_CB1_NEXTCONBK:   .word 0x00
.balign 32
