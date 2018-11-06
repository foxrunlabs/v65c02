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
Module Name : KeyboardController_tb
File Name   : kbd_controller_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module KeyboardController associated with the
          v65C02 8-bit Computer.
*******************************************************************************/

module KeyboardController_tb;


/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       en_i;
    reg [7:0] addr_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] dout_o;
    
    
/* BI-DIRECTIONAL *************************************************************/
    
    // PS/2 open-drain bus signals
    wire ps2_clk_bus;
    wire ps2_data_bus;
    
    pullup(ps2_clk_bus);
    pullup(ps2_data_bus);
    
    assign ps2_clk_bus  = (device_clk)  ? 1'bZ : 1'b0;
    assign ps2_data_bus = (device_data) ? 1'bZ : 1'b0;
    
    
/* PS/2 DEVICE SIGNALS ********************************************************/
    
    reg device_clk;                     // PS/2 clock from device
    reg device_data;                    // PS/2 data from device
    
    
/* MODULES ********************************************************************/
    
    // unit under test
    KeyboardController KeyboardController_uut
        (
        .clk_i      (clk_i),
        .en_i       (en_i),
        .addr_i     (addr_i),
        .dout_o     (dout_o),
        .ps2_clk_io (ps2_clk_bus),
        .ps2_data_io(ps2_data_bus)
        );
    
    
/* CLOCKS *********************************************************************/
    
    // clock period (ns)
    localparam T_clk = 20;
    
    // system clock
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
        
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    // scan codes
    localparam KEY_A   = 8'h1c;
    localparam KEY_B   = 8'h32;
    localparam L_SHIFT = 8'h12;
    localparam BREAK   = 8'hf0;
    
    // controller registers
    localparam STATUS   = 8'h00,
               SCANCODE = 8'h01;
    
    initial begin
        en_i   = 1'b0;
        addr_i = 8'h00;
        
        // press and release "a"
        #1;
        press_key(KEY_A);
        #100000;
        press_key(BREAK);
        #100000;
        press_key(KEY_A);
        #100000;
        @(posedge clk_i);
        
        // read the STATUS register and wait until there is a scan code avail.
        #1;
        en_i   = 1'b1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        while(~dout_o[0])
            @(posedge clk_i);
        
        // read the scan code
        #1;
        en_i = 1'b1;
        addr_i = SCANCODE;
        @(posedge clk_i);
        
        // display the scan code
        @(posedge clk_i);
        $display("Scan code: %h", dout_o);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // press and release shift + "b"
        #1;
        press_key(L_SHIFT);
        #100000;
        press_key(KEY_B);
        #100000;
        press_key(BREAK);
        #100000;
        press_key(KEY_B);
        #100000;
        press_key(BREAK);
        #100000;
        press_key(L_SHIFT);
        #100000;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
    
/* PS/2 KEYBOARD SIMULATOR ****************************************************/
    
    // PS/2 protocol bits
    localparam B_START = 1'b0;
    localparam B_STOP  = 1'b1;
    
    
    // initial state
    initial begin
        device_clk  = 1'b1;
        device_data = 1'b1;
    end
    
    
    // simulate device-to-host communication
    task press_key;
        input [7:0] key;
        
        integer        i;
        reg            parity;
        reg     [10:0] frame;
        
        begin            
            parity = ~(^ key);
            frame  = {B_STOP, parity, key, B_START};
            
            // 10 kHz PS/2 clock
            for(i = 0; i < 11; i = i + 1) begin
                device_data = frame[i];
            
                // 50 us half-period
                #50000;
                device_clk = 1'b0;
            
                // 50 us half-period
                #50000;
                device_clk = 1'b1;
            end
        end    
    endtask
    
endmodule
