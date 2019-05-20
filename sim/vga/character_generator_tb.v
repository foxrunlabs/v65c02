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
Module Name : CharacterGenerator_tb
File Name   : character_generator_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module CharacterGenerator associated with the
          v65C02 8-bit Computer.
*******************************************************************************/


module CharacterGenerator_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       we_i;
    reg [7:0] ascii_i;
    reg [3:0] glyph_row_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire        pixel_o;
    
    
/* MODULES ********************************************************************/
    
    CharacterGenerator CharacterGenerator_uut
        (
        .clk_i      (clk_i),
        .we_i       (we_i),
        .ascii_i    (ascii_i),
        .glyph_row_i(glyph_row_i),
        .pixel_o    (pixel_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    localparam T_clk = 20;          // clock period (ns)
    
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
    
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        we_i        = 1'b0;
        ascii_i     = 8'h00;
        glyph_row_i = 4'h0;
        
        // ASCII and glyph data (01110111)
        #1;
        we_i        = 1'b1;
        ascii_i     = 8'd178;
        glyph_row_i = 4'h1;
        @(posedge clk_i);
        
        // valid character ROM
        #1;
        we_i = 1'b0;
        @(posedge clk_i)
        
        // generate 8 pixels
        repeat(8)
            @(posedge clk_i);
        
        // ASCII and glyph data (11111111)
        #1;
        we_i        = 1'b1;
        ascii_i     = 8'd219;
        glyph_row_i = 4'h0;
        @(posedge clk_i);
        
        // valid character ROM
        #1;
        we_i = 1'b0;
        @(posedge clk_i)
        
        // generate 8 pixels
        repeat(8)
            @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule
