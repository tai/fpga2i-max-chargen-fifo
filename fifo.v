// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps
`default_nettype none

`include "common.v"

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
    output wire 	    n_full,
    output wire 	    n_valid
    );

   reg [WIDTH-1:0] 	    buff[DEPTH-1:0];

   typedef reg [7:0] 	    bufflen_t; // support up to DEPTH == 256
   bufflen_t rp, wp, nr;

   // Act as FWFT (First Word Fall Through) FIFO,
   // which "non-empty" flag means data on output port is already valid.
   assign port_out = buff[rp];

   assign n_empty = nr != 0;
   assign n_full  = nr != DEPTH;

   reg 			    can_read, can_write;
   assign can_read  = ~n_rd & (nr != 0);
   assign can_write = ~n_wr & (nr != DEPTH);
   
   always @(posedge clk, negedge n_rst) begin
      // handle reset
      if (~n_rst) begin
	 rp <= 0;
	 wp <= 0;
	 nr <= 0;
      end
      else begin
	 // handle write
	 if (can_write) begin
	    buff[wp] <= port_in;
	    wp <= bufflen_t'((wp + 1) & (DEPTH - 1));

	    if (~can_read) begin
	       nr <= nr + 1;
	    end
	 end

	 // handle read
	 if (can_read) begin
	    rp <= bufflen_t'((rp + 1) & (DEPTH - 1));

	    if (~can_write) begin
	       nr <= nr - 1;
	    end
	 end
      end
   end
endmodule

`default_nettype wire
