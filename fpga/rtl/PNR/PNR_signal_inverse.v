`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Furusawa_lab
// Engineer: Ruofan He
// 
// Create Date: 2021/11/15 17:12:47
// Design Name: 
// Module Name: PNR_signal_inverse
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


module PNR_signal_inverse(
    input  is_inverse,
    input  [14-1:0] input_sig,
    output [14-1:0] output_sig
    );

assign output_sig = is_inverse ? ~input_sig + 1 : input_sig;

endmodule
