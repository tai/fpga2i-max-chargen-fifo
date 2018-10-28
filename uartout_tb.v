// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module uartout_tb;
   `test_init(clk);

   parameter CDIV = 2;

   reg clk, n_rst, valid_n, ready_n, tx;
   reg [7:0] data;
   
   uartout #(.CDIV(CDIV)) uartout0(.*);

   initial begin : logging
`define HEADER(s) \
      if (s != "") $display(s); \
      $display("# time x nRST nVLD nRDY IN DAT SD N TX")
      $monitor("%6t %1b %4b %4b %4b %2c %3c %2b %1d %2b",
	       $time, `TICK_X,
	       n_rst, valid_n, ready_n,
	       data, uartout0.data_in,
	       uartout0.is_sending, uartout0.tx_index, tx);
      $timeformat(-9, 0, "", 6);

      $dumpfile("uartout_tb.vcd");
      $dumpvars(1, uartout0);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   // insert header for readability
   always #(TF * 5) begin `HEADER(""); end

   initial begin : test_main
      test_reset();
      test_write();
      test_write_overlap();
      `test_pass();
   end

   //////////////////////////////////////////////////////////////////////

   task do_reset;
      `HEADER("# do_reset");
      n_rst = `nT; #1;
      n_rst = `nF;
   endtask

   task test_reset;
      `HEADER("### test_reset ###");
      `TICK(1);
      do_reset();
      `test_ok("Data should be empty", uartout0.is_empty === `nF);
      `test_ok("TX should be high", tx === 1);
   endtask

   task test_write;
      static string buff = "abc";

      `HEADER("### test_write: reset ###");
      do_reset();

      for (int i = 0; i < buff.len(); i++) begin
         data = buff[i];

	 `HEADER(`FMT(("### test_write: [%c:%8b] ###", data, data)));

	 // START bit
	 valid_n = `nT;
	 `test_signal("Should see START as TX=0",
		      1, CDIV, (ready_n === `nF) && (tx === 0));

	 // TX bits
	 valid_n = `nF;
	 for (int bi = 0; bi < 8; bi++) begin
	    `test_signal(`FMT(("Should see bit %1d as TX=%1b", bi, data[bi])),
			 1, CDIV, tx === data[bi]);
	 end
	 `test_eq("Should be ready again", ready_n, `nT);

	 // STOP bit
 	 `test_signal("Should see STOP as TX=1", 1, CDIV, tx === 1);
      end

      `TICK(CDIV * 8);
   endtask

   task test_write_overlap;
      static string buff = "abc";
      static reg [7:0] ch;

      `HEADER("### test_write_overlap: reset ###");
      do_reset();

      for (int i = 0; i < buff.len(); i++) begin
         data = buff[i];
         ch   = buff[i];

	 `HEADER(`FMT(("### test_write_overlap: [%c:%8b] ###", ch, ch)));

	 // START bit
	 valid_n = `nT;
	 `test_signal("Should see START as TX=0",
		      1, CDIV, (ready_n === `nF) && (tx === 0));

	 // push next data on line, so overlapped read can happen
	 if (i < buff.len() - 1) begin
	    data = buff[i + 1];
	 end

	 // TX bits
	 for (int bi = 0; bi < 8; bi++) begin
	    `test_signal(`FMT(("Should see bit %1d as TX=%1b", bi, ch[bi])),
			 1, CDIV, tx === ch[bi]);
	 end

	 `test_eq("Should already be off by overlapped read", ready_n, `nF);

	 // STOP bit
 	 `test_signal("Should see STOP as TX=1", 1, CDIV, tx === 1);
      end

      `TICK(CDIV * 8);
   endtask
endmodule
