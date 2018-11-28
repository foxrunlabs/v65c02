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
    reg       rst_i;
    reg       we_i;
    reg [7:0] din_i;
    
    
/* OUTPUTS ********************************************************************/
    
    wire       tx_busy_o;
    wire       tx_err_o;
    wire       rx_stb_o;
    wire       rx_err_o;
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
    PS2Transceiver PS2Transceiver_uut
        (
        .clk_i      (clk_i),
        .rst_i      (rst_i),
        .ps2_clk_io (ps2_clk_bus),
        .ps2_data_io(ps2_data_bus),
        .we_i       (we_i),
        .din_i      (din_i),
        .tx_busy_o  (tx_busy_o),
        .tx_err_o   (tx_err_o),
        .rx_stb_o   (rx_stb_o),
        .rx_err_o   (rx_err_o),
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
    
    
/* MAIN SIMULATION ************************************************************/
    
    // scan codes
    localparam KEY_U = 8'h3C;
    localparam KEY_Q = 8'h15;
    
    initial begin
        rst_i = 1'b0;
        we_i  = 1'b0;
        din_i = 8'h00;
                
        // simulate device-to-host communication
        $write("Pressing U... ");
        #1;
        ps2_dev2host(KEY_U);
        @(posedge clk_i);
        
        #100000;    // 100 us delay
        
        $write("Pressing Q... ");
        #1;
        ps2_dev2host(KEY_Q);
        @(posedge clk_i);
        
        #100000;    // 100 us delay
        
        // simulate host-to-device communication
        #1;
        we_i  = 1'b1;
        din_i = 8'h7F;
        @(posedge clk_i);
        
        #1;
        we_i  = 1'b0;
        din_i = 8'h00;
        @(posedge clk_i);
        
        ps2_host2dev();
        
        // done
        @(posedge clk_i) $stop;
    end
    
    
/* SCAN CODE PRINTER **********************************************************/
    
    always @(posedge clk_i)
        if(rx_stb_o)
            $display("Host Received: %h", dout_o);
    
    
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
    task ps2_dev2host;
        input [7:0] din;
        
        integer        i;
        reg            parity;
        reg     [10:0] frame;
        
        begin            
            parity = ~(^ din);
            frame  = {B_STOP, parity, din, B_START};
            
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
    
    
    // simulate host-to-device communication
    task ps2_host2dev;
        integer        i;
        reg     [10:0] data;
        reg            parity;
        begin
            data = {11{1'b1}};
            
            @(posedge ps2_clk_bus);
            
            // 10kHz PS/2 clock
            for(i = 0; i < 10; i = i + 1)
                begin                    
                    // 50 us half-period
                    #50000;
                    device_clk = 1'b0;
                    
                    // 50 us half-period
                    #50000;
                    device_clk = 1'b1;
                    data       = {ps2_data_bus, data[10:1]};
                end
            
            #25000;
            parity      = ~(^ data[8:1]);
            device_data = ~(parity == data[9]);
            
            #25000;
            device_clk = 1'b0;
            
            #50000;
            device_clk  = 1'b1;
            device_data = 1'b1;
            
            $display("Host Sent: %h", data[8:1]);
        end    
    endtask
    
endmodule
