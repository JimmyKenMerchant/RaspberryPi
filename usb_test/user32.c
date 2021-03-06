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

#define ACT_TIME_ROOTHUB 750000
#define ACT_TIME_DEVICE  750000

bool init_usb_keyboard( uint32 usb_channel );
bool console_rollup();
bool print_on_receive();
uint32 usb_channel; // 0-15
int32 ticket_hub;
int32 ticket_hid;
String kb_str;
extern uint32 OS_FIQ_TIMER_ADDR;
extern bool OS_FIQ_TIMER;
_RenderBuffer* renderbuffer;

char8 character_buffer[2];

int32 _user_start() {

	usb_channel = 0;

	if ( ! init_usb_keyboard( usb_channel ) ) return EXIT_FAILURE;

	renderbuffer = (_RenderBuffer*)heap32_malloc( _wordsizeof( _RenderBuffer ) );
	draw32_renderbuffer_init( renderbuffer, FB32_WIDTH, FB32_HEIGHT, FB32_DEPTH );

#ifndef __DEBUG
	_attach_buffer( renderbuffer );
	print32_string( "\x1B[33m\x1B[44m\0", FB32_X_CARET, FB32_Y_CARET, 10 ); // Change Foreground/Background Color
	fb32_clear_color( PRINT32_FONT_BACKCOLOR );
#endif

	while(True) {
		if ( OS_FIQ_TIMER ) {
			_store_8( OS_FIQ_TIMER_ADDR, false );
			kb_str = _keyboard_get( usb_channel, 1, ticket_hid );
			arm32_dsb();
			if ( kb_str ) {
#ifdef __DEBUG
				print32_set_caret( print32_string( kb_str, FB32_X_CARET, FB32_Y_CARET, str32_strlen( kb_str ) ) );
#else
				_uarttx( kb_str, str32_strlen( kb_str ) );
#endif
				heap32_mfree( (obj)kb_str );
			}
		}
#ifndef __DEBUG
		print_on_receive();
#endif
		arm32_dsb();
	}

	return EXIT_SUCCESS;
}

/**
 * USB devices begin their activation procedures since powered-on of ports.
 * Plus, devices need to end their resetting procedures since getting resetting signal from ports.
 * To get resetting signal, devices need to end their activation procedures.
 * And to get more signals, devices need to end their resetting procedures.
 * If their procedures have not ended yet,
 * the communications between host and any device meet incorrect conclusions.
 * Many USB drivers use iteration processes (retry) for the communications.
 */
bool init_usb_keyboard( uint32 usb_channel ) {

	uint32 timeout;
	uint32 result;

	_sleep( ACT_TIME_ROOTHUB ); // Wait for Root Hub Activation

	if ( _otg_host_reset_bcm() ) return False;
	arm32_dsb();

	_sleep( ACT_TIME_DEVICE ); // Root Hub Port is Powerd On, So Wait for Detection of Other Hubs or Devices (on Inner Activation)

	timeout = 20;
	do {
		_sleep( ACT_TIME_DEVICE );
		ticket_hub = _hub_activate( usb_channel, 0 );
		if ( ticket_hub ) break; // Break Except Zero (No Detection)
		timeout--;
	} while ( timeout ); // Except Zero

	arm32_dsb();

	_sleep( ACT_TIME_DEVICE ); // Hub Port is Powerd On, So Wait for Detection of Devices (on Inner Activation)

print32_debug( ticket_hub, 500, 230 );

	if ( ticket_hub == -1 ) {
		ticket_hid = 0; // Direct Connection
		_sleep( ACT_TIME_DEVICE ); // Further Wait
	} else if ( ticket_hub > 0 ) {
		timeout = 20;
		do {
			_sleep( ACT_TIME_DEVICE );
			ticket_hid = _hub_search_device( usb_channel, ticket_hub );
			if ( ticket_hid ) break; // Break Except Zero (No Detection)
			timeout--;
		} while ( timeout ); // Except Zero

// Hubs on B type uses port no.1 for an ethernet adaptor. To get a HID, search another device again.
#ifdef __B
		arm32_dsb();
		timeout = 20;
		do {
			_sleep( ACT_TIME_DEVICE );
			ticket_hid = _hub_search_device( usb_channel, ticket_hub );
			if ( ticket_hid ) break; // Break Except Zero (No Detection)
			timeout--;
		} while ( timeout ); // Except Zero
#endif

		if ( ticket_hid <= 0 ) return False; // Hub Exists But No Connection with Device or Communication Error

	} else {
		return False; // Communication Error on Activation of Hub
	}
	arm32_dsb();

print32_debug( ticket_hid, 500, 242 );

	_sleep( ACT_TIME_DEVICE ); // HID is Detected, So Wait for Activation of Devices (on Inner Resetting Procedure)

	timeout = 20;
	do {
		_sleep( ACT_TIME_DEVICE );
		result = _hid_activate( usb_channel, 1, ticket_hid );
		if ( result > 0 ) break; // Break Except Errors
		timeout--;
	} while ( timeout ); // Except Zero

	ticket_hid = result;

	if ( ticket_hid <= 0 ) return False; // Communication Error or No HID Device If Direct Connection

	arm32_dsb();

print32_debug( ticket_hid, 500, 254 );

	//_hid_setidle( usb_channel, 0, ticket_hid );

	return True;
}


bool print_on_receive() {
	while ( _load_32( UART32_UARTINT_CLIENT_FIFO ) ) { // If Any Character Is Received
		character_buffer[0] = (char8)heap32_mpop( UART32_UARTINT_CLIENT_FIFO, HEAP32_FIFO_1BYTE );
		if ( print32_set_caret( print32_string( character_buffer, FB32_X_CARET, FB32_Y_CARET, 1 ) ) ) console_rollup();

		// Flush to Display When FIFO Becomes Empty
		if ( _load_32( UART32_UARTINT_CLIENT_FIFO ) == 0 ) {
			_attach_buffer( FB32_FRAMEBUFFER );
			arm32_dsb();
			fb32_image(
					renderbuffer->addr,
					0,
					0,
					renderbuffer->width,
					renderbuffer->height,
					0,
					0,
					0,
					0
			);
			fb32_block_color( PRINT32_FONT_COLOR, FB32_X_CARET, FB32_Y_CARET, PRINT32_FONT_WIDTH, PRINT32_FONT_HEIGHT ); // Append Text Cursor
			arm32_dsb();
			_attach_buffer( renderbuffer );
			arm32_dsb();
		}
	}
	return True;
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
