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
    reg       we_i;
    reg       regsel_i;
    reg [7:0] din_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] dout_o;
    
    
/* BI-DIRECTIONAL *************************************************************/
    
    // PS/2 open-drain bus signals
    wire ps2_clk_io;
    wire ps2_data_io;
    
    pullup(ps2_clk_io);
    pullup(ps2_data_io);
    
    assign ps2_clk_io  = (ps2_clk)  ? 1'bZ : 1'b0;
    assign ps2_data_io = (ps2_data) ? 1'bZ : 1'b0;
    
    
/* PS/2 DEVICE SIGNALS ********************************************************/
    
    reg ps2_clk;                    // PS/2 clock from device
    reg ps2_data;                   // PS/2 data from device
    
    
/* MODULES ********************************************************************/
    
    // unit under test
    KeyboardController KeyboardController_uut
        (
        .clk_i      (clk_i),
        .en_i       (en_i),
        .we_i       (we_i),
        .regsel_i   (regsel_i),
        .din_i      (din_i),
        .dout_o     (dout_o),
        .ps2_clk_io (ps2_clk_io),
        .ps2_data_io(ps2_data_io)
        );
    
    
/* CLOCKS *********************************************************************/
    
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
    
    // PS/2 commands
    localparam SET_LED = 8'hED;
    
    // scan codes
    localparam KEY_A   = 8'h1C,
               KEY_B   = 8'h32,
               L_SHIFT = 8'h12,
               BREAK   = 8'hF0;
    
    // controller registers
    localparam STATUS = 1'b0,
               DATA   = 1'b1;
    
    initial begin
        $display("\nKeyboardController Test Bench");
        
        // initial conditions
        en_i     = 1'b0;
        we_i     = 1'b0;
        regsel_i = 1'b0;
        din_i    = 8'h00;
        
        // verify STATUS register cleared, press a key, verify RX_FULL bit of
        // STATUS register set, read DATA register, verify RX_FULL bit of 
        // STATUS register cleared
        
        // read the STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = STATUS;
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
        
        // read the STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b", dout_o);
        
        // read the DATA register
        #1;
        en_i     = 1'b1;
        regsel_i = DATA;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("DATA: %h", dout_o);
        
        // read the STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b\n", dout_o);
        
        // press a key, verify RX_FULL bit of STATUS register set, press another
        // key, verify RX_FULL bit still set, read the DATA register, which
        // should contain the first keypress
        
        // press "b"
        $write("Pressing 'b'... ");
        #1;
        ps2_dev2host(KEY_B);
        @(posedge clk_i);
        $display("done.");
        
        // read the STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b", dout_o);
        
        // press "a"
        $write("Pressing 'a'... ");
        if(ps2_clk_io) begin
            #1;
            ps2_dev2host(KEY_A);
            @(posedge clk_i);
            $display("done.");
        end
        else begin
            $display("bus busy.");
        end
        
        // read the STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b", dout_o);
        
        // read the DATA register
        #1;
        en_i     = 1'b1;
        regsel_i = DATA;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("DATA: %h", dout_o);
        
        // read the STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b\n", dout_o);
        
        // press "a"
        $write("Pressing 'a'... ");
        if(ps2_clk_io) begin
            #1;
            ps2_dev2host(KEY_A);
            @(posedge clk_i);
            $display("done.");
        end
        else begin
            $display("bus busy.");
        end
        
        // read the STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b", dout_o);
        
        // read the DATA register
        #1;
        en_i     = 1'b1;
        regsel_i = DATA;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("DATA: %h", dout_o);
        
        // read the STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = STATUS;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        $display("STATUS: %b", dout_o);
        
        // simulate host-to-device communication
        // $write("Sending command to host... ");
//         #1;
//         en_i     = 1'b1;
//         we_i     = 1'b1;
//         regsel_i = TXREG;
//         din_i    = SET_LED;
//         @(posedge clk_i);
//         
//         #1;
//         en_i  = 1'b0;
//         we_i  = 1'b0;
//         @(posedge clk_i);
//         $display("done.");
//         
//         // read STATUS register
//         #1;
//         en_i     = 1'b1;
//         regsel_i = STATUS;
//         @(posedge clk_i);
//         
//         #1;
//         en_i = 1'b0;
//         @(posedge clk_i);
//         
//         $display("STATUS: %b", dout_o);
//         
//         // simulate device
//         ps2_host2dev();
//         
//         // read STATUS register
//         #1;
//         en_i     = 1'b1;
//         regsel_i = STATUS;
//         @(posedge clk_i);
//         
//         #1;
//         en_i = 1'b0;
//         @(posedge clk_i);
//         
//         $display("STATUS: %b\n", dout_o);
        
        // done
        @(posedge clk_i) $stop;
    end
    
    
/* PS/2 KEYBOARD SIMULATOR ****************************************************/
    
    // PS/2 protocol bits
    localparam B_START = 1'b0;
    localparam B_STOP  = 1'b1;
    
    // initial state
    initial ps2_clk  = 1'b1;
    initial ps2_data = 1'b1;
    
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
                ps2_data = frame[i];
            
                // 50 us half-period
                #50000;
                ps2_clk = 1'b0;
            
                // 50 us half-period
                #50000;
                ps2_clk = 1'b1;
                
                // last clock half-period
                #50000;
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
            
            // 10kHz PS/2 clock
            // receive 10 bits... last bit requires special clock simulation
            for(i = 0; i < 10; i = i + 1)
                begin                    
                    // 50 us half-period
                    #50000;
                    ps2_clk = 1'b1;
                    data    = {ps2_data_io, data[10:1]};
                    
                    // 50 us half-period
                    #50000;
                    ps2_clk = 1'b0;
                end
            
            // capture stop bit
            #50000;
            ps2_clk = 1'b1;
            data    = {ps2_data_io, data[10:1]};
            parity  = ~(^ data[8:1]);
            
            // compute ACK or NACK and send
            #25000;
            ps2_data = ~(parity == data[9]);
            
            if(ps2_data)
                $display("NACK");
            else
                $display("ACK");
            
            // back on cycle
            #25000;
            ps2_clk = 1'b0;
            
            // clear clock and data lines to high
            #50000;
            ps2_clk  = 1'b1;
            ps2_data = 1'b1;
            
            // last clock half-period
            #50000;
            
            $display("Host sent: %h", data[8:1]);
        end    
    endtask
    
endmodule
