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
    output wire [7:0] port, // output port where new byte is generated
    input wire 	      n_cs, // generates byte when asserted
    output wire       n_wr // asserted when new byte is written
    );

   reg [7:0] 	      port_int, port_next;
   reg 		      n_wr_int;

   typedef reg [7:0]  portsize_t;

   assign n_wr = n_wr_int;
   assign port = port_int;
   
   always @(posedge clk, negedge n_rst) begin
      if (~n_rst) begin
	 n_wr_int  <= `nF;
	 port_int  <= '0;
	 port_next <= "a";
      end
      else if (~n_cs) begin
	 n_wr_int  <= `nT;
	 port_int  <= port_next;
	 port_next <= portsize_t'(port_next + 1);

	 if (port_next == LASTCHAR) begin
	    port_next <= "a";
	 end
      end
      else begin
	 n_wr_int <= `nF;
	 port_int <= '0;
      end
   end
endmodule
