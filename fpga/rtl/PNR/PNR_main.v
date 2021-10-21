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
    input ADC_CLK,
    input [13:0] ADC_A,
    input [13:0] ADC_B,
    output [8-1:0] extension_GPIO_p,
    output [8-1:0] extension_GPIO_n
    );
    
    assign extension_GPIO_p = 8'b0;
    assign extension_GPIO_n = 8'b0;
endmodule
