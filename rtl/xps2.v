`timescale 1ns / 1ps


module xps2(
					input PS2_CLK,
					input PS2_DATA,
					input clk,
					input rst,
					output reg [10:0] data_out,
					output reg done
					);



	reg [10:0] data_in;
	reg [3:0] counter;
	
initial begin

done=1'd0;
data_in=11'd0;
counter=3'd0;

end



always @(posedge PS2_CLK) begin

	if (done==0) begin
	data_in <={PS2_DATA,data_in[10:1]};
	counter <=counter+1;
	end
	if (rst) begin
		data_in <=11'd0;
		counter <=3'd0;
	end
end

always @(posedge clk) begin

if (counter==11) begin
		done <= 1'd1;
		data_out <= data_in;
	end

if (rst) begin
data_out<=11'd0;
done <= 1'd0;
end

end



endmodule