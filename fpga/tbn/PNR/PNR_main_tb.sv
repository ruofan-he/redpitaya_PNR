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


endmodule
