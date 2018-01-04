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

void _user_start()
{
	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	String newline = "\n\0";

	while (true) {
		if ( _load_32( os_irq_busy ) ) {
			print32_set_caret( print32_string( os_irq_heap, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( os_irq_heap ), 8, 12, FONT_MONO_12PX_ASCII ) );
			print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
			_store_32( os_irq_busy, 0 );
		}
	}
}