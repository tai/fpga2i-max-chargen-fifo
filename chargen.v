// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

// TRUE/FALSE in negative/positive logic
`define nT '0
`define nF '1
`define pT '1
`define pF '0

module chargen
  #(
    parameter LASTCHAR = "z"
    )
   (
    input wire 	      clk,
    input wire 	      n_rst,
    output wire [7:0] port,
    input wire 	      n_cs,
    output wire       n_wr
    );

   reg [7:0] 	      port_int;
   reg 		      n_wr_int;

   assign n_wr = n_wr_int;
   assign port = port_int;
   
   always @(posedge clk, negedge n_rst) begin
      if (~n_rst) begin
	 n_wr_int <= `nF;
	 port_int <= "a";
      end
      else if (~n_cs) begin
	 n_wr_int <= `nT;
	 port_int <= port_int + 1;

	 if (port_int == LASTCHAR) begin
	    port_int <= "a";
	 end
      end
   end
endmodule

module chargen_tb;
   // timing(s)
   parameter T0 = 5;   // small offset to avoid racing with clock edge
   parameter TH = 50;  // width of half cycle
   parameter TF = 100; // width of full cycle

   reg clk, n_rst, n_cs, n_wr;
   reg [7:0] port;

   chargen #(.LASTCHAR("c")) chargen_00(.*);

   // logging
   initial begin
`define HEADER(s) \
      $display(s); \
      $display("# time nRST nCS nWR OUT")
      $monitor("%6t %4b %3b %3b %3c",
	       $time, n_rst, n_cs, n_cs, port);
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

   task test_output;
      `HEADER("### test_output ###");
      repeat(5) begin
	 n_cs = `nT; #TF;
      end
   endtask

   initial begin
      test_reset;
      test_output;
      $finish;
   end
endmodule
