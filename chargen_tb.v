// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module chargen_tb;
   `test_init(clk);

   reg clk, n_rst, n_cs, n_wr;
   reg [7:0] port;

   chargen #(.LASTCHAR(`STR(c))) chargen_00(.*);

   initial begin : logging
`define HEADER(s) \
      $display(s); \
      $display("# time x nRST nCS nWR OUT")
      $monitor("%6t %1b %4b %3b %3b %3c",
	       $time, `TICK_X, n_rst, n_cs, n_cs, port);
      $timeformat(-9, 0, "", 6);

      $dumpfile("chargen_tb.vcd");
      $dumpvars(1, chargen_00);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   //////////////////////////////////////////////////////////////////////

   initial begin : test_main
      test_reset();
      test_output();
      `test_pass();
   end

   task test_reset;
      `HEADER("### test_reset ###");
      `TICK(1);
      n_rst = `nT;
      `TICK(0);
      `test_eq("Output should be NUL", port, '0);
      n_rst = `nF;
   endtask

   task test_output;
      `HEADER("### test_output ###");
      n_cs = `nF;
      `TICK(1);
      `test_eq("Output should be NUL", port, '0);

      n_cs = `nT;
      `TICK(1);
      `test_eq("Output should be [a]", port, `STR(a));
      `test_eq("Write strobe should be asserted", n_wr, `nT);

      `TICK(1);
      `test_eq("Output should be [b]", port, `STR(b));

      `TICK(1);
      `test_eq("Output should be [c]", port, `STR(c));

      n_cs = `nF;
      `TICK(1);
      `test_eq("Output should be NUL", port, '0);
      
      n_cs = `nT;
      `TICK(1);
      `test_eq("Output should be [a]", port, `STR(a));

      `TICK(1);
      `test_eq("Output should be [b]", port, `STR(b));
   endtask
endmodule
