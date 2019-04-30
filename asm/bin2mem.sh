#!/bin/bash

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
# Program   : bin2mem
# File Name : bin2mem.sh
# Project   : v65C02 8-bit Computer
# Author    : Ryan Clarke
# E-mail    : kj6msg@icloud.com
#===============================================================================
# Purpose : Converts a binary file to MEM format for Xilinx FPGA tools.
#===============================================================================


# is there an input file?
if [ $# -eq 0 ] ; then
    echo "$0: Usage: $0 file" 1>&2
    exit 1
fi

# does the input file exist?
if [ ! -f $1 ] ; then
    echo "$0: File $1 does not exist, aborting." 1>&2
    exit 1
fi

# is the input file empty?
if [ ! -s $1 ] ; then
    echo "$0: File $1 is empty, aborting." 1>&2
    exit 1
fi

# MEM filename is input filename, stripped of extension, with .mem appended
MEMFILE=${1%.*}'.mem'

echo '// bin2mem conversion of '$1 > $MEMFILE
echo '@0000' >> $MEMFILE
xxd -p -c 1 $1 - >> $MEMFILE

exit 0
