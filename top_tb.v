// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module top_tb;
   reg	      clk, n_rst;
   reg [2:0]  dip;
   reg [2:0]  led;
   reg 	      uart_rx, uart_tx;
   
   top #(.FIFO_DEPTH(4), .UART_CDIV(4), .BLINK_INTERVAL(4))
   top_00(.*);

   // timing(s)
   parameter T0 = 5;   // small offset to avoid racing with clock edge
   parameter TH = 50;  // width of half cycle
   parameter TF = 100; // width of full cycle

   // logging
   initial begin
`define HEADER(s) \
      $display(s); \
      $display("# time nRST LED TX")
      $monitor("%6t %4b %3b %3b", $time, n_rst, led, uart_tx);
      $timeformat(-9, 0, "", 6);

      $dumpfile("top.vcd");
      $dumpvars(2, top_00);
      $dumplimit(1_000_000); // stop dump at 1MB
      $dumpon;
      
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

   task test_run;
      `HEADER("### test_run ###");
      #(TF * 1024);
   endtask

   // run test
   initial begin
      test_reset;
      test_run;
      $finish;
   end
endmodule
