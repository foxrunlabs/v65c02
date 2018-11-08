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
Module Name : KeyboardController
File Name   : kbd_controller.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 keyboard controller for the v65C02 8-bit Computer.
*******************************************************************************/


module KeyboardController
    (
    input  wire       clk_i,        // CPU clock
    
    input  wire       en_i,         // controller bus select
    input  wire       we_i,         // write enable
    
    input  wire [7:0] addr_i,       // 8-bit register address
    input  wire [7:0] din_i,        // 8-bit register data input
    output wire [7:0] dout_o,       // 8-bit register data output
    
    inout  wire       ps2_clk_io,   // PS/2 clock
    inout  wire       ps2_data_io   // PS/2 serial data
    );
    
    
/* CONTROLLER REGISTERS *******************************************************/
    
    localparam STATUS = 8'h00,
               RXREG  = 8'h01,
               TXREG  = 8'h02;
    
    wire [7:0] status;              // STATUS register bits
    wire       shift;               // combination of left and right shift keys
    reg  [7:0] dout_reg;            // register output
    
    assign shift  = lshift_ff | rshift_ff;
    assign status = {3'b000, tcvr_busy, alt_ff, ctrl_ff, shift, data_rdy_ff};
    
    // read logic
    initial dout_reg = 8'h00;
    always @(posedge clk_i)
        if(en_i)
            case(addr_i)
                STATUS:  dout_reg <= #1 status;
                RXREG:   dout_reg <= #1 rxreg_reg;
                default: dout_reg <= #1 8'h00;
            endcase
    
    // output logic
    assign dout_o = dout_reg;
    
    
/* TRANSCEIVER ****************************************************************/
    
    wire       tcvr_busy;               // busy flag
    wire       tcvr_we;                 // write enable
    wire       tx_stb;                  // transmit data complete strobe
    wire       tx_err_stb;              // transmit error strobe
    wire       rx_stb;                  // receive data complete strobe
    wire [7:0] rx_data;                 // received data
    wire       rx_err_stb;              // receive error strobe
    
    assign tcvr_we = en_i & we_i & (addr_i == TXREG);
    
    PS2Transceiver PS2Transceiver
        (
        .clk_i       (clk_i),
        .ps2_clk_io  (ps2_clk_io),
        .ps2_data_io (ps2_data_io),
        .busy_o      (tcvr_busy),
        .we_i        (tcvr_we),
        .din_i       (din_i),
        .tx_stb_o    (tx_stb),
        .tx_err_stb_o(tx_err_stb),
        .rx_stb_o    (rx_stb),
        .dout_o      (rx_data),
        .rx_err_stb_o(rx_err_stb)
        );
    
    
/* RECEIVE STATE MACHINE ******************************************************/
    
    localparam S_IDLE     = 2'b00,      // idle state
               S_MAKE     = 2'b01,      // make state
               S_MODIFIER = 2'b10,      // alt, ctrl, shift keys
               S_BREAK    = 2'b11;      // break key state
    
    localparam C_EXTEND = 8'hE0,        // extended scan code
               C_BREAK  = 8'hF0;        // break scan code
    
    // modifier keys
    localparam C_ALT    = 8'h11,
               C_CTRL   = 8'h14,
               C_LSHIFT = 8'h12,
               C_RSHIFT = 8'h59;
    
    reg [1:0] state_reg;
    reg [1:0] state_ns;
    
    initial state_reg = S_IDLE;
    always @(posedge clk_i)
        state_reg <= #1 state_ns;
    
    // next state logic
    always @* begin
        state_ns = state_reg;
                
        case(state_reg)
            S_IDLE:     // wait for a key make or break
                if(rx_stb)
                    case(rx_data)
                        C_ALT:    state_ns = S_MODIFIER;
                        C_CTRL:   state_ns = S_MODIFIER;
                        C_LSHIFT: state_ns = S_MODIFIER;
                        C_RSHIFT: state_ns = S_MODIFIER;
                        C_EXTEND: state_ns = S_IDLE;
                        C_BREAK:  state_ns = S_BREAK;
                        default:  state_ns = S_MAKE;
                    endcase
            
            S_MAKE:         // key pressed
                state_ns = S_IDLE;
            
            S_MODIFIER:     // alt, ctrl, or shift key pressed
                state_ns = S_IDLE;
            
            S_BREAK:        // break code
                if(rx_stb)
                    state_ns = S_IDLE;
            
            default:
                state_ns = S_IDLE;
        
        endcase        
    end
    
    
/* RECEIVE REGISTER ***********************************************************/
    
    wire       rxreg_en;        // receive register enable
    reg  [7:0] rxreg_reg;       // received data register
    
    assign rxreg_en = (state_reg == S_MAKE);    // only save make codes
    
    initial rxreg_reg = 8'h00;
    always @(posedge clk_i)
        if(rxreg_en)
            rxreg_reg <= #1 rx_data;
    
    
/* MODIFIER KEY BITS **********************************************************/
    
    wire modifier_make;     // modifier key make criteria
    wire modifier_break;    // modifier key break criteria
    
    // alt key signals
    reg  alt_ff;
    wire alt_dn;
    wire alt_up;
    
    // ctrl key signals
    reg  ctrl_ff;
    wire ctrl_dn;
    wire ctrl_up;
    
    // left shift key signals
    reg  lshift_ff;
    wire lshift_dn;
    wire lshift_up;
    
    // right shift key signals
    reg  rshift_ff;
    wire rshift_dn;
    wire rshift_up;
    
    assign modifier_make  = (state_reg == S_MODIFIER);
    assign modifier_break = (state_reg == S_BREAK) & rx_stb;
    
    // alt, control, and shift key down and up signals
    assign alt_dn    = modifier_make & (rx_data == C_ALT);
    assign ctrl_dn   = modifier_make & (rx_data == C_CTRL);
    assign lshift_dn = modifier_make & (rx_data == C_LSHIFT);
    assign rshift_dn = modifier_make & (rx_data == C_RSHIFT);
    
    assign alt_up    = modifier_break & (rx_data == C_ALT);
    assign ctrl_up   = modifier_break & (rx_data == C_CTRL);
    assign lshift_up = modifier_break & (rx_data == C_LSHIFT);
    assign rshift_up = modifier_break & (rx_data == C_RSHIFT);
    
    // alt key
    initial alt_ff = 1'b0;
    always @(posedge clk_i) begin
        if(alt_dn)
            alt_ff <= #1 1'b1;
        else if(alt_up)
            alt_ff <= #1 1'b0;
    end
    
    // control key
    initial ctrl_ff = 1'b0;
    always @(posedge clk_i) begin
        if(ctrl_dn)
            ctrl_ff <= #1 1'b1;
        else if(ctrl_up)
            ctrl_ff <= #1 1'b0;
    end
    
    // left shift key
    initial lshift_ff = 1'b0;
    always @(posedge clk_i) begin
        if(lshift_dn)
            lshift_ff <= #1 1'b1;
        else if(lshift_up)
            lshift_ff <= #1 1'b0;
    end
    
    // right shift key
    initial rshift_ff = 1'b0;
    always @(posedge clk_i) begin
        if(rshift_dn)
            rshift_ff <= #1 1'b1;
        else if(rshift_up)
            rshift_ff <= #1 1'b0;
    end
    
    
/* DATA READY BIT *************************************************************/
    
    wire data_rdy_rst;
    wire data_rdy_set;
    reg  data_rdy_ff;
    reg  data_rdy_ns;
    
    assign data_rdy_set = rxreg_en;                     // same criteria
    assign data_rdy_rst = en_i & (addr_i == RXREG);     // receive register read
    
    // set if data ready, clear if RXREG is read
    initial data_rdy_ff = 1'b0;
    always @(posedge clk_i) begin
        if(data_rdy_set)
            data_rdy_ff <= #1 1'b1;
        else if(data_rdy_rst)
            data_rdy_ff <= #1 1'b0;
    end
    
endmodule
