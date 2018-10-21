// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`timescale 1ns/1ps

`include "common.v"

module uartout_tb;
   `test_init(clk);

   parameter CDIV = 2;

   reg clk, n_rst, n_valid, n_ready, tx;
   reg [7:0] data;
   
   uartout #(.CDIV(CDIV)) uartout_00(.*);

   initial begin : logging
`define HEADER(s) \
      $display(s); \
      $display("# time x nRST nVLD nRDY IN TX IDX")
      $monitor("%6t %1b %4b %4b %4b %2c %2b %3d",
	       $time, `TICK_X, n_rst, n_valid, n_ready, data, tx,
	       uartout_00.tx_index);
      $timeformat(-9, 0, "", 6);

      $dumpfile("uartout_tb.vcd");
      $dumpvars(1, uartout_00);
      $dumplimit(1_000_000); // stop dump at 1MB
   end

   //////////////////////////////////////////////////////////////////////

   initial begin : test_main
      test_reset();
      test_write();
      `test_pass();
   end

   task test_reset;
      `HEADER("### test_reset ###");
      `TICK(1);
      n_rst = `nT;
      `TICK(0);
      `test_ok("Data should be cleared", uartout_00.n_empty === `nT);
      `test_ok("TX should be high", tx === 1);
      n_rst = `nF;
   endtask

   task test_write;
      `HEADER("### test_write: nVLD=nF ###");
      n_valid = `nF;
      `TICK(1);
      `test_ok("Data should still be empty", uartout_00.n_empty === `nT);
      `test_eq("TX should still be high", tx, 1);

      `HEADER("### test_write: S (0x53) ###");
      data = 8'h53;
      n_valid = `nT;
      `TICK(1);
      `test_ok("Data should be valid", uartout_00.n_empty === `nF);
      n_valid = `nF;
      
      `test_eq("TX START should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 7 should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 6 should be 1", tx, 1); `TICK(CDIV);
      `test_eq("TX bit 5 should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 4 should be 1", tx, 1); `TICK(CDIV);
      `test_eq("TX bit 3 should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 2 should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 1 should be 1", tx, 1); `TICK(CDIV);
      `test_eq("TX bit 0 should be 1", tx, 1); `TICK(CDIV);
      `test_eq("TX STOP  should be 1", tx, 1);

      // NOTE: Should be ready right after bit 0 (before STOP bit)
      wait (n_ready === `nT);

      `HEADER("### test_write: t (0x74) ###");
      data = 8'h74;
      n_valid = `nT;
      `TICK(1);
      `test_ok("Data should be valid", uartout_00.n_empty === `nF);
      n_valid = `nF;
      
      `test_eq("TX START should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 7 should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 6 should be 1", tx, 1); `TICK(CDIV);
      `test_eq("TX bit 5 should be 1", tx, 1); `TICK(CDIV);
      `test_eq("TX bit 4 should be 1", tx, 1); `TICK(CDIV);
      `test_eq("TX bit 3 should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 2 should be 1", tx, 1); `TICK(CDIV);
      `test_eq("TX bit 1 should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX bit 0 should be 0", tx, 0); `TICK(CDIV);
      `test_eq("TX STOP  should be 1", tx, 1);
   endtask
endmodule
