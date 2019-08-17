# V3D Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Output/Input**

* GPIO 47 (ACT LED) as Output

* HDMI as VIDEO Output

**Compatibility**

* Under Construction

**About QPU**

BCM2835, BCM2836, and BCM2837 have 16 QPUs. A QPU has 16 elements, so the QPU runs the assigned code in 16 ways parallelly. The element number can be obtained in codes. An allotment of vertex attribute is served to each element if you control shaders.

**VC4ASM**

```bash
vc4asm -V -o qasm_sample1.bin -I /usr/local/share/vc4inc/ -i vc4.qinc qasm_sample1.qasm
vc4dis -V -o qasm_sample1_dis.qasm -v qasm_sample1.bin
```
