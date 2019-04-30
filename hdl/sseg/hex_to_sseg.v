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
Module Name : HexToSSEG
File Name   : hex_to_sseg.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Hexadecimal to seven-segment display converter for the v65C02 8-bit
          Computer.
          
          The output is ordered from cathode A to G from bit 0 to bit 6, with
          the decimal point DP at bit 7.
          
             _A_
            |   |
            F   B
            |_G_|
            |   |
            E   C
            |_D_| o DP
*******************************************************************************/


module HexToSSEG
    (
    input wire [3:0] hex_i,     // hexadecimal input
    input wire       dp_i,      // decimal point
    
    output reg [7:0] sseg_n_o   // seven-segment display output
    );
    
    
/* ROM TABLE ******************************************************************/
    
    always @*
        begin
            case(hex_i)
                //                        GFEDCBA
                4'h0:    sseg_n_o[6:0] = 7'b1000000;
                4'h1:    sseg_n_o[6:0] = 7'b1111001;
                4'h2:    sseg_n_o[6:0] = 7'b0100100;
                4'h3:    sseg_n_o[6:0] = 7'b0110000;
                4'h4:    sseg_n_o[6:0] = 7'b0011001;
                4'h5:    sseg_n_o[6:0] = 7'b0010010;
                4'h6:    sseg_n_o[6:0] = 7'b0000010;
                4'h7:    sseg_n_o[6:0] = 7'b1111000;
                4'h8:    sseg_n_o[6:0] = 7'b0000000;
                4'h9:    sseg_n_o[6:0] = 7'b0010000;
                4'hA:    sseg_n_o[6:0] = 7'b0001000;
                4'hB:    sseg_n_o[6:0] = 7'b0000011;
                4'hC:    sseg_n_o[6:0] = 7'b1000110;
                4'hD:    sseg_n_o[6:0] = 7'b0100001;
                4'hE:    sseg_n_o[6:0] = 7'b0000110;
                4'hF:    sseg_n_o[6:0] = 7'b0001110;
                default: sseg_n_o[6:0] = 7'b1111111;
            endcase
            
            sseg_n_o[7] = ~dp_i;
        end
    
endmodule
