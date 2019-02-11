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
Module Name : TimerController_tb
File Name   : timer_controller_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module TimerController associated with
          the v65C02 8-bit Computer.
*******************************************************************************/


module TimerController_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       en_i;
    reg       we_i;
    reg [2:0] regsel_i;
    reg [7:0] din_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] dout_o;
    
    
/* MODULES ********************************************************************/
    
    TimerController TimerController_uut
        (
        .clk_i   (clk_i),
        .en_i    (en_i),
        .we_i    (we_i),
        .regsel_i(regsel_i),
        .din_i   (din_i),
        .dout_o  (dout_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    // clock period (ns)
    localparam T_clk = 10;
    
    // system clock
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
    
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        en_i     = 1'b0;
        we_i     = 1'b0;
        regsel_i = 3'o0;
        din_i    = 8'd0;
        
        // write 10 to TIMER
        #1;
        en_i     = 1'b1;
        we_i     = 1'b1;
        regsel_i = 3'o1;
        din_i    = 8'd10;
        @(posedge clk_i);
        
        #1;
        regsel_i = 3'o2;
        din_i    = 8'h00;
        @(posedge clk_i);
        
        #1;
        regsel_i = 3'o3;
        din_i    = 8'h00;
        @(posedge clk_i);
        
        #1;
        regsel_i = 3'o4;
        din_i    = 8'h00;
        @(posedge clk_i);
        
        // deselect controller bus
        #1;
        en_i = 1'b0;
        we_i = 1'b0;
        @(posedge clk_i);
        
        // read STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = 3'o0;
        @(posedge clk_i);
        
        // test the OVRFL flag
        while(~dout_o[0])
            @(posedge clk_i);
        
        // deselect controller bus
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // reinitiate
        #1;
        en_i     = 1'b1;
        we_i     = 1'b1;
        regsel_i = 3'o4;
        din_i    = 8'h00;
        @(posedge clk_i);
        
        // deselect controller bus
        #1;
        en_i = 1'b0;
        we_i = 1'b0;
        @(posedge clk_i);
        
        // read STATUS register
        #1;
        en_i     = 1'b1;
        regsel_i = 3'o0;
        @(posedge clk_i);
        
        // test the OVRFL flag
        while(~dout_o[0])
            @(posedge clk_i);
        
        // deselect controller bus
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end

endmodule
