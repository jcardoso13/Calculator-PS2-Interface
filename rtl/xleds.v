`timescale 1ns / 1ps

module xleds(
	 input clk, // clock source on Basys 3 FPGA
    input reset, // reset
	 output reg [7:0]	leds,
	 input 	[7:0] led_input,
	 input 	[7:0]	leds_sel,
	 input 			ram_led
	 );

reg [7:0] leds_buffer;

always @ (posedge clk)
begin
if (leds_sel[7]==1) begin
leds_buffer[7]<=led_input[7];
end
if (leds_sel[6]==1) begin
leds_buffer[6]<=led_input[6];
end
if (leds_sel[5]==1) begin
leds_buffer[5]<=led_input[5];
end
if (leds_sel[4]==1) begin
leds_buffer[4]<=led_input[4];
end
if (leds_sel[3]==1) begin
leds_buffer[3]<=led_input[3];
end
if (leds_sel[2]==1) begin
leds_buffer[2]<=led_input[2];
end
if (leds_sel[1]==1) begin
leds_buffer[1]<=led_input[1];
end
if (leds_sel[0]==1) begin
leds_buffer[0]<=ram_led;
end

leds = leds_buffer;


end


endmodule 