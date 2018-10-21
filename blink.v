// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module blink
  #(
    parameter CDIV=50_000_000
    )
   (
    input wire 	      clk,
    input wire 	      n_rst,
    output wire [2:0] led
    );

   reg [32:0] 	      counter;
   reg [2:0] 	      led_out;

   assign led = led_out;

   always @(posedge clk, negedge n_rst) begin
      if (~n_rst) begin
	 counter <= 0;
	 led_out <= '1;
      end else begin
	 counter <= counter + 1;

	 // flip led output every cycle
	 if (counter == CDIV) begin
	    counter <= 1;
	    led_out <= ~led_out;
	 end
      end
   end
endmodule
