`timescale 1ns / 1ps

module xps2 (
  input clk,
  input rst,
  input PS2_DATA,
  input PS2_CLK,
  output reg [31:0] data_out,	//separated by nibles to express the key pressed
  output  reg [7:0] cnt2
);



parameter idle    = 2'b01;
parameter receive = 2'b10;
parameter ready   = 2'b11;


reg [2:0]cnt=3'h0;
reg enter;
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
reg [7:0] reg1,reg2,reg3,reg4;
reg [7:0] aux;
reg [7:0] data_previous;
reg data_rst = 0;
reg [13:0] aux_cnt3,aux_cnt2,aux_cnt1;
//reg [3:0]cnt2 =0;
reg active=0;
reg rxactive;
reg dataready;
reg datafetched;

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
		datafetched <=0;
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

always @(posedge clk) beginif(state==ready) begin
	cnt2=cnt2+1;
	 data_out_pre <=rxdata;
	end
else data_out_pre <= 8'h0;


if (data_out_pre == 8'h70) begin //0
aux <= 8'h00;
end
else if (data_out_pre == 8'h69) begin //1
aux <= 8'h1;
end
else if (data_out_pre == 8'h72) begin //2
aux <= 8'h2;
end
else if (data_out_pre == 8'h7A) begin //3
aux <= 8'h3;
end
else if (data_out_pre == 8'h6B) begin //4
aux <= 8'h4;
end
else if (data_out_pre == 8'h73) begin //5
aux <= 8'h5;
end
else if (data_out_pre == 8'h74) begin //6
aux <= 8'h6;
end
else if (data_out_pre == 8'h6C) begin //7
aux <= 8'h7;
end
else if (data_out_pre == 8'h75) begin //8
aux <= 8'h8;
end
else if (data_out_pre == 8'h7D) begin //9
aux <= 8'h9;
end
else if (data_out_pre == 8'h5A) begin // Enter
aux <= 8'h11;
end
else if (data_out_pre == 8'hF0) begin // Release Code
aux <= 8'h12;
end
else aux <=8'h10;
//else begin
//aux <= 8'h10;
//end
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



always @(posedge clk)
begin
if (rst) begin
reg1 = 8'h0;
reg2 = 8'h0;
reg3 = 8'h0;
reg4 = 8'h0;
cnt <=0;
end


if ((aux!=8'h10) && (aux!=8'h11) && (aux!=8'h12) && active==1) begin
		case (cnt)
		0: begin	
		reg1 = aux;
		reg2 =0;
		reg3 =0;
		reg4 =0;
		aux_cnt1<=0;
		aux_cnt2<=0;
		aux_cnt3<=0;
		cnt<=cnt+1;
		end
		1: begin
		reg2 = reg1;
		reg1 = aux;
		reg3 = 0;
		reg4 = 0;
		aux_cnt1<=10;
		aux_cnt2<=0;
		aux_cnt3<=0;
		cnt<=cnt+1;
		end
		2: begin
		reg3 = reg2;
		reg2 = reg1;
		reg1 = aux;
		reg4 =0;
		aux_cnt1<=10;
		aux_cnt2<=100;
		aux_cnt3<=0;
		cnt<=cnt+1;
		end
		3: begin 
		reg4 = reg3;
		reg3 = reg2;
		reg2 = reg1;
		reg1 = aux;
		aux_cnt1<=10;
		aux_cnt2<=100;
		aux_cnt3<=1000;
		cnt<=cnt+1;
		end
		default:  begin
			reg1 = 8'h0;
			reg2 = 8'h0;
			reg3 = 8'h0;
			reg4 = 8'h0;
			cnt <=0;
		end
		endcase
		enter <=0;
		active =0;
		end
		else if (aux==8'h12) begin
		active=1;
		end
		else if (aux==8'h11) begin
			cnt <= 5;
			enter <=1;
			end
end


always @(posedge clk) begin

if(rst) begin
data_out=32'h0;
end
else if(enter==1'b1) begin
data_out[14:0]=reg1+(reg2*aux_cnt1)+(reg3*aux_cnt2)+(reg4*aux_cnt3);
data_out[15]=1'b1;

//data_rst<=1;
end
//else
//data_rst<=0;
end

endmodule 
