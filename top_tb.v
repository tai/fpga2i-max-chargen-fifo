// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module top_tb;
   `test_init(clk);

   parameter FIFO_DEPTH = 2;
   parameter UART_CDIV = 2;
   parameter BLINK_INTERVAL = 2;

   reg clk, n_rst;
   reg [2:0] dip;
   reg [2:0] led;
   reg 	     uart_rx, uart_tx;

   top #(.FIFO_DEPTH(FIFO_DEPTH),
	 .UART_CDIV(UART_CDIV),
	 .BLINK_INTERVAL(BLINK_INTERVAL))
   top0(.*);

   initial begin : logging
`define HEADER(s) \
      if (s != "") $display(s); \
      $display("# time x nRST LED C> IN >F RP WP NR F> OUT >U BUF SD TX")
      $monitor("%6t %1b %4b %3b %2b %2c %2b %2d %2d %2d %2b %3c %2b %3c %2b %2b",
	       $time, `TICK_X,
	       n_rst, led,
	       top0.cgen_valid_n,
	       top0.fifo_in,
	       top0.fifo_ready_n,
	       top0.fifo0.rp, top0.fifo0.wp, top0.fifo0.nr,
	       top0.fifo_valid_n,
	       top0.fifo_out,
	       top0.uout_ready_n,
	       top0.uartout0.data_in,
	       top0.uartout0.is_sending,
	       top0.uart_tx);
      $timeformat(-9, 0, "", 6);

      $dumpfile("top_tb.vcd");
      $dumpvars(2, top0);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   // insert header for readability
   always #(TF * 5) begin `HEADER(""); end

   // force finish at given time
   //always #4000 begin $finish; end

   initial begin : test_main
      test_reset();
      test_abc();
      `test_pass();
   end

   //////////////////////////////////////////////////////////////////////

   task do_reset;
      `HEADER("# do_reset");
      n_rst = `nT; #1;
      n_rst = `nF;
   endtask
   
   task test_reset;
      `HEADER("### test_reset ###");
      `TICK(1);
      do_reset();
      `test_ok("Should reset to LED=1, TX=1, EF=T, IN=X",
	       (
		(top0.led === '1) &&
		(top0.uart_tx === 1) &&
		(top0.fifo_empty_n === `nT) &&
		(top0.fifo_in === `STR(a))
		));
   endtask

   task do_once(input reg [7:0] ch);
      `HEADER(`FMT(("# do_once: %0c", ch)));

      // START
      `test_signal(`FMT(("Should see START as TX=0 for [%c:%8b]", ch, ch)),
		   4, UART_CDIV,
		   (top0.uartout0.data_in === ch) && (top0.uart_tx === 0));

      // test each bit on TX
      for (int i = 7; i >= 0; i = i - 1) begin
	 `test_signal(`FMT(("Should see bit%1d as TX=%1b", i, ch[i])),
		      1, UART_CDIV, top0.uart_tx === ch[i]);
      end

      // STOP
      `test_signal(`FMT(("Should see STOP as TX=1 with [%0c] in queue", ch + 1)),
		   1, UART_CDIV,
		   (top0.uartout0.data_in === ch + 1) && (top0.uart_tx === 1));
   endtask

   task test_abc;
      static string keys = "abcde";

      `HEADER("### test_abc ###");
      do_reset();

      for (int i = 0; i < 5; i++) begin
	 do_once(keys[i]);
      end
   endtask
endmodule
