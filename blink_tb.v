// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module blink_tb;
   // timing(s)
   parameter T0 = 5;   // small offset to avoid racing with clock edge
   parameter TH = 50;  // width of half cycle
   parameter TF = 100; // width of full cycle
   
   reg	      clk, n_rst;
   reg [2:0]  led;

   blink #(.CDIV(1)) blink_00(.*);

   // logging
   initial begin
`define HEADER(s) \
      $display(s); \
      $display("# time nRST LED")
      $monitor("%6t %4b %3b", $time, n_rst, led);
      $timeformat(-9, 0, "", 6);

      $dumpfile("blink.vcd");
      $dumpvars(1, blink_00);
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
   
   task test_blink;
      `HEADER("### test_blink ###");
      #(TF * 10);
   endtask

   // run test
   initial begin
      test_reset;
      test_blink;
      $finish;
   end
endmodule
