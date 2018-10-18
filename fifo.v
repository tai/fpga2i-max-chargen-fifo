// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

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
    output wire 	    n_full
    );

   reg [WIDTH-1:0] 	    buff[DEPTH-1:0], data_out;
   reg [WIDTH-1:0] 	    rp, wp; // big enough to count DEPTH

   typedef reg [WIDTH-1:0]  bp_t; // buffer pointer type

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
	       rp <= bp_t'((rp + 1) & (DEPTH - 1));
	    end
	 end

	 // handle write to FIFO
	 if (~n_wr) begin
	    if (n_full) begin
	       buff[wp] <= port_in;
	       wp <= bp_t'((wp + 1) & (DEPTH - 1));
	    end
	 end
      end
   end
endmodule

