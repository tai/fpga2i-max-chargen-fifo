// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps
`default_nettype none

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
    input wire [7:0] data,
    input wire 	     valid_n,
    output wire      ready_n,
    output wire      tx
    );

   reg [31:0] 	     counter;
   reg [7:0] 	     data_in;
   reg 		     tx_out;
   reg [3:0] 	     tx_index;
   reg 		     is_empty, is_sending;

   typedef reg [3:0] txlen_t;

   assign tx = tx_out;
   assign ready_n = ~is_empty;
   
   always @(posedge clk, negedge n_rst) begin
      if (~n_rst) begin
	 tx_out <= 1;
	 is_empty <= `pT;
	 is_sending <= `pF;
      end
      else begin
	 if (~valid_n && is_empty) begin
	    data_in <= data;
	    is_empty <= `pF;
	 end

	 // Send START, unless in previous STOP cycle.
	 //
	 // NOTE: If in STOP cycle, START will be sent from TX sending loop.
	 if (is_sending == `pF) begin
	    if (~is_empty || ~valid_n) begin
	       is_sending <= `pT;
	       counter <= 0;
	       tx_out <= 0; // START bit
	       tx_index <= 0;
	    end
	 end

	 if (is_sending == `pT) begin
	    counter <= counter + 1;

	    if (counter == (CDIV - 1)) begin
	       counter <= 0;

	       tx_index <= txlen_t'(tx_index + 1);
	       case (tx_index)
		 8: begin
		    tx_out <= 1; // STOP bit
		 end
		 9: begin
		    // Data seems to be sampled. Continue to next START bit
		    if (~is_empty || ~valid_n) begin
		       tx_out <= 0;
		       tx_index <= 0;
		    end
		    else begin
		       is_sending <= `pF;
		    end
		 end
		 default: begin
		    tx_out <= data_in[tx_index]; // LSbit-first

		    // last bit is sent - buffer is empty now
		    if (tx_index == 7) begin
		       is_empty <= `pT;
		    end
		 end
	       endcase
	    end
	 end
      end
   end
endmodule

`default_nettype wire
