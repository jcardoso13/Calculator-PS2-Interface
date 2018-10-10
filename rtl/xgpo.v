`timescale 1ns / 1ps
`include "xdefs.vh"


module xgpo (
			input		clk,
			input		rst,
			input wire	[7:0]	data_in,
			input		sel,
			output reg			[7:0]	data_out
			);
			
	
	always @ (posedge clk) begin
	if (rst) begin
	data_out <= 8'd0;
	end else if(sel) begin
	data_out <= data_in;
	end
	end
			
endmodule	
			
