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
; File Name : keyboard.inc
; Project   : v65C02 8-bit Computer
; Author    : Ryan Clarke
; E-mail    : kj6msg@icloud.com
;===============================================================================
; Purpose : Keyboard macros for the v65C02 BIOS.
;===============================================================================


;= REGISTER BITS ===============================================================

DATA_RDY = %00000001                   ; data ready status bit
RX_ERR   = %00000010                   ; receive error
TX_BUSY  = %00000100                   ; transmit busy status bit
TX_ERR   = %00001000                   ; transmit error
SHIFT    = %00010000                   ; shift key status bit
CTRL     = %00100000                   ; control key status bit
ALT      = %01000000                   ; alt key status bit


;= COMMANDS ====================================================================

ECHO = $EE
