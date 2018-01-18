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

void _user_start()
{
	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	uint32 pipenumber = 0;
	uint32 caltype = 0;
	uint32 process_counter = 0;
	float32 var_a = 0.0;
	float32 var_b = 0.0;
	float32 response = 0.0;
	String str_aloha = "Aloha Calc Version 0.8 Alpha: Copyright (C) 2018 Kenta Ishii\r\n\0";
	String str_prompt = "\r\nfadd/fsub/fmul/fdiv/sin/cos/tan/ln/log? Type Then Press Enter\r\n\0";
	String str_process_counter;

	if ( print32_set_caret( print32_string( str_aloha, FB32_X_CARET, FB32_Y_CARET, COLOR32_YELLOW, back_color, print32_strlen( str_aloha ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_aloha, print32_strlen( str_aloha ) + 1 );

	if ( print32_set_caret( print32_string( str_prompt, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( str_prompt ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_prompt, print32_strlen( str_prompt ) + 1 );

	str_process_counter = deci32_int32_to_string_deci( process_counter, 1, 0 ); // Min. 1 Digit, Unsigned

	while (true) {
		if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) {
				_uarttx( "\n\0", 2 ); // Send Line Feed Because Teletype Is Only Mirrored Carriage Return

			switch ( pipenumber ) {
				case 0:
					_uarttx( str_process_counter, print32_strlen( str_process_counter ) );

					if ( print32_strindex( UART32_UARTINT_HEAP, "fadd" ) != -1 ) {
						_uarttx( ": FLOAT ADD: ARG_FIRST?\r\n\0", 26 );
						caltype = 0;
						pipenumber = 1;
					} else if ( print32_strindex( UART32_UARTINT_HEAP, "fsub" ) != -1 ) {
						_uarttx( ": FLOAT SUB: ARG_FIRST?\r\n\0", 26 );
						caltype = 1;
						pipenumber = 1;
					} else if ( print32_strindex( UART32_UARTINT_HEAP, "fmul" ) != -1 ) {
						_uarttx( ": FLOAT MUL: ARG_FIRST?\r\n\0", 26 );
						caltype = 2;
						pipenumber = 1;
					} else if ( print32_strindex( UART32_UARTINT_HEAP, "fdiv" ) != -1 ) {
						_uarttx( ": FLOAT DIV: ARG_FIRST?\r\n\0", 26 );
						caltype = 3;
						pipenumber = 1;
					} else if ( print32_strindex( UART32_UARTINT_HEAP, "sin" ) != -1 ) {
						_uarttx( ": SINE: ARGUMENT?\r\n\0", 20 );
						caltype = 4;
						pipenumber = 2;
					} else if ( print32_strindex( UART32_UARTINT_HEAP, "cos" ) != -1 ) {
						_uarttx( ": COSINE: ARGUMENT?\r\n\0", 22 );
						caltype = 5;
						pipenumber = 2;
					} else if ( print32_strindex( UART32_UARTINT_HEAP, "tan" ) != -1 ) {
						_uarttx( ": TANGENT: ARGUMENT?\r\n\0", 23 );
						caltype = 6;
						pipenumber = 2;
					} else if ( print32_strindex( UART32_UARTINT_HEAP, "ln" ) != -1 ) {
						_uarttx( ": NATURAL LOG: ARGUMENT?\r\n\0", 27 );
						caltype = 7;
						pipenumber = 2;
					} else if ( print32_strindex( UART32_UARTINT_HEAP, "log" ) != -1 ) {
						_uarttx( ": COMMON LOG: ARGUMENT?\r\n\0", 26 );
						caltype = 8;
						pipenumber = 2;
					} else {
						_uarttx( ": Type Correctly\r\n\0", 19 );
					}

					break;

				case 1:
					_uarttx( str_process_counter, print32_strlen( str_process_counter ) );
					
					var_a = deci32_string_to_float32( UART32_UARTINT_HEAP, print32_charindex( UART32_UARTINT_HEAP, 0x0D ) );
					if ( vfp32_f32tohexa( var_a ) == -1 ) {
						_uarttx( ": No Float: ARGUMENT?\r\n\0", 24 );
						break;
					}

					String str_var_a = deci32_float32_to_string( var_a, 0, 20, 0 );
					print32_set_caret( print32_string( str_var_a, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( str_var_a ), 8, 12, FONT_MONO_12PX_ASCII ) );
					print32_set_caret( print32_string( "\r\n\0", FB32_X_CARET, FB32_Y_CARET, color, back_color, 3, 8, 12, FONT_MONO_12PX_ASCII ) );
					heap32_mfree( (obj)str_var_a );

					_uarttx( ": ARG_SECOND?\r\n\0", 17 );
					pipenumber = 2;

					break;

				case 2:
					_uarttx( str_process_counter, print32_strlen( str_process_counter ) );

					var_b = deci32_string_to_float32( UART32_UARTINT_HEAP, print32_charindex( UART32_UARTINT_HEAP, 0x0D ) );
					if ( vfp32_f32tohexa( var_b ) == -1 ) {
						_uarttx( ": No Float: ARGUMENT?\r\n\0", 24 );
						break;
					}

					String str_var_b = deci32_float32_to_string( var_b, 0, 20, 0 );
					print32_set_caret( print32_string( str_var_b, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( str_var_b ), 8, 12, FONT_MONO_12PX_ASCII ) );
					print32_set_caret( print32_string( "\r\n\0", FB32_X_CARET, FB32_Y_CARET, color, back_color, 3, 8, 12, FONT_MONO_12PX_ASCII ) );
					heap32_mfree( (obj)str_var_b );

					switch ( caltype ) {
						case 0:
							response = vfp32_fadd( var_a, var_b );
							break;
						case 1:
							response = vfp32_fsub( var_a, var_b );
							break;
						case 2:
							response = vfp32_fmul( var_a, var_b );
							break;
						case 3:
							response = vfp32_fdiv( var_a, var_b );
							break;
						case 4:
							response = math32_degree_to_radian( var_b );
							response = math32_sin( response );
							break;
						case 5:
							response = math32_degree_to_radian( var_b );
							response = math32_cos( response );
							break;
						case 6:
							response = math32_degree_to_radian( var_b );
							response = math32_tan( response );
							break;
						case 7:
							response = math32_ln( var_b );
							break;
						case 8:
							response = math32_log( var_b );
							break;
						default:
							break;
					}

					/* Round Off to 6th Decimal Place */
					/* This Makes Lack of Information (Saturated Integer)
					response = vfp32_fmul( response, 1000000 );
					response = vfp32_f32tos32( response );
					response = vfp32_s32tof32( response );
					response = vfp32_fdiv( response, 1000000 );
					*/

					String str_response = deci32_float32_to_string( response, 1, 7, 0 );
					print32_set_caret( print32_string( str_response, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( str_response ), 8, 12, FONT_MONO_12PX_ASCII ) );
					print32_set_caret( print32_string( "\r\n\0", FB32_X_CARET, FB32_Y_CARET, color, back_color, 3, 8, 12, FONT_MONO_12PX_ASCII ) );
					_uarttx( ": ", 2 );
					_uarttx( str_response, print32_strlen( str_response ) + 1 );
					heap32_mfree( (obj)str_response );

					_uarttx( "\r\n\0", 3 );
					_uarttx( str_prompt, print32_strlen( str_prompt ) + 1 );

					pipenumber = 0;

					heap32_mfree( (obj)str_process_counter );
					process_counter++;
					str_process_counter = deci32_int32_to_string_deci( process_counter, 1, 0 );

					break;

				default:
					break;
			}

			heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );
			_store_32( UART32_UARTINT_COUNT_ADDR, 0 );
			_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
		}
	}
}