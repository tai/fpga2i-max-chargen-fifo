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
    input wire 	     n_valid,
    input wire [7:0] data,
    output wire      n_ready,
    output wire      tx
    );

   reg [31:0] 	     counter;
   reg [7:0] 	     data_in;
   reg 		     n_empty;
   reg 		     tx_out;
   reg [3:0] 	     tx_index;
   reg 		     is_sending;

   typedef reg [3:0] txlen_t;

   assign n_ready = n_empty;
   assign tx = tx_out;

   always @(posedge clk, negedge n_rst) begin
      if (~n_rst) begin
	 tx_out <= 1;
	 n_empty <= `nT;
	 is_sending <= `pF;
      end
      else begin
	 if ((n_empty == `nT) && (n_valid == `nT)) begin
	    data_in <= data;
	    n_empty <= `nF;

	    if (is_sending == `pF) begin
	       is_sending <= `pT;
	       counter <= 1;
	       tx_out <= 0;
	       tx_index <= 1;
	    end
	 end

	 if (is_sending == `pT) begin
	    counter <= counter + 1;

	    if (counter == CDIV) begin
	       counter <= 1;

	       tx_index <= txlen_t'(tx_index + 1);
	       case (tx_index)
		 0: begin
		    tx_out <= 0; // START bit
		 end
		 8: begin
		    tx_out <= data_in[0]; // MSbit-first
		    n_empty <= `nT; // last bit is sent - buffer is empty now
		 end
		 9: begin
		    tx_out <= 1; // STOP bit
		    tx_index <= 0;

		    // try loading next data while sending STOP bit
		    if (n_valid == `nT) begin
		       data_in <= data;
		       n_empty <= `nF;
		    end
		    else begin
		       is_sending <= `pF;
		    end
		 end
		 default: begin
		    tx_out <= data_in[8 - tx_index]; // MSbit-first
		 end
	       endcase
	    end
	 end
      end
   end
endmodule
