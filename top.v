// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
//
// UART chargen with FIFO between generator and writer
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

module fifo
  #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
    )
   (
    input wire 		    res_n,
    input wire 		    clk,
    input wire [WIDTH-1:0]  port_in,
    output wire [WIDTH-1:0] port_out,
    input wire 		    wen_n,
    input wire 		    ren_n,
    output wire 	    is_empty,
    output wire 	    is_full
    );

   reg [WIDTH-1:0] 	    buff[DEPTH-1:0], data_out;
   reg [WIDTH-1:0] 	    rp, wp; // big enough to count DEPTH

   assign port_out = data_out;

   assign is_empty = (rp == wp) ? '1 : '0;
   assign is_full = ((wp - rp) == (DEPTH - 1)) ? '1 :
		    ((rp - wp) == 1) ? '1 : '0;

   always @(posedge clk, negedge res_n) begin
      if (~res_n) begin
	 rp <= '0;
	 wp <= '0;
      end else begin
	 // handle read from FIFO
	 if (~ren_n) begin
	    if (~is_empty) begin
	       data_out <= buff[rp];
	       rp <= (rp + 1) % DEPTH;
	    end
	 end

	 // handle write to FIFO
	 if (~wen_n) begin
	    if (~is_full) begin
	       buff[wp] <= port_in;
	       wp <= (wp + 1) % DEPTH;
	    end
	 end
      end
   end
endmodule

module chargen
  (
   input wire 	     clk,
   input wire 	     res_n,
   output wire [7:0] port,
   input wire 	     cs_n,
   output wire 	     wen_n
   );

   reg [7:0] 	     outchar;
   reg 		     wen_n_int;
   
   always @(posedge clk, negedge res_n) begin
      if (~res_n) begin
	 wen_n_int <= '1;
	 outchar <= "a";
      end else begin
	 if (~cs_n) begin
	    if (~wen_n_int) begin
	       wen_n_int <= '0;
	       outchar <= outchar + 1;

	       if (outchar == "z") begin
		  outchar <= "a";
	       end
	    end else begin
	       wen_n_int <= '1;
	    end
	 end else begin
	    wen_n_int <= '1;
	 end
      end
   end

   assign wen_n = wen_n_int;
   assign port = outchar;
endmodule

//
// sender module
//
// Notes on UART protocol:
// - Default signal level is HIGH
// - Bit order: [START:L] [7]...[0] [STOP:H]
//
module sender
  (
   input wire 	    clk,
   input wire 	    res_n,
   input wire [7:0] port,
   input wire 	    cs_n,
   output wire 	    ren_n,
   output wire 	    uart_tx
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
      else if (~cs_n) begin
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

//
// LED blinker
//
module blink
  (
   input wire 	     clk,
   input wire 	     res_n,
   output wire [2:0] led
   );

   reg [32:0] 	     counter;
   reg [2:0] 	     led_output;

   initial begin
      counter = 0;
      led_output <= ~0;
   end

   always @(posedge clk, negedge res_n) begin
      // reset
      if (~res_n) begin
	 counter <= 0;
	 led_output <= ~0;
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

   // drive LED
   assign led = led_output;
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

   wire [7:0] 	     fifo_in, fifo_out;
   wire 	     wen_n, ren_n, is_empty, is_full;

   fifo #(.DEPTH(16))
   fifo_00(.clk, .res_n,
	   .port_in(fifo_in), .port_out(fifo_out),
	   .wen_n(wen_n), .ren_n(ren_n),
	   .is_empty(is_empty), .is_full(is_full));

   chargen
   chargen_00(.clk, .res_n,
	      .port(fifo_in), .cs_n(~is_full), .wen_n(wen_n));
   
   sender
   sender_00(.clk, .res_n,
	     .port(fifo_in), .cs_n(~is_empty), .ren_n(ren_n),
	     .uart_tx(uart_tx));

   blink
   blink_00(.clk, .res_n, .led(led));
endmodule
