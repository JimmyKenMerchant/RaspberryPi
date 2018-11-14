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
#include "snd32/soundindex.h"
#include "snd32/soundadjust.h"
#include "snd32/musiccode.h"

/**
 * Length of Initial Loading on Start Up
 */
#define startup_load_length  "5"

#define initial_line         1
#define argument_maxlength   8
#define label_maxlength      64 // Maximum Limitation of Length of Labels
#define gpio_output          0x0F800000 // GPIO23-27

/**
 * Maximum limitation of the length of characters on each label.
 * The number means word (4 bytes), i.e., 1 Means 4 Bytes. The last 1 Bytes is for null character.
 * E.g., if you define 4, actual maximum length is 15 bytes (16 minus 1 for null character).
 */
#define label_maxchar        4 

#define link_stacksize       64
#define rawdata_maxlength    16
#define stack_offset_default 2

/**
 * On this program, the last line will be used as input buffer.
 * If you use "push" command, the data is stored to the line that the number is length of lines minus "stack_offset".
 * After you use "push" command, "stack_offset" will be incremented. After you use "pop" command, "stack_offset" will be decremented.
 */

/* D: Number of Line for Destination, S: Number of Line Stored Source */
typedef enum _command_list {
	null_command_list,
	endif, // IF statement, reset the pass flag.
	endwhile, // WHILE loop, return to the first of the loop.
	end, // End of script, should search after "end*" on search_command to prevent missing.
	_else, // IF statement, flip the pass flag.
	_break, // FOR/WHILE loop, break the loop
	print, // Print string, "print @D": Print string from D.
	sleep, // Sleep microseconds by integer "Sleep @S1": Number in S1 means micro seconds to sleep.
	/**
	 * Set calender and clock, "stime @S1 @S2 @S3 @S4 @S5 @S6 @S7":
	 * Year in S1, Month in S2, Day in S3, Hour in S4, Minute in S5, Second in S6, Micro Second in S7.
	 */
	stime,
	/**
	 * Get calender and clock, "gtime @D1 @D2 @D3 @D4 @D5 @D6 @D7 @D8":
	 * Year in S1, Month in S2, Week in S3, Day in S4, Hour in S5, Minute in S6, Second in S7, Micro Second in S8.
	 */
	gtime,
	/**
	 * "arr" makes raw data array of integer, "arr @D @S1 @S2 @S3":
	 * This command stores the number of raw data array to D. Number in S1 is the start line to be referenced. Number in S2 is length of line.
	 * Number in S3 is block size (0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes).
	 */
	arr,
	free, // Free memory space for raw data array, "free @S1": Free memory space for array whose number is indicated in S1.
	/**
	 * "pict" does sequential printing with judging bit value in raw data of array from MSB to LSB, "pict @S1 @S2 @S3 @S4":
	 * S1 is the string when true (1), S2 is the string when false (0), S3 is number of Array, S4 is block size (0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes).
	 * This command inserts "\r\n" when each data of array is ended. But the x coordinate offsets to the original point of the start of this command.
	 * On the end of this command, the x coordinate stands the original point of this command.
	 * Besides, the y coordinate stands the bottom of the last string.
	 */
	pict,
	csr, // Set cursor, "csr @S1 @S2": Set row (Y Coordinate) in S1, and column (X Coordinate) in S2.
	/**
	 * "fnt" sets configurations of font. "fnt @S1 @S2":
	 * The font width in S1 (max is 8), the font height in S2 (max is 12).
	 * Caution that this command supports for the keyboard mode. On distance terminals, font configuration does not change.
	 */
	fnt,
	/**
	 * "gpio" does sequential outputting from GPIO. "gpio @S1 @S2":
	 * S1 is the number of raw data array. S2 is the count of repeating, if the count is -1, infinite repeating.
	 * Each bit of raw data represents status of GPIO pins, e.g., Bit[3] represents GPIO 3, 0 as low and 1 as high.
	 * GPIO 2-27 are only available, plus setting out is needed for each GPIO.
	 */
	gpio,
	clrgpio, // Clear outputting from GPIO. "clrgpio @S1": clear all (0) / stay GPIO current status (1) in S1.
	/**
	 * "snd" does sequential outputting sound. "snd @S1 @S2":
	 * S1 is the number of raw data array. S2 is the count of repeating, if the count is -1, infinite repeating.
	 */
	snd,
	intsnd, // Interruption of the main sound by another sound, "intsnd @S1 @S2": Similar to "snd".
	clrsnd, // Clear sound at all. "clrsnd"
	beat, // Change the beat of sound, "beat @S1": Beat is 120000 divided by the integer in S1, e.g., 10000 in S1 sets the beat to 12Hz.
	save, // Save lines to EEPROM, "save @D @S1 @S2": Save lines from D to the chip number in S2 (Bit[2:0]). The length of lines is the value in S1.
	load, // Load lines from EEPROM, jump to the last line to be loaded, "load @D @S1 @S2": Load lines to D from the chip number in S2 (Bit[2:0]). The length of lines is the value in S1.
	_int, // Signed integer calculation, "int @D @S1 <operator> @S2": Range is -2,147,483,648 through 2,147,483,647.
	intu, // Unsigned integer calculation, "intu @D @S1 <operator> @S2": Range is 0x0 through 0xFFFFFFFF.
	and, // Logical AND, "and @D @S1 @S2"
	not, // Logical NOT, "not @D @S1"
	or, // Logical OR, "or @D @S1 @S2"
	xor, // Logical exclusive OR, "xor @D @S1 @S2"
	lsl, // Logical shift left, "lsl @D @S1 @S2"
	lsr, // Logical shift right, "lsr @D @S1 @S2"
	rand, // Random value 0-255, "rand @D"
	_if, // IF statement, "if @S1 <Comparison Symbol> @S2": Compare S1 and S2 as singed integer.
	_for, // FOR loop, "for @S1 @S2": Loop until the value in S1 reaches the value in S2 (inclusively).
	next, // FOR loop, "next @D": return to the first of the loop and increment the value in D.
	_while, // WHILE Loop, "while @S1 <Comparison Symbol> @S2": Compare S1 and S2 as singed integer.
	ifu, // IF statement, "ifu @S1 <Comparison Symbol> @S2": Compare S1 and S2 as unsinged integer.
	whileu, // WHILE loop, "whileu @S1 <Comparison Symbol> @S2": Compare S1 and S2 as unsinged integer.
	intb, // Binary-coded decimal calculation, "intb @D @S1 <operator> @S2": Range is -9,999,999,999,999,999 through 9,999,999,999,999,999.
	ifb, // IF statement, "ifb @S1 <Comparison Symbol> @S2": Compare S1 and S2 as binary-coded decimal.
	whileb, // WHILE loop, "whileb @S1 <Comparison Symbol> @S2": Compare S1 and S2 as binary-coded decimal.
	_float, // Floating point calculation, "float @D @S1 <operator> @S2"
	sqrtf, // Square root, "sqrtf @D @S1": D = S1^1/2.
	radf, // Radian, "radf @D @S1": D = S1 * pi/180.0.
	sinf, // Sine by radian on float, "sin @D @S1": D = sin(S1).
	cosf,
	tanf,
	lnf,
	logf,
	absf,
	negf,
	iff, // IF statement, "iff @S1 <Comparison Symbol> @S2": Compare S1 and S2 as floating point.
	whilef, // WHILE loop, "whilef @S1 <Comparison Symbol> @S2": Compare S1 and S2 as floating point.
	input, // Input to the line, "input @D".
	ifs, // IF statement, "ifs @S1 <Comparison Symbol> @S2": Compare S1 and S2 as string.
	whiles, // WHILE loop, "whiles @S1 <Comparison Symbol> @S2": Compare S1 and S2 as string.
	equal, // Copy, "equal @D @S1".
	append, // Append, "append @D @S1".
	vlen, // Vertical Length, "vlen @D @S1".
	hlen, // Horizontal Length, "hlen @D @S1".
	jmp, // Jump to the line, "jmp @S1": Next line will be the number in S1.
	call, // Jump to the line and store number of current line to the array (Last In First Out) for linking.
	ret, // Return to the line stored in the array for linking.
	push,
	pop,
	ptr, // Store the number of line which has label, "ptr @D .S1": D = line number of S1.
	label, // Re-enumeration of labels from the line, "label".
	clear, // Clear all in every Line then end, "clear".
	run, // Meta Command: Runs script from list number zero
	set // Meta Command: Set Line
} command_list;

/**
 * Four Types of Arguments
 * 1. Label, indicated by ".", must be initialized to hide inaccurate execution, otherwise, the execution will stop, etc.
 * 1. Indirect Label, indicated by ":", must be initialized to hide inaccurate execution, otherwise, the execution will stop, etc.
 * 3. Line Number, indicated by "@".
 * 4. Indirect Number, indicated by "[".
 * Caution that labels should not use characters, "&|^.:@[=!<>+-/%*", for their naming.
 */

/**
 * IF statements (if, ifu, ifb, iff, ifs):
 * IF statements compare two values. If the comparison is false, skip commands in the lines until "else" or "endif".
 * For Example, "if @1 < @2" checks whether the value in line No. 1 is less than the value in line No. 2 as signed integer.
 * If the comparison is true, the target line becomes the next line to execute.
 * If not (false), the next line is not executed and the lines afterwards are not executed until "else" or "endif".
 * "else" switches the pass flag; thus the lines between "else" and "endif" are not executed on true, or the lines are executed on false.
 * Comparison symbols are "== (equal)", "!= (not equal)", "<= (less than or equal)", ">= (greater than or equal)", "< (less than)", and "> (greater than)".
 */

/**
 * WHILE loops (while, whileu, whileb, whilef, whiles):
 * WHILE loops compare two values. If the comparison is false, skip commands in the lines until "endwhile".
 * For Example, "for @1 < @2" checks whether the value in line No. 1 is less than the value in line No. 2 as signed integer.
 * If the comparison is true, the target line becomes the next line to execute.
 * If not (false), the next line is not executed and the lines afterwards are not executed until "endwhile".
 * "endwhile" returns the target lines to the first of the loop if the loop is underway.
 * WHILE loops use the array for linking that "call" and "ret" also use. Caution that the array has limitation to store links.
 * Comparison symbols are "== (equal)", "!= (not equal)", "<= (less than or equal)", ">= (greater than or equal)", "< (less than)", and "> (greater than)".
 */

/**
 * FOR loop (for):
 * FOR loop compares two values as unsigned integer. If the first value is greater than the second value, skip commands in the lines until "next".
 * For Example, "for @1 @2" checks whether the value in line No. 1 is greater than the value in line No. 2 as unsigned integer.
 * If the comparison is false, the target line becomes the next line to execute.
 * If not (true), the next line is not executed and the lines afterwards are not executed until "next".
 * "next @1" returns the target lines to the first of the loop if the loop is underway, and increments the value in line No.1 by 1.
 * FOR loop uses the array for linking that "call" and "ret" also use. Caution that the array has limitation to store links.
 */

/**
 * Type statements (int, intu, intb, float):
 * Type statements Calculate two values.
 * For Example, "int @1 @2 + @3" adds the value in line No. 2 with the value in No. 3 as signed integer. The result is stored in the line No. 1.
 * Operators are "+ (addition)", "- (subtraction)", "* (multiplication)", "/ (division)", and "% (remainder of division)".
 * "& (logical AND)", "| (logical OR)", "^ (logical XOR)", "<< (logical bit shift left)", and ">> (arithemetic/logical bit shift right)" are
 * only available on int and intu.
 */

/**
 * This runtime consists blocks to run scripts.
 */
typedef enum _pipe_list {
	search_command,    // 1. Know Command in The Target Line and Line Numbers Stored Arguments
	enumurate_sources, // 2. Get Sources from Arguments If Conversion from String to Any Other Type Is Needed
	execute_command,   // 3. Execute Command
	go_nextline,       // 4. Go to The Next Line and Back to "search_command"
	termination        // 5. If No Command Exists in The Target Line, Runtime Ends and Wait with Edit Mode
} pipe_list;


typedef union _flex32 {
	char8 s8;
	uchar8 u8;
	int16 s16;
	uint16 u16;
	int32 s32;
	uint32 u32;
	obj object;
	float32 f32;
} flex32;


typedef struct _dictionary {
	obj name;
	obj number;
	uint32 length;
} dictionary;


/* Functions */
String pass_space_label( String target_str );
bool input_keyboard( bool cursor_left_edge );
bool input_keyboard_translation( String kb_str, bool cursor_left_edge );
bool input_keyboard_set_cursor();
bool process_counter();
bool text_sender( String target_str );
bool text_sender_length( String target_str, uint32 length );
bool line_writer( uint32 line_number, String target_str ); 
bool line_clean( String target_str ); 
bool command_print( String target_str ); 
bool command_pict( String true_str, String false_str, obj array, uint32 size_indicator ); 
bool command_label( uint32 start_line_number ); // Label Enumeration
bool console_rollup();
bool init_usb_keyboard( uint32 usb_channel );
bool startup_executer();
void sound_makesilence();
bool compare_signed( String target_str, uint32 length, uint32 status_nzcv );
bool compare_unsigned( String target_str, uint32 length, uint32 status_nzcv );

/* Variables on Global Scope */
bool input_keyboard_continue_flag;
String input_keyboard_kb_str;
bool kb_enable; // Enabling Flag for USB Keyboard Input
int32 ticket_hub; // Use in init_usb_keyboard()
int32 ticket_hid; // Use in init_usb_keyboard()
dictionary label_list;
bool flag_execute;
obj buffer_zero; // Zero Buffer
bool flag_pass; // Use in IF Statements and FOR/WHILE Loops

/* Start Up */
bool startup;
String startup_command1 = "load @0 .a .b\r\0";
String startup_command2 = ".a " startup_load_length "\r\0";
String startup_command3 = ".b 0b00\r\0";
String startup_command4 = "run\r\0";
uint32 startup_length = 4;

int32 _user_start() {

	String str_aloha = "Aloha Calc Version 1.0.0: Copyright (C) 2018 Kenta Ishii\r\n\0";
	String str_serialmode = "\x1B[31mSerial Mode\x1B[0m\r\n\0";
	String str_direction = null;
	obj array_source = heap32_malloc( argument_maxlength );
	obj array_argpointer = heap32_malloc( argument_maxlength );
	obj array_link = heap32_malloc( link_stacksize );
	uint32 array_link_offset = 0;
	obj array_rawdata = heap32_malloc( rawdata_maxlength ); // Two Dimentional Array
	obj buffer_line = heap32_malloc( UART32_UARTMALLOC_MAXROW + 1 / 4 ); // Add for Null Character
	uint32 length_arg = 0;
	uint32 length_temp = 0;
	uint32 src_index = 0;
	uint32 current_line = 0;
	uint32 status_nzcv = 0;
	uint32 stack_offset = stack_offset_default; // Stack offset for "push" and "pop", from the last line decremental order.
	pipe_list pipe_type = search_command;
	command_list command_type = null;
	flex32 var_temp;
	var_temp.u32 = 0;
	flex32 var_temp2;
	var_temp2.u32 = 0;
	flex32 var_temp3;
	var_temp3.u32 = 0;
	flex32 var_temp4;
	var_temp4.u32 = 0;
	flex32 direction;
	direction.u32 = 0;
	label_list.name = heap32_malloc( label_maxlength * label_maxchar ); // Naming Length: Max. 7 bytes (7 Characters and 1 Null Character)
	label_list.number = heap32_malloc( label_maxlength ); // 4 Bytes (32-bit Integer) per Number
	label_list.length = 0;
	direction.s32 = 0;
	String src_str = null;
	String dst_str = null;
	String temp_str = null; // Use for Search Commands and Arguments
	String temp_str2 = null; // Use for Search Arguments with Pointer
	String temp_str_dup = null;

	input_keyboard_continue_flag = false;
	input_keyboard_kb_str = null;

	buffer_zero = heap32_malloc( UART32_UARTMALLOC_MAXROW + 1 / 4 ); // Add for Null Character

	fb32_clear_color( PRINT32_FONT_BACKCOLOR );

	/* Title */
	if ( print32_set_caret( print32_string( str_aloha, FB32_X_CARET, FB32_Y_CARET, str32_strlen( str_aloha ) ) ) ) console_rollup();

	/* Keyboard */

	if ( init_usb_keyboard( 0 ) ) {
		kb_enable = true;
		_uartclient( true );
	} else {
		kb_enable = false;
		if ( print32_set_caret( print32_string( str_serialmode, FB32_X_CARET, FB32_Y_CARET, str32_strlen( str_serialmode ) ) ) ) console_rollup();
		_uarttx( str_aloha, str32_strlen( str_aloha ) );
	}

	/* Sound */

#ifdef __SOUND_I2S
	_sounddecode( _SOUND_INDEX, SND32_I2S, _SOUND_ADJUST );
#else
	_sounddecode( _SOUND_INDEX, SND32_PWM, _SOUND_ADJUST );
#endif

	sound_makesilence();

	/* Startup */

	if ( _gpio_in( 22 ) ) {
		startup = true;
	} else {
		startup = false;
	}

	/* Clear Line No. Zero Because Some Errors May Be Received on It */
	heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );
	_store_32( UART32_UARTINT_COUNT_ADDR, 0 );

	if ( ! _uartsetheap( initial_line ) ) {
		process_counter();
	} else {
		return False;
	}

	flag_execute = false;
	flag_pass = false;
	
	while ( true ) {
		if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) {
			if ( flag_execute ) {
				switch ( pipe_type ) {
					case search_command:

						/*  Pass Spaces and Label*/
						temp_str = pass_space_label( UART32_UARTINT_HEAP );
						temp_str_dup =  temp_str;

						/* Check Pass Flag from IF Statements and FOR/WHILE Loops */
						if ( ! flag_pass ) {

							/* Numeration Process */

							/* Select Command Type */
							if ( str32_strmatch( temp_str, 1, "*\0", 1 ) ) {
								/* Comment Will Be Immdiately Skipped */
								command_type = null;
								length_arg = 0;
								pipe_type = go_nextline;
							} else if ( str32_strmatch( temp_str, 5, "endif\0", 5 ) ) {
								command_type = endif;
								length_arg = 0;
								pipe_type = go_nextline;
								//flag_pass = false;
							} else if ( str32_strmatch( temp_str, 8, "endwhile\0", 8 ) ) {
								command_type = endwhile;
								length_arg = 0;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 3, "end\0", 3 ) ) {
								command_type = null;
								length_arg = 0;
								pipe_type = termination;
							} else if ( str32_strmatch( temp_str, 4, "else\0", 4 ) ) {
								command_type = _else;
								length_arg = 0;
								pipe_type = go_nextline;
								flag_pass = ! flag_pass;
							} else if ( str32_strmatch( temp_str, 5, "break\0", 5 ) ) {
								command_type = _break;
								length_arg = 0;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 6, "print \0", 6 ) ) {
								command_type = print;
								length_arg = 1;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 6, "sleep \0", 6 ) ) {
								command_type = sleep;
								length_arg = 1;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 6, "stime \0", 6 ) ) {
								command_type = stime;
								length_arg = 7;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 6, "gtime \0", 6 ) ) {
								command_type = gtime;
								length_arg = 8;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 4, "arr \0", 4 ) ) {
								command_type = arr;
								length_arg = 4;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Destination to Be Stored Number of Raw Data Array
							} else if ( str32_strmatch( temp_str, 5, "free \0", 5 ) ) {
								command_type = free;
								length_arg = 1;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 5, "pict \0", 5 ) ) {
								command_type = pict;
								length_arg = 4;
								pipe_type = enumurate_sources;
								src_index = 2; // Only Last Two Is Needed to Translate to Integer
							} else if ( str32_strmatch( temp_str, 4, "csr \0", 4 ) ) {
								command_type = csr;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 4, "fnt \0", 4 ) ) {
								command_type = fnt;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 5, "gpio \0", 5 ) ) {
								command_type = gpio;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 8, "clrgpio \0", 8 ) ) {
								command_type = clrgpio;
								length_arg = 1;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 4, "snd \0", 4 ) ) {
								command_type = snd;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 7, "intsnd \0", 7 ) ) {
								command_type = intsnd;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 6, "clrsnd\0", 6 ) ) {
								command_type = clrsnd;
								length_arg = 0;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 5, "beat \0", 5 ) ) {
								command_type = beat;
								length_arg = 1;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 5, "save \0", 5 ) ) {
								command_type = save;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Start Point
							} else if ( str32_strmatch( temp_str, 5, "load \0", 5 ) ) {
								command_type = load;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Start Point
							} else if ( str32_strmatch( temp_str, 4, "int \0", 4 ) ) {
								command_type = _int;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "intu \0", 5 ) ) {
								command_type = intu;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 4, "and \0", 4 ) ) {
								command_type = and;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 4, "not \0", 4 ) ) {
								command_type = not;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 3, "or \0", 3 ) ) {
								command_type = or;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 4, "xor \0", 4 ) ) {
								command_type = xor;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 4, "lsl \0", 4 ) ) {
								command_type = lsl;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 4, "lsr \0", 4 ) ) {
								command_type = lsr;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "rand \0", 5 ) ) {
								command_type = rand;
								length_arg = 1;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 3, "if \0", 3 ) ) {
								command_type = _if;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0; // No Direction
							} else if ( str32_strmatch( temp_str, 4, "for \0", 4 ) ) {
								command_type = _for;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0;
							} else if ( str32_strmatch( temp_str, 5, "next \0", 5 ) ) {
								command_type = next;
								length_arg = 1;
								pipe_type = enumurate_sources;
								src_index = 0; // 0 is Direction and Source
							} else if ( str32_strmatch( temp_str, 6, "while \0", 6 ) ) {
								command_type = _while;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0; // No Direction
							} else if ( str32_strmatch( temp_str, 4, "ifu \0", 4 ) ) {
								command_type = ifu;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0; // No Direction
							} else if ( str32_strmatch( temp_str, 7, "whileu \0", 7 ) ) {
								command_type = whileu;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0; // No Direction
							} else if ( str32_strmatch( temp_str, 5, "intb \0", 5 ) ) {
								command_type = intb;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 4, "ifb \0", 4 ) ) {
								command_type = ifb;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0; // No Direction
							} else if ( str32_strmatch( temp_str, 7, "whileb \0", 7 ) ) {
								command_type = whileb;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0; // No Direction
							} else if ( str32_strmatch( temp_str, 6, "float \0", 6 ) ) {
								command_type = _float;
								length_arg = 3;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 6, "sqrtf \0", 6 ) ) {
								command_type = sqrtf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "radf \0", 5 ) ) {
								command_type = radf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "sinf \0", 5 ) ) {
								command_type = sinf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "cosf \0", 5 ) ) {
								command_type = cosf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "tanf \0", 5 ) ) {
								command_type = tanf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 4, "lnf \0", 4 ) ) {
								command_type = lnf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "logf \0", 5 ) ) {
								command_type = logf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "absf \0", 5 ) ) {
								command_type = absf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 5, "negf \0", 5 ) ) {
								command_type = negf;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 1; // 0 is Direction
							} else if ( str32_strmatch( temp_str, 4, "iff \0", 4 ) ) {
								command_type = iff;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0; // No Direction
							} else if ( str32_strmatch( temp_str, 7, "whilef \0", 7 ) ) {
								command_type = whilef;
								length_arg = 2;
								pipe_type = enumurate_sources;
								src_index = 0; // No Direction
							} else if ( str32_strmatch( temp_str, 6, "input \0", 6 ) ) {
								command_type = input;
								length_arg = 1;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 4, "ifs \0", 4 ) ) {
								command_type = ifs;
								length_arg = 2;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 7, "whiles \0", 7 ) ) {
								command_type = whiles;
								length_arg = 2;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 6, "equal \0", 6 ) ) {
								command_type = equal;
								length_arg = 2;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 7, "append \0", 7 ) ) {
								command_type = append;
								length_arg = 2;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 5, "vlen \0", 5 ) ) {
								command_type = vlen;
								length_arg = 2;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 5, "hlen \0", 5 ) ) {
								command_type = hlen;
								length_arg = 2;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 4, "jmp \0", 4 ) ) {
								command_type = jmp;
								length_arg = 1;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 5, "call \0", 5 ) ) {
								command_type = call;
								length_arg = 1;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 3, "ret\0", 3 ) ) {
								command_type = ret;
								length_arg = 0;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 5, "push \0", 5 ) ) {
								command_type = push;
								length_arg = 1;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 4, "pop \0", 4 ) ) {
								command_type = pop;
								length_arg = 1;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 4, "ptr \0", 4 ) ) {
								command_type = ptr;
								length_arg = 2;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 5, "label\0", 5 ) ) {
								command_type = label;
								length_arg = 0;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 5, "clear\0", 5 ) ) {
								/* Clear All Lines */
								for (uint32 i = 0; i < UART32_UARTMALLOC_LENGTH; i++ ) {
									_uartsetheap( i );
									heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );
								}
								for ( uint32 i = 0; i < rawdata_maxlength; i++ ) {
									var_temp.u32 = _load_32( array_rawdata + 4 * i );
									heap32_mfree( var_temp.u32 );
								}
								heap32_mfill( array_rawdata, 0 );
								command_type = null;
								length_arg = 0;
								pipe_type = termination;
							} else {
								command_type = null;
								length_arg = 0;
								pipe_type = go_nextline;
							}

						} else {

							if ( str32_strmatch( temp_str, 4, "else\0", 4 ) ) {
								command_type = _else;
								length_arg = 0;
								pipe_type = go_nextline;
								flag_pass = ! flag_pass;
							} else if ( str32_strmatch( temp_str, 5, "endif\0", 5 ) ) {
								command_type = endif;
								length_arg = 0;
								pipe_type = go_nextline;
								flag_pass = false;
							} else if ( str32_strmatch( temp_str, 8, "endwhile\0", 8 ) ) {
								command_type = endwhile;
								length_arg = 0;
								pipe_type = execute_command;
							} else if ( str32_strmatch( temp_str, 5, "next \0", 5 ) ) {
								command_type = next;
								length_arg = 1;
								pipe_type = enumurate_sources;
								src_index = 0; // 0 is Direction and Source
							} else {
								command_type = null;
								length_arg = 0;
								pipe_type = go_nextline;
							}

						}

						current_line = UART32_UARTMALLOC_NUMBER;

						for ( uint32 i = 0; i < length_arg; ) {
							length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
							if ( length_temp == -1 ) break; // Reaching End of Script of Line
							temp_str += length_temp;
							temp_str++; // Next of Space
							while ( str32_charsearch( temp_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space
								temp_str++;
							}
							if ( str32_charsearch( temp_str, 1, 0x2E ) != -1 ) { // Ascii Code of Period
								/* Label Argument Indicated by ".<NAME>" */
								temp_str++; // Next of Character
								length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = str32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = 0;
								for ( uint32 j = 0; j < label_list.length; j++ ) {
									temp_str2 = (String)label_list.name + 4 * label_maxchar * j;
									if ( str32_strmatch( temp_str2, str32_strlen( temp_str2 ), temp_str, length_temp ) ) {
										var_temp.u32 = _load_32( label_list.number + 4 * j );
										break; // Break For Loop
									}
								}
								_store_32( array_argpointer + 4 * i,  var_temp.u32 );
								i++;
							} else if ( str32_charsearch( temp_str, 1, 0x3A ) != -1 ) { // Ascii Code of Colon
								/* Indiret Label Argument Indicated by ":<NAME>" */
								temp_str++; // Next of Character
								length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = str32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = 0;
								for ( uint32 j = 0; j < label_list.length; j++ ) {
									temp_str2 = (String)label_list.name + 4 * label_maxchar * j;
									if ( str32_strmatch( temp_str2, str32_strlen( temp_str2 ), temp_str, length_temp ) ) {
										var_temp.u32 = _load_32( label_list.number + 4 * j );
										break; // Break For Loop
									}
								}
								if ( _uartsetheap( var_temp.u32 ) ) _uartsetheap( initial_line );
								/*  Pass Spaces and Label*/
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								var_temp2.u32 = cvt32_string_to_int32( temp_str2, str32_strlen( temp_str2 ) );
								_store_32( array_argpointer + 4 * i,  var_temp2.u32 );
								i++;
							} else if ( str32_charsearch( temp_str, 1, 0x40 ) != -1 ) { // Ascii Code of @
								/* Direct Argument Indicated by "@N" */
								temp_str++; // Next of Character
								length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = str32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = cvt32_string_to_int32( temp_str, length_temp );
								_store_32( array_argpointer + 4 * i,  var_temp.u32 );
								i++;
							} else if ( str32_charsearch( temp_str, 1, 0x5B ) != -1 ) { // Ascii Code of [ (Square Bracket Left)
								/* Indirect Argument (Pointer) Indicated by "[N" */
								temp_str++; // Next of Character
								length_temp = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
								if ( length_temp == -1 ) length_temp = str32_strlen( temp_str ); // Ascii Code of Null, for Last Variable
								var_temp.u32 = cvt32_string_to_int32( temp_str, length_temp );
								if ( _uartsetheap( var_temp.u32 ) ) _uartsetheap( initial_line );
								/*  Pass Spaces and Label*/
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								var_temp2.u32 = cvt32_string_to_int32( temp_str2, str32_strlen( temp_str2 ) );
								_store_32( array_argpointer + 4 * i,  var_temp2.u32 );
								i++;
							} else { // Nothing of . : @ [
								temp_str++; // Next of Character
							}
						}

						break;

					case enumurate_sources:

						if ( _uartsetheap( _load_32( array_argpointer + 4 * src_index ) ) ) _uartsetheap( initial_line );

						/*  Pass Spaces and Label*/
						temp_str = pass_space_label( UART32_UARTINT_HEAP );
						if ( command_type >= _float ) { // Type of Single Precision Float
							var_temp.f32 = cvt32_string_to_float32( temp_str, str32_strlen( temp_str ) );
							if ( var_temp.s32 == -1 ) {
								var_temp.s32 = cvt32_string_to_int32( temp_str, str32_strlen( temp_str ) );
								var_temp.f32 = vfp32_s32tof32( var_temp.s32 );
							}
							_store_32( array_source + 4 * src_index, var_temp.s32 );
						} else if ( command_type >= intb ){ // Type of Binary-coded Decimal
							var_temp.u32 = str32_charindex( temp_str, 0x2E ); // Ascii Code of Period
							if ( var_temp.u32 == -1 ) var_temp.u32 = str32_strlen( temp_str );
							_store_32( array_source + 8 * src_index, (obj)temp_str );
							_store_32( array_source + 8 * src_index + 4, var_temp.u32 );
						} else { // Type of 32-bit Signed/Unsigned Integer
							if( str32_charindex( temp_str, 0x2E ) != -1 ) { // Ascii Code of Period
								var_temp.f32 = cvt32_string_to_float32( temp_str, str32_strlen( temp_str ) );
								var_temp.s32 = vfp32_f32tos32( var_temp.f32 );
							} else {
								var_temp.s32 = cvt32_string_to_int32( temp_str, str32_strlen( temp_str ) );
							}
							_store_32( array_source + 4 * src_index, var_temp.s32 );
						}

						src_index++;
						if ( src_index >= length_arg ) pipe_type = execute_command;

						break;

					case execute_command:

						switch ( command_type ) {
							case endwhile:
								if ( ! flag_pass ) { // Under Looping
									if ( array_link_offset <= 0 ) break;
									array_link_offset--;
									current_line = _load_32( array_link + array_link_offset * 4 ) - 1;
								} else { // At End of Loop
									flag_pass = false;
								}

								break;
							case _break:
								if ( ! flag_pass ) { // Under Looping
									if ( array_link_offset <= 0 ) break;
									array_link_offset--;
									flag_pass = true;
								}

								break;
							case print:
								var_temp.u32 = _load_32( array_argpointer );
								if ( _uartsetheap( var_temp.u32 ) ) break;
								command_print( UART32_UARTINT_HEAP );

								break;
							case sleep:
								_sleep( _load_32( array_source ) );

								break;
							case stime:
								_calender_init(
										_load_32( array_source ),
										_load_8( array_source + 4 ),
										_load_8( array_source + 8 )
										);

								_clock_init(
										_load_8( array_source + 12 ),
										_load_8( array_source + 16 ),
										_load_8( array_source + 20 ),
										_load_32( array_source + 24 )
										);

								break;
							case gtime:
								_get_time();
								str_direction = cvt32_int32_to_string_deci( (int32)CLK32_YEAR, 1, 0 );
								line_writer( _load_32( array_argpointer ), str_direction );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								str_direction = cvt32_int32_to_string_deci( (int32)CLK32_MONTH, 1, 0 );
								line_writer( _load_32( array_argpointer + 4 ), str_direction );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								str_direction = cvt32_int32_to_string_deci( (int32)CLK32_WEEK, 1, 0 );
								line_writer( _load_32( array_argpointer + 8 ), str_direction );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								str_direction = cvt32_int32_to_string_deci( (int32)CLK32_MONTHDAY, 1, 0 );
								line_writer( _load_32( array_argpointer + 12 ), str_direction );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								str_direction = cvt32_int32_to_string_deci( (int32)CLK32_HOUR, 1, 0 );
								line_writer( _load_32( array_argpointer + 16 ), str_direction );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								str_direction = cvt32_int32_to_string_deci( (int32)CLK32_MINUTE, 1, 0 );
								line_writer( _load_32( array_argpointer + 20 ), str_direction );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								str_direction = cvt32_int32_to_string_deci( (int32)CLK32_SECOND, 1, 0 );
								line_writer( _load_32( array_argpointer + 24 ), str_direction );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								str_direction = cvt32_int32_to_string_deci( (int32)CLK32_USECOND, 1, 0 );
								line_writer( _load_32( array_argpointer + 28 ), str_direction );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								break;
							case arr:
								for ( uint32 i = 0; i < rawdata_maxlength; i++ ) {
									var_temp.u32 = _load_32( array_rawdata + 4 * i );
									if ( var_temp.u32 == 0 ) {
										var_temp.u32 = _load_32( array_source + 4 );
										var_temp2.u32 = _load_32( array_source + 8 );
										var_temp2.u32 += var_temp.u32;
										if ( _uartsetheap( var_temp.u32 ) ) break;
										dst_str = pass_space_label( UART32_UARTINT_HEAP );
										var_temp.u32++;
										for ( uint32 j = var_temp.u32; j < var_temp2.u32; j++ ) {
											temp_str = dst_str;
											if ( _uartsetheap( j ) ) break;
											temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
											dst_str = str32_strcat( temp_str, temp_str2 );	
											if ( j != var_temp.u32 ) { // No Initial Round
												heap32_mfree( (obj)temp_str );
											}
										}

										var_temp.u32 = cvt32_string_to_intarray( dst_str, str32_strlen( dst_str ), _load_32( array_source + 12 ) );
//print32_debug( var_temp.u32, 400, 400 );
										_store_32( array_rawdata + 4 * i, var_temp.u32 );
										str_direction = cvt32_int32_to_string_deci( i, 1, 0 );
										break;
									}
								}

								break;
							case free:
								var_temp.u32 = _load_32( array_source );
								if ( var_temp.u32 >= rawdata_maxlength ) break;
								var_temp2.u32 = _load_32( array_rawdata + 4 * var_temp.u32 );
//print32_debug( var_temp2.u32, 400, 436 );
								heap32_mfree( var_temp2.u32 );
								_store_32( array_rawdata + 4 * var_temp.u32, 0 );

								break;
							case pict:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break; 
								temp_str = pass_space_label( UART32_UARTINT_HEAP );
								if ( _uartsetheap( _load_32( array_argpointer + 4 ) ) ) break; 
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								var_temp.u32 = _load_32( array_source + 8 );
								if ( var_temp.u32 >=  rawdata_maxlength ) break;
								var_temp.object = _load_32( array_rawdata + 4 * var_temp.u32 );
								if ( var_temp.object == 0 ) break;
								var_temp2.u32 = _load_32( array_source + 12 );

								command_pict( temp_str, temp_str2, var_temp.object, var_temp2.u32 ); 

								break;
							case csr:
								text_sender( "\x1B[\0" );

								var_temp.u32 = _load_32( array_source );
								str_direction = cvt32_int32_to_string_deci( var_temp.u32, 1, 0 );
								text_sender( str_direction );
								text_sender( ";\0" );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								var_temp.u32 = _load_32( array_source + 4 );
								str_direction = cvt32_int32_to_string_deci( var_temp.u32, 1, 0 );
								text_sender( str_direction );
								text_sender( "H\0" );
								str_direction = (String)heap32_mfree( (obj)str_direction );

								break;
							case fnt:
								PRINT32_FONT_WIDTH = _load_32( array_source );
								PRINT32_FONT_HEIGHT = _load_32( array_source + 4 );
								if ( PRINT32_FONT_WIDTH > 8 ) PRINT32_FONT_WIDTH = 8;
								if ( PRINT32_FONT_HEIGHT > 12 ) PRINT32_FONT_WIDTH = 12;

								break;
							case gpio:
								var_temp.u32 = _load_32( array_source );
								if ( var_temp.u32 >=  rawdata_maxlength ) break;
								var_temp.object = _load_32( array_rawdata + 4 * var_temp.u32 );
								var_temp2.s32 = _load_32( array_source + 4 );
								_gpioset( (gpio_sequence*)var_temp.object, gpio32_gpiolen( (gpio_sequence*)var_temp.object ) , 0, var_temp2.s32 );

								break;
							case clrgpio:
								_gpioclear( gpio_output, _load_32( array_source ) );

								break;
							case snd:
								var_temp.u32 = _load_32( array_source );
								if ( var_temp.u32 >=  rawdata_maxlength ) break;
								var_temp.object = _load_32( array_rawdata + 4 * var_temp.u32 );
								var_temp2.s32 = _load_32( array_source + 4 );

								_soundset( (music_code*)var_temp.object, snd32_musiclen( (music_code*)var_temp.object ) , 0, var_temp2.s32 );

								break;
							case intsnd:
								var_temp.u32 = _load_32( array_source );
								if ( var_temp.u32 >=  rawdata_maxlength ) break;
								var_temp.object = _load_32( array_rawdata + 4 * var_temp.u32 );
								var_temp2.s32 = _load_32( array_source + 4 );

								_soundinterrupt( (music_code*)var_temp.object, snd32_musiclen( (music_code*)var_temp.object ) , 0, var_temp2.s32 );

								break;
							case clrsnd:
								sound_makesilence();

								break;
							case beat:
								var_temp.u32 = _load_32( array_source );
								_armtimer_reload( var_temp.u32 - 1 );

								break;
							case save:
								var_temp.u32 = 0; // Memory Address
								var_temp2.u32 = _load_32( array_argpointer ); // First Line Number to Save
								if ( var_temp2.u32 < initial_line ) var_temp2.u32 = initial_line;
								var_temp3.u32 = _load_32( array_source + 4 ); // Length of Lines to Save
								var_temp3.u32 += var_temp2.u32; // End Point
								if ( var_temp3.u32 > UART32_UARTMALLOC_LENGTH ) var_temp3.u32 = UART32_UARTMALLOC_LENGTH;
								var_temp4.u32 = _load_32( array_source + 8 ); // Chip Select
								for ( uint32 i = var_temp2.u32; i < var_temp3.u32; i++ ) {
									_uartsetheap( i );
									if ( _romwrite_i2c( (obj)UART32_UARTINT_HEAP, var_temp4.u32, var_temp.u32, str32_strlen( UART32_UARTINT_HEAP ) + 1 ) ) break; // Add One for Null
									var_temp.u32 += UART32_UARTMALLOC_MAXROW + 1; // Add One for Null Character
								}

								break;
							case load:
								var_temp.u32 = 0; // Memory Address
								var_temp2.u32 = _load_32( array_argpointer ); // First Line Number to Save
								if ( var_temp2.u32 < initial_line ) var_temp2.u32 = initial_line;
								var_temp3.u32 = _load_32( array_source + 4 ); // Length of Lines to Save
								var_temp3.u32 += var_temp2.u32; // End Point
								if ( var_temp3.u32 > UART32_UARTMALLOC_LENGTH ) var_temp3.u32 = UART32_UARTMALLOC_LENGTH;
								var_temp4.u32 = _load_32( array_source + 8 ); // Chip Select
								for ( uint32 i = var_temp2.u32; i < var_temp3.u32; i++ ) {
									_uartsetheap( i );
									if ( _romread_i2c( buffer_line, var_temp4.u32, var_temp.u32, UART32_UARTMALLOC_MAXROW ) ) break; // Stay Null Character at End
									heap32_mcopy( (obj)UART32_UARTINT_HEAP, 0, buffer_line, 0, str32_strlen( (String)buffer_line ) + 1 ); // Add Null Character
									line_clean( UART32_UARTINT_HEAP );
									var_temp.u32 += UART32_UARTMALLOC_MAXROW + 1; // Add One for Null Character
								}
								current_line = UART32_UARTMALLOC_NUMBER - 1; // Next Line Becomes Last Line to Be Loaded

								break;
							case _int:
								length_temp = str32_strlen( temp_str_dup );

								if ( str32_strsearch( temp_str_dup, length_temp, "+ \0", 2 ) != -1 ) {
									direction.s32 = _load_32( array_source + 4 ) + _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "- \0", 2 ) != -1 ) {
									direction.s32 = _load_32( array_source + 4 ) - _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "* \0", 2 ) != -1 ) {
									direction.s32 = arm32_mul( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "/ \0", 2 ) != -1 ) {
									direction.s32 = arm32_sdiv( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "% \0", 2 ) != -1 ) {
									direction.s32 = arm32_srem( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "& \0", 2 ) != -1 ) {
									direction.s32 = _load_32( array_source + 4 ) & _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "| \0", 2 ) != -1 ) {
									direction.s32 = _load_32( array_source + 4 ) | _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "^ \0", 2 ) != -1 ) {
									direction.s32 = _load_32( array_source + 4 ) ^ _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "<< \0", 3 ) != -1 ) {
									direction.s32 = _load_32( array_source + 4 ) << _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, ">> \0", 3 ) != -1 ) {
									direction.s32 = _load_32( array_source + 4 ) >> _load_32( array_source + 8 );

								}

								str_direction = cvt32_int32_to_string_deci( direction.s32, 1, 1 );
								break;
							case intu:
								length_temp = str32_strlen( temp_str_dup );

								if ( str32_strsearch( temp_str_dup, length_temp, "+ \0", 2 ) != -1 ) {
									direction.u32 = _load_32( array_source + 4 ) + _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "- \0", 2 ) != -1 ) {
									direction.u32 = _load_32( array_source + 4 ) - _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "* \0", 2 ) != -1 ) {
									direction.u32 = arm32_mul( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "/ \0", 2 ) != -1 ) {
									direction.u32 = arm32_udiv( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "% \0", 2 ) != -1 ) {
									direction.u32 = arm32_urem( _load_32( array_source + 4 ), _load_32( array_source + 8 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "& \0", 2 ) != -1 ) {
									direction.u32 = _load_32( array_source + 4 ) & _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "| \0", 2 ) != -1 ) {
									direction.u32 = _load_32( array_source + 4 ) | _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "^ \0", 2 ) != -1 ) {
									direction.u32 = _load_32( array_source + 4 ) ^ _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "<< \0", 3 ) != -1 ) {
									direction.u32 = _load_32( array_source + 4 ) << _load_32( array_source + 8 );

								} else if ( str32_strsearch( temp_str_dup, length_temp, ">> \0", 3 ) != -1 ) {
									direction.u32 = _load_32( array_source + 4 ) >> _load_32( array_source + 8 );

								}

								str_direction = cvt32_int32_to_string_hexa( direction.u32, 1, 0, 1 );
								break;
							case and:
								direction.u32 = _load_32( array_source + 4 ) & _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case not:
								direction.u32 = ~( _load_32( array_source + 4 ) );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case or:
								direction.u32 = _load_32( array_source + 4 ) | _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case xor:
								direction.u32 = _load_32( array_source + 4 ) ^ _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case lsl:
								direction.u32 = _load_32( array_source + 4 ) << _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case lsr:
								direction.u32 = _load_32( array_source + 4 ) >> _load_32( array_source + 8 );
								str_direction = cvt32_int32_to_string_bin( direction.u32, 1, 1 );
								break;
							case rand:
								direction.u32 =  _random( 255 );
								str_direction = cvt32_int32_to_string_deci( direction.u32, 1, 0 );
								break;
							case _if:
								status_nzcv = arm32_cmp( _load_32( array_source ), _load_32( array_source + 4 ) );
								length_temp = str32_strlen( temp_str_dup );
								flag_pass = compare_signed( temp_str_dup, length_temp, status_nzcv );

								break;

							case _for:
								status_nzcv = arm32_cmp( _load_32( array_source ), _load_32( array_source + 4 ) );
								/* Unsigned Greater Than: C Bit[29] == 1 && Z Bit[30] == 0 */
								if ( ( status_nzcv & 0x20000000 ) && ( ! ( status_nzcv & 0x40000000 ) ) ) {
									flag_pass = true;
								} else {
									flag_pass = false;
									_store_32( array_link + array_link_offset * 4, current_line );
									array_link_offset++;
									if ( array_link_offset >= link_stacksize ) array_link_offset = link_stacksize - 1;
								}

								break;

							case next:
								if ( ! flag_pass ) { // Under Looping
									if ( array_link_offset <= 0 ) break;
									array_link_offset--;
									current_line = _load_32( array_link + array_link_offset * 4 ) - 1;
									direction.u32 =  _load_32( array_source ) + 1;
									str_direction = cvt32_int32_to_string_deci( direction.u32, 1, 0 );
								} else { // At End of Loop
									flag_pass = false;
								}

								break;

							case _while:
								status_nzcv = arm32_cmp( _load_32( array_source ), _load_32( array_source + 4 ) );
								length_temp = str32_strlen( temp_str_dup );
								flag_pass = compare_signed( temp_str_dup, length_temp, status_nzcv );

								if ( ! flag_pass ) {
									_store_32( array_link + array_link_offset * 4, current_line );
									array_link_offset++;
									if ( array_link_offset >= link_stacksize ) array_link_offset = link_stacksize - 1;
								}

								break;
							case ifu:
								status_nzcv = arm32_cmp( _load_32( array_source ), _load_32( array_source + 4 ) );
								length_temp = str32_strlen( temp_str_dup );
								flag_pass = compare_unsigned( temp_str_dup, length_temp, status_nzcv );

								break;
							case whileu:
								status_nzcv = arm32_cmp( _load_32( array_source ), _load_32( array_source + 4 ) );
								length_temp = str32_strlen( temp_str_dup );
								flag_pass = compare_unsigned( temp_str_dup, length_temp, status_nzcv );

								if ( ! flag_pass ) {
									_store_32( array_link + array_link_offset * 4, current_line );
									array_link_offset++;
									if ( array_link_offset >= link_stacksize ) array_link_offset = link_stacksize - 1;
								}

								break;
							case intb:
								length_temp = str32_strlen( temp_str_dup );

								if ( str32_strsearch( temp_str_dup, length_temp, "+ \0", 2 ) != -1 ) {
									str_direction = bcd32_badd( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "- \0", 2 ) != -1 ) {
									str_direction = bcd32_bsub( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "* \0", 2 ) != -1 ) {
									str_direction = bcd32_bmul( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "/ \0", 2 ) != -1 ) {
									str_direction = bcd32_bdiv( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "% \0", 2 ) != -1 ) {
									str_direction = bcd32_brem( (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ), (String)_load_32( array_source + 16 ), _load_32( array_source + 20 ) );

								}

								break;
							case ifb:
								status_nzcv = bcd32_bcmp( (String)_load_32( array_source ), _load_32( array_source + 4 ), (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ) );
								length_temp = str32_strlen( temp_str_dup );
								flag_pass = compare_signed( temp_str_dup, length_temp, status_nzcv );

								break;
							case whileb:
								status_nzcv = bcd32_bcmp( (String)_load_32( array_source ), _load_32( array_source + 4 ), (String)_load_32( array_source + 8 ), _load_32( array_source + 12 ) );
								length_temp = str32_strlen( temp_str_dup );
								flag_pass = compare_signed( temp_str_dup, length_temp, status_nzcv );

								if ( ! flag_pass ) {
									_store_32( array_link + array_link_offset * 4, current_line );
									array_link_offset++;
									if ( array_link_offset >= link_stacksize ) array_link_offset = link_stacksize - 1;
								}

								break;
							case _float:
								length_temp = str32_strlen( temp_str_dup );

								if ( str32_strsearch( temp_str_dup, length_temp, "+ \0", 2 ) != -1 ) {
									direction.f32 = vfp32_fadd( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "- \0", 2 ) != -1 ) {
									direction.f32 = vfp32_fsub( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "* \0", 2 ) != -1 ) {
									direction.f32 = vfp32_fmul( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );

								} else if ( str32_strsearch( temp_str_dup, length_temp, "/ \0", 2 ) != -1 ) {
									direction.f32 = vfp32_fdiv( vfp32_hexatof32( _load_32( array_source + 4 ) ), vfp32_hexatof32( _load_32( array_source + 8 ) ) );

								}

								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case sqrtf:
								direction.f32 = vfp32_fsqrt( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case radf:
								direction.f32 = math32_degree_to_radian( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case sinf:
								direction.f32 = math32_sin( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case cosf:
								direction.f32 = math32_cos( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case tanf:
								direction.f32 = math32_tan( vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case lnf:
								direction.f32 = math32_ln( ( vfp32_hexatof32( _load_32( array_source + 4 ) ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case logf:
								direction.f32 = math32_log( ( vfp32_hexatof32( _load_32( array_source + 4 ) ) ) );
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case absf:
								direction.u32 = _load_32( array_source + 4 ) & ~(0x80000000); // ~ is Not (Inverter), Sign Bit[31] Clear
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );
								break;
							case negf:
								direction.u32 = _load_32( array_source + 4 ) | 0x80000000; // Sign Bit[31] Set
								str_direction = cvt32_float32_to_string( direction.f32, 1, 7, 0 );

								break;
							case iff:
								status_nzcv = vfp32_fcmp( vfp32_hexatof32( _load_32( array_source ) ), vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								length_temp = str32_strlen( temp_str_dup );
								flag_pass = compare_signed( temp_str_dup, length_temp, status_nzcv );

								break;
							case whilef:
								status_nzcv = vfp32_fcmp( vfp32_hexatof32( _load_32( array_source ) ), vfp32_hexatof32( _load_32( array_source + 4 ) ) );
								length_temp = str32_strlen( temp_str_dup );
								flag_pass = compare_signed( temp_str_dup, length_temp, status_nzcv );

								if ( ! flag_pass ) {
									_store_32( array_link + array_link_offset * 4, current_line );
									array_link_offset++;
									if ( array_link_offset >= link_stacksize ) array_link_offset = link_stacksize - 1;
								}

								break;
							case input:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								dst_str = UART32_UARTINT_HEAP;
								if ( _uartsetheap( UART32_UARTMALLOC_LENGTH - 1 ) ) break;
								src_str = UART32_UARTINT_HEAP;
								heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 );

								_store_32( UART32_UARTINT_COUNT_ADDR, 0 );
								_store_32( UART32_UARTINT_BUSY_ADDR, 0 );

								while ( true ) {
									input_keyboard( true );
									if ( _load_32( UART32_UARTINT_BUSY_ADDR ) ) break;
								}

								/* Pass Spaces and Label */
								temp_str = pass_space_label( dst_str );
								var_temp.u32 = temp_str - dst_str;
								var_temp2.u32 = str32_strlen( src_str );
								if ( var_temp2.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp2.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
								heap32_mcopy( (obj)dst_str, var_temp.u32, (obj)src_str, 0, var_temp2.u32 + 1 ); // Add Null Character
								line_clean( dst_str );
								heap32_mfill( (obj)UART32_UARTINT_HEAP, 0 ); // Clear Line to Be Used as Input Buffer

								break;
							case ifs:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								temp_str = pass_space_label( UART32_UARTINT_HEAP );
								if ( _uartsetheap( _load_32( array_argpointer + 4 ) ) ) break;
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								status_nzcv = 0;
								if ( str32_strmatch( temp_str, str32_strlen( temp_str ), temp_str2, str32_strlen( temp_str2 ) ) ) {
									/* Equal; Z Bit[30] == 1 */
									status_nzcv |= 0x40000000;
								}

								flag_pass = compare_signed( temp_str_dup, length_temp, status_nzcv );

								break;
							case whiles:
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								temp_str = pass_space_label( UART32_UARTINT_HEAP );
								if ( _uartsetheap( _load_32( array_argpointer + 4 ) ) ) break;
								temp_str2 = pass_space_label( UART32_UARTINT_HEAP );
								status_nzcv = 0;
								if ( str32_strmatch( temp_str, str32_strlen( temp_str ), temp_str2, str32_strlen( temp_str2 ) ) ) {
									/* Equal; Z Bit[30] == 1 */
									status_nzcv |= 0x40000000;
								}

								flag_pass = compare_signed( temp_str_dup, length_temp, status_nzcv );

								if ( ! flag_pass ) {
									_store_32( array_link + array_link_offset * 4, current_line );
									array_link_offset++;
									if ( array_link_offset >= link_stacksize ) array_link_offset = link_stacksize - 1;
								}

								break;
							case equal:
								/* Destination */
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								dst_str = UART32_UARTINT_HEAP;
								/* Get Start Point to Copy */
								temp_str = pass_space_label( dst_str );
								var_temp.u32 = temp_str - dst_str;

								/* Source String */
								var_temp2.u32 =_load_32( array_argpointer + 4 );
								if ( var_temp2.u32 ) { // If Not Null, That Is, Having Second Argument with Label
									if ( _uartsetheap( var_temp2.u32 ) ) break;
									src_str = UART32_UARTINT_HEAP;
									/* Pass Spaces and Label of Source String */
									temp_str = pass_space_label( src_str );
									var_temp2.u32 = temp_str - src_str;
									var_temp3.u32 = str32_strlen( temp_str );
								} else { // If Null, That Is, Having Immediate or Nothing of Second Argument
									if ( _uartsetheap( current_line ) ) break;
									src_str = UART32_UARTINT_HEAP;
									/* Pass Spaces, Labels, Command of Source String */
									length_temp = str32_charindex( temp_str_dup, 0x20 ); // Ascii Code of Space
									if ( length_temp == -1 ) break; // Reaching End of Script of Line
									temp_str_dup += length_temp; // Beyond Command
									temp_str_dup++; // Next of Space
									temp_str = pass_space_label( temp_str_dup );
									var_temp2.u32 = temp_str - src_str;
									var_temp3.u32 = str32_strlen( temp_str );
								}

								if ( var_temp3.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp3.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
								heap32_mcopy( (obj)dst_str, var_temp.u32, (obj)src_str, var_temp2.u32, var_temp3.u32 + 1 ); // Add Null Character
								line_clean( dst_str );

								break;
							case append:
								/* Destination */
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								dst_str = UART32_UARTINT_HEAP;
								/* Get Start Point to Copy */
								var_temp.u32 = str32_strlen( dst_str );

								/* Source String */
								var_temp2.u32 =_load_32( array_argpointer + 4 );
								if ( var_temp2.u32 ) { // If Not Null, That Is, Having Second Argument with Label
									if ( _uartsetheap( var_temp2.u32 ) ) break;
									src_str = UART32_UARTINT_HEAP;
									/* Pass Spaces and Label of Source String */
									temp_str = pass_space_label( src_str );
									var_temp2.u32 = temp_str - src_str;
									var_temp3.u32 = str32_strlen( temp_str );
								} else { // If Null, That Is, Having Immediate or Nothing of Second Argument
									if ( _uartsetheap( current_line ) ) break;
									src_str = UART32_UARTINT_HEAP;
									/* Pass Spaces, Labels, Command of Source String */
									length_temp = str32_charindex( temp_str_dup, 0x20 ); // Ascii Code of Space
									if ( length_temp == -1 ) break; // Reaching End of Script of Line
									temp_str_dup += length_temp; // Beyond Command
									temp_str_dup++; // Next of Space
									temp_str = pass_space_label( temp_str_dup );
									var_temp2.u32 = temp_str - src_str;
									var_temp3.u32 = str32_strlen( temp_str );
								}

								if ( var_temp3.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp3.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
								heap32_mcopy( (obj)dst_str, var_temp.u32, (obj)src_str, var_temp2.u32, var_temp3.u32 + 1 ); // Add Null Character
								line_clean( dst_str );

								break;
							case vlen:
								var_temp.u32 = _load_32( array_argpointer + 4 );
								direction.u32 = 0;

								for ( uint32 i = var_temp.u32; i < UART32_UARTMALLOC_LENGTH; i++ ) {
									if ( _uartsetheap( i ) ) break;
									temp_str = pass_space_label( UART32_UARTINT_HEAP );
									if ( ! str32_strlen( temp_str ) ) break;
									direction.u32++;
								}
								str_direction = cvt32_int32_to_string_deci( direction.u32, 1, 0 );

								break;
							case hlen:
								if ( _uartsetheap( _load_32( array_argpointer + 4 ) ) ) break;

								temp_str = pass_space_label( UART32_UARTINT_HEAP );
								direction.u32 = str32_strlen( temp_str );
								str_direction = cvt32_int32_to_string_deci( direction.u32, 1, 0 );

								break;
							case jmp:
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case call:
 								_store_32( array_link + array_link_offset * 4, current_line );
								array_link_offset++;
								if ( array_link_offset >= link_stacksize ) array_link_offset = link_stacksize - 1;
								current_line = _load_32( array_argpointer ) - 1;

								break;
							case ret:
								if ( array_link_offset <= 0 ) break;
								array_link_offset--;
								current_line = _load_32( array_link + array_link_offset * 4 );

								break;
							case push:
								if ( _uartsetheap( UART32_UARTMALLOC_LENGTH - stack_offset ) ) break;
								dst_str = UART32_UARTINT_HEAP;
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								src_str = UART32_UARTINT_HEAP;

								/* Pass Spaces and Label */
								temp_str = pass_space_label( src_str );
								var_temp.u32 = temp_str - src_str;
								var_temp2.u32 = str32_strlen( temp_str );
								heap32_mcopy( (obj)dst_str, 0, (obj)src_str, var_temp.u32, var_temp2.u32 + 1 ); // Add Null Character
								line_clean( dst_str );

								stack_offset++;

								break;
							case pop:
								if ( stack_offset <= stack_offset_default ) break;
								stack_offset--;
								if ( _uartsetheap( _load_32( array_argpointer ) ) ) break;
								dst_str = UART32_UARTINT_HEAP;
								if ( _uartsetheap( UART32_UARTMALLOC_LENGTH - stack_offset ) ) break;
								src_str = UART32_UARTINT_HEAP;

								/* Pass Spaces and Label */
								temp_str = pass_space_label( dst_str );
								var_temp.u32 = temp_str - dst_str;
								var_temp2.u32 = str32_strlen( src_str );
								if ( var_temp2.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp2.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
								heap32_mcopy( (obj)dst_str, var_temp.u32, (obj)src_str, 0, var_temp2.u32 + 1 ); // Add Null Character
								line_clean( dst_str );

								break;
							case ptr:
								/* Equal; Z Bit[30] == 1 */
								direction.u32 = _load_32( array_argpointer + 4 );
								str_direction = cvt32_int32_to_string_deci( direction.u32, 1, 0 );

								break;
							case label:
								heap32_mfill( label_list.name, 0 );
								heap32_mfill( label_list.number, 0 );
								label_list.length = 0;
								command_label( current_line );

								break;
							default:
								break;
						}

						pipe_type = go_nextline;
						if ( str_direction == null ) break;
						line_writer( _load_32( array_argpointer ), str_direction );
						str_direction = (String)heap32_mfree( (obj)str_direction ); // Clear to Null

						break;

					case go_nextline:
						/* Continue Process */

						/* Clean Arrays About Arguments on Each Command */
						heap32_mfill( array_argpointer, 0 );
						heap32_mfill( array_source, 0 );

						if ( _uartsetheap( current_line + 1 ) ) {
							pipe_type = termination;
						} else {
							pipe_type = search_command;
						}

						break;

					case termination:
						/* End Process */

						/* Clean Memory Spaces  */
						heap32_mfill( label_list.name, 0 );
						heap32_mfill( label_list.number, 0 );
						label_list.length = 0;
						for ( uint32 i = 0; i < rawdata_maxlength; i++ ) {
							var_temp.u32 = _load_32( array_rawdata + 4 * i );
							heap32_mfree( var_temp.u32 );
						}
						heap32_mfill( array_rawdata, 0 );

						/* Print Commands Untill Line with Null Character */
						for ( uint32 i = initial_line; i < UART32_UARTMALLOC_LENGTH; i++ ) {
							_uartsetheap( i );
							process_counter();
							var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
							if ( var_temp.u32 == 0 ) break;
							text_sender( UART32_UARTINT_HEAP );
							if ( i < UART32_UARTMALLOC_LENGTH - 1 ) text_sender( "\r\n\0" ); // If Not Last Line
						}
						
						pipe_type = search_command;
						flag_execute = false;
						var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
						if ( var_temp.u32 >= UART32_UARTMALLOC_MAXROW ) {
							var_temp.u32 = UART32_UARTMALLOC_MAXROW - 1;
							text_sender( "\x1B[D\0" );
						}
						/* Save Content in Line to Buffer for Retrieve It When Meta Command Is Wrote in Line */
						heap32_mcopy( buffer_line, 0, (obj)UART32_UARTINT_HEAP, 0, str32_strlen( UART32_UARTINT_HEAP ) + 1 ); // Add Null
						_store_32( UART32_UARTINT_COUNT_ADDR, var_temp.u32 );
						_store_32( UART32_UARTINT_BUSY_ADDR, 0 );

						break;

					default:

						break;
				}
			} else {
				if ( str32_strmatch( UART32_UARTINT_HEAP, 3, "run\0", 3 ) ) {
					/* If You Command "run", It Starts Execution */
					/* Retrieve Previous Content in Line that is Wrote Meta Command */
					heap32_mcopy( (obj)UART32_UARTINT_HEAP, 0, buffer_line, 0, str32_strlen( (String)buffer_line ) + 1 ); // Add Null Character
					line_clean( UART32_UARTINT_HEAP );

					flag_execute = true;
					pipe_type = search_command;
					text_sender( "\x1B[2J\x1B[H\0" ); // Clear All Screen and Move Cursor to Upper Left

					command_label( initial_line );

					_uartsetheap( initial_line );

//print32_debug_hexa( label_list.name, 400, 400, 64 );
//print32_debug_hexa( label_list.number, 400, 424, 64 );

				} else if ( str32_strmatch( UART32_UARTINT_HEAP, 3, "set\0", 3 ) ) {
					/* If You Command "set <LineNumber>", It Sets Line */
					text_sender( "\x1B[2J\x1B[H\0" ); // Clear All Screen and Move Cursor to Upper Left
					temp_str = UART32_UARTINT_HEAP;
					var_temp.u32 = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
					if ( var_temp.u32 == -1 ) {
						var_temp.u32 = str32_strlen( temp_str );
					} else {
						var_temp.u32++; // Next to Space
					}
					temp_str += var_temp.u32;
					var_temp.u32 = cvt32_string_to_int32( temp_str, str32_strlen( temp_str ) );
					/* Retrieve Previous Content in Line that is Wrote Meta Command */
					heap32_mcopy( (obj)UART32_UARTINT_HEAP, 0, buffer_line, 0, str32_strlen( (String)buffer_line ) + 1 ); // Add Null Character
					line_clean( UART32_UARTINT_HEAP );
					if ( var_temp.u32 < initial_line ) var_temp.u32 = initial_line;
					if ( _uartsetheap( var_temp.u32 ) ) _uartsetheap( initial_line );
					/* Save Content in Line to Buffer for Retrieve It When Meta Command Is Wrote in Line */
					heap32_mcopy( buffer_line, 0, (obj)UART32_UARTINT_HEAP, 0, str32_strlen( UART32_UARTINT_HEAP ) + 1 ); // Add Null
					process_counter();
					text_sender( UART32_UARTINT_HEAP );
					var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
					if ( var_temp.u32 >= UART32_UARTMALLOC_MAXROW ) {
						var_temp.u32 = UART32_UARTMALLOC_MAXROW - 1;
						text_sender( "\x1B[D\0" );
					}
					_store_32( UART32_UARTINT_COUNT_ADDR, var_temp.u32 );
					_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
				} else {
					text_sender( "\r\n\0" ); // Send These Because Teletype Is Only Mirrored Carriage Return from Host
					if ( _uartsetheap( UART32_UARTMALLOC_NUMBER + 1 ) ) _uartsetheap( initial_line );
					/* Save Content in Line to Buffer for Retrieve It When Meta Command Is Wrote in Line */
					heap32_mcopy( buffer_line, 0, (obj)UART32_UARTINT_HEAP, 0, str32_strlen( UART32_UARTINT_HEAP ) + 1 ); // Add Null
					process_counter();
					text_sender( UART32_UARTINT_HEAP );
					var_temp.u32 = str32_strlen( UART32_UARTINT_HEAP );
					if ( var_temp.u32 >= UART32_UARTMALLOC_MAXROW ) {
						var_temp.u32 = UART32_UARTMALLOC_MAXROW - 1;
						text_sender( "\x1B[D\0" );
					}
					_store_32( UART32_UARTINT_COUNT_ADDR, var_temp.u32 );
					_store_32( UART32_UARTINT_BUSY_ADDR, 0 );
				}
			}
		}
		if ( ! flag_execute ) input_keyboard( false );
		if ( startup ) startup_executer();
	}

	return EXIT_SUCCESS;
}


bool input_keyboard( bool cursor_left_edge ) {
	if ( kb_enable ) {
		String kb_str = _keyboard_get( 0, 1, ticket_hid );
		arm32_dsb();
		if ( kb_str > 0 ) { // If Key Status Changed
			if ( input_keyboard_kb_str != null ) { // If Not Initial
				if ( str32_strmatch( input_keyboard_kb_str, str32_strlen( input_keyboard_kb_str ), kb_str, str32_strlen( kb_str ) ) ) {
					input_keyboard_continue_flag = true;				
				} else {
					heap32_mfree( (obj)input_keyboard_kb_str );
					input_keyboard_continue_flag = false;				
				}
			}
			input_keyboard_translation( kb_str, cursor_left_edge );
			if ( ! input_keyboard_continue_flag ) input_keyboard_kb_str = kb_str;
		}

		if ( input_keyboard_continue_flag ) { // If Holding Key-pushing
			input_keyboard_translation( input_keyboard_kb_str, cursor_left_edge );
		}
		_sleep( 20000 );
	}

	return true;
}


bool input_keyboard_translation( String kb_str, bool cursor_left_edge ) {
	flex32 var_temp;
	// Erase Cursor
	var_temp.u32 = _load_32( UART32_UARTINT_COUNT_ADDR );
	if ( (uchar8)_load_8( (obj)UART32_UARTINT_HEAP + var_temp.u32 ) ) {
		// If Other than Null Character (Assumes Real Character)
		print32_string( UART32_UARTINT_HEAP + var_temp.u32, FB32_X_CARET, FB32_Y_CARET, 1 );
	} else {
		// If Null Character
		print32_string( " \0", FB32_X_CARET, FB32_Y_CARET, 1 );
	}

	arm32_dsb();

	for ( uint32 i = 0; i < str32_strlen( kb_str ); i++ ) {
		var_temp.u8 = _load_8( (obj)kb_str + i );
		String temp_str = _uartint_emulate( true, var_temp.u8 );
		if ( temp_str ) { // If Not Error(0)
			if ( str32_charsearch( temp_str, 1, 0x15 ) == -1 ) { // If Not NAK
				if ( print32_set_caret( print32_string( temp_str, FB32_X_CARET, FB32_Y_CARET, str32_strlen( temp_str ) ) ) ) console_rollup();
			}
			heap32_mfree( (obj)temp_str );
		}
	}
	if ( FB32_X_CARET || cursor_left_edge ) input_keyboard_set_cursor(); // If Not On Left Edge by Carriage Return or cursor_left_edge Is True

	return true;
}

bool input_keyboard_set_cursor() {
	uint32 count = _load_32( UART32_UARTINT_COUNT_ADDR );
	print32_string( "\x1B[7m \x1B[0m\0", FB32_X_CARET, FB32_Y_CARET, 9 );
	if ( count ) {
		// If Count is Bigger than 0
		if ( print32_set_caret( print32_string( "\x1B[D\0", FB32_X_CARET, FB32_Y_CARET, 3 ) ) ) console_rollup();
		if ( print32_set_caret( print32_string( UART32_UARTINT_HEAP + count - 1, FB32_X_CARET, FB32_Y_CARET, 1 ) ) ) console_rollup();
	}
	if ( count < UART32_UARTMALLOC_MAXROW - 1 ) { // If Count Reaches Maximum, Do Nothing
		if ( print32_set_caret( print32_string( "\x1B[C\0", FB32_X_CARET, FB32_Y_CARET, 3 ) ) ) console_rollup();
		if ( (uchar8)_load_8( (obj)UART32_UARTINT_HEAP + count + 1 ) ) {
			// If Other than Null Character (Assumes Real Character)
			if ( print32_set_caret( print32_string( UART32_UARTINT_HEAP + count + 1, FB32_X_CARET, FB32_Y_CARET, 1 ) ) ) console_rollup();
		} else {
			// If Null Character
			if ( print32_set_caret( print32_string( " \0", FB32_X_CARET, FB32_Y_CARET, 1 ) ) ) console_rollup();
		}
		if ( print32_set_caret( print32_string( "\x1B[D\x1B[D\0", FB32_X_CARET, FB32_Y_CARET, 6 ) ) ) console_rollup();
	}

	arm32_dsb();

	return true;
}


bool process_counter() {
	String str_process_counter = cvt32_int32_to_string_deci( UART32_UARTMALLOC_NUMBER, 2, 0 ); // Min. 2 Digit, Unsigned
	text_sender( "|\0" );
	text_sender( str_process_counter );
	text_sender( "| \0" );
	heap32_mfree( (obj)str_process_counter );

	return true;
}


bool text_sender( String target_str ) {
	uint32 length = str32_strlen( target_str );
	if ( kb_enable ) {
		if ( print32_set_caret( print32_string( target_str, FB32_X_CARET, FB32_Y_CARET, length ) ) ) console_rollup();
	} else {
		_uarttx( target_str, length ); // Clear All Screen and Move Cursor to Upper Left
		if ( print32_set_caret( print32_string_dummy( target_str, FB32_X_CARET, FB32_Y_CARET, length ) ) ) {
			FB32_X_CARET = 0;
			FB32_Y_CARET = FB32_HEIGHT - PRINT32_FONT_HEIGHT;
		}
	}

	return true;
}


bool text_sender_length( String target_str, uint32 length ) {
	if ( kb_enable ) {
		if ( print32_set_caret( print32_string( target_str, FB32_X_CARET, FB32_Y_CARET, length ) ) ) console_rollup();
	} else {
		_uarttx( target_str, length ); // Clear All Screen and Move Cursor to Upper Left
	}

	return true;
}


bool line_writer( uint32 line_number, String target_str ) {
	flex32 var_temp;
	flex32 var_temp2;

	arm32_dsb();

	if ( _uartsetheap( line_number ) ) return false;
	/* Pass Spaces and Label */
	String temp_str = pass_space_label( UART32_UARTINT_HEAP );
	var_temp.u32 = temp_str - UART32_UARTINT_HEAP;
	var_temp2.u32 = str32_strlen( target_str );
	if ( var_temp2.u32 > UART32_UARTMALLOC_MAXROW - var_temp.u32 ) var_temp2.u32 = UART32_UARTMALLOC_MAXROW - var_temp.u32; // Limitatin for Safety
	heap32_mcopy( (obj)UART32_UARTINT_HEAP, var_temp.u32, (obj)target_str, 0, var_temp2.u32 + 1 ); // Add Null Character
	line_clean( UART32_UARTINT_HEAP );

	return true;
}


String pass_space_label( String target_str ) {

	/* Pass Spaces  */
	while ( str32_charsearch( target_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space 
		target_str++;
	}
	/* Pass Label Itself */
	if ( str32_charsearch( target_str, 1, 0x2E ) != -1 ) { // Period
		uint32 length_temp = str32_charindex( target_str, 0x20 ); // Ascii Code of Space
		if ( length_temp == -1 ) length_temp = str32_strlen( target_str );
		if ( length_temp != -1 ) {
			target_str += length_temp;
			/* Pass Spaces After Label */
			if (  str32_charsearch( target_str, 1, 0x20 ) != -1 ) {
				while ( str32_charsearch( target_str, 1, 0x20 ) != -1 ) { // Ascii Code of Space 
					target_str++;
				}
			} else { // If Not Initialized
				_store_8( (obj)target_str, 0x20 ); // Ascii Code of Space
				target_str++;
			}
		}
	}

	return target_str;
}


/* Clean Back of Line After Null Character */
bool line_clean( String target_str ) {
	uint32 length_temp = str32_strlen( target_str ); // Ascii Code of Space
	heap32_mcopy( (obj)target_str, length_temp, buffer_zero, 0, UART32_UARTMALLOC_MAXROW - length_temp ); // Add Null Character

	return true;
}


bool command_print( String target_str ) {
	String temp_str = pass_space_label( target_str );
	uint32 temp_str_index;
	while ( str32_strlen( temp_str ) ) {
		if ( str32_strindex( temp_str, "\\n\0" ) != -1 ) {
			temp_str_index = str32_strindex( temp_str, "\\n\0" );
			text_sender_length( temp_str, temp_str_index );
			text_sender( "\r\n\0" );
			temp_str += temp_str_index;
			temp_str += 2;
		} else if ( str32_strindex( temp_str, "\\s\0" ) != -1 ) {
			temp_str_index = str32_strindex( temp_str, "\\s\0" );
			text_sender_length( temp_str, temp_str_index );
			text_sender( " \0" );
			temp_str += temp_str_index;
			temp_str += 2;
		} else if ( str32_strindex( temp_str, "\\e\0" ) != -1 ) {
			temp_str_index = str32_strindex( temp_str, "\\e\0" );
			text_sender_length( temp_str, temp_str_index );
			text_sender( "\x1B\0" );
			temp_str += temp_str_index;
			temp_str += 2;
		} else {
			temp_str_index = str32_strlen( temp_str );
			text_sender_length( temp_str, temp_str_index );
			temp_str += temp_str_index;
		}
	}

	return true; 
}


bool command_pict( String true_str, String false_str, obj array, uint32 size_indicator ) {
	arm32_dsb();
	int32 size_array = heap32_mcount( array );
	uint32 x_offset = arm32_udiv( FB32_X_CARET, PRINT32_FONT_WIDTH );
	if ( size_array == -1 ) return false;
	if ( size_indicator > 2 ) size_indicator = 2;
	uint32 count_array = size_array >> size_indicator;
	size_indicator = 1 << size_indicator;
	int32 length_data = 8 * size_indicator; // 1 Byte equals 8 Bits
	for ( uint32 i = 0; i < count_array; i++ ) {
		uint32 data = _load_32( array + size_indicator * i );
		for ( int32 j = length_data - 1; j >= 0; j-- ) {
			uint32 bit = data & true << j;
			if ( bit ) {
				command_print( true_str );
			} else {
				command_print( false_str );
			}
		}
		text_sender( "\r\n\0" );
		for ( uint32 j = 0; j < x_offset; j++ ) {
			text_sender( "\x1B[C\0" );
		}
	}

	return true;
}


bool command_label( uint32 start_line_number ) {
	flex32 var_temp;
	var_temp.u32 = 0;
	flex32 var_temp2;
	var_temp2.u32 = 0;

	if ( start_line_number < initial_line ) start_line_number = initial_line;

	/* Labels Enumuration */
	for ( uint32 i = start_line_number; i < UART32_UARTMALLOC_LENGTH; i++ ) {
		_uartsetheap( i );
		String temp_str = UART32_UARTINT_HEAP;
		/* Pass Spaces */
		while ( str32_charsearch( temp_str, 1, 0x20 ) != -1 ) { // Ascii Code of Spaces
			temp_str++;
		}
		var_temp.u32 = str32_charsearch( temp_str, 1, 0x2E ); // Ascii Code of Period
		if ( var_temp.u32 != -1 ) {
//print32_debug( var_temp.u32, 400, 300  );
			temp_str++;
			var_temp.u32 = str32_charindex( temp_str, 0x20 ); // Ascii Code of Space
			if ( var_temp.u32 == -1 ) { // If Not Initialized
				var_temp.u32 = str32_strlen( temp_str );
			}
			if ( var_temp.u32 > label_maxchar * 4 - 1 ) var_temp.u32 = label_maxchar * 4 - 1; // Subtract One for Null Character
			var_temp2.u32 = temp_str - UART32_UARTINT_HEAP;
			/* Store Name of Label */
			/* heap32_mcopy can't slide the address of Heap because of its system for verifying overflow */
			heap32_mcopy( label_list.name, label_maxchar * 4 * label_list.length, (obj)UART32_UARTINT_HEAP, var_temp2.u32, var_temp.u32 );
			/* Store Line Number of Label */
			_store_32( label_list.number + 4 * label_list.length, i );
			label_list.length++;
			/* Maximum Length of Label List is 16 */
			if ( label_list.length >= label_maxlength ) break;
		}
	}

	return true;
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


bool init_usb_keyboard( uint32 usb_channel ) {

	uint32 timeout;
	uint32 result;

	_sleep( 100000 ); // Wait for Root Hub Activation

	if ( _otg_host_reset_bcm() ) return False;
	arm32_dsb();

	_sleep( 500000 ); // Root Hub Port is Powerd On, So Wait for Detection of Other Hubs or Devices (on Inner Activation)

	timeout = 20;
	do {
		_sleep( 500000 );
		ticket_hub = _hub_activate( usb_channel, 0 );
		if ( ticket_hub ) break; // Break Except Zero (No Detection)
		timeout--;
	} while ( timeout ); // Except Zero

	arm32_dsb();

	_sleep( 500000 ); // Hub Port is Powerd On, So Wait for Detection of Devices (on Inner Activation)

//print32_debug( ticket_hub, 500, 230 );

	if ( ticket_hub == -1 ) {
		ticket_hid = 0; // Direct Connection
		_sleep( 500000 ); // Further Wait
	} else if ( ticket_hub > 0 ) {
		timeout = 20;
		do {
			_sleep( 500000 );
			ticket_hid = _hub_search_device( usb_channel, ticket_hub );
			if ( ticket_hid ) break; // Break Except Zero (No Detection)
			timeout--;
		} while ( timeout ); // Except Zero

// Hubs on B type uses port no.1 for an ethernet adaptor. To get a HID, search another device again.
#ifdef __B
		arm32_dsb();
		timeout = 20;
		do {
			_sleep( 500000 );
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

//print32_debug( ticket_hid, 500, 242 );

	_sleep( 500000 ); // HID is Detected, So Wait for Activation of Devices (on Inner Resetting Procedure)

	timeout = 20;
	do {
		_sleep( 500000 );
		result = _hid_activate( usb_channel, 1, ticket_hid );
		if ( result > 0 ) break; // Break Except Errors
		timeout--;
	} while ( timeout ); // Except Zero

	ticket_hid = result;

	if ( ticket_hid <= 0 ) return False; // Communication Error or No HID Device If Direct Connection

	arm32_dsb();

//print32_debug( ticket_hid, 500, 254 );

	//_hid_setidle( usb_channel, 0, ticket_hid );

	return True;
}


bool startup_executer() {
	if ( startup_length >= 4 ) {
		input_keyboard_translation( startup_command1, false );
		startup_length--;
	} else if ( startup_length >= 3 ) {
		input_keyboard_translation( startup_command2, false );
		startup_length--;
	} else if ( startup_length >= 2 ) {
		input_keyboard_translation( startup_command3, false );
		startup_length--;
	} else if ( startup_length >= 1 ) {
		input_keyboard_translation( startup_command4, false );
		startup_length--;
	}

	if ( startup_length <= 0 ) {
		startup = false;
	}

	return true;
}


void sound_makesilence() {

#ifdef __SOUND_I2S
	_soundclear(True);
#else
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundclear(False);
#endif

}


bool compare_signed( String target_str, uint32 length, uint32 status_nzcv ) {

	if ( str32_strsearch( target_str, length, "== \0", 3 ) != -1 ) {
		/* Equal; Z Bit[30] == 1 */
		if (  status_nzcv & 0x40000000  ) return false;

	} else if ( str32_strsearch( target_str, length, "!= \0", 3 ) != -1 ) {
		/* Not Equal: Z Bit[30] == 0 */
		if ( ! ( status_nzcv & 0x40000000 )  ) return false;

	} else if ( str32_strsearch( target_str, length, ">= \0", 3 ) != -1 ) {
		/* Signed Greater Than or Equal: N Bit[31] == V Bit[28] */
		if ( ( status_nzcv & 0x80000000 ) == ( status_nzcv & 0x10000000 ) ) return false;

	} else if ( str32_strsearch( target_str, length, "<= \0", 3 ) != -1 ) {
		/* Signed Less Than or Equal: N Bit[31] != V Bit[28] || Z Bit[30] == 1 */
		if ( ( ( status_nzcv & 0x80000000 ) != ( status_nzcv & 0x10000000 ) || ( status_nzcv & 0x40000000 ) ) ) return false;

	} else if ( str32_strsearch( target_str, length, "> \0", 2 ) != -1 ) {
		/* Signed Greater Than: N Bit[31] == V Bit[28] && Z Bit[30] == 0 */
		if ( ( ( status_nzcv & 0x80000000 ) == ( status_nzcv & 0x10000000 ) && ( ! ( status_nzcv & 0x40000000 ) ) ) ) return false;

	} else if ( str32_strsearch( target_str, length, "< \0", 2 ) != -1 ) {
		/* Signed Less Than: N Bit[31] != V Bit[28] */
		if ( ( status_nzcv & 0x80000000 ) != ( status_nzcv & 0x10000000 ) ) return false;

	}

	return true;

}


bool compare_unsigned( String target_str, uint32 length, uint32 status_nzcv ) {

	if ( str32_strsearch( target_str, length, "== \0", 3 ) != -1 ) {
		/* Equal; Z Bit[30] == 1 */
		if ( status_nzcv & 0x40000000 ) return false;

	} else if ( str32_strsearch( target_str, length, "!= \0", 3 ) != -1 ) {
		/* Not Equal: Z Bit[30] == 0 */
		if ( ! ( status_nzcv & 0x40000000 ) ) return false;

	} else if ( str32_strsearch( target_str, length, ">= \0", 3 ) != -1 ) {
		/* Unsinged Greater Than or Equal: C Bit[29] == 1 */
		if ( status_nzcv & 0x20000000 ) return false;

	} else if ( str32_strsearch( target_str, length, "<= \0", 3 ) != -1 ) {
		/* Unsigned Less Than or Equal: C Bit[29] == 0 || Z Bit[30] == 1 */
		if ( ( ! ( status_nzcv & 0x20000000 ) ) || ( status_nzcv & 0x40000000 ) ) return false;

	} else if ( str32_strsearch( target_str, length, "> \0", 2 ) != -1 ) {
		/* Unsigned Greater Than: C Bit[29] == 1 && Z Bit[30] == 0 */
		if ( ( status_nzcv & 0x20000000 ) && ( ! ( status_nzcv & 0x40000000 ) ) ) return false;

	} else if ( str32_strsearch( target_str, length, "< \0", 2 ) != -1 ) {
		/* Unsigned Less Than: C Bit[29] == 0 */
		if ( ! ( status_nzcv & 0x20000000 ) ) return false;

	}

	return true;

}

