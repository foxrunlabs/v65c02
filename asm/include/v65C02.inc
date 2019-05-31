;===============================================================================
; Copyright 2018-2019 Ryan Clarke
;
; Licensed under the Apache License, Version 2.0 (the "License"); you may not
; use this file except in compliance with the License. You may obtain a copy of
; the License at
; 
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
; WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
; License for the specific language governing permissions and limitations under
; the License.
;===============================================================================

;===============================================================================
; Program   : v65C02 BIOS
; File Name : v65C02.inc
; Project   : v65C02 8-bit Computer
; Author    : Ryan Clarke
; E-mail    : kj6msg@icloud.com
;===============================================================================
; Purpose : Constant definitions for the v65C02 BIOS.
;===============================================================================


;===============================================================================
; ZERO PAGE MEMORY MAP
;===============================================================================

;= GENERAL REGISTERS ===========================================================

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


;= BIOS ========================================================================

;- console routines ------------------------------------------------------------
COL     = $10               ; current cursor column
ROW     = $11               ; current cursor row
ATTR    = $12               ; character attribute
VRAM    = $13               ; video RAM pointer
VRAML   = $13               ; video RAM pointer LSB
VRAMH   = $14               ; video RAM pointer MSB
STR     = $15               ; string pointer (puts routine)
STRL    = $15               ; string pointer LSB
STRH    = $16               ; string pointer MSB
CURS    = $17               ; cursor address
CURSL   = $17               ; cursor address LSB
CURSH   = $18               ; cursor address MSB
CURSTMP = $19               ; cursor temp (gotoxy routine)
SCROLL  = $1A               ; next line video RAM pointer (scrolldn routine)
SCROLLL = $1A               ; next line video RAM pointer LSB
SCROLLH = $1B               ; next line video RAM pointer MSB

;- call table address ----------------------------------------------------------
BIOSTL  = $1C               ; call table (LSB) pointer
BIOSTLL = $1C               ; call table (LSB) pointer LSB
BIOSTLH = $1D               ; call table (LSB) pointer MSB
BIOSTH  = $1E               ; call table (MSB) pointer
BIOSTHL = $1E               ; call table (MSB) pointer LSB
BIOSTHH = $1F               ; call table (MSB) pointer MSB


;= ROM MONITOR =================================================================

;- ROM monitor -----------------------------------------------------------------
MODE    = $20               ; store mode: 0 = addres, 1 = byte
ADDR    = $21               ; address pointer
ADDRL   = $21               ; address pointer LSB
ADDRH   = $22               ; address pointer MSB

XBLOCK  = $23               ; XMODEM block number
XCHKSUM = $24               ; XMODEM checksum
XDATA   = $25               ; XMODEM data pointer
XDATAL  = $25               ; XMODEM data pointer LSB
XDATAH  = $26               ; XMODEM data pointer MSB
XERROR  = $27               ; XMODEM error

BUF     = $28               ; buffer address
CMDLN   = $28               ; command line address


;===============================================================================
; CONSTANTS
;===============================================================================

;= Screen Size =================================================================
            
NUMCOLS = 80                ; 80 character columns
NUMROWS = 30                ; 30 character rows


;= ASCII Character Constants ===================================================

NUL  = $00
SOH  = $01
_STX = $02
ETX  = $03
EOT  = $04
ENQ  = $05
ACK  = $06
BEL  = $07
BS   = $08
HT   = $09
LF   = $0A
VT   = $0B
FF   = $0C
CR   = $0D
SO   = $0E
SI   = $0F
DLE  = $10
DC1  = $11
DC2  = $12
DC3  = $13
DC4  = $14
NAK  = $15
SYN  = $16
ETB  = $17
CAN  = $18
EM   = $19
SUB  = $1A
ESC  = $1B
FS   = $1C
GS   = $1D
RS   = $1E
US   = $1F
DEL  = $7F


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


;===============================================================================
; HARDWARE DEVICES
;===============================================================================

;= VIDEO RAM ===================================================================

VRAM_PAGE = %00010000                   ; VRAM page bit mask


;= IO MEMORY MAP ===============================================================

IO          = $E000

;- device 0 --------------------------------------------------------------------
VGA         = IO + $000
VGA_STATUS  = VGA + 0
VGA_CURSL   = VGA + 1
VGA_CURSH   = VGA + 2

;- device 1 --------------------------------------------------------------------
KBD         = IO + $100
KBD_STATUS  = KBD + 0
KBD_DATA    = KBD + 1

;- device 2 --------------------------------------------------------------------
UART        = IO + $200
UART_STATUS = UART + 0
UART_BRGL   = UART + 1
UART_BRGH   = UART + 2
UART_TXREG  = UART + 3
UART_RXREG  = UART + 4

;- device 3 --------------------------------------------------------------------
TMR         = IO + $300
TMR_STATUS  = TMR + 0
TMR_TIMER08 = TMR + 1
TMR_TIMER16 = TMR + 2
TMR_TIMER24 = TMR + 3
TMR_TIMER32 = TMR + 4

;- device 4 --------------------------------------------------------------------
SSEG        = IO + $400
SSEG_DIGITS = SSEG + 0
SSEG_DP     = SSEG + 1
SSEG_BYTE0  = SSEG + 2
SSEG_BYTE1  = SSEG + 3
SSEG_BYTE2  = SSEG + 4
SSEG_BYTE3  = SSEG + 5

;- device 5 --------------------------------------------------------------------
DEVICE5     = IO + $500

;- device 6 --------------------------------------------------------------------
DEVICE6     = IO + $600

;- device 7 --------------------------------------------------------------------
DEVICE7     = IO + $700

;- device 8 --------------------------------------------------------------------
DEVICE8     = IO + $800

;- device 9 --------------------------------------------------------------------
DEVICE9     = IO + $900

;- device 10 -------------------------------------------------------------------
DEVICE10    = IO + $A00

;- device 11 -------------------------------------------------------------------
DEVICE11    = IO + $B00

;- device 12 -------------------------------------------------------------------
DEVICE12    = IO + $C00

;- device 13 -------------------------------------------------------------------
DEVICE13    = IO + $D00

;- device 14 -------------------------------------------------------------------
DEVICE14    = IO + $E00

;- device 15 -------------------------------------------------------------------
DEVICE15    = IO + $F00


;= DEVICE REGISTERS ============================================================

;- VGA status register bits ----------------------------------------------------
VGA_EN       = %00000001                ; EN bit mask of VGA STATUS register
VGA_CURS     = %00000010                ; CURS bit mask for VGA STATUS register

;- keyboard status register bits -----------------------------------------------
KBD_DATAFULL = %00000001                ; keyboard data register full

;- UART status register bits ---------------------------------------------------
UART_TXBUSY  = %00000001                ; UART transmit busy
UART_RXFULL  = %00000010                ; UART receive buffer full

;- timer status register bits --------------------------------------------------
TMR_OVRFL    = %00000001                ; timer overflow


;= UART baud rate generator values ---------------------------------------------

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
