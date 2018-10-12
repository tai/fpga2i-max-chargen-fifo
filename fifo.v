// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

// TRUE/FALSE in negative/positive logic
`define nT '0
`define nF '1
`define pT '1
`define pF '0

module fifo
  #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
    )
   (
    input wire 		    clk,
    input wire 		    n_rst,
    input wire [WIDTH-1:0]  port_in,
    output wire [WIDTH-1:0] port_out,
    input wire 		    n_wr,
    input wire 		    n_rd,
    output wire 	    n_empty,
    output wire 	    n_full
    );

   reg [WIDTH-1:0] 	    buff[DEPTH-1:0], data_out;
   reg [WIDTH-1:0] 	    rp, wp; // big enough to count DEPTH

   assign port_out = data_out;

   assign n_empty = (rp == wp) ? `nT : `nF;
   assign n_full = ((wp - rp) == (DEPTH - 1)) ? `nT :
		   ((rp - wp) == 1) ? `nT : `nF;

   always @(posedge clk, negedge n_rst) begin
      // handle reset
      if (~n_rst) begin
	 rp <= 0;
	 wp <= 0;
      end
      else begin
	 // handle read from FIFO
	 if (~n_rd) begin
	    if (n_empty) begin
	       data_out <= buff[rp];
	       rp <= (rp + 1) & (DEPTH - 1);
	    end
	 end

	 // handle write to FIFO
	 if (~n_wr) begin
	    if (n_full) begin
	       buff[wp] <= port_in;
	       wp <= (wp + 1) & (DEPTH - 1);
	    end
	 end
      end
   end
endmodule

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
