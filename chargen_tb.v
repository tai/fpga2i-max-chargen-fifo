// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module chargen_tb;
   `test_init(clk);

   reg clk, n_rst, ready_n, valid_n;
   reg [7:0] port;

   chargen #(.LASTCHAR(`STR(c))) chargen0(.*);

   initial begin : logging
`define HEADER(s) \
      if (s != "") $display(s); \
      $display("# time x nRST nRDY nVLD OUT")
      $monitor("%6t %1b %4b %4b %4b %3c",
	       $time, `TICK_X, n_rst, ready_n, valid_n, port);
      $timeformat(-9, 0, "", 6);

      $dumpfile("chargen_tb.vcd");
      $dumpvars(1, chargen0);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   // insert header for readability
   always #(TF * 5) begin `HEADER(""); end

   // force finish at given time
   //always #4000 begin $finish; end

   //////////////////////////////////////////////////////////////////////

   initial begin : test_main
      test_reset();
      test_output();
      `test_pass();
   end

   task do_reset;
      `HEADER("# do_reset");
      n_rst = `nT; #1;
      n_rst = `nF;
   endtask

   task test_reset;
      `HEADER("### test_reset ###");
      `TICK(1);
      do_reset();
      `test_eq("Output should be [a]", port, `STR(a));
   endtask

   task test_output;
      `HEADER("### test_output ###");
      do_reset();

      ready_n = `nF;
      `TICK(1);
      `test_eq("Output should be [a]", port, `STR(a));

      ready_n = `nT;
      `TICK(1);
      `test_eq("Output should be [a]", port, `STR(a));
      `test_eq("Data should be valid", valid_n, `nT);

      `TICK(1);
      `test_eq("Output should be [b]", port, `STR(b));

      `TICK(1);
      `test_eq("Output should be [c]", port, `STR(c));

      ready_n = `nF;
      `TICK(1);
      `test_eq("Output should be [c]", port, `STR(c));
      `test_eq("Data should not be valid", valid_n, `nF);
      
      ready_n = `nT;
      `TICK(1);
      `test_eq("Output should be [a]", port, `STR(c));
      `test_eq("Data should be valid", valid_n, `nT);

      `TICK(1);
      `test_eq("Output should be [b]", port, `STR(a));
   endtask
endmodule
