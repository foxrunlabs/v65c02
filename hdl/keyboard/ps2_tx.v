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
Module Name : PS2_TX
Parent:     : PS2Transceiver
File Name   : ps2_tx.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 transmitter module for the v65C02 8-bit Computer.
*******************************************************************************/

module PS2_TX
    (
    input  wire       clk_i,        // system clock
    input  wire       rst_i,        // reset
    
    input  wire       ps2_clk_fe_i, // PS/2 clock falling edge
    input  wire       ps2_din_i,    // PS/2 serial data input
    output wire       ps2_dout_o,   // PS/2 serial data output
    
    input  wire       we_i,         // write enable
    input  wire [7:0] din_i,        // 8-bit data input
    
    output wire       tx_busy_o,    // data received strobe
    output wire       tx_err_o      // receive error strobe
    );
    
    
/* BIT COUNTER ****************************************************************/
    
    wire      bit_count_en;
    reg [3:0] bit_count_reg;
    
    assign bit_count_en = ps2_clk_fe_i & (bit_count_reg < 4'd11);
    
    initial bit_count_reg = 4'd11;
    always @(posedge clk_i)
        if(we_i)
            bit_count_reg <= #1 4'd0;
        else if(bit_count_en)
            bit_count_reg <= #1 bit_count_reg + 1'd1;
    
    assign tx_busy_o = bit_count_reg < 4'd11;
    
    
/* SHIFT REGISTER *************************************************************/
    
    // PS/2 protocol bits
    localparam B_START = 1'b0,
               B_STOP  = 1'b1;
    
    wire        parity;                 // odd parity
    reg  [10:0] frame_reg;              // 11-bit PS/2 frame register
    wire        tx_done;                // transmit complete signal
    
    assign parity = ~(^ din_i);         // compute odd parity
    
    initial frame_reg = {11{1'b1}};
    always @(posedge clk_i) begin
        if(rst_i)
            frame_reg <= #1 {11{1'b1}};
        else begin
            if(we_i)
                frame_reg <= #1 {B_STOP, parity, din_i, B_START};
            else if(bit_count_en)
                frame_reg <= #1 {1'b1, frame_reg[10:1]};
        end
    end
    
    // output logic
    assign ps2_dout_o = frame_reg[0];
    
    
/* ACK BIT ********************************************************************/
    
    reg error_ff;
    
    initial error_ff = 1'b0;
    always @(posedge clk_i)
        if(ps2_clk_fe_i & (bit_count_reg == 4'd10))
            error_ff <= #1 ps2_din_i;
    
    // output logic
    assign tx_err_o = error_ff;
    
endmodule
