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
Module Name : PS2Clock_tb
File Name   : ps2_clk_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module PS2Clock associated with the v65C02
          8-bit Computer.
*******************************************************************************/

module PS2Clock_tb;


/* INPUTS *********************************************************************/
    
    reg clk_i;
    reg rst_i;
    reg we_i;
    
    
/* OUTPUTS ********************************************************************/

    wire ps2_clk_fe_o;
    
    
/* PS/2 DEVICE SIGNALS ********************************************************/
    
    reg device_clk;                     // PS/2 clock from device
    
    
/* BI-DIRECTIONAL *************************************************************/
    
    // PS/2 open-drain bus signals
    wire ps2_clk_bus;
    
    pullup(ps2_clk_bus);
        
    assign ps2_clk_bus  = (device_clk)  ? 1'bZ : 1'b0;
    
    
/* MODULES ********************************************************************/
    
    PS2Clock PS2Clock_uut
        (
        .clk_i       (clk_i),
        .rst_i       (rst_i),
        .we_i        (we_i),
        .ps2_clk_io  (ps2_clk_bus),
        .ps2_clk_fe_o(ps2_clk_fe_o)
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
    
    initial begin
        rst_i = 1'b0;
        we_i  = 1'b0;
        
        ps2_dev2host();
        
        @(posedge clk_i);
        
        #100000;
        
        #1;
        we_i = 1'b1;
        @(posedge clk_i);
        
        #1;
        we_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
    
/* PS/2 KEYBOARD SIMULATOR ****************************************************/
    
    // initial state
    initial device_clk  = 1'b1;
    
    
    // simulate device-to-host communication
    task ps2_dev2host;
        integer i;                
        begin            
            // 10 kHz PS/2 clock
            for(i = 0; i < 11; i = i + 1) begin
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
