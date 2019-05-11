################################################################################
# Copyright 2018-2019 Ryan Clarke
#
# Licensed under the Solderpad Hardware License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may 
# obtain a copy of the License at
#
#    https://solderpad.org/licenses/SHL-2.0/
#
# Unless required by applicable law or agreed to in writing, software, hardware
# and materials distributed under the License are distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

################################################################################
# Procedure : update_bios
# File Name : update_bios.tcl
# Project   : v65C02 8-bit Computer
# Author    : Ryan Clarke
# E-mail    : kj6msg@icloud.com
################################################################################
# Purpose : Update the BIOS in the v65C02 8-bit Computer .BIT file
################################################################################


proc update_bios {} {
    # MMI and MEM files
    append mmi_file "bram_data/bios.mmi"
    append mem_file "bram_data/bios.mem"
    
    # set the location of the BIT file
    append bit_dir [current_project] ".runs/" [current_run]
    append bit_file $bit_dir "/v65C02_Top.bit"
    
    # update the BIT file with the new BIOS
    exec updatemem --force --proc dummy --meminfo $mmi_file --data $mem_file \
                   --bit $bit_file --out $bit_file
    }
