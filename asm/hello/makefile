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
# Purpose : Makefile for the Hello World test program for the v65C02 8-bit
#           Computer
#===============================================================================


SHELL = /bin/sh

prefix      = .
exec_prefix = $(prefix)
bin_dir     = $(exec_prefix)

PROGRAM  = helloworld.bin
OBJECTS  = helloworld.o

AS       = ca65
ASFLAGS  = --cpu 65C02 -l $(basename $@).lst -t none -I ../include/

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = -C $(LDCONFIG) -L ../lib/ -m $(basename $@).map -o $(PROGRAM)

.PHONY: all clean

all : helloworld.bin

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

helloworld.o : helloworld.a65

$(PROGRAM) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^ v65C02.lib

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
