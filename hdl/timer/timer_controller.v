`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright 2018-2019 Ryan Clarke

Licensed under the Solderpad Hardware License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License. You may obtain a
copy of the License at

    https://solderpad.org/licenses/SHL-2.0/

Unless required by applicable law or agreed to in writing, software, hardware
and materials distributed under the License are distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.
*******************************************************************************/

/*******************************************************************************
Module Name : TimerController
File Name   : timer_controller.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : 32-bit timer controller for the v65C02 8-bit Computer.
*******************************************************************************/


module TimerController
    (
    input  wire       clk_i,        // CPU clock
    
    input  wire       en_i,         // controller bus select
    input  wire       we_i,         // controller bus write enable
    
    input  wire [2:0] regsel_i,     // 3-bit register select
    input  wire [7:0] din_i,        // 8-bit register data input
    output reg  [7:0] dout_o        // 8-bit register data output
    );
    
    
/* CONTROLLER BUS *************************************************************/
    
    localparam R_STATUS  = 3'o0,
               R_TIMER08 = 3'o1,
               R_TIMER16 = 3'o2,
               R_TIMER24 = 3'o3,
               R_TIMER32 = 3'o4;
    
    reg  [31:0] timer_reg;
    wire        timer_rst;
    
    // input registers
    initial timer_reg = 32'h00000000;
    always @(posedge clk_i)
        if(en_i)
            if(we_i)
                case(regsel_i)
                    R_TIMER08: timer_reg <= #1 {timer_reg[31:8], din_i};
                    R_TIMER16: timer_reg <= #1 {timer_reg[31:16], din_i,
                                                timer_reg[7:0]};
                    R_TIMER24: timer_reg <= #1 {timer_reg[31:24], din_i,
                                                timer_reg[15:0]};
                    R_TIMER32: timer_reg <= #1 {din_i, timer_reg[23:0]};
                endcase
    
    assign timer_rst = en_i & we_i & (regsel_i == R_TIMER32);
    
    // output registers
    initial dout_o = 8'h00;
    always @(posedge clk_i)
        if(en_i)
            case(regsel_i)
                R_STATUS: dout_o <= #1 {7'b0000_000, ovrfl_ff};
                default:  dout_o <= #1 8'h00;
            endcase
    
    
/* COUNTER ********************************************************************/
    
    reg  [31:0] counter_reg;          // internal 32-bit counter

    wire       ovrfl_rst;
    reg        ovrfl_ff;
    
    // 32-bit counter
    initial counter_reg = 32'h00000000;
    always @(posedge clk_i) begin
        if(timer_rst)
            counter_reg <= #1 32'h00000000;
        else
            if(~ovrfl_ff)
                if(counter_reg < timer_reg)
                    counter_reg <= #1 counter_reg + 32'h00000001;
    end
    
    // overflow flag (OVRFL)
    initial ovrfl_ff = 1'b0;
    always @(posedge clk_i) begin
        if(timer_rst)
            ovrfl_ff <= #1 1'b0;
        else
            if(counter_reg == timer_reg)
                ovrfl_ff <= #1 1'b1;
    end
    
endmodule
