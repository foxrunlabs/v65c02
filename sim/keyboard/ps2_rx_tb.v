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
Module Name : PS2_RX_tb
File Name   : ps2_rx_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module PS2_RX associated with the v65C02 8-bit
          Computer.
*******************************************************************************/

module PS2_RX_tb;


/* INPUTS *********************************************************************/
    
    reg clk_i;
    reg en_i;
    reg ps2_clk_fe_stb_i;
    reg ps2_din_i;
    
    
/* OUTPUTS ********************************************************************/
    
    wire       rx_stb_o;
    wire [7:0] dout_o;
    wire       parity_err_o;
    
    
/* PS/2 DEVICE SIGNALS ********************************************************/
    
    reg ps2_clk;
    reg ps2_clk_prev;
    
    
/* MODULES ********************************************************************/
    
    PS2_RX PS2_RX_uut
        (
        .clk_i           (clk_i),
        .en_i            (en_i),
        .ps2_clk_fe_stb_i(ps2_clk_fe_stb_i),
        .ps2_din_i       (ps2_din_i),
        .rx_stb_o        (rx_stb_o),
        .dout_o          (dout_o),
        .parity_err_o    (parity_err_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    // clock period (ns)
    localparam T_clk = 20;
    
    // 50 MHz system clock
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
        
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN SIMULATION ************************************************************/
    
    // scan codes
    localparam KEY_U = 8'h3C;
    localparam KEY_Q = 8'h15;
    
    initial begin        
        en_i      = 1'b0;
        ps2_din_i = 1'b1;
        @(posedge clk_i);      
        
        // simulate device-to-host communication
        $write("Pressing U... ");
        #1;
        ps2_dev2host(KEY_U);
        @(posedge clk_i);
        
        #100000;    // 100 us delay
        
        #1;
        en_i = 1'b1;
        @(posedge clk_i);
        
        $write("Pressing U... ");
        #1;
        ps2_dev2host(KEY_U);
        @(posedge clk_i);
        
        #100000;    // 100 us delay
        
        $write("Pressing Q... ");
        #1;
        ps2_dev2host(KEY_Q);
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
    
/* SCAN CODE PRINTER **********************************************************/
    
    always @(posedge clk_i)
        if(rx_stb_o)
            $display("Scan code: %h", dout_o);
    
    
/* PS/2 CLOCK FALLING EDGE DETECTOR *******************************************/
    
    initial ps2_clk = 1'b1;
    
    initial ps2_clk_prev = 1'b1;
    always @(posedge clk_i)
        ps2_clk_prev <= #1 ps2_clk;
    
    initial ps2_clk_fe_stb_i = 1'b0;
    always @(posedge clk_i)
        ps2_clk_fe_stb_i <= #1 ps2_clk_prev & (~ps2_clk);
    
    
/* PS/2 KEYBOARD SIMULATOR ****************************************************/
    
    // PS/2 protocol bits
    localparam B_START = 1'b0;
    localparam B_STOP  = 1'b1;
    
    // simulate device-to-host communication
    task ps2_dev2host;
        input [7:0] din;
        
        integer        i;
        reg            parity;
        reg     [10:0] frame;
        
        begin            
            parity = ~(^ din);      // odd parity
            frame  = {B_STOP, parity, din, B_START};
            
            // 10 kHz PS/2 clock
            for(i = 0; i < 11; i = i + 1) begin
                ps2_din_i = frame[i];
            
                // 50 us half-period
                #50000;
                ps2_clk = 1'b0;
            
                // 50 us half-period
                #50000;
                ps2_clk = 1'b1;
            end
        end    
    endtask
    
endmodule
