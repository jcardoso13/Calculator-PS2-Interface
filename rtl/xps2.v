`timescale 1ns / 1ps

module xps2 (
  input clk,
  input rst,
  input PS2_DATA,
  input PS2_CLK,
  output reg [10:0] data_out	//separated by nibles to express the key pressed
);



parameter idle    = 2'b01;
parameter receive = 2'b10;
parameter ready   = 2'b11;

reg [10:0] data_out1=11'h0;
reg [7:0] finished;
reg [7:0] opcode;
reg[7:0] data_out_pre;
reg [1:0]  state=idle;
reg [15:0] rxtimeout=16'b0000000000000000;
reg [10:0] rxregister=11'b11111111111;
reg [1:0]  datasr=2'b11;
reg [1:0]  clksr=2'b11;
reg [7:0]  rxdata;


reg datafetched;
reg rxactive;
reg dataready;

always @(posedge clk ) 
begin 
  rxtimeout<=rxtimeout+1;
  datasr <= {datasr[0],PS2_DATA};
  clksr  <= {clksr[0],PS2_CLK};


  if(clksr==2'b10)
    rxregister<= {datasr[1],rxregister[10:1]};


  case (state) 
    idle: 
    begin
      rxregister <=11'b11111111111;
      rxactive   <=0;
      dataready  <=0;
      rxtimeout  <=16'b0000000000000000;
      if(datasr[1]==0 && clksr[1]==1)
      begin
        state<=receive;
        rxactive<=1;
      end   
    end
    
    receive:
    begin
      if(rxtimeout==50000)
        state<=idle;
      else if(rxregister[0]==0)
      begin
        dataready<=1;
        rxdata<=rxregister[8:1];
        state<=ready;
        datafetched<=1;
      end
    end
    
    ready: 
    begin
      if(datafetched==1)
      begin
        state     <=idle;
        dataready <=0;
        rxactive  <=0;
      end  
    end  
  endcase
end 


always @(posedge clk) begin

if(datafetched==1) begin
	 data_out_pre <=rxdata;

if (data_out_pre == 8'h70)
data_out <= 8'h0;
else if (data_out_pre == 8'h69)
data_out <= 8'h1;
else if (data_out_pre == 8'h72)
data_out <= 8'h2;
else if (data_out_pre == 8'h7A)
data_out <= 8'h3;
else if (data_out_pre == 8'h6B)
data_out <= 8'h4;
else if (data_out_pre == 8'h73)
data_out <= 8'h5;
else if (data_out_pre == 8'h74)
data_out <= 8'h6;
else if (data_out_pre == 8'h6C)
data_out <= 8'h7;
else if (data_out_pre == 8'h75)
data_out <= 8'h8;
else if (data_out_pre == 8'h7D)
data_out <= 8'h9;
else
data_out <= data_out_pre;


end
/*
if (data_out_pre == 8'h54 )
opcode <= 8'h0; // +
else if (data_out_pre && 8'h4A == 1)
opcode <= 8'h1; // -
else if (data_out_pre && 8'h22 == 1)
opcode <= 8'h2; // x
else if (data_out_pre && 8'h3D == 1)
opcode <= 8'h3; // /
else if (data_out_pre && 8'h5A == 1)
finished <= 8'h1; // ENTER*/
end

endmodule 
