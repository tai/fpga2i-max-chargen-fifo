// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

// TRUE/FALSE in negative/positive logic
`define nT '0
`define nF '1
`define pT '1
`define pF '0

// Example: `LOG(("value=%2d", value));
`define LOG(s) $write("%6t ", $time); $display s

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

module uartout_tb;
   // timing(s)
   parameter T0 = 5;   // small offset to avoid racing with clock edge
   parameter TH = 50;  // width of half cycle
   parameter TF = 100; // width of full cycle

   reg clk, n_rst, n_cs, n_rd;
   reg [7:0] data;
   reg 	     tx;
   
   uartout #(.CDIV(8)) uartout_00(.*);

   // logging
   initial begin
`define HEADER(s) \
      $display(s); \
      $display("# time nRST nCS nRD IN TX TXI")
      $monitor("%6t %4b %3b %3b %2c %2b %3d",
	       $time, n_rst, n_cs, n_rd, data, tx, uartout_00.tx_index);
      $timeformat(-9, 0, "", 6);

      $dumpfile("uartout.vcd");
      $dumpvars(1, uartout_00);
      $dumplimit(1_000_000); // stop dump at 1MB
      $dumpon;

      //`HEADER("# start");
      //forever #(TF*10) `HEADER("#");
   end

   // clock
   initial begin
      #T0 clk = 0;
      forever #TH clk = ~clk;
   end

   task test_reset;
      `HEADER("### test_reset ###");
      n_rst = `nF; #TF;
      n_rst = `nT; #TF;
      n_rst = `nF; #TF;
   endtask

   task test_write;
      `HEADER("### test_write: S ###");
      data = 8'b01010011;
      n_cs = `nT; #TF;
      n_cs = `nF;
      while (n_rd) #TF;

      `HEADER("### test_write: t ###");
      data = 8'b01110100;
      n_cs = `nT; #TF;
      n_cs = `nF;
      while (n_rd) #TF;
   endtask

   // run test
   initial begin
      test_reset;
      test_write;
      $finish;
   end
endmodule
