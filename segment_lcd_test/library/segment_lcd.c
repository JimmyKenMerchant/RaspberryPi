/**
 * segment_lcd.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

void segment_lcd_init( uchar8 gpio_cs, uchar8 gpio_wr, uchar8 gpio_data ) {
	segment_lcd_gpio_cs = gpio_cs;
	segment_lcd_gpio_wr = gpio_wr;
	segment_lcd_gpio_data = gpio_data;
	arm32_dsb();

	_gpiopull( segment_lcd_gpio_cs, _GPIOPULL_DOWN );
	_gpiopull( segment_lcd_gpio_wr, _GPIOPULL_DOWN );
	_gpiopull( segment_lcd_gpio_data, _GPIOPULL_DOWN );
	_gpiomode( segment_lcd_gpio_cs, _GPIOMODE_OUT );
	_gpiomode( segment_lcd_gpio_wr, _GPIOMODE_OUT );
	_gpiomode( segment_lcd_gpio_data, _GPIOMODE_OUT );

	segment_lcd_reset();

	/* Delay Time After Power On */
	_sleep( SEGMENT_LCD_DELAY_WIDTH );
	arm32_dsb();
}

void segment_lcd_reset() {
	/* Reset to High */
	_gpiotoggle( segment_lcd_gpio_cs, _GPIOTOGGLE_HIGH );
	_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_HIGH );
	_gpiotoggle( segment_lcd_gpio_data, _GPIOTOGGLE_HIGH );

	/* Wait for Next CS Low */
	_sleep( SEGMENT_LCD_PULSE_WIDTH );
	arm32_dsb();
}

void segment_lcd_write( uchar8 bits, uchar8 length_bits ) {
	uchar8 mask = 0b1 << (length_bits - 1);

	/* Each Bit is Detected on Rising Edge of WR Clock */
	for ( uint32 i = 0; i < length_bits; i++ ) {
		_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_LOW );
		if ( (bits << i) & mask ) {
			_gpiotoggle( segment_lcd_gpio_data, _GPIOTOGGLE_HIGH );
		} else {
			_gpiotoggle( segment_lcd_gpio_data, _GPIOTOGGLE_LOW );
		}
		_sleep( SEGMENT_LCD_PULSE_WIDTH );
		_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_HIGH );
		_sleep( SEGMENT_LCD_PULSE_WIDTH );
		arm32_dsb();
	}
}

void segment_lcd_command( uchar8 command ) {
	segment_lcd_reset();

	/* CS Low and Wait */
	_gpiotoggle( segment_lcd_gpio_cs, _GPIOTOGGLE_LOW );
	_sleep( SEGMENT_LCD_PULSE_WIDTH );

	/* Start Bits 0b100 */
	segment_lcd_write( 0b100, SEGMENT_LCD_START_LENGTH );

	/* Command */
	segment_lcd_write( command, SEGMENT_LCD_COMMAND_LENGTH );

	/* Dummy WR Clock at Last */
	_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_LOW );
	_sleep( SEGMENT_LCD_PULSE_WIDTH );
	_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_HIGH );
	_sleep( SEGMENT_LCD_PULSE_WIDTH );

	/* Reset to High */
	segment_lcd_reset();
}

void segment_lcd_data( uchar8 address, uchar8 data ) {
	segment_lcd_reset();

	/* CS Low and Wait */
	_gpiotoggle( segment_lcd_gpio_cs, _GPIOTOGGLE_LOW );
	_sleep( SEGMENT_LCD_PULSE_WIDTH );

	/* Start Bits 0b100 */
	segment_lcd_write( 0b101, SEGMENT_LCD_START_LENGTH );

	/* Address */
	segment_lcd_write( address, SEGMENT_LCD_ADDRESS_LENGTH );

	/* Data */
	data = (uchar8)bit32_reflect_bit( data, SEGMENT_LCD_DATA_LENGTH ); // Reflect Bits
	segment_lcd_write( data, SEGMENT_LCD_DATA_LENGTH ); // Data is Send from LSB to MSB

	/* Dummy WR Clock at Last */
	_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_LOW );
	_sleep( SEGMENT_LCD_PULSE_WIDTH );
	_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_HIGH );
	_sleep( SEGMENT_LCD_PULSE_WIDTH );

	/* Reset to High */
	segment_lcd_reset();
}

void segment_lcd_printn( uchar8 digit, uchar8 number, uchar8 mask ) {
	if ( number >= SEGMENT_LCD_NUMBER_MAX ) number = SEGMENT_LCD_NUMBER_MAX - 1;
	uchar8 data_number = segment_lcd_array_numbers[number];
	data_number |= mask; // Add Bits in mask
	segment_lcd_data( digit * 2, data_number & 0xF );
	segment_lcd_data( (digit * 2) + 1, (data_number >> 4) & 0xF );
}

void segment_lcd_clear( uchar8 data ) {
	for ( uint32 i = 0; i < SEGMENT_LCD_GRAM_SIZE; i++ ) {
			segment_lcd_data( i, data );
			arm32_dsb();
	}
}
