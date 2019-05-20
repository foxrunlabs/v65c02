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
Module Name : VRAM_BRAM
File Name   : vram_bram.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : BRAM based dual-port synchronous RAM with a read/write (no change)
          port A and a read-only port B.
          
          All outputs are registered and incur a one clock cycle delay.
*******************************************************************************/


module VRAM_BRAM
    #(
    parameter WIDTH = 8,
              DEPTH = 4096
    )
    (
    // port A
    input wire                       clka_i,    // clock
    input wire                       ena_i,     // RAM enable
    input wire                       wea_i,     // write enable
    input wire [clogb2(DEPTH) - 1:0] addra_i,   // address
    input wire [(WIDTH - 1):0]       dia_i,     // data input
    output reg [(WIDTH - 1):0]       doa_o,     // data output
    
    // port B
    input wire                       clkb_i,    // clock
    input wire                       enb_i,     // RAM enable
    input wire [clogb2(DEPTH) - 1:0] addrb_i,   // address
    output reg [(WIDTH - 1):0]       dob_o      // data output
    );
    
    
/* RAM ************************************************************************/
    
    // 8K x 8-bit block RAM
    (*ram_style = "block" *) reg [(WIDTH - 1):0] ram_reg [0:(DEPTH - 1)];   
    
    // zero out the data
    generate
        integer i;
        
        initial for(i = 0; i < DEPTH; i = i + 1)
            ram_reg[i] = {WIDTH{1'b0}};
    endgenerate
    
    // port A output register
    initial doa_o = 8'h00;
    always @(posedge clka_i)
        if(ena_i) begin
            if(wea_i)
                ram_reg[addra_i] <= #1 dia_i;
            else
                doa_o <= #1 ram_reg[addra_i];
        end
    
    // port B output register
    initial dob_o = 8'h00;
    always @(posedge clkb_i)
        if(enb_i)
            dob_o <= #1 ram_reg[addrb_i];
    
    
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
