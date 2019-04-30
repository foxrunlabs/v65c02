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
# Purpose : Update the BIOS on the v65C02 8-bit Computer
################################################################################


proc update_bios { { bios_name bios } } {
    set bram_data_dir bram_data    
    append mmi_file $bram_data_dir {/} $bios_name {.mmi}
    append mem_file $bram_data_dir {/} $bios_name {.mem}
    
    append bit_dir [get_property NAME [current_project]] {.runs} {/} [current_run]
    set top_module [get_property TOP [current_fileset]]
    append in_file $bit_dir {/} $top_module {.bit}
    append out_file $bit_dir {/} $top_module {_updated.bit}

    puts [exec updatemem --force --proc dummy --meminfo $mmi_file --data $mem_file --bit $in_file --out $out_file]
    }
