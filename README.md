# v65C02 8-bit Computer for the Nexys 4 DDR

## Description:
Verilog and assembler source to implement a 65C02 based 8-bit computer on the [Digilent Nexys 4 DDR](http://store.digilentinc.com/nexys-4-ddr-artix-7-fpga-trainer-board-recommended-for-ece-curriculum/) FPGA development board.

### Hardware Specifications:
* [verilog-65C02](https://github.com/hoglet67/verilog-6502) soft core
* 44K x 8-bit RAM
* 16K x 8-bit ROM
* 80x25 16-color text (720x400 @ 70Hz)
    * 4K x 8-bit Video RAM
    * 4K x 8-bit Character ROM
* PS/2 Keyboard
* UART
* 32-bit Timer
* Eight digit seven-segment display

The user must generate the system and pixel clocks in the top-level module using the Xilinx Clocking Wizard. Due to copyright restrictions, the clock IP is not included with this repository.

### BIOS Specifications:
* Initializes system
    * Clears screen and turns on cursor
    * Clears seven-segment display
    * Clears keyboard buffer
    * Prints BIOS information to screen
    * Executes ROM monitor

The ROM monitor has five different functions:

* Dump 16 bytes of memory to the screen
* Write bytes in either 8- or 16-bit format to memory
* Execute code at address $0300
* Receive a file via XMODEM and store at address $0300
* Print a help menu

To print the help menu, type ```?``` and press enter. Dumping memory to screen is accomplished by entering an address. For example, to see the contents of $B000, you would type ```b000``` and press enter. To write a set of data at an address, follow the typed address with the bytes or words in hexadecimal format, separated by spaces. For example, to enter the values 1, 2, and 3 starting at address $0300, you would type ```300 1 2 3``` and press enter. To receive a file or execute code, you would type ```x``` or ```g``` respectively.

The BIOS has several system calls, starting from 0:

* Soft Reset
* Write Character at Current Cursor
* Write String at Current Cursor
* Set Cursor Position
* Scroll Screen Down One Line
* Wait for Keystroke and Read

See the ROM monitor source code for examples of their use.

### Example Program:
A "Hello, World!" program has been included, with supporting library, to test the XMODEM receive and code execution function.

### Legal:
The original verilog-6502 soft core is copyright (C) Arlet Ottens, and the 65C02 extensions are copyright (C) 2016 David Banks and Ed Spittles.

The assembly sources and remaining Verilog sources are copyright (C) 2018 Ryan Clarke under the GNU General Public License Version 3.

Character ROM data is derived from the *IBM VGA8* font contained in [The Ultimate Oldschool PC Font Pack](http://int10h.org/oldschool-pc-fonts/) and is copyright (C) 2016 VileR under the Creative Commons Attribution-ShareAlike 4.0 International License.
