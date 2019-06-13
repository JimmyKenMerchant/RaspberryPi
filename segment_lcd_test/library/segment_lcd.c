/**
 * segment_lcd.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

void segment_lcd_init( uchar8 gpio_cs, uchar8 gpio_rd, uchar8 gpio_wr, uchar8 gpio_data ) {
	segment_lcd_gpio_cs = gpio_cs;
	segment_lcd_gpio_rd = gpio_rd;
	segment_lcd_gpio_wr = gpio_wr;
	segment_lcd_gpio_data = gpio_data;
	arm32_dsb();

	_gpiomode( segment_lcd_gpio_cs, _GPIOMODE_OUT );
	_gpiomode( segment_lcd_gpio_rd, _GPIOMODE_OUT );
	_gpiomode( segment_lcd_gpio_wr, _GPIOMODE_OUT );
	_gpiomode( segment_lcd_gpio_data, _GPIOMODE_OUT );
	arm32_dsb();

	segment_lcd_reset();
	
	/* Wait Time 10 Milliseconds After Power On */
	_sleep( 10000 );
}

void segment_lcd_reset() {
	/* Reset to High */
	_gpiotoggle( segment_lcd_gpio_cs, _GPIOTOGGLE_HIGH );
	_gpiotoggle( segment_lcd_gpio_rd, _GPIOTOGGLE_HIGH );
	_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_HIGH );
	_gpiotoggle( segment_lcd_gpio_data, _GPIOTOGGLE_HIGH );
	arm32_dsb();
	
	/* Wait for Next CS Low */
	_sleep( SEGMENT_LCD_PULSE_WIDTH );
}

void segment_lcd_write( uchar8 data, uchar8 length_bits ) {
	uchar8 mask = 0b1 << (length_bits - 1);

	/* Each Bit is Detected on Rising Edge of WR Clock */
	for ( uint32 i = 0; i < length_bits; i++ ) {
		_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_LOW );
		if ( (data << i) & mask ) {
			_gpiotoggle( segment_lcd_gpio_data, _GPIOTOGGLE_HIGH );
		} else {
			_gpiotoggle( segment_lcd_gpio_data, _GPIOTOGGLE_LOW );
		}
		arm32_dsb();
		_sleep( SEGMENT_LCD_PULSE_WIDTH );
		_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_HIGH );
		arm32_dsb();
		_sleep( SEGMENT_LCD_PULSE_WIDTH );
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

	/* Last WR Clock */
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
	segment_lcd_write( data, SEGMENT_LCD_DATA_LENGTH );

	/* Last WR Clock */
	_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_LOW );
	_sleep( SEGMENT_LCD_PULSE_WIDTH );
	_gpiotoggle( segment_lcd_gpio_wr, _GPIOTOGGLE_HIGH );
	_sleep( SEGMENT_LCD_PULSE_WIDTH );
	
	/* Reset to High */
	segment_lcd_reset();
}

void segment_lcd_char( uchar8 digit, uchar8 number_char ) {
	if ( number_char >= SEGMENT_LCD_CHARS_MAX ) number_char = SEGMENT_LCD_CHARS_MAX - 1;
	uchar8 data_number = segment_lcd_chars[number_char];
	segment_lcd_data( digit * 2, (data_number >> 4) & 0xF );
	segment_lcd_data( (digit * 2) + 1, data_number & 0xF );
}
