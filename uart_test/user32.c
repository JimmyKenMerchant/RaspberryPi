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

String pass_space_label( String target_str ); 

extern String UART32_UARTINT_HEAP;
extern uint32 UART32_UARTINT_BUSY_ADDR;
extern uint32 UART32_UARTINT_COUNT_ADDR;
extern uint32 UART32_UARTMALLOC_LENGTH;
extern uint32 UART32_UARTMALLOC_NUMBER;
extern uint32 UART32_UARTMALLOC_MAXROW;

/* D: Line Number for Direction, S1: Line Number Stored First Source, S2: Line Number Stored Second Source */
typedef enum _command_list {
	null,
	sleep, // Sleep Microseconds by Integer "Sleep %S1"
	add, // Integer Addition, "add %D %S1 %S2": D = S1 + S2. -2,147,483,648 through 2,147,483,647.
	sub,
	mul,
	div,
	rem,
	rand,
	cmp, // Compare Two Values of Integer, "cmp %S1 %S2": Reflects NZCV Flags.
	badd, // Binary-coded Decimal, "badd %D %S1 %S2": D = S1 + S2. -9,999,999,999,999,999 through 9,999,999,999,999,999.
	bsub,
	bmul,
	bdiv,
	brem,
	bcmp,
	fadd, // Floating Point Addition, "fadd %D %S1 %S2": D = S1 + S2.
	fsub, // Float Point Subtruction, "fsub %D %S1 %S2": D = S1 - S2.
	fmul,
	fdiv,
	fsqrt, // Square Root, "fsqrt %D %S1": D = S1^1/2
	frad, // Radian, "frad %D %S1": D = S1 * pi/180.0 
	fsin, // Sine by Radian on Float, "sin %D %S1": D = sin(S1).
	fcos,
	ftan,
	fln,
	flog,
	fabs,
	fneg,
	fcmp, // Compare Two Values of Floating Point, "fcmp %S1 %S2": Reflects NZCV Flags.
	input, // Input to the Line, "input %D"
	print,
	mov, // Copy, "mov %D %S1"
	clr, // Clear Line, "clr %D"
	jmp, // Jump to the Line, "jmp %S1": Next line will be the number in S1.
	call, // Jump to the Line and Store Current Line to Stack (Last In First Out) for Link
	ret, // Return to Previous Line Stored in Stack
	push,
	pop,
	skpeq, // Skip One Line If Equal, just "skpeq": Use next to a "cmp.." command.
	skpne,
	skpge,
	skple,
	skpgt,
	skplt,
	run, // Runs Script From List Number Zero
	clear // Clear All in Every Line
} command_list;


typedef enum _pipe_list {
	search_command,
	enumurate_variables,
	execute_command,
	go_nextline,
	termination
} pipe_list;


typedef union _flex32 {
	float32 f32;
	int32 s32;
	uint32 u32;
	obj oj;
} flex32;


typedef struct _dictionary {
	obj name;
	obj number;
	uint32 length;
} dictionary;


bool flag_execute;


void _user_start()
{

	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	String str_aloha = "Aloha Calc Version 0.8.5 Alpha: Copyright (C) 2018 Kenta Ishii\r\n\0";
	String str_process_counter = null;
	String str_direction = null;
	obj array_source = heap32_malloc( 8 );
	obj array_argpointer = heap32_malloc( 8 );
	obj array_link = heap32_malloc( 32 );
	uint32 array_link_offset = 0;
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
	flex32 direction;
	direction.u32 = 0;
	dictionary label_list;
	label_list.name = heap32_malloc( 32 ); // Naming Length: Max. 8 bytes (8 Characters)
	label_list.number = heap32_malloc( 16 ); // 4 Bytes (32-bit Integer) per Number
	label_list.length = 0;
	direction.s32 = 0;
	uint32 stack_offset = 1; // Stack offset for "push" and "pop", 1 is minimam, from the last line decremental order.
	String src_str = null;
	String dst_str = null;
	String temp_str = null;
	String temp_str2 = null;

	if ( print32_set_caret( print32_string( str_aloha, FB32_X_CARET, FB32_Y_CARET, COLOR32_YELLOW, back_color, print32_strlen( str_aloha ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_aloha, print32_strlen( str_aloha ) );

	_uarttx( "00: \0", 4 );

	flag_execute = false;
	
	while ( true ) {
		if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) {
			if ( flag_execute ) {
				switch ( pipe_type ) {
					case search_command:

						/*  Pass Spaces */
						temp_str = pass_space_label( UART32_UARTINT_HEAP );
						/* Pass Spaces  */
						while ( print32_charsearch( temp_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space 
						temp_str++;
						}

						/* Numeration Process */

						/* Select Command Type */
						if ( print32_strsearch( temp_str, 1, "*\0", 1 ) != -1 ) {
							/* Comment Will Be Immdiately Skipped */
							command_type = null;
							length_arg = 0;
							pipe_type = go_nextline;
						} else if ( print32_strsearch( temp_str, 1, ".\0", 1 ) != -1 ) {
							/* Skip If Label */
							command_type = null;
							length_arg = 0;
							pipe_type = go_nextline;
						} else if ( print32_strlen( temp_str ) == 0 ) {
							/* Stop Execution If No Content in Line */
							command_type = null;
							length_arg = 0;
							pipe_type = termination;
						} else if ( print32_strsearch( temp_str, 5, "sleep\0", 5 ) != -1 ) {
							command_type = sleep;
							length_arg = 1;
							pipe_type = enumurate_variables;
							var_index = 0;
						} else if ( print32_strsearch( temp_str, 3, "add\0", 3 ) != -1 ) {
							command_type = add;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 3, "sub\0", 3 ) != -1 ) {
							command_type = sub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 3, "mul\0", 3 ) != -1 ) {
							command_type = mul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 3, "div\0", 3 ) != -1 ) {
							command_type = div;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 3, "rem\0", 3 ) != -1 ) {
							command_type = rem;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "rand\0", 4 ) != -1 ) {
							command_type = rand;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 3, "cmp\0", 3 ) != -1 ) {
							command_type = cmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( print32_strsearch( temp_str, 4, "badd\0", 4 ) != -1 ) {
							command_type = badd;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "bsub\0", 4 ) != -1 ) {
							command_type = bsub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "bmul\0", 4 ) != -1 ) {
							command_type = bmul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "bdiv\0", 4 ) != -1 ) {
							command_type = bdiv;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "brem\0", 4 ) != -1 ) {
							command_type = brem;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "bcmp\0", 4 ) != -1 ) {
							command_type = bcmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( print32_strsearch( temp_str, 4, "fadd\0", 4 ) != -1 ) {
							command_type = fadd;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "fsub\0", 4 ) != -1 ) {
							command_type = fsub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "fmul\0", 4 ) != -1 ) {
							command_type = fmul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "fdiv\0", 4 ) != -1 ) {
							command_type = fdiv;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 5, "fsqrt\0", 5 ) != -1 ) {
							command_type = fsqrt;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "frad\0", 4 ) != -1 ) {
							command_type = frad;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "fsin\0", 4 ) != -1 ) {
							command_type = fsin;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "fcos\0", 4 ) != -1 ) {
							command_type = fcos;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "ftan\0", 4 ) != -1 ) {
							command_type = ftan;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 3, "fln\0", 3 ) != -1 ) {
							command_type = fln;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "flog\0", 4 ) != -1 ) {
							command_type = flog;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "fabs\0", 4 ) != -1 ) {
							command_type = fabs;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "fneg\0", 4 ) != -1 ) {
							command_type = fneg;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( temp_str, 4, "fcmp\0", 4 ) != -1 ) {
							command_type = fcmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( print32_strsearch( temp_str, 5, "input\0", 5 ) != -1 ) {
							command_type = input;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "print\0", 5 ) != -1 ) {
							command_type = print;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 3, "mov\0", 3 ) != -1 ) {
							command_type = mov;
							length_arg = 2;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 3, "clr\0", 3 ) != -1 ) {
							command_type = clr;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 3, "jmp\0", 3 ) != -1 ) {
							command_type = jmp;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 4, "call\0", 4 ) != -1 ) {
							command_type = call;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 3, "ret\0", 3 ) != -1 ) {
							command_type = ret;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 4, "push\0", 4 ) != -1 ) {
							command_type = push;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 3, "pop\0", 3 ) != -1 ) {
							command_type = pop;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "skpeq\0", 5 ) != -1 ) {
							command_type = skpeq;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "skpne\0", 5 ) != -1 ) {
							command_type = skpne;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "skpge\0", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Greater Than or Equal */
							command_type = skpge;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "skple\0", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Less Than or Equal */
							command_type = skple;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "skpgt\0", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Greater Than */
							command_type = skpgt;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "skplt\0", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Less Than */
							command_type = skplt;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "skplt\0", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Less Than */
							command_type = skplt;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( temp_str, 5, "clear\0", 5 ) != -1 ) {
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
							length_temp = print32_charindex( temp_str, 0x20 ); // Ascii Code of Space
							if ( length_temp == -1 ) break;
							temp_str += length_temp;
							temp_str++; // Next of Space
							while ( print32_charsearch( temp_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space
								temp_str++;
							}
							if ( print32_charsearch( temp_str, 1, 0x2E ) != -1 ) { // Ascii Code of Period
								/* Label Argument Indicated by ".<NAME>" */
								temp_str++; // Next of Character
								length_temp = print32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = print32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = 0;
								for ( uint32 j = 0; j < label_list.length; j++ ) {
									if ( print32_strsearch( (String)label_list.name + 8 * j, 8, temp_str, length_temp ) != -1 ) {
										var_temp.u32 = _load_32( label_list.number + 4 * j );
									}
								}
								_store_32( array_argpointer + 4 * i,  var_temp.u32 );
							} else if ( print32_charsearch( temp_str, 1, 0x3A ) != -1 ) { // Ascii Code of Colon
								/* Indiret Label Argument Indicated by ":<NAME>" */
								temp_str++; // Next of Character
								length_temp = print32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = print32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = 0;
								for ( uint32 j = 0; j < label_list.length; j++ ) {
									if ( print32_strsearch( (String)label_list.name + 8 * j, 8, temp_str, length_temp ) != -1 ) {
										var_temp.u32 = _load_32( label_list.number + 4 * j );
									}
								}
								if ( _uartsetheap( var_temp.u32 ) ) _uartsetheap( 0 );
								/*  Pass Spaces and Label*/
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								var_temp2.u32 = deci32_string_to_int32( temp_str2, print32_strlen( temp_str2 ) );
								_store_32( array_argpointer + 4 * i,  var_temp2.u32 );
							} else if ( print32_charsearch( temp_str, 1, 0x25 ) != -1 ) { // Ascii Code of %
								/* Direct Argument Indicated by "%N" */
								temp_str++; // Next of Character
								length_temp = print32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = print32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = deci32_string_to_int32( temp_str, length_temp );
								_store_32( array_argpointer + 4 * i,  var_temp.u32 );
							} else if ( print32_charsearch( temp_str, 1, 0x5B ) != -1 ) { // Ascii Code of [ (Square Bracket Left)
								/* Indirect Argument (Pointer) Indicated by "[N" */
								temp_str++; // Next of Character
								length_temp = print32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = print32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = deci32_string_to_int32( temp_str, length_temp );
								if ( _uartsetheap( var_temp.u32 ) ) _uartsetheap( 0 );
								/*  Pass Spaces and Label*/
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								var_temp2.u32 = deci32_string_to_int32( temp_str2, print32_strlen( temp_str2 ) );
print32_debug( var_temp2.u32, 300, 300  ); 
								_store_32( array_argpointer + 4 * i,  var_temp2.u32 );
							}
						}

						break;

					case enumurate_variables:

						if ( _uartsetheap( _load_32( array_argpointer + 4 * var_index ) ) ) _uartsetheap( 0 );

						/*  Pass Spaces and Label*/
						temp_str = pass_space_label( UART32_UARTINT_HEAP );
						if ( command_type >= fadd ) { // Type of Single Precision Float
							var_temp.f32 = deci32_string_to_float32( temp_str, print32_strlen( temp_str ) );
							if ( var_temp.s32 == -1 ) {
								var_temp.s32 = deci32_string_to_int32( temp_str, print32_strlen( temp_str ) );
								var_temp.f32 = vfp32_s32tof32( var_temp.s32 );
							}
							_store_32( array_source + 4 * var_index, var_temp.s32 );
						} else if ( command_type >= badd ){ // Type of Binary-coded Decimal
							var_temp.u32 = print32_charindex( temp_str, 0x2E ); // Ascii Code of Period
							if ( var_temp.u32 == -1 ) var_temp.u32 = print32_strlen( temp_str );
							_store_32( array_source + 8 * var_index, (obj)temp_str );
							_store_32( array_source + 8 * var_index + 4, var_temp.u32 );
						} else { // Type of 32-bit Signed Integer
							if( print32_charindex( temp_str, 0x2E ) != -1 ) { // Ascii Code of Period
								var_temp.f32 = deci32_string_to_float32( temp_str, print32_strlen( temp_str ) );
								var_temp.s32 = vfp32_f32tos32( var_temp.f32 );
							} else {
								var_temp.s32 = deci32_string_to_int32( temp_str, print32_strlen( temp_str ) );
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
							case add:
								direction.s32 =  _load_32( array_source + 4 ) + _load_32( array_source + 8 );
								str_direction = deci32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case sub:
								direction.s32 =  _load_32( array_source + 4 ) - _load_32( array_source + 8 );
								str_direction = deci32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case mul:
								direction.s32 =  arm32_mul( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = deci32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case div:
								direction.s32 =  arm32_sdiv( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = deci32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case rem:
								direction.s32 =  arm32_srem( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = deci32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case rand:
								direction.s32 =  _random( 255 );
								str_direction = deci32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case cmp:
								status_nzcv = arm32_cmp( _load_32( array_source ), _load_32( array_source + 4 ) );

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
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fsub:
								direction.f32 = vfp32_fsub( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fmul:
								direction.f32 = vfp32_fmul( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fdiv:
								direction.f32 = vfp32_fdiv( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fsqrt:
								direction.f32 = vfp32_fsqrt( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case frad:
								direction.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fsin:
								direction.f32 = math32_sin( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fcos:
								direction.f32 = math32_cos( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case ftan:
								direction.f32 = math32_tan( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fln:
								direction.f32 = math32_ln( ( vfp32_hexatof32( _load_32( array_source + 4 ) ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case flog:
								direction.f32 = math32_log( ( vfp32_hexatof32( _load_32( array_source + 4 ) ) ) );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fabs:
								direction.u32 = _load_32( array_source + 4 ) & ~(0x80000000); // ~ is Not (Inverter), Sign Bit[31] Clear
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fneg:
								direction.u32 = _load_32( array_source + 4 ) | 0x80000000; // Sign Bit[31] Set
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );

								break;
							case fcmp:
								status_nzcv = vfp32_fcmp( vfp32_hexatof32( _load_32( array_source ) ), vfp32_hexatof32( _load_32( array_source + 4 ) ) );

								break;
							case input:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								_uarttx( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
								_store_32( UART32_UARTINT_COUNT_ADDR, print32_strlen( UART32_UARTINT_HEAP ) );
								_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
								while (true) {
									if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) break;
								}

								break;
							case print:
								_uartsetheap( _load_32( array_argpointer ) );
								/*  Pass Spaces and Label*/
								temp_str = pass_space_label( UART32_UARTINT_HEAP );
								uint32 temp_str_index;
								while ( print32_strlen( temp_str ) ) {
									if ( print32_strindex( temp_str, "\\n\0" ) != -1 ) {
										temp_str_index = print32_strindex( temp_str, "\\n\0" );
										_uarttx( temp_str, temp_str_index );
										print32_set_caret( print32_string( temp_str, FB32_X_CARET, FB32_Y_CARET, color, back_color, temp_str_index, 8, 12, FONT_MONO_12PX_ASCII ) );
										_uarttx( "\r\n\0", 2 );
										print32_set_caret( print32_string( "\r\n\0", FB32_X_CARET, FB32_Y_CARET, color, back_color, 2, 8, 12, FONT_MONO_12PX_ASCII ) );
										temp_str += temp_str_index;
										temp_str += 2;
									} else if ( print32_strindex( temp_str, "\\e\0" ) != -1 ) {
										temp_str_index = print32_strindex( temp_str, "\\e\0" );
										_uarttx( temp_str, temp_str_index );
										print32_set_caret( print32_string( temp_str, FB32_X_CARET, FB32_Y_CARET, color, back_color, temp_str_index, 8, 12, FONT_MONO_12PX_ASCII ) );
										_uarttx( "\x1B\0", 1 );
										//print32_set_caret( print32_string( "\x1B\0", FB32_X_CARET, FB32_Y_CARET, color, back_color, 1, 8, 12, FONT_MONO_12PX_ASCII ) );
										temp_str += temp_str_index;
										temp_str += 1;
									} else {
										temp_str_index = print32_strlen( temp_str );
										_uarttx( temp_str, temp_str_index );
										print32_set_caret( print32_string( temp_str, FB32_X_CARET, FB32_Y_CARET, color, back_color, temp_str_index, 8, 12, FONT_MONO_12PX_ASCII ) );
										temp_str += temp_str_index;
									}
								}

								break;
							case mov:
								_uartsetheap( _load_32( array_argpointer ) );
								dst_str = UART32_UARTINT_HEAP;
								_uartsetheap( _load_32( array_argpointer + 4 ) );
								src_str = UART32_UARTINT_HEAP;
								heap32_mcopy( (obj)dst_str, 0, (obj)src_str, 0, print32_strlen( src_str ) + 1 ); // Add Null Character

								break;
							case clr:
								_uartsetheap( _load_32( array_argpointer ) );
								heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );

								break;
							case jmp:
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case call:
								_store_32( array_link + array_link_offset * 4, current_line );
								array_link_offset++;
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case ret:
								if ( array_link_offset <= 0 ) break;
								array_link_offset--;
								current_line = _load_32( array_link + array_link_offset * 4 );

								break;
							case push:
								_uartsetheap(  UART32_UARTMALLOC_LENGTH - stack_offset );
								dst_str = UART32_UARTINT_HEAP;
								//heap32_mfill( (obj)dst_str, 0 );
								_uartsetheap( _load_32( array_argpointer ) );
								src_str = UART32_UARTINT_HEAP;
								heap32_mcopy( (obj)dst_str, 0, (obj)src_str, 0, print32_strlen( src_str ) + 1 ); // Add Null Character
								stack_offset++;

								break;
							case pop:
								if ( stack_offset <= 1 ) break;
								stack_offset--;
								_uartsetheap( _load_32( array_argpointer ) );
								dst_str = UART32_UARTINT_HEAP;
								//heap32_mfill( (obj)dst_str, 0 );
								_uartsetheap( UART32_UARTMALLOC_LENGTH - stack_offset );
								src_str = UART32_UARTINT_HEAP;
								heap32_mcopy( (obj)dst_str, 0, (obj)src_str, 0, print32_strlen( src_str ) + 1 ); // Add Null Character

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
							default:
								break;
						}

						pipe_type = go_nextline;
						if ( str_direction == null ) break;
						_uartsetheap( _load_32( array_argpointer ) );
						/* Pass Spaces and Label */
						temp_str = pass_space_label( UART32_UARTINT_HEAP );
						var_temp.u32 = temp_str - UART32_UARTINT_HEAP;
						var_temp2.u32 = print32_strlen( str_direction );
						if ( var_temp2.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp2.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
						heap32_mcopy( (obj)UART32_UARTINT_HEAP, var_temp.u32, (obj)str_direction, 0, var_temp2.u32 + 1 ); // Add Null Character
						str_direction = (String)heap32_mfree( (obj)str_direction );

						break;

					case go_nextline:
						/* Continue Process */

						if ( _uartsetheap( current_line + 1 ) ) _uartsetheap( 0 ); // #0 is Guaranteed as Null
						pipe_type = search_command;

						break;

					case termination:
						/* End Process */
						_uarttx( "\r\n\0", 2 );

						heap32_mfill( label_list.name, 0 );
						heap32_mfill( label_list.number, 0 );
						label_list.length = 0;

						/* Print Commands Untill Line with Null Character */
						for ( uint32 i = 0; i < UART32_UARTMALLOC_LENGTH; i++ ) {
							_uartsetheap( i );
							str_process_counter = deci32_int32_to_string_hexa( UART32_UARTMALLOC_NUMBER, 2, 0, 0 ); // Min. 2 Digit, Unsigned
							_uarttx( str_process_counter, print32_strlen( str_process_counter ) );
							_uarttx( ": \0", 2 );
							heap32_mfree( (obj)str_process_counter );

							var_temp.u32 = print32_strlen( UART32_UARTINT_HEAP );
							if ( var_temp.u32 == 0 ) break;
							_uarttx( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
							_uarttx( "\r\n\0", 2 );
						}
						_store_32( UART32_UARTINT_COUNT_ADDR, print32_strlen( UART32_UARTINT_HEAP ) );
						_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
						pipe_type = search_command;
						flag_execute = false;

						break;

					default:

						break;
				}
			} else {
				_uarttx( "\r\n\0", 2 ); // Send These Because Teletype Is Only Mirrored Carriage Return from Host
				if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "run\0", 3 ) != -1 ) {
					/* If You Command "run", It Starts Execution */
					heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );

					/* Labels Enumuration */
					for ( uint32 i = 0; i < UART32_UARTMALLOC_LENGTH; i++ ) {
						_uartsetheap( i );
						temp_str = UART32_UARTINT_HEAP;
						/* Pass Spaces */
						while ( print32_charsearch( temp_str, 1, 0x20 ) != -1 ) { // Ascii Code of Spaces
							temp_str++;
						}
						var_temp.u32 = print32_charsearch( temp_str, 1, 0x2E ); // Ascii Code of Period
						if ( var_temp.u32 != -1 ) {
							var_temp.u32 = print32_charsearch( temp_str, 1, 0x20 ); // Ascii Code of Space
							if ( var_temp.u32 == -1 ) var_temp.u32 = print32_strlen( temp_str );
							var_temp.u32 = var_temp.u32 - 1;
							/* Maximum Length of Name is 8 */
							if ( var_temp.u32 > 8 ) var_temp.u32 = 8;
							/* Store Name of Label */
							heap32_mcopy( label_list.name + 8 * label_list.length, 0, (obj)temp_str, 1, var_temp.u32 ); // Add Null Character
							/* Store Line Number of Label */
							_store_32( label_list.number + 4 * label_list.length, i );
							label_list.length++;
							/* Maximum Length of Label List is 16 */
							if ( label_list.length > 16 ) label_list.length = 16;
						}
					}

					_uarttx( "\x1B[2J\x1B[H\0", 8 ); // Clear All Screen and Move Cursor to Upper Left
					flag_execute = true;
					pipe_type = search_command;
					_uartsetheap( 0 );
				} else {
					if ( _uartsetheap( UART32_UARTMALLOC_NUMBER + 1 ) ) _uartsetheap( 0 );
					str_process_counter = deci32_int32_to_string_hexa( UART32_UARTMALLOC_NUMBER, 2, 0, 0 ); // Min. 2 Digit, Unsigned
					_uarttx( str_process_counter, print32_strlen( str_process_counter ) );
					_uarttx( ": \0", 2 );
					heap32_mfree( (obj)str_process_counter );
					_uarttx( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
					_store_32( UART32_UARTINT_COUNT_ADDR, print32_strlen( UART32_UARTINT_HEAP ) );
					_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
				}
			}
		}
	}
}


String pass_space_label( String target_str ) {

	/* Pass Spaces  */
	while ( print32_charsearch( target_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space 
		target_str++;
	}
	/* Pass Label Itself */
	if ( print32_charsearch( target_str, 1, 0x2E ) != -1 ) { // Period
		uint32 length_temp = print32_charindex( target_str, 0x20 ); // Ascii Code of Space
		if ( length_temp == -1 ) length_temp = print32_strlen( target_str );
		if ( length_temp != -1 ) {
			target_str += length_temp;
			target_str++; // Next of Space
		}
	}
	return target_str;
}

