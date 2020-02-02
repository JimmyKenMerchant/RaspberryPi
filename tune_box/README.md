# Tune Box

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

### Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Purpose**

* Tune Box is a sibling of Sound Box. In addition to the selectable sound of Sound Box from I2S, Tune Box has two outputs of pulse wave from PWM; and high or low state from GPIO. These outputs are synchronized.

* Differences from Sound Box are as follows.
	* Selectable Sound of Sound Box Only from I2S.
	* Two PWM Sequences for Pulses
	* Two GPIO Sequences for High/low State: GPIO 2-7 are set as outputs.
	* `soundle=jack` at making sets two pulses from the jack port (2B and 3B). In my experience, the first pulse to emit sequentially is approx. +3dB higher than next pulses because of no bias voltage. If you record the pulses, it may be an issue. However, in view of analogue output, it may be enough as normalized.
