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

/* Function Declaration */
void makesilence();

/* Global Variables and Constants */

extern uint32 OS_RESET_MIDI_CHANNEL; // From vector32.s

/**
 * In default, there is a 480Hz synchronization clock (it's a half of 960Hz on Arm Timer beacause of toggling).
 * To set 48 beats as 60 BPM, decoding of sequence of music code (_soundplay) plays at only one clock out of ten clocks.
 * A set of 48 beats (= delta times) is 60BPM on 48HZ (one delta time is 1/48 seconds).
 * Arm Timer sets 480000Hz as clock.
 * 500 is divisor (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier_defualt), i.e., 480000Hz / 250 / 2 equals 480Hz (60BPM).
 * The Maximum beat (480000 / (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_MINLIMIT) / 2) is 2400Hz (300BPM).
 * The minimum beat (480000 / (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_MAXLIMIT) / 2) is 240Hz (30BPM).
 *
 * If you want particular BPM for a track, use _armtimer_reload and/or _armtimer prior to _soundset.
 */

#define TIMER_COUNT_MULTIPLICAND        5
#define TIMER_COUNT_MULTIPLIER_DEFAULT  100
#define TIMER_COUNT_MULTIPLIER_MINLIMIT 20
#define TIMER_COUNT_MULTIPLIER_MAXLIMIT 200
#define LOOP_COUNTDOWN_DEFAULT          10 // one out of ten

music_code music1[] =
{	
	_12_BIG(_RAP(
		_8_CHR(_20_NOIT)
	))

	_12_BIG(_RAP(
		_6(_20_NOIS) _6(_21_NOIS) _6(_20_NOIS) _6(_21_NOIS)
	))

	_12_BIG(_RAP(
		_4(_20_NOIT) _4(_20_NOIS)
		_4(_20_NOIM) _4(_20_NOIL)
		_4(_20_NOIM) _4(_20_NOIS)
	))

	_24_BIG(_RAP(
		_1(_51_NOIT) _1(_SILENCE)
		_1(_51_NOIS) _1(_SILENCE)
		_1(_51_NOIM) _1(_SILENCE)
		_1(_51_NOIL) _1(_SILENCE)
	))

	_12_BIG(_RAP(
		_8_DEC(_52_NOIL)
	))

	_48(_1_NOIT) _48(_2_NOIT)
	_48(_3_NOIT) _48(_4_NOIT)
	_48(_5_NOIT) _48(_6_NOIT)
	_48(_7_NOIT) _48(_8_NOIT)
	_48(_9_NOIT) _48(_10_NOIT)
	_48(_11_NOIT) _48(_12_NOIT)
	_48(_13_NOIT) _48(_14_NOIT)
	_48(_15_NOIT) _48(_16_NOIT)
	_48(_17_NOIT) _48(_18_NOIT)
	_48(_19_NOIT) _48(_20_NOIT)
	_48(_21_NOIT) _48(_22_NOIT)
	_48(_23_NOIT) _48(_24_NOIT)
	_48(_25_NOIT) _48(_26_NOIT)
	_48(_27_NOIT) _48(_28_NOIT)
	_48(_29_NOIT) _48(_30_NOIT)
	_48(_31_NOIT) _48(_32_NOIT)
	_48(_33_NOIT) _48(_34_NOIT)
	_48(_35_NOIT) _48(_36_NOIT)
	_48(_37_NOIT) _48(_38_NOIT)
	_48(_39_NOIT) _48(_40_NOIT)
	_48(_41_NOIT) _48(_42_NOIT)
	_48(_43_NOIT) _48(_44_NOIT)
	_48(_45_NOIT) _48(_46_NOIT)
	_48(_47_NOIT) _48(_48_NOIT)
	_48(_49_NOIT) _48(_50_NOIT)
	_48(_51_NOIT) _48(_52_NOIT)


	_48(_1_NOIS) _48(_2_NOIS)
	_48(_3_NOIS) _48(_4_NOIS)
	_48(_5_NOIS) _48(_6_NOIS)
	_48(_7_NOIS) _48(_8_NOIS)
	_48(_9_NOIS) _48(_10_NOIS)
	_48(_11_NOIS) _48(_12_NOIS)
	_48(_13_NOIS) _48(_14_NOIS)
	_48(_15_NOIS) _48(_16_NOIS)
	_48(_17_NOIS) _48(_18_NOIS)
	_48(_19_NOIS) _48(_20_NOIS)
	_48(_21_NOIS) _48(_22_NOIS)
	_48(_23_NOIS) _48(_24_NOIS)
	_48(_25_NOIS) _48(_26_NOIS)
	_48(_27_NOIS) _48(_28_NOIS)
	_48(_29_NOIS) _48(_30_NOIS)
	_48(_31_NOIS) _48(_32_NOIS)
	_48(_33_NOIS) _48(_34_NOIS)
	_48(_35_NOIS) _48(_36_NOIS)
	_48(_37_NOIS) _48(_38_NOIS)
	_48(_39_NOIS) _48(_40_NOIS)
	_48(_41_NOIS) _48(_42_NOIS)
	_48(_43_NOIS) _48(_44_NOIS)
	_48(_45_NOIS) _48(_46_NOIS)
	_48(_47_NOIS) _48(_48_NOIS)
	_48(_49_NOIS) _48(_50_NOIS)
	_48(_51_NOIS) _48(_52_NOIS)

	_48(_1_NOIM) _48(_2_NOIM)
	_48(_3_NOIM) _48(_4_NOIM)
	_48(_5_NOIM) _48(_6_NOIM)
	_48(_7_NOIM) _48(_8_NOIM)
	_48(_9_NOIM) _48(_10_NOIM)
	_48(_11_NOIM) _48(_12_NOIM)
	_48(_13_NOIM) _48(_14_NOIM)
	_48(_15_NOIM) _48(_16_NOIM)
	_48(_17_NOIM) _48(_18_NOIM)
	_48(_19_NOIM) _48(_20_NOIM)
	_48(_21_NOIM) _48(_22_NOIM)
	_48(_23_NOIM) _48(_24_NOIM)
	_48(_25_NOIM) _48(_26_NOIM)
	_48(_27_NOIM) _48(_28_NOIM)
	_48(_29_NOIM) _48(_30_NOIM)
	_48(_31_NOIM) _48(_32_NOIM)
	_48(_33_NOIM) _48(_34_NOIM)
	_48(_35_NOIM) _48(_36_NOIM)
	_48(_37_NOIM) _48(_38_NOIM)
	_48(_39_NOIM) _48(_40_NOIM)
	_48(_41_NOIM) _48(_42_NOIM)
	_48(_43_NOIM) _48(_44_NOIM)
	_48(_45_NOIM) _48(_46_NOIM)
	_48(_47_NOIM) _48(_48_NOIM)
	_48(_49_NOIM) _48(_50_NOIM)
	_48(_51_NOIM) _48(_52_NOIM)

	_48(_1_NOIL) _48(_2_NOIL)
	_48(_3_NOIL) _48(_4_NOIL)
	_48(_5_NOIL) _48(_6_NOIL)
	_48(_7_NOIL) _48(_8_NOIL)
	_48(_9_NOIL) _48(_10_NOIL)
	_48(_11_NOIL) _48(_12_NOIL)
	_48(_13_NOIL) _48(_14_NOIL)
	_48(_15_NOIL) _48(_16_NOIL)
	_48(_17_NOIL) _48(_18_NOIL)
	_48(_19_NOIL) _48(_20_NOIL)
	_48(_21_NOIL) _48(_22_NOIL)
	_48(_23_NOIL) _48(_24_NOIL)
	_48(_25_NOIL) _48(_26_NOIL)
	_48(_27_NOIL) _48(_28_NOIL)
	_48(_29_NOIL) _48(_30_NOIL)
	_48(_31_NOIL) _48(_32_NOIL)
	_48(_33_NOIL) _48(_34_NOIL)
	_48(_35_NOIL) _48(_36_NOIL)
	_48(_37_NOIL) _48(_38_NOIL)
	_48(_39_NOIL) _48(_40_NOIL)
	_48(_41_NOIL) _48(_42_NOIL)
	_48(_43_NOIL) _48(_44_NOIL)
	_48(_45_NOIL) _48(_46_NOIL)
	_48(_47_NOIL) _48(_48_NOIL)
	_48(_49_NOIL) _48(_50_NOIL)
	_48(_51_NOIL) _48(_52_NOIL)

	_END
};

/**
 * "Stille Nacht (Silent Night)", Austrian Christmas Carol
 * Melody With Arpeggio
 */
music_code music2[] =
{
	_48_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_A4_SINL) _48_DEC(_G4_SINL) _48_DEC(_E4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT)
	_48_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_A4_SINL) _48_DEC(_G4_SINL) _48_DEC(_E4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT)
	_48_DEC(_D5_SINL) _24_MAJ_ARP(_D4_SINT) _24_MAJ_ARP(_D4_SINT) _48_DEC(_D5_SINL) _48_DEC(_B4_SINL) _24_MAJ_ARP(_D4_SINT) _24_MAJ_ARP(_D4_SINT) _24_MAJ_ARP(_D4_SINT) _24_MAJ_ARP(_D4_SINT)
	_48_DEC(_C5_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _48_DEC(_C5_SINL) _48_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT)

	_48_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _48_DEC(_A4_SINL) _48_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_B4_SINL) _48_DEC(_A4_SINL)
	_48_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_A4_SINL) _48_DEC(_G4_SINL) _48_DEC(_E4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT)
	_48_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _48_DEC(_A4_SINL) _48_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_B4_SINL) _48_DEC(_A4_SINL)
	_48_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_A4_SINL) _48_DEC(_G4_SINL) _48_DEC(_E4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT)

	_48_DEC(_D5_SINL) _24_MAJ_ARP(_G4_SINT) _24_MAJ_ARP(_G4_SINT) _48_DEC(_D5_SINL) _48_DEC(_F5_SINL) _24_MAJ_ARP(_G4_SINT) _24_DEC(_D5_SINL) _48_DEC(_B4_SINL)
	_48_DEC(_C5_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _48_DEC(_E5_SINL) _24_MAJ_ARP(_C5_SINT) _24_MAJ_ARP(_C5_SINT) _24_MAJ_ARP(_C5_SINT) _24_MAJ_ARP(_C5_SINT)
	_48_DEC(_C5_SINL) _48_DEC(_G4_SINL) _48_DEC(_E4_SINL) _48_DEC(_G4_SINL) _24_MAJ_ARP(_G4_SINT) _24_DEC(_F4_SINL) _48_DEC(_D4_SINL)
	_48_DEC(_C4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _48(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT)

	_END
};

/**
 * "Stille Nacht (Silent Night)", Austrian Christmas Carol
 * Melody
music_code music2[] =
{
	_48(_G4_SINL) _24(_G4_SINL) _24(_A4_SINL) _48(_G4_SINL) _48(_E4_SINL) _48(_E4_SINL) _48(_E4_SINL)
	_48(_G4_SINL) _24(_G4_SINL) _24(_A4_SINL) _48(_G4_SINL) _48(_E4_SINL) _48(_E4_SINL) _48(_E4_SINL)
	_48(_D5_SINL) _40(_D5_SINL) _8(_SILENCE) _48(_D5_SINL) _48(_B4_SINL) _48(_B4_SINL) _48(_B4_SINL)
	_48(_C5_SINL) _40(_C5_SINL) _8(_SILENCE) _48(_C5_SINL) _48(_G4_SINL) _48(_G4_SINL) _48(_G4_SINL)

	_48(_A4_SINL) _40(_A4_SINL) _8(_SILENCE) _48(_A4_SINL) _48(_C5_SINL) _24(_C5_SINL) _24(_B4_SINL) _48(_A4_SINL)
	_48(_G4_SINL) _24(_G4_SINL) _24(_A4_SINL) _48(_G4_SINL) _48(_E4_SINL) _48(_E4_SINL) _48(_E4_SINL)
	_48(_A4_SINL) _40(_A4_SINL) _8(_SILENCE) _48(_A4_SINL) _48(_C5_SINL) _24(_C5_SINL) _24(_B4_SINL) _48(_A4_SINL)
	_48(_G4_SINL) _24(_G4_SINL) _24(_A4_SINL) _48(_G4_SINL) _48(_E4_SINL) _48(_E4_SINL) _48(_E4_SINL)

	_48(_D5_SINL) _40(_D5_SINL) _8(_SILENCE) _48(_D5_SINL) _48(_F5_SINL) _24(_F5_SINL) _24(_D5_SINL) _48(_B4_SINL)
	_48(_C5_SINL) _48(_C5_SINL) _48(_C5_SINL) _48(_E5_SINL) _48(_E5_SINL) _48(_E5_SINL)
	_48(_C5_SINL) _48(_G4_SINL) _48(_E4_SINL) _48(_G4_SINL) _24(_G4_SINL) _24(_F4_SINL) _48(_D4_SINL)
	_48(_C4_SINL) _48(_C4_SINL) _48(_C4_SINL) _48(_C4_SINL) _48(_C4_SINL) _48(_C4_SINL)

	_END
};
 */

/*
music_code music2[] =
{
	//_12_DEC(_A4_TRIL) _12_DEC(_B4_TRIL)
	//_12_DEC(_C5_TRIL) _12_DEC(_B4_TRIL)
	//_12_DEC(_A4_TRIL) _12(_A4_TRIT)
	//_48(_SILENCE)
	_48(_C4_SINL) _48(_C4_SINL)
	_48(_C4_SINL) _48(_C4_SINL)
	_48(_C4_SINL) _48(_C4_SINL)
	_48(_C4_SINL) _48(_C4_SINL)
	_END
};
*/

music_code music3[] =
{
	_12(_C4_SINL)
	_4(_E4_SINL) _4(_G4_SINL) _4(_C5_SINL)
	_12(_E4_SINL)
	_4(_G4_SINL) _4(_C5_SINL) _4(_E5_SINL)
	_12(_G4_SINL)
	_4(_E5_SINL) _4(_G5_SINL) _4(_C6_SINL)
	_END
};

/**
 * "Auld Lang Syne", Scottish Folk Song
 * Melody With Arpeggio
 */
music_code music4[] =
{
	_24_DEC(_C4_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_A4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT)
	_24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_D5_SINL) _24_MAJ_ARP(_AS4_SINT) _24(_D5_SINT) _24_MAJ_ARP(_AS4_SINT) _24(_D5_SINT) _24_MAJ_ARP(_AS4_SINT)

	_24_DEC(_D5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_A4_SINL) _12(_SILENCE) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_F4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT)
	_24_DEC(_A4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_MAJ_ARP(_AS4_SINT) _12_DEC(_D4_SINL) _12(_SILENCE) _24_DEC(_D4_SINL) _24_MAJ_ARP(_AS4_SINT)
	_24_DEC(_C4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _24(_F4_SINT) _24_MAJ_ARP(_F4_SINT)

	_24_DEC(_D5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_A4_SINL) _12(_SILENCE) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_F4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT)
	_24_DEC(_D5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_A4_SINL) _12(_SILENCE) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_D5_SINL) _24_MAJ_ARP(_AS4_SINT) _24(_D5_SINT) _24_MAJ_ARP(_AS4_SINT) _24(_D5_SINT) _24_MAJ_ARP(_AS4_SINT)

	_24_DEC(_D5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_A4_SINL) _12(_SILENCE) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_F4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT)
	_24_DEC(_A4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_MAJ_ARP(_AS4_SINT) _12_DEC(_D4_SINL) _12(_SILENCE) _24_DEC(_D4_SINL) _24_MAJ_ARP(_AS4_SINT)
	_24_DEC(_C4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _24(_F4_SINT) _24_MAJ_ARP(_F4_SINT)

	_END
};

/**
 * "Auld Lang Syne", Scottish Folk Song
 * Melody
music_code music4[] =
{
	_24(_C4_SINL) _24(_SILENCE) _48(_F4_SINL) _24(_SILENCE) _12(_F4_SINL) _12(_SILENCE) _24(_F4_SINL) _24(_SILENCE)
	_24(_A4_SINL) _24(_SILENCE) _48(_G4_SINL) _24(_SILENCE) _12(_F4_SINL) _12(_SILENCE) _24(_G4_SINL) _24(_SILENCE)
	_24(_A4_SINL) _24(_SILENCE) _24(_F4_SINL) _24(_SILENCE) _24(_F4_SINL) _24(_SILENCE) _24(_A4_SINL) _24(_SILENCE)
	_24(_C5_SINL) _24(_SILENCE) _24(_D5_SINL) _24(_D5_SINL) _24(_D5_SINL) _24(_D5_SINL) _24(_D5_SINL) _24(_SILENCE)

	_24(_D5_SINL) _24(_SILENCE) _48(_C5_SINL) _24(_SILENCE) _12(_A4_SINL) _12(_SILENCE) _24(_A4_SINL) _24(_SILENCE)
	_24(_F4_SINL) _24(_SILENCE) _48(_G4_SINL) _24(_SILENCE) _12(_F4_SINL) _12(_SILENCE) _24(_G4_SINL) _24(_SILENCE)
	_24(_A4_SINL) _24(_SILENCE) _48(_F4_SINL) _24(_SILENCE) _12(_D4_SINL) _12(_SILENCE) _24(_D4_SINL) _24(_SILENCE)
	_24(_C4_SINL) _24(_SILENCE) _24(_F4_SINL) _24(_F4_SINL) _24(_F4_SINL) _24(_F4_SINL) _24(_F4_SINL) _24(_SILENCE)

	_24(_D5_SINL) _24(_SILENCE) _48(_C5_SINL) _24(_SILENCE) _12(_A4_SINL) _12(_SILENCE) _24(_A4_SINL) _24(_SILENCE)
	_24(_F4_SINL) _24(_SILENCE) _48(_G4_SINL) _24(_SILENCE) _12(_F4_SINL) _12(_SILENCE) _24(_G4_SINL) _24(_SILENCE)
	_24(_D5_SINL) _24(_SILENCE) _48(_C5_SINL) _24(_SILENCE) _12(_A4_SINL) _12(_SILENCE) _24(_A4_SINL) _24(_SILENCE)
	_24(_C5_SINL) _24(_SILENCE) _24(_D5_SINL) _24(_D5_SINL) _24(_D5_SINL) _24(_D5_SINL) _24(_D5_SINL) _24(_SILENCE)

	_24(_D5_SINL) _24(_SILENCE) _48(_C5_SINL) _24(_SILENCE) _12(_A4_SINL) _12(_SILENCE) _24(_A4_SINL) _24(_SILENCE)
	_24(_F4_SINL) _24(_SILENCE) _48(_G4_SINL) _24(_SILENCE) _12(_F4_SINL) _12(_SILENCE) _24(_G4_SINL) _24(_SILENCE)
	_24(_A4_SINL) _24(_SILENCE) _48(_F4_SINL) _24(_SILENCE) _12(_D4_SINL) _12(_SILENCE) _24(_D4_SINL) _24(_SILENCE)
	_24(_C4_SINL) _24(_SILENCE) _24(_F4_SINL) _24(_F4_SINL) _24(_F4_SINL) _24(_F4_SINL) _24(_F4_SINL) _24(_SILENCE)

	_END
};
 */

/*
music_code music4[] =
{
	_12_MAJ(_C4_SINL) _12_MAJ(_E4_SINL) _12_MAJ(_G4_SINL) _12_MAJ(_B4_SINL)
	_12_MAJ(_E4_SINL) _12_MAJ(_G4_SINL) _12_MAJ(_B4_SINL) _12_MAJ(_D5_SINL)
	_12_MAJ(_G4_SINL) _12_MAJ(_B4_SINL) _12_MAJ(_D5_SINL) _12_MAJ(_F5_SINL)
	_END
};
*/

music_code music5[] =
{
	_12(_E4_TRIL)
	_END
};

music_code music6[] =
{
	_24_M(_C3_SINL) _24_M(_B2_SINL)
	_24_M(_A2_SINL) _24_M(_B2_SINL)
	_END
};

music_code music7[] =
{
	_48_9TH(_F4_TRIL)
	_END
};

/*
music_code music8[] =
{
	_48_DOM(_D4_TRIL)
	_24_DOM_ARP(_G4_TRIL) _24_DOM_ARP(_G4_TRIL)
	_48_DOM(_D5_TRIL)
	_48_DOM(_D4_TRIL)
	_END
};
*/

/**
 * "When The Saints Go Marching In", American Gospel Song
 * Chorus
 */
music_code music8[] =
{
	_24_DOM(_C4_SINL) _24_DOM(_E4_SINL) _24_DOM(_F4_SINL) _24_DOM(_G4_SINL) _24_DOM(_C5_SINS) _24_DOM(_E5_SINS) _24_DOM(_F5_SINS) _24_DOM(_G5_SINS)
	_24_DOM(_C4_SINL) _24_DOM(_E4_SINL) _24_DOM(_F4_SINL) _24_DOM(_G4_SINL) _24_DOM(_C5_SINS) _24_DOM(_E5_SINS) _24_DOM(_F5_SINS) _24_DOM(_G5_SINS)
	_24_DOM(_C4_SINL) _24_DOM(_E4_SINL) _24_DOM(_F4_SINL) _24_DOM(_G4_SINL) _24_DOM(_G5_SINS) _24_DOM(_E4_SINL) _24_DOM(_E5_SINS) _24_DOM(_C4_SINL)
	_24_DOM(_C5_SINS) _24_DOM(_E4_SINL) _24_DOM(_E5_SINS) _24_DOM(_D4_SINL) _24_DOM(_D5_SINS) _24_DOM(_D5_SINS) _24_DOM(_D5_SINS) _24_DOM(_E5_SINS)

	_24_DOM(_E4_SINL) _24_DOM(_E4_SINL) _24_DOM(_D4_SINL) _24_DOM(_C4_SINL) _24_DOM(_C4_SINL) _24_DOM(_C5_SINS) _24_DOM(_C4_SINL) _24_DOM(_E4_SINL)
	_24_DOM(_E5_SINS) _24_DOM(_G4_SINL) _24_DOM(_G5_SINS) _24_DOM(_G4_SINL) _24_DOM(_F4_SINL) _24_DOM(_F4_SINL) _24_DOM(_F5_SINS) _24_DOM(_G5_SINS)
	_24_DOM(_G5_SINS) _24_DOM(_E4_SINL) _24_DOM(_F4_SINL) _24_DOM(_G4_SINL) _24_DOM(_G5_SINS) _24_DOM(_E4_SINL) _24_DOM(_E5_SINS) _24_DOM(_C4_SINL)
	_24_DOM(_C5_SINS) _24_DOM(_D4_SINL) _24_DOM(_D5_SINS) _24_DOM(_C4_SINL) _24_DOM(_C4_SINL) _24_DOM(_C5_SINS) _24_DOM(_C5_SINS) _24_DOM(_D5_SINS)

	_END
};

/**
 * "When The Saints Go Marching In", American Gospel Song
 * Melody
music_code music8[] =
{
	_24(_C4_SINL) _24(_E4_SINL) _24(_F4_SINL) _24(_G4_SINL) _24(_SILENCE) _24(_SILENCE) _24(_SILENCE) _24(_SILENCE)
	_24(_C4_SINL) _24(_E4_SINL) _24(_F4_SINL) _24(_G4_SINL) _24(_SILENCE) _24(_SILENCE) _24(_SILENCE) _24(_SILENCE)
	_24(_C4_SINL) _24(_E4_SINL) _24(_F4_SINL) _24(_G4_SINL) _24(_SILENCE) _24(_E4_SINL) _24(_SILENCE) _24(_C4_SINL)
	_24(_SILENCE) _24(_E4_SINL) _24(_SILENCE) _24(_D4_SINL) _24(_D4_SINL) _24(_SILENCE) _24(_SILENCE) _24(_SILENCE)

	_24(_E4_SINL) _24(_E4_SINL) _24(_D4_SINL) _24(_C4_SINL) _24(_C4_SINL) _24(_SILENCE) _24(_C4_SINL) _24(_E4_SINL)
	_24(_SILENCE) _24(_G4_SINL) _24(_SILENCE) _24(_G4_SINL) _24(_F4_SINL) _24(_F4_SINL) _24(_SILENCE) _24(_SILENCE)
	_24(_SILENCE) _24(_E4_SINL) _24(_F4_SINL) _24(_G4_SINL) _24(_SILENCE) _24(_E4_SINL) _24(_SILENCE) _24(_C4_SINL)
	_24(_SILENCE) _24(_D4_SINL) _24(_SILENCE) _24(_C4_SINL) _24(_C4_SINL) _24(_SILENCE) _24(_SILENCE) _24(_SILENCE)

	_END
};
 */

music_code interrupt16[] =
{
	_4_BIG(_RAP(
		_48_RYU_ARP(_D4_TRIL)
		_24_RYU_ARP(_G4_TRIL) _24_RYU_ARP(_G4_TRIL)
		_48_RYU_ARP(_D5_TRIL)
		_48_RYU_ARP(_D4_TRIL)
	))
	_1_BIG(_RAP(
		_48(_SILENCE)
	))
	_END
};

#define MUSIC_CODE_PRE_NUMBER 9

/* Register for Music Codes */
music_code* music_code_pre_table[MUSIC_CODE_PRE_NUMBER] = {
	music1,
	music2,
	music3,
	music4,
	music5,
	music6,
	music7,
	music8,
	interrupt16
};

/* Register for Modulation Parameters, 1st Delta (Signed -256 to 256), 2nd Range (Mid-Peak, Unsigned Up to 4096) */
uint16 modulation_pre_table[MUSIC_CODE_PRE_NUMBER*2] = {
	 0x0000, 0x0000,
	 0x0000, 0x0000,
	 0x0000, 0x0000,
	 0x0000, 0x0000,
	 0x0000, 0x0000,
	 0x0000, 0x0000,
	 0x0000, 0x0000,
	 0x0000, 0x0000,
	-0x0010, 0x1000
};

/* Register for Index of Tables */
uint32 music_code_pre_table_index[MUSIC_CODE_PRE_NUMBER] = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	16
};

music_code** music_code_table;
int16* modulation_table;
uint32* musiclen_table;
uint32 tempo_index;

void makesilence() {
#ifdef __SOUND_I2S
	_soundclear(True);
#elif defined(__SOUND_I2S_BALANCED)
	_soundclear(True);
#elif defined(__SOUND_PWM)
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundclear(False);
#elif defined(__SOUND_PWM_BALANCED)
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundclear(False);
#elif defined(__SOUND_JACK)
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundclear(False);
#elif defined(__SOUND_JACK_BALANCED)
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundclear(False);
#endif
}

int32 _user_start() {
	/* Local Variables */
	uint32 timer_count_multiplier = TIMER_COUNT_MULTIPLIER_DEFAULT;
	uint32 delta_multiplier;
	uint32 detect_parallel = 0;
	uint32 table_index;
	int32 loop_countdown = LOOP_COUNTDOWN_DEFAULT; // Use Signed Integer to Prevent Incorrect Compilation (Using Comparison in IF Statement)
	uchar8 result;
	uchar8 playing_signal;
	bool flag_midi_noteon = False;
	bool mode_soundplay;
#ifdef __SOUND_I2S
	_sounddecode( _SOUND_INDEX, SND32_I2S, _SOUND_ADJUST );
	mode_soundplay = True;
	delta_multiplier = 6;
#elif defined(__SOUND_I2S_BALANCED)
	_sounddecode( _SOUND_INDEX, SND32_I2S_BALANCED, _SOUND_ADJUST );
	mode_soundplay = True;
	delta_multiplier = 6;
#elif defined(__SOUND_PWM)
	_sounddecode( _SOUND_INDEX, SND32_PWM, _SOUND_ADJUST );
	mode_soundplay = False;
	delta_multiplier = 4;
#elif defined(__SOUND_PWM_BALANCED)
	_sounddecode( _SOUND_INDEX, SND32_PWM_BALANCED, _SOUND_ADJUST );
	mode_soundplay = False;
	delta_multiplier = 4;
#elif defined(__SOUND_JACK)
	_sounddecode( _SOUND_INDEX, SND32_PWM, _SOUND_ADJUST );
	mode_soundplay = False;
	delta_multiplier = 4;
#elif defined(__SOUND_JACK_BALANCED)
	_sounddecode( _SOUND_INDEX, SND32_PWM_BALANCED, _SOUND_ADJUST );
	mode_soundplay = False;
	delta_multiplier = 4;
#endif

	/* Initialization of Global Variables */
	music_code_table = (music_code**)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	modulation_table = (int16*)heap32_malloc( 128 ); // 128 Words (256 Half Words) = 512 Bytes
	musiclen_table = (uint32*)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	for ( uint32 i = 0; i < MUSIC_CODE_PRE_NUMBER; i++ ) {
		table_index = music_code_pre_table_index[i];
		// To Get Proper Latency, Get Lengths in Advance
		music_code_table[table_index] = music_code_pre_table[i];
		modulation_table[table_index * 2] = modulation_pre_table[i * 2];
		modulation_table[(table_index * 2) + 1] = modulation_pre_table[(i * 2) + 1];
		musiclen_table[table_index] = snd32_musiclen( music_code_pre_table[i] );
	}
	tempo_index = 0;

	/* Silence in Advance */
	makesilence();

	while ( true ) {
#ifdef __SOUND_I2S
		_soundmidi( OS_RESET_MIDI_CHANNEL, SND32_MIDI_PCM );
#elif defined(__SOUND_I2S_BALANCED)
		_soundmidi( OS_RESET_MIDI_CHANNEL, SND32_MIDI_PCM );
#elif defined(__SOUND_PWM)
		_soundmidi( OS_RESET_MIDI_CHANNEL, SND32_MIDI_PWM );
#elif defined(__SOUND_PWM_BALANCED)
		_soundmidi( OS_RESET_MIDI_CHANNEL, SND32_MIDI_PWM );
#elif defined(__SOUND_JACK)
		_soundmidi( OS_RESET_MIDI_CHANNEL, SND32_MIDI_PWM );
#elif defined(__SOUND_JACK_BALANCED)
		_soundmidi( OS_RESET_MIDI_CHANNEL, SND32_MIDI_PWM );
#endif

		/* High on GPIO20 If MIDI Note On */
		if ( SND32_STATUS & 0x4 ) { // Bit[2] MIDI Note Off(0)/ Note On(1)
			if ( ! flag_midi_noteon ) {
				flag_midi_noteon = True;
				_gpiotoggle( 20, flag_midi_noteon ); // Gate On
			}
		} else {
			if ( flag_midi_noteon ) {
				flag_midi_noteon = False;
				_gpiotoggle( 20, flag_midi_noteon ); // Gate Off
			}
		}

		/* Detect Falling Edge of GPIO */
		if ( _gpio_detect( 27 ) ) {
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );
			detect_parallel = ((detect_parallel >> 22) & 0b11111) | 0x80000000; // Set Outstanding Flag
		}

		/**
		 * Detecting falling edge of gpio is sticky, and is cleared by falling edge of GPIO 27.
		 * So, physical all high is needed to act as doing nothing or its equivalent.
		 * 0x1F = 0b11111 (31) is physical all high in default. Command 31 is used as stopping sound.
		 * 0x7F = 0b1111111 (127) is virtual all high in default.
		 * If you extend physical parallel up to 0x7F, you need to use Command 127 as doing nothing or so.
		 * Command 127 is used as setting upper 8 bits of the tempo index.
		 */
		if ( detect_parallel ) { // If Any Non Zero Including Outstanding Flag
			detect_parallel &= 0x7F; // 0-127
			if ( detect_parallel > 111 ) { // 112(0x70)-127(0x7F)
				// Tempo Index Upper 8-bit
				tempo_index = (tempo_index & 0x0F) | ((detect_parallel & 0x0F) << 8);
				timer_count_multiplier = tempo_index;
				if ( timer_count_multiplier > TIMER_COUNT_MULTIPLIER_MAXLIMIT ) {
					timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MAXLIMIT;
				} else if ( timer_count_multiplier < TIMER_COUNT_MULTIPLIER_MINLIMIT ) {
					timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MINLIMIT;
				}
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel > 95 ) { // 96(0x60)-111(0x6F)
				// Tempo Index Lower 8-bit
				tempo_index = (tempo_index & 0xF0) | (detect_parallel & 0x0F);
				timer_count_multiplier = tempo_index;
				if ( timer_count_multiplier > TIMER_COUNT_MULTIPLIER_MAXLIMIT ) {
					timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MAXLIMIT;
				} else if ( timer_count_multiplier < TIMER_COUNT_MULTIPLIER_MINLIMIT ) {
					timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MINLIMIT;
				}
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel > 31 ) { // 32-95
				// One Time
				SND32_MODULATION_DELTA = modulation_table[detect_parallel * 2] * delta_multiplier;
				SND32_MODULATION_RANGE = modulation_table[(detect_parallel * 2) + 1] * delta_multiplier;
				_soundset( music_code_table[detect_parallel], musiclen_table[detect_parallel], 0, 1 );
			} else if ( detect_parallel == 0b11111 ) { // 0b11111 (31)
				makesilence();
			} else if ( detect_parallel == 0b11110 ) { // 0b11110 (30)
				/* Beat Down */
				timer_count_multiplier += 5;
				if ( timer_count_multiplier > TIMER_COUNT_MULTIPLIER_MAXLIMIT ) timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MAXLIMIT;
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel == 0b11101 ) { // 0b11101 (29)
				/* Beat Up */
				timer_count_multiplier -= 5;
				if ( timer_count_multiplier < TIMER_COUNT_MULTIPLIER_MINLIMIT ) timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MINLIMIT;
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel > 15 ) { // 16-28
				// One Time
				SND32_MODULATION_DELTA = modulation_table[detect_parallel * 2] * delta_multiplier;
				SND32_MODULATION_RANGE = modulation_table[(detect_parallel * 2) + 1] * delta_multiplier;
				_soundinterrupt( music_code_table[detect_parallel], musiclen_table[detect_parallel], 0, 1 );
			} else if ( detect_parallel > 0 ) { // 1-15
				// Loop
				SND32_MODULATION_DELTA = modulation_table[detect_parallel * 2] * delta_multiplier;
				SND32_MODULATION_RANGE = modulation_table[(detect_parallel * 2) + 1] * delta_multiplier;
				_soundset( music_code_table[detect_parallel], musiclen_table[detect_parallel], 0, -1 );
			} // Do Nothing at 0 for Preventing Chattering
			detect_parallel = 0;
		}

		/* Detect Rising Edge of GPIO */
		if ( _gpio_detect( 17 ) ) {
			if ( SND32_VIRTUAL_PARALLEL ) {
				detect_parallel = SND32_VIRTUAL_PARALLEL;
				SND32_VIRTUAL_PARALLEL = 0;
			}

//print32_debug( detect_parallel, 100, 100 );

			// Subtract Pitch Bend Ratio to Divisor (Upside Down)
#ifdef __SOUND_I2S
			_clockmanager_divisor( _cm_pcm, SND32_DIVISOR - SND32_SOUNDMIDI_PITCHBEND );
#elif defined(__SOUND_I2S_BALANCED)
			_clockmanager_divisor( _cm_pcm, SND32_DIVISOR - SND32_SOUNDMIDI_PITCHBEND );
#elif defined(__SOUND_PWM)
			_clockmanager_divisor( _cm_pwm, SND32_DIVISOR - SND32_SOUNDMIDI_PITCHBEND );
#elif defined(__SOUND_PWM_BALANCED)
			_clockmanager_divisor( _cm_pwm, SND32_DIVISOR - SND32_SOUNDMIDI_PITCHBEND );
#elif defined(__SOUND_JACK)
			_clockmanager_divisor( _cm_pwm, SND32_DIVISOR - SND32_SOUNDMIDI_PITCHBEND );
#elif defined(__SOUND_JACK_BALANCED)
			_clockmanager_divisor( _cm_pwm, SND32_DIVISOR - SND32_SOUNDMIDI_PITCHBEND );
#endif

/*
print32_debug( SND32_DIVISOR, 100, 100 );
print32_debug( SND32_MODULATION_DELTA, 100, 112 );
print32_debug( SND32_MODULATION_MAX, 100, 124 );
print32_debug( SND32_MODULATION_MIN, 100, 136 );
*/

			/* Triangle LFO */
			SND32_DIVISOR += SND32_MODULATION_DELTA;
			if ( SND32_DIVISOR >= SND32_MODULATION_MAX ) {
				SND32_DIVISOR = SND32_MODULATION_MAX;
				SND32_MODULATION_DELTA = -( SND32_MODULATION_DELTA );
			} else if ( SND32_DIVISOR <= SND32_MODULATION_MIN ) {
				SND32_DIVISOR = SND32_MODULATION_MIN;
				SND32_MODULATION_DELTA = -( SND32_MODULATION_DELTA );
			}
			arm32_dsb();

			loop_countdown--; // Decrement Counter
			if ( loop_countdown <= 0 ) { // If Reaches Zero
				result = _soundplay( mode_soundplay );
				if ( result == 0 ) { // Playing
					playing_signal = _GPIOTOGGLE_HIGH;
				} else { // Not Playing
					playing_signal = _GPIOTOGGLE_LOW;
				}
				_gpiotoggle( 16, playing_signal );
				loop_countdown = LOOP_COUNTDOWN_DEFAULT; // Reset Counter
			}
		}
	}
	return EXIT_SUCCESS;
}
