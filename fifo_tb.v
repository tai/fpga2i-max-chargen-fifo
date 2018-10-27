// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module fifo_tb;
   `test_init(clk);

   parameter DEPTH = 2;

   reg clk, n_rst, n_wr, n_rd, n_empty, n_full, n_valid;
   reg [7:0] port_in, port_out;

   fifo #(.DEPTH(DEPTH)) fifo0(.*);

   initial begin : logging
`define HEADER(s) \
      if (s != "") $display(s); \
      $display("# time x nRST nWR nRD nEF nFF IN OUT RP WP NR")
      $monitor("%6t %1b %4b %3b %3b %3b %3b %2c %3c %2d %2d %2d",
	       $time, `TICK_X, n_rst, n_wr, n_rd,
	       n_empty, n_full, port_in, port_out,
	       fifo0.rp, fifo0.wp, fifo0.nr);
      $timeformat(-9, 0, "", 6);

      $dumpfile("fifo_tb.vcd");
      $dumpvars(1, fifo0);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   // insert header for readability
   always #(TF * 5) begin `HEADER(""); end

   //////////////////////////////////////////////////////////////////////
   
   initial begin : test_main
      test_reset();
      test_write();
      test_read();
      test_rw_nop();
      test_rw();
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
      `test_ok("Should reset to 0", fifo0.nr === 0);
      `test_ok("Should be empty", n_empty === `nT);
      `test_ok("Should not be full", n_full === `nF);
   endtask

   task test_write;
      `HEADER("### test_write (non-asserted write) ###");

      do_reset();
      `test_ok("Should test from empty state", n_empty === `nT);

      n_rd = `nF;
      n_wr = `nF;

      `TICK(1);
      `test_ok("Should not change nr", fifo0.nr === 0);
      `test_ok("Should be empty", n_empty === `nT);
      `test_ok("Should not be full", n_full === `nF);

      `HEADER("### test_write (asserted write) ###");
      n_rd = `nF;
      n_wr = `nT;

      port_in = "a";
      `TICK(1);
      `test_ok("Should inc nr", fifo0.nr === 1);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should not be full", n_full === `nF);
      
      port_in = port_in + 1;
      `TICK(1);
      `test_ok("Should inc nr", fifo0.nr === 2);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should be full", n_full === `nT);

      port_in = port_in + 1;
      `TICK(1);
      `test_ok("Should not change nr", fifo0.nr === 2);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should be full", n_full === `nT);

      n_wr = `nF;
   endtask

   task test_read;
      `HEADER("### test_read (non-asserted read) ###");
      `test_ok("Should test from full state", n_full === `nT);

      n_rd = `nF;
      `test_event("Should stay full if not read-asserted",
		  1, n_full === `nT);
      
      // NOTE: first valid data is alway on the port
      `test_ok("Should see [a] ", port_out === `STR(a));

      `HEADER("### test_read (asserted read) ###");

      n_rd = `nT;

      // Next data in FIFO pops out with every tick
      `test_event("Should see [b], with non-full buffer",
		  1, port_out === `STR(b) && n_full === `nF);

      `HEADER("### test_read (read when empty) ###");

      `test_event("Should be empty",
		  1, n_empty === `nT && fifo0.nr === 0);

      `test_event("Should be empty (again)",
		  1, n_empty === `nT && fifo0.nr === 0);

      n_rd = `nF;
   endtask

   task test_rw_nop;
      `HEADER("### test_rw_nop (non-asserted read/write) ###");
      n_wr = `nF;
      n_rd = `nF;
      
      `test_event("Should stay empty with non-asserted read/write",
		  1, n_empty === `nT && fifo0.nr === 0);
   endtask

   task test_rw;
      `HEADER("### test_rw (rw at the same time) ###");

      do_reset();
      `test_ok("Should test from empty state", n_empty === `nT);
      
      n_wr = `nT;
      n_rd = `nT;

      port_in = port_in + 1;
      `test_event("When empty, only write should happen",
		  1, n_empty === `nF && fifo0.nr === 1);
      
      port_in = port_in + 1;
      `test_event("Should keep nr as both read/write happened",
		  1, n_empty === `nF && fifo0.nr === 1);

      n_wr = `nF;
      n_rd = `nF;
   endtask
endmodule
