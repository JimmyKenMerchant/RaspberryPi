/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#include "system32.h"
#include "system32.c"

#define initial_line       1
#define argument_maxlength 8
#define label_maxlength    16
#define label_maxchar      4 // Word (4 bytes) 1 Means 4 Bytes, Last 1 Bytes is for Null Character
#define link_stacksize     32
#define rawdata_maxlength  16

bool input_keyboard();
bool set_cursor();
bool process_counter();
bool text_sender( String target_str );
String pass_space_label( String target_str );
bool line_clean( String target_str ); 
bool command_print( String target_str ); 
bool command_pict( String true_str, String false_str, obj array, uint32 size_indicator ); 
bool console_rollup();
bool init_usb_keyboard( uint32 usb_channel );
int32 ticket_hub; // Use in init_usb_keyboard()
int32 ticket_hid; // Use in init_usb_keyboard()

bool kb_enable; // Enabling Flag for USB Keyboard Input

/* D: Line Number for Direction, S1: Line Number Stored First Source, S2: Line Number Stored Second Source... */
typedef enum _command_list {
	null,
	end,
	sleep, // Sleep microseconds by integer "Sleep %S1"
	arr, // Make raw data array of integer, "arr %D %S1 %S2 %S3": D = number of array made of S1 - S2. S3 is block size (0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes).
	free, // Free memory space for raw data array, "free %S1": Free memory space for array whose number is indicated in S1.
	/**
	 * "pict" does sequential printing with judging bit value in raw data of array from MSB to LSB, "pict %S1 %S2 %S3 %S4":
	 * S1 is the string when true (1), S2 is the string when false (0), S3 is number of Array, S4 is block size (0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes).
	 * This command inserts "\r\n" when each data of array is ended.
	 */
	pict,
	add, // Integer signed addition, "add %D %S1 %S2": D = S1 + S2. -2,147,483,648 through 2,147,483,647.
	sub,
	mul,
	div,
	rem,
	uadd, // Integer unsigned addition, "uadd %D %S1 %S2": D = S1 + S2. 0x0 through 0xFFFFFFFF.
	usub,
	umul,
	udiv,
	urem,
	and, // Logical AND, "and %D %S1 %S2"
	not, // Logical NOT, "not %D %S1"
	or, // Logical OR, "or %D %S1 %S2"
	xor, // Logical exclusive OR, "xor %D %S1 %S2"
	lsl, // Logical shift left, "lsl %D %S1 %S2"
	lsr, // Logical shift right, "lsr %D %S1 %S2"
	rand, // Random value 0-255, "rand %D"
	cmp, // Arithmetic comparison, "cmp %S1 %S2": Reflects NZCV flags.
	tst, // Logical comparison, "tst %S1 %S2": Reflects NZCV flags.
	badd, // Binary-coded decimal, "badd %D %S1 %S2": D = S1 + S2. -9,999,999,999,999,999 through 9,999,999,999,999,999.
	bsub,
	bmul,
	bdiv,
	brem,
	bcmp, // Compare two values of binary-coded decimal, "bcmp %S1 %S2": Reflects NZCV flags.
	fadd, // Floating point addition, "fadd %D %S1 %S2": D = S1 + S2.
	fsub, // Floating point subtruction, "fsub %D %S1 %S2": D = S1 - S2.
	fmul,
	fdiv,
	fsqrt, // Square root, "fsqrt %D %S1": D = S1^1/2.
	frad, // Radian, "frad %D %S1": D = S1 * pi/180.0.
	fsin, // Sine by radian on float, "sin %D %S1": D = sin(S1).
	fcos,
	ftan,
	fln,
	flog,
	fabs,
	fneg,
	fcmp, // Compare two values of floating point, "fcmp %S1 %S2": Reflects NZCV flags.
	input, // Input to the line, "input %D".
	print,
	scmp, // String Compare
	mov, // Copy, "mov %D %S1".
	clr, // Clear the line, "clr %D".
	jmp, // Jump to the line, "jmp %S1": Next line will be the number in S1.
	call, // Jump to the line and store number of current line to array (Last In First Out) for link.
	ret, // Return to the line stored in array for link.
	push,
	pop,
	ptr, // Store the number of line which has label, "ptr %D .S1": D = line number of S1.
	skpeq, // Skip one line if equal: Use next to a "cmp.." command.
	skpne,
	skpge,
	skple,
	skpgt,
	skplt,
	skpcs, // Skip one line if carry flag is set (Unsigned Higher or Equal)
	skpcc, // Skip one line if carry flag is not set (Unsigned Lower)
	clear, // Clear all in every Line
	run, // Meta Command: Runs script from list number zero
	set // Meta Command: Set Line
} command_list;

/**
 * Four Types of Arguments
 * 1. Label, indicated by ".", must be initialized to hide inaccurate execution, otherwise, the execution will stop, etc.
 * 1. Indirect Label, indicated by ":", must be initialized to hide inaccurate execution, otherwise, the execution will stop, etc.
 * 3. Line Number, indicated by "%".
 * 4. Indirect Number, indicated by "[".
 */

typedef enum _pipe_list {
	search_command,
	enumurate_variables,
	execute_command,
	go_nextline,
	termination
} pipe_list;


typedef union _flex32 {
	char8 s8;
	uchar8 u8;
	int16 s16;
	uint16 u16;
	int32 s32;
	uint32 u32;
	obj object;
	float32 f32;
} flex32;


typedef struct _dictionary {
	obj name;
	obj number;
	uint32 length;
} dictionary;


bool flag_execute;

obj buffer_zero; // Zero Buffer

int32 _user_start()
{

	String str_aloha = "Aloha Calc Version 0.8.5 Alpha: Copyright (C) 2018 Kenta Ishii\r\n\0";
	String str_serialmode = "\x1B[31mSerial Mode\x1B[0m\r\n\0";
	String str_direction = null;
	obj array_source = heap32_malloc( argument_maxlength );
	obj array_argpointer = heap32_malloc( argument_maxlength );
	obj array_link = heap32_malloc( link_stacksize );
	uint32 array_link_offset = 0;
	obj array_rawdata = heap32_malloc( rawdata_maxlength ); // Two Dimentional Array
	obj buffer_line = heap32_malloc( UART32_UARTMALLOC_MAXROW / 4 );
	uint32 length_arg = 0;
	uint32 length_temp = 0;
	uint32 var_index = 0;
	uint32 current_line = 0;
	uint32 status_nzcv = 0;
	pipe_list pipe_type = search_command;
	command_list command_type = null;
	flex32 var_temp;
	var_temp.u32 = 0;
	flex32 var_temp2;
	var_temp2.u32 = 0;
	flex32 var_temp3;
	var_temp3.u32 = 0;
	flex32 direction;
	direction.u32 = 0;
	dictionary label_list;
	label_list.name = heap32_malloc( label_maxlength * label_maxchar ); // Naming Length: Max. 7 bytes (7 Characters and 1 Null Character)
	label_list.number = heap32_malloc( label_maxlength ); // 4 Bytes (32-bit Integer) per Number
	label_list.length = 0;
	direction.s32 = 0;
	uint32 stack_offset = 1; // Stack offset for "push" and "pop", 1 is minimam, from the last line decremental order.
	String src_str = null;
	String dst_str = null;
	String temp_str = null;
	String temp_str2 = null;

	buffer_zero = heap32_malloc( UART32_UARTMALLOC_MAXROW + 1 / 4 ); // Add for Null Character

	fb32_clear_color( PRINT32_FONT_BACKCOLOR );

	if ( print32_set_caret( print32_string( str_aloha, FB32_X_CARET, FB32_Y_CARET, str32_strlen( str_aloha ) ) ) ) console_rollup();
	
	if ( init_usb_keyboard( 0 ) ) {
		kb_enable = true;
		_uartsettest( false, false, false );
	} else {
		kb_enable = false;
		if ( print32_set_caret( print32_string( str_serialmode, FB32_X_CARET, FB32_Y_CARET, str32_strlen( str_serialmode ) ) ) ) console_rollup();
		_uarttx( str_aloha, str32_strlen( str_aloha ) );
	}

	if ( ! _uartsetheap( initial_line ) ) {
		process_counter();
	}

	flag_execute = false;
	
	while ( true ) {
		if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) {
			if ( flag_execute ) {
				switch ( pipe_type ) {
					case search_command:

						/*  Pass Spaces and Label*/
						temp_str = pass_space_label( UART32_UARTINT_HEAP );

						/* Numeration Process */

						/* Select Command Type */
						if ( str32_strmatch( temp_str, 1, "*\0", 1 ) ) {
							/* Comment Will Be Immdiately Skipped */
							command_type = null;
							length_arg = 0;
							pipe_type = go_nextline;
							pipe_type = go_nextline;
						} else if ( str32_strlen( temp_str ) == 0 ) {
							/* Stop Execution If No Content in Line */
							/* Labels with No Initialization Becomes This Type */
							command_type = null;
							length_arg = 0;
							pipe_type = termination;
						} else if ( str32_strmatch( temp_str, 3, "end\0", 3 ) ) {
							command_type = null;
							length_arg = 0;
							pipe_type = termination;
						} else if ( str32_strmatch( temp_str, 5, "sleep\0", 5 ) ) {
							command_type = sleep;
							length_arg = 1;
							pipe_type = enumurate_variables;
							var_index = 0;
						} else if ( str32_strmatch( temp_str, 3, "arr\0", 3 ) ) {
							command_type = arr;
							length_arg = 4;
							pipe_type = enumurate_variables;
							var_index = 3; // Only Last One Is Needed to Translate to Integer
						} else if ( str32_strmatch( temp_str, 4, "free\0", 4 ) ) {
							command_type = free;
							length_arg = 1;
							pipe_type = enumurate_variables;
							var_index = 0; // Only Last One Is Needed to Translate to Integer
						} else if ( str32_strmatch( temp_str, 4, "pict\0", 4 ) ) {
							command_type = pict;
							length_arg = 4;
							pipe_type = enumurate_variables;
							var_index = 2; // Only Last Two Is Needed to Translate to Integer
						} else if ( str32_strmatch( temp_str, 3, "add\0", 3 ) ) {
							command_type = add;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "sub\0", 3 ) ) {
							command_type = sub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "mul\0", 3 ) ) {
							command_type = mul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "div\0", 3 ) ) {
							command_type = div;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "rem\0", 3 ) ) {
							command_type = rem;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "uadd\0", 4 ) ) {
							command_type = uadd;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "usub\0", 4 ) ) {
							command_type = usub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "umul\0", 4 ) ) {
							command_type = umul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "udiv\0", 4 ) ) {
							command_type = udiv;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "urem\0", 4 ) ) {
							command_type = urem;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "and\0", 3 ) ) {
							command_type = and;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "not\0", 3 ) ) {
							command_type = not;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 2, "or\0", 2 ) ) {
							command_type = or;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "xor\0", 3 ) ) {
							command_type = xor;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "lsl\0", 3 ) ) {
							command_type = lsl;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "lsr\0", 3 ) ) {
							command_type = lsr;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "rand\0", 4 ) ) {
							command_type = rand;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 3, "cmp\0", 3 ) ) {
							command_type = cmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( str32_strmatch( temp_str, 3, "tst\0", 3 ) ) {
							command_type = tst;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( str32_strmatch( temp_str, 4, "badd\0", 4 ) ) {
							command_type = badd;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "bsub\0", 4 ) ) {
							command_type = bsub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "bmul\0", 4 ) ) {
							command_type = bmul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "bdiv\0", 4 ) ) {
							command_type = bdiv;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "brem\0", 4 ) ) {
							command_type = brem;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "bcmp\0", 4 ) ) {
							command_type = bcmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( str32_strmatch( temp_str, 4, "fadd\0", 4 ) ) {
							command_type = fadd;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "fsub\0", 4 ) ) {
							command_type = fsub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "fmul\0", 4 ) ) {
							command_type = fmul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "fdiv\0", 4 ) ) {
							command_type = fdiv;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 5, "fsqrt\0", 5 ) ) {
							command_type = fsqrt;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "frad\0", 4 ) ) {
							command_type = frad;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "fsin\0", 4 ) ) {
							command_type = fsin;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "fcos\0", 4 ) ) {
							command_type = fcos;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "ftan\0", 4 ) ) {
							command_type = ftan;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 3, "fln\0", 3 ) ) {
							command_type = fln;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "flog\0", 4 ) ) {
							command_type = flog;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "fabs\0", 4 ) ) {
							command_type = fabs;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "fneg\0", 4 ) ) {
							command_type = fneg;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( str32_strmatch( temp_str, 4, "fcmp\0", 4 ) ) {
							command_type = fcmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( str32_strmatch( temp_str, 5, "input\0", 5 ) ) {
							command_type = input;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "print\0", 5 ) ) {
							command_type = print;
							length_arg = 2;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 4, "scmp\0", 4 ) ) {
							command_type = scmp;
							length_arg = 2;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 3, "mov\0", 3 ) ) {
							command_type = mov;
							length_arg = 2;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 3, "clr\0", 3 ) ) {
							command_type = clr;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 3, "jmp\0", 3 ) ) {
							command_type = jmp;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 4, "call\0", 4 ) ) {
							command_type = call;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 3, "ret\0", 3 ) ) {
							command_type = ret;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 4, "push\0", 4 ) ) {
							command_type = push;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 3, "pop\0", 3 ) ) {
							command_type = pop;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 3, "ptr\0", 3 ) ) {
							command_type = ptr;
							length_arg = 2;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "skpeq\0", 5 ) ) {
							command_type = skpeq;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "skpne\0", 5 ) ) {
							command_type = skpne;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "skpge\0", 5 ) ) {
							/* Jump Over One Line If Signed Greater Than or Equal */
							command_type = skpge;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "skple\0", 5 ) ) {
							/* Jump Over One Line If Signed Less Than or Equal */
							command_type = skple;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "skpgt\0", 5 ) ) {
							/* Jump Over One Line If Signed Greater Than */
							command_type = skpgt;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "skplt\0", 5 ) ) {
							/* Jump Over One Line If Signed Less Than */
							command_type = skplt;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "skpcs\0", 5 ) ) {
							command_type = skpcs;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "skpcc\0", 5 ) ) {
							command_type = skpcc;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( str32_strmatch( temp_str, 5, "clear\0", 5 ) ) {
							/* Clear All Lines */
							for (uint32 i = 0; i < UART32_UARTMALLOC_LENGTH; i++ ) {
								_uartsetheap( i );
								heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );
							}
							command_type = null;
							length_arg = 0;
							pipe_type = termination;
						} else {
							command_type = null;
							length_arg = 0;
							pipe_type = go_nextline;
						}

						current_line = UART32_UARTMALLOC_NUMBER;

						for ( uint32 i = 0; i < length_arg; i++ ) {
							length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
							if ( length_temp == -1 ) break;
							temp_str += length_temp;
							temp_str++; // Next of Space
							while ( str32_charsearch( temp_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space
								temp_str++;
							}
							if ( str32_charsearch( temp_str, 1, 0x2E ) != -1 ) { // Ascii Code of Period
								/* Label Argument Indicated by ".<NAME>" */
								temp_str++; // Next of Character
								length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = str32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = 0;
								for ( uint32 j = 0; j < label_list.length; j++ ) {
									temp_str2 = (String)label_list.name + 4 * label_maxchar * j;
									if ( str32_strmatch( temp_str2, str32_strlen( temp_str2 ), temp_str, length_temp ) ) {
										var_temp.u32 = _load_32( label_list.number + 4 * j );
										break; // Break For Loop
									}
								}
								_store_32( array_argpointer + 4 * i,  var_temp.u32 );
							} else if ( str32_charsearch( temp_str, 1, 0x3A ) != -1 ) { // Ascii Code of Colon
								/* Indiret Label Argument Indicated by ":<NAME>" */
								temp_str++; // Next of Character
								length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = str32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = 0;
								for ( uint32 j = 0; j < label_list.length; j++ ) {
									temp_str2 = (String)label_list.name + 4 * label_maxchar * j;
									if ( str32_strmatch( temp_str2, str32_strlen( temp_str2 ), temp_str, length_temp ) ) {
										var_temp.u32 = _load_32( label_list.number + 4 * j );
										break; // Break For Loop
									}
								}
								if ( _uartsetheap( var_temp.u32 ) ) _uartsetheap( initial_line );
								/*  Pass Spaces and Label*/
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								var_temp2.u32 = cvt32_string_to_int32( temp_str2, str32_strlen( temp_str2 ) );
								_store_32( array_argpointer + 4 * i,  var_temp2.u32 );
							} else if ( str32_charsearch( temp_str, 1, 0x25 ) != -1 ) { // Ascii Code of %
								/* Direct Argument Indicated by "%N" */
								temp_str++; // Next of Character
								length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = str32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = cvt32_string_to_int32( temp_str, length_temp );
								_store_32( array_argpointer + 4 * i,  var_temp.u32 );
							} else if ( str32_charsearch( temp_str, 1, 0x5B ) != -1 ) { // Ascii Code of [ (Square Bracket Left)
								/* Indirect Argument (Pointer) Indicated by "[N" */
								temp_str++; // Next of Character
								length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = str32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = cvt32_string_to_int32( temp_str, length_temp );
								if ( _uartsetheap( var_temp.u32 ) ) _uartsetheap( initial_line );
								/*  Pass Spaces and Label*/
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								var_temp2.u32 = cvt32_string_to_int32( temp_str2, str32_strlen( temp_str2 ) );
/*print32_debug( var_temp2.u32, 300, 300  );*/
								_store_32( array_argpointer + 4 * i,  var_temp2.u32 );
							}
						}

						break;

					case enumurate_variables:

						if ( _uartsetheap( _load_32( array_argpointer + 4 * var_index ) ) ) _uartsetheap( initial_line );

						/*  Pass Spaces and Label*/
						temp_str = pass_space_label( UART32_UARTINT_HEAP );
						if ( command_type >= fadd ) { // Type of Single Precision Float
							var_temp.f32 = cvt32_string_to_float32( temp_str, str32_strlen( temp_str ) );
							if ( var_temp.s32 == -1 ) {
								var_temp.s32 = cvt32_string_to_int32( temp_str, str32_strlen( temp_str ) );
								var_temp.f32 = vfp32_s32tof32( var_temp.s32 );
							}
							_store_32( array_source + 4 * var_index, var_temp.s32 );
						} else if ( command_type >= badd ){ // Type of Binary-coded Decimal
							var_temp.u32 = str32_charindex( temp_str, 0x2E ); // Ascii Code of Period
							if ( var_temp.u32 == -1 ) var_temp.u32 = str32_strlen( temp_str );
							_store_32( array_source + 8 * var_index, (obj)temp_str );
							_store_32( array_source + 8 * var_index + 4, var_temp.u32 );
						} else { // Type of 32-bit Signed Integer
							if( str32_charindex( temp_str, 0x2E ) != -1 ) { // Ascii Code of Period
								var_temp.f32 = cvt32_string_to_float32( temp_str, str32_strlen( temp_str ) );
								var_temp.s32 = vfp32_f32tos32( var_temp.f32 );
							} else {
								var_temp.s32 = cvt32_string_to_int32( temp_str, str32_strlen( temp_str ) );
							}
							_store_32( array_source + 4 * var_index, var_temp.s32 );
						}

						var_index++;
						if ( var_index >= length_arg ) pipe_type = execute_command;

						break;

					case execute_command:

						switch ( command_type ) {
							case sleep:
								_sleep( _load_32( array_source ) );
								break;
							case arr:
								for ( uint32 i = 0; i < rawdata_maxlength; i++ ) {
									var_temp.u32 = _load_32( array_rawdata + 4 * i );
									if ( var_temp.u32 == 0 ) {
										var_temp.u32 = _load_32( array_argpointer + 4 );
										var_temp2.u32 = _load_32( array_argpointer + 8 );
										if ( _uartsetheap( var_temp.u32 ) ) break;
										dst_str = pass_space_label( UART32_UARTINT_HEAP );
										var_temp.u32++;
										for ( uint32 j = var_temp.u32; j <= var_temp2.u32; j++ ) {
											temp_str = dst_str;
											if ( _uartsetheap( j ) ) break;
											temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
											dst_str = str32_strcat( temp_str, temp_str2 );	
											if ( j != var_temp.u32 ) { // No Initial Round
												heap32_mfree( (obj)temp_str );
											}
										}

										var_temp.u32 = cvt32_string_to_intarray( dst_str, str32_strlen( dst_str ), _load_32( array_source + 12 ) );
//print32_debug( var_temp.u32, 400, 400 );
										_store_32( array_rawdata + 4 * i, var_temp.u32 );
										str_direction = cvt32_int32_to_string_deci( i, 1, 0 );
										break;
									}
								}

								break;
							case free:
								var_temp.u32 = _load_32( array_source );
								if ( var_temp.u32 >= rawdata_maxlength ) break;
								var_temp2.u32 = _load_32( array_rawdata + 4 * var_temp.u32 );
//print32_debug( var_temp2.u32, 400, 436 );
								heap32_mfree( var_temp2.u32 );
								_store_32( array_rawdata + 4 * var_temp.u32, 0 );

								break;
							case pict:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break; 
								temp_str = pass_space_label( UART32_UARTINT_HEAP );
								if ( _uartsetheap( _load_32( array_argpointer + 4 ) ) ) break; 
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								var_temp.u32 = _load_32( array_source + 8 );
								if ( var_temp.u32 >=  rawdata_maxlength ) break;
								var_temp.object = _load_32( array_rawdata + 4 * var_temp.u32 );
								if ( var_temp.object == 0 ) break;
								var_temp2.u32 = _load_32( array_source + 12 );

								command_pict( temp_str, temp_str2, var_temp.object, var_temp2.u32 ); 

								break;
							case add:
								direction.s32 = _load_32( array_source + 4 ) + _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case sub:
								direction.s32 = _load_32( array_source + 4 ) - _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case mul:
								direction.s32 = arm32_mul( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = cvt32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case div:
								direction.s32 = arm32_sdiv( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = cvt32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case rem:
								direction.s32 = arm32_srem( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = cvt32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case uadd:
								direction.u32 = _load_32( array_source + 4 ) + _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_hexa( direction.u32, 1, 0, 1 );
								break;
							case usub:
								direction.u32 = _load_32( array_source + 4 ) - _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_hexa( direction.u32, 1, 0, 1 );
								break;
							case umul:
								direction.u32 = arm32_mul( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = cvt32_int32_to_string_hexa( direction.u32, 1, 0, 1 );
								break;
							case udiv:
								direction.u32 = arm32_udiv( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = cvt32_int32_to_string_hexa( direction.u32, 1, 0, 1 );
								break;
							case urem:
								direction.u32 = arm32_urem( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = cvt32_int32_to_string_hexa( direction.u32, 1, 0, 1 );
								break;
							case and:
								direction.u32 = _load_32( array_source + 4 ) & _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case not:
								direction.u32 = ~( _load_32( array_source + 4 ) );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case or:
								direction.u32 = _load_32( array_source + 4 ) | _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case xor:
								direction.u32 = _load_32( array_source + 4 ) ^ _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case lsl:
								direction.u32 = _load_32( array_source + 4 ) << _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case lsr:
								direction.u32 = _load_32( array_source + 4 ) >> _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case rand:
								direction.u32 =  _random( 255 );
								str_direction = cvt32_int32_to_string_deci( direction.u32, 1, 0 );
								break;
							case cmp:
								status_nzcv = arm32_cmp( _load_32( array_source ), _load_32( array_source + 4 ) );

								break;
							case tst:
								status_nzcv = arm32_tst( _load_32( array_source ), _load_32( array_source + 4 ) );

								break;
							case badd:
								str_direction = bcd32_badd( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								break;
							case bsub:
								str_direction = bcd32_bsub( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								break;
							case bmul:
								str_direction = bcd32_bmul( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								break;
							case bdiv:
								str_direction = bcd32_bdiv( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								break;
							case brem:
								str_direction = bcd32_brem( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								break;
							case bcmp:
								status_nzcv = bcd32_bcmp( (String)_load_32( array_source ), _load_32( array_source + 4 ), (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ) );

								break;
							case fadd:
								direction.f32 = vfp32_fadd( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fsub:
								direction.f32 = vfp32_fsub( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fmul:
								direction.f32 = vfp32_fmul( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fdiv:
								direction.f32 = vfp32_fdiv( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fsqrt:
								direction.f32 = vfp32_fsqrt( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case frad:
								direction.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fsin:
								direction.f32 = math32_sin( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fcos:
								direction.f32 = math32_cos( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case ftan:
								direction.f32 = math32_tan( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fln:
								direction.f32 = math32_ln( ( vfp32_hexatof32( _load_32( array_source + 4 ) ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case flog:
								direction.f32 = math32_log( ( vfp32_hexatof32( _load_32( array_source + 4 ) ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fabs:
								direction.u32 = _load_32( array_source + 4 ) & ~(0x80000000); // ~ is Not (Inverter), Sign Bit[31] Clear
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fneg:
								direction.u32 = _load_32( array_source + 4 ) | 0x80000000; // Sign Bit[31] Set
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );

								break;
							case fcmp:
								status_nzcv = vfp32_fcmp( vfp32_hexatof32( _load_32( array_source ) ), vfp32_hexatof32( _load_32( array_source + 4 ) ) );

								break;
							case input:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								text_sender( ">>\0" );
								text_sender( UART32_UARTINT_HEAP );
								var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
								if ( var_temp.u32 >= UART32_UARTMALLOC_MAXROW ) {
									var_temp.u32 = UART32_UARTMALLOC_MAXROW - 1;
									text_sender( "\x1B[D\0" );
								}
								_store_32( UART32_UARTINT_COUNT_ADDR, var_temp.u32 );
								_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
								while (true) {
									input_keyboard();
									if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) break;
								}

								break;
							case print:
								var_temp.u32 = _load_32( array_argpointer );
								var_temp2.u32 = _load_32( array_argpointer + 4 );
								if ( var_temp2.u32 < var_temp.u32 ) var_temp2.u32 = var_temp.u32; // If Second Argument Is Not Defined, etc.
								for ( uint32 i = var_temp.u32; i <= var_temp2.u32; i++ ) {
									if ( _uartsetheap( i ) ) break; 
									command_print( UART32_UARTINT_HEAP );
								}

								break;
							case scmp:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								temp_str = pass_space_label( UART32_UARTINT_HEAP );
								if ( _uartsetheap( _load_32( array_argpointer + 4 ) ) ) break; 
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								status_nzcv = 0;
								if ( str32_strmatch( temp_str, str32_strlen( temp_str ), temp_str2, str32_strlen( temp_str2 ) ) ) {
									/* Equal; Z Bit[30] == 1 */
									status_nzcv |= 0x40000000;
								}

								break;
							case mov:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								dst_str = UART32_UARTINT_HEAP;
								if ( _uartsetheap( _load_32( array_argpointer + 4 ) ) ) break;
								src_str = UART32_UARTINT_HEAP;

								/* Pass Spaces and Label */
								temp_str = pass_space_label( dst_str );
								var_temp.u32 = temp_str - dst_str;
								temp_str2 = pass_space_label( src_str );
								var_temp2.u32 = temp_str2 - src_str;

								var_temp3.u32 = str32_strlen( temp_str2 );
								if ( var_temp3.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp3.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
								heap32_mcopy( (obj)dst_str, var_temp.u32, (obj)src_str, var_temp2.u32, var_temp3.u32 + 1 ); // Add Null Character
								line_clean( dst_str );

								break;
							case clr:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );

								break;
							case jmp:
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case call:
								_store_32( array_link + array_link_offset * 4, current_line );
								array_link_offset++;
								if ( array_link_offset >= link_stacksize ) array_link_offset = link_stacksize - 1;
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case ret:
								if ( array_link_offset <= 0 ) break;
								array_link_offset--;
								current_line = _load_32( array_link + array_link_offset * 4 );

								break;
							case push:
								if ( _uartsetheap(  UART32_UARTMALLOC_LENGTH - stack_offset ) ) break;
								dst_str = UART32_UARTINT_HEAP;
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								src_str = UART32_UARTINT_HEAP;

								/* Pass Spaces and Label */
								temp_str = pass_space_label( src_str );
								var_temp.u32 = temp_str - src_str;
								var_temp2.u32 = str32_strlen( temp_str );
								heap32_mcopy( (obj)dst_str, 0, (obj)src_str, var_temp.u32, var_temp2.u32 + 1 ); // Add Null Character
								line_clean( dst_str );

								stack_offset++;

								break;
							case pop:
								if ( stack_offset <= 1 ) break;
								stack_offset--;
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								dst_str = UART32_UARTINT_HEAP;
								if ( _uartsetheap( UART32_UARTMALLOC_LENGTH - stack_offset ) ) break;
								src_str = UART32_UARTINT_HEAP;

								/* Pass Spaces and Label */
								temp_str = pass_space_label( dst_str );
								var_temp.u32 = temp_str - dst_str;
								var_temp2.u32 = str32_strlen( src_str );
								if ( var_temp2.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp2.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
								heap32_mcopy( (obj)dst_str, var_temp.u32, (obj)src_str, 0, var_temp2.u32 + 1 ); // Add Null Character
								line_clean( dst_str );

								break;
							case ptr:
								/* Equal; Z Bit[30] == 1 */
								direction.u32 = _load_32( array_argpointer + 4 );
								str_direction = cvt32_int32_to_string_deci( direction.u32, 1, 0 );

								break;
							case skpeq:
								/* Equal; Z Bit[30] == 1 */
								if ( status_nzcv & 0x40000000 ) current_line++;

								break;
							case skpne:
								/* Not Equal: Z Bit[30] != 1 */
								if ( ! ( status_nzcv & 0x40000000 ) ) current_line++;

								break;
							case skpge:
								/* Greater Than or Equal: N Bit[31] == V Bit[28] */
								if ( ( status_nzcv & 0x80000000 ) == ( status_nzcv & 0x10000000 ) ) current_line++;

								break;
							case skple:
								/* Less Than or Equal: N Bit[31] != V Bit[28] || Z Bit[30] == 1 */
								if ( ( ( status_nzcv & 0x80000000 ) != ( status_nzcv & 0x10000000 ) || ( status_nzcv & 0x40000000 ) ) ) current_line++;

								break;
							case skpgt:
								/* Greater Than: N Bit[31] == V Bit[28] && Z Bit[30] == 0 */
								if ( ( ( status_nzcv & 0x80000000 ) == ( status_nzcv & 0x10000000 ) && ( ! ( status_nzcv & 0x40000000 ) ) ) ) current_line++;

								break;
							case skplt:
								/* Less Than: N Bit[31] != V Bit[28] */
								if ( ( status_nzcv & 0x80000000 ) != ( status_nzcv & 0x10000000 ) ) current_line++;

								break;
							case skpcs:
								/* Less Than: C Bit[29] == 1 */
								if ( status_nzcv & 0x20000000 ) current_line++;

								break;
							case skpcc:
								/* Less Than: C Bit[29] != 1 */
								if ( ! ( status_nzcv & 0x20000000 ) ) current_line++;

								break;
							default:
								break;
						}

						pipe_type = go_nextline;
						if ( str_direction == null ) break;
						if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
						/* Pass Spaces and Label */
						temp_str = pass_space_label( UART32_UARTINT_HEAP );
						var_temp.u32 = temp_str - UART32_UARTINT_HEAP;
						var_temp2.u32 = str32_strlen( str_direction );
						if ( var_temp2.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp2.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
						heap32_mcopy( (obj)UART32_UARTINT_HEAP, var_temp.u32, (obj)str_direction, 0, var_temp2.u32 + 1 ); // Add Null Character
						line_clean( UART32_UARTINT_HEAP );
						str_direction = (String)heap32_mfree( (obj)str_direction );

						break;

					case go_nextline:
						/* Continue Process */

						/* Clean Arrays About Arguments on Each Command */
						heap32_mfill( array_argpointer, 0 );
						heap32_mfill( array_source, 0 );

						if ( _uartsetheap( current_line + 1 ) ) {
							pipe_type = termination;
						} else {
							pipe_type = search_command;
						}

						break;

					case termination:
						/* End Process */

						/* Clean Memory Spaces  */
						heap32_mfill( label_list.name, 0 );
						heap32_mfill( label_list.number, 0 );
						label_list.length = 0;
						for ( uint32 i = 0; i < rawdata_maxlength; i++ ) {
							var_temp.u32 = _load_32( array_rawdata + 4 * i );
							heap32_mfree( var_temp.u32 );
						}
						heap32_mfill( array_rawdata, 0 );

						/* Print Commands Untill Line with Null Character */
						for ( uint32 i = initial_line; i < UART32_UARTMALLOC_LENGTH; i++ ) {
							_uartsetheap( i );
							process_counter();
							var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
							if ( var_temp.u32 == 0 ) break;
							text_sender( UART32_UARTINT_HEAP );
							if ( i < UART32_UARTMALLOC_LENGTH - 1 ) text_sender( "\r\n\0" ); // If Not Last Line
						}
						
						pipe_type = search_command;
						flag_execute = false;
						var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
						if ( var_temp.u32 >= UART32_UARTMALLOC_MAXROW ) {
							var_temp.u32 = UART32_UARTMALLOC_MAXROW - 1;
							text_sender( "\x1B[D\0" );
						}
						_store_32( UART32_UARTINT_COUNT_ADDR, var_temp.u32 );
						_store_32( UART32_UARTINT_BUSY_ADDR, 0 );

						break;

					default:

						break;
				}
			} else {
				if ( str32_strmatch( UART32_UARTINT_HEAP, 3, "run\0", 3 ) ) {
					/* If You Command "run", It Starts Execution */
					/* Retrieve Previous Content in Line that is Wrote Meta Command */
					heap32_mcopy( (obj)UART32_UARTINT_HEAP, 0, buffer_line, 0, str32_strlen( (String)buffer_line ) + 1 ); // Add Null Character
					line_clean( UART32_UARTINT_HEAP );

					flag_execute = true;
					pipe_type = search_command;
					text_sender( "\x1B[2J\x1B[H\0" ); // Clear All Screen and Move Cursor to Upper Left

					/* Labels Enumuration */
					for ( uint32 i = initial_line; i < UART32_UARTMALLOC_LENGTH; i++ ) {
						_uartsetheap( i );
						temp_str = UART32_UARTINT_HEAP;
						/* Pass Spaces */
						while ( str32_charsearch( temp_str, 1, 0x20 ) != -1 ) { // Ascii Code of Spaces
							temp_str++;
						}
						var_temp.u32 = str32_charsearch( temp_str, 1, 0x2E ); // Ascii Code of Period
						if ( var_temp.u32 != -1 ) {
//print32_debug( var_temp.u32, 400, 300  );
							temp_str++;
							var_temp.u32 = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
							if ( var_temp.u32 == -1 ) { // If Not Initialized
								text_sender( "Error! No Initialized Label: \0" );
								process_counter();
								pipe_type = termination;
								break; // Break from for loop, NOT IF STATEMENT
							}
							if ( var_temp.u32 > label_maxchar * 4 - 1 ) var_temp.u32 = label_maxchar * 4 - 1; // Subtract One for Null Character
							var_temp2.u32 = temp_str - UART32_UARTINT_HEAP;
							/* Store Name of Label */
							/* heap32_mcopy can't slide the address of Heap because of its system for verifying overflow */
							heap32_mcopy( label_list.name, label_maxchar * 4 * label_list.length, (obj)UART32_UARTINT_HEAP, var_temp2.u32, var_temp.u32 );
							/* Store Line Number of Label */
							_store_32( label_list.number + 4 * label_list.length, i );
							label_list.length++;
							/* Maximum Length of Label List is 16 */
							if ( label_list.length > label_maxlength ) label_list.length = label_maxlength;
						}
					}

					_uartsetheap( initial_line );

//print32_debug_hexa( label_list.name, 400, 400, 64 );
//print32_debug_hexa( label_list.number, 400, 424, 64 );

				} else if ( str32_strmatch( UART32_UARTINT_HEAP, 3, "set\0", 3 ) ) {
					/* If You Command "set <LineNumber>", It Sets Line */
					text_sender( "\x1B[2J\x1B[H\0" ); // Clear All Screen and Move Cursor to Upper Left
					temp_str = UART32_UARTINT_HEAP;
					var_temp.u32 = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
					if ( var_temp.u32 == -1 ) {
						var_temp.u32 = str32_strlen( temp_str );
					} else {
						var_temp.u32++; // Next to Space
					}
					temp_str += var_temp.u32;
					var_temp.u32 = cvt32_string_to_int32( temp_str, str32_strlen( temp_str ) );
					/* Retrieve Previous Content in Line that is Wrote Meta Command */
					heap32_mcopy( (obj)UART32_UARTINT_HEAP, 0, buffer_line, 0, str32_strlen( (String)buffer_line ) + 1 ); // Add Null Character
					line_clean( UART32_UARTINT_HEAP );
					if ( var_temp.u32 < initial_line ) var_temp.u32 = initial_line;
					if ( _uartsetheap( var_temp.u32 ) ) _uartsetheap( initial_line );
					/* Save Content in Line to Buffer for Retrieve It When Meta Command Is Wrote in Line */
					heap32_mcopy( buffer_line, 0, (obj)UART32_UARTINT_HEAP, 0, str32_strlen(UART32_UARTINT_HEAP) + 1 ); // Add Null
					process_counter();
					text_sender( UART32_UARTINT_HEAP );
					var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
					if ( var_temp.u32 >= UART32_UARTMALLOC_MAXROW ) {
						var_temp.u32 = UART32_UARTMALLOC_MAXROW - 1;
						text_sender( "\x1B[D\0" );
					}
					_store_32( UART32_UARTINT_COUNT_ADDR, var_temp.u32 );
					_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
				} else {
					text_sender( "\r\n\0" ); // Send These Because Teletype Is Only Mirrored Carriage Return from Host
					if ( _uartsetheap( UART32_UARTMALLOC_NUMBER + 1 ) ) _uartsetheap( initial_line );
					/* Save Content in Line to Buffer for Retrieve It When Meta Command Is Wrote in Line */
					heap32_mcopy( buffer_line, 0, (obj)UART32_UARTINT_HEAP, 0, str32_strlen(UART32_UARTINT_HEAP) + 1 ); // Add Null
					process_counter();
					text_sender( UART32_UARTINT_HEAP );
					var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
					if ( var_temp.u32 >= UART32_UARTMALLOC_MAXROW ) {
						var_temp.u32 = UART32_UARTMALLOC_MAXROW - 1;
						text_sender( "\x1B[D\0" );
					}
					_store_32( UART32_UARTINT_COUNT_ADDR, var_temp.u32 );
					_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
				}
			}
		}
		input_keyboard();
	}

	return EXIT_SUCCESS;
}


bool input_keyboard() {
	flex32 var_temp;
	var_temp.u32 = 0;
	if ( kb_enable ) {
		String kb_str = _keyboard_get( 0, 1, ticket_hid );
		arm32_dsb();
		if ( kb_str > 0 ) {
			// Erase Cursor
			var_temp.u32 = _load_32( UART32_UARTINT_COUNT_ADDR );
			if ( (uchar8)_load_8( (obj)UART32_UARTINT_HEAP + var_temp.u32 ) ) {
				// If Other than Null Character (Assumes Real Character)
				print32_string( UART32_UARTINT_HEAP + var_temp.u32, FB32_X_CARET, FB32_Y_CARET, 1 );
			} else {
				// If Null Character
				print32_string( " \0", FB32_X_CARET, FB32_Y_CARET, 1 );
			}
			for ( uint32 i = 0; i < str32_strlen( kb_str ); i++ ) {
				var_temp.u8 = _load_8( (obj)kb_str + i );
				String temp_str = _uartint_emulate( UART32_UARTMALLOC_MAXROW, true, var_temp.u8 );
				if ( temp_str ) { // If Not Error(0)
					if ( str32_charsearch( temp_str, 1, 0x15 ) == -1 ) { // If Not NAK
						if ( print32_set_caret( print32_string( temp_str, FB32_X_CARET, FB32_Y_CARET, str32_strlen( temp_str ) ) ) ) console_rollup();
					}
				}
				heap32_mfree( (obj)temp_str );
			}
			if ( FB32_X_CARET ) set_cursor(); // If Not On Left Edge by Carriage Return
			heap32_mfree( (obj)kb_str );
		}
		_sleep( 40000 );
	}

	return true;
}


bool set_cursor() {
	uint32 count = _load_32( UART32_UARTINT_COUNT_ADDR );
	print32_string( "\x1B[7m \x1B[0m\0", FB32_X_CARET, FB32_Y_CARET, 9 );
	if ( count ) {
		// If Count is Bigger than 0
		if ( print32_set_caret( print32_string( "\x1B[D\0", FB32_X_CARET, FB32_Y_CARET, 3 ) ) ) console_rollup();
		if ( print32_set_caret( print32_string( UART32_UARTINT_HEAP + count - 1, FB32_X_CARET, FB32_Y_CARET, 1 ) ) ) console_rollup();
	}
	if ( count < UART32_UARTMALLOC_MAXROW - 1 ) { // If Count Reaches Maximum, Do Nothing
		if ( print32_set_caret( print32_string( "\x1B[C\0", FB32_X_CARET, FB32_Y_CARET, 3 ) ) ) console_rollup();
		if ( (uchar8)_load_8( (obj)UART32_UARTINT_HEAP + count + 1 ) ) {
			// If Other than Null Character (Assumes Real Character)
			if ( print32_set_caret( print32_string( UART32_UARTINT_HEAP + count + 1, FB32_X_CARET, FB32_Y_CARET, 1 ) ) ) console_rollup();
		} else {
			// If Null Character
			if ( print32_set_caret( print32_string( " \0", FB32_X_CARET, FB32_Y_CARET, 1 ) ) ) console_rollup();
		}
		if ( print32_set_caret( print32_string( "\x1B[D\x1B[D\0", FB32_X_CARET, FB32_Y_CARET, 6 ) ) ) console_rollup();
	}

	return true;
}


bool process_counter() {
	String str_process_counter = cvt32_int32_to_string_deci( UART32_UARTMALLOC_NUMBER, 2, 0 ); // Min. 2 Digit, Unsigned
	text_sender( "|\0" );
	text_sender( str_process_counter );
	text_sender( "| \0" );
	heap32_mfree( (obj)str_process_counter );

	return true;
}


bool text_sender( String target_str ) {
	uint32 length = str32_strlen( target_str );
	if ( kb_enable ) {
		if ( print32_set_caret( print32_string( target_str, FB32_X_CARET, FB32_Y_CARET, length ) ) ) console_rollup();
	} else {
		_uarttx( target_str, length ); // Clear All Screen and Move Cursor to Upper Left
	}

	return true;
}


String pass_space_label( String target_str ) {

	/* Pass Spaces  */
	while ( str32_charsearch( target_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space 
		target_str++;
	}
	/* Pass Label Itself */
	if ( str32_charsearch( target_str, 1, 0x2E ) != -1 ) { // Period
		uint32 length_temp = str32_charindex( target_str, 0x20 ); // Ascii Code of Space
		if ( length_temp == -1 ) length_temp = str32_strlen( target_str );
		if ( length_temp != -1 ) {
			target_str += length_temp;
			/* Pass Spaces After Label */
			while ( str32_charsearch( target_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space 
				target_str++;
			}
		}
	}

	return target_str;
}


/* Clean Back of Line After Null Character */
bool line_clean( String target_str ) {
	uint32 length_temp = str32_strlen( target_str ); // Ascii Code of Space
	heap32_mcopy( (obj)target_str, length_temp, buffer_zero, 0, UART32_UARTMALLOC_MAXROW - length_temp ); // Add Null Character

	return true;
}


bool command_print( String target_str ) {
	String temp_str = pass_space_label( target_str );
	uint32 temp_str_index;
	while ( str32_strlen( temp_str ) ) {
		if ( str32_strindex( temp_str, "\\n\0" ) != -1 ) {
			temp_str_index = str32_strindex( temp_str, "\\n\0" );
			text_sender( temp_str );
			text_sender( "\r\n\0" );
			temp_str += temp_str_index;
			temp_str += 2;
		} else if ( str32_strindex( temp_str, "\\s\0" ) != -1 ) {
			temp_str_index = str32_strindex( temp_str, "\\s\0" );
			text_sender( temp_str );
			text_sender( " \0" );
			temp_str += temp_str_index;
			temp_str += 2;
		} else if ( str32_strindex( temp_str, "\\e\0" ) != -1 ) {
			temp_str_index = str32_strindex( temp_str, "\\e\0" );
			text_sender( temp_str );
			text_sender( "\x1B\0" );
			temp_str += temp_str_index;
			temp_str += 2;
		} else {
			temp_str_index = str32_strlen( temp_str );
			text_sender( temp_str );
			temp_str += temp_str_index;
		}
	}

	return true; 
}


bool command_pict( String true_str, String false_str, obj array, uint32 size_indicator ) {
	uint32 size_array = heap32_mcount( array ); 
	if ( size_indicator > 2 ) size_indicator = 2;
	uint32 count_array = size_array >> size_indicator;
	size_indicator = 1 << size_indicator;
	int32 length_data = 8 * size_indicator; // 1 Byte equals 8 Bits
	for ( uint32 i = 0; i < count_array; i++ ) {
		uint32 data = _load_32( array + size_indicator * i );
		for ( int32 j = length_data - 1; j >= 0; j-- ) {
			uint32 bit = data & true << j;
			if ( bit ) {
				command_print( true_str );
			} else {
				command_print( false_str );
			}
		}
		text_sender( "\r\n\0" );
	}

	return true;
}


bool console_rollup() {
	fb32_image(
			FB32_ADDR,
			0,
			-PRINT32_FONT_HEIGHT,
			FB32_WIDTH,
			FB32_HEIGHT,
			0,
			0,
			0,
			0
	);
	FB32_X_CARET = 0;
	FB32_Y_CARET = FB32_HEIGHT - PRINT32_FONT_HEIGHT;
	print32_string( "\x1B[2K", FB32_X_CARET, FB32_Y_CARET, 4 );

	return true;
}


bool init_usb_keyboard( uint32 usb_channel )
{

	_sleep( 200000 );

	_otg_host_reset_bcm();

	ticket_hub = _hub_activate( usb_channel, 0 );
	arm32_dsb();

//print32_debug( ticket_hub, 500, 230 );

	if ( ticket_hub == -2 ) {
		ticket_hid = 0; // Direct Connection
	} else if ( ticket_hub > 0 ) {
		ticket_hid = _hub_search_device( usb_channel, ticket_hub );
#ifdef __B
		arm32_dsb();
		ticket_hid = _hub_search_device( usb_channel, ticket_hub );
#endif
	} else {
		return false;
	}
	arm32_dsb();

//print32_debug( ticket_hid, 500, 242 );

	if ( ticket_hid <= 0 ) return false;

	_sleep( 500000 ); // Hub Port is Powerd On, So Wait for Activation of Device

	uint32 response = _hid_activate( usb_channel, 1, ticket_hid );
	arm32_dsb();

	if ( response != ticket_hid ) return false;

	//_hid_setidle( usb_channel, 0, ticket_hid );

	return true;
}
