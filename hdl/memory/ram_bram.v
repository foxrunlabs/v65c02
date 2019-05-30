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
Module Name : RAM_BRAM
File Name   : ram_bram.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : BRAM based single-port synchronous RAM for the v65C02 8-bit Computer.
*******************************************************************************/


module RAM_BRAM
    #(
    parameter WIDTH = 8,
              DEPTH = 4096
    )
    (
    input wire                       i_clk,     // system clock
    
    input wire                       i_en,      // enable
    input wire                       i_we,      // write enable
    
    input wire [clogb2(DEPTH) - 1:0] i_addr,    // log2(DEPTH)-bit address
    input wire [(WIDTH - 1):0]       i_data,    // WIDTH-bit data input
    output reg [(WIDTH - 1):0]       o_data     // WIDTH-bit data outut
    );
    
    
/* RAM ************************************************************************/
    
    // block RAM
    (* ram_style = "block" *) reg [(WIDTH - 1):0] ram_reg [0:(DEPTH - 1)];    
    
    // zero out the data
    generate
        integer i;
        
        initial for(i = 0; i < DEPTH; i = i + 1)
            ram_reg[i] = {WIDTH{1'b0}};
    endgenerate
    
    // output register (no change)
    initial o_data = 8'h00;
    always @(posedge i_clk)
        if(i_en) begin
            if(i_we)
                ram_reg[i_addr] <= #1 i_data;
            else
                o_data <= #1 ram_reg[i_addr];
        end
    
    
/* LOG-BASE-2 *****************************************************************/
    
    function integer clogb2;
        input integer depth;
        begin
            depth = depth - 1;
            
            for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
                depth = depth >> 1;
        end
    endfunction
    
endmodule
