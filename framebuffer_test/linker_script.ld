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

		/* Add size, 65,536 bytes to the end of .vector as HEAP */
		. += 0x10000;
	}

	.renderbuffer32 : {
		aloha_kernel32.o(.renderbuffer)

		/* Reserve size, 16,777,216 bytes */
		. = 0x1000000;
	}

	.text : {
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