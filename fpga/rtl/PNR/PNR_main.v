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
    input rstn_i,
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
    

//---------------------------------------------------------------------------------
//  Trigger created from input signal

reg  [  2-1: 0] adc_scht_p    ;
reg  [  2-1: 0] adc_scht_n    ;
reg  [ 14-1: 0] set_tresh     ;
reg  [ 14-1: 0] set_treshp    ;
reg  [ 14-1: 0] set_treshm    ;
reg  [ 14-1: 0] set_hyst      ;
reg             adc_trig_p    ;
reg             adc_trig_n    ;

always @(posedge ADC_CLK)
if (rstn_i == 1'b0) begin
   adc_scht_p  <=  2'h0 ;
   adc_scht_n  <=  2'h0 ;
   adc_trig_p  <=  1'b0 ;
   adc_trig_n  <=  1'b0 ;
end else begin
   set_treshp <= set_tresh + set_hyst ; // calculate positive
   set_treshm <= set_tresh - set_hyst ; // and negative treshold

           if ($signed(trig_source_sig) >= $signed(set_tresh ))      adc_scht_p[0] <= 1'b1 ;  // treshold reached
      else if ($signed(trig_source_sig) <  $signed(set_treshm))      adc_scht_p[0] <= 1'b0 ;  // wait until it goes under hysteresis
           if ($signed(trig_source_sig) <= $signed(set_tresh ))      adc_scht_n[0] <= 1'b1 ;  // treshold reached
      else if ($signed(trig_source_sig) >  $signed(set_treshp))      adc_scht_n[0] <= 1'b0 ;  // wait until it goes over hysteresis


   adc_scht_p[1] <= adc_scht_p[0] ;
   adc_scht_n[1] <= adc_scht_n[0] ;

   adc_trig_p <= adc_scht_p[0] && !adc_scht_p[1] ; // make 1 cyc pulse 
   adc_trig_n <= adc_scht_n[0] && !adc_scht_n[1] ;
end
    
    
    
endmodule
