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


module CPUReset_tb;


/* INPUTS *********************************************************************/
    
    reg clk_i;
    reg rst_i;
    
    
/* OUTPUTS ********************************************************************/
    
    wire rst_o;
    
    
/* MODULES ********************************************************************/
    
    // unit under test
    CPUReset CPUReset_uut
        (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rst_o(rst_o)
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
        rst_i = 1'b0;
        
        // wait for the power-up reset to complete
        @(negedge rst_o);
        @(posedge clk_i);
        
        // trigger another reset
        #1
        rst_i = 1'b1;
        @(posedge clk_i);
        
        #6000000;
        
        #1;
        rst_i = 1'b0;
        @(posedge clk_i)
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule
