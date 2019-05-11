#===============================================================================
# Copyright 2018-2019 Ryan Clarke
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#===============================================================================

#===============================================================================
# File Name : makefile
# Project   : v65C02 8-bit Computer
# Author    : Ryan Clarke
# E-mail    : kj6msg@icloud.com
#===============================================================================
# Purpose : Makefile for the v65C02 8-bit Computer BIOS
#===============================================================================


SHELL = /bin/sh

prefix      = ..
exec_prefix = $(prefix)
bin_dir     = $(exec_prefix)/bram_data

BIOS     = bios.rom
BIOS_MEM = bios.mem
BIOS_HEX = bios.hex
OBJECTS  = bios.o monitor.o

AS       = ca65
ASFLAGS  = --cpu 65C02 -l $(basename $@).lst -t none -I ./include/

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = -C $(LDCONFIG) -m $(basename $@).map -o $(BIOS)

BIN2MEM  = ./bin2mem.sh
BIN2HEX  = ./bin2hex.sh

.PHONY: all install clean

all : $(BIOS)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

bios.o : bios.a65 include/v65C02.inc
monitor.o : monitor.a65 include/v65C02.inc

$(BIOS) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^
	$(BIN2MEM) $@
	$(BIN2HEX) $@

install :
	@cp -v $(BIOS_MEM) $(bin_dir)
	@cp -v $(BIOS_HEX) $(bin_dir)

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
	@rm -fv $(BIOS)
	@rm -fv $(BIOS_MEM)
	@rm -fv $(BIOS_HEX)
