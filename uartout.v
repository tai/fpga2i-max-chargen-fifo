// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps
`include "common.v"

//
// uartout module
//
// Notes on UART protocol:
// - Default signal level is HIGH
// - Bit order: [START:L] [7]...[0] [STOP:H]
//
module uartout
  #(
    parameter CDIV = 434
    )
   (
    input wire 	     clk,
    input wire 	     n_rst,
    input wire 	     n_cs,
    input wire [7:0] data,
    output wire      n_rd,
    output wire      tx
    );

   reg [31:0] 	     counter;
   reg [7:0] 	     data_saved;
   reg 		     data_valid;
   reg 		     tx_out;
   reg [3:0] 	     tx_index;
   reg 		     n_rd_out;

   assign n_rd = n_rd_out;
   assign tx = tx_out;

   always @(posedge clk, negedge n_rst) begin
      if (~n_rst) begin
	 n_rd_out <= `nT;
	 tx_out <= 1;
	 data_valid <= 0;
      end
      else begin
	 if (~n_cs) begin
	    if (~data_valid) begin
	       data_valid <= 1;
	       data_saved <= data;

	       tx_out <= 0; // START bit
	       tx_index <= 0;

	       counter <= 1;
	       n_rd_out <= `nF;
	    end
	 end

	 if (data_valid) begin
	    counter <= counter + 1;

	    if (counter == CDIV) begin
	       counter <= 0;
	    end
	    else if (counter == 0) begin
	       tx_index <= tx_index + 1;

	       case (tx_index)
		 8: begin
		    tx_out <= 1; // STOP bit
		    data_valid <= 0;
		    n_rd_out <= `nT;
		 end
		 default: begin
		    tx_out <= data_saved[tx_index];
		 end
	       endcase
	    end
	 end
      end
   end
endmodule

