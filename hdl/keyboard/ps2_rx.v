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
    input  wire       i_clk,            // system clock
    
    input  wire       i_en,             // enable
    
    input  wire       i_ps2_clk_fe_stb, // PS/2 clock falling edge strobe
    input  wire       i_ps2_data,       // PS/2 serial data input
    
    output wire       o_rx_stb,         // data received strobe
    output wire [7:0] o_data,           // 8-bit data output
    output wire       o_parity_err      // parity error
    );
    
    
/* BIT COUNTER ****************************************************************/
    
    reg  [3:0] bit_count_reg;           // bit counter register
    wire       bit_count_rst;           // bit counter reset signal
    wire       rx_done;                 // receive complete signal
    
    // reset bit counter when RX disabled or 11 bits received
    assign bit_count_rst = (~i_en) | (bit_count_reg == 4'd11);
    
    // bit counter
    initial bit_count_reg = 4'd0;
    always @(posedge i_clk) begin
        if(bit_count_rst)
            bit_count_reg <= #1 4'd0;
        else
            if(i_ps2_clk_fe_stb)
                bit_count_reg <= #1 bit_count_reg + 4'd1;
    end
    
    // receive complete when 11 bits received
    assign rx_done = (bit_count_reg == 4'd11);
    
    
/* RECEIVE SHIFT REGISTER *****************************************************/
    
    reg [10:0] frame_reg;               // 11-bit PS/2 protocol frame register
    
    // PS/2 frame
    initial frame_reg = 11'd0;
    always @(posedge i_clk)
        if(i_en)
            if(i_ps2_clk_fe_stb)
                frame_reg <= #1 {i_ps2_data, frame_reg[10:1]};
    
    
/* RECEIVE STROBE *************************************************************/
    
    reg rx_stb_ff;                      // receive complete strobe flip-flop
    
    // received data strobe
    initial rx_stb_ff = 1'b0;
    always @(posedge i_clk)
        rx_stb_ff <= #1 rx_done;

    // output logic
    assign o_rx_stb = rx_stb_ff;
    
    
/* RECEIVED DATA REGISTER *****************************************************/
    
    reg [7:0] dout_reg;                 // data output register
    
    // received data
    initial dout_reg = 8'h00;
    always @(posedge i_clk)
        if(rx_done)
            dout_reg <= #1 frame_reg[8:1];
    
    // output logic
    assign o_data  = dout_reg;
    
    
/* PARITY ERROR ***************************************************************/
    
    wire parity;                            // received data parity
    reg  parity_err_ff;                     // parity error flip-flop
    
    assign parity = ~(^ frame_reg[8:1]);    // odd parity
    
    // set if parity bit and computed parity are not equal
    initial parity_err_ff = 1'b0;
    always @(posedge i_clk)
        if(rx_done)
            parity_err_ff <= #1 (frame_reg[9] != parity);
    
    // output logic
    assign o_parity_err = parity_err_ff;
    
    
endmodule
