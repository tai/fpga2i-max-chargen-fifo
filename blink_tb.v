// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps
`include "common.v"

module blink_tb;
   `test_init(clk);

   reg clk, n_rst;
   reg [2:0] led;

   blink #(.CDIV(3)) blink0(.*);

   initial begin : logging
`define HEADER(s) \
      $display(s); \
      $display("# time x nRST LED COUNTER")
      $monitor("%6t %1b %4b %3b %7d",
	       $time, `TICK_X, n_rst, led, blink0.counter);
      $timeformat(-9, 0, "", 6);

      $dumpfile("blink_tb.vcd");
      $dumpvars(1, blink0);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   //////////////////////////////////////////////////////////////////////

   initial begin : test_main
      test_reset();
      test_blink();
      `test_pass();
   end
   
   task test_reset;
      `HEADER("### test_reset ###");
      `TICK(1);
      n_rst = `nT;
      `TICK(0); // async reset does not have to wait for clock edge
      `test_ok("Counter should reset to 0", blink0.counter === 0);
      `test_ok("LED should be off (pin==1)", blink0.led === '1);
      n_rst = `nF;
   endtask

   task test_blink;
      `HEADER("### test_blink ###");

      //
      // tick-based tests (kept as a record - better use state-based tests)
      //

      `TICK(1);
      `test_ok("Counter should be 1", blink0.counter === 1);

      `TICK(1);
      `test_ok("Counter should be 2", blink0.counter === 2);

      `TICK(1);
      `test_ok("Counter should be 3", blink0.counter === 3);
      `test_ok("LED should be off (pin==1)", blink0.led === '1);

      `TICK(1);
      `test_ok("Counter should be 1", blink0.counter === 1);
      `test_ok("LED should now be on (pin==0)", blink0.led === '0);

      //
      // better state-based behaviour tests
      //
      `test_event("LED should be 1 in 3T", 3, blink0.led === '1);
      `test_state("LED should stay 1 for 2T", 2, blink0.led === '1);
      `test_event("LED should be 0 in 1T", 1, blink0.led === '0);
      `test_state("LED should stay 0 for 2T", 2, blink0.led === '0);
   endtask
endmodule
