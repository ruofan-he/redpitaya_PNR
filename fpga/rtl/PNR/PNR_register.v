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
   output wire [8-1:0]    led_o           ,
   // system bus
   input  wire [ 32-1: 0] sys_addr        ,  //!< bus address
   input  wire [ 32-1: 0] sys_wdata       ,  //!< bus write data
   input  wire            sys_wen         ,  //!< bus write enable
   input  wire            sys_ren         ,  //!< bus read enable
   output wire [ 32-1: 0] sys_rdata       ,  //!< bus read data
   output wire            sys_err         ,  //!< bus error indicator
   output wire            sys_ack         ,  //!< bus acknowledge signal
   //ADC_threshold for photon number resolving
   output wire [ 14-1: 0] adc_photon_threshold_1,
   output wire [ 14-1: 0] adc_photon_threshold_2,
   output wire [ 14-1: 0] adc_photon_threshold_3,
   output wire [ 14-1: 0] adc_photon_threshold_4,
   output wire [ 14-1: 0] adc_photon_threshold_5,
   output wire [ 14-1: 0] adc_photon_threshold_6,
   output wire [ 14-1: 0] adc_photon_threshold_7
    );

reg [32-1:0] _sys_rdata;
reg          _sys_err;
reg          _sys_ack;

assign sys_rdata = _sys_rdata;
assign sys_err   = _sys_err;
assign sys_ack   = _sys_ack;




reg [8-1:0] led_reg;
reg [14-1:0] adc_photon_threshold_1_reg;
reg [14-1:0] adc_photon_threshold_2_reg;
reg [14-1:0] adc_photon_threshold_3_reg;
reg [14-1:0] adc_photon_threshold_4_reg;
reg [14-1:0] adc_photon_threshold_5_reg;
reg [14-1:0] adc_photon_threshold_6_reg;
reg [14-1:0] adc_photon_threshold_7_reg;

assign adc_photon_threshold_1 = adc_photon_threshold_1_reg;
assign adc_photon_threshold_2 = adc_photon_threshold_2_reg;
assign adc_photon_threshold_3 = adc_photon_threshold_3_reg;
assign adc_photon_threshold_4 = adc_photon_threshold_4_reg;
assign adc_photon_threshold_5 = adc_photon_threshold_5_reg;
assign adc_photon_threshold_6 = adc_photon_threshold_6_reg;
assign adc_photon_threshold_7 = adc_photon_threshold_7_reg;



assign led_o = led_reg[8-1:0];

//---------------------------------------------------------------------------------
//
//  System bus connection

always @(posedge clk_i) begin
   if (rstn_i == 1'b0) begin
      led_reg    <= 8'h0 ;
      adc_photon_threshold_1_reg  <= 14'b0;
      adc_photon_threshold_2_reg  <= 14'b0;
      adc_photon_threshold_3_reg  <= 14'b0;
      adc_photon_threshold_4_reg  <= 14'b0;
      adc_photon_threshold_5_reg  <= 14'b0;
      adc_photon_threshold_6_reg  <= 14'b0;
      adc_photon_threshold_7_reg  <= 14'b0;

   end
   else begin
      if (sys_wen) begin
         if (sys_addr[20-1:0]==20'h0)    led_reg  <= sys_wdata[8-1:0] ;
         if (sys_addr[20-1:0]==20'h1)    adc_photon_threshold_1_reg  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h2)    adc_photon_threshold_2_reg  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h3)    adc_photon_threshold_3_reg  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h4)    adc_photon_threshold_4_reg  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h5)    adc_photon_threshold_5_reg  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h6)    adc_photon_threshold_6_reg  <= sys_wdata[14-1:0] ;
         if (sys_addr[20-1:0]==20'h7)    adc_photon_threshold_7_reg  <= sys_wdata[14-1:0] ;
      end
   end
end

wire sys_en;
assign sys_en = sys_wen | sys_ren;

always @(posedge clk_i)
if (rstn_i == 1'b0) begin
   _sys_err <= 1'b0 ;
   _sys_ack <= 1'b0 ;
end else begin
   _sys_err <= 1'b0 ;

   casez (sys_addr[20-1:0])
      20'h0   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-8{1'b0}}, led_reg}              ; end
      20'h1   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_1_reg}              ; end
      20'h2   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_2_reg}              ; end
      20'h3   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_3_reg}              ; end
      20'h4   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_4_reg}              ; end
      20'h5   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_5_reg}              ; end
      20'h6   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_6_reg}              ; end
      20'h7   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-14{1'b0}}, adc_photon_threshold_7_reg}              ; end
      default : begin _sys_ack <= sys_en;          _sys_rdata <=  32'h0                              ; end
   endcase
end

endmodule

