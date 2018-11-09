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
Module Name : Debounce
File Name   : debounce.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Debounce circuit for the v65C02 8-bit Computer.
          
          Implements an approximately 5.24 ms debounce for a physical button.
*******************************************************************************/

module Debounce
    (
    input  clk_i,
    
    input  in_i,
    output out_o
    );
    
    
/* COUNTER ********************************************************************/
    
    wire        count_rst;
    reg  [17:0] count_reg;
    
    // counting starts if output doesn't equal input
    assign count_en = (out_reg != in_i);
    
    initial count_reg = 18'd0;
    always @(posedge clk_i) begin
        if(count_en)
            count_reg <= #1 count_reg + 18'd1;
        else
            count_reg <= #1 18'd0;
    end
    
    
/* OUTPUT *********************************************************************/
    
    wire out_en;
    reg  out_reg;
    
    // the output is flipped when the counter is full
    assign out_en = (& count_reg);
    
    initial out_reg = 1'b0;
    always @(posedge clk_i)
        if(out_en)
            out_reg <= #1 ~out_reg;
    
    assign out_o = out_reg;
    
endmodule
