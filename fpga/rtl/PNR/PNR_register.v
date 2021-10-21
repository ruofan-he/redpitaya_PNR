`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/21 18:03:08
// Design Name: 
// Module Name: PNR_register
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
   output wire            sys_ack            //!< bus acknowledge signal
    );

reg [32-1:0] _sys_rdata;
reg          _sys_err;
reg          _sys_ack;

assign sys_rdata = _sys_rdata;
assign sys_err   = _sys_err;
assign sys_ack   = _sys_ack;



reg [14-1:0] some_reg;



assign led_o = some_reg[8-1:0];

//---------------------------------------------------------------------------------
//
//  System bus connection

always @(posedge clk_i) begin
   if (rstn_i == 1'b0) begin
      some_reg    <= 14'h0 ;

   end
   else begin
      if (sys_wen) begin
         if (sys_addr[19:0]==20'h0)    some_reg  <= sys_wdata[14-1:0] ;
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

   casez (sys_addr[19:0])
      20'h0   : begin _sys_ack <= sys_en;         _sys_rdata <= {{32-14{1'b0}}, some_reg}           ; end 
     default : begin _sys_ack <= sys_en;          _sys_rdata <=  32'h0                              ; end
   endcase
end

endmodule
