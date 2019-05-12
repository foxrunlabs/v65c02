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
Module Name : VGAController
File Name   : vga_controller.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : VGA text-mode controller for the v65C02 8-bit Computer on the 
          Nexys 4 DDR FPGA development board. Implements a CRT controller, 4KB
          video RAM, character generator, 4KB character ROM, attribute decoder,
          and synchronizer.
          
          The CRT controller generates the character column and scan line,
          horizontal and vertical sync signals, cursor, and active video flag.
          
          The video RAM has a 12-bit address bus and 8-bit data bus for
          interface with the 65C02 and an 11-bit address bus and 16-bit data
          bus for interface with the VGA controller. Each 16-bit word consists
          of an ASCII code and display attribute:
          
          ---------------------------------------------------------------------
           15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 
          ---------------------------------------------------------------------
                       Attribute               |          ASCII Code
          ---------------------------------------------------------------------
          
          The character generator outputs pixel data corresponding to the ASCII
          code of the current character. Pixel data for each ASCII character is
          stored in the character ROM. The ninth pixel is generated referencing
          the IBM Code Page 437 drawing characters.
                              
          The character ROM is large enough to accomodate all 256 characters of
          IBM Code Page 437 using an 8x16 glyph.
          
          The attribute decoder translates each foreground and background value
          into the appropriate IBM VGA equivalent 12-bit RGB444 value.
          Attributes are stored in RAM in two 4-bit nibbles, representing a
          coded RGB444 value.
          
             Background  |  Foreground
          -------------------------------
           7 | 6 | 5 | 4 | 3 | 2 | 1 | 0
          -------------------------------
           B | B | B | B | F | F | F | F
          -------------------------------
          
          The synchronizer matches timing between the horizontal sync, vertical
          sync, RGB444, and character generator.
          
          The VGA controller has three control registers: STATUS, CURS_LSB, and
          CURS_MSB. STATUS controls the VGA controller, and CURS_LSB and
          CURS_MSB form the 12-bit address for the cursor. STATUS contains two
          bits: EN which enables the display, and CURS which enables the cursor.
          
                   ------------------------------------------
                     7 |  6 |  5 |  4 |  3 |  2  |   1  |  0
                   ------------------------------------------
          STATUS     X |  X |  X |  X |  X |  X  | CURS | EN
          CURS_LSB  A7 | A6 | A5 | A4 | A3 |  A2 |  A1  | A0
          CURS_MSB   X |  X |  X |  X |  X | A10 |  A9  | A8
          
          Total delay from start to valid output is six pixel-clock cycles.          
*******************************************************************************/


module VGAController
    (
    input  wire        clk_cpu_i,   // CPU clock
    input  wire        clk_pixel_i, // pixel clock
    
    // video RAM
    input  wire        vram_en_i,   // video RAM enable
    input  wire        vram_we_i,   // video RAM write enable
    input  wire [11:0] vram_addr_i, // 12-bit video RAM address
    input  wire [7:0]  vram_din_i,  // 8-bit video RAM data input
    output wire [7:0]  vram_dout_o, // 8-bit video RAM data output
    
    // registers
    input  wire        reg_en_i,    // registers enable
    input  wire        reg_we_i,    // registers write enable
    input  wire [1:0]  regsel_i,    // 2-bit register select
    input  wire [7:0]  reg_din_i,   // 8-bit register data input
    output reg  [7:0]  reg_dout_o,  // 8-bit register data output
    
    // outputs
    output wire [11:0] rgb_o,       // RGB444 output
    output wire        hsync_o,     // horizontal sync
    output wire        vsync_o      // vertical sync
    );
    
    
/* CONTROL REGISTERS **********************************************************/
    
    localparam R_STATUS = 2'b00,
               R_CURSL  = 2'b01,
               R_CURSH  = 2'b10;
    
    reg  [1:0]  status_reg;         // STATUS
    reg  [7:0]  curs_lsb_reg;       // CURS_LSB
    reg  [2:0]  curs_msb_reg;       // CURS_MSB
    wire [10:0] curs_addr;          // 11-bit cursor address
    
    assign curs_addr = {curs_msb_reg, curs_lsb_reg};
    
    // control registers input
    initial status_reg   = 2'b00;   // cursor disabled, output disabled
    initial curs_lsb_reg = 8'd0;    // cursor at (0,0)
    initial curs_msb_reg = 3'o0;
    always @(posedge clk_cpu_i)
        if(reg_en_i)
            if(reg_we_i)
                case(regsel_i)
                    R_STATUS: status_reg   <= #1 reg_din_i[1:0];
                    R_CURSL:  curs_lsb_reg <= #1 reg_din_i;
                    R_CURSH:  curs_msb_reg <= #1 reg_din_i[2:0];
                endcase
    
    // control registers output
    initial reg_dout_o = 8'h00;
    always @(posedge clk_cpu_i)
        if(reg_en_i)
            case(regsel_i)
                R_STATUS: reg_dout_o <= #1 {6'b0000_00, status_reg};
                R_CURSL:  reg_dout_o <= #1 curs_lsb_reg;
                R_CURSH:  reg_dout_o <= #1 {5'b0000_0, curs_msb_reg};
                default:  reg_dout_o <= #1 8'd0;
            endcase
    
    
/* CRT CONTROLLER *************************************************************/
    
    wire [6:0]  crtc_col;           // character column
    wire [8:0]  crtc_line;          // scan line
    wire        crtc_col_stb;       // new column strobe
    wire        crtc_hsync;         // horizontal sync
    wire        crtc_vsync;         // vertical sync
    wire        crtc_cursor;        // cursor timing
    wire        crtc_video_on;      // active video flag
    
    CRTC CRTC
        (
        .clk_i     (clk_pixel_i),
        .col_stb_o (crtc_col_stb),
        .col_o     (crtc_col),
        .line_o    (crtc_line),
        .hsync_o   (crtc_hsync),
        .vsync_o   (crtc_vsync),
        .cursor_o  (crtc_cursor),
        .video_on_o(crtc_video_on)
        );
    
    
/* VIDEO RAM ******************************************************************/
    
    wire [4:0]  char_row;           // character row
    wire [10:0] vga2vram_addr;      // VGA controller to video RAM address
    wire [15:0] vram2vga_data;      // video RAM to VGA controller data
    
    // character row equals scan line mod 16
    assign char_row = crtc_line[8:4];
    
    // linear RAM addressing: x + 80y = x + (y << 6) + (y << 4)
    assign vga2vram_addr = {4'b0000, crtc_col} + {char_row, 6'b00_0000} +
                           {2'b00, char_row, 4'b0000};
    
    RAM_4K8_2K16 VideoRAM
        (
        .clka_i (clk_cpu_i),
        .ena_i  (vram_en_i),
        .wea_i  (vram_we_i),
        .addra_i(vram_addr_i),
        .dia_i  (vram_din_i),
        .doa_o  (vram_dout_o),
        .clkb_i (clk_pixel_i),
        .enb_i  (crtc_col_stb),
        .addrb_i(vga2vram_addr),
        .dob_o  (vram2vga_data)
        );
    
    
/* CHARACTER GENERATOR AND CHARACTER ROM **************************************/
    
    reg         chargen_en_stb_ff;  // enable strobe
    reg  [3:0]  glyph_row_p1_reg;   // glyph row pipeline
    wire        char2rom_rd_stb;    // character ROM read strobe
    wire [11:0] char2rom_addr;      // character generator to ROM address
    wire        chargen_pixel;      // pixel output
    wire [7:0]  rom2char_data;      // character ROM to character generator data
    
    // character generator enable strobe... also matches delay from video RAM
    initial chargen_en_stb_ff = 1'b0;
    always @(posedge clk_pixel_i)
        chargen_en_stb_ff <= #1 crtc_col_stb;
    
    // character glyph row pipeline... matches delay from video RAM access
    initial glyph_row_p1_reg = 4'd0;
    always @(posedge clk_pixel_i)
        glyph_row_p1_reg <= #1 crtc_line[3:0];
    
    CharacterGenerator CharacterGenerator
        (
        .clk_i      (clk_pixel_i),
        .en_i       (chargen_en_stb_ff),
        .glyph_row_i(glyph_row_p1_reg),
        .ascii_i    (vram2vga_data[7:0]),
        .rd_stb_o   (char2rom_rd_stb),
        .addr_o     (char2rom_addr),
        .din_i      (rom2char_data),
        .pixel_o    (chargen_pixel)
        );
    
    ROM_BRAM
        #(
        .WIDTH    (8),
        .DEPTH    (4096),
        .INIT_FILE("../../bram_data/font.hex")
        )
        CharacterROM
        (
        .clk_i (clk_pixel_i),
        .en_i  (char2rom_rd_stb),
        .addr_i(char2rom_addr),
        .dout_o(rom2char_data)
        );
    
    
/* ATTRIBUTE DECODER **********************************************************/
    
    reg         attr_en_stb_ff;     // enable strobe
    reg  [7:0]  attr_p1_reg;        // text attribute pipeline
    wire [11:0] attr_fg_rgb;        // foreground RGB444 value
    wire [11:0] attr_bg_rgb;        // background RGB444 value
    
    // text attribute pipeline and enable strobe... matches output delays to 
    // character generator
    initial attr_en_stb_ff = 1'b0;
    initial attr_p1_reg    = 8'd0;
    always @(posedge clk_pixel_i) begin
        attr_en_stb_ff <= #1 chargen_en_stb_ff;
        attr_p1_reg    <= #1 vram2vga_data[15:8];
    end
    
    AttributeDecoder AttributeDecoder
        (
        .clk_i   (clk_pixel_i),
        .en_i    (attr_en_stb_ff),
        .attr_i  (attr_p1_reg),
        .fg_rgb_o(attr_fg_rgb),
        .bg_rgb_o(attr_bg_rgb)
        );
    
    
/* SYNCHRONIZER ***************************************************************/
    
    wire        cursor_pixel;       // cursor pixel generator
    wire [11:0] sync_rgb;           // RGB444 output
    wire        sync_hsync;         // horizontal sync
    wire        sync_vsync;         // vertical sync
       
    assign cursor_pixel  = status_reg[1] & (curs_addr == vga2vram_addr)
                                         & crtc_cursor;
    
    Synchronizer Synchronizer
        (
        .clk_i     (clk_pixel_i),
        .en_i      (status_reg[0]),
        .hsync_i   (crtc_hsync),
        .vsync_i   (crtc_vsync),
        .video_on_i(crtc_video_on),
        .pixel_i   (chargen_pixel),
        .fg_rgb_i  (attr_fg_rgb),
        .bg_rgb_i  (attr_bg_rgb),
        .cursor_i  (cursor_pixel),
        .rgb_o     (sync_rgb),
        .hsync_o   (sync_hsync),
        .vsync_o   (sync_vsync)
        );
    
    // output logic
    assign rgb_o   = sync_rgb;
    assign hsync_o = sync_hsync;
    assign vsync_o = sync_vsync;
    
endmodule
