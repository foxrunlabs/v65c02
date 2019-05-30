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
Module Name : v65C02_Top
File Name   : v65C02_top.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Top module for the v65C02 8-bit Computer.
*******************************************************************************/


module v65C02_Top
    (
    input  wire       CLK100MHZ,        // 100 MHz Nexys 4 DDR clock
    input  wire       CPU_RESETN,       // active-low asynchronous reset
    
    // VGA
    output wire [3:0] VGA_R,            // red
    output wire [3:0] VGA_G,            // green
    output wire [3:0] VGA_B,            // blue
    output wire       VGA_HS,           // horizontal sync
    output wire       VGA_VS,           // vertical sync
    
    // seven-segment display
    output wire [7:0] AN,
    output wire       CA,
    output wire       CB,
    output wire       CC,
    output wire       CD,
    output wire       CE,
    output wire       CF,
    output wire       CG,
    output wire       DP,
    
    // UART
    input  wire       UART_TXD_IN,      // input from serial port
    output wire       UART_RXD_OUT,     // output to serial port
    
    // PS/2 keyboard
    inout wire        PS2_CLK,          // PS/2 clock
    inout wire        PS2_DATA          // PS/2 serial data
    );
    
    
/* CLOCK GENERATOR ************************************************************/
    
    wire clk_cpu;                       // 50 MHz CPU clock
    wire clk_pixel;                     // 25.175 MHz VGA pixel clock
    
    ClockGen ClockGen
        (
        .i_clk_nexys(CLK100MHZ),
        .o_clk_cpu  (clk_cpu),
        .o_clk_vga  (clk_pixel)
        );
    
    
/* RESET CIRCUIT **************************************************************/
    
    wire reset;                         // reset signal
    
    Reset Reset
        (
        .i_clk(clk_cpu),
        .i_rst(~CPU_RESETN),
        .o_rst(reset)
        );
    
    
/* 65C02 CPU ******************************************************************/
    
    wire [15:0] cpu_addr;               // v65C02 16-bit address bus
    reg  [7:0]  cpu_din;                // v65C02 8-bit data input
    wire [7:0]  cpu_dout;               // v65C02 8-bit data output
    wire        cpu_we;                 // v65C02 write enable
    
    v65C02 CPU
        (
        .i_clk( clk_cpu),
        .i_rst (reset),
        .i_irq (1'b0),
        .i_nmi (1'b0),
        .i_rdy (1'b1),
        .o_addr(cpu_addr),
        .o_we  (cpu_we),
        .o_data(cpu_dout),
        .i_data(cpu_din)
        );
    
    
/* ROM BIOS *******************************************************************/
        
    wire       bios_en;                     // BIOS select
    wire [7:0] bios_dout;                   // BIOS 8-bit data out
    
    assign bios_en = (& cpu_addr[15:14]);   // BIOS = $C000 -> $FFFF
    
    // 16K x 8-bit ROM
    ROM_BRAM
        #(
        .WIDTH    (8),
        .DEPTH    (16384),
        .INIT_FILE("bios.hex")
        )
        BIOS
        (
        .i_clk (clk_cpu),
        .i_en  (bios_en),
        .i_addr(cpu_addr[13:0]),
        .o_data(bios_dout)
        );
    
    
/* RAM ************************************************************************/
    
    wire       ram_en;                          // RAM select
    wire [7:0] ram_dout;                        // RAM 8-bit data out
    
    assign ram_en = (cpu_addr[15:8] < 8'hAF);   // RAM = $0000 -> $AEFF
    
    // 44K x 8-bit RAM
    RAM_BRAM
        #(
        .WIDTH(8),
        .DEPTH(45056)
        )
        RAM
        (
        .i_clk (clk_cpu),
        .i_en  (ram_en),
        .i_we  (cpu_we),
        .i_addr(cpu_addr),
        .i_data(cpu_dout),
        .o_data(ram_dout)
        );
    
    
/* IO PORTS *******************************************************************/
    
    localparam P_VGA  = 4'h0,
               P_SSEG = 4'h1,
               P_UART = 4'h2,
               P_KBD  = 4'h3,
               P_TMR  = 4'h4;
    
    wire       io_en;
    wire [3:0] port;
    wire       vga_reg_en;
    wire       sseg_en;
    wire       uart_en;
    wire       kbd_en;
    wire       tmr_en; 
    
    // IO ports = $AF00 -> $AFFF
    assign io_en = (cpu_addr[15:8] == 8'hAF);
    
    // 16 IO ports from $AF00 to $AFF0 (16 registers per port)
    assign port = cpu_addr[7:4];
    
    // port enables
    assign vga_reg_en = io_en & (port == P_VGA);
    assign sseg_en    = io_en & (port == P_SSEG);
    assign uart_en    = io_en & (port == P_UART);
    assign kbd_en     = io_en & (port == P_KBD);
    assign tmr_en     = io_en & (port == P_TMR);
    
    
/* VGA CONTROLLER *************************************************************/
    
    wire        vga_vram_en;                // video RAM select
    wire [11:0] vga_vram_addr;              // 12-bit video RAM address
    wire [7:0]  vga_vram_dout;              // 8-bit video RAM output
    wire [7:0]  vga_reg_dout;               // 8-bit register output
    wire [11:0] vga_rgb;                    // 12-bit RGB444 output
    wire        vga_hsync;                  // horizontal sync
    wire        vga_vsync;                  // vertical sync
    
    // VRAM = $B000 -> $BFFF
    assign vga_vram_en = (cpu_addr[15:12] == 4'hB);
    
    VGAController VGAController
        (
        .i_clk_cpu  (clk_cpu),
        .i_clk_pixel(clk_pixel),
        .i_vram_en  (vga_vram_en),
        .i_vram_we  (cpu_we),
        .i_vram_addr(cpu_addr[11:0]),
        .i_vram_din (cpu_dout),
        .o_vram_dout(vga_vram_dout),
        .i_reg_en   (vga_reg_en),
        .i_reg_we   (cpu_we),
        .i_reg_sel  (cpu_addr[1:0]),
        .i_reg_din  (cpu_dout),
        .o_reg_dout (vga_reg_dout),
        .o_rgb      (vga_rgb),
        .o_hsync    (vga_hsync),
        .o_vsync    (vga_vsync)
        );
    
    // output logic
    assign {VGA_R, VGA_G, VGA_B} = vga_rgb;
    assign VGA_HS = vga_hsync;
    assign VGA_VS = vga_vsync;
    
    
/* SEVEN-SEGMENT CONTROLLER ***************************************************/
    
    wire [7:0] sseg_an_n;                   // anode (active low)
    wire [7:0] sseg_sseg_n;                 // seven-segment digit (active low)
    
    SevenSegmentController SevenSegmentController
        (
        .i_clk    (clk_cpu),
        .i_en     (sseg_en),
        .i_we     (cpu_we),
        .i_reg_sel(cpu_addr[2:0]),
        .i_data   (cpu_dout),
        .o_an_n   (sseg_an_n),
        .o_sseg_n (sseg_sseg_n)
        );
    
    // output logic
    assign AN = sseg_an_n;
    assign {DP, CG, CF, CE, CD, CC, CB, CA} = sseg_sseg_n;
    
    
/* UART ***********************************************************************/
    
    wire [7:0] uart_dout;                   // 8-bit data output
    wire       uart_tx;                     // serial data output
    
    UARTController UARTController
        (
        .i_clk    (clk_cpu),
        .i_en     (uart_en),
        .i_we     (cpu_we),
        .i_reg_sel(cpu_addr[2:0]),
        .i_data   (cpu_dout),
        .o_data   (uart_dout),
        .i_rx     (UART_TXD_IN),
        .o_tx     (uart_tx)
        );
    
    // output logic
    assign UART_RXD_OUT = uart_tx;
    
    
/* PS/2 KEYBOARD **************************************************************/
    
    wire [7:0] kbd_dout;                    // 8-bit data output
    
    KeyboardController KeyboardController
        (
        .i_clk      (clk_cpu),
        .i_en       (kbd_en),
        .i_reg_sel  (cpu_addr[0]),
        .o_data     (kbd_dout),
        .io_ps2_clk (PS2_CLK),
        .io_ps2_data(PS2_DATA)
        );
    
    
/* 32-BIT TIMER ***************************************************************/
    
    wire [7:0] tmr_dout;                    // 8-bit data output
    
    TimerController TimerController
        (
        .i_clk    (clk_cpu),
        .i_en     (tmr_en),
        .i_we     (cpu_we),
        .i_reg_sel(cpu_addr[2:0]),
        .i_data   (cpu_dout),
        .o_data   (tmr_dout)
        );
    
    
/* CPU INPUT DECODING LOGIC ***************************************************/
    
    localparam BIOS_EN = 8'b0000_0001,
               RAM_EN  = 8'b0000_0010,
               VRAM_EN = 8'b0000_0100,
               VGA_EN  = 8'b0000_1000,
               SSEG_EN = 8'b0001_0000,
               UART_EN = 8'b0010_0000,
               PS2_EN  = 8'b0100_0000,
               TMR_EN  = 8'b1000_0000;
               
    reg [7:0] en_p1_reg;                    // chip enable pipeline
    
    // v65C02 expects valid data after one-clock cycle
    initial en_p1_reg = 8'h00;
    always @(posedge clk_cpu)
        en_p1_reg <= #1 {tmr_en, kbd_en, uart_en, sseg_en,
                         vga_reg_en, vga_vram_en, ram_en, bios_en};
    
    // v65C02 data input multiplexer
    always @*
        case(en_p1_reg)
            BIOS_EN: cpu_din = bios_dout;
            RAM_EN:  cpu_din = ram_dout;
            VRAM_EN: cpu_din = vga_vram_dout;
            VGA_EN:  cpu_din = vga_reg_dout;
            UART_EN: cpu_din = uart_dout;
            PS2_EN:  cpu_din = kbd_dout;
            TMR_EN:  cpu_din = tmr_dout;
            default: cpu_din = 8'h00;
        endcase
    
endmodule
