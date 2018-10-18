// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

`define INITCHAR "a"
`define LASTCHAR "c"

module chargen_tb;
   // timing(s)
   parameter T0 = 5;   // small offset to avoid racing with clock edge
   parameter TH = 50;  // width of half cycle
   parameter TF = 100; // width of full cycle

   reg clk, n_rst, n_cs, n_wr;
   reg [7:0] port;

   chargen #(.LASTCHAR(`LASTCHAR)) chargen_00(.*);

   // logging
   initial begin
`define HEADER(s) \
      $display(s); \
      $display("# time nRST nCS nWR OUT")
      $monitor("%6t %4b %3b %3b %3c",
	       $time, n_rst, n_cs, n_cs, port);
      $timeformat(-9, 0, "", 6);

      $dumpfile("chargen_tb.vcd");
      $dumpvars(1, chargen_00);
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
      #TF n_rst = `nF;
      #TF n_rst = `nT;
      #TF n_rst = `nF;

      `test_eq("Output should be initialized to [a]", port, `INITCHAR);
   endtask

   task test_output;
      `HEADER("### test_output ###");
      repeat(6) begin
	 #TF n_cs = `nT;
      end
      `test_eq("Output should now be [c]", port, `LASTCHAR);
   endtask

   initial begin
      test_reset();
      test_output();
      `test_pass();
   end
endmodule
