// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
// -*- mode: verilog; coding: utf-8-unix -*-

`ifndef COMMON_V
`define COMMON_V

// TRUE/FALSE in negative/positive logic
`define nT '0
`define nF '1
`define pT '1
`define pF '0

// Example: `LOG(("value=%2d", value));
`define LOG(s) $write("%6t ", $time); $display s

//
//
typedef logic [0:0] b1_t;
typedef logic [3:0] b4_t;
typedef logic [7:0] b8_t;
typedef logic [15:0] b16_t;
typedef logic [31:0] b32_t;
  
//
// assertion support
//

`define test_eq(msg, arg1, arg2) \
   if ((arg1) !== (arg2)) begin \
      $display("NG: %s:%0d - %s", `__FILE__, `__LINE__, msg); \
      $display("NG: arg-1: arg1"); \
      $display("NG: arg-2: arg2"); \
      $finish; \
   end

`define test_ok(msg, arg) `test_eq(msg, 1==1, arg)
`define test_ng(msg, arg) `test_eq(msg, 1==0, arg)

`define test_fail(msg) \
   $display("NG: %s", `__FILE__); \
   $finish

`define test_pass(msg) \
   $display("OK: %s", `__FILE__); \
   $finish

`endif //  `ifndef COMMON_V
