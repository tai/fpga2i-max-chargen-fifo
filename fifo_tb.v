// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

function [7:0] vc(reg [7:0] c);
   begin
      if (c < " ") begin
	 vc = " ";
      end
      else if (c > "~") begin
	 vc = " ";
      end
      else begin
	 vc = c;
      end
   end
endfunction

module fifo_tb;
   `test_init(clk);

   parameter DEPTH = 2;

   reg clk, n_rst, n_wr, n_rd, n_empty, n_full;
   reg [7:0] port_in, port_out;

   fifo #(.DEPTH(DEPTH)) fifo_00(.*);

   initial begin : logging
`define HEADER(s) \
      $display(s); \
      $display("# time x nRST nWR nRD nEF nFF IN OUT nr rp wp")
      $monitor("%6t %1b %4b %3b %3b %3b %3b %2x %3x %2d %2d %2d",
	       $time, `TICK_X, n_rst, n_wr, n_rd,
	       n_empty, n_full, port_in, port_out,
	       fifo_00.nr, fifo_00.rp, fifo_00.wp);
      $timeformat(-9, 0, "", 6);

      $dumpfile("fifo_tb.vcd");
      $dumpvars(1, fifo_00);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   //////////////////////////////////////////////////////////////////////
   
   initial begin : test_main
      test_reset();
      test_write();
      test_read();
      test_rw_nop();
      test_rw();
      `test_pass();
   end

   task test_reset;
      `HEADER("### test_reset ###");
      `TICK(1);
      n_rst = `nT;
      `TICK(0);
      `test_ok("Should reset to 0", fifo_00.nr === 0);
      `test_ok("Should be empty", n_empty === `nT);
      `test_ok("Should not be full", n_full === `nF);
      n_rst = `nF;
   endtask

   task test_write;
      `test_ok("Should test from empty state", n_empty === `nT);

      `HEADER("### test_write (write without flag) ###");
      n_wr = `nF;

      `TICK(1);
      `test_ok("Should not change nr", fifo_00.nr === 0);
      `test_ok("Should be empty", n_empty === `nT);
      `test_ok("Should not be full", n_full === `nF);

      `HEADER("### test_write (write with flag) ###");
      n_wr = `nT;

      port_in = "a";
      `TICK(1);
      `test_ok("Should inc nr", fifo_00.nr === 1);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should not be full", n_full === `nF);
      
      port_in = port_in + 1;
      `TICK(1);
      `test_ok("Should inc nr", fifo_00.nr === 2);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should be full", n_full === `nT);

      port_in = port_in + 1;
      `TICK(1);
      `test_ok("Should not change nr", fifo_00.nr === 2);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should be full", n_full === `nT);

      n_wr = `nF;
   endtask

   task test_read;
      `test_ok("Should test from full state", n_full === `nT);

      `HEADER("### test_read (read without flag) ###");
      n_rd = `nF;

      `TICK(1);
      `test_ok("Should be full", n_full === `nT);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should not change nr", fifo_00.nr === 2);
      
      `HEADER("### test_read (read with flag) ###");
      n_rd = `nT;

      `TICK(1);
      `test_ok("Should get [a] ", port_out === `STR(a));
      `test_ok("Should not be full", n_full === `nF);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should dec nr", fifo_00.nr === 1);

      `TICK(1);
      `test_ok("Should get [b]", port_out === `STR(b));
      `test_ok("Should not be full", n_full === `nF);
      `test_ok("Should be empty", n_empty === `nT);
      `test_ok("Should dec nr", fifo_00.nr === 0);

      `HEADER("### test_read (read when empty) ###");

      `TICK(1);
      `test_ok("Should not be full", n_full === `nF);
      `test_ok("Should be empty", n_empty === `nT);
      `test_ok("Should not change nr", fifo_00.nr === 0);

      `TICK(1);
      `test_ok("Should not be full", n_full === `nF);
      `test_ok("Should be empty", n_empty === `nT);
      `test_ok("Should not change nr", fifo_00.nr === 0);

      n_rd = `nF;
   endtask

   task test_rw_nop;
      `HEADER("### test_rw_nop (rw at the same time without flag) ###");
      n_wr = `nF;
      n_rd = `nF;
      
      `TICK(1);
      `test_ok("Should not change nr", fifo_00.nr === 0);
      `test_ok("Should be empty", n_empty === `nT);
      `test_ok("Should not be full", n_full === `nF);
   endtask

   task test_rw;
      `HEADER("### test_rw (rw at the same time) ###");
      n_wr = `nT;
      n_rd = `nT;

      `test_ok("Should test from empty state", n_empty === `nT);

      port_in = port_in + 1;
      `TICK(1);
      `test_ok("When empty, only write should happen", fifo_00.nr === 1);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should not be full", n_full === `nF);

      port_in = port_in + 1;
      `TICK(1);
      `test_ok("Should keep nr as both rw/wr happened", fifo_00.nr === 1);
      `test_ok("Should not be empty", n_empty === `nF);
      `test_ok("Should not be full", n_full === `nF);

      n_wr = `nF;
      n_rd = `nF;
   endtask
endmodule
