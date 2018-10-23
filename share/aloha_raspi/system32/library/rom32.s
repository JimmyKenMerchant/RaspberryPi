/**
 * rom32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function rom32_romread_i2c
 * I2C EEPROM Write
 *
 * Parameters
 * r0: Heap to Write Data
 * r1: Chip Select (Bit[2:0])
 * r2: Memory Address in EEPROM (Bit[15:0])
 * r3: Length to Read (Bytes)
 *
 * Return: r0 (0 as Success, -1, 1-4 as Error)
 * Error(-1): Memory Allocation Fails
 * Error(1): Device Address Error (Derived From I2C)
 * Error(2): Clock Stretch Timeout (Derived From I2C)
 * Error(3): Transaction Error on Checking Process (Derived From I2C)
 */
.globl rom32_romread_i2c
rom32_romread_i2c:
	/* Auto (Local) Variables, but just Aliases */
	heap            .req r0
	chip_select     .req r1
	addr            .req r2
	length          .req r3
	heap_addr       .req r4 @ Heap for Writing Address
	temp            .req r5

	push {r4-r5,lr}

	push {r0-r3}
	bl heap32_mcount
	mov temp, r0
	pop {r0-r3}

	cmp temp, #-1
	beq rom32_romread_i2c_error

	cmp length, temp
	movgt length, temp                @ Prevent Overflow

	push {r0-r3}
	add r0, #1
	bl heap32_malloc
	mov heap_addr, r0
	pop {r0-r3}

	cmp heap_addr, #0
	beq rom32_romread_i2c_error

	/* Most Significant Word Will Be Send at First, Least Significant Word Will Be Send at Second */
	and temp, addr, #0xFF00
	lsr temp, temp, #8
	strb temp, [heap_addr]
	and temp, addr, #0xFF
	strb temp, [heap_addr, #1]

	/**
	 * Bit[6:3] is Fixed, Bit[6:0] becomes Device Address Bit[7:1], Bit[0] is Write/Read
	 */
	orr chip_select, chip_select, #0b01010000

	/* Address Write */
	push {r0-r3}
	mov r0, heap_addr
	mov r2, #2
	bl i2c32_i2ctx
	mov temp, r0
	pop {r0-r3}

/*
macro32_debug temp, 0, 100
*/

	cmp temp, #0
	bne rom32_romread_i2c_common      @ If Error on I2C

	/* Wait for 5ms to write address */
	push {r0-r3}
	mov r0, #0x1400                   @ Decimal 5120
	bl arm32_sleep
	pop {r0-r3}

	push {r0-r3}
	mov r2, length
	bl i2c32_i2crx
	mov temp, r0
	pop {r0-r3}

/*
macro32_debug temp, 0, 112
*/

	cmp temp, #0
	bne rom32_romread_i2c_common     @ If Error on I2C

	b rom32_romread_i2c_success

	rom32_romread_i2c_error:
		mvn r0, #0                        @ Error With -1
		b rom32_romread_i2c_common

	rom32_romread_i2c_success:
		mov r0, #0

	rom32_romread_i2c_common:
		push {r0-r3}
		mov r0, heap_addr
		bl heap32_mfree                   @ mfree Issues Error if Address Is Null(0)
		pop {r0-r3}

		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r5,pc}

.unreq heap
.unreq chip_select
.unreq addr
.unreq length
.unreq heap_addr
.unreq temp


/**
 * function rom32_romwrite_i2c
 * I2C EEPROM Write
 *
 * Parameters
 * r0: Heap to Write Data
 * r1: Chip Select (Bit[2:0])
 * r2: Memory Address in EEPROM (Bit[15:0])
 * r3: Length to Write (Bytes)
 *
 * Return: r0 (0 as Success, -1, 1-4 as Error)
 * Error(-1): Memory Allocation Fails
 * Error(1): Device Address Error (Derived From I2C)
 * Error(2): Clock Stretch Timeout (Derived From I2C)
 * Error(3): Transaction Error on Checking Process (Derived From I2C)
 */
.globl rom32_romwrite_i2c
rom32_romwrite_i2c:
	/* Auto (Local) Variables, but just Aliases */
	heap            .req r0
	chip_select     .req r1
	addr            .req r2
	length          .req r3
	heap_addr       .req r4 @ Heap for Writing Address
	temp            .req r5

	push {r4-r5,lr}

	tst length, #0b11                 @ Check Bit[1:0]
	addne temp, length, #0b100        @ Add 4 If Value Exists on Bit[1:0]
	moveq temp, length

	lsr temp, temp, #2                @ Substitute of Division by 4

	push {r0-r3}
	add r0, temp, #1
	bl heap32_malloc
	mov heap_addr, r0
	pop {r0-r3}

	cmp heap_addr, #0
	beq rom32_romwrite_i2c_error

	/* Most Significant Word Will Be Send at First, Least Significant Word Will Be Send at Second */
	and temp, addr, #0xFF00
	lsr temp, temp, #8
	strb temp, [heap_addr]
	and temp, addr, #0xFF
	strb temp, [heap_addr, #1]

	push {r0-r3}
	push {length}
	mov r2, heap
	mov r0, heap_addr
	mov r1, #2
	mov r3, #0
	bl heap32_mcopy
	add sp, sp, #4
	mov temp, r0
	pop {r0-r3}

	cmp temp, #0
	beq rom32_romwrite_i2c_error      @ If Error on Memory Copy

	/**
	 * Bit[6:3] is Fixed, Bit[6:0] becomes Device Address Bit[7:1], Bit[0] is Write/Read
	 */
	orr chip_select, chip_select, #0b01010000

	/* Address and Data Write */
	push {r0-r3}
	mov r0, heap_addr
	add r2, length, #2                @ Address Plus Data 
	bl i2c32_i2ctx
	mov temp, r0
	pop {r0-r3}

/*
macro32_debug temp, 0, 136
*/

	cmp temp, #0
	bne rom32_romwrite_i2c_common     @ If Error on I2C

	/* Wait for 5ms to write address */
	push {r0-r3}
	mov r0, #0x1400                   @ Decimal 5120
	bl arm32_sleep
	pop {r0-r3}

	b rom32_romwrite_i2c_success

	rom32_romwrite_i2c_error:
		mvn r0, #0                        @ Error With -1
		b rom32_romwrite_i2c_common

	rom32_romwrite_i2c_success:
		mov r0, #0

	rom32_romwrite_i2c_common:
		push {r0-r3}
		mov r0, heap_addr
		bl heap32_mfree                   @ mfree Issues Error if Address Is Null(0)
		pop {r0-r3}

		macro32_dsb ip                    @ Ensure Completion of Instructions Before
		pop {r4-r5,pc}

.unreq heap
.unreq chip_select
.unreq addr
.unreq length
.unreq heap_addr
.unreq temp

