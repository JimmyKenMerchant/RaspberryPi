/**
 * linker_script.ld
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * Linker Script for ARM Baremetal for Raspberry Pi
 */

/* Wildcards before parenthesis in curly brackets mean any file to link */

SECTIONS {

	/* Assign Address */
	. = 0x8000;
	.vector32 : {
		aloha_kernel32.o(.vector)
		. = 0x2000;
	}
	. = 0xA000;
	.text : {
		system32.o(.text)
		/* Add size, 16,777,216 bytes to the end of .vector */
		. += 0x1000000;

		/* Remaining Other than system32.o */
		*(.text)
	}

	.data : {
		*(.data)
	}

	.rodata : {
		*(.rodata)
	}

	.bss : {
		*(.bss)
	}

}