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
Module Name : PS2toASCII
File Name   : ps2_to_ascii.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 scan code to ASCII code converter.
*******************************************************************************/


module PS2toASCII
    (
    input  wire       clk_i,                // CPU clock
    
    input  wire       en_i,                 // enable signal
    input  wire [7:0] scancode_i,           // PS/2 scan code
    
    output wire       rdy_stb_o,            // ASCII code ready strobe
    output wire [7:0] ascii_o               // ASCII code
    );
    
    
/* EXTENDED AND BREAK CODE FLAGS **********************************************/
    
    reg extend_ff;                          // extended scan code flag ($E0)
    reg extend_ns;
    reg break_ff;                           // break scan code flag ($F0)
    reg break_ns;
    
    initial extend_ff = 1'b0;
    initial break_ff  = 1'b0;
    always @(posedge clk_i) begin
        extend_ff <= #1 extend_ns;
        break_ff  <= #1 break_ns;
    end
    
    
/* CONTROL KEYS ***************************************************************/
    
    reg  lctrl_ff;                          // left CTRL key
    reg  lctrl_ns;
    reg  rctrl_ff;                          // right CTRL key
    reg  rctrl_ns;
    wire ctrl;
    
    initial lctrl_ff = 1'b0;
    initial rctrl_ff = 1'b0;
    always @(posedge clk_i) begin
        lctrl_ff <= #1 lctrl_ns;
        rctrl_ff <= #1 rctrl_ns;
    end
    
    assign ctrl = lctrl_ff | rctrl_ff;      // combine into one signal
    
    
/* SHIFT KEYS *****************************************************************/
    
    reg  lshift_ff;                         // left SHIFT key
    reg  lshift_ns;
    reg  rshift_ff;                         // right SHIFT key
    reg  rshift_ns;
    wire shift;
    
    initial lshift_ff = 1'b0;
    initial rshift_ff = 1'b0;
    always @(posedge clk_i) begin
        lshift_ff <= #1 lshift_ns;
        rshift_ff <= #1 rshift_ns;
    end
    
    assign shift = lshift_ff | rshift_ff;   // combine into one signal
    
    
/* STATE MACHINE **************************************************************/
    
    // states
    localparam S_IDLE    = 2'b00,           // wait for PS/2 code
               S_DECODE  = 2'b01,           // decode PS/2 to ASCII
               S_ASCII   = 2'b10;           // valid ASCII code
               
    // PS/2 scan codes
    localparam C_CTRL    = 8'h14,           // CTRL key
               C_LSHIFT  = 8'h12,           // left SHIFT key
               C_RSHIFT  = 8'h59;           // right SHIFT key
               
    localparam C_EXTEND  = 8'hE0,           // extended code
               C_BREAK   = 8'hF0;           // break code
               
    // ASCII codes
    localparam A_INVALID = 8'hFF;           // invalid ASCII code
    
    reg [1:0] state_reg;
    reg [1:0] state_ns;
    
    // state machine register
    initial state_reg = S_IDLE;
    always @(posedge clk_i)
        state_reg <= #1 state_ns;
    
    // next-state logic
    always @* begin
        state_ns  = state_reg;
        
        extend_ns = extend_ff;
        break_ns  = break_ff;
        
        lctrl_ns  = lctrl_ff;
        rctrl_ns  = rctrl_ff;
        
        lshift_ns = lshift_ff;
        rshift_ns = rshift_ff;
        
        ascii_ns  = ascii_reg;
        
        case(state_reg)
            // wait for a valid PS/2 scan code
            S_IDLE:
                begin
                    if(en_i) begin          // code received
                        case(scancode_i)
                            // extended code
                            C_EXTEND:
                                begin
                                    extend_ns = 1'b1;
                                end
                            
                            // break code
                            C_BREAK:
                                begin
                                    break_ns = 1'b1;
                                end
                            
                            // everything else
                            default:
                                begin
                                    ascii_ns = A_INVALID;
                                    state_ns = S_DECODE;
                                end
                        endcase
                    end
                end
            
            // decode the PS/2 scan code to ASCII
            S_DECODE:
                begin
                    //- reset extended and break code flags --------------------
                    extend_ns = 1'b0;
                    break_ns  = 1'b0;
                    
                    //- control keys -------------------------------------------
                    if(scancode_i == C_CTRL) begin
                        if(extend_ff)
                            rctrl_ns = ~break_ff;           // right CTRL
                        else
                            lctrl_ns = ~break_ff;           // left CTRL
                    end
                    
                    //- shift keys ---------------------------------------------
                    if(scancode_i == C_LSHIFT)
                        lshift_ns = ~break_ff;              // left SHIFT
                    else if(scancode_i == C_RSHIFT)
                        rshift_ns = ~break_ff;              // right SHIFT
                    
                    //- control key(s) pressed ---------------------------------
                    if(ctrl) begin
                        case(scancode_i)
                            8'h15: ascii_ns = 8'h11;        // ^q DC1 
                            8'h1A: ascii_ns = 8'h1A;        // ^z SUB
                            8'h1B: ascii_ns = 8'h13;        // ^s DC3
                            8'h1C: ascii_ns = 8'h01;        // ^a SOH
                            8'h1D: ascii_ns = 8'h17;        // ^w ETB
                            8'h1E: ascii_ns = 8'h00;        // ^@ NUL
                            
                            8'h21: ascii_ns = 8'h03;        // ^c ETX
                            8'h22: ascii_ns = 8'h18;        // ^x CAN
                            8'h23: ascii_ns = 8'h04;        // ^d EOT
                            8'h24: ascii_ns = 8'h05;        // ^e ENQ
                            
                            8'h2A: ascii_ns = 8'h16;        // ^v SYN
                            8'h2B: ascii_ns = 8'h06;        // ^f ACK
                            8'h2C: ascii_ns = 8'h14;        // ^t DC4
                            8'h2D: ascii_ns = 8'h12;        // ^r DC2
                            
                            8'h31: ascii_ns = 8'h0E;        // ^n SO
                            8'h32: ascii_ns = 8'h02;        // ^b STX
                            8'h33: ascii_ns = 8'h08;        // ^h BS
                            8'h34: ascii_ns = 8'h07;        // ^g BEL
                            8'h35: ascii_ns = 8'h19;        // ^y EM
                            8'h36: ascii_ns = 8'h1E;        // ^^ RS
                            8'h3A: ascii_ns = 8'h0D;        // ^m CR
                            8'h3B: ascii_ns = 8'h0A;        // ^j LF
                            8'h3C: ascii_ns = 8'h15;        // ^u NAK
                            
                            8'h42: ascii_ns = 8'h0B;        // ^k VT
                            8'h43: ascii_ns = 8'h09;        // ^i HT
                            8'h44: ascii_ns = 8'h0F;        // ^o SI
                            8'h4B: ascii_ns = 8'h0C;        // ^l FF
                            8'h4D: ascii_ns = 8'h10;        // ^p DLE
                            8'h4E: ascii_ns = 8'h1F;        // ^_ US
                            
                            8'h54: ascii_ns = 8'h1B;        // ^[ ESC
                            8'h5B: ascii_ns = 8'h1D;        // ^] GS
                            8'h5D: ascii_ns = 8'h1C;        // ^\ FS
                        endcase
                    end
                    // - control key(s) not pressed ----------------------------
                    else begin
                        //- keys that aren't affected by shift key(s) ----------
                        if(extend_ff) begin
                            case(scancode_i)
                                8'h6B: ascii_ns = 8'h82;    // left arrow
                                
                                8'h72: ascii_ns = 8'h81;    // down arrow
                                8'h74: ascii_ns = 8'h83;    // right arrow
                                8'h75: ascii_ns = 8'h80;    // up arrow
                            endcase
                        end
                        else begin
                            case(scancode_i)
                                8'h01: ascii_ns = 8'hF9;    // F9
                                8'h03: ascii_ns = 8'hF5;    // F5
                                8'h04: ascii_ns = 8'hF3;    // F3
                                8'h05: ascii_ns = 8'hF1;    // F1
                                8'h06: ascii_ns = 8'hF2;    // F2
                                8'h07: ascii_ns = 8'hFC;    // F12
                                8'h09: ascii_ns = 8'hFA;    // F10
                                8'h0A: ascii_ns = 8'hF8;    // F8
                                8'h0B: ascii_ns = 8'hF6;    // F6
                                8'h0C: ascii_ns = 8'hF4;    // F4
                                8'h0D: ascii_ns = 8'h09;    // tab
                                
                                8'h29: ascii_ns = 8'h20;    // space
                                
                                8'h5A: ascii_ns = 8'h0A;    // enter
                                
                                8'h66: ascii_ns = 8'h08;    // backspace
                                8'h6B: ascii_ns = 8'h82;    // left arrow
                                
                                8'h72: ascii_ns = 8'h81;    // down arrow
                                8'h74: ascii_ns = 8'h83;    // right arrow
                                8'h75: ascii_ns = 8'h80;    // up arrow
                                8'h76: ascii_ns = 8'h1B;    // escape
                                8'h78: ascii_ns = 8'hFB;    // F11
                                
                                8'h83: ascii_ns = 8'hF7;    // F7
                            endcase
                        end
                    
                        //- keys that are affected by shift key(s) -------------
                        if(shift) begin
                            case(scancode_i)
                                8'h0E: ascii_ns = 8'h7E;    // ~
                
                                8'h15: ascii_ns = 8'h51;    // Q
                                8'h16: ascii_ns = 8'h21;    // !
                                8'h1A: ascii_ns = 8'h5A;    // Z
                                8'h1B: ascii_ns = 8'h53;    // S
                                8'h1C: ascii_ns = 8'h41;    // A
                                8'h1D: ascii_ns = 8'h57;    // W
                                8'h1E: ascii_ns = 8'h40;    // @
            
                                8'h21: ascii_ns = 8'h43;    // C
                                8'h22: ascii_ns = 8'h58;    // X
                                8'h23: ascii_ns = 8'h44;    // D
                                8'h24: ascii_ns = 8'h45;    // E
                                8'h25: ascii_ns = 8'h24;    // $
                                8'h26: ascii_ns = 8'h23;    // #
                
                                8'h2A: ascii_ns = 8'h56;    // V
                                8'h2B: ascii_ns = 8'h46;    // F
                                8'h2C: ascii_ns = 8'h54;    // T
                                8'h2D: ascii_ns = 8'h52;    // R
                                8'h2E: ascii_ns = 8'h25;    // %
            
                                8'h31: ascii_ns = 8'h4E;    // N
                                8'h32: ascii_ns = 8'h42;    // B
                                8'h33: ascii_ns = 8'h48;    // H
                                8'h34: ascii_ns = 8'h47;    // G
                                8'h35: ascii_ns = 8'h59;    // Y
                                8'h36: ascii_ns = 8'h5E;    // ^
                                8'h3A: ascii_ns = 8'h4D;    // M
                                8'h3B: ascii_ns = 8'h4A;    // J
                                8'h3C: ascii_ns = 8'h55;    // U
                                8'h3D: ascii_ns = 8'h26;    // &
                                8'h3E: ascii_ns = 8'h2A;    // *
            
                                8'h41: ascii_ns = 8'h3C;    // <
                                8'h42: ascii_ns = 8'h4B;    // K
                                8'h43: ascii_ns = 8'h49;    // I
                                8'h44: ascii_ns = 8'h4F;    // O
                                8'h45: ascii_ns = 8'h29;    // )
                                8'h46: ascii_ns = 8'h28;    // (
                                8'h49: ascii_ns = 8'h3E;    // >
                                8'h4A: ascii_ns = 8'h3F;    // ?
                                8'h4B: ascii_ns = 8'h4C;    // L
                                8'h4C: ascii_ns = 8'h3A;    // :
                                8'h4D: ascii_ns = 8'h50;    // P
                                8'h4E: ascii_ns = 8'h5F;    // _
            
                                8'h52: ascii_ns = 8'h22;    // "
                                8'h54: ascii_ns = 8'h7B;    // {
                                8'h55: ascii_ns = 8'h2B;    // +
                
                                8'h5B: ascii_ns = 8'h7D;    // }
                                8'h5D: ascii_ns = 8'h7C;    // |
                            endcase
                        end
                        else begin
                            case(scancode_i)
                                8'h0E: ascii_ns = 8'h60;    // `
                
                                8'h15: ascii_ns = 8'h71;    // q
                                8'h16: ascii_ns = 8'h31;    // 1
                                8'h1A: ascii_ns = 8'h7A;    // z
                                8'h1B: ascii_ns = 8'h73;    // s
                                8'h1C: ascii_ns = 8'h61;    // a
                                8'h1D: ascii_ns = 8'h77;    // w
                                8'h1E: ascii_ns = 8'h32;    // 2
            
                                8'h21: ascii_ns = 8'h63;    // c
                                8'h22: ascii_ns = 8'h78;    // x
                                8'h23: ascii_ns = 8'h64;    // d
                                8'h24: ascii_ns = 8'h65;    // e
                                8'h25: ascii_ns = 8'h34;    // 4
                                8'h26: ascii_ns = 8'h33;    // 3
                
                                8'h2A: ascii_ns = 8'h76;    // v
                                8'h2B: ascii_ns = 8'h66;    // f
                                8'h2C: ascii_ns = 8'h74;    // t
                                8'h2D: ascii_ns = 8'h72;    // r
                                8'h2E: ascii_ns = 8'h35;    // 5
            
                                8'h31: ascii_ns = 8'h6E;    // n
                                8'h32: ascii_ns = 8'h62;    // b
                                8'h33: ascii_ns = 8'h68;    // h
                                8'h34: ascii_ns = 8'h67;    // g
                                8'h35: ascii_ns = 8'h79;    // y
                                8'h36: ascii_ns = 8'h36;    // 6
                                8'h3A: ascii_ns = 8'h6D;    // m
                                8'h3B: ascii_ns = 8'h6A;    // j
                                8'h3C: ascii_ns = 8'h75;    // u
                                8'h3D: ascii_ns = 8'h37;    // 7
                                8'h3E: ascii_ns = 8'h38;    // 8
            
                                8'h41: ascii_ns = 8'h2C;    // ,
                                8'h42: ascii_ns = 8'h6B;    // k
                                8'h43: ascii_ns = 8'h69;    // i
                                8'h44: ascii_ns = 8'h6F;    // o
                                8'h45: ascii_ns = 8'h30;    // 0
                                8'h46: ascii_ns = 8'h39;    // 9
                                8'h49: ascii_ns = 8'h2E;    // .
                                8'h4A: ascii_ns = 8'h2F;    // /
                                8'h4B: ascii_ns = 8'h6C;    // l
                                8'h4C: ascii_ns = 8'h3B;    // ;
                                8'h4D: ascii_ns = 8'h70;    // p
                                8'h4E: ascii_ns = 8'h2D;    // -

                                8'h52: ascii_ns = 8'h27;    // '
                                8'h54: ascii_ns = 8'h5B;    // [
                                8'h55: ascii_ns = 8'h3D;    // =
                
                                8'h5B: ascii_ns = 8'h5D;    // ]
                                8'h5D: ascii_ns = 8'h5C;    // \
                            endcase
                        end
                    end
                    
                    //- do nothing for a break code ----------------------------
                    if(break_ff)
                        state_ns = S_IDLE;
                    else
                        state_ns = S_ASCII;
                end
            
            // valid ASCII code received
            S_ASCII:
                state_ns = S_IDLE;
            
            default:
                state_ns = S_IDLE;
            
        endcase
    end
    
    
/* READY STROBE ***************************************************************/
    
    reg  rdy_ff;                    // ASCII code ready strobe
    wire ascii_valid;
    
    assign ascii_valid = (state_reg == S_ASCII) & (ascii_reg != A_INVALID);
    
    initial rdy_ff = 1'b0;
    always @(posedge clk_i) begin
        if(ascii_valid)
            rdy_ff <= #1 1'b1;
        else
            rdy_ff <= #1 1'b0;
    end
    
    // output logic
    assign rdy_stb_o = rdy_ff;
    
    
/* ASCII CODE *****************************************************************/
    
    reg [7:0] ascii_reg;            // ASCII code register
    reg [7:0] ascii_ns;
    
    initial ascii_reg = 8'h00;
    always @(posedge clk_i)
        ascii_reg <= #1 ascii_ns;
    
    // output logic
    assign ascii_o = ascii_reg;
    
endmodule
