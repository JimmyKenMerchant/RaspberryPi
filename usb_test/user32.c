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

int32 response;

int32 _user_start()
{
	usb_channel = 0;
	obj string = heap32_malloc( 2 );

	_sleep( 500000 );

	if ( ! init_usb_keyboard() ) return EXIT_FAILURE;

	while(True) {
		response = _keyboard_get( usb_channel, 1, ticket_hid );
		arm32_dsb();
print32_debug( response, 500, 206 );
		if ( response > 0 ) {
			_store_32( string, response );
			print32_set_caret( print32_string( (String)string, FB32_X_CARET, FB32_Y_CARET, str32_strlen( (String)string ) ) );
		}
		_sleep( 10000 );
	}

	heap32_mfree( string );

	return EXIT_SUCCESS;
}


bool init_usb_keyboard()
{
	_otg_host_reset_bcm();

	ticket_hub = _hub_activate( usb_channel, 0 );
	arm32_dsb();

print32_debug( ticket_hub, 500, 230 );

	if ( ticket_hub == -2 ) {
		ticket_hid = 0; // Direct Connection
	} else if ( ticket_hub > 0 ) {
		ticket_hid = _hub_search_device( usb_channel, ticket_hub );
#ifdef __B
		arm32_dsb();
		ticket_hid = _hub_search_device( usb_channel, ticket_hub );
#endif
	} else {
		return False;
	}
	arm32_dsb();

print32_debug( ticket_hid, 500, 242 );

	if ( ticket_hid <= 0 ) return False;

	_sleep( 500000 ); // Hub Port is Powerd On, So Wait for Activation of Device

	ticket_hid = _hid_activate( usb_channel, 1, ticket_hid );
	arm32_dsb();

	return True;
}


