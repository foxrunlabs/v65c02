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
Module Name : ClockGen
File Name   : clock_gen.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Clock generator for the v65C02 8-bit Computer.
          
          Generates a 50 MHz CPU clock and a 25.175 MHz VGA clock from the
          100 MHz Nexys 4 DDR clock.
*******************************************************************************/


module ClockGen
    (
    input  wire i_clk_nexys,        // 100 MHz input clock
    
    output wire o_clk_cpu,          // 50 MHz
    output wire o_clk_vga           // 25.175 MHz
    );
    
    
/* INPUT BUFFER ***************************************************************/
    
    wire clk_nexys_buf;
    
    IBUF NexysClockIBUF
        (
        .I(i_clk_nexys),
        .O(clk_nexys_buf)
        );
    
    
/* MMCM ***********************************************************************/
    
    wire clkfbout;
    wire clk_cpu;
    wire clk_vga;
    
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
        MMCME2Base
        (
        .CLKIN1   (clk_nexys_buf),
        .RST      (1'b0),
        .PWRDWN   (1'b0),
        .CLKOUT0  (clk_vga),
        .CLKOUT0B (),
        .CLKOUT1  (clk_cpu),
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
    
    BUFG CPUClockBUFG
        (
        .I(clk_cpu),
        .O(o_clk_cpu)
        );
    
    BUFG VGAClockBUFG
        (
        .I(clk_vga),
        .O(o_clk_vga)
        );
    
endmodule
