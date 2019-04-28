`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright (C) 2018 Ryan Clarke
*******************************************************************************/

/*******************************************************************************
Module Name : RAM_44K8
File Name   : ram_44k8.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : 44K x 8-bit write-first synchronous RAM for the v65C02 8-bit Computer.
*******************************************************************************/


module RAM_44K8
    (
    input wire        clk_i,    // system clock
    
    input wire        en_i,     // RAM enable
    input wire        we_i,     // write enable
    
    input wire [15:0] addr_i,   // 16-bit address
    input wire [7:0]  din_i,    // 8-bit data input
    output reg [7:0]  dout_o    // 8-bit data outut
    );
    
    
/* DECLARATIONS ***************************************************************/
    
    // 44K x 8-bit block RAM
    (* ram_style = "block" *) reg [7:0] ram_reg [0:45055];
    
    
/* RAM REGISTER ***************************************************************/
    
    always @(posedge clk_i)
        if(en_i)
            if(we_i)
                ram_reg[addr_i] <= #1 din_i;
            else
                dout_o <= #1 ram_reg[addr_i];
    
endmodule
