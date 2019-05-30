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
Module Name : UART_TX
File Name   : uart_tx.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : UART Transmitter module for the v65C02 8-bit Computer.
*******************************************************************************/


module UART_TX
    (
    input wire        i_clk,        // system clock
    
    input wire        i_brg_stb,    // baud rate generator strobe
    input wire        i_we,         // write enable
    
    input  wire [7:0] i_data,        // 8-bit data input
    output wire       o_data,       // 1-bit serial output
    
    output wire       o_busy        // busy flag
    );
    
    
/* BAUD RATE GENERATOR DIV 16 *************************************************/
    
    reg  [3:0] brg_16_reg;          // baud rate generator divide-by-16 register
    wire       brg_16_stb;          // baud rate generator divide-by-16 strobe
    
    initial brg_16_reg = 4'h0;
    always @(posedge i_clk)
        if(i_brg_stb)
            brg_16_reg <= #1 brg_16_reg + 4'h1;
    
    // one clock-cycle strobe at a baud rate generator divide-by-16 rate
    assign brg_16_stb = (brg_16_reg == 4'hF) & (i_brg_stb);
    
    
/* TRANSMIT SHIFT REGISTER ****************************************************/
    
    // transmit bit values
    localparam B_IDLE  = 1'b1,
               B_START = 1'b0,
               B_STOP  = 1'b1;
    
    reg [9:0] txsr_reg;                 // 10-bit transmit shift register
    
    initial txsr_reg = {10{B_IDLE}};
    always @(posedge i_clk)
        if(i_we)
            txsr_reg <= #1 {B_STOP, i_data, B_START};        // load
        else
            if(brg_16_stb)
                txsr_reg <= #1 {B_IDLE, txsr_reg[9:1]};     // right shift
    
    
/* SERIAL OUTPUT **************************************************************/
    
    reg dout_ff;                        // 1-bit serial data
    
    initial dout_ff = B_IDLE;
    always @(posedge i_clk)
        if(brg_16_stb)
            dout_ff <= #1 txsr_reg[0];  // LSb of transmit shift register
    
    // output logic
    assign o_data = dout_ff;
    
    
/* BUSY FLAG ******************************************************************/
    
    reg [3:0] bit_count_reg;            // transmitted bit counter
    
    initial bit_count_reg = 4'hF;       // empty
    always @(posedge i_clk) begin
        if(i_we)
            bit_count_reg <= #1 4'd10;  // 10 bits to transmit
        else
            if(brg_16_stb)              // sync with baud rate generator/16
                if(bit_count_reg != 4'hF)
                    bit_count_reg <= #1 bit_count_reg - 4'h1;
    end
    
    // output logic
    assign o_busy = (bit_count_reg != 4'hF);    // rolls through 0
    
endmodule
