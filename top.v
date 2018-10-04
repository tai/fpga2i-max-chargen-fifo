`define CYCLE_1SEC 48000000 // 48MHz

//---------------------------------
// Top pf the FPGA
//---------------------------------
module top
  (
   input wire 	     clk, // 48MHzClock
   input wire 	     res_n, // Reset Switch
   input wire [2:0]  dip, // DIP switch
   output wire [2:0] led  // LED Output
   );

   assign led = dip;
   
endmodule
