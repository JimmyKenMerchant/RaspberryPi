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

extern String UART32_UARTINT_HEAP;
extern uint32 UART32_UARTINT_BUSY_ADDR;
extern uint32 UART32_UARTINT_COUNT_ADDR;
extern uint32 UART32_UARTMALLOC_NUMBER;
extern uint32 UART32_UARTMALLOC_LENGTH;

/* D: Line Number for Direction, S1: Line Number Stored First Source, S2: Line Number Stored Second Source */
typedef enum _command_list {
	null,
	sleep, // Sleep Microseconds by Integer "Sleep %S1"
	add, // Integer Addition, "add %D %S1 %S2": D = S1 + S2.
	sub,
	mul,
	div,
	rem,
	cmp, // Compare Two Values of Integer, "cmp %S1 %S2": Reflects NZCV Flags.
	fadd, // Floating Point Addition, "fadd %D %S1 %S2": D = S1 + S2.
	fsub, // Float Point Subtruction, "fsub %D %S1 %S2": D = S1 - S2.
	fmul,
	fdiv,
	fsin, // Sine by Degrees on Float, "sin %D %S1": D = sin(S1).
	fcos,
	ftan,
	fln,
	flog,
	fcmp, // Compare Two Values of Floating Point, "fcmp %S1 %S2": Reflects NZCV Flags.
	input, // Input to the Line, "input %D"
	print,
	mov, // Copy, "mov %D %S1"
	clr, // Clear Line, "clr %D"
	jmp, // Jump to the Line, "jmp %S1": Next line will be the number in S1.
	call, // Jump to the Line and Store Current Line to Stack (Last In First Out) for Link
	ret, // Return to Previous Line Stored in Stack
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
	terminate_pipe
} pipe_list;


typedef union _flex32 {
	float32 f32;
	int32 i32;
	uint32 u32;
	obj oj;
} flex32;

bool flag_execute;

void _user_start()
{

	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	String str_aloha = "Aloha Calc Version 0.8 Alpha: Copyright (C) 2018 Kenta Ishii\r\n\0";
	String str_process_counter = null;
	String str_direction = null;
	obj array_source = heap32_malloc( 8 );
	obj array_argpointer = heap32_malloc( 8 );
	uint32 length_arg;
	uint32 var_index;
	uint32 current_line;
	uint32 status_nzcv;
	pipe_list pipe_type = search_command;
	command_list command_type = null;
	flex32 direction;
	direction.i32 = 0;
	uint32 stack_offset = 1; // Stack offset for "Call" and "Ret", 1 is minimam, from the last line decremental order.

	if ( print32_set_caret( print32_string( str_aloha, FB32_X_CARET, FB32_Y_CARET, COLOR32_YELLOW, back_color, print32_strlen( str_aloha ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_aloha, print32_strlen( str_aloha ) + 1 );
	_uarttx( "00: \0", 5 );

	flag_execute = false;
	
	while ( true ) {
		if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) {
			if ( flag_execute ) {
				switch ( pipe_type ) {
					case search_command:

						/* Numeration Process */

						/* Select Command Type */
						if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "sleep", 5 ) != -1 ) {
							command_type = sleep;
							length_arg = 1;
							pipe_type = enumurate_variables;
							var_index = 0;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "add", 3 ) != -1 ) {
							command_type = add;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "sub", 3 ) != -1 ) {
							command_type = sub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "mul", 3 ) != -1 ) {
							command_type = mul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "div", 3 ) != -1 ) {
							command_type = div;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "rem", 3 ) != -1 ) {
							command_type = rem;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "cmp", 3 ) != -1 ) {
							command_type = cmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "fadd", 4 ) != -1 ) {
							command_type = fadd;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "fsub", 4 ) != -1 ) {
							command_type = fsub;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "fmul", 4 ) != -1 ) {
							command_type = fmul;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "fdiv", 4 ) != -1 ) {
							command_type = fdiv;
							length_arg = 3;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "fsin", 4 ) != -1 ) {
							command_type = fsin;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "fcos", 4 ) != -1 ) {
							command_type = fcos;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "ftan", 4 ) != -1 ) {
							command_type = ftan;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "fln", 3 ) != -1 ) {
							command_type = fln;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "flog", 4 ) != -1 ) {
							command_type = flog;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "fcmp", 4 ) != -1 ) {
							command_type = fcmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "input", 5 ) != -1 ) {
							command_type = input;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "print", 5 ) != -1 ) {
							command_type = print;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "mov", 3 ) != -1 ) {
							command_type = mov;
							length_arg = 2;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "clr", 3 ) != -1 ) {
							command_type = clr;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "jmp", 3 ) != -1 ) {
							command_type = jmp;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "call", 4 ) != -1 ) {
							command_type = call;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "ret", 3 ) != -1 ) {
							command_type = ret;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "skpeq", 5 ) != -1 ) {
							command_type = skpeq;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "skpne", 5 ) != -1 ) {
							command_type = skpne;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "skpge", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Greater Than or Equal */
							command_type = skpge;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "skple", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Less Than or Equal */
							command_type = skple;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "skpgt", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Greater Than */
							command_type = skpgt;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "skplt", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Less Than */
							command_type = skplt;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "skplt", 5 ) != -1 ) {
							/* Jump Over One Line If Signed Less Than */
							command_type = skplt;
							length_arg = 0;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "run", 3 ) != -1 ) {
							/* Stop Execution If Reaching "run" */
							command_type = null;
							length_arg = 0;
							pipe_type = terminate_pipe;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "clear", 5 ) != -1 ) {
							/* Clear All Lines */
							for (uint32 i = 0; i < UART32_UARTMALLOC_LENGTH; i++ ) {
								_uartsetheap( i );
								heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );
							}
							command_type = null;
							length_arg = 0;
							pipe_type = terminate_pipe;
						} else if ( print32_strlen( UART32_UARTINT_HEAP ) == 0 ) {
							/* Stop Execution If No Content in Line */
							command_type = null;
							length_arg = 0;
							pipe_type = terminate_pipe;
						} else {
							command_type = null;
							length_arg = 0;
							pipe_type = go_nextline;
						}

						uint32 offset = 0;
						uint32 var_temp;
						uint32 length_temp;

						for ( uint32 i = 0; i < length_arg; i++ ) {
							var_temp = print32_charindex( UART32_UARTINT_HEAP + offset, 0x25 ); // Ascii Code of %
							if ( var_temp == -1 ) break;
							offset += var_temp;
							offset++;
							length_temp = print32_charindex( UART32_UARTINT_HEAP + offset, 0x20 ); // Ascii Code of Space
							if ( length_temp == -1 ) length_temp = print32_strlen( UART32_UARTINT_HEAP + offset ); // Ascii Code of CR, for Last Variable
							var_temp = deci32_string_to_int32( UART32_UARTINT_HEAP + offset, length_temp );
							_store_32( array_argpointer + 4 * i,  var_temp );
						}

						current_line = UART32_UARTMALLOC_NUMBER;

						break;

					case enumurate_variables:
						
						if ( _uartsetheap( _load_32( array_argpointer + 4 * var_index ) ) ) _uartsetheap( 0 );

						flex32 var_temp2;

						if ( command_type >= fadd ) { // Type of Single Precision Float
							var_temp2.f32 = deci32_string_to_float32( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
							if ( var_temp2.i32 == -1 ) {
								var_temp2.i32 = deci32_string_to_int32( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
								var_temp2.f32 = vfp32_s32tof32( var_temp2.i32 );
							}
						} else { // Type of 32-bit Signed Integer
							if( print32_charindex( UART32_UARTINT_HEAP, 0x2E ) != -1 ) { // Ascii Code of Period
								var_temp2.f32 = deci32_string_to_float32( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
								var_temp2.i32 = vfp32_f32tos32( var_temp2.f32 );
							} else {
								var_temp2.i32 = deci32_string_to_int32( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
							}
						}

						_store_32( array_source + 4 * var_index, var_temp2.i32 );

						var_index++;
						if ( var_index >= length_arg ) pipe_type = execute_command;

						break;

					case execute_command:

						switch ( command_type ) {
							case sleep:
								_sleep( _load_32( array_source ) );
								break;
							case add:
								direction.i32 =  _load_32( array_source + 4 ) + _load_32( array_source + 8 );
								str_direction = deci32_int32_to_string_deci( direction.i32, 1, 1 );
								break;
							case sub:
								direction.i32 =  _load_32( array_source + 4 ) - _load_32( array_source + 8 );
								str_direction = deci32_int32_to_string_deci( direction.i32, 1, 1 );
								break;
							case mul:
								direction.i32 =  arm32_mul( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = deci32_int32_to_string_deci( direction.i32, 1, 1 );
								break;
							case div:
								direction.i32 =  arm32_div( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = deci32_int32_to_string_deci( direction.i32, 1, 1 );
								break;
							case rem:
								direction.i32 =  arm32_rem( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );
								str_direction = deci32_int32_to_string_deci( direction.i32, 1, 1 );
								break;
							case cmp:
								status_nzcv = arm32_cmp( _load_32( array_source ), _load_32( array_source + 4 ) );

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
							case fsin:
								direction.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								direction.f32 = math32_sin( direction.f32 );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case fcos:
								direction.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								direction.f32 = math32_cos( direction.f32 );
								str_direction = deci32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case ftan:
								direction.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								direction.f32 = math32_tan( direction.f32 );
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
							case fcmp:
								status_nzcv = vfp32_fcmp( vfp32_hexatof32( _load_32( array_source ) ), vfp32_hexatof32( _load_32( array_source + 4 ) ) );

								break;
							case input:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								_uarttx( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) + 1 );
								_store_32( UART32_UARTINT_COUNT_ADDR, print32_strlen( UART32_UARTINT_HEAP ) );
								_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
								while (true) {
									if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) break;
								}

								break;
							case print:
								_uartsetheap( _load_32( array_argpointer ) );
								String temp_str = UART32_UARTINT_HEAP;
								uint32 temp_str_index;
								while ( print32_strlen( temp_str ) ) {
									temp_str_index = print32_strindex( temp_str, "\\n" ); // Escaped
									if ( temp_str_index == -1 ) {
										temp_str_index = print32_strlen( temp_str );
										_uarttx( temp_str, temp_str_index );
										print32_set_caret( print32_string( temp_str, FB32_X_CARET, FB32_Y_CARET, color, back_color, temp_str_index, 8, 12, FONT_MONO_12PX_ASCII ) );
										temp_str += temp_str_index;
									} else {
										_uarttx( temp_str, temp_str_index );
										print32_set_caret( print32_string( temp_str, FB32_X_CARET, FB32_Y_CARET, color, back_color, temp_str_index, 8, 12, FONT_MONO_12PX_ASCII ) );
										_uarttx( "\r\n", 2 );
										print32_set_caret( print32_string( "\r\n", FB32_X_CARET, FB32_Y_CARET, color, back_color, 2, 8, 12, FONT_MONO_12PX_ASCII ) );
										temp_str += temp_str_index;
										temp_str += 2;
									}
								}

								break;
							case mov:
								_uartsetheap( _load_32( array_argpointer ) );
								String mov_str_dst = UART32_UARTINT_HEAP;
								_uartsetheap( _load_32( array_argpointer + 4 ) );
								String mov_str_src = UART32_UARTINT_HEAP;
								heap32_mcopy( (obj)mov_str_dst, (obj)mov_str_src, 0, print32_strlen( mov_str_src ) );

								break;
							case clr:
								_uartsetheap( _load_32( array_argpointer ) );
								heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );

								break;
							case jmp:
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case call:
								_uartsetheap(  UART32_UARTMALLOC_LENGTH - stack_offset );
								_store_32( (obj)UART32_UARTINT_HEAP, current_line );
								stack_offset++;
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case ret:
								if ( stack_offset <= 1 ) break;
								stack_offset--;
								_uartsetheap( UART32_UARTMALLOC_LENGTH - stack_offset );
								current_line = _load_32( (obj)UART32_UARTINT_HEAP );

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
						heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );
						heap32_mcopy( (obj)UART32_UARTINT_HEAP, (obj)str_direction, 0, print32_strlen( str_direction ) );
						str_direction = (String)heap32_mfree( (obj)str_direction );

						break;

					case go_nextline:

						/* Continue Process */

						if ( _uartsetheap( current_line + 1 ) ) _uartsetheap( 0 );
						pipe_type = search_command;
						heap32_mfill( array_source, 0 );
						heap32_mfill( array_argpointer, 0 );

						break;

					case terminate_pipe:

						/* End Process */
						_uartsetheap( 0 );
						str_process_counter = deci32_int32_to_string_hexa( UART32_UARTMALLOC_NUMBER, 2, 0, 0 ); // Min. 2 Digit, Unsigned
						_uarttx( str_process_counter, print32_strlen( str_process_counter ) );
						_uarttx( ": \0", 3 );
						heap32_mfree( (obj)str_process_counter );
						_uarttx( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) + 1 );
						_store_32( UART32_UARTINT_COUNT_ADDR, print32_strlen( UART32_UARTINT_HEAP ) );
						//_store_32( UART32_UARTINT_COUNT_ADDR, 0 );
						_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
						pipe_type = search_command;
						flag_execute = false;

						break;

					default:

						break;
				}
			} else {
				_uarttx( "\r\n", 2 ); // Send These Because Teletype Is Only Mirrored Carriage Return from Host
				if ( print32_strindex( UART32_UARTINT_HEAP, "run" ) != -1 ) {
					/* If You Command "run", It Starts Execution */
					flag_execute = true;
					pipe_type = search_command;
					_uartsetheap( 0 );
				} else {
					str_process_counter = deci32_int32_to_string_hexa( UART32_UARTMALLOC_NUMBER + 1, 2, 0, 0 ); // Min. 2 Digit, Unsigned
					_uarttx( str_process_counter, print32_strlen( str_process_counter ) );
					_uarttx( ": \0", 3 );
					heap32_mfree( (obj)str_process_counter );
					if ( _uartsetheap( UART32_UARTMALLOC_NUMBER + 1 ) ) _uartsetheap( 0 );
					//heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );
					//_store_32( UART32_UARTINT_COUNT_ADDR, 0 );
					_uarttx( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) + 1 );
					_store_32( UART32_UARTINT_COUNT_ADDR, print32_strlen( UART32_UARTINT_HEAP ) );
					_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
				}
			}
		}
	}
}
