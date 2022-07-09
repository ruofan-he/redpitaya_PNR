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
    input trigger,
    input delayed_trigger,
    input [14-1:0] pnr_source_sig,
    input [16-1:0] dac_logic_mask,
    //ADC_threshold for photon number resolving
    input [14-1:0] adc_photon_threshold_1,
    input [14-1:0] adc_photon_threshold_2,
    input [14-1:0] adc_photon_threshold_3,
    input [14-1:0] adc_photon_threshold_4,
    input [14-1:0] adc_photon_threshold_5,
    input [14-1:0] adc_photon_threshold_6,
    input [14-1:0] adc_photon_threshold_7,
    input [14-1:0] adc_photon_threshold_8,
    // output
    output [ 8-1:0] extension_GPIO_p,
    output [ 8-1:0] extension_GPIO_n,
    output [14-1:0] dac_masked_GPIO,
    // adc FIFO control
    output [14-1:0] adc_fifo_data,
    output          adc_fifo_wr_en
    );


reg [8-1:0] segment_photon_num;
wire [8-1:0] level_comparation;

assign level_comparation[0] =  $signed(adc_photon_threshold_1) < $signed(pnr_source_sig);
assign level_comparation[1] =  $signed(adc_photon_threshold_2) < $signed(pnr_source_sig);
assign level_comparation[2] =  $signed(adc_photon_threshold_3) < $signed(pnr_source_sig);
assign level_comparation[3] =  $signed(adc_photon_threshold_4) < $signed(pnr_source_sig);
assign level_comparation[4] =  $signed(adc_photon_threshold_5) < $signed(pnr_source_sig);
assign level_comparation[5] =  $signed(adc_photon_threshold_6) < $signed(pnr_source_sig);
assign level_comparation[6] =  $signed(adc_photon_threshold_7) < $signed(pnr_source_sig);
assign level_comparation[7] =  $signed(adc_photon_threshold_8) < $signed(pnr_source_sig);


always @(posedge ADC_CLK)
if ( (rstn_i == 1'b0) || trigger ) begin
    segment_photon_num <= 8'b0;
end else begin
    if (delayed_trigger) begin
        segment_photon_num[0] <=                         ~level_comparation[0]; // phton 0 or less 
        segment_photon_num[1] <= level_comparation[0] && ~level_comparation[1]; // photon 1
        segment_photon_num[2] <= level_comparation[1] && ~level_comparation[2]; 
        segment_photon_num[3] <= level_comparation[2] && ~level_comparation[3];
        segment_photon_num[4] <= level_comparation[3] && ~level_comparation[4];
        segment_photon_num[5] <= level_comparation[4] && ~level_comparation[5];
        segment_photon_num[6] <= level_comparation[5] && ~level_comparation[6]; // photon 6
        segment_photon_num[7] <= level_comparation[6]                         ; // photon 7 or more
    end
end


assign adc_fifo_data  = pnr_source_sig;
assign adc_fifo_wr_en = delayed_trigger;

assign extension_GPIO_p = segment_photon_num;
assign extension_GPIO_n = 8'b0;

assign dac_masked_GPIO = &(dac_logic_mask & { extension_GPIO_n , extension_GPIO_p}) ? 14'b01111111111111 : 14'b0;


endmodule
