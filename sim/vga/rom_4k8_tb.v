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
Module Name : ROM_4K8_tb
File Name   : rom_4k8_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module ROM_4K8 associated with the v65C02 8-bit
          Computer.
*******************************************************************************/


module ROM_4K8_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_i;
    reg        en_i;
    reg [11:0] addr_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] dout_o;
    
    
/* MODULES ********************************************************************/
    
    ROM_4K8 ROM_4K8_uut
        (
        .clk_i (clk_i),
        .en_i  (en_i),
        .addr_i(addr_i),
        .dout_o(dout_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    localparam T_clk = 10;      // clock period (ns)
    
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
    
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        en_i   =  1'b0;
        addr_i = 12'h000;
        
        // read two bytes
        #1;
        en_i   =  1'b1;
        addr_i = 12'h012;
        @(posedge clk_i);
        
        #1;
        en_i   =  1'b1;
        addr_i = 12'h013;
        @(posedge clk_i);
        
        // deselect ROM
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule
