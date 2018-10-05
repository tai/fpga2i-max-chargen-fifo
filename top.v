//
// UART chargen example to test FPGA2I board
//
// Expected behavior:
// - PMOD[0] works as UART-RX
// - PMOD[1] works as UART-TX
// - ASCII stream is generated through TX
// - LED also blinks just to show the board is alive
//

`define CYCLE_1s  50_000_000 // 50MHz
`define CYCLE_1ms (CYCLE_1s / 1000)

`define BAUDRATE 115200
`define CYCLE_uart 434 // = (`CYCLE_1s / `BAUDRATE)

//
// chargen module
//
// Notes on UART protocol:
// - Default signal level is HIGH
// - Bit order: [START:L] [7]...[0] [STOP:H]
//
module chargen
  (
   input wire  clk,
   input wire  res_n,
   input wire  uart_rx,
   output wire uart_tx
   );

   reg [32:0] 	     counter;
   reg [8:0] 	     outchar;
   reg 		     tx;
   reg [8:0] 	     outchar_index;

   initial begin
      tx = 1;
      counter = 0;
      outchar = "a";
      outchar_index = 0;
   end

   always @(posedge clk, negedge res_n) begin
      if (~res_n) begin
	 tx <= 1;
	 counter <= 0;
	 outchar <= "a";
	 outchar_index <= 0;
      end
      else begin
	 counter <= counter + 1;

	 if (counter == `CYCLE_uart) begin
	    counter <= 0;

	    outchar_index <= outchar_index + 1;
	    case (outchar_index)
	      0: tx <= 0;
	      9: begin
		 tx <= 1;
		 outchar_index <= 0;

		 if (outchar >= "z") begin
		    outchar <= "a";
		 end
		 else begin
		    outchar <= outchar + 1;
		 end
	      end
	      default: tx <= outchar[outchar_index - 1];
	    endcase
	 end
      end
   end

   assign uart_tx = tx;

endmodule

module top
  (
   input wire 	     clk,
   input wire 	     res_n,
   input wire [2:0]  dip,
   output wire [2:0] led,
   input wire 	     uart_rx,
   output wire 	     uart_tx
   );

   reg [32:0] 	     counter;
   reg [2:0] 	     led_output;

   chargen gen(.clk(clk), .res_n(res_n), .uart_rx(uart_rx), .uart_tx(uart_tx));

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
	 if (counter == `CYCLE_1s) begin
	    counter <= 0;
	    led_output <= ~led_output;
	 end
      end
   end

   // LED[i]:ON when DIP[i]:ON
   assign led = dip;
   
endmodule
