`timescale 1ns / 1ps


module xdisplay(
		output [3:0] 	leds,
		output [6:0]		sevenseg,
		output				dp,
		output	[3:0]		anodes
);

//leds
assign leds = '0000';

//display
assign sevenseg = '1111111';
assign dp = '0';
assign anodes = '1000';

endmodule
