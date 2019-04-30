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
# Purpose : Makefile for the v65C02 8-bit Computer library
#===============================================================================


SHELL = /bin/sh

prefix      = .
exec_prefix = $(prefix)
lib_dir     = $(prefix)

LIBRARY = v65C02.lib
OBJECTS = v65C02.o

AS      = ca65
ASFLAGS = --cpu 65C02 -l $(basename $@).lst -t none -I ../include/

AR      = ar65
ARFLAGS = r $(LIBRARY)

.PHONY: all clean

all : $(LIBRARY)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

v65C02.o : v65C02.a65 ../include/v65C02.inc

$(LIBRARY) : $(OBJECTS)
	$(AR) $(ARFLAGS) $^

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
