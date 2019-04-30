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
Module Name : KeyboardController
File Name   : kbd_controller.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 keyboard controller for the v65C02 8-bit Computer.
*******************************************************************************/

// TODO: implement a control interface, which bypasses the PS/2-to-ASCII
// module (disables it), so that we can write and read to the PS/2 keyboard.


module KeyboardController
    (
    input  wire       clk_i,        // CPU clock
    
    input  wire       en_i,         // controller bus select
    input  wire       we_i,         // write enable
    
    input  wire       regsel_i,     // 1-bit register select
    input  wire [7:0] din_i,        // 8-bit register data input
    output wire [7:0] dout_o,       // 8-bit register data output
    
    inout  wire       ps2_clk_io,   // PS/2 clock
    inout  wire       ps2_data_io   // PS/2 serial data
    );
    
    
/* CONTROLLER REGISTERS *******************************************************/
    
    localparam STATUS = 1'b0,
               DATA   = 1'b1;
    
    wire [7:0] status;              // STATUS register bits
    reg  [7:0] dout_reg;            // register output
    
    assign status = {4'b0000, tx_err, tx_busy, rx_parity_err, rx_full_ff};
    
    // read logic
    initial dout_reg = 8'h00;
    always @(posedge clk_i)
        if(en_i)
            if(~we_i)
                case(regsel_i)
                    STATUS:  dout_reg <= #1 status;
                    DATA:    dout_reg <= #1 rx_data_reg;
                    default: dout_reg <= #1 8'h00;
                endcase
    
    // output logic
    assign dout_o = dout_reg;
    
    
/* PS/2 CLOCK INPUT SYNCHRONIZER **********************************************/
    
    reg ps2_clkin_async_ff;     // PS/2 clock input synchronizer
    reg ps2_clkin_sync_ff;      // PS/2 clock input synchronizer
    
    // PS/2 clock input synchronizer
    initial ps2_clkin_async_ff = 1'b1;
    initial ps2_clkin_sync_ff  = 1'b1;
    always @(posedge clk_i) begin
        ps2_clkin_async_ff <= #1 ps2_clk_io;
        ps2_clkin_sync_ff  <= #1 ps2_clkin_async_ff;
    end
    
    
/* PS/2 DATA INPUT SYNCHRONIZER ***********************************************/
    
    reg ps2_din_async_ff;       // PS/2 data input synchronizer
    reg ps2_din_sync_ff;        // PS/2 data input synchronizer
    
    // PS/2 data input synchronizer
    initial ps2_din_async_ff = 1'b1;
    initial ps2_din_sync_ff  = 1'b1;
    always @(posedge clk_i) begin
        ps2_din_async_ff <= #1 ps2_data_io;
        ps2_din_sync_ff  <= #1 ps2_din_async_ff;
    end
    
    
/* PS/2 CLOCK INPUT EDGE DETECTORS ********************************************/
    
    reg  ps2_clkin_prev_ff;     // PS/2 clock input previous value
    wire ps2_clk_re_stb;        // PS/2 clock input rising edge strobe
    wire ps2_clk_fe_stb;        // PS/2 clock input falling edge strobe
    
    // capture PS/2 clock previous value
    initial ps2_clkin_prev_ff = 1'b1;
    always @(posedge clk_i)
        ps2_clkin_prev_ff <= #1 ps2_clkin_sync_ff;
    
    // rising edge detector
    assign ps2_clk_re_stb = (~ps2_clkin_prev_ff) & ps2_clkin_sync_ff;
    
    // falling edge detector
    assign ps2_clk_fe_stb = ps2_clkin_prev_ff & (~ps2_clkin_sync_ff);
    
    
/* PS/2 CLOCK OUTPUT **********************************************************/
    
    assign ps2_clk_io = (rx_full_ff) ? 1'b0 : 1'bZ;
    
    
/* PS/2 TRANSMITTER ***********************************************************/
    
    wire tx_we;                 // TX write enable
    wire tx_dout;               // TX 1-bit data output
    wire tx_busy;               // TX busy flag
    wire tx_err;                // TX error flag
    
    assign tx_we = 1'b0;        // disabled
    
    PS2_TX PS2_TX
        (
        .clk_i           (clk_i),
        .we_i            (tx_we),
        .din_i           (din_i),
        .ps2_clk_re_stb_i(ps2_clk_re_stb),
        .ps2_clk_fe_stb_i(ps2_clk_fe_stb),
        .ps2_din_i       (ps2_din_sync_ff),
        .ps2_dout_o      (tx_dout),
        .tx_busy_o       (tx_busy),
        .tx_err_o        (tx_err)
        );
    
    assign ps2_data_io = (tx_dout) ? 1'bZ : 1'b0;   // hi-Z or active low
    
    
/* PS/2 RECEIVER **************************************************************/
    
    wire       rx_en;           // RX enable
    wire       rx_stb;          // RX complete strobe
    wire [7:0] rx_dout;         // RX 8-bit data output
    wire       rx_parity_err;   // RX parity error flag
    
    // RX disabled if TX busy or RX buffer full
    assign rx_en = ~(tx_busy | rx_full_ff);
    
    PS2_RX PS2_RX
        (
        .clk_i           (clk_i),
        .en_i            (rx_en),
        .ps2_clk_fe_stb_i(ps2_clk_fe_stb),
        .ps2_din_i       (ps2_din_sync_ff),
        .rx_stb_o        (rx_stb),
        .dout_o          (rx_dout),
        .parity_err_o    (rx_parity_err)
        );
    
    
/* PS2-TO-ASCII CONVERTER *****************************************************/
    
    wire       scancode_valid;  // PS/2 scan code valid signal
    wire       ascii_valid;     // ASCII code valid signal
    wire [7:0] ascii;           // ASCII code
    
    // ignore if parity error
    assign scancode_valid = rx_stb & (~rx_parity_err);
    
    PS2toASCII PS2toASCII
        (
        .clk_i     (clk_i),
        .en_i      (scancode_valid),
        .scancode_i(rx_dout),
        .rdy_stb_o (ascii_valid),
        .ascii_o   (ascii)
        );
    
    
/* RECEIVE REGISTER ***********************************************************/
    
    reg [7:0] rx_data_reg;      // RX 8-bit data buffer register
    
    initial rx_data_reg = 8'h00;
    always @(posedge clk_i)
        if(ascii_valid)
            rx_data_reg <= #1 ascii;
    
    
/* BUFFER FULL BIT ************************************************************/
    
    wire data_rd;               // CPU reading DATA register
    reg  rx_full_ff;            // RX full flag
    
    // CPU reading DATA register read flag
    assign data_rd = en_i & (~we_i) & (regsel_i == DATA);
    
    // set if receive buffer full, clear if receive buffer read
    initial rx_full_ff = 1'b0;
    always @(posedge clk_i) begin
        if(ascii_valid)
            rx_full_ff <= #1 1'b1;
        else
            if(data_rd)
                rx_full_ff <= #1 1'b0;
    end
    
endmodule
