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
Module Name : PS2_Transceiver_tb
File Name   : ps2_tcvr_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module PS2_Transceiver associated with the
          v65C02 8-bit Computer.
*******************************************************************************/

module PS2Transceiver_tb;


/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       we_i;
    reg [7:0] din_i;
    
    
/* BI-DIRECTIONAL *************************************************************/
    
    wire ps2_clk_io;
    wire ps2_data_io;
    
    
/* OUTPUTS ********************************************************************/
    
    wire       busy_o;
    wire       rx_stb_o;
    wire [7:0] dout_o;
    
    
/* OPEN DRAIN LOGIC ***********************************************************/
    
    reg ps2_clk;                    // PS/2 clock from device
    reg ps2_data;                   // PS/2 data from device
    
    // pull-ups for PS/2 bus
    pullup(ps2_clk_io);
    pullup(ps2_data_io);
    
    assign ps2_clk_io = ps2_clk;
    assign ps2_data_io = ps2_data;
    
    
/* MODULES ********************************************************************/
    
    // unit under test
    PS2Transceiver PS2Transceiver_uut
        (
        .clk_i      (clk_i),
        .ps2_clk_io (ps2_clk_io),
        .ps2_data_io(ps2_data_io),
        .busy_o     (busy_o),
        .we_i       (we_i),
        .din_i      (din_i),
        .rx_stb_o   (rx_stb_o),
        .dout_o     (dout_o)
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
    
    
/* MAIN ***********************************************************************/
    
    // scan codes
    localparam KEY_U = 8'h3C;
    localparam KEY_Q = 8'h15;
    
    initial begin
        ps2_clk  = 1'bZ;
        ps2_data = 1'bZ;
        we_i     = 1'b0;
        din_i    = 8'h00;
        
        $write("Pressing U... ");
        #1;
        ps2_kbd(KEY_U);
        @(posedge clk_i);
        
        $write("Pressing Q... ");
        #1;
        ps2_kbd(KEY_Q);
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
    // display scan code when received
    always @(posedge clk_i)
        if(rx_stb_o)
            $display("Scan code: %h", dout_o);
    
    
/* PS/2 KEYBOARD SIMULATOR ****************************************************/
    
    // PS/2 protocol bits
    localparam B_START = 1'b0;
    localparam B_STOP  = 1'b1;
    
    // Simulate pressing a key
    task ps2_kbd;
        input [7:0] key;
        
        integer        i;
        reg            parity;
        reg     [10:0] frame;
        
        begin            
            parity = ~(^ key);
            frame = {B_STOP, parity, key, B_START};
            
            // 10 kHz PS/2 clock
            for(i = 0; i < 11; i = i + 1) begin
                ps2_data = (frame[i]) ? 1'bZ : 1'b0;
            
                // 50 us half-period
                #(50000);
                ps2_clk = 1'b0;
            
                // 50 us half-period
                #(50000);
                ps2_clk = 1'bZ;
            end
        end    
    endtask
    
endmodule
