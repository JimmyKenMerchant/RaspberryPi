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

#define _END  0x00,0x00
#define _FREQ 0
#define _MAG  16
#define _BEAT 0
#define _RIS  0
#define _FAL  16
#define _INT  2
#define _FRAC 0

#define _A0  27ul<<_INT|2<<_FRAC
#define _AS0 29ul<<_INT|1<<_FRAC
#define _B0  30ul<<_INT|3<<_FRAC

#define _C1  32ul<<_INT|3<<_FRAC
#define _CS1 34ul<<_INT|3<<_FRAC
#define _D1  36ul<<_INT|3<<_FRAC
#define _DS1 39ul<<_INT
#define _E1  41ul<<_INT|1<<_FRAC
#define _F1  43ul<<_INT|3<<_FRAC
#define _FS1 46ul<<_INT|1<<_FRAC
#define _G1  49ul<<_INT
#define _GS1 52ul<<_INT
#define _A1  55ul<<_INT
#define _AS1 58ul<<_INT|1<<_FRAC
#define _B1  61ul<<_INT|3<<_FRAC

#define _C2  65ul<<_INT|2ul<<_FRAC
#define _CS2 69ul<<_INT|1ul<<_FRAC
#define _D2  73ul<<_INT|2ul<<_FRAC
#define _DS2 77ul<<_INT|3ul<<_FRAC
#define _E2  82ul<<_INT|2ul<<_FRAC
#define _F2  87ul<<_INT|1ul<<_FRAC
#define _FS2 92ul<<_INT|2ul<<_FRAC
#define _G2  98ul<<_INT
#define _GS2 103ul<<_INT|3ul<<_FRAC
#define _A2  110ul<<_INT
#define _AS2 116ul<<_INT|2ul<<_FRAC
#define _B2  123ul<<_INT|2ul<<_FRAC

#define _C3  130ul<<_INT|3ul<<_FRAC
#define _CS3 138ul<<_INT|2ul<<_FRAC
#define _D3  146ul<<_INT|3ul<<_FRAC
#define _DS3 155ul<<_INT|2ul<<_FRAC
#define _E3  164ul<<_INT|3ul<<_FRAC
#define _F3  174ul<<_INT|2ul<<_FRAC
#define _FS3 185ul<<_INT
#define _G3  196ul<<_INT
#define _GS3 207ul<<_INT|3ul<<_FRAC
#define _A3  220ul<<_INT
#define _AS3 233ul<<_INT
#define _B3  247ul<<_INT

#define _C4  261ul<<_INT|3ul<<_FRAC
#define _CS4 277ul<<_INT|1ul<<_FRAC
#define _D4  293ul<<_INT|3ul<<_FRAC
#define _DS4 311ul<<_INT|1ul<<_FRAC
#define _E4  329ul<<_INT|3ul<<_FRAC
#define _F4  349ul<<_INT|1ul<<_FRAC
#define _FS4 370ul<<_INT
#define _G4  392ul<<_INT
#define _GS4 415ul<<_INT|1ul<<_FRAC
#define _A4  440ul<<_INT
#define _AS4 466ul<<_INT|1ul<<_FRAC
#define _B4  494ul<<_INT

#define _C5  523ul<<_INT|1ul<<_FRAC
#define _CS5 554ul<<_INT|1ul<<_FRAC
#define _D5  587ul<<_INT|1ul<<_FRAC
#define _DS5 622ul<<_INT|1ul<<_FRAC
#define _E5  659ul<<_INT|1ul<<_FRAC
#define _F5  698ul<<_INT|2ul<<_FRAC
#define _FS5 740ul<<_INT
#define _G5  784ul<<_INT
#define _GS5 830ul<<_INT|2ul<<_FRAC
#define _A5  880ul<<_INT
#define _AS5 932ul<<_INT|1ul<<_FRAC
#define _B5  987ul<<_INT|3ul<<_FRAC

#define _C6  1046ul<<_INT|2ul<<_FRAC
#define _CS6 1108ul<<_INT|3ul<<_FRAC
#define _D6  1174ul<<_INT|3ul<<_FRAC
#define _DS6 1244ul<<_INT|2ul<<_FRAC
#define _E6  1318ul<<_INT|2ul<<_FRAC
#define _F6  1397ul<<_INT
#define _FS6 1480ul<<_INT
#define _G6  1568ul<<_INT
#define _GS6 1661ul<<_INT|1ul<<_FRAC
#define _A6  1760ul<<_INT
#define _AS6 1864ul<<_INT|3ul<<_FRAC
#define _B6  1975ul<<_INT|2ul<<_FRAC

#define _C7  2093ul<<_INT
#define _CS7 2217ul<<_INT|2ul<<_FRAC
#define _D7  2349ul<<_INT|1ul<<_FRAC
#define _DS7 2489ul<<_INT
#define _E7  2637ul<<_INT
#define _F7  2793ul<<_INT|3ul<<_FRAC
#define _FS7 2960ul<<_INT
#define _G7  3136ul<<_INT
#define _GS7 3322ul<<_INT|1ul<<_FRAC
#define _A7  3520ul<<_INT
#define _AS7 3729ul<<_INT|1ul<<_FRAC
#define _B7  3951ul<<_INT

#define _C8  4186ul<<_INT
#define _CS8 4435ul<<_INT
#define _D8  4698ul<<_INT|3ul<<_FRAC
#define _DS8 4978ul<<_INT
#define _E8  5274ul<<_INT
#define _F8  5587ul<<_INT|3ul<<_FRAC
#define _FS8 5920ul<<_INT
#define _G8  6272ul<<_INT
#define _GS8 6645ul<<_INT
#define _A8  7040ul<<_INT
#define _AS8 7458ul<<_INT|2ul<<_FRAC
#define _B8  7902ul<<_INT|1ul<<_FRAC

#define _KEY1  _A0
#define _KEY2  _AS0
#define _KEY3  _B0

#define _KEY4  _C1
#define _KEY5  _CS1
#define _KEY6  _D1
#define _KEY7  _DS1
#define _KEY8  _E1
#define _KEY9  _F1
#define _KEY10 _FS1
#define _KEY11 _G1
#define _KEY12 _GS1
#define _KEY13 _A1
#define _KEY14 _AS1
#define _KEY15 _B1

#define _KEY16 _C2
#define _KEY17 _CS2
#define _KEY18 _D2
#define _KEY19 _DS2
#define _KEY20 _E2
#define _KEY21 _F2
#define _KEY22 _FS2
#define _KEY23 _G2
#define _KEY24 _GS2
#define _KEY25 _A2
#define _KEY26 _AS2
#define _KEY27 _B2

#define _KEY28 _C3
#define _KEY29 _CS3
#define _KEY30 _D3
#define _KEY31 _DS3
#define _KEY32 _E3
#define _KEY33 _F3
#define _KEY34 _FS3
#define _KEY35 _G3
#define _KEY36 _GS3
#define _KEY37 _A3
#define _KEY38 _AS3
#define _KEY39 _B3

#define _KEY40 _C4
#define _KEY41 _CS4
#define _KEY42 _D4
#define _KEY43 _DS4
#define _KEY44 _E4
#define _KEY45 _F4
#define _KEY46 _FS4
#define _KEY47 _G4
#define _KEY48 _GS4
#define _KEY49 _A4
#define _KEY50 _AS4
#define _KEY51 _B4

#define _KEY52 _C5
#define _KEY53 _CS5
#define _KEY54 _D5
#define _KEY55 _DS5
#define _KEY56 _E5
#define _KEY57 _F5
#define _KEY58 _FS5
#define _KEY59 _G5
#define _KEY60 _GS5
#define _KEY61 _A5
#define _KEY62 _AS5
#define _KEY63 _B5

#define _KEY64 _C6
#define _KEY65 _CS6
#define _KEY66 _D6
#define _KEY67 _DS6
#define _KEY68 _E6
#define _KEY69 _F6
#define _KEY70 _FS6
#define _KEY71 _G6
#define _KEY72 _GS6
#define _KEY73 _A6
#define _KEY74 _AS6
#define _KEY75 _B6

#define _KEY76 _C7
#define _KEY77 _CS7
#define _KEY78 _D7
#define _KEY79 _DS7
#define _KEY80 _E7
#define _KEY81 _F7
#define _KEY82 _FS7
#define _KEY83 _G7
#define _KEY84 _GS7
#define _KEY85 _A7
#define _KEY86 _AS7
#define _KEY87 _B7

#define _KEY88 _C8
#define _KEY89 _CS8
#define _KEY90 _D8
#define _KEY91 _DS8
#define _KEY92 _E8
#define _KEY93 _F8
#define _KEY94 _FS8
#define _KEY95 _G8
#define _KEY96 _GS8
#define _KEY97 _A8
#define _KEY98 _AS8
#define _KEY99 _B8

#define _A0_INT  28ul<<_INT
#define _AS0_INT 29ul<<_INT
#define _B0_INT  31ul<<_INT

#define _C1_INT  33ul<<_INT
#define _CS1_INT 35ul<<_INT
#define _D1_INT  37ul<<_INT
#define _DS1_INT 39ul<<_INT
#define _E1_INT  41ul<<_INT
#define _F1_INT  44ul<<_INT
#define _FS1_INT 46ul<<_INT
#define _G1_INT  49ul<<_INT
#define _GS1_INT 52ul<<_INT
#define _A1_INT  55ul<<_INT
#define _AS1_INT 58ul<<_INT
#define _B1_INT  62ul<<_INT

#define _C2_INT  65ul<<_INT
#define _CS2_INT 69ul<<_INT
#define _D2_INT  73ul<<_INT
#define _DS2_INT 78ul<<_INT
#define _E2_INT  82ul<<_INT
#define _F2_INT  87ul<<_INT
#define _FS2_INT 92ul<<_INT
#define _G2_INT  98ul<<_INT
#define _GS2_INT 104ul<<_INT
#define _A2_INT  110ul<<_INT
#define _AS2_INT 117ul<<_INT
#define _B2_INT  123ul<<_INT

#define _C3_INT  131ul<<_INT
#define _CS3_INT 139ul<<_INT
#define _D3_INT  147ul<<_INT
#define _DS3_INT 156ul<<_INT
#define _E3_INT  165ul<<_INT
#define _F3_INT  175ul<<_INT
#define _FS3_INT 185ul<<_INT
#define _G3_INT  196ul<<_INT
#define _GS3_INT 208ul<<_INT
#define _A3_INT  220ul<<_INT
#define _AS3_INT 233ul<<_INT
#define _B3_INT  247ul<<_INT

#define _C4_INT  262ul<<_INT
#define _CS4_INT 277ul<<_INT
#define _D4_INT  294ul<<_INT
#define _DS4_INT 311ul<<_INT
#define _E4_INT  330ul<<_INT
#define _F4_INT  349ul<<_INT
#define _FS4_INT 370ul<<_INT
#define _G4_INT  392ul<<_INT
#define _GS4_INT 415ul<<_INT
#define _A4_INT  440ul<<_INT
#define _AS4_INT 466ul<<_INT
#define _B4_INT  494ul<<_INT

#define _C5_INT  523ul<<_INT
#define _CS5_INT 554ul<<_INT
#define _D5_INT  587ul<<_INT
#define _DS5_INT 622ul<<_INT
#define _E5_INT  659ul<<_INT
#define _F5_INT  698ul<<_INT
#define _FS5_INT 740ul<<_INT
#define _G5_INT  784ul<<_INT
#define _GS5_INT 831ul<<_INT
#define _A5_INT  880ul<<_INT
#define _AS5_INT 932ul<<_INT
#define _B5_INT  988ul<<_INT

#define _C6_INT  1047ul<<_INT
#define _CS6_INT 1109ul<<_INT
#define _D6_INT  1175ul<<_INT
#define _DS6_INT 1245ul<<_INT
#define _E6_INT  1319ul<<_INT
#define _F6_INT  1397ul<<_INT
#define _FS6_INT 1480ul<<_INT
#define _G6_INT  1568ul<<_INT
#define _GS6_INT 1661ul<<_INT
#define _A6_INT  1760ul<<_INT
#define _D6_INT  1175ul<<_INT
#define _DS6_INT 1245ul<<_INT
#define _E6_INT  1319ul<<_INT
#define _F6_INT  1397ul<<_INT
#define _FS6_INT 1480ul<<_INT
#define _G6_INT  1568ul<<_INT
#define _GS6_INT 1661ul<<_INT
#define _A6_INT  1760ul<<_INT
#define _AS6_INT 1865ul<<_INT
#define _B6_INT  1976ul<<_INT

#define _C7_INT  2093ul<<_INT
#define _CS7_INT 2217ul<<_INT
#define _D7_INT  2349ul<<_INT
#define _DS7_INT 2489ul<<_INT
#define _E7_INT  2637ul<<_INT
#define _F7_INT  2794ul<<_INT
#define _FS7_INT 2960ul<<_INT
#define _G7_INT  3136ul<<_INT
#define _GS7_INT 3322ul<<_INT
#define _A7_INT  3520ul<<_INT
#define _AS7_INT 3729ul<<_INT
#define _B7_INT  3951ul<<_INT

#define _C8_INT  4186ul<<_INT
#define _CS8_INT 4435ul<<_INT
#define _D8_INT  4699ul<<_INT
#define _DS8_INT 4978ul<<_INT
#define _E8_INT  5274ul<<_INT
#define _F8_INT  5588ul<<_INT
#define _FS8_INT 5920ul<<_INT
#define _G8_INT  6272ul<<_INT
#define _GS8_INT 6645ul<<_INT
#define _A8_INT  7040ul<<_INT
#define _AS8_INT 7459ul<<_INT
#define _B8_INT  7902ul<<_INT
