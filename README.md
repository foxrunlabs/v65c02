# v65C02 — FPGA 8-Bit Computer

**A 65C02-based computer implemented in Verilog for the Digilent Nexys 4 DDR, with a text-mode VGA display, PS/2 keyboard, serial interface, and assembly-language BIOS and ROM monitor.**

v65C02 brings processor, memory, and peripheral logic together inside an FPGA. The project explores the complete hardware/software path from memory-mapped peripheral registers to firmware routines and an interactive machine-code monitor.

The engineering work centers on adapting an existing soft-core CPU, designing and integrating the surrounding digital system, and writing the firmware that operates it.

## Highlights

- **FPGA system integration:** a 65C02-compatible CPU connected to synchronous memory and memory-mapped peripherals.
- **Text-mode video:** 80×30 characters at 640×480, with separate character and color-attribute memory, foreground/background colors, and a hardware cursor.
- **Peripheral design:** PS/2 keyboard input, UART transmit/receive, a programmable 32-bit timer, and an eight-digit seven-segment display controller.
- **Embedded firmware:** a 65C02 assembly BIOS and ROM monitor, built with the cc65 toolchain.
- **Development infrastructure:** Verilog testbenches, board constraints, and Tcl helpers for updating BIOS data in a generated bitstream.

## Architecture

```text
                      Nexys 4 DDR FPGA
  +------------------------------------------------------+
  |                                                      |
  |  65C02-compatible CPU                                 |
  |           |                                          |
  |    Address decoding and registered read-data mux      |
  |           |                                          |
  |    +------+------+--------+------+-------+-------+   |
  |    |      |      |        |      |       |       |   |
  |   RAM    ROM    VGA      PS/2   UART    Timer   SSEG   |
  |                 |                                    |
  |          Character / attribute RAM                   |
  |          Font ROM and video timing                   |
  |                                                      |
  |  Clock generation, reset, and input conditioning      |
  +------------------------------------------------------+
```

The CPU uses a 16-bit address bus and separate 8-bit read and write data buses. Address decoding selects memory or peripheral registers; a registered selection stage aligns read data with the CPU's one-clock memory interface.

### Memory Map

| Address range | Function | Mapped size |
| --- | --- | --- |
| `$0000–$BFFF` | General-purpose RAM, including zero page and stack | 48 KiB |
| `$C000–$CFFF` | Video character RAM | 4 KiB |
| `$D000–$DFFF` | Video attribute RAM | 4 KiB |
| `$E000–$EFFF` | Memory-mapped peripheral region | 4 KiB |
| `$F000–$FFFF` | BIOS and ROM monitor | 4 KiB |

The RAM module is instantiated with a 64 KiB backing array, but address decoding exposes 48 KiB as general-purpose RAM. Font storage is a separate 4 KiB ROM used by the video subsystem.

Peripheral register blocks begin at `$E000` for VGA, `$E100` for the keyboard, `$E200` for the UART, `$E300` for the timer, and `$E400` for the seven-segment display. Register definitions are in `asm/include/v65C02.inc`.

## Hardware Design

### Processor

The processor derives from Arlet Ottens' 6502 core, with 65C02 extensions by David Banks and Ed Spittles. This project adapts its module and port naming and integrates it with the computer's memory and peripherals. The upstream implementation is credited in the CPU and ALU source headers; it is not an original CPU design by this project's author.

### VGA Display

The video pipeline separates timing generation, character generation, color decoding, and output synchronization. It uses 8×16 glyphs to display 80 columns and 30 rows, with 4-bit foreground and background color values translated to RGB444 output.

Dual-port character and attribute memories allow CPU access and display scanning on separate clocks. Control registers enable the display and cursor and select the cursor position. The committed timing configuration targets 640×480 at approximately 60 Hz.

### Input and Peripherals

The PS/2 subsystem receives keyboard scan codes and converts them to ASCII for firmware access. The UART provides serial transmit/receive registers and a programmable baud-rate generator. The timer exposes a programmable 32-bit interval and a polled overflow flag. The display controller drives the board's eight seven-segment digits.

The clock module directly instantiates Xilinx `IBUF`, `MMCME2_BASE`, and `BUFG` primitives. Its configuration derives a 50 MHz CPU clock and an approximately 25.2 MHz pixel clock from the board's 100 MHz oscillator.

## BIOS and ROM Monitor

The BIOS initializes the display, seven-segment registers, firmware call table, and keyboard buffer, prints startup information, and enters the ROM monitor.

Firmware services include screen clearing, cursor positioning, scrolling, character and attribute access, string output, keyboard input, and UART input/output. The call table in `asm/src/bios.a65` defines the service order.

The monitor supports:

| Input | Operation |
| --- | --- |
| `b000` | Display 16 bytes beginning at `$B000`. |
| `200 1 2 3` | Write hexadecimal values starting at `$0200`. |
| `g` | Call code at `$0200` and return to the monitor when it returns. |
| `x` | Receive data through the UART using XMODEM, starting at `$0200`. |
| `?` | Display command help. |

The committed instructions use `$0200` for program execution and XMODEM loading. Some older comments and documentation refer to `$0300`; the executable instructions determine the behavior described here.

## Building and Working with the Sources

### Firmware

The assembly build requires `ca65` and `ld65` from cc65, Make, and the utilities used by `asm/bin2mem.sh` and `asm/bin2hex.sh`.

From the repository root:

```sh
cd asm
make
make install
```

The Makefile assembles the BIOS and monitor and produces `bios.rom`, `bios.mem`, and `bios.hex`. The install target copies the memory image to `bram_data/` and the hexadecimal image to `hdl/memory/`.

### FPGA Implementation

Use a Xilinx Vivado environment targeting the Nexys 4 DDR's Artix-7 FPGA:

1. Create a project and add the hardware sources under `hdl/`.
2. Set `v65C02_Top` as the top-level module and add `Nexys4DDR.xdc`.
3. Build the BIOS and add its generated `bios.hex` initialization file.
4. Supply a compatible 4 KiB `font.hex` image for the character ROM.
5. Review constraints and initialization-file paths, then synthesize, implement, and generate a bitstream.

The Tcl helpers under `tcl/` support inspecting BIOS BRAM placement and patching BIOS data into an existing bitstream with `updatemem`. The memory mapping information must match the implemented design.

### Simulation

The `sim/` directory contains 16 Verilog testbench files covering reset, debounce, keyboard, UART, VGA, timer, and seven-segment logic. Several testbenches retain older module or port names and need reconciliation with the current HDL before use. A passing automated regression suite is not established by their presence.

## Development Status

The project contains an integrated hardware design and BIOS/monitor implementation.

Reproducing the project requires supplying the font image, creating the FPGA project, and resolving stale testbench interfaces.

## Credits and Licensing

v65C02 BIOS is available under the [Apache License 2.0](LICENSES/Apache-2.0.txt).

v65C02 Verilog source is available under the [Solderpad Hardware License 2.0](LICENSES/Solderpad-2.0.txt)

Copyright © 2019 Ryan Clarke

Original 6502 CPU Verilog source is Copyright © Arlet Owens and  65C02 CPU Verilog is Copyright © 2016 David Banks and Ed Spittles. See source for license details.
