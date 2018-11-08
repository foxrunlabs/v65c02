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

DATA_RDY  = %00000001                   ; data ready status bit
SHIFT     = %00000010                   ; shift key status bit
CTRL      = %00000100                   ; control key status bit
ALT       = %00001000                   ; alt key status bit
TCVR_BUSY = %00010000                   ; transceiver busy status bit
