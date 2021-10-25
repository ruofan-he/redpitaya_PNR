`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/20 17:12:47
// Design Name: 
// Module Name: PNR_main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PNR_main(
    // signal
    input ADC_CLK,
    input [14-1:0] trig_source_sig,
    input [14-1:0] pnr_source_sig,
    // config
    input [14-1:0] trig_threshold, // threshold of trigger
    input [32-1:0] trig_clearance   , // clearance to next trigger(unit is a clock duration)
    input [32-1:0] pnr_delay        , // trigger pnr delay(unit is a clock duration)
    // output
    output [8-1:0] extension_GPIO_p,
    output [8-1:0] extension_GPIO_n
    );
    
    assign extension_GPIO_p = 8'b0;
    assign extension_GPIO_n = 8'b0;
endmodule
