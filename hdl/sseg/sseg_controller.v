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
Module Name : SevenSegmentController
File Name   : sseg_controller.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Seven-segment display controller for the v65C02 8-bit Computer.
*******************************************************************************/


module SevenSegmentController
    (
    input wire        i_clk,            // CPU clock
    
    input wire        i_en,             // controller bus enable
    input wire        i_we,             // write enable
    input wire  [2:0] i_reg_sel,        // 3-bit register select
    input wire  [7:0] i_data,           // 8-bit data input bus
    
    output wire [7:0] o_an_n,           // anode (active low)
    output wire [7:0] o_sseg_n          // segments (active low)
    );
    
    
/* CONTROLLER REGISTERS AND RAM ***********************************************/
    
    localparam R_DIGITS = 3'o0,
               R_DP     = 3'o1,
               R_BYTE0  = 3'o2,
               R_BYTE1  = 3'o3,
               R_BYTE2  = 3'o4,
               R_BYTE3  = 3'o5;
    
    reg [7:0] digits_reg;               // DIGITS
    reg [7:0] dp_reg;                   // DP
    reg [3:0] data_reg [0:7];           // DATA
    
    // controller registers
    initial digits_reg = 8'd0;          // all digits disabled
    initial dp_reg     = 8'd0;          // all decimal points disabled
    always @(posedge i_clk)
        if(i_en)
            if(i_we)
                case(i_reg_sel)
                    R_DIGITS: digits_reg <= #1 i_data;
                    R_DP:     dp_reg     <= #1 i_data;
                endcase
    
    // data registers
    always @(posedge i_clk)
        if(i_en)
            if(i_we)
                case(i_reg_sel)
                    R_BYTE0:
                        begin
                            data_reg[0] <= #1 i_data[3:0];
                            data_reg[1] <= #1 i_data[7:4];
                        end
                
                    R_BYTE1:
                        begin
                            data_reg[2] <= #1 i_data[3:0];
                            data_reg[3] <= #1 i_data[7:4];
                        end
                    
                    R_BYTE2:
                        begin
                            data_reg[4] <= #1 i_data[3:0];
                            data_reg[5] <= #1 i_data[7:4];
                        end
                
                    R_BYTE3:
                        begin
                            data_reg[6] <= #1 i_data[3:0];
                            data_reg[7] <= #1 i_data[7:4];
                        end
                endcase
    
    
/* HEX TO SEVEN-SEGMENT *******************************************************/
    
    wire [7:0] sseg_n [0:7];                 // seven-segment data
    
    generate
        genvar i;
        
        // 8x hexadecimal to seven-segment converters
        for(i = 0; i <= 7; i = i + 1)
            begin : nibbles
                HexToSSEG HexToSSEG
                    (
                    .i_hex   (data_reg[i]),
                    .i_dp    (dp_reg[i]),
                    .o_sseg_n(sseg_n[i])
                    );
            end
    endgenerate
    
    
/* MULTIPLEXER ****************************************************************/
    
    reg  [18:0] refresh_counter_reg;    // display refresh counter
    wire [2:0]  digit;                  // current seven-segment digit
    reg  [7:0]  an_n_reg;               // anode (active low)
    reg  [7:0]  sseg_n_reg;             // seven-segment digit (active low)
    
    // refresh counter
    initial refresh_counter_reg = 19'd0;
    always @(posedge i_clk)
        refresh_counter_reg <= #1 refresh_counter_reg + 19'd1;
    
    // ~762 Hz cycle rate equates to ~95 Hz display refresh rate
    assign digit = refresh_counter_reg[18:16];
    
    // anode - essentially a 3-to-8 multiplexer
    initial an_n_reg = 8'hFF;
    always @(posedge i_clk)
        an_n_reg <= #1 ~(1 << digit);
    
    // seven-segment digit - 3-to-8 multiplexer
    initial sseg_n_reg = 8'hFF;
    always @(posedge i_clk)
        sseg_n_reg <= #1 sseg_n[digit];
    
    
    // output logic
    assign o_an_n   = an_n_reg | ~digits_reg;
    assign o_sseg_n = sseg_n_reg;
    
endmodule
