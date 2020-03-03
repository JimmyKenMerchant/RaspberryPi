# DMX512 Transmitter Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

## Purpose

* Test of Protocol of DMX512: Not yet tested with a RS485 transceiver.

## Output and Input

* GPIO14 as TXD0

* GPIO15 as Output of Busy Toggle for Acknowledgment of Command from Parallel Bus

* GPIO16 as Output of EOP (End of Packet) Toggle

* GPIO27 as Input of Clock IN for Parallel Bus (Detects Status of Parallel Bus on Falling Edge of Clock IN)

* GPIO22-26 as Input of GPIO for Parallel Bus: CAUTION! DON'T MAKE A SHORT CIRCUIT BETWEEN POWER SOURCE AND GROUND. OTHERWISE YOUR RASPBERRY PI WILL BE BROKEN. CHECK OUT GPIO MAP SO CAREFULLY.

* HDMI as VIDEO Output (For Debug Only)

### GPIO ARE UP TO VOLTAGE OF 3.3V TO INPUT!!! DON'T INPUT VOLTAGE OVER 3.3V TO GPIO PIN!!! OTHERWISE, YOU WILL BE IN DANGER!!! IF YOU CAN'T UNDERSTAND ABOUT THIS, PLEASE STUDY ELECTRONICS FOR A WHILE BEFORE DOING THIS.

## Parallel Bus: Bit[4:0]

* 0x00 (0) - 0x0F (15) for Sending Data
	* Bit[3:0] at First Sending
	* Bit[7:4] at Second Sending
	* Bit[8] at Third Sending (Only for Slot Index Mode)
	* Bit positions are changed by sending as follows.
		* The position is changed to Bit[3:0] - Bit[7:4] alternatively on the slot value mode.
		* Bit[3:0] - Bit[7:4] - Bit[8] then the position is backed to Bit[3:0] on the slot index mode.

* 0x10 (16) - 0x1F (31) for Sending Command
	* 0x10 (16): Reset Data Position to LSB (All Commands Reset Data Position)
	* 0x11 (17): Select Slot Index Mode to Send Data (Default)
	* 0x12 (18): Select Slot Value Mode to Send Data
	* 0x13 (19): Select Slot Value Sequentially Mode to Send Data
	* 0x14 (20): Store Value to BACK Buffer in Slot Value Mode (default)
	* 0x15 (21): Store Value to FRONT Buffer in Slot Value Mode
	* 0x16 (22) - 0x19 (25): Reserved
	* 0x1A (26): Start Tx
	* 0x1B (27): Set Repeat Tx
	* 0x1C (28): Clear Repeat Tx, Pause after End of Packet (Default)
	* 0x1D (29): Swap FRONT/BACK Buffer
	* 0x1E (30): Tx Send FRONT Buffer (Default)
	* 0x1F (31): Tx Send FRONT and Swap FRONT/BACK Buffer on End of Packet

* Busy Toggle is an acknowledgment of sending command and data. It's useful to know the timing of the next sending.

* Procedure on Flushing Method with Single Sending of Slot Value
	* Command 0x1E (30) to Tx Send FRONT Buffer
	* Command 0x15 (21) to Store Value to FRONT Buffer in Slot Value Mode
	* Command 0x1C (28) to Clear Repeat Tx
		1. Command 0x11 (17) to Select Slot Index Mode and Send Data
		2. Command 0x12 (18) to Select Slot Value Mode and Send Data to Back Buffer
		3. Back to No.1 If Any Other Changes Exist
		4. Command 0x1A (26) to Start Tx
		5. Back to No.1

* Procedure on Flushing Method with Sequential Sending of Slot Value
	* Command 0x1F (31) to Tx Send FRONT and Swap FRONT/BACK Buffer on End of Packet
	* Command 0x14 (20) to Store Value to BACK Buffer in Slot Value Mode
	* Command 0x1B (27) to Set Repeat Tx
	* Command 0x11 (17) to Select Slot Index Mode and Send 0x00
	* Command 0x13 (19) to Select Slot Value Sequentially Mode and Send Data for Initial Values (513 Slots) to Back Buffer
	* Command 0x1D (29) to Swap FRONT/BACK Buffer
	* Command 0x1A (26) to Start Tx
		1. Send Data for Values (513 Slots) to Back Buffer: Must Be Finished Before Next EOP (Approx. 1s / 44hz = 22ms).
		2. Poll EOP Toggle
		3. If Low/High Change on EOP Toggle, Back to No.1

## Compatibility

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`
