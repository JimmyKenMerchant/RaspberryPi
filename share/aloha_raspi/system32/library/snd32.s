/**
 * snd32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


SND32_DMA_CB_FRONT_MEMORY: .word SYSTEM32_HEAP_NONCACHE        @ Max. 4095
SND32_DMA_CB_BACK_MEMORY:  .word SYSTEM32_HEAP_NONCACHE + 4096 @ Max. 4095
SND32_DMA_CB_NEXT:         .word equ32_dma32_cb_snd32_start

SND32_CODE:                .word 0x00 @ Pointer of Music Code, If End, Automatically Cleared
SND32_LENGTH:              .word 0x00 @ Length of Music Code, If End, Automatically Cleared
SND32_COUNT:               .word 0x00 @ Incremental Count, Once Music Code Reaches Last, This Value will Be Reset
SND32_REPEAT:              .word 0x00 @ -1 is Infinite Loop

/**
 * Bit[0] Started (1)
 * Bit[1] CB Back is Active (1)
 * Bit[2] Same Value Before (1)
 * Bit[3] First of Music Code (0) / Continue of Music Code (1)
 * Bit[31] Initialized
 */
SND32_STATUS:              .word 0x00

/**
 * Usage
 * 1. Make sure to place `snd32_soundinit` on the end of `os_reset` in vector32.s.
 * 2. Place `snd32_soundplay` and `snd32_sounddecode` on FIQ/IRQ Handler which will be triggered with any timer.
 * 3. Make sure `snd32_soundplay` is forward, `snd32_sounddecode` is backward on placing.
 * 4. Place `snd32_soundset` with needed arguments in `user32.c` as a C Lang function.
 * 5. Music code automatically plays the sound with the assigned values.  
 */

/**
 * Music Code is made of 16-bit Blocks. One Block means one beat.
 * Bit[11:0]: Length of Wave, 0 to 4095
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is Zero (In Noise, Least).
 * Bit[15:14]: Type of Wave, 0 is Triangle, 1 is Square, 2/3 is Noise
 */

/**
 * function snd32_soundinit
 * Initialize For Functions in snd32.s
 *
 * Return: r0 (0 as success)
 */
.globl snd32_soundinit
snd32_soundinit:
	/* Auto (Local) Variables, but just Aliases */
	temp           .req r0
	memorymap_base .req r1

	ldr temp, SND32_STATUS
	tst temp, #0x80000000
	bne snd32_soundinit_success                        @ If Already Initialized

	orr temp, temp, #0x80000000
	str temp, SND32_STATUS

	ldr memorymap_base, SND32_DMA_CB_FRONT_MEMORY
	mov temp, #4096
	str temp, [memorymap_base]
	add memorymap_base, memorymap_base, #4
	str memorymap_base, SND32_DMA_CB_FRONT_MEMORY

	ldr memorymap_base, SND32_DMA_CB_BACK_MEMORY
	mov temp, #4096
	str temp, [memorymap_base]
	add memorymap_base, memorymap_base, #4
	str memorymap_base, SND32_DMA_CB_BACK_MEMORY

	macro32_dsb ip

	snd32_soundinit_success:
		mov r0, #0                                 @ Return with Success

	snd32_soundinit_common:
		mov pc, lr

.unreq temp
.unreq memorymap_base

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

	push {r4-r10,lr}                          @ Style of Enter/Return (2017 Winter)

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

	mov count, #0

	cmp repeat, #-1
	beq snd32_sounddecode_main

	sub repeat, repeat, #1

	cmp repeat, #0
	beq snd32_sounddecode_free

	snd32_sounddecode_main:

		macro32_dsb ip

		lsl temp, count, #1                        @ Substitution of Multiplication by 2

		ldrh code, [addr_code, temp]

		cmp temp, #0
		orreq status, status, #1                   @ If First Block of Music Code, Active Bit[0]
		moveq temp2, #0                            @ If First Block of Music Code, Prior Value is Nothing
		beq snd32_sounddecode_main_wave            @ If First Block of Music Code

		sub temp, temp, #2
		ldrh temp2, [addr_code, temp]              @ Prior Value

		snd32_sounddecode_main_wave:

			bic wave_length, code, #0xF000
			and wave_volume, code, #0x3000
			lsr wave_volume, wave_volume, #12
			and wave_type, code, #0xC000
			lsr wave_type, wave_type, #14

			cmp code, temp2
			orreq status, status, #4                   @ If Same Value Between Current and Prior, Set Bit[2]
			beq snd32_sounddecode_main_common

			tst status, #2
			ldreq temp, SND32_DMA_CB_BACK_MEMORY       @ If Active is Front
			ldrne temp, SND32_DMA_CB_FRONT_MEMORY      @ If Active is Back

			cmp wave_type, #2
			bhs snd32_sounddecode_main_wave_noise      @ If Noise

			/* Triangle or Square Wave */

			push {r0-r3}
			mov r0, temp
			mov r1, wave_length
			cmp wave_volume, #3
			moveq r2, #0
			cmp wave_volume, #2
			moveq r2, #31
			cmp wave_volume, #1
			moveq r2, #63
			movlo r2, #127                             @ Height in Bytes
			mov r3, #128                               @ Medium in Bytes
			cmp wave_type, #1
			bleq heap32_wave_square
			cmp wave_type, #0
			bleq heap32_wave_triangle
			pop {r0-r3}

			b snd32_sounddecode_main_wave_setcb

			snd32_sounddecode_main_wave_noise:

				push {r0-r3}
				mov r0, temp
				mov r1, wave_length
				cmp wave_volume, #3
				moveq r2, #31
				moveq r3, #31
				cmp wave_volume, #2
				moveq r2, #63
				moveq r3, #63
				cmp wave_volume, #1
				moveq r2, #127
				moveq r3, #127
				movlo r2, #255
				movlo r3, #255
				bl heap32_wave_random
				pop {r0-r3}

			snd32_sounddecode_main_wave_setcb:

				push {r0-r3}
				mov r0, temp
				mov r1, #1                                @ Clean
				bl arm32_cache_operation_heap
				pop {r0-r3}

				ldr temp2, SND32_DMA_CB_NEXT

				push {r0-r6}
				mov r0, temp2
				mov r1, #5<<equ32_dma_ti_permap
				bic r1, r1, #equ32_dma_ti_no_wide_bursts
				orr r1, r1, #0<<equ32_dma_ti_waits
				orr r1, r1, #0<<equ32_dma_ti_burst_length
				orr r1, r1, #equ32_dma_ti_src_inc|equ32_dma_ti_dst_dreq @ Transfer Information
				orr r1, r1, #equ32_dma_ti_wait_resp
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
				pop {r0-r6}

		snd32_sounddecode_main_common:

			add count, count, #1
			str count, SND32_COUNT
			str repeat, SND32_REPEAT
			str status, SND32_STATUS

			b snd32_sounddecode_success

	snd32_sounddecode_free:
		mov addr_code, #0
		mov length, #0
		bic status, status, #0xD                   @ Clear Bit[3], Bit[2], and Bit[0]

		str addr_code, SND32_CODE
		str length, SND32_LENGTH
		str count, SND32_COUNT                     @ count is Already Zero
		str repeat, SND32_REPEAT                   @ repeat is Already Zero
		str status, SND32_STATUS

		push {r0-r3}
		mov r0, #equ32_snd32_dma_channel
		bl dma32_clear_channel
		pop {r0-r3}

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
		pop {r4-r10,pc}                            @ Style of Enter/Return (2017 Winter)

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
 * function snd32_soundclear
 * Clear Music Code
 *
 * Return: r0 (0 as success)
 */
.globl snd32_soundclear
snd32_soundclear:
	/* Auto (Local) Variables, but just Aliases */
	temp   .req r0 @ Register for Result, Scratch Register

	mov temp, #0

	str temp, SND32_CODE
	str temp, SND32_LENGTH
	str temp, SND32_COUNT
	str temp, SND32_REPEAT

	ldr temp, SND32_STATUS	
	bic temp, temp, #0xD                   @ Clear Bit[3], Bit[2], and Bit[0]
	str temp, SND32_STATUS

	push {r0-r3}
	mov r0, #equ32_snd32_dma_channel
	bl dma32_clear_channel
	pop {r0-r3}

	snd32_soundclear_success:
		mov r0, #0                            @ Return with Success

	snd32_soundclear_common:
		mov pc, lr

.unreq temp


/**
 * function snd32_soundplay
 * Play Sound
 *
 * Return: r0 (0 as success)
 */
.globl snd32_soundplay
snd32_soundplay:
	/* Auto (Local) Variables, but just Aliases */
	temp   .req r0 @ Register for Result, Scratch Register
	status .req r1 @ Scratch Register

	/* Make sure to take status to r1, otherwise, missing in `tst` occurs */

	ldr status, SND32_STATUS

	tst status, #1
	beq snd32_soundplay_success           @ If Not Active

	tst status, #4
	bicne status, status, #4              @ If Same Value Between Current and Prior
	bne snd32_soundplay_success
	
	tst status, #8
	bne snd32_soundplay_contine           @ If Continue of Music Code

	push {r0-r3,lr}
	mov r0, #equ32_snd32_dma_channel
	bl dma32_clear_channel
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #equ32_snd32_dma_channel
	ldr r1, SND32_DMA_CB_NEXT
	bl dma32_set_channel
	pop {r0-r3,lr}

	orr status, status, #8

	b snd32_soundplay_flip

	snd32_soundplay_contine:
		push {r0-r3,lr}
		mov r0, #equ32_snd32_dma_channel
		ldr r1, SND32_DMA_CB_NEXT
		bl dma32_change_nextcb
		pop {r0-r3,lr}

	snd32_soundplay_flip:
		ldr temp, SND32_DMA_CB_NEXT
		add temp, temp, #1
		cmp temp, #equ32_dma32_cb_snd32_end
		movhi temp, #equ32_dma32_cb_snd32_start
		str temp, SND32_DMA_CB_NEXT

		eor status, status, #2                @ Flip Front/Back

	snd32_soundplay_success:
		str status, SND32_STATUS
		mov r0, #0                            @ Return with Success

	snd32_soundplay_common:
		mov pc, lr

.unreq temp
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
 * Return: r0 (0 as success)
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
	bic temp, temp, #0xD      @ Clear Bit[3], Bit[2], and Bit[0]
	str temp, SND32_STATUS

	str length, SND32_LENGTH
	str count, SND32_COUNT
	str repeat, SND32_REPEAT
	str addr_code, SND32_CODE @ Should Set Music Code at End for Polling Functions, `snb32_sounddecode`, `snd32_soundplay`

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
 * function snd32_musiclen
 * Count 2-Bytes Beats of Music Code
 *
 * Parameters
 * r0: Pointer of Array of Music Code
 *
 * Return: r0 (Number of Beats in Music Code) Maximum of 4,294,967,295 Beats
 */
.globl snd32_musiclen
snd32_musiclen:
	/* Auto (Local) Variables, but just Aliases */
	music_point       .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	music_hword       .req r1
	length            .req r2

	mov length, #0

	snd32_musiclen_loop:
		ldrh music_hword, [music_point]           @ Load Half Word (16-bit)
		cmp music_hword, #0                       @ NULL Character (End of String) Checker
		beq snd32_musiclen_common                 @ Break Loop if Null Character

		add music_point, music_point, #2
		add length, length, #1
		b snd32_musiclen_loop

	snd32_musiclen_common:
		mov r0, length
		mov pc, lr

.unreq music_point
.unreq music_hword
.unreq length


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
	orr r1, r1, #equ32_dma_ti_src_dreq|equ32_dma_ti_src_inc @ Transfer Information
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
