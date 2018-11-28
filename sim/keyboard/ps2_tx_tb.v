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
Module Name : PS2_TX_tb
File Name   : ps2_tx_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module PS2_TX associated with the v65C02 8-bit
          Computer.
*******************************************************************************/

module PS2_TX_tb;


/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       rst_i;
    reg       ps2_clk_i;
    reg       ps2_din_i;
    reg       we_i;
    reg [7:0] din_i;
    
    
/* OUTPUTS ********************************************************************/
    
    wire ps2_clk_o;
    wire ps2_dout_o; 
    wire tx_busy_o;
    wire tx_err_o;
    
    
/* BI-DIRECTIONAL *************************************************************/
    
    // PS/2 open-drain bus signals
    wire ps2_clk_bus;
    wire ps2_data_bus;
    
    pullup(ps2_clk_bus);
    pullup(ps2_data_bus);
    
    assign ps2_clk_bus  = (device_clk)  ? 1'bZ : 1'b0;
    assign ps2_data_bus = (device_data) ? 1'bZ : 1'b0;
    
    
/* PS/2 DEVICE SIGNALS ********************************************************/
    
    reg device_clk;                     // PS/2 clock from device
    reg device_data;                    // PS/2 data from device