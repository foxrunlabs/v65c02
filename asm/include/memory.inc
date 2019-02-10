;===============================================================================
;Copyright (C) 2018 Ryan Clarke
;
;This program is free software (firmware): you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 3 of the License, or
;(at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;===============================================================================

;===============================================================================
; Program   : v65C02 BIOS
; File Name : memory.inc
; Project   : v65C02 8-bit Computer
; Author    : Ryan Clarke
; E-mail    : kj6msg@icloud.com
;===============================================================================
; Purpose : Memory addresses for the v65C02 BIOS.
;===============================================================================


;= ABSOLUTE ADDRESSES ==========================================================

ZP          = $0000
STACK       = $0100
RAM         = $0200
VRAM_START  = $B000
VRAM_END    = VRAM_START + $0F9F

VGA         = $BFA0
VGA_STATUS  = VGA + 0
VGA_CURSL   = VGA + 1
VGA_CURSH   = VGA + 2

SSEG        = $BFA8
SSEG_DIGITS = SSEG + 0
SSEG_DP     = SSEG + 1
SSEG_BYTE0  = SSEG + 2
SSEG_BYTE1  = SSEG + 3
SSEG_BYTE2  = SSEG + 4
SSEG_BYTE3  = SSEG + 5

UART        = $BFB0
UART_STATUS = UART + 0
UART_BRGL   = UART + 1
UART_BRGH   = UART + 2
UART_TXREG  = UART + 3
UART_RXREG  = UART + 4

KBD         = $BFB8
KBD_STATUS  = KBD + 0
KBD_RXREG   = KBD + 1
KBD_TXREG   = KBD + 2

TMR         = $BFC0
TMR_STATUS  = TMR + 0
TMR_TIMER08 = TMR + 1
TMR_TIMER16 = TMR + 2
TMR_TIMER24 = TMR + 3
TMR_TIMER32 = TMR + 4

BIOS_ROM    = $C000


;= ZERO PAGE ADDRESSES =========================================================

; General registers
R0 = $00
R1 = $01
R2 = $02
R3 = $03
R4 = $04
R5 = $05
R6 = $06
R7 = $07
R8 = $08
R9 = $09
RA = $0A
RB = $0B
RC = $0C
RD = $0D
RE = $0E
RF = $0F

; Console routines
COL   = $10
ROW   = $11
ATTR  = $12
VRAM  = $13
VRAML = $13
VRAMH = $14
STR   = $15
STRL  = $15
STRH  = $16
COL8  = $17
CURS  = $18
CURSL = $18
CURSH = $19
CURST = $1A

; XMODEM receiver
BLOCK  = $1B
CHKSUM = $1C
DATA   = $1D
DATAL  = $1D
DATAH  = $1E
ERROR  = $1F

; Conversion routines
BYTE  = $20
WORD  = $21
WORDL = $21
WORDH = $22
HSTR  = $23
HSTRL = $23
HSTRH = $24
DSTR  = $25

; Monitor
INPUT = $2B
MEM   = $35
MEML  = $35
MEMH  = $36
BUF   = $37

; BIOS Routines
BIOSLO = $47
BIOSHI = $49
PARAM1 = $4B
PARAM2 = $4C
