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
`define TICK_T _tb_t // alias for clock line

// initialize clock and internal registers
`define test_init(clk) \
   initial begin clk = 1; forever #TH clk = ~clk; end \
   reg `TICK_X = 0; reg [31:0] `TICK_N = 0; \
   wire `TICK_T; assign `TICK_T = clk

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

// check if expr becomes true within given ticks
`define test_event(msg, tick, expr) \
   begin \
      `LOG(("=== %s ===", msg)); \
      fork : `CAT(_test_event_, `__LINE__) \
         begin `TICK(tick); disable `CAT(_test_event_, `__LINE__); end \
         begin  wait(expr); disable `CAT(_test_event_, `__LINE__); end \
      join \
      `test_ok(msg, expr); \
   end

// check if expr stays true (= keeps state) within given ticks
`define test_state(msg, tick, expr) \
   begin \
      `LOG(("=== %s ===", msg)); \
      fork : `CAT(_test_state_, `__LINE__) \
         begin    `TICK(tick); disable `CAT(_test_state_, `__LINE__); end \
         begin wait(! (expr)); disable `CAT(_test_state_, `__LINE__); end \
      join \
      `test_ok(msg, expr); \
   end

`endif //  `ifndef COMMON_V
