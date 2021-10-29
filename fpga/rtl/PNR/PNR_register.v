`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Furusawa lab.
// Engineer: Ruofan He
// 
// Create Date: 2021/10/21 18:03:08
// Design Name: 
// Module Name: PNR_register
// Project Name: redpitaya_PNR
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


module PNR_register(
   // signals
   input  wire            clk_i           ,  //!< processing clock
   input  wire            rstn_i          ,  //!< processing reset - active low
   // system bus
   input  wire [ 32-1: 0] sys_addr        ,  //!< bus address
   input  wire [ 32-1: 0] sys_wdata       ,  //!< bus write data
   input  wire            sys_wen         ,  //!< bus write enable
   input  wire            sys_ren         ,  //!< bus read enable
   output reg [ 32-1: 0]  sys_rdata       ,  //!< bus read data
   output reg             sys_err         ,  //!< bus error indicator
   output reg             sys_ack         ,  //!< bus acknowledge signal
   //led test
   output reg [8-1:0]    led_o            ,
   // auxiliary io
   input wire [32-1:0]   aux_i            ,
   output reg [32-1:0]   aux_o            ,
   // misc. config
   output reg            trig_is_adc_a    ,
   output reg [ 14-1: 0] trig_threshold   ,
   output reg [ 14-1: 0] trig_hysteresis  , // schmitt trigger hysteresis, trig_threshold - trig_hysteresis
   output reg [ 32-1: 0] trig_clearance   , // clearance to next trigger(unit is a clock duration)
   output reg            trig_is_posedge  , // trigger with positive edge
   output reg [ 32-1: 0] pnr_delay        , // trigger pnr delay(unit is a clock duration)
   //ADC_threshold for photon number resolving
   output reg [ 14-1: 0] adc_photon_threshold_1,
   output reg [ 14-1: 0] adc_photon_threshold_2,
   output reg [ 14-1: 0] adc_photon_threshold_3,
   output reg [ 14-1: 0] adc_photon_threshold_4,
   output reg [ 14-1: 0] adc_photon_threshold_5,
   output reg [ 14-1: 0] adc_photon_threshold_6,
   output reg [ 14-1: 0] adc_photon_threshold_7,
   output reg [ 14-1: 0] adc_photon_threshold_8
    );

//---------------------------------------------------------------------------------
//
//  System bus connection

always @(posedge clk_i) begin
   if (rstn_i == 1'b0) begin
      led_o    <= 8'h0 ;
      trig_is_adc_a  <= 1'b1; // default trig source is adc_a
      trig_threshold <= 14'b0; // default trig_threshold is 0V
      trig_hysteresis<= 14'd100; // trig_hysteresis , 100/8192 [V] 
      trig_clearance <= 32'd200; // default clearance to next trigger is 1600ns
      trig_is_posedge<= 1'b1; // default trig with positive edge
      pnr_delay      <= 32'd100; // default delay is 800ns
      //aux_i is read only
      aux_o          <= 32'd0;
      
      adc_photon_threshold_1  <= 14'b0;
      adc_photon_threshold_2  <= 14'b0;
      adc_photon_threshold_3  <= 14'b0;
      adc_photon_threshold_4  <= 14'b0;
      adc_photon_threshold_5  <= 14'b0;
      adc_photon_threshold_6  <= 14'b0;
      adc_photon_threshold_7  <= 14'b0;
      adc_photon_threshold_8  <= 14'b0;

   end
   else begin
      if (sys_wen) begin
         if (sys_addr[20-1:0]==20'h00)    led_o              <= sys_wdata[ 8-1:0] ;
         if (sys_addr[20-1:0]==20'h04)    trig_is_adc_a      <= sys_wdata[     0] ;
         if (sys_addr[20-1:0]==20'h08)    trig_threshold     <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h0C)    trig_hysteresis    <= sys_wdata[14-1:0] ;
         
         if (sys_addr[20-1:0]==20'h10)    trig_clearance     <= sys_wdata[32-1:0] ;
         if (sys_addr[20-1:0]==20'h14)    trig_is_posedge    <= sys_wdata[     0] ;
         if (sys_addr[20-1:0]==20'h18)    pnr_delay          <= sys_wdata[32-1:0] ;
         
         //0x20 is aux_i, read only
         if (sys_addr[20-1:0]==20'h24)    aux_o              <= sys_wdata[32-1:0] ;
         
         if (sys_addr[20-1:0]==20'h40)    adc_photon_threshold_1  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h44)    adc_photon_threshold_2  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h48)    adc_photon_threshold_3  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h4C)    adc_photon_threshold_4  <= sys_wdata[14-1:0] ;
         
         if (sys_addr[20-1:0]==20'h50)    adc_photon_threshold_5  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h54)    adc_photon_threshold_6  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h58)    adc_photon_threshold_7  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h5C)    adc_photon_threshold_8  <= sys_wdata[14-1:0] ;
      end
   end
end

wire sys_en;
assign sys_en = sys_wen | sys_ren;

always @(posedge clk_i)
if (rstn_i == 1'b0) begin
   sys_err <= 1'b0 ;
   sys_ack <= 1'b0 ;
end else begin
   sys_err <= 1'b0 ;

   casez (sys_addr[20-1:0])
      20'h00  : begin sys_ack <= sys_en;         sys_rdata <= {{32- 8{1'b0}}, led_o                 }              ; end
      20'h04  : begin sys_ack <= sys_en;         sys_rdata <= {{32- 1{1'b0}}, trig_is_adc_a         }              ; end
      20'h08  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, trig_threshold        }              ; end
      20'h0C  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, trig_hysteresis       }              ; end
      
      20'h10  : begin sys_ack <= sys_en;         sys_rdata <=  trig_clearance                                      ; end
      20'h14  : begin sys_ack <= sys_en;         sys_rdata <= {{32- 1{1'b0}}, trig_is_posedge       }              ; end
      20'h18  : begin sys_ack <= sys_en;         sys_rdata <=  pnr_delay                                           ; end
      
      20'h20  : begin sys_ack <= sys_en;         sys_rdata <=  aux_i                                               ; end
      20'h24  : begin sys_ack <= sys_en;         sys_rdata <=  aux_o                                               ; end
      
      20'h40  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_1}              ; end
      20'h44  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_2}              ; end
      20'h48  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_3}              ; end
      20'h4C  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_4}              ; end
      
      20'h50  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_5}              ; end
      20'h54  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_6}              ; end
      20'h58  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_7}              ; end
      20'h5C  : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_8}              ; end
      default : begin sys_ack <= sys_en;         sys_rdata <=  32'h0                                               ; end
   endcase
end

endmodule

