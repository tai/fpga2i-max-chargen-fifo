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

   wire 	      cgen_valid_n;
   wire 	      fifo_ready_n, fifo_valid_n;
   wire 	      uout_ready_n;
   wire 	      fifo_empty_n, fifo_full_n;

   assign fifo_valid_n = ~fifo_empty_n;
   assign fifo_ready_n = ~fifo_full_n;

   blink #(.CDIV(BLINK_INTERVAL))
   blink0(.clk, .n_rst, .led(led));

   chargen #(.LASTCHAR("z"))
   chargen0(.clk, .n_rst,
	    .port(fifo_in),
	    .ready_n(fifo_ready_n),
	    .valid_n(cgen_valid_n)
	    );
   
   fifo #(.DEPTH(FIFO_DEPTH))
   fifo0(.clk, .n_rst,
	 .port_in(fifo_in),
	 .port_out(fifo_out),
	 .n_wr(cgen_valid_n),
	 .n_rd(uout_ready_n),
	 .n_empty(fifo_empty_n),
	 .n_full(fifo_full_n)
	 );

   uartout #(.CDIV(UART_CDIV))
   uartout0(.clk, .n_rst,
	    .data(fifo_out),
	    .valid_n(fifo_valid_n),
	    .ready_n(uout_ready_n),
	    .tx(uart_tx)
	    );
endmodule

