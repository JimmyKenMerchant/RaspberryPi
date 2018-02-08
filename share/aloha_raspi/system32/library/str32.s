/**
 * str32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * function str32_strindex
 * Search Second Key String in First String
 *
 * Parameters
 * r0: Pointer of Array of String to Be Subjected
 * r1: Pointer of Array of String to Be Searched (Key)
 *
 * Return: r0 (Index of First Character in String, if not -1)
 */
.globl str32_strindex
str32_strindex:
	/* Auto (Local) Variables, but just Aliases */
	string_point1      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_point2      .req r1 @ Parameter, Register for Argument, Scratch Register
	char_search        .req r2
	search_length      .req r3
	string_length1     .req r4
	string_length2     .req r5
	string_size2       .req r6
	increment          .req r7

	push {r4-r7,lr}

	push {r0-r3}
	bl str32_strlen
	mov string_length1, r0
	pop {r0-r3}

	push {r0-r3}
	mov r0, string_point2
	bl str32_strlen
	mov string_length2, r0
	pop {r0-r3}

	add string_size2, string_point2, string_length2

	mov increment, #0
	mov search_length, string_length1                 @ For First Character of Key

	str32_strindex_loop:
		cmp string_point2, string_size2
		subhs increment, increment, string_length2     @ string_length2 May Have Zero
		bhs str32_strindex_common

		cmp increment, string_length1
		mvnhs increment, #0
		bhs str32_strindex_common

		ldrb char_search, [string_point2]

		push {r0-r3}
		add r0, string_point1, increment
		mov r1, search_length
		mov r2, char_search
		bl str32_charsearch
		cmp r0, #-1                                    @ 0xFFFFFFF
		addne increment, increment, r0
		pop {r0-r3}
		mvneq increment, #0
		beq str32_strindex_common

		add string_point2, string_point2, #1
		add increment, increment, #1
		mov search_length, #1                          @ After Search and Hit First Character of Key 

		b str32_strindex_loop

	str32_strindex_common:
		mov r0, increment
		pop {r4-r7,pc}

.unreq string_point1
.unreq string_point2
.unreq char_search
.unreq search_length
.unreq string_length1
.unreq string_length2
.unreq string_size2
.unreq increment


/**
 * function str32_charindex
 * Search Byte Character in String
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Character to Be Searched (Key)
 *
 * Return: r0 (Index of Character, if not -1)
 */
.globl str32_charindex
str32_charindex:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	char_search       .req r1 @ Parameter, Register for Argument, Scratch Register
	char_string       .req r2
	increment         .req r3
	string_length     .req r4

	push {r4,lr}

	push {r0-r3}
	bl str32_strlen
	mov string_length, r0
	pop {r0-r3}

	mov increment, #0

	str32_charindex_loop:
		cmp increment, string_length
		mvnhs increment, #0
		bhs str32_charindex_common

		ldrb char_string, [string_point, increment]
		cmp char_string, char_search
		beq str32_charindex_common

		add increment, increment, #1
		b str32_charindex_loop

	str32_charindex_common:
		mov r0, increment
		pop {r4,pc}

.unreq string_point
.unreq char_search
.unreq char_string
.unreq increment
.unreq string_length


/**
 * function str32_charsearch
 * Search Byte Character in String within Range
 * This function stops at the null character of the string.
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Length of Array
 * r2: Character to Be Searched (Key)
 *
 * Return: r0 (Index of Character, if not -1)
 */
.globl str32_charsearch
str32_charsearch:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_length     .req r1 @ Parameter, Register for Argument, Scratch Register
	char_search       .req r2 @ Parameter, Register for Argument, Scratch Register
	char_string       .req r3
	increment         .req r4

	push {r4}

	mov increment, #0

	str32_charsearch_loop:
		cmp increment, string_length
		mvnhs increment, #0
		bhs str32_charsearch_common

		ldrb char_string, [string_point, increment]
		cmp char_string, #0                         @ Null Character
		mvneq increment, #0
		beq str32_charsearch_common
		cmp char_string, char_search
		beq str32_charsearch_common

		add increment, increment, #1
		b str32_charsearch_loop

	str32_charsearch_common:
		mov r0, increment
		pop {r4}
		mov pc, lr

.unreq string_point
.unreq string_length
.unreq char_search
.unreq char_string
.unreq increment


/**
 * function str32_strsearch
 * Search Second Key String in First String within Range
 * This function stops at the null character of the string.
 *
 * Parameters
 * r0: Pointer of Array of String to Be Subjected
 * r1: Length of String to Be Subjected
 * r2: Pointer of Array of String to Be Searched (Key)
 * r3: Length 0f String to Be Searched (Key)
 *
 * Return: r0 (Index of First Character in String, if not -1)
 */
.globl str32_strsearch
str32_strsearch:
	/* Auto (Local) Variables, but just Aliases */
	string_point1      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_length1     .req r1 @ Parameter, Register for Argument, Scratch Register
	string_point2      .req r2
	string_length2     .req r3
	char_search        .req r4
	search_length      .req r5
	string_size2       .req r6
	increment          .req r7

	push {r4-r7,lr}

	add string_size2, string_point2, string_length2

	mov increment, #0
	mov search_length, string_length1                 @ For First Character of Key

	str32_strsearch_loop:
		cmp string_point2, string_size2
		subhs increment, increment, string_length2        @ string_length2 May Have Zero
		bhs str32_strsearch_common

		cmp increment, string_length1
		mvnhs increment, #0
		bhs str32_strsearch_common

		ldrb char_search, [string_point2]
		cmp char_search, #0                               @ Null Character
		mvneq increment, #0
		beq str32_strsearch_common

		push {r0-r3}
		add r0, string_point1, increment
		mov r1, search_length
		mov r2, char_search
		bl str32_charsearch
		cmp r0, #-1                                       @ 0xFFFFFFF
		addne increment, increment, r0
		pop {r0-r3}
		mvneq increment, #0
		beq str32_strsearch_common

		add string_point2, string_point2, #1
		add increment, increment, #1
		mov search_length, #1                          @ After Search and Hit First Character of Key 

		b str32_strsearch_loop

	str32_strsearch_common:
		mov r0, increment
		pop {r4-r7,pc}

.unreq string_point1
.unreq string_length1
.unreq string_point2
.unreq string_length2
.unreq char_search
.unreq search_length
.unreq string_size2
.unreq increment


/**
 * function str32_charcount
 * Count Byte Characters in String
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Length of Array of String
 * r2: Character to Be Searched (Key)
 *
 * Return: r0 (Number of Counts for Character Key)
 */
.globl str32_charcount
str32_charcount:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_length     .req r1 @ Parameter, Register for Argument, Scratch Register
	char_search       .req r2 @ Parameter, Register for Argument, Scratch Register
	char_string       .req r3
	increment         .req r4
	count             .req r5

	push {r4-r5}

	mov increment, #0
	mov count, #0

	str32_charcount_loop:
		cmp increment, string_length
		bge str32_charcount_common

		ldrb char_string, [string_point, increment]
		cmp char_string, char_search
		addeq count, count, #1

		add increment, increment, #1
		b str32_charcount_loop

	str32_charcount_common:
		mov r0, count
		pop {r4-r5}
		mov pc, lr

.unreq string_point
.unreq string_length
.unreq char_search
.unreq char_string
.unreq increment
.unreq count


/**
 * function str32_strcount
 * Count Key String in Subjected String
 *
 * Parameters
 * r0: Pointer of Array of String to Be Subjected
 * r1: Length of String to Be Subjected
 * r2: Pointer of Array of String to Be Searched (Key)
 * r3: Length 0f String to Be Searched (Key)
 *
 * Return: r0 (Number of Counts for String Key)
 */
.globl str32_strcount
str32_strcount:
	/* Auto (Local) Variables, but just Aliases */
	string_point1      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_length1     .req r1 @ Parameter, Register for Argument, Scratch Register
	string_point2      .req r2
	string_length2     .req r3
	count              .req r4
	index              .req r5

	push {r4-r5,lr}

	mov count, #0
	mov index, #0

	str32_strcount_loop:

		push {r0-r3}
		bl str32_strsearch
		mov index, r0
		pop {r0-r3}

		cmp index, #-1
		beq str32_strcount_common

		add count, count, #1
		add index, index, string_length2
		add string_point1, string_point1, index
		sub string_length1, string_length1, index

		b str32_strcount_loop

	str32_strcount_common:
		mov r0, count
		pop {r4-r5,pc}

.unreq string_point1
.unreq string_length1
.unreq string_point2
.unreq string_length2
.unreq count
.unreq index


/**
 * function str32_strmatch
 * Check Whether One Pair of Strings Are Same
 * This function stops at the null character of the string.
 *
 * Parameters
 * r0: Pointer of Array of String to Be Subjected
 * r1: Length of String to Be Subjected
 * r2: Pointer of Array of String to Be Searched (Key)
 * r3: Length 0f String to Be Searched (Key)
 *
 * Return: r0 (1 is Match, 0 is Not Match)
 */
.globl str32_strmatch
str32_strmatch:
	/* Auto (Local) Variables, but just Aliases */
	string_point1      .req r0
	string_length1     .req r1
	string_point2      .req r2
	string_length2     .req r3
	byte1              .req r4
	byte2              .req r5

	push {r4-r5,lr}

	cmp string_length1, string_length2
	bne str32_strmatch_notmatch

	add string_length1, string_point1, string_length1
	add string_length2, string_point2, string_length2

	str32_strmatch_loop:

		ldrb byte1, [string_point1]
		cmp byte1, #0
		beq str32_strmatch_notmatch

		ldrb byte2, [string_point2]
		cmp byte2, #0
		beq str32_strmatch_notmatch

		cmp byte1, byte2
		bne str32_strmatch_notmatch

		add string_point1, string_point1, #1
		add string_point2, string_point2, #1

		cmp string_point1, string_length1
		blt str32_strmatch_loop

	str32_strmatch_match:
		mov r0, #1
		b str32_strmatch_common

	str32_strmatch_notmatch:
		mov r0, #0

	str32_strmatch_common:
		pop {r4-r5,pc}

.unreq string_point1
.unreq string_length1
.unreq string_point2
.unreq string_length2
.unreq byte1
.unreq byte2


/**
 * function str32_charreplace
 * Replace Character
 * This function stops at the null character of the string.
 *
 * Parameters
 * r0: Pointer of Array of String to Be Subjected
 * r1: Index of Character to Be Replaced
 * r2: Character to Be Substituted
 *
 * Return: r0 (1 is Match, 0 is Not Match)
 */
.globl str32_charreplace
str32_charreplace:
	/* Auto (Local) Variables, but just Aliases */
	string_point1      .req r0
	string_index1      .req r1
	character          .req r2
	string_length1     .req r3

	push {lr}

	push {r0-r2}
	bl str32_strlen
	mov r3, r0
	pop {r0-r2}

	cmp string_index1, string_length1
	bge str32_charreplace_error

	strb character, [string_point1, string_index1]
	b str32_charreplace_success

	str32_charreplace_error:
		mov r0, #1
		b str32_charreplace_common

	str32_charreplace_success:
		mov r0, #0

	str32_charreplace_common:
		pop {pc}

.unreq string_point1
.unreq string_index1
.unreq character
.unreq string_length1


/**
 * function str32_strcat
 * Concatenation of Two Strings
 * Caution! On the standard C Langage string.h library, strcat returns Pointer of Array of the first argument with
 * the concatenated string. That needs to have enough spaces of memory on the first one to concatenate.
 * But that makes buffer overflow easily. So in this function, str32_strcat returns new Pointer of Array.
 * Note that this function makes new memory space to be needed to make the memory free.
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Pointer of Array of String
 *
 * Usage: r0-r7
 * Return: r0 (Pointer of Concatenated String, if 0, no enough space for new Pointer of Array)
 */
.globl str32_strcat
str32_strcat:
	/* Auto (Local) Variables, but just Aliases */
	string_point1     .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_point2     .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	string_byte       .req r2
	heap_size         .req r3
	length1           .req r4
	length2           .req r5
	heap_origin       .req r6
	heap              .req r7

	push {r4-r7}

	push {r0-r3,lr}
	mov r0, string_point1
	bl str32_strlen
	mov length1, r0
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, string_point2
	bl str32_strlen
	mov length2, r0
	pop {r0-r3,lr}

	add length1, length1, length2
	add length1, length1, #1                      @ Add One for Null Character
	mov heap_size, #1

	str32_strcat_countsize:
		subs length1, length1, #4
		addgt heap_size, #1
		bgt str32_strcat_countsize

	push {r0-r3,lr}
	mov r0, heap_size
	bl heap32_malloc
	mov heap_origin, r0
	pop {r0-r3,lr}

	cmp heap_origin, #0
	beq str32_strcat_common
	mov heap, heap_origin

	str32_strcat_loop1:
		ldrb string_byte, [string_point1]         @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq str32_strcat_loop2                  @ Break Loop if Null Character

		strb string_byte, [heap]                  @ Store Byte to New Pointer

		add string_point1, string_point1, #1
		add heap, heap, #1
		b str32_strcat_loop1

	str32_strcat_loop2:
		ldrb string_byte, [string_point2]         @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq str32_strcat_success                @ Break Loop if Null Character

		strb string_byte, [heap]                  @ Store Byte to New Pointer

		add string_point2, string_point2, #1
		add heap, heap, #1
		b str32_strcat_loop2

	str32_strcat_success:
		mov string_byte, #0
		strb string_byte, [heap]                  @ Make Sure to Add Null Character to the End

	str32_strcat_common:
		mov r0, heap_origin
		pop {r4-r7}
		mov pc, lr

.unreq string_point1
.unreq string_point2
.unreq string_byte
.unreq heap_size
.unreq length1
.unreq length2
.unreq heap_origin
.unreq heap


/**
 * function str32_strlist
 * Make Array of String List from One String
 * Caution! This Function Generates Two-dimensional Array in Heap Area.
 *
 * Parameters
 * r0: Pointer of Array of String
 * r1: Length of Array of String
 * r2: Character of Separater (Ascii Code)
 *
 * Return: r0 (Pointer of Two-dimensional Array of List, if 0, no enough space for new Pointer of Array)
 */
.globl str32_strlist
str32_strlist:
	/* Auto (Local) Variables, but just Aliases */
	str_origin        .req r0
	length_str_origin .req r1
	separator         .req r2
	temp              .req r3
	size_heap         .req r4
	heap              .req r5
	length_str_sub    .req r6
	str_sub           .req r7
	size_subheap      .req r8
	subheap           .req r9
	offset_str_origin .req r10
	offset_heap       .req r11

	push {r4-r11,lr}

	push {r0-r3}
	bl str32_charcount
	mov size_heap, r0
	pop {r0-r3}

	add size_heap, size_heap, #1

	push {r0-r3}
	mov r0, size_heap
	bl heap32_malloc
	mov heap, r0
	pop {r0-r3}

	cmp heap, #0
	beq str32_strlist_common

	mov offset_str_origin, #0
	mov offset_heap, #0

	str32_strlist_loop:

		cmp size_heap, #0
		ble str32_strlist_common

		/* Set Initial Size of Sub Heap in Advance */
		mov size_subheap, #1

		push {r0-r3}
		add r0, str_origin, offset_str_origin
		sub r1, length_str_origin, offset_str_origin
		bl str32_charsearch
		mov length_str_sub, r0
		pop {r0-r3}

		cmp length_str_sub, #-1
		addne temp, length_str_sub, #1        @ For Null Character
		bne str32_strlist_loop_countsize

		push {r0-r3}
		add r0, str_origin, offset_str_origin
		bl str32_strlen
		mov length_str_sub, r0
		pop {r0-r3}

		add temp, length_str_sub, #1          @ For Null Character

		str32_strlist_loop_countsize:
			subs temp, temp, #4
			addgt size_subheap, #1
			bgt str32_strlist_loop_countsize

		push {r0-r3}
		mov r0, size_subheap
		bl heap32_malloc
		mov subheap, r0
		pop {r0-r3}

		push {r0-r3}
		mov r2, str_origin                    @ Pointer of Start Address of Memory Space to Be Copied (Source)
		mov r0, subheap                       @ Pointer of Start Address of Memory Space to Be Destination
		mov r1, #0                            @ Offset of Bytes to Be Copied
		mov r3, length_str_sub                @ Length of Bytes to Be Copied (Source)
		push {r3}
		mov r3, offset_str_origin             @ Offset of Bytes to Be Copied (Source)
		bl heap32_mcopy
		add sp, sp, #4
		mov subheap, r0
		pop {r0-r3}

		cmp subheap, #0
		beq str32_strlist_common

		mov temp, #0
		str temp, [subheap, length_str_sub]   @ Store Null Character

		str subheap, [heap, offset_heap]

		add offset_heap, offset_heap, #4
		add offset_str_origin, offset_str_origin, length_str_sub
		add offset_str_origin, offset_str_origin, #1

		sub size_heap, size_heap, #1

		b str32_strlist_loop

	str32_strlist_common:
		mov r0, heap
		pop {r4-r11,pc}

.unreq str_origin
.unreq length_str_origin
.unreq separator
.unreq temp
.unreq size_heap
.unreq heap
.unreq length_str_sub
.unreq str_sub
.unreq size_subheap
.unreq subheap
.unreq offset_str_origin
.unreq offset_heap


/**
 * function str32_strlen
 * Count 1-Byte Words of String
 *
 * Parameters
 * r0: Pointer of Array of String
 *
 * Usage: r0-r2
 * Return: r0 (Number of Words) Maximum of 4,294,967,295 words
 */
.globl str32_strlen
str32_strlen:
	/* Auto (Local) Variables, but just Aliases */
	string_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	string_byte       .req r1
	length            .req r2

	mov length, #0

	str32_strlen_loop:
		ldrb string_byte, [string_point]          @ Load Character Byte
		cmp string_byte, #0                       @ NULL Character (End of String) Checker
		beq str32_strlen_common                 @ Break Loop if Null Character

		add string_point, string_point, #1
		add length, length, #1
		b str32_strlen_loop

	str32_strlen_common:
		mov r0, length
		mov pc, lr

.unreq string_point
.unreq string_byte
.unreq length

