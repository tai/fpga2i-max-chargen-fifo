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
   top_00(.*);

   initial begin : logging
`define HEADER(s) \
      $display(s); \
      $display("# time x nRST LED nWR nRD RP WP NR EF FF IN OUT BUF TX")
      $monitor("%6t %1b %4b %3b %3b %3b %2d %2d %2d %2b %2b %2c %3c %3c %2b",
	       $time, `TICK_X, n_rst, led,
	       top_00.n_wr, top_00.n_rd,
	       top_00.fifo_00.rp, top_00.fifo_00.wp, top_00.fifo_00.nr,
	       top_00.n_empty, top_00.n_full,
	       top_00.fifo_in, top_00.fifo_out,
	       top_00.uartout_00.data_in, uart_tx);
      $timeformat(-9, 0, "", 6);

      $dumpfile("top_tb.vcd");
      $dumpvars(2, top_00);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   initial begin : test_main
      test_reset();
      test_abc();
      test_a2z();
      `test_pass();
   end

   //////////////////////////////////////////////////////////////////////

   task do_reset;
      n_rst = `nT; #1;
      n_rst = `nF;
   endtask
   
   task test_reset;
      `HEADER("### test_reset ###");
      `TICK(1);
      do_reset();
      `test_event("Should reset to LED=1, TX=1, EF=T, IN=0", 1,
		  (
		   (top_00.led === '1) &&
		   (top_00.uart_tx === 1) &&
		   (top_00.n_empty === `nT) &&
		   (top_00.fifo_in === '0)
		   ));
   endtask

   task test_abc;
      static reg [7:0] ch = "a";

      `HEADER("### test_abc ###");

      do_reset();

      // START
      `test_event(`FMT(("Should see START for [%c:%8b]", ch, ch)), 4,
		  (top_00.fifo_out === ch) && (top_00.uart_tx === '0));

      // test each bit on TX
      for (int i = 7; i >= 0; i = i - 1) begin
	 `test_state(`FMT(("Should see bit%1d on TX", i)),
		     UART_CDIV, top_00.uart_tx === ch[i]);
      end

      // STOP
      `test_state(`FMT("Should see STOP with [%2x] in queue", ch + 1),
		  UART_CDIV,
		  (top_00.fifo_out === ch + 1) && (top_00.uart_tx === '1));
   endtask

   task test_a2z;
      static reg [7:0] ch = "a";

      `HEADER("### test_a2z ###");
   endtask
endmodule
