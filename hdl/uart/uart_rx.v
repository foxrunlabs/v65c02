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
Module Name : UART_RX
File Name   : uart_tx.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : UART Receiver module for the v65C02 8-bit Computer.
*******************************************************************************/


module UART_RX
    (
    input  wire       i_clk,            // CPU clock
    
    input  wire       i_brg_stb,        // baud rate generator strobe
    
    input  wire       i_data,           // 1-bit serial data input
    output wire [7:0] o_data,           // 8-bit data output
    
    output reg        o_done_stb        // new received byte strobe
    );
    
    
/* BAUD RATE GENERATOR COUNTER ************************************************/
    
    reg [3:0] brg_count_reg;
    reg [3:0] brg_count_ns;
    
    initial brg_count_reg = 4'h0;
    always @(posedge i_clk)
        brg_count_reg <= #1 brg_count_ns;
    
    
/* BIT COUNTER ****************************************************************/
    
    reg [3:0] bit_count_reg;
    reg [3:0] bit_count_ns;
    
    initial bit_count_reg = 4'h0;
    always @(posedge i_clk)
        bit_count_reg <= #1 bit_count_ns;
    
    
/* STATE MACHINE **************************************************************/
    
    // FSM states
    localparam S_IDLE  = 2'b00,
               S_START = 2'b01,
               S_DATA  = 2'b10,
               S_STOP  = 2'b11;
    
    localparam B_START = 1'b0;          // start bit value
    
    reg [1:0] state_reg;
    reg [1:0] state_ns;
    
    // FSM state register
    initial state_reg = S_IDLE;
    always @(posedge i_clk)
        state_reg <= #1 state_ns;
    
    // FSM logic
    always @* begin
        brg_count_ns = brg_count_reg;   // baud rate generator counter
        bit_count_ns = bit_count_reg;   // bit counter
        o_done_stb   = 1'b0;            // "done" strobe
        state_ns     = state_reg;       // state register
        
        case(state_reg)
            S_IDLE:
                if(i_data == B_START) begin      // triggered on start bit
                    brg_count_ns = 4'h0;        // reset bit counter
                    state_ns     = S_START;
                end
            
            S_START:
                if(i_brg_stb) begin             // correct timing for baud rate
                    // half sample period to find middle of bit
                    if(brg_count_reg == 4'h7) begin
                        brg_count_ns = 4'h0;
                        bit_count_ns = 4'h0;
                        state_ns     = S_DATA;
                    end
                    else begin
                        brg_count_ns = brg_count_reg + 4'h1;
                    end
                end
            
            S_DATA:
                if(i_brg_stb)
                    // sample bit at middle, based on start bit timing
                    if(brg_count_reg == 4'hF) begin
                        brg_count_ns = 4'h0;
                        
                        // receive eight bits
                        if(bit_count_reg == 4'h7)
                            state_ns = S_STOP;
                        else
                            bit_count_ns = bit_count_reg + 4'h1;
                    end
                    else begin
                        brg_count_ns = brg_count_reg + 4'h1;
                    end
            
            S_STOP:
                if(i_brg_stb) begin
                    // we must account for the stop bit
                    if(brg_count_reg == 4'hF) begin
                        o_done_stb = 1'b1;      // toggle the "done" flag
                        state_ns   = S_IDLE;
                    end
                    else begin
                        brg_count_ns = brg_count_reg + 4'h1;
                    end
                end
            
            default:
                state_ns = S_IDLE;
            
        endcase
    end
    
    
/* RECEIVE SHIFT REGISTER *****************************************************/
    
    localparam B_IDLE = 1'b1;           // idle state
    
    wire       rxsr_en;
    reg  [7:0] rxsr_reg;
    
    // receiver shift register only enabled in sync with baud rate generator,
    // during the data portion of the FSM, and in the middle of a received bit.
    assign rxsr_en = (i_brg_stb) &
                     (state_reg == S_DATA) &
                     (brg_count_reg == 4'hF);
    
    initial rxsr_reg = {8{B_IDLE}};
    always @(posedge i_clk)
        if(rxsr_en)
            rxsr_reg <= #1 {i_data, rxsr_reg[7:1]};
    
    // output logic
    assign o_data = rxsr_reg;
    
endmodule
