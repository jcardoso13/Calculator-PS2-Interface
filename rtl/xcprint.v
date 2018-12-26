`timescale 1ns / 1ps
`include "xdefs.vh"

module xcprint (
		input 	    clk,
		input 	    sel,
		input [7:0] data_in
		);

 always @(posedge clk)
   if(sel)
     $write("%c", data_in);

endmodule
