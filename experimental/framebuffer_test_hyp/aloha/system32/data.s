/**
 * data.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

.globl DATA_COLOR32_SAMPLE_IMAGE0
.globl DATA_COLOR32_SAMPLE_IMAGE0_SIZE
DATA_COLOR32_SAMPLE_IMAGE0: .word _DATA_COLOR32_SAMPLE_IMAGE0
DATA_COLOR32_SAMPLE_IMAGE0_SIZE: .word _DATA_COLOR32_SAMPLE_IMAGE0_END - _DATA_COLOR32_SAMPLE_IMAGE0

.globl DATA_COLOR32_SAMPLE_IMAGE1
.globl DATA_COLOR32_SAMPLE_IMAGE1_SIZE
DATA_COLOR32_SAMPLE_IMAGE1: .word _DATA_COLOR32_SAMPLE_IMAGE1
DATA_COLOR32_SAMPLE_IMAGE1_SIZE: .word _DATA_COLOR32_SAMPLE_IMAGE1_END - _DATA_COLOR32_SAMPLE_IMAGE1

.section	.data

_DATA_COLOR32_SAMPLE_IMAGE0:
.incbin "system32/data/bugufo_abgr.bin"          @ Little Endian, ABGR Style
_DATA_COLOR32_SAMPLE_IMAGE0_END:
_DATA_COLOR32_SAMPLE_IMAGE1:
.incbin "system32/data/moonsymbol_abgr.bin"      @ Little Endian, ABGR Style
_DATA_COLOR32_SAMPLE_IMAGE1_END:
