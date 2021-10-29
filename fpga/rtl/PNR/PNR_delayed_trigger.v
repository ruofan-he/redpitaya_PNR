`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/20 17:12:47
// Design Name: 
// Module Name: PNR_delayed_trigger
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


module PNR_delayed_trigger(
    // signal
    input ADC_CLK,
    input rstn_i,
    input [14-1:0] trig_source_sig,
    // config
    input [14-1:0] trig_threshold   , // threshold of trigger
    input [14-1:0] trig_hysteresis  , // schmitt trigger, hysterisis
    input [32-1:0] trig_clearance   , // clearance to next trigger(unit is a clock duration)
    input          trig_is_posedge  , // trigger with positive edge
    input [32-1:0] pnr_delay        , // trigger pnr delay(unit is a clock duration)
    // output
    output trigger,
    output delayed_trigger
    );

    

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
reg          counter_ratch  ;
reg          is_idle;
wire          delayed_trig  ;

assign trig = trig_is_posedge ? adc_trig_p : adc_trig_n;

always @(posedge ADC_CLK)
if (rstn_i == 1'b0) begin
   counter         <= 0;
   is_idle         <= 1'b1;
   counter_ratch   <= 1'b0;
end else begin
   counter         <= (trig && is_idle) ? 0    : counter + 1;
   is_idle         <= (trig && is_idle) ? 1'b0 : (counter >= trig_clearance) && (counter >= pnr_delay) || is_idle;
   counter_ratch   <= (trig && is_idle) ? 1'b0 : (counter >= pnr_delay);
end

assign delayed_trig = (counter >= pnr_delay) && !counter_ratch && !is_idle;


assign trigger = trig;
assign delayed_trigger = delayed_trig;


endmodule
