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
   //led test
   output reg [8-1:0]    led_o           ,
   // system bus
   input  wire [ 32-1: 0] sys_addr        ,  //!< bus address
   input  wire [ 32-1: 0] sys_wdata       ,  //!< bus write data
   input  wire            sys_wen         ,  //!< bus write enable
   input  wire            sys_ren         ,  //!< bus read enable
   output reg [ 32-1: 0] sys_rdata       ,  //!< bus read data
   output reg            sys_err         ,  //!< bus error indicator
   output reg            sys_ack         ,  //!< bus acknowledge signal
   //ADC_threshold for photon number resolving
   output reg [ 14-1: 0] adc_photon_threshold_1,
   output reg [ 14-1: 0] adc_photon_threshold_2,
   output reg [ 14-1: 0] adc_photon_threshold_3,
   output reg [ 14-1: 0] adc_photon_threshold_4,
   output reg [ 14-1: 0] adc_photon_threshold_5,
   output reg [ 14-1: 0] adc_photon_threshold_6,
   output reg [ 14-1: 0] adc_photon_threshold_7
    );

//---------------------------------------------------------------------------------
//
//  System bus connection

always @(posedge clk_i) begin
   if (rstn_i == 1'b0) begin
      led_o    <= 8'h0 ;
      adc_photon_threshold_1  <= 14'b0;
      adc_photon_threshold_2  <= 14'b0;
      adc_photon_threshold_3  <= 14'b0;
      adc_photon_threshold_4  <= 14'b0;
      adc_photon_threshold_5  <= 14'b0;
      adc_photon_threshold_6  <= 14'b0;
      adc_photon_threshold_7  <= 14'b0;

   end
   else begin
      if (sys_wen) begin
         if (sys_addr[20-1:0]==20'h0)    led_o  <= sys_wdata[8-1:0] ;
         if (sys_addr[20-1:0]==20'h1)    adc_photon_threshold_1  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h2)    adc_photon_threshold_2  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h3)    adc_photon_threshold_3  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h4)    adc_photon_threshold_4  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h5)    adc_photon_threshold_5  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h6)    adc_photon_threshold_6  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h7)    adc_photon_threshold_7  <= sys_wdata[14-1:0] ;
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
      20'h0   : begin sys_ack <= sys_en;         sys_rdata <= {{32-8{1'b0}}, led_o}              ; end
      20'h1   : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_1}              ; end
      20'h2   : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_2}              ; end
      20'h3   : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_3}              ; end
      20'h4   : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_4}              ; end
      20'h5   : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_5}              ; end
      20'h6   : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_6}              ; end
      20'h7   : begin sys_ack <= sys_en;         sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_7}              ; end
      default : begin sys_ack <= sys_en;         sys_rdata <=  32'h0                              ; end
   endcase
end

endmodule

