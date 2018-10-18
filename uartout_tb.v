// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module uartout_tb;
   // timing(s)
   parameter T0 = 5;   // small offset to avoid racing with clock edge
   parameter TH = 50;  // width of half cycle
   parameter TF = 100; // width of full cycle

   reg clk, n_rst, n_cs, n_rd;
   reg [7:0] data;
   reg 	     tx;
   
   uartout #(.CDIV(8)) uartout_00(.*);

   // logging
   initial begin
`define HEADER(s) \
      $display(s); \
      $display("# time nRST nCS nRD IN TX TXI")
      $monitor("%6t %4b %3b %3b %2c %2b %3d",
	       $time, n_rst, n_cs, n_rd, data, tx, uartout_00.tx_index);
      $timeformat(-9, 0, "", 6);

      $dumpfile("uartout.vcd");
      $dumpvars(1, uartout_00);
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

   task test_write;
      `HEADER("### test_write: S ###");
      data = 8'b01010011;
      n_cs = `nT; #TF;
      n_cs = `nF;
      while (n_rd) #TF;

      `HEADER("### test_write: t ###");
      data = 8'b01110100;
      n_cs = `nT; #TF;
      n_cs = `nF;
      while (n_rd) #TF;
   endtask

   // run test
   initial begin
      test_reset;
      test_write;
      $finish;
   end
endmodule
