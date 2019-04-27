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
File Name   : ps2_tx.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 transmitter module for the v65C02 8-bit Computer.
*******************************************************************************/

module PS2_TX
    (
    input  wire       clk_i,            // system clock
    
    input  wire       we_i,             // write enable
    input  wire [7:0] din_i,            // 8-bit data input
    
    input  wire       ps2_clk_re_stb_i, // PS/2 clock rising edge strobe
    input  wire       ps2_clk_fe_stb_i, // PS/2 clock falling edge strobe
    input  wire       ps2_din_i,        // PS/2 serial data input
    output wire       ps2_dout_o,       // PS/2 serial data output
    
    output wire       tx_busy_o,        // data received strobe
    output wire       tx_err_o          // receive error strobe
    );
    
    
/* BIT COUNTER ****************************************************************/
    
    reg [3:0] bit_count_reg;            // bit counter register
    reg [3:0] bit_count_ns;
    
    // bit counter
    initial bit_count_reg = 4'd0;
    always @(posedge clk_i)
        bit_count_reg <= #1 bit_count_ns;
    
    
/* SHIFT REGISTER *************************************************************/
    
    // PS/2 protocol bits
    localparam B_START = 1'b0,
               B_STOP  = 1'b1;
    
    reg  [10:0] frame_reg;              // 11-bit PS/2 protocol frame register
    reg  [10:0] frame_ns;
    wire        parity;                 // transmit data parity
    
    assign parity = ~(^ din_i);         // compute odd parity
    
    // PS/2 frame
    initial frame_reg = {11{1'b1}};
    always @(posedge clk_i)
        frame_reg <= #1 frame_ns;
    
    // output logic
    assign ps2_dout_o = frame_reg[0];
    
    
/* STATE MACHINE **************************************************************/
    
    localparam S_IDLE = 2'd0,           // idle
               S_TX   = 2'd1,           // transmit
               S_ACK  = 2'd2,           // acknowledge
               S_DONE = 2'd3;           // done
    
    reg [1:0] state_reg;                // state register
    reg [1:0] state_ns;
    
    // state
    initial state_reg = S_IDLE;
    always @(posedge clk_i)
        state_reg <= #1 state_ns;
    
    // next state logic
    always @* begin
        state_ns     = state_reg;
        frame_ns     = frame_reg;
        bit_count_ns = bit_count_reg;
        
        case(state_reg)
            S_IDLE:
                if(we_i) begin
                    bit_count_ns = 4'd0;
                    frame_ns     = {B_STOP, parity, din_i, B_START};
                    
                    state_ns = S_TX;
                end
            
            S_TX: begin
                // first bit is transmitted immediately, so cycle through 10
                if(bit_count_reg < 4'd10) begin
                    if(ps2_clk_fe_stb_i) begin
                        bit_count_ns = bit_count_reg + 4'd1;
                        frame_ns     = {1'b1, frame_reg[10:1]};
                    end
                end
                else begin
                    state_ns = S_ACK;
                end
            end
            
            S_ACK:
                if(ps2_clk_fe_stb_i)
                    state_ns = S_DONE;
            
            S_DONE:
                if(ps2_clk_re_stb_i)    // wait until clock resets to idle
                    state_ns = S_IDLE;
            
            default:
                state_ns = S_IDLE;
            
        endcase
    
    end
    
    // output logic
    assign tx_busy_o = (state_reg != S_IDLE);   
    
    
/* ACK BIT ********************************************************************/
    
    reg error_ff;                       // transmit error, set if NACK
    
    initial error_ff = 1'b0;
    always @(posedge clk_i)
        if(state_reg == S_ACK)
            if(ps2_clk_fe_stb_i)
                error_ff <= #1 ps2_din_i;   // high = NACK, low = ACK
    
    // output logic
    assign tx_err_o = error_ff;
    
endmodule
