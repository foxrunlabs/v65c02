`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright 2018-2019 Ryan Clarke

Licensed under the Solderpad Hardware License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License. You may obtain a
copy of the License at

    https://solderpad.org/licenses/SHL-2.0/

Unless required by applicable law or agreed to in writing, software, hardware
and materials distributed under the License are distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.
*******************************************************************************/

/*******************************************************************************
Module Name : ROM_4K8
File Name   : rom_4k8.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : 4K x 8-bit synchronous ROM.

          Loads the ROM with an 8-bit binary formatted text file.
          
          All outputs are registered for a one clock cycle delay.
*******************************************************************************/


module ROM_4K8
    (
    input wire        clk_i,    // clock
    input wire        en_i,     // ROM enable
    
    input wire [11:0] addr_i,   // 12-bit address
    output reg [7:0]  dout_o    // 8-bit data
    );
    
    
/* ROM ************************************************************************/
    
    // 4K x 8-bit block RAM
    (* rom_style = "block" *) reg [7:0] rom_reg [0:4095];
    
    // Initialize the ROM with IBM Code Page 437
    initial $readmemb("ibm_cp437.txt", rom_reg, 0, 4095);
    
    initial dout_o = 8'h00;
    always @(posedge clk_i)
        if(en_i)
            dout_o <= #1 rom_reg[addr_i];
    
endmodule
