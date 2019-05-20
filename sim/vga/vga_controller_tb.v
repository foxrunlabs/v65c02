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
Module Name : VGAController_tb
File Name   : vga_controller_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module VGAController associated with the v65C02
          8-bit Computer.
*******************************************************************************/


module VGAController_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_cpu_i;
    reg        clk_pixel_i;
    reg        vram_en_i;
    reg        vram_we_i;
    reg [11:0] vram_addr_i;
    reg [7:0]  vram_din_i;
    reg        reg_en_i;
    reg        reg_we_i;
    reg [1:0]  regsel_i;
    reg [7:0]  reg_din_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0]  vram_dout_o;
    wire [7:0]  reg_dout_o;
    wire [11:0] rgb_o;
    wire        hsync_o;
    wire        vsync_o;
    
    
/* MODULES ********************************************************************/
    
    VGAController VGAController_uut
        (
        .clk_cpu_i  (clk_cpu_i),
        .clk_pixel_i(clk_pixel_i),
        .vram_en_i  (vram_en_i),
        .vram_we_i  (vram_we_i),
        .vram_addr_i(vram_addr_i),
        .vram_din_i (vram_din_i),
        .vram_dout_o(vram_dout_o),
        .reg_en_i   (reg_en_i),
        .reg_we_i   (reg_we_i),
        .regsel_i   (regsel_i),
        .reg_din_i  (reg_din_i),
        .reg_dout_o (reg_dout_o),
        .rgb_o      (rgb_o),
        .hsync_o    (hsync_o),
        .vsync_o    (vsync_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    // clock period (ns)
    localparam T_clk_cpu   = 20;
    localparam T_clk_pixel = T_clk_cpu * 2;
    
    // CPU clock
    always begin
        clk_cpu_i = 1'b1;
        #(T_clk_cpu / 2);
    
        clk_cpu_i = 1'b0;
        #(T_clk_cpu / 2);
    end
    
    // pixel clock
    always begin
        clk_pixel_i = 1'b1;
        #(T_clk_pixel / 2);
    
        clk_pixel_i = 1'b0;
        #(T_clk_pixel / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        vram_en_i   =  1'b0;
        vram_we_i   =  1'b0;
        vram_addr_i = 12'h000;
        vram_din_i  =  8'h00;
        reg_en_i    =  1'b0;
        reg_we_i    =  1'b0;
        regsel_i    =  2'b00;
        reg_din_i   =  8'h00;
        
        // write SPACE character to VRAM address 0x000
        #1;
        vram_en_i   =  1'b1;
        vram_we_i   =  1'b1;
        vram_addr_i = 12'h000;
        vram_din_i  =  8'h20;
        @(posedge clk_cpu_i);
        
        #1;
        vram_en_i = 1'b0;
        vram_we_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // select attribute page
        #1;
        reg_en_i  = 1'b1;
        reg_we_i  = 1'b1;
        regsel_i  = 2'b00;
        reg_din_i = 8'b0000_0100;
        @(posedge clk_cpu_i);
        
        #1;
        reg_en_i = 1'b0;
        reg_we_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // write attribute to VRAM address 0x000;
        #1;
        vram_en_i   =  1'b1;
        vram_we_i   =  1'b1;
        vram_addr_i = 12'h000;
        vram_din_i  =  8'h17;
        @(posedge clk_cpu_i);
        
        #1;
        vram_en_i = 1'b0;
        vram_we_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // move cursor to (1,1)
//         #1;
//         vram_en_i = 1'b0;
//         vram_we_i = 1'b0;
//         reg_en_i  = 1'b1;
//         reg_we_i  = 1'b1;
//         regsel_i  = 2'b01;
//         reg_din_i = 8'h51;
//         @(posedge clk_cpu_i);
        
//         #1;
//         regsel_i  = 2'b10;
//         reg_din_i = 8'h00;
//         @(posedge clk_cpu_i);
        
        // enable VGA output and cursor, select display page
        #1;
        reg_en_i  = 1'b1;
        reg_we_i  = 1'b1;
        regsel_i  = 2'b00;
        reg_din_i = 8'b0000_0011;
        @(posedge clk_cpu_i);
        
        #1;
        reg_en_i = 1'b0;
        reg_we_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // read video RAM address 0x000
        #1;
        vram_en_i   =  1'b1;
        vram_addr_i = 12'h000;
        @(posedge clk_cpu_i);
        
        #1;
        vram_en_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // select attribute page
        #1;
        reg_en_i  = 1'b1;
        reg_we_i  = 1'b1;
        regsel_i  = 2'b00;
        reg_din_i = 8'b0000_0111;
        @(posedge clk_cpu_i);
        
        #1;
        reg_en_i = 1'b0;
        reg_we_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // read video RAM address 0x000
        #1;
        vram_en_i   =  1'b1;
        vram_addr_i = 12'h000;
        @(posedge clk_cpu_i);
        
        #1;
        vram_en_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // read STATUS register
        #1;
        reg_en_i = 1'b1;
        regsel_i = 2'b00;
        @(posedge clk_cpu_i);
        
        #1;
        reg_en_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // read cursor address
//         #1;
//         regsel_i = 2'b01;
//         @(posedge clk_cpu_i);
//         
//         #1;
//         regsel_i = 2'b10;
//         @(posedge clk_cpu_i);
        
        // run for 33 frames to observe cursor
        //I#(33 * T_clk_pixel * 900 * 449);
        
        // done
        @(posedge clk_cpu_i) $stop;
    end
    
endmodule
