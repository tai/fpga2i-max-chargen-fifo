// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

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

