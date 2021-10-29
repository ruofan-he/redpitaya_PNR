`timescale 1ns / 1ps

module PNR_delayed_trigger_tb #(
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


parameter real f = 1E6;
parameter real TWO_PI = 3.1415 * 2;
logic [32-1:0] counter = 0;
logic [14-1:0] sin_value;
always @(posedge clk) begin
    counter <= counter + 1;
    sin_value <= $rtoi( 2000 * $sin(TWO_PI * f * counter * 8E-9) ) + 4000;
end

wire trigger;
wire delayed_trigger;

PNR_delayed_trigger i_delayed_trigger(
    .ADC_CLK(clk),
    .rstn_i(rstn),
    .trig_source_sig(sin_value),
    .trig_threshold(4000),
    .trig_hysteresis(20),
    .trig_clearance(500),
    .trig_is_posedge(1'b1),
    .pnr_delay(400),
    .trigger(trigger),
    .delayed_trigger(delayed_trigger)
);


endmodule
