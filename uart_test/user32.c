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

void _user_start()
{
	bool flag_execute = false;
	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	String str_aloha = "Aloha Calc Version 0.8 Alpha: Copyright (C) 2018 Kenta Ishii\r\n\0";
	String str_prompt = "\r\nfadd/fsub/fmul/fdiv/sin/cos/tan/ln/log/print? Type Then Press Enter\r\n\0";
	String str_process_counter;
	obj array_var = heap32_malloc( 8 );
	obj array_argpointer = heap32_malloc( 8 );
	uint32 pipenumber;
	uint32 commandtype;
	uint32 length_arg;
	uint32 var_index;
	uint32 current_number;
	float32 response;

	if ( print32_set_caret( print32_string( str_aloha, FB32_X_CARET, FB32_Y_CARET, COLOR32_YELLOW, back_color, print32_strlen( str_aloha ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_aloha, print32_strlen( str_aloha ) + 1 );

	if ( print32_set_caret( print32_string( str_prompt, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( str_prompt ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_prompt, print32_strlen( str_prompt ) + 1 );

	str_process_counter = deci32_int32_to_string_hexa( 0, 2, 0, 0 ); // Min. 2 Digit, Unsigned
	_uarttx( str_process_counter, print32_strlen( str_process_counter ) );
	_uarttx( ": \0", 3 );
	heap32_mfree( (obj)str_process_counter );

	while ( true ) {
		if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) {
			if ( flag_execute ) {
				switch ( pipenumber ) {
					case 0:

						/* Numeration Process */

						/* Select Command Type */
						if ( print32_strindex( UART32_UARTINT_HEAP, "fadd" ) != -1 ) {
							commandtype = 0;
							length_arg = 3;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "fsub" ) != -1 ) {
							commandtype = 1;
							length_arg = 3;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "fmul" ) != -1 ) {
							commandtype = 2;
							length_arg = 3;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "fdiv" ) != -1 ) {
							commandtype = 3;
							length_arg = 3;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "sin" ) != -1 ) {
							commandtype = 4;
							length_arg = 2;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "cos" ) != -1 ) {
							commandtype = 5;
							length_arg = 2;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "tan" ) != -1 ) {
							commandtype = 6;
							length_arg = 2;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "ln" ) != -1 ) {
							commandtype = 7;
							length_arg = 2;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "log" ) != -1 ) {
							commandtype = 8;
							length_arg = 2;
							pipenumber = 1;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "print" ) != -1 ) {
							commandtype = 9;
							length_arg = 1;
							pipenumber = 2;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "run" ) != -1 ) {
							/* Stop Execution If Reaching "run" */
							commandtype = 0;
							length_arg = 0;
							pipenumber = 4;
						} else if ( print32_strindex( UART32_UARTINT_HEAP, "clear" ) != -1 ) {
							/* Clear All Lines */
							for (uint32 i = 0; i < UART32_UARTMALLOC_LENGTH; i++ ) {
								_uartsetheap( i );
								heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );
							}
							commandtype = 0;
							length_arg = 0;
							pipenumber = 4;
						} else if ( print32_strlen( UART32_UARTINT_HEAP ) == 0 ) {
							/* Stop Execution If No Content in Line */
							commandtype = 0;
							length_arg = 0;
							pipenumber = 4;
						} else {
							commandtype = 0;
							length_arg = 0;
							pipenumber = 3;
						}

						uint32 offset = 0;
						uint32 var_temp;
						uint32 length_temp;

						for( uint32 i = 0; i < length_arg; i++ ) {
							var_temp = print32_charindex( UART32_UARTINT_HEAP + offset, 0x25 ); // Ascii Code of %
							if ( var_temp == -1 ) break;
							offset += var_temp;
							offset++;
							length_temp = print32_charindex( UART32_UARTINT_HEAP + offset, 0x20 ); // Ascii Code of Space
							if ( length_temp == -1 ) length_temp = print32_strlen( UART32_UARTINT_HEAP + offset ); // Ascii Code of CR, for Last Variable
							var_temp = deci32_string_to_int32( UART32_UARTINT_HEAP + offset, length_temp );
							_store_32( array_argpointer + 4 * i,  var_temp );
						}

						current_number = UART32_UARTMALLOC_NUMBER;
						var_index = 1; // 0 is Direction

						break;

					case 1:
						
						if ( _uartsetheap( _load_32( array_argpointer + 4 * var_index ) ) ) _uartsetheap( 0 );

						float32 var_temp2 = deci32_string_to_float32( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
						if ( vfp32_f32tohexa( var_temp2 ) == -1 ) {
							var_temp2 = 0.0;
						}
						_store_32( array_var + 4 * var_index,  vfp32_f32tohexa( var_temp2 ) );

						var_index++;
						if ( var_index >= length_arg ) {
						   	pipenumber = 2;
						} else {
							pipenumber = 1;
						}

						break;

					case 2:

						switch ( commandtype ) {
							case 0:
								response = vfp32_fadd( vfp32_hexatof32( _load_32( array_var + 4 ) ), vfp32_hexatof32( _load_32( array_var + 8 ) ) );
								break;
							case 1:
								response = vfp32_fsub( vfp32_hexatof32( _load_32( array_var + 4 ) ), vfp32_hexatof32( _load_32( array_var + 8 ) ) );
								break;
							case 2:
								response = vfp32_fmul( vfp32_hexatof32( _load_32( array_var + 4 ) ), vfp32_hexatof32( _load_32( array_var + 8 ) ) );
								break;
							case 3:
								response = vfp32_fdiv( vfp32_hexatof32( _load_32( array_var + 4 ) ), vfp32_hexatof32( _load_32( array_var + 8 ) ) );
								break;
							case 4:
								response = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_var + 4 ) ) );
								response = math32_sin( response );
								break;
							case 5:
								response = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_var + 4 ) ) );
								response = math32_cos( response );
								break;
							case 6:
								response = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_var + 4 ) ) );
								response = math32_tan( response );
								break;
							case 7:
								response = math32_ln( ( vfp32_hexatof32( _load_32( array_var + 4 ) ) ) );
								break;
							case 8:
								response = math32_log( ( vfp32_hexatof32( _load_32( array_var + 4 ) ) ) );

								break;
							case 9:
								_uartsetheap( _load_32( array_argpointer ) );
								_uarttx( UART32_UARTINT_HEAP, print32_strlen( UART32_UARTINT_HEAP ) );
								_uarttx( "\r\n\0", 3 );
								print32_set_caret( print32_string( UART32_UARTINT_HEAP, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( UART32_UARTINT_HEAP ), 8, 12, FONT_MONO_12PX_ASCII ) );
								print32_set_caret( print32_string( "\r\n\0", FB32_X_CARET, FB32_Y_CARET, color, back_color, 3, 8, 12, FONT_MONO_12PX_ASCII ) );

								break;
							default:
								break;
						}

						pipenumber = 3;
						if ( commandtype == 9 ) break; // print
						String str_response = deci32_float32_to_string( response, 1, 7, 0 );
						//print32_set_caret( print32_string( str_response, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( str_response ), 8, 12, FONT_MONO_12PX_ASCII ) );
						//print32_set_caret( print32_string( "\r\n\0", FB32_X_CARET, FB32_Y_CARET, color, back_color, 3, 8, 12, FONT_MONO_12PX_ASCII ) );
						//_uarttx( str_response, print32_strlen( str_response ) + 1 );
						//_uarttx( "\r\n\0", 3 );
						_uartsetheap( _load_32( array_argpointer ) );
						heap32_mcopy( (obj)UART32_UARTINT_HEAP, (obj)str_response, 0, print32_strlen( str_response ) );
						heap32_mfree( (obj)str_response );

						break;

					case 3:

						/* Continue Process */

						if ( _uartsetheap( current_number + 1 ) ) _uartsetheap( 0 );
						pipenumber = 0;
						heap32_mfill( array_var, 0 );
						heap32_mfill( array_argpointer, 0 );

						break;

					case 4:

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
						pipenumber = 0;
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
					pipenumber = 0;
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
