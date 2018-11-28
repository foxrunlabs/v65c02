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
Module Name : PS2_Transceiver
Parent:     : KeyboardController
File Name   : ps2_tcvr.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 transceiver module for the v65C02 8-bit Computer.
*******************************************************************************/

module PS2Transceiver
    (
    input  wire       clk_i,        // system clock
    input  wire       rst_i,        // reset
    
    inout  wire       ps2_clk_io,   // PS/2 clock
    inout  wire       ps2_data_io,  // PS/2 serial data
    
    input  wire       we_i,         // write enable
    input  wire [7:0] din_i,        // 8-bit data input
    output wire       tx_busy_o,    // transmit busy signal
    output wire       tx_err_o,     // transmit error
    
    output wire       rx_stb_o,     // data received strobe
    output wire       rx_err_o,     // receive error strobe
    output wire [7:0] dout_o        // 8-bit data output
    );
    
    
/* INPUT SYNCHRONIZER *********************************************************/
    
    reg ps2_data_async_ff;          // PS/2 data synchronizer
    reg ps2_data_sync_ff;           // PS/2 data synchronizer
    
    // PS/2 data synchronizer
    initial ps2_data_async_ff = 1'b1;
    initial ps2_data_sync_ff  = 1'b1;
    always @(posedge clk_i) begin
        ps2_data_async_ff <= #1 ps2_data_io;
        ps2_data_sync_ff  <= #1 ps2_data_async_ff;
    end
    
    
/* PS/2 CLOCK *****************************************************************/
    
    wire ps2_clk_fe;
    
    PS2Clock PS2Clock
        (
        .clk_i       (clk_i),
        .rst_i       (rst_i),
        .we_i        (we_i),
        .ps2_clk_io  (ps2_clk_io),
        .ps2_clk_fe_o(ps2_clk_fe)
        );
    
    
/* PS/2 RECEIVER **************************************************************/
    
    PS2_RX PS2_RX
        (
        .clk_i       (clk_i),
        .rst_i       (rst_i | tx_busy_o),
        .ps2_clk_fe_i(ps2_clk_fe),
        .ps2_din_i   (ps2_data_sync_ff),
        .rx_stb_o    (rx_stb_o),
        .rx_err_o    (rx_err_o),
        .dout_o      (dout_o)
        );
    
    
/* PS/2 TRANSMITTER ***********************************************************/
    
    wire tx_clk;
    wire tx_dout;
    
    PS2_TX PS2_TX
        (
        .clk_i       (clk_i),
        .rst_i       (rst_i),
        .ps2_clk_fe_i(ps2_clk_fe),
        .ps2_din_i   (ps2_data_sync_ff),
        .ps2_dout_o  (tx_dout),
        .we_i        (we_i),
        .din_i       (din_i),
        .tx_busy_o   (tx_busy_o),
        .tx_err_o    (tx_err_o)
        );
    
    assign ps2_data_io = (tx_dout) ? 1'bZ : 1'b0;
    
endmodule
