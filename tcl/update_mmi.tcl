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
# Procedure : update_mmi
# File Name : update_mmi.tcl
# Project   : v65C02 8-bit Computer
# Author    : Ryan Clarke
# E-mail    : kj6msg@icloud.com
################################################################################
# Purpose : Update the BIOS MMI file for the v65C02 8-bit Computer
################################################################################


proc update_mmi { { mmi_filename bios.mmi } } {
    set bram_locs [get_property LOC [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.bram.* && NAME =~ BIOS*}]]
    
    foreach bram_loc $bram_locs {
        set bram_name [get_property NAME $bram_loc]
        lappend bram_list [string trimleft $bram_name "BRAM36_"]
    }
    
    set template_file [open "bram_data/template.mmi" r]
    set template [read $template_file]
    close $template_file
    
    set mmi [format $template {*}$bram_list]
    
    set mmi_file [open "bram_data/$mmi_filename" w]
    puts -nonewline $mmi_file $mmi
    close $mmi_file
}