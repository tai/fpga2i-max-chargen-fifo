//
// LED blink example to test FPGA2I board
//
// Expected behavior:
// - LED[i] will toggle every second
// - LED[i] will blink when DIP[i] is OFF
//

`define CYCLE_1SEC 50_000_000 // 50MHz

module top
  (
   input wire 	     clk,
   input wire 	     res_n,
   input wire [2:0]  dip,
   output wire [2:0] led
   );

   reg [32:0] 	     counter;
   reg [2:0] 	     led_output;

   initial begin
      counter = 0;
   end

   always @(posedge clk, negedge res_n) begin
      // reset
      if (~res_n) begin
	 led_output <= ~0;
	 counter <= 0;
      end

      // clocked operation
      else begin
	 counter <= counter + 1;

	 // flip led output every cycle
	 if (counter == `CYCLE_1SEC) begin
	    counter <= 0;
	    led_output <= ~led_output;
	 end
      end
   end

   // LED[i]:ON when DIP[i]:ON
   // - led[i] lights when led[i] is 0
   // - led[i] is 1 when dip[i] is 0 (DIP[i]:OFF)
   // -- So DIP works as a mask to turn LED OFF
   // -- Negated logic is to turn LED ON when DIP is OFF
   assign led = led_output | ~dip;

   // LED[i]:ON when DIP[i]:ON
   //assign led = dip;
   
endmodule
