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
