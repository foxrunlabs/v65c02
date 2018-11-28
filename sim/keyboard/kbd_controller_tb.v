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
    reg       rst_i;
    reg       en_i;
    reg       we_i;
    reg [7:0] addr_i;
    reg [7:0] din_i;
    
    
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
        .rst_i      (rst_i),
        .en_i       (en_i),
        .we_i       (we_i),
        .addr_i     (addr_i),
        .din_i      (din_i),
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
    
    // PS/2 commands
    localparam SET_LED = 8'hED;
    
    // scan codes
    localparam KEY_A   = 8'h1c,
               KEY_B   = 8'h32,
               L_SHIFT = 8'h12,
               BREAK   = 8'hf0;
    
    // controller registers
    localparam STATUS = 8'h00,
               RXREG  = 8'h01,
               TXREG  = 8'h02;
    
    initial begin
        $display("\nKeyboardController Test Bench");
        
        rst_i  = 1'b0;
        en_i   = 1'b0;
        we_i   = 1'b0;
        addr_i = 8'h00;
        din_i  = 8'h00;
        
        // read STATUS register
        #1;
        en_i   = 1'b1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b\n", dout_o);
        
        // press "a"
        $write("Pressing 'a'... ");
        #1;
        ps2_dev2host(KEY_A);
        @(posedge clk_i);
        $display("done.");
        
        #100000;    // 100 us delay
        
        // release "a"
        $write("Releasing 'a'... ");
        #1;
        ps2_dev2host(BREAK);
        ps2_dev2host(KEY_A);
        @(posedge clk_i);
        $display("done.");
        
        // read the STATUS register and wait until there is a scan code ready
        #1;
        en_i   = 1'b1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        while(~dout_o[0])
            @(posedge clk_i);
        
        $display("STATUS: %b", dout_o);
        
        // read RXREG
        #1;
        addr_i = RXREG;
        @(posedge clk_i);
        
        // wait for output to register
        @(posedge clk_i);
        
        $display("RXREG: %h", dout_o);
        
        // read STATUS again
        #1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b\n", dout_o);
        
        #100000;    // 100 us delay
        
        // press shift + "b"
        $write("Pressing SHIFT+'b'... ");
        #1;
        ps2_dev2host(L_SHIFT);
        #100000;
        ps2_dev2host(KEY_B);
        @(posedge clk_i);
        $display("done.");
        
        // read the STATUS register and wait until shift key is registered
        #1;
        en_i   = 1'b1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        while(~dout_o[4])
            @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // display STATUS register
        $display("STATUS: %b", dout_o);
        
        #100000;    // 100 us delay
        
        // release "b" + shift
        $write("Releasing SHIFT+'b'... ");
        #1;
        ps2_dev2host(BREAK);
        ps2_dev2host(KEY_B);
        #100000;
        ps2_dev2host(BREAK);
        ps2_dev2host(L_SHIFT);
        @(posedge clk_i);
        $display("done.");
        
        // read STATUS register
        #1;
        en_i   = 1'b1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        // wait for output to register
        @(posedge clk_i);
        
        // display STATUS register
        $display("STATUS: %b", dout_o);
        
        // read RXREG
        #1;
        addr_i = RXREG;
        @(posedge clk_i);
        
        // wait for output to register
        @(posedge clk_i);
        
        $display("RXREG: %h", dout_o);
        
        // read STATUS register
        #1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        // wait for output to register
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // display STATUS register
        $display("STATUS: %b\n", dout_o);
        
        // simulate host-to-device communication
        $write("Sending command to host... ");
        #1;
        en_i   = 1'b1;
        we_i   = 1'b1;
        addr_i = TXREG;
        din_i  = SET_LED;
        @(posedge clk_i);
        
        #1;
        en_i  = 1'b0;
        we_i  = 1'b0;
        @(posedge clk_i);
        $display("done.");
        
        // read STATUS register
        #1;
        en_i   = 1'b1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b", dout_o);
        
        // simulate device
        ps2_host2dev();
        
        // read STATUS register
        #1;
        en_i   = 1'b1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b\n", dout_o);
        
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
            
            $display("[PS/2 Device] Received: %h", data[8:1]);
        end    
    endtask
    
endmodule
