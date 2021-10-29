`timescale 1ns / 1ps

module PNR_main_tb #(
  realtime  TP = 8.0ns  // 125MHz
)();

logic              clk ;
logic              rstn;

// ADC clock
initial        clk = 1'b0;
always #(TP/2) clk = ~clk;

// ADC reset
initial begin
  rstn = 1'b0;
  repeat(4) @(posedge clk);
  rstn = 1'b1;
  repeat(1000) @(posedge clk);
  $finish;
end

reg sim_trig;
reg sim_d_trig;


parameter real f = 3E6;
parameter real TWO_PI = 3.1415 * 2;
logic [8-1:0] counter = 0;
logic [32-1:0] sin_counter = 0;
logic [14-1:0] sin_value;
always @(posedge clk) begin
    counter <= counter + 1;
    sin_counter <= sin_counter + 1;
    sin_value <= $rtoi( 4000 * $sin(TWO_PI * f * sin_counter * 8E-9) ) + 4000;
    casez (counter+1)
      50      : sim_trig <= 1;
      100      : sim_d_trig <= 1;
      default : begin sim_trig <= 0; sim_d_trig <= 0 ; end
   endcase
end


PNR_main i_main(
    .ADC_CLK(clk),
    .rstn_i(rstn),
    .trigger(sim_trig),
    .delayed_trigger(sim_d_trig),
    .pnr_source_sig(sin_value),
    .adc_photon_threshold_1(1000-500),
    .adc_photon_threshold_2(2000-500),
    .adc_photon_threshold_3(3000-500),
    .adc_photon_threshold_4(4000-500),
    .adc_photon_threshold_5(5000-500),
    .adc_photon_threshold_6(6000-500),
    .adc_photon_threshold_7(7000-500),
    .adc_photon_threshold_8(8000-500)
);



endmodule
