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

`include "common.v"

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

