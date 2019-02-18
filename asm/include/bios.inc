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
; File Name : ascii.inc
; Project   : v65C02 8-bit Computer
; Author    : Ryan Clarke
; E-mail    : kj6msg@icloud.com
;===============================================================================
; Purpose : BIOS include file
;===============================================================================


;= ZERO PAGE MAP ===============================================================

;- General registers -----------------------------------------------------------
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

;- Console routines ------------------------------------------------------------
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

;- XMODEM receiver -------------------------------------------------------------
BLOCK  = $1B
CHKSUM = $1C
DATA   = $1D
DATAL  = $1D
DATAH  = $1E
ERROR  = $1F

;- Conversion routines ---------------------------------------------------------
BYTE  = $20
WORD  = $21
WORDL = $21
WORDH = $22
HSTR  = $23
HSTRL = $23
HSTRH = $24
DSTR  = $25

;- ROM Monitor -----------------------------------------------------------------
INPUT = $2B
MEM   = $35
MEML  = $35
MEMH  = $36
BUF   = $37

;- BIOS Routines ---------------------------------------------------------------
BIOSTL  = $47
BIOSTLL = $47
BIOSTLH = $48
BIOSTH  = $49
BIOSTHL = $49
BIOSTHH = $4A

;- Keyboard Map ----------------------------------------------------------------

KEYMAP    = $4B
KEYMAPL   = $4B
KEYMAPH   = $4C
KEYMAPSH  = $4D
KEYMAPSHL = $4D
KEYMAPSHH = $4E

;- Scrolling -------------------------------------------------------------------

SCROLL  = $4F
SCROLLL = $4F
SCROLLH = $50


;= ASCII Character Constants ===================================================

NUL = $00
SOH = $01
EOT = $04
ACK = $06
BS  = $08
TAB = $09
LF  = $0A
CR  = $0D
NAK = $15
CAN = $18
ESC = $1B


;= TEXT COLORS =================================================================

BLACK         = $00
BLUE          = $01
GREEN         = $02
CYAN          = $03
RED           = $04
MAGENTA       = $05
BROWN         = $06
LIGHT_GRAY    = $07
DARK_GRAY     = $08
LIGHT_BLUE    = $09
LIGHT_GREEN   = $0A
LIGHT_CYAN    = $0B
LIGHT_RED     = $0C
LIGHT_MAGENTA = $0D
YELLOW        = $0E
WHITE         = $0F


;= DEVICE MAP ==================================================================

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


;= VGA STATUS REGISTER BITS ====================================================

VGA_EN   = %00000001                    ; EN bit of VGA STATUS register
VGA_CURS = %00000010                    ; CURS bit mask for VGA STATUS register


;= KEYBOARD STATUS REGISTER BITS ===============================================

DATA_RDY = %00000001                   ; data ready status bit
RX_ERR   = %00000010                   ; receive error
TX_BUSY  = %00000100                   ; transmit busy status bit
TX_ERR   = %00001000                   ; transmit error
SHIFT    = %00010000                   ; shift key status bit
CTRL     = %00100000                   ; control key status bit
ALT      = %01000000                   ; alt key status bit


;= KEYBOARD COMMANDS ===========================================================

ECHO = $EE


;= UART STATUS REGISTER BITS ===================================================

TXBUSY = %00000001
RXFULL = %00000010


;= UART BAUD RATE GENERATOR VALUES =============================================

B110     = 28408
B300     = 10416
B600     = 5207
B1200    = 2603
B2400    = 1301
B4800    = 650
B9600    = 325
B14400   = 216
B19200   = 162
B28800   = 108
B38400   = 80
B56000   = 55
B57600   = 53
B115200  = 26
B128000  = 23
B230400  = 13
B256000  = 11
B460800  = 6
B500000  = 5
B512000  = 5
B921600  = 2
B1000000 = 2
B1024000 = 2
B1562500 = 1
