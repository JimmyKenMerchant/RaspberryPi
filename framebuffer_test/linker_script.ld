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
	.vector : {
		*(.vector)

		/* Add size, 65,536 bytes to the end of .vector as HEAP */
		. += 0x1000;
	}

	.text : {
		*(.text)
	}

	.data : {
		*(.data)
	}

	.bss : {
		*(.bss)
	}

}