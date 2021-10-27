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
    input [14-1:0] trig_threshold   , // threshold of trigger
    input [14-1:0] trig_hysteresis  , // schmitt trigger, hysterisis
    input [32-1:0] trig_clearance   , // clearance to next trigger(unit is a clock duration)
    input          trig_is_posedge  , // trigger with positive edge
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
wire [ 14-1: 0] set_tresh     ;
reg  [ 14-1: 0] set_treshp    ;
reg  [ 14-1: 0] set_treshm    ;
wire [ 14-1: 0] set_hyst      ;
reg             adc_trig_p    ;
reg             adc_trig_n    ;

assign set_tresh = trig_threshold;
assign set_hyst  = trig_hysteresis;

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



//---------------------------------------------------------------------------------
//  trigger timing control
//  - delay
//  - clearance

wire         trig          ;
reg [32-1:0] counter       ;
reg [2-1: 0] counter_scht  ;
reg          is_idle       ;
reg          delayed_trig  ;

assign trig = trig_is_posedge ? adc_trig_p : adc_trig_n;

always @(posedge ADC_CLK)
if (rstn_i == 1'b0) begin
   counter      <= 0;
   is_idle      <= 1'b1;
   delayed_trig <= 1'b0;
   counter_scht <= 2'b0;
end else begin
   counter <= counter + 1;
   if (counter > trig_clearance) is_idle <= 1'b1;
   if (counter > pnr_delay) counter_scht[0] <= 1'b1;
                       else counter_scht[0] <= 1'b0;
   counter_scht[1] <= counter_scht[0] ;
   delayed_trig <= counter_scht[0] && !counter_scht[1] && !is_idle;
end

always @(posedge trig)
if (is_idle) begin
    counter <= 0;
    is_idle <= 1'b0;
end
    
endmodule
