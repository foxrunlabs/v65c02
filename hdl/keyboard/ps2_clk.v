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
Module Name : PS2Clock
File Name   : ps2_clk.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 receiver module for the v65C02 8-bit Computer.
*******************************************************************************/

module PS2Clock
    (
    input  wire clk_i,          // system clock
    input  wire rst_i,          // reset
    
    input  wire we_i,           // transmit enable
    inout  wire ps2_clk_io,     // PS/2 clock
    
    output wire ps2_clk_fe_o    // PS/2 clock falling edge
    );
    
    
/* INPUT SYNCHRONIZER *********************************************************/
    
    reg ps2_clk_async_ff;           // PS/2 clock synchronizer
    reg ps2_clk_sync_ff;            // PS/2 clock synchronizer
    
    // PS/2 clock synchronizer
    initial ps2_clk_async_ff = 1'b1;
    initial ps2_clk_sync_ff  = 1'b1;
    always @(posedge clk_i) begin
        ps2_clk_async_ff <= #1 ps2_clk_io;
        ps2_clk_sync_ff  <= #1 ps2_clk_async_ff;
    end
    
    
/* PS/2 CLOCK FALLING EDGE DETECTOR *******************************************/
    
    reg  ps2_clk_prev_ff;       // PS/2 clock previous value
    wire ps2_clk_fe;            // PS/2 clock falling edge signal
    
    // capture PS/2 clock previous value
    initial ps2_clk_prev_ff = 1'b1;
    always @(posedge clk_i)
        ps2_clk_prev_ff <= #1 ps2_clk_sync_ff;
    
    // falling edge detector
    assign ps2_clk_fe_o = ps2_clk_prev_ff & (~ps2_clk_sync_ff) & ~rts_en;
    
    
/* REQUEST TO SEND ************************************************************/
    
    reg  [12:0] rts_count_reg;  // RTS counter register
    
    assign rts_en = ~(& rts_count_reg);
    
    // delay counter
    initial rts_count_reg = {13{1'b1}};
    always @(posedge clk_i) begin
        if(rst_i)
            rts_count_reg <= #1 {13{1'b1}};
        else begin
            if(we_i)
                rts_count_reg <= #1 13'd0;
            else if(rts_en)
                rts_count_reg <= #1 rts_count_reg + 13'd1;
        end
    end
    
    assign ps2_clk_io = (rts_en) ? 1'b0 : 1'bZ;
    
endmodule
