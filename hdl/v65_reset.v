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
Module Name : v65Reset
File Name   : v65_reset.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Reset circuit for the v65C02 8-bit Computer.
          
          Generates an active-high reset signal, triggered on startup or by the
          rising-edge sensitive trigger input. The reset signal lasts four clock
          cycles to meet the minimum 2 clock cycle specification of the 65C02.
*******************************************************************************/


module v65Reset
    (
    input  wire i_clk,              // system clock
    
    input  wire i_trig,             // trigger input
    output wire o_rst               // reset ouput
    );
    
    
/* RISING EDGE DETECTOR *******************************************************/
    
    reg  trig_prev_ff;              // previous trigger input
    wire trig_re;                   // trigger rising-edge
    
    initial trig_prev_ff = 1'b0;
    always @(posedge i_clk)
        trig_prev_ff <= #1 i_trig;
    
    assign trig_re = ~trig_prev_ff & i_trig;
    
    
/* RESET SIGNAL ***************************************************************/
    
    reg  [2:0] count_reg;           // clock cycle counter
    
    initial count_reg = 3'o0;
    always @(posedge i_clk) begin
        if(trig_re)
            count_reg <= #1 3'o0;
        else if(~count_reg[2])
            count_reg <= #1 count_reg + 3'o1;
    end
    
    assign o_rst = ~count_reg[2];
    
endmodule
