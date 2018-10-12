// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
//
// UART chargen with FIFO between generator and writer
//
// Expected behavior:
// - PMOD[0] works as UART-RX
// - PMOD[1] works as UART-TX
// - ASCII stream is generated through TX
// - LED also blinks just to show the board is alive
//

`timescale 1ns/1ps

// TRUE/FALSE in negative/positive logic
`define nT '0
`define nF '1
`define pT '1
`define pF '0

`define CYCLE_1s  50_000_000 // 50MHz

module top
  #(
    parameter FIFO_DEPTH=16,
    parameter UART_CDIV=434,
    parameter BLINK_INTERVAL=`CYCLE_1s
    )
   (
    input wire 	      clk,
    input wire 	      n_rst,
    input wire [2:0]  dip,
    output wire [2:0] led,
    input wire 	      uart_rx,
    output wire       uart_tx
    );

   wire [7:0] 	      fifo_in, fifo_out;
   wire 	      n_wr, n_rd, n_empty, n_full;

   fifo #(.DEPTH(FIFO_DEPTH))
   fifo_00(.clk, .n_rst,
	   .port_in(fifo_in), .port_out(fifo_out),
	   .n_wr(n_wr), .n_rd(n_rd), .n_empty(n_empty), .n_full(n_full));

   chargen #(.LASTCHAR("z"))
   chargen_00(.clk, .n_rst,
	      .port(fifo_in), .n_cs(~n_full), .n_wr(n_wr));
   
   uartout #(.CDIV(UART_CDIV))
   uartout_00(.clk, .n_rst,
	      .data(fifo_in), .n_cs(~n_empty), .n_rd(n_rd),
	      .tx(uart_tx));

   blink #(.CDIV(BLINK_INTERVAL))
   blink_00(.clk, .n_rst, .led(led));
endmodule

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
