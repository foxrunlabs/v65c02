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

.SUFFIXES:
.SUFFIXES: .a65 .o

prefix  = ..
srcdir  = ./src
bramdir = $(prefix)/bram_data
hexdir  = $(prefix)/hdl/memory

VPATH = $(srcdir)

TARGET = bios.rom
MEM    = bios.mem
HEX    = bios.hex
OBJS   = bios.o monitor.o

AS       = ca65
ASFLAGS  = --cpu 65C02 -l $(basename $@).lst -t none -I ./include

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = -C $(LDCONFIG) -m $(basename $@).map

BIN2MEM  = ./bin2mem.sh
BIN2HEX  = ./bin2hex.sh

.PHONY: all
all : $(TARGET)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

$(TARGET) : $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^
	$(BIN2MEM) $@
	$(BIN2HEX) $@

.PHONY: install
install : all
	@cp -v $(MEM) $(bramdir)
	@cp -v $(HEX) $(hexdir)

.PHONY: clean
clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o

.PHONY: distclean
distclean : clean
	@rm -fv $(TARGET)
	@rm -fv $(MEM)
	@rm -fv $(HEX)
