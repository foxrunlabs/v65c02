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
