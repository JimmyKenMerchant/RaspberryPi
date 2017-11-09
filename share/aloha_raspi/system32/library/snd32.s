/**
 * snd32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


SND32_DMA_CB_FRONT_MEMORY: .word 0x00 @ Max. 4095
SND32_DMA_CB_BACK_MEMORY:  .word 0x00 @ Max. 4095
SND32_DMA_CB_NOISE:        .word 0x00

SND32_CODE:                .word 0x00 @ Pointer of Music Code, If End, Automatically Cleared
SND32_LENGTH:              .word 0x00 @ Length of Music Code, If End, Automatically Cleared
SND32_COUNT:               .word 0x00 @ Incremental Count, Once Music Code Reaches Last, This Value will Be Reset
SND32_REPEAT:              .word 0x00 @ -1 is Infinite Loop
SND32_STATUS:              .word 0x00 @ Bit[0] Started, Bit[1] CB Back is Active, Bit[2] Same Value Before, Bit[31] Initialized

/**
 * Usage
 * 1. Make sure to place `snd32_soundinit` on the end of `os_reset` in vector32.s.
 * 2. Place `snd32_soundplay` and `snd32_sounddecode` on FIQ/IRQ Handler which will be triggered with any timer.
 * 3. Make sure `snd32_soundplay` is forward, `snd32_sounddecode` is backward on placing.
 * 4. Place `snd32_soundset` with needed arguments in `user32.c` as a C Lang function.
 * 5. Music code automatically plays the sound with the assgined values.  
 */

/**
 * Music Code is made off 16-bit Blocks. One Block means one beat.
 * Bit[11:0]: Length of Wave, 0 to 4095
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is 0.
 * Bit[15:14]: Type of Wave, 0 is Triangle, 1 is Square, 2 is Random, 3 is Noise (On 3, Length and Volume will be ignored)
 */

/**
 * function snd32_soundinit
 * Initialize For Functions in snd32.s
 *
 * Return: r0 (0 as success, 1 as error)
 * Error(1): Memory Space is Not Allocated
 */
.globl snd32_soundinit
snd32_soundinit:
	/* Auto (Local) Variables, but just Aliases */
	status        .req r0
	addr_memory   .req r4 @ Register for Result, Scratch Register

	push {r4}

	ldr status, SND32_STATUS
	tst status, #0x80000000
	bne snd32_soundinit_success                 @ If Already Initialized

	push {r0-r3,lr}
	mov r0, #0xF00
	add r0, r0, #0xFF                           @ 4095
	bl heap32_malloc
	cmp r0, #0
	beq snd32_soundinit_error
	mov addr_memory, r0
	pop {r0-r3,lr}

	str addr_memory, SND32_DMA_CB_FRONT_MEMORY

	push {r0-r3,lr}
	mov r0, #0xF00
	add r0, r0, #0xFF                           @ 4095
	bl heap32_malloc
	cmp r0, #0
	beq snd32_soundinit_error
	mov addr_memory, r0
	pop {r0-r3,lr}

	str addr_memory, SND32_DMA_CB_BACK_MEMORY

	orr status, status, #0x80000000
	str status, SND32_STATUS

	macro32_dsb ip

	b snd32_soundinit_success	

	snd32_soundinit_error:
		mov r0, #1                                 @ Return with Error 1
		b snd32_soundinit_common

	snd32_soundinit_success:
		mov r0, #0                                 @ Return with Success

	snd32_soundinit_common:
		pop {r4}
		mov pc, lr

.unreq status
.unreq addr_memory


/**
 * function snd32_sounddecode
 * Decode Music Code
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): There is No Assigned Music Code
 * Error(2): Not Initialized for These Functions
 */
.globl snd32_sounddecode
snd32_sounddecode:
	/* Auto (Local) Variables, but just Aliases */
	addr_code   .req r0 @ Register for Result, Scratch Register
	length      .req r1 @ Scratch Register
	count       .req r2 @ Scratch Register
	repeat      .req r3 @ Scratch Register
	status      .req r4
	code        .req r5
	wave_length .req r6
	wave_volume .req r7
	wave_type   .req r8
	temp        .req r9
	temp2       .req r10

	push {r4-r10}

	ldr addr_code, SND32_CODE
	cmp addr_code, #0
	beq snd32_sounddecode_error1

	ldr length, SND32_LENGTH
	ldr count, SND32_COUNT
	ldr repeat, SND32_REPEAT
	ldr status, SND32_STATUS

	tst status, #0x80000000                   @ If Not Initialized
	beq snd32_sounddecode_error2

	cmp count, length
	blo snd32_sounddecode_main

	cmp repeat, #-1
	moveq count, #0
	beq snd32_sounddecode_main

	cmp repeat, #0
	beq snd32_sounddecode_free

	sub repeat, repeat, #1
	mov count, #0

	snd32_sounddecode_main:

		lsl temp, count, #1                        @ Substitution of Multiplication by 2

		ldrh code, [addr_code, temp]

		cmp temp, #0
		beq snd32_sounddecode_main_jump            @ If First Block of Music Code

		sub temp, temp, #2
		ldrh temp2, [addr_code, temp]              @ Prior Value

		cmp code, temp2
		orreq status, #4                           @ If Same Value Between Current and Prior, Set Bit[2]
		streq status, SND32_STATUS
		beq snd32_sounddecode_main_common

		snd32_sounddecode_main_jump:

			bic wave_length, code, #0xF000
			and wave_volume, code, #0x3000
			lsr wave_volume, wave_volume, #12
			and wave_type, code, #0xC000
			lsr wave_type, wave_type, #14

			tst status, #2
			ldreq temp, SND32_DMA_CB_BACK_MEMORY  @ If Active is Front
			ldrne temp, SND32_DMA_CB_FRONT_MEMORY @ If Active is Back

			push {r0-r3,lr}
			mov r0, temp
			mov r1, wave_length
			cmp wave_volume, #3
			moveq r2, #17
			cmp wave_volume, #2
			moveq r2, #33
			cmp wave_volume, #1
			moveq r2, #65
			movlo r2, #127                        @ Height in Bytes
			mov r3, #128                          @ Medium in Bytes
			cmp wave_type, #2
			bleq heap32_wave_random
			cmp wave_type, #1
			bleq heap32_wave_square
			cmp wave_type, #0
			bleq heap32_wave_triangle
			pop {r0-r3,lr}

			push {r0-r3,lr}
			mov r0, temp
			mov r1, #1                                @ Clean
			bl arm32_cache_operation_heap
			pop {r0-r3,lr}

			tst status, #2
			moveq temp2, #equ32_snd32_dma_cb_back  @ If Active is Front
			movne temp2, #equ32_snd32_dma_cb_front @ If Active is Back

			push {r0-r6,lr}
			mov r0, temp2                                           @ CB Number
			mov r1, #5<<equ32_dma_ti_permap
			orr r1, r1, #equ32_dma_ti_src_inc|equ32_dma_ti_dst_dreq @ Transfer Information
			mov r2, temp                                            @ Source Address
			mov r3, #equ32_bus_peripherals_base
			add r3, r3, #equ32_pwm_base_lower
			add r3, r3, #equ32_pwm_base_upper
			add r3, r3, #equ32_pwm_fif1                             @ Destination Address
			lsl r4, wave_length, #2	                                @ Transfer Length
			mov r5, #0                                              @ 2D Stride
			mov r6, temp2                                           @ Next CB Number
			push {r4-r6}
			bl dma32_set_cb
			add sp, sp, #12
			pop {r0-r6,lr}

		snd32_sounddecode_main_common:

			add count, count, #1
			str count, SND32_COUNT

			b snd32_sounddecode_success

	snd32_sounddecode_free:
		mov addr_code, #0
		mov length, #0
		mov count, #0
		mov repeat, #0
		bic status, status, #5                     @ Clear Bit[2] and Bit[0]

		str addr_code, SND32_CODE
		str length, SND32_LENGTH
		str count, SND32_COUNT
		str repeat, SND32_REPEAT
		str status, SND32_STATUS

		b snd32_sounddecode_success

	snd32_sounddecode_error1:
		mov r0, #1                                 @ Return with Error 1
		b snd32_sounddecode_common

	snd32_sounddecode_error2:
		mov r0, #2                                 @ Return with Error 2
		b snd32_sounddecode_common

	snd32_sounddecode_success:
		mov r0, #0                                 @ Return with Success

	snd32_sounddecode_common:
		pop {r4-r10}
		mov pc, lr

.unreq addr_code
.unreq length
.unreq count
.unreq repeat
.unreq status
.unreq code
.unreq wave_length
.unreq wave_volume
.unreq wave_type
.unreq temp
.unreq temp2


/**
 * function snd32_soundplay
 * Play Sound
 *
 * Return: r0 (0 as success)
 */
.globl snd32_soundplay
snd32_soundplay:
	/* Auto (Local) Variables, but just Aliases */
	status .req r0 @ Register for Result, Scratch Register

	ldr status, SND32_STATUS

	tst status, #1
	beq snd32_soundplay_success           @ If Not Active

	tst status, #4
	bicne status, status, #4              @ If Same Value Between Current and Prior
	bne snd32_soundplay_success

	push {r0-r3,lr}
	mov r0, #equ32_snd32_dma_channel
	bl dma32_clear_channel
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #equ32_snd32_dma_channel
	tst status, #2
	moveq r1, #equ32_snd32_dma_cb_back    @ If Active is Front, Alternate
	movne r1, #equ32_snd32_dma_cb_front   @ If Active is Back, Alternate
	bl dma32_set_channel
	pop {r0-r3,lr}

	eor status, #2                        @ Flip Front/Back

	snd32_soundplay_success:
		str status, SND32_STATUS 
		mov r0, #0                            @ Return with Success

	snd32_soundplay_common:
		mov pc, lr

.unreq status


/**
 * function snd32_soundset
 * Set Sound
 *
 * Parameters
 * r0: Music Code
 * r1: Length
 * r2: Count (Offset)
 * r3: Number of Repeat, If -1, Infinite Loop
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1): There is No Assigned Music Code
 * Error(2): Not Initialized for These Functions
 */
.globl snd32_soundset
snd32_soundset:
	/* Auto (Local) Variables, but just Aliases */
	addr_code   .req r0 @ Register for Result, Scratch Register
	length      .req r1 @ Scratch Register
	count       .req r2 @ Scratch Register
	repeat      .req r3 @ Scratch Register
	temp        .req r4

	push {r4}

	mov temp, #0

	str temp, SND32_CODE
	str temp, SND32_LENGTH
	str temp, SND32_COUNT
	str temp, SND32_REPEAT
	ldr temp, SND32_STATUS
	bic temp, temp, #5        @ Clear Active Bit[0] and Same Value Bit[2]
	str temp, SND32_STATUS

	macro32_dsb ip

	str length, SND32_LENGTH
	str count, SND32_COUNT
	str repeat, SND32_REPEAT
	str addr_code, SND32_CODE @ Should Set Music Code at End for Polling Functions, `snb32_sounddecode`, `snd32_soundplay`

	macro32_dsb ip

	b snd32_soundset_success

	snd32_soundset_success:
		mov r0, #0                                 @ Return with Success

	snd32_soundset_common:
		pop {r4}
		mov pc, lr

.unreq addr_code
.unreq length
.unreq count
.unreq repeat
.unreq temp


/**
 * function snd32_soundtest
 *
 * Parameters
 * r0:
 * r1:
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1):
 * Error(2):
 */
.globl snd32_soundtest
snd32_soundtest:
	/* Auto (Local) Variables, but just Aliases */
	temp .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	push {r4-r11}

	push {r0-r3,lr}
	mov r0, #144                            @ 144 Words Equals 576 Bytes
	bl heap32_malloc
	mov r4, r0
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, r4
	mov r1, #144                           @ Length in Words, Intended that 3.2KHz/144 Equals 222.2Hz
	mov r2, #63                            @ Height in Bytes
	mov r3, #128                           @ Medium in Bytes
	bl heap32_wave_triangle
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, r4
	mov r1, #1                                @ Clean
	bl arm32_cache_operation_heap
	pop {r0-r3,lr}

	/* Channel Block Setting */

	push {r0-r6,lr}
	mov r0, #0                                              @ CB Number
	mov r1, #5<<equ32_dma_ti_permap
	orr r1, r1, #equ32_dma_ti_src_inc|equ32_dma_ti_dst_dreq @ Transfer Information
	mov r2, r4                                              @ Source Address
	mov r3, #equ32_bus_peripherals_base
	add r3, r3, #equ32_pwm_base_lower
	add r3, r3, #equ32_pwm_base_upper
	add r3, r3, #equ32_pwm_fif1                             @ Destination Address
	mov r4, #576	                                        @ Transfer Length
	mov r5, #0                                              @ 2D Stride
	mov r6, #0                                              @ Next CB Number
	push {r4-r6}
	bl dma32_set_cb
	add sp, sp, #12
	pop {r0-r6,lr}

	push {r0-r3,lr}
	mov r0, #1
	mov r1, #0
	bl dma32_set_channel
	pop {r0-r3,lr}

	b snd32_soundtest_success

	snd32_soundtest_error1:
		mov r0, #1                                 @ Return with Error 1
		b snd32_soundtest_common

	snd32_soundtest_error2:
		mov r0, #2                                 @ Return with Error 2
		b snd32_soundtest_common

	snd32_soundtest_success:
		mov r0, #0                                 @ Return with Success

	snd32_soundtest_common:
		pop {r4-r11}
		mov pc, lr

.unreq temp
