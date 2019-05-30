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
Module Name : Synchronizer
File Name   : synchronizer.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Synchronizer for the VGA text-mode controller module.
          
          Synchronizes the horizontal and vertical sync, active video flag, 
          character generator pixel, RGB444, and cursor inputs. The horizontal
          and vertical sync, active video flag, and cursor pixelo are delayed
          three pixel-clock cycles in order to match timing.
          
          The synchronizer is the final end point for the VGA signal and can be
          enabled and disabled to blank the screen.
          
          All outputs are registered and incur a one pixel-clock delay. Total
          delay from start to a valid output is six pixel-clock cycles.
*******************************************************************************/


module Synchronizer
    (
    input wire         i_clk,       // pixel clock
    input wire         i_en,        // output enable
    
    input wire         i_hsync,     // horizontal sync from CRTC
    input wire         i_vsync,     // vertical sync from CRTC
    input wire         i_video_on,  // active video flag from CRTC
    
    input wire         i_pixel,     // character generator pixel 
    input wire         i_cursor,    // cursor pixel
    
    input wire  [11:0] i_fg_rgb,    // foreground RGB444 from attribute decoder
    input wire  [11:0] i_bg_rgb,    // background RGB444 from attribute decoder
    
    output wire [11:0] o_rgb,       // RGB444 output
    output wire        o_hsync,     // horizontal sync output
    output wire        o_vsync      // vertical sync output
    );
    
    
/* PIPELINE SYNC **************************************************************/
    
    // horizontal sync pipeline
    reg hsync_p1_ff;
    reg hsync_p2_ff;
    reg hsync_p3_ff;
    
    // vertical sync pipeline
    reg vsync_p1_ff;
    reg vsync_p2_ff;
    reg vsync_p3_ff;
    
    // active video flag pipeline
    reg video_on_p1_ff;
    reg video_on_p2_ff;
    reg video_on_p3_ff;
    
    // cursor pixel pipeline
    reg cursor_p1_ff;
    reg cursor_p2_ff;
    reg cursor_p3_ff;
    
    // horizontal sync
    initial hsync_p1_ff = 1'b0;
    initial hsync_p2_ff = 1'b0;
    initial hsync_p3_ff = 1'b0;
    always @(posedge i_clk) begin
        hsync_p1_ff <= #1 i_hsync;
        hsync_p2_ff <= #1 hsync_p1_ff;
        hsync_p3_ff <= #1 hsync_p2_ff;
    end
    
    // vertical sync
    initial vsync_p1_ff = 1'b0;
    initial vsync_p2_ff = 1'b0;
    initial vsync_p3_ff = 1'b0;
    always @(posedge i_clk) begin
        vsync_p1_ff <= #1 i_vsync;
        vsync_p2_ff <= #1 vsync_p1_ff;
        vsync_p3_ff <= #1 vsync_p2_ff;
    end
    
    // active video indicator
    initial video_on_p1_ff = 1'b0;
    initial video_on_p2_ff = 1'b0;
    initial video_on_p3_ff = 1'b0;
    always @(posedge i_clk) begin
        video_on_p1_ff <= #1 i_video_on;
        video_on_p2_ff <= #1 video_on_p1_ff;
        video_on_p3_ff <= #1 video_on_p2_ff;
    end
    
    // cursor timing
    initial cursor_p1_ff = 1'b0;
    initial cursor_p2_ff = 1'b0;
    initial cursor_p3_ff = 1'b0;
    always @(posedge i_clk) begin
        cursor_p1_ff <= #1 i_cursor;
        cursor_p2_ff <= #1 cursor_p1_ff;
        cursor_p3_ff <= #1 cursor_p2_ff;
    end
    
    
/* FINAL OUTPUT REGISTERS *****************************************************/
    
    localparam COLOR_BLACK = 12'h000; 
    
    wire [11:0] rgb_mux;        // foreground/background RGB444 multiplexer
    reg  [11:0] rgb_reg;        // multiplexed RGB444 register
    reg         hsync_p4_ff;    // horizontal sync
    reg         vsync_p4_ff;    // vertical sync
    
    // multiplex the character and cursor pixel with the foreground and
    // background RGB444 values    
    assign rgb_mux = (cursor_p3_ff | i_pixel) ? i_fg_rgb
                                              : i_bg_rgb;
    
    // RGB444 output
    initial rgb_reg = 12'h000;
    always @(posedge i_clk)
        if(i_en & video_on_p3_ff)
            rgb_reg <= #1 rgb_mux;
        else
            rgb_reg <= #1 COLOR_BLACK;
    
    // output logic
    assign o_rgb   = rgb_reg;
    
    // horizontal and vertical sync signals
    initial hsync_p4_ff = 1'b0;
    initial vsync_p4_ff = 1'b0;
    always @(posedge i_clk) begin
        hsync_p4_ff <= #1 hsync_p3_ff;
        vsync_p4_ff <= #1 vsync_p3_ff;
    end
    
    // output logic
    assign o_hsync = hsync_p4_ff;
    assign o_vsync = vsync_p4_ff;
    
endmodule
