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
Module Name : CRTC_tb
File Name   : crtc_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module CRTC associated with the v65C02 8-bit
          Computer.
*******************************************************************************/


module CRTC_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire       new_col_stb_o;
    wire [6:0] col_o;
    wire [9:0] line_o;
    wire       hsync_o;
    wire       vsync_o;
    wire       cursor_o;
    wire       video_on_o;
    
    
/* MODULES ********************************************************************/
    
    CRTC
        #(
        .HS_TOTAL (7'd100),
        .HS_ACTIVE(7'd80),
        .HS_START (7'd82),
        .HS_TIME  (7'd12),
        .HS_POL   (1'b0),
        .VS_TOTAL (10'd525),
        .VS_ACTIVE(10'd480),
        .VS_START (10'd490),
        .VS_TIME  (10'd2),
        .VS_POL   (1'b0)
        )
        CRTC_uut
        (
        .clk_i        (clk_i),
        .new_col_stb_o(new_col_stb_o),
        .col_o        (col_o),
        .line_o       (line_o),		
        .hsync_o      (hsync_o),
        .vsync_o      (vsync_o),
        .cursor_o     (cursor_o),
        .video_on_o   (video_on_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    localparam T_clk = 40;          // clock period (ns)
    
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
    
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        @(posedge clk_i);
        
        // observe cursor timing
        @(negedge cursor_o);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule
