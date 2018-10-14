/**
 * sts32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * This header file is for the convenience of using functions in ../(asterisk)/system32/library/sts32.s
 * Because of the purpose, names of constants are abbreviated and less considered of naming conventions.
 * Be careful of naming conventions with constants in other header files.
 */

/**
 * One Preset is 24 Bytes (6 Words)
 *     First Word: Pitch of Sub Frequency (Hard Coded Float)
 *     Second Word: Amplitude of Sub Frequency (Hard Coded Float, 0 - 2PI)
 *     Third Word: Attack (Unsigned Integer)
 *     Fourth Word: Decay (Unsigned Integer)
 *     Fifth Word: Release (Unsigned Integer)
 *     Sixth Word: Sustain Level (Hard Coded Float 0 - 1.0)
 * "equ32_sts32_synthemidi_presets" in system32/equ32.s defines the maximum index of presets (number of presets - 1)
 */
uint32 _SYNTHE_PRESETS[] =
{ // (First Word, Second Word, Sixth Word) in Parentheses
	0x3F800000, 0x00000000, 512, 512, 512, 0x3F800000, // Flute (1.0, 0.0, 1.0)
	0x3F800000, 0x40C90FE4, 512, 512, 512, 0x3F000000, // String (1.0, 2PI, 0.5)
	0x3F800000, 0x00000000, 18, 242, 338, 0x3F000000,  // Electric Piano Type 1 (1.0, 0.0, 0.5)
	0x3F800000, 0x40C90FE4, 18, 242, 338, 0x3F000000,  // Electric Piano Type 2 (1.0, 2PI, 0.5)
	0x40000000, 0x40C90FE4, 18, 512, 800, 0x3F000000,  // Metallophone (2.0, 2PI, 0.5)
	0x00000000, 0x40C90FE4, 1, 512, 98, 0x00000000     // Percussion (0.0, 2PI, 0.0)
};

