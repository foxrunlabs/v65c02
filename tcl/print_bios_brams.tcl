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
# Procedure : print_bios_brams
# File Name : print_bios_brams.tcl
# Project   : v65C02 8-bit Computer
# Author    : Ryan Clarke
# E-mail    : kj6msg@icloud.com
################################################################################
# Purpose : Print the BIOS BRAM location and bit lane information.
################################################################################


proc print_bios_brams {} {
    # open the implemented design
    open_run impl_1
    
    # get list of BIOS BRAMs
    set brams [get_cells -hierarchical \
                         -filter { PRIMITIVE_TYPE =~ BMEM.bram.* && \
                                   NAME =~ BIOS*}]
    
    # header
    puts "LOC          MSB LSB"
    puts "--------------------"
    
    # iterate through each BRAM, printing the LOC and BRAM slice information
    foreach bram $brams {
        set bram_info [get_property LOC $bram]
        append bram_info "  " [get_property bram_slice_end $bram] "  "
        append bram_info " " [get_property bram_slice_begin $bram]
        puts $bram_info
    }
    
    # close the implemented design
    close_design
}
