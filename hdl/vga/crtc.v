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
Module Name : CRTC
File Name   : crtc.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : CRT controller for the VGA text-mode controller module.

          Generates the character column and scan line, horizontal and vertical
          sync signals, cursor timing, and active video flag.
        
          The horizontal and vertical sync are derived from the character column
          and scan line. The column and scan line are pipelined to match the
          sync signals. The cursor timing is based off the frame rate.
          
          Total output delay is two pixel clock cycles.
*******************************************************************************/


module CRTC
    #(
    // parameters for CRTC timing: 640 x 480 @ 60 Hz (25.175 MHz pixel clock)
    parameter HS_TOTAL   = 7'd100,      // 100 characters (800 pixels)
              HS_ACTIVE  = 7'd80,       //  80 characters (640 pixels)
              HS_START   = 7'd82,       //  82 characters (656 pixels)
              HS_TIME    = 7'd12,       //  12 characters (96 pixels)
              HS_POL     = 1'b0,        // negative pulse,
              
              VS_TOTAL   = 10'd525,     // 525 lines
              VS_ACTIVE  = 10'd480,     // 480 lines
              VS_START   = 10'd490,     // 490 lines
              VS_TIME    = 10'd2,       //   2 lines
              VS_POL     = 1'b0         // negative pulse
    )
    (
    input wire        i_clk,            // pixel clock
    
    output wire       o_new_col_stb,    // new column strobe
    output wire [6:0] o_col,            // column
    output wire [9:0] o_line,           // scan line
    
    output wire       o_hsync,          // horizontal sync
    output wire       o_vsync,          // vertical sync
    
    output wire       o_cursor,         // cursor timing
    
    output wire       o_video_on        // active video flag
    );
    
    
/* GLYPH PIXEL COUNTER ********************************************************/
    
    reg  [2:0] glyph_pixel_reg; // glyph pixel counter
    wire       glyph_end;       // glyph end indicator
    
    assign glyph_end = (glyph_pixel_reg == 3'o7);    
    
    initial glyph_pixel_reg = 3'o0;
    always @(posedge i_clk)
        glyph_pixel_reg <= #1 glyph_pixel_reg + 3'o1;
    
    
/* COLUMN COUNTER *************************************************************/
    
    wire       col_start;       // column start indicator
    reg        new_col_stb_ff;  // new column strobe
    reg  [6:0] col_reg;         // column counter
    reg  [6:0] col_p1_reg;      // pipeline delay
    wire       last_col;        // last column indicator
    
    assign col_start = (glyph_pixel_reg == 3'o0);
    
    // new column strobe
    initial new_col_stb_ff = 1'b0;
    always @(posedge i_clk)
        new_col_stb_ff <= #1 col_start;
    
    assign last_col = (col_reg == HS_TOTAL - 7'd1);
    
    // column counter
    initial col_reg = 7'd0;
    always @(posedge i_clk)
        if(glyph_end) begin
            if(last_col)
                col_reg <= #1 7'd0;
            else
                col_reg <= #1 col_reg + 7'd1;
        end
    
    // pipeline delay to match sync timing
    initial col_p1_reg  = 7'd0;
    always @(posedge i_clk)
        col_p1_reg  <= #1 col_reg;
    
    // output logic
    assign o_new_col_stb = new_col_stb_ff;
    assign o_col         = col_p1_reg;
    
    
/* SCAN LINE COUNTER **********************************************************/    
    
    reg  [9:0] line_reg;        // scan line counter
    reg  [9:0] line_p1_reg;     // pipeline delay
    wire       last_line;       // last line indicator
    
    assign last_line = (line_reg == VS_TOTAL - 10'd1);
    
    // scan line counter
    initial line_reg = 10'd0;
    always @(posedge i_clk)
        if(last_col & glyph_end) begin
            if(last_line)
                line_reg <= #1 10'd0;
            else
                line_reg <= #1 line_reg + 10'd1;
        end
    
    // pipeline delay to match sync timing
    initial line_p1_reg = 10'd0;
    always @(posedge i_clk)
        line_p1_reg <= #1 line_reg;
    
    // output logic
    assign o_line = line_p1_reg;
    
    
/* SYNC SIGNALS ***************************************************************/
    
    reg  hsync_ff;          // horizontal sync
    reg  vsync_ff;          // vertical sync
    wire hsync_on;          // horizontal sync active indicator
    wire vsync_on;          // vertical sync active indicator
    
    assign hsync_on = (col_reg >= (HS_START)) &
                      (col_reg <  (HS_START + HS_TIME));
    assign vsync_on = (line_reg >= (VS_START)) &
                      (line_reg <  (VS_START + VS_TIME));
    
    // horizontal sync
    initial hsync_ff = 1'b0;
    always @(posedge i_clk) begin
        if(hsync_on)
            hsync_ff <= #1 HS_POL;
        else
            hsync_ff <= #1 ~HS_POL;
    end
    
    // vertical sync
    initial vsync_ff = 1'b0;
    always @(posedge i_clk) begin
        if(vsync_on)
            vsync_ff <= #1 VS_POL;
        else
            vsync_ff <= #1 ~VS_POL;
    end
    
    // output logic
    assign o_hsync = hsync_ff;
    assign o_vsync = vsync_ff;
    
    
/* CURSOR TIMING **************************************************************/
    
    wire       frame_end;       // frame end indicator
    reg  [4:0] frame_cnt_reg;   // frame counter
    reg        cursor_ff;       // cursor timing
    
    assign frame_end = glyph_end & last_col & last_line;
    
    // frame counter
    initial frame_cnt_reg = 5'd0;
    always @(posedge i_clk)
        if(frame_end)
            frame_cnt_reg <= #1 frame_cnt_reg + 5'd1;
    
    // cursor blink rate is tied to frame rate. Blinks at 1.875 Hz
    // 1/(2 * 16 / 60) Hz
    initial cursor_ff = 1'b0;
    always @(posedge i_clk)
        cursor_ff <= #1 frame_cnt_reg[4];
    
    // output logic
    assign o_cursor = cursor_ff;
    
    
/* ACTIVE VIDEO FLAG **********************************************************/
    
    reg video_on_ff;            // active video indicator
    
    // active video flag
    initial video_on_ff = 1'b0;
    always @(posedge i_clk)
        video_on_ff <= #1 (col_reg < HS_ACTIVE) & (line_reg < VS_ACTIVE);
    
    // output logic
    assign o_video_on = video_on_ff;
    
endmodule
