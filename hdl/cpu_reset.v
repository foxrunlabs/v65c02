`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright (C) 2018 Ryan Clarke
*******************************************************************************/

/*******************************************************************************
Module Name : CPUReset
Top Module  : v65C02_Top
File Name   : cpu_reset.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Reset circuit for the v65C02 8-bit Computer.
          
          Generates an active-high reset signal, triggered on startup or by the
          rising-edge sensitive trigger input. The reset signal lasts four clock
          cycles to meet the minimum 2 clock cycle specification of the 65C02.
*******************************************************************************/


module CPUReset
    (
    input  wire clk_i,              // system clock
    
    input  wire rst_i,              // reset input
    output wire rst_o               // reset ouput
    );
    
    
/* SYNCHRONIZER ***************************************************************/
    
    reg  rst_async_ff;                  // reset synchronizer
    reg  rst_sync_ff;
    
    initial rst_async_ff = 1'b0;
    initial rst_sync_ff  = 1'b0;
    always @(posedge clk_i) begin
        rst_async_ff <= #1 rst_i;
        rst_sync_ff  <= #1 rst_async_ff;
    end
    
    
/* DEBOUNCE *******************************************************************/
    
    wire rst_db;                        // debounce reset button
    
    Debounce Debounce
        (
        .clk_i(clk_i),
        .in_i (rst_sync_ff),
        .out_o(rst_db)
        );
    
    
/* RISING EDGE DETECTOR *******************************************************/
    
    reg        rst_prev_ff;         // previous reset input
    wire       rst_re;              // reset rising-edge
    
    initial rst_prev_ff = 1'b0;
    always @(posedge clk_i)
        rst_prev_ff <= #1 rst_db;
    
    assign rst_re = ~rst_prev_ff & rst_db;
    
    
/* RESET SIGNAL ***************************************************************/
    
    reg  [2:0] count_reg;           // clock cycle counter
    
    initial count_reg = 3'd0;
    always @(posedge clk_i)
        if(rst_re)
            count_reg <= #1 3'd0;
        else if(~count_reg[2])
            count_reg <= #1 count_reg + 3'd1;
    
    assign rst_o = ~count_reg[2];
    
endmodule
