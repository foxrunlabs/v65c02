# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Initialization of SSEG controller added to BIOS startup code.
### Changed
- v65C02 IP core changed to maximize RAM use. IO devices now between $BFA0-$BFFF, video RAM between $B000-$BF9F, and program RAM between $0200-$AFFF (44 KiB total). Limited to 12 IO devices, with 8 registers each. This removed the individual digit registers for the SSEG.
- Updated peripherals to reference register select lines, vice address lines. Split the register and VRAM lines in the VGA controller.
- Updated test benches to reflect changes.
### Fixed
- Fixed issue in htou8 routine. If high byte invalid, routine would not clear stack, resulting in crash.

## [1.1.0] - 2018-11-29
###
- BIOS subroutine table and appropriate zero page locations to access it from user software. Intended to be used as an RTS table.

## [1.0.0] - 2018-11-28
### Added
- PS/2 keyboard controller implemented as a transceiver module with separate receiver and transmitter.
### Changed
- Implemented a new zero page memory map, including 16 general purpose "registers."
- XMODEM receiver stores file at $0200 and the run command executes at $0200.
### Fixed
- Pull-ups enabled on PS/2 pins.
- CPU Reset button properly debounced.
- clrln routine fixed.

## [0.3.0] - 2018-10-15
### Added
- Implemented an XMODEM receiver to store a file at $0300.

## [0.2.1] - 2018-10-15
### Fixed
- Fixed monitor to show XMODEM vice YMODEM.

## [0.2.0] - 2018-10-15
### Added
- 32-bit one-shot timer.
### Changed
- Memory map updated to reflect addition of the timer.

## [0.1.0] - 2018-10-05
### Added
- Initial public release of the v65C02 8-bit Computer.
- v65C02 BIOS monitor program functions correctly with the exception of the YMODEM receiver.

## [0.0.0-alpha] - 2017-12-07
### Added
- Initial development started.
- Private code only. No public release.