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
Module Name : v65Keyboard
File Name   : v65_keyboard.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 keyboard controller for the v65C02 8-bit Computer.
*******************************************************************************/

// TODO: implement a control interface, which bypasses the PS/2-to-ASCII
// module (disables it), so that we can write and read to the PS/2 keyboard.


module v65Keyboard
    (
    input  wire       i_clk,        // CPU clock
    
    input  wire       i_en,         // controller bus select
    
    input  wire       i_reg_sel,    // 1-bit register select
    output wire [7:0] o_data,       // 8-bit register data output
    
    inout  wire       io_ps2_clk,   // PS/2 clock
    inout  wire       io_ps2_data   // PS/2 serial data
    );
    
    
/* CONTROLLER REGISTERS *******************************************************/
    
    localparam STATUS = 1'b0,
               DATA   = 1'b1;
    
    reg  [7:0] dout_reg;            // register output
    
    // read logic
    initial dout_reg = 8'h00;
    always @(posedge i_clk)
        if(i_en)
            case(i_reg_sel)
                STATUS:  dout_reg <= #1 {7'b0000_000, data_full_ff};
                DATA:    dout_reg <= #1 data_reg;
                default: dout_reg <= #1 8'h00;
            endcase
    
    // output logic
    assign o_data = dout_reg;
    
    
/* PS/2 CLOCK AND DATA OUTPUT *************************************************/
    
    assign io_ps2_clk  = (data_full_ff) ? 1'b0 : 1'bZ;  // suppress if DATA full
    assign io_ps2_data = 1'bZ;                          // always receiving
    
    
/* PS/2 CLOCK INPUT SYNCHRONIZER AND FALLING EDGE DETECTOR ********************/
    
    reg  ps2_clkin_async_ff;        // PS/2 clock input synchronizer
    reg  ps2_clkin_sync_ff;         // PS/2 clock input synchronizer
    reg  ps2_clkin_sync_prev_ff;    // PS/2 clock previous input
    wire ps2_clkin_fe_stb;          // PS/2 clock input falling edge strobe
    
    // PS/2 clock input synchronizer
    initial ps2_clkin_async_ff     = 1'b1;
    initial ps2_clkin_sync_ff      = 1'b1;
    initial ps2_clkin_sync_prev_ff = 1'b1;
    always @(posedge i_clk) begin
        ps2_clkin_async_ff     <= #1 io_ps2_clk;
        ps2_clkin_sync_ff      <= #1 ps2_clkin_async_ff;
        ps2_clkin_sync_prev_ff <= #1 ps2_clkin_sync_ff;
    end
    
    // falling edge detector
    assign ps2_clkin_fe_stb = ps2_clkin_sync_prev_ff & (~ps2_clkin_sync_ff);
    
    
/* PS/2 DATA INPUT SYNCHRONIZER ***********************************************/
    
    reg ps2_din_async_ff;       // PS/2 data input synchronizer
    reg ps2_din_sync_ff;        // PS/2 data input synchronizer
    
    // PS/2 data input synchronizer
    initial ps2_din_async_ff = 1'b1;
    initial ps2_din_sync_ff  = 1'b1;
    always @(posedge i_clk) begin
        ps2_din_async_ff <= #1 io_ps2_data;
        ps2_din_sync_ff  <= #1 ps2_din_async_ff;
    end
    
    
/* PS/2 RECEIVER **************************************************************/
    
    wire       rx_en;           // PS/2 RX enable
    wire       rx_stb;          // PS/2 RX complete strobe
    wire [7:0] rx_dout;         // PS/2 RX 8-bit data output
    wire       rx_parity_err;   // PS/2 RX parity error flag
    
    // RX disabled if TX busy or RX buffer full
    assign rx_en = ~data_full_ff;
    
    PS2_RX PS2_RX
        (
        .i_clk           (i_clk),
        .i_en            (rx_en),
        .i_ps2_clk_fe_stb(ps2_clkin_fe_stb),
        .i_ps2_data      (ps2_din_sync_ff),
        .o_rx_stb        (rx_stb),
        .o_data          (rx_dout),
        .o_parity_err    (rx_parity_err)
        );
    
    
/* PS2-TO-ASCII CONVERTER *****************************************************/
    
    wire       scancode_valid;  // PS/2 scan code valid signal
    wire       ascii_valid;     // ASCII code valid signal
    wire [7:0] ascii;           // ASCII code
    
    // ignore if parity error
    assign scancode_valid = rx_stb & (~rx_parity_err);
    
    PS2toASCII PS2toASCII
        (
        .i_clk     (i_clk),
        .i_en      (scancode_valid),
        .i_scancode(rx_dout),
        .o_rdy_stb (ascii_valid),
        .o_ascii   (ascii)
        );
    
    
/* RECEIVE REGISTER ***********************************************************/
    
    reg [7:0] data_reg;         // 8-bit data register
    
    initial data_reg = 8'h00;
    always @(posedge i_clk)
        if(ascii_valid)
            data_reg <= #1 ascii;
    
    
/* BUFFER FULL BIT ************************************************************/
    
    wire data_rd;               // CPU reading DATA register
    reg  data_full_ff;          // DATAFULL bit of STATUS register
    
    assign data_rd = i_en & (i_reg_sel == DATA);
    
    // set if data register full, clear if data register read by CPU
    initial data_full_ff = 1'b0;
    always @(posedge i_clk) begin
        if(ascii_valid)
            data_full_ff <= #1 1'b1;
        else
            if(data_rd)
                data_full_ff <= #1 1'b0;
    end
    
endmodule
