`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright (C) 2018 Ryan Clarke
*******************************************************************************/

/*******************************************************************************
Module Name : PS2_TX_tb
File Name   : ps2_tx_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module PS2_TX associated with the v65C02 8-bit
          Computer.
*******************************************************************************/

module PS2_TX_tb;


/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       we_i;
    reg [7:0] din_i;
    reg       ps2_clk_re_stb_i;
    reg       ps2_clk_fe_stb_i;
    reg       ps2_din_i;
    
    
/* OUTPUTS ********************************************************************/
    
    wire ps2_dout_o; 
    wire tx_busy_o;
    wire tx_err_o;
    
    
/* PS/2 DEVICE SIGNALS ********************************************************/
    
    reg ps2_clk;
    reg ps2_clk_prev;
    
    
/* MODULES ********************************************************************/
    
    // unit under test
    PS2_TX PS2_TX_uut
        (
        .clk_i           (clk_i),
        .we_i            (we_i),
        .din_i           (din_i),
        .ps2_clk_re_stb_i(ps2_clk_re_stb_i),
        .ps2_clk_fe_stb_i(ps2_clk_fe_stb_i),
        .ps2_din_i       (ps2_din_i),
        .ps2_dout_o      (ps2_dout_o),
        .tx_busy_o       (tx_busy_o),
        .tx_err_o        (tx_err_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    // clock period (ns)
    localparam T_clk = 20;
    
    // 50 MHz system clock
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
        
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN SIMULATION ************************************************************/
    
    // scan codes
    localparam KEY_U = 8'h3C;
    localparam KEY_Q = 8'h15;
    
    initial begin
        we_i      = 1'b0;
        din_i     = 8'h00;
        ps2_din_i = 1'b1;
        @(posedge clk_i);
        
        // simulate RTS
        ps2_clk = 1'b0;
        #100000;
        
        // send U to PS/2 TX
        #1;
        we_i  = 1'b1;
        din_i = KEY_U;
        @(posedge clk_i);
        
        // clear lines
        #1;
        we_i  = 1'b0;
        din_i = 8'h00;
        @(posedge clk_i);
        
        // simulate PS/2 device
        ps2_host2dev();
        @(posedge clk_i);
        
        // simulate RTS
        ps2_clk = 1'b0;
        #100000;
        
        // send Q to PS/2 TX
        #1;
        we_i  = 1'b1;
        din_i = KEY_Q;
        @(posedge clk_i);
        
        // clear lines
        #1;
        we_i  = 1'b0;
        din_i = 8'h00;
        @(posedge clk_i);
        
        // simulate PS/2 device
        ps2_host2dev();
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
    
/* PS/2 CLOCK EDGE DETECTORS **************************************************/
    
    initial ps2_clk = 1'b1;
    
    initial ps2_clk_prev = 1'b1;
    always @(posedge clk_i)
        ps2_clk_prev <= #1 ps2_clk;
    
    // rising edge detector
    initial ps2_clk_re_stb_i = 1'b0;
    always @(posedge clk_i)
        ps2_clk_re_stb_i <= #1 (~ps2_clk_prev) & ps2_clk;
    
    // falling edge detector
    initial ps2_clk_fe_stb_i = 1'b0;
    always @(posedge clk_i)
        ps2_clk_fe_stb_i <= #1 ps2_clk_prev & (~ps2_clk);
    
    
/* PS/2 KEYBOARD SIMULATOR ****************************************************/
    
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
                    // captures data on rising edge
                    #50000;
                    ps2_clk = 1'b1;
                    data    = {ps2_dout_o, data[10:1]};
                    
                    // 50 us half-period
                    #50000;
                    ps2_clk = 1'b0;
                end
            
            // capture stop bit
            #50000;
            ps2_clk   = 1'b1;
            data      = {ps2_dout_o, data[10:1]};
            parity    = ~(^ data[8:1]);
            
            // compute ACK or NACK and send
            #25000;
            ps2_din_i = ~(parity == data[9]);
            
            if(ps2_din_i)
                $display("NACK");
            else
                $display("ACK");
            
            // back on cycle
            #25000;
            ps2_clk = 1'b0;
            
            // clear clock and data lines to high
            #50000;
            ps2_clk   = 1'b1;
            ps2_din_i = 1'b1;
            
            // last clock half-period
            #50000;
            
            $display("Host sent: %h", data[8:1]);
        end    
    endtask
    
endmodule
