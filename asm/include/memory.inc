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
VRAM_START  = $8000
VRAM_END    = VRAM_START + $1000
VGA_STATUS  = $9000
VGA_CURSL   = $9001
VGA_CURSH   = $9002
SSEG_DIGITS = $9100
SSEG_DP     = $9101
SSEG_BYTE0  = $9102
SSEG_BYTE1  = $9103
SSEG_BYTE2  = $9104
SSEG_BYTE3  = $9105
SSEG_DIGIT0 = $9106
SSEG_DIGIT1 = $9107
SSEG_DIGIT2 = $9108
SSEG_DIGIT3 = $9109
SSEG_DIGIT4 = $910A
SSEG_DIGIT5 = $910B
SSEG_DIGIT6 = $910C
SSEG_DIGIT7 = $910D
UART_STATUS = $9200
UART_BRGL   = $9201
UART_BRGH   = $9202
UART_TXREG  = $9203
UART_RXREG  = $9204
KBD_STATUS  = $9300
KBD_RXREG   = $9301
KBD_TXREG   = $9302
TMR_STATUS  = $9400
TMR_TIMER08 = $9401
TMR_TIMER16 = $9402
TMR_TIMER24 = $9403
TMR_TIMER32 = $9404
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
