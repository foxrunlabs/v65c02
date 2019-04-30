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
Module Name : AttributeDecoder_tb
File Name   : attribute_decoder_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module AttributeDecoder associated with the
          v65C02 8-bit Computer.
*******************************************************************************/


module AttributeDecoder_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       en_i;
    reg [7:0] attr_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [11:0] fg_rgb_o;
    wire [11:0] bg_rgb_o;
    
    
/* MODULES ********************************************************************/
    
    AttributeDecoder AttributeDecoder_uut
        (
        .clk_i   (clk_i),
        .en_i    (en_i),
        .attr_i  (attr_i),
        .fg_rgb_o(fg_rgb_o),
        .bg_rgb_o(bg_rgb_o)
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
        en_i   = 1'b0;
        attr_i = 8'h00;
        
        // light gray text on blue background
        #1;
        en_i   = 1'b1;
        attr_i = 8'h17;
        @(posedge clk_i);
        
        // disable
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule
