// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

//
// chargen - character generator
//
module chargen
  #(
    parameter LASTCHAR = "z"
    )
   (
    input wire 	      clk, // on every posedge, new byte is generated
    input wire 	      n_rst, // reset state when asserted
    input wire 	      ready_n, // slave is ready to read
    output wire       valid_n, // data is valid
    output wire [7:0] port // output data
    );

   typedef reg [7:0]  portdata_t;

   portdata_t next_port, next_char;
   reg 		      next_valid_n;

   assign valid_n = next_valid_n;
   assign port = next_port;
   
   always @(posedge clk, negedge n_rst) begin
      if (~n_rst) begin
	 next_valid_n <= `nF;
	 next_port <= "a";
	 next_char <= "a";
      end
      else if (~ready_n) begin
	 next_valid_n <= `nT;
	 next_port <= next_char;
	 next_char <= portdata_t'(next_char + 1);

	 if (next_char == LASTCHAR) begin
	    next_char <= "a";
	 end
      end
      else begin
	 next_valid_n <= `nF;
	 next_char <= next_port;
      end
   end
endmodule
