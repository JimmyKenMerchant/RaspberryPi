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

extern String os_irq_heap;
extern uint32 os_irq_busy;
extern uint32 os_irq_count;

void _user_start()
{
	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	uint32 pipe = 0;
	uint32 type = 0;
	float32 var_a = 0.0;
	float32 var_b = 0.0;
	float32 response = 0.0;
	String str_aloha = "Aloha Calc Version 0.8 Alpha: Copyright (C) 2018 Kenta Ishii\r\n\r\n\0";
	String str_prompt = "0: fadd/fsub/fmul/fdiv?\r\n\0";

	if ( print32_set_caret( print32_string( str_aloha, FB32_X_CARET, FB32_Y_CARET, COLOR32_YELLOW, back_color, print32_strlen( str_aloha ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_aloha, print32_strlen( str_aloha ) + 1 );

	if ( print32_set_caret( print32_string( str_prompt, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( str_prompt ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;
	_uarttx( str_prompt, print32_strlen( str_prompt ) + 1 );

	while (true) {
		if ( _load_32( os_irq_busy ) ) {
			if ( print32_set_caret( print32_string( os_irq_heap, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( os_irq_heap ), 8, 12, FONT_MONO_12PX_ASCII ) ) ) FB32_Y_CARET = 0;

			switch ( pipe ) {
				case 0:
					if ( print32_strindex( os_irq_heap, "fadd" ) != -1 ) {
						_uarttx( "1: Float ADD\r\n1: VAR_FIRST?\r\n\0", 30 );
						type = 0;
						pipe = 1;
					} else if ( print32_strindex( os_irq_heap, "fsub" ) != -1 ) {
						_uarttx( "1: Float SUB\r\n1: VAR_FIRST?\r\n\0", 30 );
						type = 1;
						pipe = 1;
					} else if ( print32_strindex( os_irq_heap, "fmul" ) != -1 ) {
						_uarttx( "1: Float MUL\r\n1: VAR_FIRST?\r\n\0", 30 );
						type = 2;
						pipe = 1;
					} else if ( print32_strindex( os_irq_heap, "fdiv" ) != -1 ) {
						_uarttx( "1: Float MUL\r\n1: VAR_FIRST?\r\n\0", 30 );
						type = 3;
						pipe = 1;
					}

					break;

				case 1:
					_uarttx( "2: VAR_SECOND?\r\n\0", 17 );

					pipe = 2;

					break;

				case 2:

					pipe = 0;

					break;

				default:
					break;
			}

			heap32_mfill( (obj)os_irq_heap, 0 );
			_store_32( os_irq_count, 0 );
			_store_32( os_irq_busy, 0 );
		}
	}
}