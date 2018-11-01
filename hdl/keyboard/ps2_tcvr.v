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
    
    inout  wire       ps2_clk_io,   // PS/2 clock
    inout  wire       ps2_data_io,  // PS/2 serial data
    
    output wire       busy_o,       // busy signal
    
    input  wire       we_i,         // write enable
    input  wire [7:0] din_i,        // 8-bit data input
    
    output wire       rx_stb_o,     // data received strobe
    output wire [7:0] dout_o        // 8-bit data output
    );
    
    
/* INPUT SYNCHRONIZER *********************************************************/
    
    reg ps2_clk_async_ff;           // PS/2 clock synchronizer
    reg ps2_clk_sync_ff;            // PS/2 clock synchronizer
    
    reg ps2_data_async_ff;          // PS/2 data synchronizer
    reg ps2_data_sync_ff;           // PS/2 data synchronizer
    
    // PS/2 clock synchronizer
    initial ps2_clk_async_ff = 1'b1;
    initial ps2_clk_sync_ff  = 1'b1;
    always @(posedge clk_i) begin
        ps2_clk_async_ff <= #1 ps2_clk_io;
        ps2_clk_sync_ff  <= #1 ps2_clk_async_ff;
    end
    
    // PS/2 data synchronizer
    initial ps2_data_async_ff = 1'b1;
    initial ps2_data_sync_ff  = 1'b1;
    always @(posedge clk_i) begin
        ps2_data_async_ff <= #1 ps2_data_io;
        ps2_data_sync_ff  <= #1 ps2_data_async_ff;
    end
    
    
/* PS/2 CLOCK FALLING EDGE DETECTOR *******************************************/
    
    reg  ps2_clk_p1_ff;      // PS/2 clock delay
    wire ps2_clk_fe;         // PS/2 clock falling edge
    
    // PS/2 clock delay (captures previous clock state)
    initial ps2_clk_p1_ff = 1'b1;
    always @(posedge clk_i)
        ps2_clk_p1_ff <= #1 ps2_clk_sync_ff;
    
    // falling edge detector
    assign ps2_clk_fe = (ps2_clk_p1_ff) & (~ps2_clk_sync_ff);
    
    
/* BIT COUNTER ****************************************************************/
    
    localparam NUM_BITS = 4'd11;        // 11-bits in the PS/2 protocol
    
    wire      count_rst;                // counter reset signal
    reg [3:0] bit_count_reg;
    
    assign count_rst = (bit_count_reg == NUM_BITS);
    
    // reset at 11-bits, otherwise count bits on falling edge of PS/2 clock
    initial bit_count_reg = 4'd0;
    always @(posedge clk_i) begin
        if(count_rst)
            bit_count_reg <= #1 4'd0;
        else if(ps2_clk_fe)
            bit_count_reg <= #1 bit_count_reg + 4'd1;
    end
    
    
/* FINITE STATE MACHINE *******************************************************/
    
    localparam S_IDLE     = 2'b00,
               S_RECEIVE  = 2'b01;
    
    reg [2:0] state_reg;
    reg [2:0] state_ns;
    
    initial state_reg = S_IDLE;
    always @(posedge clk_i)
        state_reg <= #1 state_ns;
    
    always @* begin
        state_ns = state_reg;
        
        case(state_reg)
            S_IDLE:
                if(ps2_clk_fe)
                    state_ns = S_RECEIVE;

            S_RECEIVE:
                if(bit_count_reg == NUM_BITS)
                    state_ns = S_IDLE;
            
            default:
                state_ns = S_IDLE;
        
        endcase
    end
    
    
/* SHIFT REGISTER *************************************************************/
    
    // PS/2 protocol bits
    localparam B_START = 1'b0,
               B_STOP  = 1'b1;
        
    wire       parity;
    reg [10:0] frame_reg;
    
    assign parity = ~(^ din_i);         // odd parity
    
    initial frame_reg = {11{1'b1}};
    always @(posedge clk_i) begin
        if(we_i)
            frame_reg <= #1 {B_STOP, parity, din_i, B_START};
        else if(ps2_clk_fe)
            frame_reg <= #1 {ps2_data_sync_ff, frame_reg[10:1]};
    end
    
    
/* RECEIVED DATA REGISTER AND STROBE ******************************************/
    
    wire      rx_done;          // receive complete signal
    reg [7:0] dout_reg;         // output register
    reg       rx_stb_ff;        // received data strobe
    
    assign rx_done = (bit_count_reg == NUM_BITS);
    
    // output register
    initial dout_reg = 8'h00;
    always @(posedge clk_i)
        if(rx_done)
            dout_reg <= #1 frame_reg[8:1];
    
    // received data strobe
    initial rx_stb_ff = 1'b0;
    always @(posedge clk_i) begin
        if(rx_done)
            rx_stb_ff <= #1 1'b1;
        else
            rx_stb_ff <= #1 1'b0;
    end
    
    // output logic
    assign rx_stb_o = rx_stb_ff;
    assign dout_o   = dout_reg;
    
    
/* OPEN DRAIN LOGIC ***********************************************************/
    
    assign ps2_clk_io  = 1'bZ;
    assign ps2_data_io = 1'bZ;
    
    
/* BUSY SIGNAL ****************************************************************/
    
    assign busy_o = (state_reg != S_IDLE);
    
endmodule
