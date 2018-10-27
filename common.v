// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
// -*- mode: verilog; coding: utf-8-unix -*-

`ifndef COMMON_V
`define COMMON_V

// clock speed (default: 50MHz)
`define CYCLE_1s  50_000_000

// TRUE/FALSE in negative/positive logic
`define nT '0
`define nF '1
`define pT '1
`define pF '0

// for macro hacking
`define STR(x) `"x`"
`define VAL(a) a
`define CAT(a,b) `VAL(a)/**/`VAL(b)

// stringfy
`define _(x) `"x`"

// Example: `LOG(("value=%2d", value));
`define LOG(s) $write("%6t ", $time); $display s
`define ERR(s) $display s
`define OUT(s) $display s
`define FMT(s) $sformatf s

//////////////////////////////////////////////////////////////////////
// testbench helpers
//////////////////////////////////////////////////////////////////////

// basic timing(s)
parameter T0 = 10;  // small offset to avoid race with clock edge
parameter TH = 50;  // width of half cycle
parameter TF = 100; // width of full cycle

// internal registers
`define TICK_X _tb_x // dummy bit for $monitor to trigger output on TICK()
`define TICK_N _tb_n // tick count
`define TICK_T _tb_t // test clock (wire)
`define TICK_D _tb_d // test clock driver (reg)

// initialize base clock, phase-shifted test clock, and internal registers
`define test_init(clk) \
   initial begin clk = 1; forever #TH clk = ~clk; end \
   initial begin #T0 `TICK_D = 1; forever #TH `TICK_D = ~`TICK_D; end \
   reg `TICK_X = 0; reg [31:0] `TICK_N = 0; \
   reg `TICK_D; wire `TICK_T; assign `TICK_T = clk /* use TICK_D or clk */

// wait for next tick
`define TICK(n) \
   begin \
      if (n > 0) repeat(n) @(posedge `TICK_T); \
      `TICK_X = ~`TICK_X; `TICK_N = `TICK_N + 1; #1; \
   end

//
// assertions
//

// report success
`define test_pass(msg) \
   begin \
      $display("OK: %s:%0d", `__FILE__, `__LINE__); \
      $finish; \
   end

// report failure
`define test_fail(msg) \
   begin \
      $display("NG: %s:%0d", `__FILE__, `__LINE__); \
      $finish; \
   end

// check if expr is true (fail if not true)
`define test_ok(msg, expr) \
   if (! (expr)) begin \
      `LOG(("NG")); \
      `ERR(("NG: %s at %s:%0d", msg, `__FILE__, `__LINE__)); \
      `ERR(("NG: expr")); \
      `TICK(10) $finish; \
   end \
   else begin \
      `LOG(("OK: %s", msg)); \
   end

// check if expr is false (fail if not false)
`define test_ng(msg, expr) `test_ok(msg, ! (expr))

// compare args
`define test_op(msg, arg1, arg2, op) \
   if ((arg1) op (arg2)) begin \
      `LOG(("NG")); \
      `ERR(("NG: %s at %s:%0d", msg, `__FILE__, `__LINE__)); \
      `ERR(("NG: arg1 = %x", arg1)); \
      `ERR(("NG: arg2 = %x", arg2)); \
      `TICK(10) $finish; \
   end \
   else begin \
      `LOG(("OK: %s", msg)); \
   end

// check if args are equal (fail if not equal)
`define test_eq(msg, arg1, arg2) `test_op(msg, arg1, arg2, !==)

// check if args are not equal (fail if equal)
`define test_ne(msg, arg1, arg2) `test_op(msg, arg1, arg2, ===)

// check if expr becomes true in next tick and after, within given deadline
`define test_event(msg, t, expr) \
   begin \
      `LOG(("=== %s ===", msg)); \
      fork : `CAT(_test_event_, `__LINE__) \
         begin `TICK(t);         #1; disable `CAT(_test_event_, `__LINE__); end \
         begin `TICK(1); wait(expr); disable `CAT(_test_event_, `__LINE__); end \
      join \
      `test_ok(msg, expr); \
   end

// check if expr stays true (= keeps state) within given ticks
`define test_state(msg, k, expr) \
   begin \
      `LOG(("=== %s ===", msg)); \
      fork : `CAT(_test_state_, `__LINE__) \
         begin       `TICK(k); disable `CAT(_test_state_, `__LINE__); end \
         begin wait(! (expr)); disable `CAT(_test_state_, `__LINE__); end \
      join \
      `test_ok(msg, expr); \
   end

// check if expr happens within deadline (t) and keeps for given time (k)
`define test_signal(msg, t, k, expr) \
   begin \
      `LOG(("=== %s (%0dT, %0dT) ===", msg, t, k)); \
      fork : `CAT(_test_signal_event_, `__LINE__) \
         begin `TICK(t);         #1; disable `CAT(_test_signal_event_, `__LINE__); end \
         begin `TICK(1); wait(expr); disable `CAT(_test_signal_event_, `__LINE__); end \
      join \
      `test_ok(`FMT(("%s (S)", msg)), expr); \
      if ((k) > 0) begin \
         fork : `CAT(_test_signal_state_, `__LINE__) \
            begin `TICK((k) - 1); disable `CAT(_test_signal_state_, `__LINE__); end \
            begin wait(! (expr)); disable `CAT(_test_signal_state_, `__LINE__); end \
         join \
         `test_ok(`FMT(("%s (E)", msg)), expr); \
      end \
   end

//  test - compare with 'x as a wildcard
`define tmp_eq(s_exp, s_got, ret) \
   begin \
      ret = 1; \
      for (int i = 0; i < $size(s_exp); i=i+1) begin \
         if ((s_exp[i] !== 'x) && (s_exp[i] !== s_got[i])) begin \
            ret = 0; \
         end \
      end \
   end

`endif //  `ifndef COMMON_V
