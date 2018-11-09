`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright (C) 2018 Ryan Clarke

This program is free software (firmware): you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/

/*******************************************************************************
Module Name : CPUReset_tb
File Name   : cpu_reset_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module CPUReset associated with the v65C02
          8-bit Computer.
*******************************************************************************/


module Debounce_tb;


/* INPUTS *********************************************************************/
    
    reg clk_i;
    reg in_i;
    
    
/* OUTPUTS ********************************************************************/
    
    wire out_o;
    
    
/* MODULES ********************************************************************/
    
    // unit under test
    Debounce Debounce_uut
        (
        .clk_i(clk_i),
        .in_i (in_i),
        .out_o(out_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    localparam T_clk = 20;      // clock period (ns)
    
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
        
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        in_i = 1'b0;
        
        // 100 us bounce
        #1;
        in_i = 1'b1;
        @(posedge clk_i);
        
        #100000;
        
        #1;
        in_i = 1'b0;
        @(posedge clk_i);
        
        #100000;
        
        // 6 ms switch press
        #1;
        in_i = 1'b1;
        @(posedge clk_i);
        
        #6000000;
        
        // 100 us bounce        
        #1;
        in_i = 1'b0;
        @(posedge clk_i);
        
        #100000;
        
        #1;
        in_i = 1'b1;
        @(posedge clk_i);
        
        #100000;
        
        // 6 ms switch release
        #1;
        in_i = 1'b0;
        @(posedge clk_i);
        
        #6000000;
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule
