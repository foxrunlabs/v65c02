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
Module Name : PS2_RX
File Name   : ps2_rx.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 receiver module for the v65C02 8-bit Computer.
*******************************************************************************/

module PS2_RX
    (
    input  wire       clk_i,            // system clock
    
    input  wire       en_i,             // enable
    
    input  wire       ps2_clk_fe_stb_i, // PS/2 clock falling edge strobe
    input  wire       ps2_din_i,        // PS/2 serial data input
    
    output wire       rx_stb_o,         // data received strobe
    output wire [7:0] dout_o,           // 8-bit data output
    output wire       parity_err_o      // parity error
    );
    
    
/* BIT COUNTER ****************************************************************/
    
    reg  [3:0] bit_count_reg;           // bit counter register
    wire       bit_count_rst;           // bit counter reset signal
    wire       rx_done;                 // receive complete signal
    
    // reset bit counter when RX disabled or 11 bits received
    assign bit_count_rst = (~en_i) | (bit_count_reg == 4'd11);
    
    // bit counter
    initial bit_count_reg = 4'd0;
    always @(posedge clk_i) begin
        if(bit_count_rst)
            bit_count_reg <= #1 4'd0;
        else
            if(ps2_clk_fe_stb_i)
                bit_count_reg <= #1 bit_count_reg + 4'd1;
    end
    
    // receive complete when 11 bits received
    assign rx_done = (bit_count_reg == 4'd11);
    
    
/* RECEIVE SHIFT REGISTER *****************************************************/
    
    reg [10:0] frame_reg;               // 11-bit PS/2 protocol frame register
    
    // PS/2 frame
    initial frame_reg = 11'd0;
    always @(posedge clk_i)
        if(en_i)
            if(ps2_clk_fe_stb_i)
                frame_reg <= #1 {ps2_din_i, frame_reg[10:1]};
    
    
/* RECEIVE STROBE *************************************************************/
    
    reg rx_stb_ff;                      // receive complete strobe flip-flop
    
    // received data strobe
    initial rx_stb_ff = 1'b0;
    always @(posedge clk_i)
        rx_stb_ff <= #1 rx_done;

    // output logic
    assign rx_stb_o = rx_stb_ff;
    
    
/* RECEIVED DATA REGISTER *****************************************************/
    
    reg [7:0] dout_reg;                 // data output register
    
    // received data
    initial dout_reg = 8'h00;
    always @(posedge clk_i)
        if(rx_done)
            dout_reg <= #1 frame_reg[8:1];
    
    // output logic
    assign dout_o  = dout_reg;
    
    
/* PARITY ERROR ***************************************************************/
    
    wire parity;                            // received data parity
    reg  parity_err_ff;                     // parity error flip-flop
    
    assign parity = ~(^ frame_reg[8:1]);    // odd parity
    
    // set if parity bit and computed parity are not equal
    initial parity_err_ff = 1'b0;
    always @(posedge clk_i)
        if(rx_done)
            parity_err_ff <= #1 (frame_reg[9] != parity);
    
    // output logic
    assign parity_err_o = parity_err_ff;
    
    
endmodule
