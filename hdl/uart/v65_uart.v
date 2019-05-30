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
Module Name : v65UART
File Name   : v65_uart.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : UART controller for the v65C02 8-bit Computer.        
*******************************************************************************/


module v65UART
    (
    input  wire       i_clk,        // CPU clock
    
    input  wire       i_en,         // control bus select
    input  wire       i_we,         // write enable
    
    input  wire [2:0] i_reg_sel,    // 3-bit register select
    input  wire [7:0] i_data,       // 8-bit register data input
    output wire [7:0] o_data,       // 8-bit register data output
    
    input  wire       i_rx,         // serial input
    output wire       o_tx          // serial output
    );
    
    
/* SERIAL INPUT SYNCHRONIZER **************************************************/
    
    reg        rx_async_ff;         // serial input synchronizer
    reg        rx_sync_ff;
    
    // synchronize serial input to CPU clock
    initial rx_async_ff = B_IDLE;
    initial rx_sync_ff  = B_IDLE;
    always @(posedge i_clk) begin
        rx_async_ff <= #1 i_rx;
        rx_sync_ff  <= #1 rx_async_ff;
    end
    
    
/* CONTROLLER REGISTERS *******************************************************/
    
    localparam STATUS = 3'o0,
               BRGL   = 3'o1,
               BRGH   = 3'o2,
               TXREG  = 3'o3,
               RXREG  = 3'o4;
    
    reg [7:0] brgl_reg;             // baud rate generator (LSB)
    reg [7:0] brgh_reg;             // baud rate generator (MSB)
    reg [7:0] rxdata_reg;           // received data
    reg [7:0] dout_reg;             // register data output
    
    // input registers
    initial brgl_reg = 8'h00;
    initial brgh_reg = 8'h00;
    always @(posedge i_clk)
        if(i_en)
            if(i_we)
                case(i_reg_sel)
                    BRGL:   brgl_reg <= #1 i_data;
                    BRGH:   brgh_reg <= #1 i_data;
                endcase
    
    // output registers
    initial dout_reg = 8'h00;
    always @(posedge i_clk)
        if(i_en)
            case(i_reg_sel)
                STATUS:  dout_reg <= #1 {6'b0000_00, rx_full_ff, tx_busy};
                RXREG:   dout_reg <= #1 rxdata_reg;
                default: dout_reg <= #1 8'h00;
            endcase
    
    // output logic
    assign o_data = dout_reg;
    
    
/* BAUD RATE GENERATOR ********************************************************/
    
    reg  [15:0] brg_count_reg;      // baud rate generator counter
    wire        brg_stb;            // baud rate generator strobe
    
    initial brg_count_reg = 16'h0000;
    always @(posedge i_clk) begin
        if(brg_count_reg == {brgh_reg, brgl_reg})
            brg_count_reg <= #1 16'h0000;
        else
            brg_count_reg <= #1 brg_count_reg + 16'h0001;
    end
    
    assign brg_stb = (brg_count_reg == {brgh_reg, brgl_reg});
    
    
/* TRANSMITTER ****************************************************************/
    
    wire tx_we;                     // transmit enable
    wire tx_dout;                   // serial data output
    wire tx_busy;                   // transmit busy
    
    assign tx_we = i_en & i_we & (i_reg_sel == TXREG);
    
    UART_TX UART_TX
        (
        .i_clk    (i_clk),
        .i_brg_stb(brg_stb),
        .i_we     (tx_we),
        .i_data   (i_data),
        .o_data   (tx_dout),
        .o_busy   (tx_busy)
        );
    
    // output logic
    assign o_tx = tx_dout;
    
    
/* RECEIVER *******************************************************************/
    
    localparam B_IDLE = 1'b1;       // idle high
    
    wire [7:0] rx_dout;             // 8-bit received data (non-persistent)
    wire       rx_done_stb;         // new data
    reg        rx_full_ff;          // receiver full
    
    UART_RX UART_RX
        (
        .i_clk     (i_clk),
        .i_brg_stb (brg_stb),
        .i_data    (rx_sync_ff),
        .o_data    (rx_dout),
        .o_done_stb(rx_done_stb)
        );
    
    // received data register (RXDATA)
    initial rxdata_reg = 8'h00;
    always @(posedge i_clk)
        if(rx_done_stb)
            rxdata_reg <= #1 rx_dout;           // stores read data
    
    // receiver full flag
    initial rx_full_ff = 1'b0;
    always @(posedge i_clk) begin
        if(rx_done_stb)
            rx_full_ff <= #1 1'b1;
        else
            if(i_en)
                if(i_reg_sel == RXREG)
                    rx_full_ff <= #1 1'b0;      // reset on read
    end
    
endmodule
