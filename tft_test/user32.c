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

#define TFT_HEIGHT 160
#define TFT_WIDTH 128
#define TFT_SIZE TFT_HEIGHT * TFT_WIDTH

#define LIFE_HEIGHT 40
#define LIFE_WIDTH 32
#define BLOCK_HEIGHT 4
#define BLOCK_WIDTH 4
#define BLOCK_COLOR COLOR16_YELLOW
#define BACK_COLOR COLOR16_BLUE
#define PADDING_COLOR COLOR16_CYAN
#define OFFSET_X 0
#define OFFSET_Y 0
#define LIFE_PRESET true // If False, Start with Random

void binary_random( uchar8* array, uint32 array_size );
void print_life( uchar8* life, uint32 life_height, uint32 life_width );

uchar8 life1[LIFE_HEIGHT*LIFE_WIDTH] =
{
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,1,0,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,1,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
};


uchar8* life2;
uchar8* life_front;
uchar8* life_back;
uint32 life_height = LIFE_HEIGHT; // Multiply of 4
uint32 life_width = LIFE_WIDTH;
uint32 life_size;
bool life_switch;

int32 _user_start()
{
	uchar8 number_neighbor;
	uint32 offset_vertical;
	int32 neighbor_vertical;
	int32 neighbor_horizontal;

	// Initialize Buffer
	obj renderbuffer = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer, TFT_WIDTH, TFT_HEIGHT, 16 );
	_attach_buffer( renderbuffer );

	life_size = life_height * life_width;
	life2 = (uchar8*)heap32_malloc( life_size / 4 ); // One Unit of This Malloc is One Word (4 Bytes)
	binary_random( life2, life_size );

//print32_debug_hexa( (uint32)life1, 0, 0, life_size );
//print32_debug_hexa( (uint32)life2, 0, 300, life_size );

	if ( LIFE_PRESET ) {
		life_switch = true;
	} else {
		life_switch = false;
	}

	while( true ) {
		if ( life_switch ) {
			life_front = life1;
			life_back = life2;
			life_switch = false;
		} else {
			life_front = life2;
			life_back = life1;
			life_switch = true;
		}
		print_life( life_front, life_height, life_width );

		for ( uint32 i = 0; i < life_height; i++ ) {
			offset_vertical = i * life_width;
			for ( uint32 j = 0; j < life_width; j++ ) {
				number_neighbor = 0;

				// Vertical Shift to Upper Neighbors
				neighbor_vertical = i - 1;
				if ( neighbor_vertical < 0 ) neighbor_vertical = life_height - 1;
				neighbor_horizontal = j - 1;
				if ( neighbor_horizontal < 0 ) neighbor_horizontal = life_width - 1;
				if ( life_front[neighbor_vertical*life_width+neighbor_horizontal] ) number_neighbor++;
				neighbor_horizontal = j;
				if ( life_front[neighbor_vertical*life_width+neighbor_horizontal] ) number_neighbor++;
				neighbor_horizontal = j + 1;
				if ( neighbor_horizontal >= life_width ) neighbor_horizontal = 0;
				if ( life_front[neighbor_vertical*life_width+neighbor_horizontal] ) number_neighbor++;

				// Vertical Shift to Horizontal Neighbors
				neighbor_vertical = i;
				neighbor_horizontal = j - 1;
				if ( neighbor_horizontal < 0 ) neighbor_horizontal = life_width - 1;
				if ( life_front[neighbor_vertical*life_width+neighbor_horizontal] ) number_neighbor++;
				neighbor_horizontal = j + 1;
				if ( neighbor_horizontal >= life_width ) neighbor_horizontal = 0;
				if ( life_front[neighbor_vertical*life_width+neighbor_horizontal] ) number_neighbor++;

				// Vertical Shift to Lower Neighbors
				neighbor_vertical = i + 1;
				if ( neighbor_vertical >= life_height ) neighbor_vertical = 0;
				neighbor_horizontal = j - 1;
				if ( neighbor_horizontal < 0 ) neighbor_horizontal = life_width - 1;
				if ( life_front[neighbor_vertical*life_width+neighbor_horizontal] ) number_neighbor++;
				neighbor_horizontal = j;
				if ( life_front[neighbor_vertical*life_width+neighbor_horizontal] ) number_neighbor++;
				neighbor_horizontal = j + 1;
				if ( neighbor_horizontal >= life_width ) neighbor_horizontal = 0;
				if ( life_front[neighbor_vertical*life_width+neighbor_horizontal] ) number_neighbor++;

				if ( number_neighbor < 2 || number_neighbor > 3 ) {
					life_back[offset_vertical+j] = 0x00;
				} else if ( number_neighbor == 3 ) {
					life_back[offset_vertical+j] = 0x01;
				} else { // 2 Stays Status
					life_back[offset_vertical+j] = life_front[offset_vertical+j];
				}
				arm32_dsb();
			}
		}
		_tftimage_type1( _load_32( renderbuffer + draw32_renderbuffer_addr ), TFT_SIZE );
		_sleep( 250000 );
	}

	return EXIT_SUCCESS;
}

void binary_random( uchar8* array, uint32 array_size ) {
//print32_debug( (uint32)array, 0, 100 );
//print32_debug( (uint32)array_size, 0, 112 );
	for ( uint32 i = 0; i < array_size; i++ ) {
		if ( _random( 255 ) > 127) {
			array[i] = 0x01;
		} else {
			array[i] = 0x00;
		}
//print32_debug( i, 0, 124 );
		arm32_dsb();
	}
}

void print_life( uchar8* life, uint32 life_height, uint32 life_width ) {
	uint32 offset_vertical = 0;
	FB32_X_CARET = OFFSET_X;
	FB32_Y_CARET = OFFSET_Y;
	fb32_block_color( BACK_COLOR, FB32_X_CARET, FB32_Y_CARET, LIFE_WIDTH * BLOCK_WIDTH, LIFE_HEIGHT * BLOCK_HEIGHT );
	for ( uint32 i = 0; i < life_height; i++ ) {
		for ( uint32 j = 0; j < life_width; j++ ) {
			if ( life[offset_vertical+j] ) fb32_block_color( BLOCK_COLOR, FB32_X_CARET, FB32_Y_CARET, BLOCK_WIDTH, BLOCK_HEIGHT );
			FB32_X_CARET += BLOCK_WIDTH;
			arm32_dsb();
		}
		FB32_X_CARET = OFFSET_X;
		FB32_Y_CARET += BLOCK_HEIGHT;
		offset_vertical += life_width;
	}

}

