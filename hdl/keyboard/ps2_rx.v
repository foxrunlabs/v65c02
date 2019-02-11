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
    input  wire       clk_i,        // system clock
    input  wire       rst_i,        // reset
    
    input  wire       ps2_clk_fe_i, // PS/2 clock falling edge
    input  wire       ps2_din_i,    // PS/2 serial data input
    
    output wire       rx_stb_o,     // data received strobe
    output wire       rx_err_o,     // receive error strobe
    output wire [7:0] dout_o        // 8-bit data output
    );
    
    
/* RECEIVE SHIFT REGISTER *****************************************************/
    
    wire        rx_done;
    reg  [10:0] frame_reg;      // 11-bit PS/2 frame register
    
    initial frame_reg = {11{1'b1}};
    always @(posedge clk_i) begin
        if(rst_i | rx_done)
            frame_reg <= #1 {11{1'b1}};
        else if(ps2_clk_fe_i)
            frame_reg <= #1 {ps2_din_i, frame_reg[10:1]};
    end
    
    assign rx_done = ~frame_reg[0];
    
    
/* RECEIVE STROBE *************************************************************/
    
    reg rx_stb_ff;              // receive complete strobe flip-flop
    
    // received data strobe
    initial rx_stb_ff = 1'b0;
    always @(posedge clk_i)
        rx_stb_ff <= #1 rx_done;
    
    // output logic
    assign rx_stb_o = rx_stb_ff;
    
    
/* RECEIVE ERROR **************************************************************/
    
    wire rx_parity;             // received data parity
    reg  rx_err_ff;             // receive error flip-flop
    
    assign rx_parity = ~(^ frame_reg[8:1]);
    
    // set if parity bit and computed parity are not equal
    initial rx_err_ff = 1'b0;
    always @(posedge clk_i)
        if(rx_done)
            rx_err_ff <= #1 (frame_reg[9] != rx_parity);
    
    // output logic
    assign rx_err_o = rx_err_ff;
    
    
/* RECEIVED DATA REGISTER *****************************************************/
    
    reg  [7:0] dout_reg;        // output register
    
    // output register
    initial dout_reg = 8'h00;
    always @(posedge clk_i)
        if(rx_done)
            dout_reg <= #1 frame_reg[8:1];
    
    // output logic
    assign dout_o  = dout_reg;
    
endmodule
