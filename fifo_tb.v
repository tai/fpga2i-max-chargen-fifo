// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module fifo_tb;
   // timing(s)
   parameter T0 = 5;   // small offset to avoid racing with clock edge
   parameter TH = 50;  // width of half cycle
   parameter TF = 100; // width of full cycle

   reg clk, n_rst, n_wr, n_rd, n_empty, n_full;
   reg [7:0] port_in, port_out;

   fifo #(.DEPTH(4)) fifo_00(.*);

   // logging
   initial begin
`define HEADER(s) \
      $display(s); \
      $display("# time nRST nWR nRD nEF nFF IN OUT rp wp")
      $monitor("%6t %4b %3b %3b %3b %3b %2c %3c %2d %2d",
	       $time, n_rst, n_wr, n_rd,
	       n_empty, n_full, port_in, port_out, fifo_00.rp, fifo_00.wp);
      $timeformat(-9, 0, "", 6);

      //`HEADER("# start");
      //forever #(TF*10) `HEADER("#");
   end

   // clock
   initial begin
      #T0 clk = 0;
      forever #TH clk = ~clk;
   end

   task test_reset;
      `HEADER("### test_reset ###");
      n_rst = `nF; #TF;
      n_rst = `nT; #TF;
      n_rst = `nF; #TF;
   endtask

   task test_write;
      `HEADER("### test_write ###");
      n_wr = `nF;
      port_in = "a";
      #TF;
      repeat(5) begin
	 n_wr = `nT; #TF;
	 n_wr = `nF; #TF;
	 port_in = port_in + 1;
      end
   endtask

   task test_read;
      `HEADER("### test_read ###");
      n_rd = `nF; #TF;
      repeat(5) begin
	 n_rd = `nT; #TF;
	 n_rd = `nF; #TF;
      end
   endtask
      
   // run test
   initial begin
      test_reset;
      test_write;
      test_read;
      $finish;
   end
endmodule
