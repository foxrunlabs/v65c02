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
Module Name : CharacterGenerator
File Name   : character_generator.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Character generator for the VGA text-mode controller module.
          
          Current character ASCII code is obtained from video RAM.
          
          All outputs are registered. Reading the character ROM incurs a one
          pixel-clock cycle delay. Registering the pixel output incurs a second
          delay. Total delay is two pixel-clock cycles for a valid output.
*******************************************************************************/


module CharacterGenerator
    (
    input wire        i_clk,        // pixel clock
    input wire        i_we,         // write enable signal
    
    input wire  [7:0] i_ascii,      // 8-bit ASCII character
    input wire  [3:0] i_glyph_row,  // character glyph row
    
    output wire       o_pixel       // pixel output
    );
    
    
/* CHARACTER ROM **************************************************************/
    
    wire        char_rom_en;
    wire [11:0] char_rom_addr;
    wire [7:0]  char_rom_data;
    
    assign char_rom_en   = i_we;
    assign char_rom_addr = {i_ascii, i_glyph_row};
    
    // 4K x 8-bit character ROM
    ROM_BRAM
        #(
        .WIDTH    (8),
        .DEPTH    (4096),
        .INIT_FILE("font.hex")
        )
        CharacterROM
        (
        .i_clk (i_clk),
        .i_en  (char_rom_en),
        .i_addr(char_rom_addr),
        .o_data(char_rom_data)
        );
    
    
/* GLYPH PIXELS SHIFT REGISTER ************************************************/
    
    reg       glyph_pixels_ld_ff;   // glyph pixels load signal
    reg [7:0] glyph_pixels_reg;     // glyph pixels shift register
    
    initial glyph_pixels_ld_ff = 1'b0;
    always @(posedge i_clk)
        glyph_pixels_ld_ff <= #1 i_we;
    
    // glyph pixels shift register
    initial glyph_pixels_reg = 8'd0;
    always @(posedge i_clk)
        if(glyph_pixels_ld_ff)
            glyph_pixels_reg <= #1 char_rom_data;
        else
            glyph_pixels_reg <= #1 {glyph_pixels_reg[6:0], 1'b0};
    
    assign o_pixel = glyph_pixels_reg[7];
    
endmodule
