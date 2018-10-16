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

bool init_usb_keyboard();
uint32 usb_channel; // 0-15
int32 ticket_hub;
int32 ticket_hid;
int32 ticket_hid_passed;
String kb_str;

int32 _user_start()
{

	usb_channel = 0;

	if ( ! init_usb_keyboard() ) return EXIT_FAILURE;

	while(True) {
		kb_str = _keyboard_get( usb_channel, 1, ticket_hid_passed );
		arm32_dsb();
		if ( kb_str ) {
			print32_set_caret( print32_string( kb_str, FB32_X_CARET, FB32_Y_CARET, str32_strlen( kb_str ) ) );
			heap32_mfree( (obj)kb_str );
		}
		_sleep( 10000 );
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
 * Many USB drivers use iteration process (retry) for the communications.
 */
bool init_usb_keyboard()
{

	uint32 timeout;

	_otg_host_reset_bcm();

	_sleep( 200000 ); // Root Hub Port is Powerd On, So Wait for Detection of Other Hubs or Devices (on Inner Activation)

	timeout = 30;
	do {
		ticket_hub = _hub_activate( usb_channel, 0 );
		if ( ticket_hub ) break; // Break Except Zero (No Detection)
		_sleep( 100000 );
		timeout--;
	} while ( timeout ); // Except Zero

	arm32_dsb();

	_sleep( 200000 ); // Hub Port is Powerd On, So Wait for Detection of Devices (on Inner Activation)

print32_debug( ticket_hub, 500, 230 );

	if ( ticket_hub == -1 ) {
		ticket_hid = 0; // Direct Connection
		_sleep( 2000000 ); // Further Wait
	} else if ( ticket_hub > 0 ) {
		timeout = 30;
		do {
			ticket_hid = _hub_search_device( usb_channel, ticket_hub );
			if ( ticket_hid ) break; // Break Except Zero (No Detection)
			_sleep( 100000 );
			timeout--;
		} while ( timeout ); // Except Zero

// Hubs on B type uses port no.1 for an ethernet adaptor. To get a HID, search another device again.
#ifdef __B
		arm32_dsb();
		timeout = 30;
		do {
			ticket_hid = _hub_search_device( usb_channel, ticket_hub );
			if ( ticket_hid ) break; // Break Except Zero (No Detection)
			_sleep( 100000 );
			timeout--;
		} while ( timeout ); // Except Zero
#endif

		if ( ticket_hid <= 0 ) return False; // Hub Exists But No Connection with Device or Communication Error

	} else {
		return False; // Communication Error on Activation of Hub
	}
	arm32_dsb();

print32_debug( ticket_hid, 500, 242 );

	_sleep( 200000 ); // HID is Detected, So Wait for Activation of Devices (on Inner Resetting Procedure)

	timeout = 30;
	do {
		ticket_hid_passed = _hid_activate( usb_channel, 1, ticket_hid );
		if (ticket_hid_passed > 0) break; // Break Except Errors
		_sleep( 100000 );
		timeout--;
	} while ( timeout ); // Except Zero

	arm32_dsb();

print32_debug( ticket_hid_passed, 500, 254 );

	//_hid_setidle( usb_channel, 0, ticket_hid_passed );

	return True;
}


