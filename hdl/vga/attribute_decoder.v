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
Module Name : AttributeDecoder
File Name   : attribute_decoder.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Attribute decoder for the VGA text-mode controller module.
          
          Converts each foreground and background value of the current
          attribute stored in video RAM into the appropriate 12-bit RGB444
          value. Attributes are two 4-bit nibbles, representing a coded
          foreground color (lower nibble) and background color (upper nibble).
          
          All outputs are registered for a one pixel clock cycle delay.
*******************************************************************************/


module AttributeDecoder
    (
    input wire        i_clk,        // pixel clock
    input wire        i_en,         // enable
    
    input wire [7:0]  i_attr,       // attribute
    
    output reg [11:0] o_fg_rgb,     // foreground RGB444 value
    output reg [11:0] o_bg_rgb      // background RGB444 value
    );
    
    
/* FOREGROUND ATTRIBUTE *******************************************************/
    
    wire [3:0] fg_attr;
    
    // extract foreground attribute from 8-bit input
    assign fg_attr = i_attr[3:0];
    
    // foreground RGB444 value
    initial o_fg_rgb = 12'h000;
    always @(posedge i_clk)
        if(i_en)
            case(fg_attr)
                4'h0: o_fg_rgb <= #1 {4'd0,  4'd0,  4'd0 };    // black
                4'h1: o_fg_rgb <= #1 {4'd0,  4'd0,  4'd10};    // blue
                4'h2: o_fg_rgb <= #1 {4'd0,  4'd10, 4'd0 };    // green
                4'h3: o_fg_rgb <= #1 {4'd0,  4'd10, 4'd10};    // cyan
                4'h4: o_fg_rgb <= #1 {4'd10, 4'd0,  4'd0 };    // red
                4'h5: o_fg_rgb <= #1 {4'd10, 4'd0,  4'd10};    // magenta
                4'h6: o_fg_rgb <= #1 {4'd10, 4'd5,  4'd0 };    // brown
                4'h7: o_fg_rgb <= #1 {4'd10, 4'd10, 4'd10};    // light gray
                4'h8: o_fg_rgb <= #1 {4'd5,  4'd5,  4'd5 };    // dark gray
                4'h9: o_fg_rgb <= #1 {4'd5,  4'd5,  4'd15};    // light blue
                4'ha: o_fg_rgb <= #1 {4'd5,  4'd15, 4'd5 };    // light green
                4'hb: o_fg_rgb <= #1 {4'd5,  4'd15, 4'd15};    // light cyan
                4'hc: o_fg_rgb <= #1 {4'd15, 4'd5,  4'd5 };    // light red
                4'hd: o_fg_rgb <= #1 {4'd15, 4'd5,  4'd15};    // light magenta
                4'he: o_fg_rgb <= #1 {4'd15, 4'd15, 4'd5 };    // yellow
                4'hf: o_fg_rgb <= #1 {4'd15, 4'd15, 4'd15};    // white
            endcase
    
    
/* BACKGROUND ATTRIBUTE *******************************************************/    
    
    wire [3:0] bg_attr;
    
    // extract background attribute from 8-bit input
    assign bg_attr = i_attr[7:4];
    
    // background RGB444 value
    initial o_bg_rgb = 12'h000;
    always @(posedge i_clk)
        if(i_en)
            case(bg_attr)
                4'h0: o_bg_rgb <= #1 {4'd0,  4'd0,  4'd0 };    // black
                4'h1: o_bg_rgb <= #1 {4'd0,  4'd0,  4'd10};    // blue
                4'h2: o_bg_rgb <= #1 {4'd0,  4'd10, 4'd0 };    // green
                4'h3: o_bg_rgb <= #1 {4'd0,  4'd10, 4'd10};    // cyan
                4'h4: o_bg_rgb <= #1 {4'd10, 4'd0,  4'd0 };    // red
                4'h5: o_bg_rgb <= #1 {4'd10, 4'd0,  4'd10};    // magenta
                4'h6: o_bg_rgb <= #1 {4'd10, 4'd5,  4'd0 };    // brown
                4'h7: o_bg_rgb <= #1 {4'd10, 4'd10, 4'd10};    // light gray
                4'h8: o_bg_rgb <= #1 {4'd5,  4'd5,  4'd5 };    // dark gray
                4'h9: o_bg_rgb <= #1 {4'd5,  4'd5,  4'd15};    // light blue
                4'ha: o_bg_rgb <= #1 {4'd5,  4'd15, 4'd5 };    // light green
                4'hb: o_bg_rgb <= #1 {4'd5,  4'd15, 4'd15};    // light cyan
                4'hc: o_bg_rgb <= #1 {4'd15, 4'd5,  4'd5 };    // light red
                4'hd: o_bg_rgb <= #1 {4'd15, 4'd5,  4'd15};    // light magenta
                4'he: o_bg_rgb <= #1 {4'd15, 4'd15, 4'd5 };    // yellow
                4'hf: o_bg_rgb <= #1 {4'd15, 4'd15, 4'd15};    // white
            endcase
    
endmodule
