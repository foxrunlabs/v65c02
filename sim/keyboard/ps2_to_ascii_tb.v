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
Module Name : PS2toASCII_tb
File Name   : ps2_to_ascii.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module PS2toASCII associated with the v65C02
          8-bit Computer.
*******************************************************************************/


module PS2toASCII_tb;


/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       en_i;
    reg [7:0] scancode_i;
    
    
/* OUTPUTS ********************************************************************/
    
    wire       rdy_stb_o;
    wire [7:0] ascii_o;
    
    
/* MODULES ********************************************************************/
    
    PS2toASCII PS2toASCII_uut
        (
        .clk_i     (clk_i),
        .en_i      (en_i),
        .scancode_i(scancode_i),
        .rdy_stb_o (rdy_stb_o),
        .ascii_o   (ascii_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    // clock period (ns)
    localparam T_clk = 20;
    
    // 50 MHz system clock
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
        
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN SIMULATION ************************************************************/
    
    // PS/2 scan codes
    localparam KEY_Q      = 8'h15;
    localparam KEY_UP     = 7'h75;
    localparam KEY_LCTRL  = 8'h14;
    localparam KEY_LSHIFT = 8'h12;
    localparam BREAK      = 8'hF0;
    localparam EXTEND     = 8'hE0;
    
    initial begin        
        en_i       = 1'b0;
        scancode_i = 8'h00;
        @(posedge clk_i);      
        
        //- press q ------------------------------------------------------------
        $display("Press and release q...");
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_Q;
        @(posedge clk_i);
        $display("Scan code: %h", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        //- release q ----------------------------------------------------------
        #1;
        en_i       = 1'b1;
        scancode_i = BREAK;
        @(posedge clk_i);
        $write("Scan code: %h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_Q;
        @(posedge clk_i);
        $display("%h\n", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        //- press left-shift + q -----------------------------------------------
        $display("Press and release left-shift + q...");
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_LSHIFT;
        @(posedge clk_i);
        $write("Scan code: %h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_Q;
        @(posedge clk_i);
        $display("%h", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        //- release left-shift + q ---------------------------------------------
        #1;
        en_i       = 1'b1;
        scancode_i = BREAK;
        @(posedge clk_i);
        $write("Scan code: %h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_LSHIFT;
        @(posedge clk_i);
        $write("%h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = BREAK;
        @(posedge clk_i);
        $write("%h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_Q;
        @(posedge clk_i);
        $display("%h\n", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        //- press up-arrow -----------------------------------------------------
        $display("Press and release up-arrow...");
        
        #1;
        en_i       = 1'b1;
        scancode_i = EXTEND;
        @(posedge clk_i);
        $write("Scan code: %h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_UP;
        @(posedge clk_i);
        $display("%h", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        //- release up-arrow ---------------------------------------------------
        #1;
        en_i       = 1'b1;
        scancode_i = EXTEND;
        @(posedge clk_i);
        $write("Scan code: %h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = BREAK;
        @(posedge clk_i);
        $write("%h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_UP;
        @(posedge clk_i);
        $display("%h\n", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        //- press left-ctrl + q ------------------------------------------------
        $display("Press and release left-ctrl + q...");
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_LCTRL;
        @(posedge clk_i);
        $write("Scan code: %h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_Q;
        @(posedge clk_i);
        $display("%h", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        //- release left-ctrl + q ----------------------------------------------
        #1;
        en_i       = 1'b1;
        scancode_i = BREAK;
        @(posedge clk_i);
        $write("Scan code: %h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_LCTRL;
        @(posedge clk_i);
        $write("%h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = BREAK;
        @(posedge clk_i);
        $write("%h ", scancode_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        #100;
        
        #1;
        en_i       = 1'b1;
        scancode_i = KEY_Q;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        $display("%h\n", scancode_i);
        
        #100;
        
        //- done ---------------------------------------------------------------
        @(posedge clk_i) $stop;
    end
    
    
/* ASCII CODE PRINTER *********************************************************/
    
    reg [7:0] ascii;
    
    initial ascii = 8'h00;
    always @(posedge clk_i)
        if(rdy_stb_o) begin
            $display("ASCII code: %h", ascii_o);
            ascii <= ascii_o;
        end
    
endmodule
