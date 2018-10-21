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
   reg [WIDTH-1:0] 	    nr;

   typedef reg [WIDTH-1:0]  bp_t; // buffer pointer type

   assign port_out = data_out;

   assign n_empty = (nr ==     0) ? `nT : `nF;
   assign n_full  = (nr == DEPTH) ? `nT : `nF;

   always @(posedge clk, negedge n_rst) begin
      // handle reset
      if (~n_rst) begin
	 rp <= 0;
	 wp <= 0;
	 nr <= 0;
      end
      else begin
	 // handle read+write at the same time
	 if (~n_rd && ~n_wr) begin
	    buff[wp] <= port_in;
	    wp <= bp_t'((wp + 1) & (DEPTH - 1));

	    if (nr > 0) begin
	       // read is only possible when non-empty
	       data_out <= buff[rp];
	       rp <= bp_t'((rp + 1) & (DEPTH - 1));
	    end
	    else begin
	       // increment if only write actually happened
	       nr <= nr + 1;
	    end
	 end

	 // handle read
	 else if (~n_rd) begin
	    if (nr > 0) begin
	       data_out <= buff[rp];
	       rp <= bp_t'((rp + 1) & (DEPTH - 1));
	       nr <= nr - 1;
	    end
	 end

	 // handle write
	 else if (~n_wr) begin
	    if (nr < DEPTH) begin
	       buff[wp] <= port_in;
	       wp <= bp_t'((wp + 1) & (DEPTH - 1));
	       nr <= nr + 1;
	    end
	 end
      end
   end
endmodule
