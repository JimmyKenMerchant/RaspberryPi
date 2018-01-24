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

/* D: Line Number for Direction, A1: Line Number Stored First Argument, A2: Line Number Stored Second Argument */
typedef enum _command_list {
	null,
	fadd, // Float Addition, "fadd %D %A1 %A2": D = A1 + A2.
	fsub, // Float Subtruction, "fsub %D %A1 %A2": D = A1 - A2.
	fmul,
	fdiv,
	sin, // Sine by Degrees on Float, "sin %D %A1": D = sin(A1).
	cos,
	tan,
	ln,
	log,
	input, // Input to the Line, "input %D1"
	print,
	jmp, // Jump to the Line, "jmp %A1": Next line will be the number in A1.
	cmp, // Compare Two Values, "cmp %A1 %A2": Reflects NZCV Flags.
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


void _user_start()
{
	bool flag_execute = false;
	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	String str_aloha = "Aloha Calc Version 0.8 Alpha: Copyright (C) 2018 Kenta Ishii\r\n\0";
	String str_process_counter = null;
	String str_response = null;
	obj array_var = heap32_malloc( 8 );
	obj array_argpointer = heap32_malloc( 8 );
	uint32 length_arg;
	uint32 var_index;
	uint32 current_line;
	uint32 status_nzcv;
	pipe_list pipe_type = 0;
	command_list command_type = null;
	flex32 response;
	response.i32 = 0;

	if ( print32_set_caret( print32_string( str_aloha, FB32_X_CARET, FB32_Y_CARET, COLOR32_YELLOW, back_color, print32_strlen( str_aloha ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_aloha, print32_strlen( str_aloha ) + 1 );

	_uarttx( "00: \0", 5 );

	while ( true ) {
		if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) {
			if ( flag_execute ) {
				switch ( pipe_type ) {
					case search_command:

						/* Numeration Process */

						/* Select Command Type */
						if ( print32_strsearch( UART32_UARTINT_HEAP, 4, "fadd", 4 ) != -1 ) {
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
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "sin", 3 ) != -1 ) {
							command_type = sin;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "cos", 3 ) != -1 ) {
							command_type = cos;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "tan", 3 ) != -1 ) {
							command_type = tan;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 2, "ln", 2 ) != -1 ) {
							command_type = ln;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "log", 3 ) != -1 ) {
							command_type = log;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 1; // 0 is Direction
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "input", 5 ) != -1 ) {
							command_type = input;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 5, "print", 5 ) != -1 ) {
							command_type = print;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "jmp", 3 ) != -1 ) {
							command_type = jmp;
							length_arg = 1;
							pipe_type = execute_command;
						} else if ( print32_strsearch( UART32_UARTINT_HEAP, 3, "cmp", 3 ) != -1 ) {
							command_type = cmp;
							length_arg = 2;
							pipe_type = enumurate_variables;
							var_index = 0; // No Direction
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
						var_temp2.f32 = deci32_string_to_float32( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
						if ( var_temp2.i32 == -1 ) {
							var_temp2.f32 = 0.0;
						}
						_store_32( array_var + 4 * var_index, var_temp2.i32 );

						var_index++;
						if ( var_index >= length_arg ) pipe_type = execute_command;

						break;

					case execute_command:

						switch ( command_type ) {
							case fadd:
								response.f32 = vfp32_fadd( vfp32_hexatof32( _load_32( array_var + 4 ) ), vfp32_hexatof32( _load_32( array_var + 8 ) ) );
								break;
							case fsub:
								response.f32 = vfp32_fsub( vfp32_hexatof32( _load_32( array_var + 4 ) ), vfp32_hexatof32( _load_32( array_var + 8 ) ) );
								break;
							case fmul:
								response.f32 = vfp32_fmul( vfp32_hexatof32( _load_32( array_var + 4 ) ), vfp32_hexatof32( _load_32( array_var + 8 ) ) );
								break;
							case fdiv:
								response.f32 = vfp32_fdiv( vfp32_hexatof32( _load_32( array_var + 4 ) ), vfp32_hexatof32( _load_32( array_var + 8 ) ) );
								break;
							case sin:
								response.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_var + 4 ) ) );
								response.f32 = math32_sin( response.f32 );
								break;
							case cos:
								response.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_var + 4 ) ) );
								response.f32 = math32_cos( response.f32 );
								break;
							case tan:
								response.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_var + 4 ) ) );
								response.f32 = math32_tan( response.f32 );
								break;
							case ln:
								response.f32 = math32_ln( ( vfp32_hexatof32( _load_32( array_var + 4 ) ) ) );
								break;
							case log:
								response.f32 = math32_log( ( vfp32_hexatof32( _load_32( array_var + 4 ) ) ) );

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
							case jmp:
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case cmp:
								status_nzcv = vfp32_fcmp( vfp32_hexatof32( _load_32( array_var ) ), vfp32_hexatof32( _load_32( array_var + 4 ) ) );

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
						if ( command_type >= input ) break; // Type of No Direction or Special
						if ( command_type >= fadd) { // Type of Float
							str_response = deci32_float32_to_string( response.f32, 1, 7, 0 );
						}
						_uartsetheap( _load_32( array_argpointer ) );
						heap32_mcopy( (obj)UART32_UARTINT_HEAP, (obj)str_response, 0, print32_strlen( str_response ) );
						heap32_mfree( (obj)str_response );

						break;

					case go_nextline:

						/* Continue Process */

						if ( _uartsetheap( current_line + 1 ) ) _uartsetheap( 0 );
						pipe_type = search_command;
						heap32_mfill( array_var, 0 );
						heap32_mfill( array_argpointer, 0 );

						break;

					case terminate_pipe:

						/* End Process */
						_uarttx( "\0\r\n", 3 );

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
				_uarttx( "\n\0", 2 ); // Send Line Feed Because Teletype Is Only Mirrored Carriage Return
				if ( print32_strindex( UART32_UARTINT_HEAP, "run" ) != -1 ) {
					/* If You Command "run", It Starts Execution */
					flag_execute = true;
					pipe_type = 0;
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
