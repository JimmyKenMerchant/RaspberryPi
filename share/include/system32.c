/**
 * system32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * In SVC mode, Regular Registers Stay, but SP, LR, and SPSR are Banked.
 * So, as SVCm, you need to have only r0-r3 registers to execute functions.
 */
__attribute__((noinline)) uint32 _example_svc_0( int32 a, int32 b, int32 c, int32 d )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0");
	return result;
}

__attribute__((noinline)) uint32 _display_off( bool bool_off )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x02");
	return result;
}

__attribute__((noinline)) uint32 _flush_doublebuffer()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x03");
	return result;
}

__attribute__((noinline)) uint32 _set_doublebuffer( uint32 address_buffer_front, uint32 address_buffer_back )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x04");
	return result;
}

__attribute__((noinline)) uint32 _attach_buffer( uint32 address_buffer )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x05");
	return result;
}

__attribute__((noinline)) void _stopwatch_start()
{
	asm volatile ("svc #0x06");
}

__attribute__((noinline)) uint64 _stopwatch_end()
{
	register uint64 result asm("r0"); // r0 and r1 Are Used for uint64
	asm volatile ("svc #0x07");
	return result;
}

__attribute__((noinline)) void _sleep( uint32 u_seconds )
{
	asm volatile ("svc #0x08");
}

__attribute__((noinline)) uchar8 _random( uchar8 range_end )
{
	register uchar8 result asm("r0");
	asm volatile ("svc #0x09");
	return result;
}

__attribute__((noinline)) void _store_8( uint32 address, char8 data )
{
	asm volatile ("svc #0x0A");
}

__attribute__((noinline)) char8 _load_8( uint32 address )
{
	register char8 result asm("r0");
	asm volatile ("svc #0x0B");
	return result;
}

__attribute__((noinline)) void _store_16( uint32 address, int16 data )
{
	asm volatile ("svc #0x0C");
}

__attribute__((noinline)) int16 _load_16( uint32 address )
{
	register int16 result asm("r0");
	asm volatile ("svc #0x0D");
	return result;
}

__attribute__((noinline)) void _store_32( uint32 address, int32 data )
{
	asm volatile ("svc #0x0E");
}

__attribute__((noinline)) int32 _load_32( uint32 address )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x0F");
	return result;
}

__attribute__((noinline)) uint64 _timestamp()
{
	register uint64 result asm("r0"); // r0 and r1 Are Used for uint64
	asm volatile ("svc #0x10");
	return result;
}

__attribute__((noinline)) uint32 _armtimer( uint32 timer_ctl, uint32 load, uint32 predivider )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x11");
	return result;
}

__attribute__((noinline)) uint32 _armtimer_reload( uint32 reload )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x12");
	return result;
}

__attribute__((noinline)) uint32 _armtimer_load( uint32 load )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x13");
	return result;
}

__attribute__((noinline)) uint32 _clockmanager( uint32 clocktype_base, uint32 clk_ctl, uint32 clk_divisors )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x14");
	return result;
}

__attribute__((noinline)) uint32 _clockmanager_divisor( uint32 clocktype_base, uint32 clk_divisors )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x15");
	return result;
}

__attribute__((noinline)) uint32 _calender_init( uint32 year, uchar8 month, uchar8 day )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x16");
	return result;
}

__attribute__((noinline)) uint32 _clock_init( uchar8 hour, uchar8 minute, uchar8 second, uint32 usecond )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x17");
	return result;
}

__attribute__((noinline)) uint32 _correct_utc( int32 distance_utc )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x18");
	return result;
}

__attribute__((noinline)) uint32 _get_time()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x19");
	return result;
}

__attribute__((noinline)) uint32 _set_time( uint64 timestamp )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x1A");
	return result;
}

__attribute__((noinline)) uint32 _sounddecode( sound_index* index, uchar8 mode, sound_adjust* adjust )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x1B");
	return result;
}

__attribute__((noinline)) uint32 _soundset( music_code* music, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x1C");
	return result;
}

__attribute__((noinline)) uint32 _soundplay( bool mode )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x1D");
	return result;
}

__attribute__((noinline)) uint32 _soundinterrupt( music_code* music, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x1E");
	return result;
}

__attribute__((noinline)) uint32 _soundclear()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x1F");
	return result;
}

__attribute__((noinline)) uint32 _synthewave_pwm( float32 bend_rate, uint32 number_voices )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x20");
	return result;
}

__attribute__((noinline)) uint32 _synthewave_i2s( float32 bend_rate, uint32 number_voices )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x21");
	return result;
}

__attribute__((noinline)) uint32 _syntheset( synthe_code* synthe, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x22");
	return result;
}

__attribute__((noinline)) uint32 _syntheplay( uint32 number_voices )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x23");
	return result;
}

__attribute__((noinline)) uint32 _syntheclear( uint32 number_voices )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x24");
	return result;
}

__attribute__((noinline)) uint32 _gpioplay( uint32 gpio_mask )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x25");
	return result;
}

__attribute__((noinline)) uint32 _gpioset( gpio_sequence* gpio, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x26");
	return result;
}

__attribute__((noinline)) uint32 _gpioclear( uint32 gpio_mask, bool stay )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x27");
	return result;
}

__attribute__((noinline)) uint32 _gpiotoggle( uint32 number_gpio, uchar8 control )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x28");
	return result;
}

__attribute__((noinline)) uint32 _gpiomode( uint32 number_gpio, uchar8 function_select )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x29");
	return result;
}

__attribute__((noinline)) uint32 _gpioevent( uint32 number_gpio, uchar8 event_select, bool on )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x2A");
	return result;
}

__attribute__((noinline)) uint32 _gpiopull( uint32 number_gpio, uchar8 control )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x2B");
	return result;
}

__attribute__((noinline)) uint32 _pwmplay()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x2C");
	return result;
}

__attribute__((noinline)) uint32 _pwmset( pwm_sequence* pwm, uint32 length, uint32 count, int32 repeat )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x2D");
	return result;
}

__attribute__((noinline)) uint32 _pwmclear( bool stay )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x2E");
	return result;
}

__attribute__((noinline)) uint32 _pwmselect( uint32 channel )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x2F");
	return result;
}

__attribute__((noinline)) uint32 _uartinit( uint32 div_int, uint32 div_frac, uint32 line_ctl, uint32 ctl )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x30");
	return result;
}

__attribute__((noinline)) uint32 _uartsettest( bool tdr_on, bool tx_on, bool rx_on )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x31");
	return result;
}

__attribute__((noinline)) uint32 _uarttestwrite( String address_heap, uint32 size )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x32");
	return result;
}

__attribute__((noinline)) uint32 _uarttestread( String address_heap, uint32 size )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x33");
	return result;
}

__attribute__((noinline)) uint32 _uartsetint( uint32 int_fifo, uint32 int_mask )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x34");
	return result;
}

__attribute__((noinline)) String _uartint_emulate( bool flag_mirror, uchar8 character_rx )
{
	register String result asm("r0");
	asm volatile ("svc #0x35");
	return result;
}

__attribute__((noinline)) uint32 _uartclrint()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x36");
	return result;
}

__attribute__((noinline)) uint32 _uarttx( String address_heap, uint32 size )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x37");
	return result;
}

__attribute__((noinline)) uint32 _uartrx( String address_heap, uint32 size )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x38");
	return result;
}

__attribute__((noinline)) uint32 _uartclrrx()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x39");
	return result;
}

__attribute__((noinline)) uint32 _uartsetheap( uint32 num_heap )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x3A");
	return result;
}

__attribute__((noinline)) uint32 _uartclient( bool mode_client )
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x3B");
	return result;
}

__attribute__((noinline)) uint32 _otg_host_reset_bcm()
{
	register uint32 result asm("r0");
	asm volatile ("svc #0x3C");
	return result;
}

__attribute__((noinline)) int32 _hub_activate( uint32 channel, uint32 ticket )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x3D");
	return result;
}

__attribute__((noinline)) int32 _hub_search_device( uint32 channel, uint32 address_hub )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x3E");
	return result;
}

__attribute__((noinline)) int32 _hid_activate( uint32 channel, uint32 number_configuration, uint32 ticket )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x3F");
	return result;
}

__attribute__((noinline)) int32 _hid_setidle( uint32 channel, uint32 number_interface, uint32 ticket )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x40");
	return result;
}

__attribute__((noinline)) String _keyboard_get( uint32 channel, uint32 number_endpoint, uint32 ticket )
{
	register String result asm("r0");
	asm volatile ("svc #0x41");
	return result;
}

__attribute__((noinline)) int32 _romread_i2c( uint32 address_heap, uint32 chip_select, uint32 address_memory, uint32 length )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x42");
	return result;
}

__attribute__((noinline)) int32 _romwrite_i2c( uint32 address_heap, uint32 chip_select, uint32 address_memory, uint32 length )
{
	register int32 result asm("r0");
	asm volatile ("svc #0x43");
	return result;
}


/**
 * Unique Definitions
 */

void _no_op()
{
	asm volatile ("mov r0, r0");
}

bool _gpio_detect( uchar8 gpio_number )
{
	int32 value;
	if ( gpio_number >= 32 ) {
		gpio_number -= 32;
		value = _load_32( _gpio_base|_gpio_gpeds1 );
		if ( value & 1 << gpio_number ) {
			value = 1 << gpio_number;
			_store_32( _gpio_base|_gpio_gpeds1, value );
			return true;
		} else {
			return false;
		}
	} else {
		value = _load_32( _gpio_base|_gpio_gpeds0 );
		if ( value & 1 << gpio_number ) {
			value = 1 << gpio_number;
			_store_32( _gpio_base|_gpio_gpeds0, value );
			return true;
		} else {
			return false;
		}
	}
}

bool _gpio_in( uchar8 gpio_number )
{
	int32 value;
	if ( gpio_number >= 32 ) {
		gpio_number -= 32;
		value = _load_32( _gpio_base|_gpio_gplev1 );
	} else {
		value = _load_32( _gpio_base|_gpio_gplev0 );
	}
	if ( value & 1 << gpio_number ) {
		return true;
	} else {
		return false;
	}
}

