`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Furusawa_lab
// Engineer: Ruofan He
// 
// Create Date: 2021/10/20 17:12:47
// Design Name: 
// Module Name: PNR_signal_selector
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


module PNR_signal_selector(
    input trig_is_adc_a,
    input [14-1:0] ADC_A,
    input [14-1:0] ADC_B,
    output [14-1:0] trig_source_sig,
    output [14-1:0] pnr_source_sig
    );
    
assign trig_source_sig = trig_is_adc_a ? ADC_A : ADC_B;
assign pnr_source_sig  = trig_is_adc_a ? ADC_B : ADC_A;

endmodule
