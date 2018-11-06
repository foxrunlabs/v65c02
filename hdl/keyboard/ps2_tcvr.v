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
    output wire       tx_stb_o,     // data transmit complete strobe
    output wire       tx_err_stb_o, // transmit error strobe
    
    output wire       rx_stb_o,     // data received strobe
    output wire [7:0] dout_o,       // 8-bit data output
    output wire       rx_err_stb_o  // receive error strobe
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
    
    reg  ps2_clk_p1_ff;      // PS/2 clock previous value
    wire ps2_clk_fe;         // PS/2 clock falling edge signal
    
    // capture PS/2 clock previous value
    initial ps2_clk_p1_ff = 1'b1;
    always @(posedge clk_i)
        ps2_clk_p1_ff <= #1 ps2_clk_sync_ff;
    
    // falling edge detector
    assign ps2_clk_fe = (ps2_clk_p1_ff) & (~ps2_clk_sync_ff);
    
    
/* FINITE STATE MACHINE *******************************************************/
    
    localparam S_IDLE      = 3'b000,    // idle
               S_RECEIVE   = 3'b001,    // receive PS/2 frame
               S_RTS       = 3'b010,    // host-to-device request-to-send
               S_HOLD_DATA = 3'b011,    // hold data low prior to clock release
               S_TRANSMIT  = 3'b100,    // transmit PS/2 frame
               S_ACK       = 3'b101,    // ACK receipt
               S_DONE      = 3'b110;    // complete
    
    reg [2:0] state_reg;
    reg [2:0] state_ns;
    
    wire rx_complete;       // receive complete signal
    wire tx_complete;       // transmit complete signal
    wire idle_bus;          // idle PS/2 bus signal
    
    initial state_reg = S_IDLE;
    always @(posedge clk_i)
        state_reg <= #1 state_ns;
    
    // receive and transmit complete signals
    // transmit complete is one less due START bit already read at clock release
    assign rx_done = (bit_count_reg == NUM_BITS) & (state_reg == S_RECEIVE);
    assign tx_done = (bit_count_reg == (NUM_BITS - 4'd1)) &
                     (state_reg == S_TRANSMIT);
    
    // idle bus can be checked when clock and data are both high... sorta
    assign idle_bus = (ps2_clk_sync_ff == 1'b1) & (ps2_data_sync_ff == 1'b1);
    
    always @* begin
        state_ns = state_reg;
        
        case(state_reg)
            S_IDLE: begin
                if(ps2_clk_fe)  // prioritize receive over transmit
                    state_ns = S_RECEIVE;
                else if(we_i)
                    state_ns = S_RTS;
            end

            S_RECEIVE:
                if(rx_done)
                    state_ns = S_DONE;
            
            S_RTS:
                if(delay_done)
                    state_ns = S_HOLD_DATA;
            
            S_HOLD_DATA:
                if(delay_done)
                    state_ns = S_TRANSMIT;
            
            S_TRANSMIT:
                if(tx_done)
                    state_ns = S_ACK;
            
            S_ACK:
                if(ps2_clk_fe)
                    state_ns = S_DONE;
            
            S_DONE:
                if(idle_bus)
                    state_ns = S_IDLE;
            
            default:
                state_ns = S_IDLE;
        
        endcase
    end
    
    
/* SHIFT REGISTER *************************************************************/
    
    // PS/2 protocol bits
    localparam B_START = 1'b0,
               B_STOP  = 1'b1;

    wire       frame_ld;        // PS/2 frame load signal
    wire       tx_parity;       // odd parity bit
    wire       shift_en;        // shift enable signal
    reg [10:0] frame_reg;       // 11-bit PS/2 frame register
    
    // load a frame when WE and IDLE
    assign frame_ld = (we_i) & (state_reg == S_IDLE);
    
    // compute odd parity
    assign tx_parity = ~(^ din_i);
    
    // shift is enabled at falling edge, and in IDLE, RECEIVE, or TRANSMIT state
    assign shift_en = (ps2_clk_fe) & ((state_reg == S_IDLE) |
                                      (state_reg == S_RECEIVE) |
                                      (state_reg == S_TRANSMIT));
    
    initial frame_reg = {11{1'b1}};
    always @(posedge clk_i) begin
        if(frame_ld)
            frame_reg <= #1 {B_STOP, tx_parity, din_i, B_START};
        else if(shift_en)
            frame_reg <= #1 {ps2_data_sync_ff, frame_reg[10:1]};
    end
    
    
/* BIT COUNTER ****************************************************************/
    
    localparam NUM_BITS = 4'd11;        // 11-bits in the PS/2 protocol
    
    wire       count_rst;               // counter reset signal
    wire       count_en;                // counter enable
    reg  [3:0] bit_count_reg;
    
    assign count_rst = (state_reg == S_DONE);
    assign count_en  = shift_en;        // counter and shift enable are the same
    
    initial bit_count_reg = 4'd0;
    always @(posedge clk_i) begin
        if(count_rst)
            bit_count_reg <= #1 4'd0;
        else if(count_en)
            bit_count_reg <= #1 bit_count_reg + 4'd1;
    end
    
    
/* DELAY COUNTER **************************************************************/
    
    // values take into account state transition (20 ns)
    localparam DELAY_100US = 13'd4999,  // 100 us delay @ 50 MHz clock
               DELAY_50US  = 13'd2499;  // 50 us delay @ 50 MHz clock
    
    wire        delay_100us_ld;         // 100 us delay load signal
    wire        delay_50us_ld;          // 50 us delay load signal
    wire        delay_done;             // delay complete signal
    reg  [12:0] delay_counter_reg;      // counter register
    
    // load only when write enabled and idle
    assign delay_100us_ld = (we_i) & (state_reg == S_IDLE);
    assign delay_50us_ld  = (delay_done) & (state_reg == S_RTS);
    assign delay_done     = (delay_counter_reg == 13'd0);
    
    // delay counter
    initial delay_counter_reg = 13'd0;
    always @(posedge clk_i) begin
        if(delay_100us_ld)
            delay_counter_reg <= #1 DELAY_100US;
        else if(delay_50us_ld)
            delay_counter_reg <= #1 DELAY_50US;
        else if(delay_counter_reg > 13'd0)
            delay_counter_reg <= #1 delay_counter_reg - 13'd1;
    end
    
    
/* RECEIVED DATA REGISTER *****************************************************/
    
    reg [7:0] dout_reg;         // output register
    
    // output register
    initial dout_reg = 8'h00;
    always @(posedge clk_i)
        if(rx_done)
            dout_reg <= #1 frame_reg[8:1];
    
    // output logic
    assign dout_o   = dout_reg;
    
    
/* RECEIVE STROBE *************************************************************/
    
    reg rx_stb_ff;              // receive complete strobe flip-flop
    
    // received data strobe
    initial rx_stb_ff = 1'b0;
    always @(posedge clk_i)
            rx_stb_ff <= #1 rx_done;
    
    // output logic
    assign rx_stb_o = rx_stb_ff;
    
    
/* RECEIVE ERROR STROBE *******************************************************/
    
    wire rx_parity;             // received data parity
    reg  rx_err_stb_ff;         // receive error flip-flop
    
    assign rx_parity = ~(^ frame_reg[8:1]);
    
    // set if parity bit and computed parity are not equal
    initial rx_err_stb_ff = 1'b0;
    always @(posedge clk_i) begin
        if(rx_done)
            rx_err_stb_ff <= #1 (~frame_reg[9]) == (rx_parity);
        else
            rx_err_stb_ff <= #1 1'b0;
    end
    
    assign rx_err_stb_o = rx_err_stb_ff;
    

/* TRANSMIT STROBE ************************************************************/
    
    wire ack_done;          // ACK bit received signal
    reg  tx_stb_ff;         // transmit complete strobe
    
    assign ack_done = (state_reg == S_ACK) & (ps2_clk_fe);
    
    initial tx_stb_ff = 1'b0;
    always @(posedge clk_i)
        tx_stb_ff <= #1 ack_done;
    
    // output logic
    assign tx_stb_o = tx_stb_ff;
    
    
/* TRANSMIT ERROR STROBE ******************************************************/
    
    reg  tx_err_stb_ff;         // transmit error strobe flip-flop
    
    // error set is ACK bit is not zero
    initial tx_err_stb_ff = 1'b0;
    always @(posedge clk_i) begin
        if(ack_done)
            tx_err_stb_ff <= #1 ps2_data_sync_ff;
        else
            tx_err_stb_ff <= #1 1'b0;
    end
    
    // output logic
    assign tx_err_stb_o = tx_err_stb_ff;
    
    
/* OPEN DRAIN LOGIC ***********************************************************/
    
    reg ps2_clkout_reg;     // PS/2 clock output
    reg ps2_dout_reg;       // PS/2 data output
    
    // PS/2 clock output is low when RTS and holding data to being transmit
    initial ps2_clkout_reg = 1'b1;
    always @(posedge clk_i) begin
        if((state_reg == S_RTS) | (state_reg == S_HOLD_DATA))
            ps2_clkout_reg <= #1 1'b0;
        else
            ps2_clkout_reg <= #1 1'b1;
    end
    
    // PS/2 data output is active when transmitting
    initial ps2_dout_reg = 1'b1;
    always @(posedge clk_i) begin
        if((state_reg == S_HOLD_DATA) | (state_reg == S_TRANSMIT))
            ps2_dout_reg <= #1 frame_reg[0];
        else
            ps2_dout_reg <= #1 1'b1;
    end
    
    // convert ones to hi-Z
    assign ps2_clk_io  = (ps2_clkout_reg) ? 1'bZ : 1'b0;
    assign ps2_data_io = (ps2_dout_reg)   ? 1'bZ : 1'b0;
    
    
/* BUSY SIGNAL ****************************************************************/
    
    assign busy_o = (state_reg != S_IDLE);
    
endmodule
