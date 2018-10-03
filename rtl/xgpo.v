`timescale 1ns / 1ps
`include "xdefs.vh"


module xgpo (
			input		clk,
			input		rst,
			input wire	[`DATA_W-1:0]	data_in,
			input		sel,
			output reg 	[`DATA_W-1:0]	data_out
			);
			
	
	always @ (posedge clk) begin
	if (rst) begin
	data_out= `DATA_W'd0;
	end else if(sel) begin
	data_out <= data_in;
	end
	end
			
endmodule	
			
