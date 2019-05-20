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
Module Name : Clock
File Name   : clock.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Clock generator for the v65C02 8-bit Computer.
*******************************************************************************/


module Clock
    (
    input  wire clk_100M_i,         // 100 MHz input clock
    
    output wire clk_50M_o,          // 50 MHz CPU clock
    output wire clk_25_175M_o       // 25.175 MHz VGA pixel clock
    );
    
    
/* INPUT BUFFER ***************************************************************/
    
    wire clk_100M_buf;
    
    IBUF clk_100M_ibuf
        (
        .I(clk_100M_i),
        .O(clk_100M_buf)
        );
    
    
/* MMCM ***********************************************************************/
    
    wire clkfbout;
    wire clk_50M;
    wire clk_25_175M;
    
    MMCME2_BASE
        #(
        .BANDWIDTH         ("OPTIMIZED"),
        .CLKFBOUT_MULT_F   (8.000),
        .CLKFBOUT_PHASE    (0.000),
        .CLKIN1_PERIOD     (10.000),
        .CLKOUT0_DIVIDE_F  (31.750),
        .CLKOUT0_DUTY_CYCLE(0.500),
        .CLKOUT0_PHASE     (0.000),
        .CLKOUT1_DIVIDE    (16),
        .CLKOUT1_DUTY_CYCLE(0.500),
        .CLKOUT1_PHASE     (0.000),
        .CLKOUT4_CASCADE   ("FALSE"),
        .DIVCLK_DIVIDE     (1),
        .REF_JITTER1       (0.0),
        .STARTUP_WAIT      ("FALSE")

        )
        mmcme2_base
        (
        .CLKIN1   (clk_100M_buf),
        .RST      (1'b0),
        .PWRDWN   (1'b0),
        .CLKOUT0  (clk_25_175M),
        .CLKOUT0B (),
        .CLKOUT1  (clk_50M),
        .CLKOUT1B (),
        .CLKOUT2  (),
        .CLKOUT2B (),
        .CLKOUT3  (),
        .CLKOUT3B (),
        .CLKOUT4  (),
        .CLKOUT5  (),
        .CLKOUT6  (),
        .CLKFBOUT (clkfbout),
        .CLKFBOUTB(),
        .CLKFBIN  (clkfbout),
        .LOCKED   ()
        );
    
    
/* OUTPUT BUFFERS *************************************************************/
    
    BUFG clk_50M_bufg
        (
        .I(clk_50M),
        .O(clk_50M_o)
        );
    
    BUFG clk_25_175M_bufg
        (
        .I(clk_25_175M),
        .O(clk_25_175M_o)
        );
    
endmodule
